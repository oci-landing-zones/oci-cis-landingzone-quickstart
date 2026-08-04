#!/bin/bash
###############################################################################
# Copyright (c) 2022, 2026, Oracle and/or its affiliates.  All rights reserved.
# This software is dual-licensed to you under the Universal Permissive License
# (UPL) 1.0 as shown at https://oss.oracle.com/licenses/upl.
###############################################################################
#
# Author: Olaf Heimburger
#
VERSION=260727
FILE_REMOTE="https://github.com/oci-landing-zones/oci-cis-landingzone-quickstart/raw/main/release-notes.md"
OCI_CONFIG_FILE="${OCI_CLI_CONFIG_FILE:-$HOME/.oci/config}"

OS_TYPE=$(uname)
OS_PLATFORM=$(uname -m)
SHA_SIZE="512"
CMD_SHASUM=''
OPT_SHASUM=""
BASE64_DECODE="base64 -d"
STAMP=$(date +%Y-%m-%d_%H:%M:%S)

_os_type='linux'
_os_platform='amd64'

case "${OS_TYPE}" in
    Darwin)
        _os_type=macos
        CMD_SHASUM=$(which shasum)
        OPT_SHASUM="-a ${SHA_SIZE}"
        BASE64_DECODE="base64 -D"
        STAMP=$(date +%Y-%m-%d_%H.%M.%S)
        ;;
    Linux)
        _os_type=linux
        CMD_SHASUM="$(which 'sha'"${SHA_SIZE}"'sum')"
        ;;
    *)
        printf "ERROR: Platform %s is not supported!\n" ${OS_TYPE}
        exit 1
        ;;
esac
case "$OS_PLATFORM" in
    x86_64)
        _os_platform='amd64'
        ;;
    arm64)
        _os_platform='aarch64'
        ;;
    aarch64)
        _os_platform='aarch64'
        ;;
    *)
        printf "ERROR: Platform %s is not supported!\n" $OS_PLATFORM
        exit 1
        ;;
esac

usage() {
    printf "\nUsage: $0 [-h] [-ip] [-st] [-cf|--config-file config_file] [-t tenancy_name] [-r|--region region_name]\n"
    printf "          [-o|--output-dir parent_directory] [--redact] [--zip-protect] [--no-checksum] [--no-zip]\n"
    printf "          [--cis options] [-v|--version] [--verbose]\n"
    printf " -h                                 -- This message.\n"
    printf " -ip                                -- Use instance principal for authentication.\n"
    printf " -st                                -- Use OCI security token for authentication.\n"
    printf " -cf|--config-file config_file      -- OCI config file (defaults to "'$HOME/.oci/config'").\n"
    printf " -t|--tenancy tenancy_configuration -- Specify a name of the tenancy (defaults to 'DEFAULT').\n"
    printf " -r|--region region_name            -- Run assess.sh on region region_name only.\n"
    printf " -o|--output-dir output_parent      -- Use the speficied directory as parent directory for output directoires.\n"
    printf " --redact                           -- Redact sensitive information in output files.\n"
    printf " --zip-protect                      -- Encrypt the ZIP file with a password of your choice.\n"
    printf " --no-checksum                      -- Do not create checksum files.\n"
    printf " --no-zip                           -- Do not create a ZIP file for the contents of the output directory.\n"
    printf " --cis options                      -- Run cis_report only and provide additional options.\n"
    printf "                                       For example, --cis '-h' shows available options.\n"
    printf "                                       The options -dt, -ip, -st, -t, -r are detected automatically and are not required.\n"
    printf " -v|--version                       -- Show the version numbers of the scripts used.\n"
    printf " --verbose                          -- Print script execution details (Good for debuging).\n"
    exit 1
}

test_internet_access() {
    error_code=0
    printf "INFO: Checking Internet connection.\n"
    local _wg_=$(which curl | wc -c)
    if [ ${_wg_} -gt 0 ]; then
        curl ${FILE_REMOTE} -s -o /dev/null
        error_code=$?
    else
        wget --timeout=5 --tries=2 -q --spider ${FILE_REMOTE}
        error_code=$?
    fi
    if [ $error_code -gt 0 ]; then
        HAS_INTERNET_ACCESS=0
        printf "WARNING: Internet connection is unavailable.\n"
    else
        printf "INFO: Internet connection is available.\n"
    fi
}

