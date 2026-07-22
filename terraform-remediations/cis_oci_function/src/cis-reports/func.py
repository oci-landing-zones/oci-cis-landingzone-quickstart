import io
import hashlib
import importlib.util
import inspect
import json
import logging
import datetime
import sys
import time
from pathlib import Path
from urllib.parse import unquote

import oci
import oci.object_storage
import oci.ons
import pytz
import requests

logger = logging.getLogger(__name__)

CIS_REPORTS_FILENAME = "cis_reports.py"
CIS_SUMMARY_REPORT_FILENAME = "cis_summary_report.html"
HTML_NOTIFICATION_PAR_EXPIRATION_HOURS = 4
CIS_REPORTS_REPO_RAW_URL = (
    "https://raw.githubusercontent.com/"
    "oci-landing-zones/oci-cis-landingzone-quickstart"
)


def _parse_bool(value, default=False):
    if isinstance(value, bool):
        return value
    if value is None:
        return default
    return str(value).strip().lower() in ("1", "true", "t", "yes", "y", "on")


def _parse_report_level(value):
    try:
        report_level = int(value)
    except (TypeError, ValueError) as exc:
        raise ValueError("report_level must be 1 or 2") from exc

    if report_level not in (1, 2):
        raise ValueError("report_level must be 1 or 2")
    return report_level


def _normalize_script_version(script_version):
    normalized = str(script_version or "latest").strip()
    return normalized or "latest"


def _script_url(script_version):
    script_version = _normalize_script_version(script_version)
    if script_version.lower() in ("latest", "bundled"):
        ref_path = "refs/heads/main"
    else:
        ref_path = f"refs/tags/{script_version}"

    return f"{CIS_REPORTS_REPO_RAW_URL}/{ref_path}/scripts/{CIS_REPORTS_FILENAME}"


def _import_cis_reports_module(module_path):
    logger.info("Loading CIS reports module from %s", module_path)
    spec = importlib.util.spec_from_file_location("cis_reports", module_path)
    if spec is None or spec.loader is None:
        raise ImportError(f"Unable to load module spec from {module_path}")

    cis_reports = importlib.util.module_from_spec(spec)
    sys.modules["cis_reports"] = cis_reports
    spec.loader.exec_module(cis_reports)
    return cis_reports


def _download_cis_reports(script_version):
    url = _script_url(script_version)
    destination = Path("/tmp") / CIS_REPORTS_FILENAME

    logger.info("Downloading CIS reports script version '%s' from %s", script_version, url)
    try:
        response = requests.get(url, timeout=60)
        response.raise_for_status()
        destination.write_text(response.text, encoding="utf-8")
    except requests.RequestException:
        logger.exception("Failed to download CIS reports script from %s", url)
        raise
    except OSError:
        logger.exception("Failed to write CIS reports script to %s", destination)
        raise

    logger.info("Downloaded CIS reports script to %s", destination)
    return destination


def _load_cis_report_class(script_version):
    script_version = _normalize_script_version(script_version)
    local_paths = [
        Path.cwd() / CIS_REPORTS_FILENAME,
        Path(__file__).resolve().parent / CIS_REPORTS_FILENAME,
    ]

    if script_version.lower() == "bundled":
        for local_path in dict.fromkeys(local_paths):
            if local_path.exists():
                logger.info("Using local CIS reports script at %s", local_path)
                module = _import_cis_reports_module(local_path)
                break
        else:
            logger.warning("No bundled CIS reports script found; downloading latest instead")
            downloaded_path = _download_cis_reports("latest")
            module = _import_cis_reports_module(downloaded_path)
    else:
        downloaded_path = _download_cis_reports(script_version)
        module = _import_cis_reports_module(downloaded_path)

    try:
        return module.CIS_Report
    except AttributeError as exc:
        logger.exception("CIS_Report class was not found in %s", module.__file__)
        raise ImportError("CIS_Report class was not found in the CIS reports script") from exc


