# OCI CIS Terraform Remediations

![Landing Zone logo](../images/landing%20zone_300.png)

This directory contains three independent Terraform remediation stacks for an OCI tenancy. They can be deployed separately: one exports audit logs to an external SIEM, one establishes CIS-aligned monitoring and governance controls, and one runs recurring CIS benchmark reports.

| Directory | Purpose | Main OCI services |
| --- | --- | --- |
| [`cis_oci_benchmark_siem_integration_remediation`](./cis_oci_benchmark_siem_integration_remediation/README.md) | Delivers tenancy audit logs to a third-party SIEM through OCI Streaming. | Service Connector Hub, Streaming, IAM |
| [`cis_oci_benchmark_logging_monitoring_remediation`](./cis_oci_benchmark_logging_monitoring_remediation/README.md) | Adds event notifications, connectivity alarms, Cloud Guard configuration, and forecast budgets. | Events, Notifications, Monitoring, Cloud Guard, Budgets |
| [`cis_oci_function`](./cis_oci_function/README.md) | Deploys a containerized OCI Function that generates CIS reports and saves them to Object Storage. | Functions, OCIR, Object Storage, Logging, Resource Scheduler |

## 1. SIEM integration remediation

This stack creates a stream pool and stream, then creates a Service Connector Hub connector that forwards audit logs from the current region to that stream. It supports **Splunk**, **Stellar Cyber**, and a **generic stream-based** receiver. The outputs provide vendor documentation links and guidance for the next steps.

When selected, the stack also creates a least-privilege IAM reader identity for the SIEM:

- An OCI IAM group and `stream-pull` policy for API signing-key access, or
- A dynamic group for instance-principal access.

IAM resources are limited to the home-region deployment; the stream and connector are regional. Each additional subscribed region needs its own deployment to export that region's audit logs.

## 2. Logging and monitoring remediation

This stack is a collection of optional controls, enabled individually through Terraform variables:

- Network-change event rule and email topic.
- IAM-change event rule and email topic, managed through the home-region provider.
- VPN-status and FastConnect-status alarms with an email topic.
- Cloud Guard enablement, a root-tenancy target with cloned recipes, service policies, and email alerts for **High** and **Critical** findings.
- A root-level monthly budget that alerts based on forecast spend.

All resources use a configurable service-label prefix. Cloud Guard, IAM event rules, and budgets are tenancy/home-region controls; network event rules and connectivity alarms are regional. Before enabling Cloud Guard, confirm that an existing root target will not conflict with the target this stack creates.

## 3. CIS report function

This stack builds an ARM64 Python OCI Functions image, pushes it to a private OCIR repository, and deploys it into an OCI Functions application. The function authenticates with an OCI resource principal, loads the CIS reporting script, runs a Level 1 or Level 2 report, and writes results to a private Object Storage bucket.

Optional capabilities include:

- Creation or reuse of a compartment, a dynamic group, IAM policies, and a private function network.
- Vault-backed OCIR credentials during image push.
- OCI Functions invocation logs.
- Scheduled execution through OCI Resource Scheduler.
- HTML-summary email notifications containing a four-hour ObjectRead pre-authenticated request link.

By default, the function can download the latest upstream CIS script at runtime. Pinning `script_version` to a release tag, or using a bundled copy, is preferable when reproducibility and change control are required.

## Deployment considerations

- Provide OCI credentials and IAM permissions appropriate to the resources each selected stack creates. The SIEM and monitoring stacks use Terraform modules downloaded from public GitHub, so Terraform initialization needs outbound connectivity.
- Deploy home-region resources once, then deploy regional resources separately for every OCI region in scope.
- The function stack also requires a compatible container CLI (Docker or Podman); Vault-backed image login requires OCI CLI and Python 3 on the Terraform runner.
- Configure email recipients, budget values, compartments, retention, and service-label naming before running `terraform apply`. The stacks do not supply organization-specific contacts or mandatory defined tags.
- Treat SIEM stream endpoints, OCI credentials, Terraform state, and HTML-report pre-authenticated links as sensitive operational data.

## Recommended deployment order

1. Deploy **logging and monitoring** controls in the home region; repeat regional controls where required.
2. Deploy the **SIEM integration** stack in each region that must export audit logs, then configure the external SIEM with the generated stream details.
3. Deploy the **CIS report function** after confirming its runtime dynamic-group permissions and Object Storage destination; add its schedule only after a successful manual run.