debug() {
    if [ $DEBUG -eq 1 ]; then
        echo 'DEBUG: ' $*
    fi
}

check_directories() {
    printf "INFO: Checking for required script files.\n"
    if [ ! -e ${SCRIPT_DIR}/${CIS_SCRIPT_NAME} ]; then
        printf "ERROR: File '"${CIS_SCRIPT_NAME}"' missing!\n"
        exit 1
    fi
    printf "INFO: Found required script file: %s.\n" "${CIS_SCRIPT_NAME}"
}

check_python_version() {
    _W_=$(which python3 | wc -c)
    printf "INFO: Checking Python version. \n"

    if [ ${_W_} -le 0 ]; then
        printf "ERROR: Please install python3 first! Use a version higher than 3.9.\n"
        exit 1
    fi
    PYTHON_VERSION=$(${CMD_PYTHON} --version | sed -e 's,Python ,,g')
    _V_=$(echo -n ${PYTHON_VERSION} | sed -e 's,Python ,,g' -e 's;GraalPy ;;g' -e 's;\.;;g' -e 's; (.*)$;;g')
    if [ 39 -ge ${_V_} ]; then
        printf "ERROR: Please upgrade your Python verion higher than 3.9.\n"
        exit 1
    fi

    printf "INFO: Found Python version: $PYTHON_VERSION. \n"

}

check_config_for_profile() {
    local _wc_=$(grep '\['"$1"'\]' $OCI_CONFIG_FILE)
    printf "INFO: Checking for OCI Config. \n"

    if [ -z "${_wc_}" ]; then
        printf "ERROR: Profile name %s is not present in the OCI config file (%s)!\n" ${TENANCY} ${OCI_CONFIG_FILE}
        exit 1
    fi
    printf "INFO: Found OCI Config: $OCI_CONFIG_FILE \n"
}