def _read_json_payload(data):
    if data is None:
        return None

    try:
        raw_body = data.getvalue() if hasattr(data, "getvalue") else data.read()
    except (AttributeError, OSError):
        logger.exception("Unable to read invocation payload")
        return None

    if not raw_body:
        return None

    if isinstance(raw_body, bytes):
        raw_body = raw_body.decode("utf-8")

    try:
        payload = json.loads(raw_body)
    except (TypeError, ValueError):
        logger.info("Invocation payload is not JSON; continuing with report generation")
        return None

    logger.info("Invocation payload summary: %s", _payload_summary(payload))
    return payload


OBJECT_STORAGE_HTML_EVENT_TYPES = {
    "com.oraclecloud.objectstorage.createobject",
    "com.oraclecloud.objectstorage.updateobject",
}


def _payload_summary(payload):
    if isinstance(payload, dict):
        keys = ",".join(sorted(str(key) for key in payload.keys())[:12])
        event_type = payload.get("eventType") or payload.get("type")
        return f"dict keys=[{keys}] event_type={event_type or 'none'}"
    if isinstance(payload, list):
        return f"list length={len(payload)}"
    return type(payload).__name__


def _json_value(value):
    if isinstance(value, str):
        try:
            return json.loads(value)
        except ValueError:
            return value
    return value


def _find_object_storage_event(payload, depth=0):
    """Find the first recognized Object Storage event in a nested payload."""
    if depth > 4:
        return None

    payload = _json_value(payload)
    if isinstance(payload, list):
        for item in payload:
            event = _find_object_storage_event(item, depth + 1)
            if event:
                return event
        return None

    if not isinstance(payload, dict):
        return None

    if _is_object_storage_event(payload):
        return payload

    for key in ("event", "events", "payload", "body", "message", "data"):
        if key in payload:
            event = _find_object_storage_event(payload[key], depth + 1)
            if event:
                return event

    return None


def _is_object_storage_event(payload):
    if not isinstance(payload, dict):
        return False

    event_type = payload.get("eventType") or payload.get("type")
    return event_type in OBJECT_STORAGE_HTML_EVENT_TYPES


def _object_name_from_resource_id(resource_id):
    if not resource_id or "/o/" not in resource_id:
        return ""
    return unquote(resource_id.split("/o/", 1)[1])


def _normalize_object_name(object_name):
    return unquote(str(object_name or "").strip())


def _is_summary_report_object(object_name):
    normalized = _normalize_object_name(object_name).rstrip("/")
    return normalized.split("/")[-1] == CIS_SUMMARY_REPORT_FILENAME


def _extract_html_event_details(event, cfg):
    """Extract the bucket, object, namespace, region, and event metadata."""
    event_data = event.get("data") or {}
    additional_details = event_data.get("additionalDetails") or {}

    object_name = _normalize_object_name(
        event_data.get("resourceName")
        or additional_details.get("objectName")
        or _object_name_from_resource_id(event_data.get("resourceId"))
    )
    namespace = (
        additional_details.get("namespace")
        or additional_details.get("namespaceName")
        or cfg.get("html_notification_object_storage_namespace")
    )

    return {
        "bucket_name": additional_details.get("bucketName") or cfg.get("output_bucket"),
        "object_name": object_name,
        "event_time": event.get("eventTime") or event.get("time"),
        "compartment_id": event_data.get("compartmentId"),
        "compartment_name": event_data.get("compartmentName"),
        "namespace": namespace,
        "region": (
            additional_details.get("region")
            or additional_details.get("regionId")
            or event.get("region")
            or cfg.get("html_notification_object_storage_region")
        ),
    }


def _notification_title(details):
    return f"OCI CIS summary report ready: {details['object_name']}"


def _format_compartment(details):
    compartment_id = details.get("compartment_id")
    compartment_name = details.get("compartment_name")
    if compartment_name and compartment_id:
        return f"{compartment_name} ({compartment_id})"
    return compartment_name or compartment_id or "unknown"