get_oci_config_value() {
    CMD_AWK=$(which awk)
    if [ ! -z $CMD_AWK ]; then
        local profile="$1"
        local key="$2"
        local file="${OCI_CLI_CONFIG_FILE:-$HOME/.oci/config}"

        $CMD_AWK -F'=' -v profile="[$profile]" -v key="$key" '
            $0 == profile { found=1; next }
            /^\[/ { found=0 }
            found && $1 ~ key {
            gsub(/^[ \t]+|[ \t]+$/, "", $2)
            print $2
            exit
            }
        ' "$file"
    fi
}

check_jwt_expiry() {
    local jwt="$1"
    printf "INFO: Checking Security Token expiry.\n"

    # Extract payload (2nd part)
    local payload="${jwt#*.}"
    payload="${payload%%.*}"

    # Convert base64url to base64
    payload="${payload//-/+}"
    payload="${payload//_/\/}"    
    payload="${payload}$(printf '=%.0s' $(seq 1 "$pad"))"

    # Decode JSON payload
    local json="$(printf '%s' "$payload" | base64 -d 2>/dev/null)"

    # Extract "exp" value using bash tools
    local exp="$(printf '%s\n' "$json" | grep -o '"exp":[0-9]*' | cut -d: -f2)"

    # Current time
    local now="$(date +%s)"

    if [[ "$exp" =~ ^[0-9]+$ ]]; then
        if (( now < exp )); then
            _expiry=$(( (exp - now) / 60))
            printf "INFO: Security Token is valid for %s minutes.\n" "${_expiry}"
            if [ ${_expiry} -lt 10 -a ${_expiry} -gt 5 ]; then
                printf "WARNING: ***********************************************************************************\n"
                printf "WARNING: Your Security Token is valid for less the %s minutes.\n" "10"
                printf "WARNING: ***********************************************************************************\n"
            fi
            if [ ${_expiry} -lt 5 ]; then
                printf "ERROR: *************************************************************************************\n"
                printf "ERROR: Your Security Token is valid for less the %s minutes.\n" "5"
                printf "ERROR: This is not enough time for a successful run.\n"
                printf "ERROR: Please re-authenticate using\nERROR: 'oci session authenticate --tenancy-name tname --region-name rname --identity-provider-name dname --profile-name pname'\n"
                printf "ERROR: For details see https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/session/authenticate.html\n"
                printf "ERROR: *************************************************************************************\n"
                exit 1
            fi
        else
            printf "ERROR: *************************************************************************************\n"
            printf "ERROR: Your Security Token is expired!\n"
            printf "ERROR: Please re-authenticate using\nERROR: 'oci session authenticate --tenancy-name tname --region-name rname --identity-provider-name dname --profile-name pname'\n"
            printf "ERROR: For details see https://docs.oracle.com/en-us/iaas/tools/oci-cli/latest/oci_cli_docs/cmdref/session/authenticate.html\n"
            printf "ERROR: *************************************************************************************\n"
            exit 1
        fi
    else
        printf "ERROR: Could not parse expiry date of Security Token.\n"
        exit 1
    fi
}

show_version() {
    printf "INFO: %s version %s\n" "$0" "${VERSION}"
    ${CMD_PYTHON} ${CIS_SCRIPT} -v
}

show_version_json() {
    # Example: Version 2.8.0 Updated on February 23, 2024
    version_cis=$(${CMD_PYTHON} ${CIS_SCRIPT} -v | sed -e 's;^Version ;;g' -e 's; Updated.*;;g')
    printf "{ \"%s\": \"%s\", \"%s\": \"%s\"}" "${SCRIPT_NAME}" "${VERSION}" "${CIS_SCRIPT_NAME}" "${version_cis}"
}

make_env() {
    printf "INFO: Checking Python virtual environment.\n"
    if [ $HAS_INTERNET_ACCESS -eq 1 ]; then
        if [ ! -d ${PYTHON_ENV} ]; then
            printf "INFO: Creating Python virtual environment.\n"
            ${CMD_PYTHON} -m venv ${PYTHON_ENV}
        fi
    fi
    PIP_OPTS="-q --no-warn-script-location"
    if [ -d ${PYTHON_ENV} ]; then
        source ${PYTHON_ENV}/bin/activate
        CMD_PYTHON=$(which python3)
        printf "INFO: Python virtual environment is ready.\n"
        if [ $HAS_INTERNET_ACCESS -eq 1 ]; then
            ${CMD_PYTHON} -m pip install pip --upgrade ${PIP_OPTS}
        else
            local _V_
            local PYVENV_VERSION
            _V_=$(echo -n ${PYTHON_VERSION} | sed -e 's,Python ,,g' -e 's;\.;;g')
            PYVENV_VERSION=$(cat ${PYTHON_ENV}/pyvenv.cfg | grep version | sed -e 's;version = ;;g' -e 's;\.;;g')
            if [ $PYVENV_VERSION -ne $_V_ ]; then
                printf "ERROR: Python and Python Virtual Environment version mismatch!\n"
                printf "ERROR: Python version: %s\n" "${PYTHON_VERSION}"
                printf "ERROR: Python Virtual Environment version: %s!\n" "${PYVENV_VERSION}"
                printf "ERROR: Please use matching versions!\n"
                exit 1
            fi
        fi
    fi

    if [ $HAS_INTERNET_ACCESS -eq 1 ]; then
        printf "INFO: Checking for required libraries ...\n"
        if [ ! -e ${SCRIPT_DIR}/requirements.txt ]; then
            printf "INFO: Creating requirements file.\n"
            if ! cat > "${SCRIPT_DIR}/requirements.txt" <<'EOF'
# Required
pytz
oci
requests
EOF
            then
                printf "ERROR: Unable to create requirements file '%s'.\n" "${SCRIPT_DIR}/requirements.txt"
                exit 1
            fi
        fi
        ${CMD_PYTHON} -m pip install ${PIP_OPTS} -r ${SCRIPT_DIR}/requirements.txt
        if [ $? -gt 0 ]; then
            printf "ERROR: Permissions to install the required libraries are missing.\n"
            printf "ERROR: Please check with your OCI administrator.\n"
            exit 1
        fi
    fi
}

check_authentication() {
    if [ ! -z "${TENANCY}" -a -z "${CLOUD_SHELL_TOOL_SET}" -a "${INSTANCE_PRINCIPAL}" -eq 0 ]; then
        printf "INFO: Checking authentication for OCI profile %s.\n" "${TENANCY}"
        local tname=$(get_oci_config_value ${TENANCY} tenancy)
        local security_token_file=$(get_oci_config_value ${TENANCY} security_token_file)
        if [ -z ${tname} ]; then
            printf "ERROR: Profile name %s is not present in the config file!\n" ${TENANCY}
        fi
        if [ ! -z ${security_token_file} ]; then
            jwt="$(tr -d '\n\r ' < "${security_token_file}")"
            check_jwt_expiry "${jwt}"
            CIS_AUTH_OPT="-st"
        fi
        if [ ! -z "${tname}" ]; then
            printf "INFO: OCI profile authentication configuration is ready.\n"
        fi
    fi
}

check_env() {
    printf "INFO: Checking Python virtual environment configuration.\n"
    local _WC_=$(${CMD_PYTHON} -m pip list | grep pytz | wc -c)
    if [ ${_WC_} -lt 1 ]; then
        printf "ERROR: ************************************************************************\n"
        printf "ERROR: venv configuration failed!\n"
        printf "ERROR: ************************************************************************\n"
        if [ ${HAS_INTERNET_ACCESS} -eq 0 ]; then
            if [ ! -z ${CLOUD_SHELL_TOOL_SET} ]; then
                printf "ERROR: Either:\n"
                printf "ERROR: - Change the Cloud Shell network to 'public'.\n"
                printf "ERROR: or\n"
                printf "ERROR: - Please ask your Oracle contact for the required supplement file.\n"
            else
                printf "ERROR: - Ensure that the Internet can be reached (NAT mode will be sufficient).\n"
            fi
            printf "ERROR: When finished re-run again.\n"
            printf "ERROR: ************************************************************************\n"
        fi
        exit 1
    fi
}

cleanup() {
    deactivate
}

SCRIPT_DIR=$(dirname $0)
if [ ${SCRIPT_DIR} == "." ]; then
    SCRIPT_DIR=${PWD}
    OUTPUT_DIR_PARENT="$(dirname ${SCRIPT_DIR})"
else
    OUTPUT_DIR_PARENT="$(dirname ${SCRIPT_DIR})"
fi
if [ "${OUTPUT_DIR_PARENT}" == "." ]; then
    OUTPUT_DIR_PARENT=${PWD}
fi

CIS_SCRIPT_NAME="cis_reports.py"
CIS_SCRIPT="${SCRIPT_DIR}/${CIS_SCRIPT_NAME}"

DEBUG=0
NO_ZIP=0
NO_CSV=1
NO_SHASUM=0
ZIP_PROTECT=0
QUIET=1
REGION_NAME=''
TENANCY="DEFAULT"
INSTANCE_PRINCIPAL=0
SECURITY_TOKEN=0
REDACT_OUTPUT=0
CREATE_NATIVE=0
CMD_PYTHON=$(which python3)
CMD_SCRIPT=$(which script)

SCRIPT_NAME=$(basename $0)
HAS_INTERNET_ACCESS=1
TYPE_NAME='standard'
test_internet_access

PYTHON_ENV="$HOME/.venv/${TYPE_NAME}"
POSTFIX="_${TYPE_NAME}"

while test -n "$1"; do
    case "$1" in
        --cis)
            CIS_DATA_OPT="$2"
            shift 2
            ;;
        -ip)
            INSTANCE_PRINCIPAL=1
            SECURITY_TOKEN=0
            shift 1
            ;;
        -st)
            INSTANCE_PRINCIPAL=0
            SECURITY_TOKEN=1
            shift 1
            ;;
        -r|--region)
            REGION_NAME="$2"
            shift 2
            ;;
        --redact)
            REDACT_OUTPUT=1
            shift 1
            ;;
        -t|--tenancy)
            TENANCY="$2"
            check_config_for_profile $TENANCY
            shift 2
            ;;
        -cf|--config-file)
            OCI_CONFIG_FILE="$2"
            shift 2
            ;;
        -o|--output-dir)
            OUTPUT_DIR_PARENT="$2"
            shift 2
            ;;
        --zip-protect)
            ZIP_PROTECT=1
            shift 1
            ;;
        --no-checksum)
            NO_SHASUM=1
            shift 1
            ;;
        --no-zip)
            NO_ZIP=1
            shift 1
            ;;
        --verbose)
            QUIET=0
            shift 1
            ;;
        -v|--version)
            show_version
            exit 1
            ;;
        -h|--help)
            usage
            ;;
        *)
            usage
            ;;
    esac
done

if [ $REDACT_OUTPUT -eq 1 ]; then
    CIS_DATA_OPT="${CIS_DATA_OPT} --redact-output"
fi

CIS_AUTH_OPT=""
TENANCY_NAME=""
if [ ! -z "${CLOUD_SHELL_TOOL_SET}" ]; then
    CIS_AUTH_OPT="-dt"
    CLI_TENANCY_NAME=$(oci iam tenancy get --tenancy-id $OCI_TENANCY --query 'data.name' 2>/dev/null)
    if [ $? -gt 0 ]; then
        if [ $HAS_INTERNET_ACCESS -eq 0 ]; then
            printf "ERROR: Cloud Shell with NO internet access can run in Home region, only!\n"
        else
            printf "ERROR: Permissions to run the OCI CLI are missing.\n"
            printf "ERROR: Please contact your OCI administrator.\n"
        fi
        exit 1
    fi
    TENANCY_NAME=$(echo -n $CLI_TENANCY_NAME | sed -e 's/"//g')
elif [ "${INSTANCE_PRINCIPAL}" -gt 0 ]; then
    CIS_AUTH_OPT="-ip"
elif [ "${SECURITY_TOKEN}" -gt 0 ]; then
    CIS_AUTH_OPT="-st"
fi
if [ ! -z "${TENANCY_NAME}" ]; then
    TENANCY=${TENANCY_NAME}