def _format_utc(timestamp):
    if not timestamp:
        return "unknown"
    return timestamp.astimezone(datetime.timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def _build_notification_body(details, par_link, expiration_hours, par_error=None):
    sent_at = datetime.datetime.now(datetime.timezone.utc)
    expires_at = sent_at + datetime.timedelta(hours=expiration_hours)
    lines = [
        "An OCI CIS summary report is ready.",
        "",
        f"Bucket name: {details.get('bucket_name') or 'unknown'}",
        f"Object name: {details.get('object_name') or 'unknown'}",
        f"Event time: {details.get('event_time') or 'unknown'}",
        f"Compartment: {_format_compartment(details)}",
        f"Namespace: {details.get('namespace') or 'unknown'}",
        f"Region: {details.get('region') or 'unknown'}",
        f"Email sent time: {_format_utc(sent_at)}",
        "",
    ]
    if par_link:
        lines.extend([
            f"Pre-authenticated request link (ObjectRead, valid for {expiration_hours} hours):",
            par_link,
            f"PAR expires at: {_format_utc(expires_at)}",
            "",
            (
                "Important: If the report is not retrieved from this pre-authenticated URL within "
                f"{expiration_hours} hours of this email being sent, the link will expire and the "
                "report will need to be retrieved manually from Object Storage."
            ),
        ])
    else:
        lines.extend([
            "Pre-authenticated request link: unavailable",
            f"PAR creation error: {par_error or 'unknown'}",
        ])
    return "\n".join(lines)


def _object_storage_endpoint(object_storage_client, region):
    base_client = getattr(object_storage_client, "base_client", None)
    endpoint = getattr(base_client, "endpoint", None)
    return (endpoint or f"https://objectstorage.{region}.oraclecloud.com").rstrip("/")


def _wait_for_object_readable(object_storage_client, details, max_attempts=6):
    for attempt in range(1, max_attempts + 1):
        try:
            object_storage_client.head_object(
                details["namespace"],
                details["bucket_name"],
                details["object_name"],
            )
            logger.info(
                "Confirmed Object Storage object exists before PAR creation: namespace=%s bucket=%s object=%s",
                details["namespace"],
                details["bucket_name"],
                details["object_name"],
            )
            return
        except Exception as exc:
            status = getattr(exc, "status", None)
            code = getattr(exc, "code", None)
            logger.warning(
                "Object existence check attempt %s failed for bucket=%s object=%s status=%s code=%s error=%s",
                attempt,
                details["bucket_name"],
                details["object_name"],
                status,
                code,
                exc,
            )
            if attempt < max_attempts and status == 404:
                time.sleep(min(2 * attempt, 10))
                continue
            raise


def _create_html_report_par(config, signer, details, expiration_hours):
    """Confirm the report exists and create an ObjectRead pre-authenticated request."""
    client_config = dict(config)
    if details.get("region"):
        client_config["region"] = details["region"]

    logger.info(
        "Creating ObjectRead PAR for namespace=%s bucket=%s object=%s region=%s",
        details.get("namespace"),
        details.get("bucket_name"),
        details.get("object_name"),
        client_config.get("region"),
    )
    object_storage_client = oci.object_storage.ObjectStorageClient(client_config, signer=signer)
    _wait_for_object_readable(object_storage_client, details)
    now = datetime.datetime.now(datetime.timezone.utc)
    expires = now + datetime.timedelta(hours=expiration_hours)
    digest_source = (
        f"{details.get('namespace')}/{details.get('bucket_name')}/"
        f"{details.get('object_name')}/{details.get('event_time')}/{now.isoformat()}"
    )
    digest = hashlib.sha256(digest_source.encode("utf-8")).hexdigest()[:16]
    par_name = f"cis-html-report-{digest}"

    par_details = oci.object_storage.models.CreatePreauthenticatedRequestDetails(
        name=par_name,
        object_name=details["object_name"],
        access_type=oci.object_storage.models.CreatePreauthenticatedRequestDetails.ACCESS_TYPE_OBJECT_READ,
        time_expires=expires,
    )
    last_error = None
    for attempt in range(1, 4):
        try:
            par = object_storage_client.create_preauthenticated_request(
                details["namespace"],
                details["bucket_name"],
                par_details,
            ).data
            break
        except Exception as exc:
            last_error = exc
            logger.warning("PAR creation attempt %s failed: %s", attempt, exc)
            if attempt < 3:
                time.sleep(2 * attempt)
    else:
        raise last_error

    access_uri = getattr(par, "access_uri", None) or getattr(par, "full_path", None)
    if not access_uri:
        raise RuntimeError("Object Storage did not return a PAR access URI")
    if access_uri.startswith("http://") or access_uri.startswith("https://"):
        return access_uri
    if not access_uri.startswith("/"):
        access_uri = f"/{access_uri}"
    return f"{_object_storage_endpoint(object_storage_client, client_config['region'])}{access_uri}"


def _publish_html_report_notification(config, signer, cfg, details, par_link, expiration_hours, par_error=None):
    topic_id = cfg.get("html_notification_topic_id")
    if not topic_id:
        raise RuntimeError("html_notification_topic_id is not configured")

    topic_endpoint = cfg.get("html_notification_topic_endpoint")
    message = oci.ons.models.MessageDetails(
        title=_notification_title(details),
        body=_build_notification_body(details, par_link, expiration_hours, par_error=par_error),
    )

    endpoints = [topic_endpoint, None] if topic_endpoint else [None]
    last_error = None
    for endpoint in endpoints:
        client_kwargs = {"signer": signer}
        if endpoint:
            client_kwargs["service_endpoint"] = endpoint

        try:
            logger.info("Publishing HTML report notification to topic %s using endpoint %s", topic_id, endpoint or "default")
            notification_client = oci.ons.NotificationDataPlaneClient(config, **client_kwargs)
            notification_client.publish_message(topic_id, message, message_type="RAW_TEXT")
            return
        except Exception as exc:
            last_error = exc
            logger.warning("PublishMessage failed using endpoint %s: %s", endpoint or "default", exc)

    raise last_error


def _publish_diagnostic_notification(config, signer, cfg, title, body):
    topic_id = cfg.get("html_notification_topic_id")
    if not topic_id:
        logger.warning("Unable to publish diagnostic notification because html_notification_topic_id is not configured")
        return

    topic_endpoint = cfg.get("html_notification_topic_endpoint")
    endpoints = [topic_endpoint, None] if topic_endpoint else [None]
    message = oci.ons.models.MessageDetails(title=title, body=body)
    for endpoint in endpoints:
        client_kwargs = {"signer": signer}
        if endpoint:
            client_kwargs["service_endpoint"] = endpoint
        try:
            logger.info("Publishing diagnostic notification to topic %s using endpoint %s", topic_id, endpoint or "default")
            notification_client = oci.ons.NotificationDataPlaneClient(config, **client_kwargs)
            notification_client.publish_message(topic_id, message, message_type="RAW_TEXT")
            return
        except Exception as exc:
            logger.warning("Diagnostic PublishMessage failed using endpoint %s: %s", endpoint or "default", exc)


def _handle_html_report_event(config, signer, cfg, event):
    if not _parse_bool(cfg.get("html_notification_enabled")):
        logger.info("HTML report notification event received, but notifications are disabled")
        return {"notified": False, "reason": "notifications disabled"}

    details = _extract_html_event_details(event, cfg)
    object_name = details.get("object_name") or ""
    if not _is_summary_report_object(object_name):
        logger.info("Ignoring Object Storage event for object '%s'; only %s is notified", object_name, CIS_SUMMARY_REPORT_FILENAME)
        return {"notified": False, "reason": f"object is not {CIS_SUMMARY_REPORT_FILENAME}"}

    required_fields = ["namespace", "bucket_name", "object_name", "region"]
    missing_fields = [field for field in required_fields if not details.get(field)]
    if missing_fields:
        raise ValueError(f"Object Storage event missing required fields: {', '.join(missing_fields)}")

    expiration_hours = HTML_NOTIFICATION_PAR_EXPIRATION_HOURS
    par_link = None
    par_error = None
    try:
        par_link = _create_html_report_par(config, signer, details, expiration_hours)
    except Exception as exc:
        par_error = str(exc)
        logger.exception("Failed to create HTML report PAR; sending notification without PAR link")

    _publish_html_report_notification(config, signer, cfg, details, par_link, expiration_hours, par_error=par_error)
    logger.info(
        "Published HTML report notification for bucket=%s object=%s",
        details["bucket_name"],
        details["object_name"],
    )
    return {
        "notified": True,
        "bucket_name": details["bucket_name"],
        "object_name": details["object_name"],
    }


def _summary_report_object_candidates(report_directory):
    """Return possible Object Storage names for the generated summary report."""
    report_path = Path(report_directory or "/tmp")
    candidates = []

    if report_path.exists():
        for summary_path in sorted(report_path.rglob(CIS_SUMMARY_REPORT_FILENAME)):
            candidates.append(str(summary_path))
            try:
                candidates.append(str(summary_path.relative_to(Path("/tmp"))))
            except ValueError:
                pass
            candidates.append(summary_path.name)

    expected_path = report_path / CIS_SUMMARY_REPORT_FILENAME
    candidates.extend([str(expected_path), CIS_SUMMARY_REPORT_FILENAME])

    unique_candidates = []
    for candidate in candidates:
        if candidate and candidate not in unique_candidates:
            unique_candidates.append(candidate)
    return unique_candidates


def _generated_html_report_details(config, signer, cfg, bucket_name, report_directory, event_time):
    namespace = cfg.get("html_notification_object_storage_namespace")
    region = cfg.get("html_notification_object_storage_region") or config.get("region")
    if not namespace:
        raise ValueError("html_notification_object_storage_namespace is not configured")
    if not region:
        raise ValueError("html_notification_object_storage_region is not configured")

    client_config = dict(config)
    client_config["region"] = region
    object_storage_client = oci.object_storage.ObjectStorageClient(client_config, signer=signer)
    base_details = {
        "bucket_name": bucket_name,
        "event_time": event_time,
        "compartment_id": cfg.get("html_notification_output_bucket_compartment_id"),
        "compartment_name": cfg.get("html_notification_output_bucket_compartment_name"),
        "namespace": namespace,
        "region": region,
    }

    errors = []
    for object_name in _summary_report_object_candidates(report_directory):
        details = dict(base_details)
        details["object_name"] = object_name
        try:
            _wait_for_object_readable(object_storage_client, details, max_attempts=2)
            return details
        except Exception as exc:
            errors.append(f"{object_name}: {exc}")

    raise FileNotFoundError(
        "Unable to confirm cis_summary_report.html in Object Storage. Tried: "
        + "; ".join(errors)
    )


def _publish_generated_html_report_notification(config, signer, cfg, bucket_name, report_directory):
    if not _parse_bool(cfg.get("html_notification_enabled")):
        logger.info("HTML report notifications are disabled")
        return {"notified": False, "reason": "notifications disabled"}

    event_time = _format_utc(datetime.datetime.now(datetime.timezone.utc))
    details = _generated_html_report_details(config, signer, cfg, bucket_name, report_directory, event_time)
    expiration_hours = HTML_NOTIFICATION_PAR_EXPIRATION_HOURS
    par_link = None
    par_error = None

    try:
        par_link = _create_html_report_par(config, signer, details, expiration_hours)
    except Exception as exc:
        par_error = str(exc)
        logger.exception("Failed to create HTML report PAR; sending notification without PAR link")

    _publish_html_report_notification(config, signer, cfg, details, par_link, expiration_hours, par_error=par_error)
    logger.info(
        "Published generated HTML report notification for bucket=%s object=%s",
        details["bucket_name"],
        details["object_name"],
    )
    return {
        "notified": True,
        "bucket_name": details["bucket_name"],
        "object_name": details["object_name"],
        "par_created": par_link is not None,
    }


def handler(ctx, data: io.BytesIO = None):
    # Create a UTC timestamp for the report output directory.
    start_datetime = datetime.datetime.now().replace(tzinfo=pytz.UTC)
    report_datetime = str(start_datetime.strftime("%Y-%m-%d_%H-%M-%S"))
    # Authenticate with OCI using the function resource principal.
    signer = oci.auth.signers.get_resource_principals_signer()
    config = {"region": signer.region, "tenancy": signer.tenancy_id}
    payload = _read_json_payload(data)
    try:
        cfg = ctx.Config()
        logger.info("Function configuration loaded")
        object_storage_event = _find_object_storage_event(payload)
        if object_storage_event:
            logger.info(
                "Recognized Object Storage event: eventType=%s resourceName=%s",
                object_storage_event.get("eventType") or object_storage_event.get("type"),
                (object_storage_event.get("data") or {}).get("resourceName"),
            )
            return _handle_html_report_event(config, signer, cfg, object_storage_event)
        if payload is not None and _parse_bool(cfg.get("html_notification_enabled")):
            payload_summary = _payload_summary(payload)
            logger.info(
                "Invocation payload was not a recognized Object Storage event; continuing with CIS report generation: %s",
                payload_summary,
            )

        bucket = cfg["output_bucket"]
        regions_to_run_in = cfg["regions_to_run_in"]
        obp = _parse_bool(cfg["obp"])
        raw_data = _parse_bool(cfg["raw_data"])
        report_level = _parse_report_level(cfg.get("report_level", 2))
        report_summary_json = _parse_bool(cfg.get("report_summary_json"), default=True)
        redact_output = _parse_bool(cfg.get("redact_output"))
        all_resources = _parse_bool(cfg.get("all_resources"))
        script_version = cfg.get("script_version", "latest")
        logger.info(
            "Report configuration: bucket=%s, regions_to_run_in=%s, report_level=%s, "
            "obp=%s, raw_data=%s, report_summary_json=%s, redact_output=%s, "
            "all_resources=%s, script_version=%s",
            bucket,
            regions_to_run_in,
            report_level,
            obp,
            raw_data,
            report_summary_json,
            redact_output,
            all_resources,
            script_version,
        )
    except KeyError:
        logger.exception("Missing required function configuration key")
        raise

    CIS_Report = _load_cis_report_class(script_version)

    report = _create_cis_report(
        CIS_Report,
        config=config,
        signer=signer,
        proxy=None,
        output_bucket=bucket,
        report_directory=f"/tmp/{report_datetime}",
        report_prefix=None,
        report_summary_json=report_summary_json,
        print_to_screen="False",
        regions_to_run_in=regions_to_run_in,
        raw_data=raw_data,
        obp=obp,
        redact_output=redact_output,
        oci_url=None,
        debug=False,
        all_resources=all_resources,
        disable_api_keys=True,
    )
    csv_report_directory = report.generate_reports(report_level)
    logger.info("CIS report generation completed: %s", csv_report_directory)

    try:
        _publish_generated_html_report_notification(config, signer, cfg, bucket, csv_report_directory)
    except Exception:
        logger.exception("Failed to publish generated HTML report notification")

    return True


def _create_cis_report(cis_report_class, **kwargs):
    """Instantiate the report class with only constructor arguments it supports."""
    signature = inspect.signature(cis_report_class.__init__)
    accepts_var_kwargs = any(
        parameter.kind == inspect.Parameter.VAR_KEYWORD
        for parameter in signature.parameters.values()
    )
    if accepts_var_kwargs:
        return cis_report_class(**kwargs)

    supported_args = {
        name for name in signature.parameters
        if name != "self"
    }
    filtered_kwargs = {
        name: value for name, value in kwargs.items()
        if name in supported_args
    }
    skipped_kwargs = sorted(set(kwargs) - supported_args)
    if skipped_kwargs:
        logger.info("Skipping unsupported CIS_Report arguments: %s", ", ".join(skipped_kwargs))
    return cis_report_class(**filtered_kwargs)