fi

check_directories
check_python_version
make_env
check_authentication
check_env

OUTPUT_DIR_NAME="${TENANCY}_${STAMP}"

if [ $HAS_INTERNET_ACCESS -ne 1 -a ! -z "${OCI_REGION}" ]; then
    printf "WARNING: No Internet connection.\n\nWARNING: This script can run on home region only!\n\n"
    if [ ! -z "${REGION_NAME}" ]; then
        printf "WARNING: Ignoring option '-r "${REGION_NAME}"'.\n"
    fi
    printf "INFO: Running check for region '"${OCI_REGION}"' only.\n"
    REGION_NAME=${OCI_REGION}
fi

CIS_REGION_OPT=''
if [ ! -z "${REGION_NAME}" ]; then
    CIS_REGION_OPT="--regions ${REGION_NAME}"
    OUTPUT_REGION='_'"$(echo -n ${REGION_NAME} | sed '-e s;,;_;g')"
    OUTPUT_DIR_NAME="${OUTPUT_DIR_NAME}${OUTPUT_REGION}"
fi

OUTPUT_DIR="${OUTPUT_DIR_PARENT}/${OUTPUT_DIR_NAME}"
if [ ! -e ${OUTPUT_DIR} ]; then
    printf "INFO: Creating output directory %s.\n" "${OUTPUT_DIR}"
    mkdir -p ${OUTPUT_DIR}
    show_version_json > ${OUTPUT_DIR}/script_versions.json
fi

MSG_SCRIPTS="'"${CIS_SCRIPT_NAME}"'"
MSG_REGION="for all regions"
if [ ! -z "${REGION_NAME}" ]; then
    MSG_REGION="for region '"${REGION_NAME}"'"
fi

INFO_STR="Running script ${MSG_SCRIPTS} ${MSG_REGION}"
if [ ! -z "${TENANCY_NAME}" ]; then
    INFO_STR="${INFO_STR} in tenancy '"${TENANCY_NAME}"'"
else
    INFO_STR="${INFO_STR} using configuration '"${TENANCY}"'"
fi
printf "INFO: %s\n" "${INFO_STR}"

CIS_OPTS="-t ${TENANCY} -c ${OCI_CONFIG_FILE} ${CIS_REGION_OPT} ${CIS_DATA_OPT} ${CIS_AUTH_OPT} --report-summary-json --report-prefix ${OUTPUT_DIR_NAME}"

trap "cleanup; echo The script has been canceled; exiting" 1 2 3 6
_W_=$(which script | wc -c)
out=$(echo -n ${OUTPUT_DIR} | sed -e 's;\./;;g')
CIS_OPTS="${CIS_OPTS} --report-directory ${out}"
if [ ${_W_} -gt 0 ]; then
    if [ "${OS_TYPE}" == 'Darwin' ]; then
        ${CMD_SCRIPT} -e -q ${out}/${TYPE_NAME}_cis_report.txt ${CMD_PYTHON} ${CIS_SCRIPT} ${CIS_OPTS} 
    else
        ${CMD_SCRIPT} -e -c "${CMD_PYTHON} ${CIS_SCRIPT} ${CIS_OPTS}" ${out}/${TYPE_NAME}_cis_report.txt
    fi
    _error=$?
    # echo " Error code ${_error}"
else
    ${CMD_PYTHON} ${CIS_SCRIPT} ${CIS_OPTS}
fi

#
# Add SHASUM for 
#

if [ ${NO_SHASUM} -eq 0 ]; then
    printf "INFO: Creating SHA-%s checksum files.\n" "${SHA_SIZE}"
    _cwd=$(pwd)
    cd ${OUTPUT_DIR}
    _files=$(ls)
    for i in ${_files}; do
        ${CMD_SHASUM} ${OPT_SHASUM} ${i} > ${i}.sha${SHA_SIZE}
    done
    VERIFY=verify_checksums.sh
    printf '#!/bin/bash\n' >${VERIFY}
    printf 'OS_TYPE=$(uname)\n\n'"SHA_SIZE='512'\nCMD_SHASUM=''\n\n" >>${VERIFY}
    printf 'case "${OS_TYPE}" in\n    Darwin)\n        CMD_SHASUM="$(which shasum) -a ${SHA_SIZE}"\n        ;;\n' >>${VERIFY}
    printf '    Linux)\n        CMD_SHASUM="$(which 'sha'"${SHA_SIZE}"'sum')"\n        ;;\n' >>${VERIFY}
    printf '    *)\n        echo "ERROR: Platform ${OS_TYPE} not supported!"\n        exit 1\n        ;;\n' >>${VERIFY}
    printf 'esac\n\nfiles=$(ls *.sha${SHA_SIZE})\n' >>${VERIFY}
    printf 'for i in ${files}; do\n    ${CMD_SHASUM} -c ${i}\ndone\n' >>${VERIFY}
    chmod +x ${VERIFY}
    cd ${_cwd}
    printf "INFO: SHA-%s checksum files are ready.\n" "${SHA_SIZE}"
fi

if [ ${NO_ZIP} -eq 0 ]; then
    printf "INFO: Packaging results into a ZIP file.\n"
    DIR_PARENT_OUTPUT="$(dirname ${OUTPUT_DIR})"
    cd $DIR_PARENT_OUTPUT
    if [ ${ZIP_PROTECT} -eq 1 ]; then
        printf "\nPlease enter a password for the ZIP file. Zero length passwords are not supported!\n"
        zip -e -q -r ${OUTPUT_DIR_NAME}.zip ${OUTPUT_DIR_NAME}
        if [ $? -ne 0 ]; then
            printf "Please run $0 again.\n"
            exit 1
        fi
    else
        zip -q -r ${OUTPUT_DIR_NAME}.zip ${OUTPUT_DIR_NAME}
        if [ $? -ne 0 ]; then
            printf "Please run $0 again.\n"
            exit 1
        fi
    fi
    if [ ${NO_SHASUM} -eq 0 ]; then
        ${CMD_SHASUM} ${OPT_SHASUM} ${OUTPUT_DIR_NAME}.zip > ${OUTPUT_DIR_NAME}.zip.sha${SHA_SIZE}
    fi

    printf "INFO: ZIP package is ready.\n"
    printf "\nINFO: All output can be found in the directory '%s'.\nINFO: Results are packaged as downloadable file '%s' at '%s'.\n" "${OUTPUT_DIR_NAME}" "${OUTPUT_DIR_NAME}.zip" "${OUTPUT_DIR_PARENT}"
    if [ ! -z "${CLOUD_SHELL_TOOL_SET}" ]; then
        printf "\nINFO: To download the ZIP file:\nINFO:  1. Copy the filename %s\nINFO:  2. Click on the settings icon of the Cloud Shell on the right\nINFO:  3. Select 'Download'\nINFO:  4. Paste the file name into the modal window and click on 'Download'\n\n" "${OUTPUT_DIR_NAME}.zip"
    fi
    if [ $HAS_INTERNET_ACCESS -eq 0 -a ! -z "$OCI_REGION" ]; then
        printf "\nWARNING: Your Cloud Shell seems to have the OCI services network configured.\n"
        printf "WARNING: With this setup the script can check your home region '"${OCI_REGION}"' only.\nWARNING: To check all your regions you need Internet access for your Cloud Shell!\n\n"
    fi
fi
