##########################################################################
# Copyright (c) 2016, 2020, Oracle and/or its affiliates.  All rights reserved.
# This software is dual-licensed to you under the Universal Permissive License (UPL) 1.0 as shown at https://oss.oracle.com/licenses/upl or Apache License 2.0 as shown at http://www.apache.org/licenses/LICENSE-2.0. You may choose either license.
#
# cis_reports.py
# @author base: Adi Zohar
# @author: Andre Luiz Correa and Josh Hammer
#
# Supports Python 3 and above
#
# coding: utf-8
##########################################################################

from __future__ import print_function
import sys
import argparse
import datetime
import oci
import json
import os

##########################################################################
# Print header centered
##########################################################################
def print_header(name):
    chars = int(90)
    print("")
    print('#' * chars)
    print("#" + name.center(chars - 2, " ") + "#")
    print('#' * chars)


##########################################################################
# check service error to warn instead of error
##########################################################################
def check_service_error(code):
    return ('max retries exceeded' in str(code).lower() or
            'auth' in str(code).lower() or
            'notfound' in str(code).lower() or
            code == 'Forbidden' or
            code == 'TooManyRequests' or
            code == 'IncorrectState' or
            code == 'LimitExceeded'
            )

##########################################################################
# Create signer for Authentication
# Input - config_profile and is_instance_principals and is_delegation_token
# Output - config and signer objects
##########################################################################
def create_signer(config_profile, is_instance_principals, is_delegation_token):

    # if instance principals authentications
    if is_instance_principals:
        try:
            signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
            config = {'region': signer.region, 'tenancy': signer.tenancy_id}
            return config, signer

        except Exception:
            print_header("Error obtaining instance principals certificate, aborting")
            raise SystemExit

    # -----------------------------
    # Delegation Token
    # -----------------------------
    elif is_delegation_token:

        try:
            # check if env variables OCI_CONFIG_FILE, OCI_CONFIG_PROFILE exist and use them
            env_config_file = os.environ.get('OCI_CONFIG_FILE')
            env_config_section = os.environ.get('OCI_CONFIG_PROFILE')

            # check if file exist
            if env_config_file is None or env_config_section is None:
                print("*** OCI_CONFIG_FILE and OCI_CONFIG_PROFILE env variables not found, abort. ***")
                print("")
                raise SystemExit

            config = oci.config.from_file(env_config_file, env_config_section)
            delegation_token_location = config["delegation_token_file"]

            with open(delegation_token_location, 'r') as delegation_token_file:
                delegation_token = delegation_token_file.read().strip()
                # get signer from delegation token
                signer = oci.auth.signers.InstancePrincipalsDelegationTokenSigner(delegation_token=delegation_token)

                return config, signer

        except KeyError:
            print("* Key Error obtaining delegation_token_file")
            raise SystemExit

        except Exception:
            raise

    # -----------------------------
    # config file authentication
    # -----------------------------
    else:
        config = oci.config.from_file(
            oci.config.DEFAULT_LOCATION,
            (config_profile if config_profile else oci.config.DEFAULT_PROFILE)
        )
        signer = oci.signer.Signer(
            tenancy=config["tenancy"],
            user=config["user"],
            fingerprint=config["fingerprint"],
            private_key_file_location=config.get("key_file"),
            pass_phrase=oci.config.get_config_value_or_default(config, "pass_phrase"),
            private_key_content=config.get("key_content")
        )
        return config, signer

##########################################################################
# Load compartments
##########################################################################
def identity_read_compartments(identity, tenancy):

    print("Loading Compartments...")
    try:
        compartments = oci.pagination.list_call_get_all_results(
            identity.list_compartments,
            tenancy.id,
            compartment_id_in_subtree=True
        ).data

        # Add root compartment which is not part of the list_compartments
        compartments.append(tenancy)

        print("    Total " + str(len(compartments)) + " compartments loaded.")
        return compartments

    except Exception as e:
        raise RuntimeError("Error in identity_read_compartments: " + str(e.args))

##########################################################################
# Load users
##########################################################################
def identity_read_users(identity, tenancy):

    print("Loading Users...")
    try:
        users = oci.pagination.list_call_get_all_results(
            identity.list_users,
            tenancy.id
        ).data


        print("    Total " + str(len(users)) + " users loaded.")
        return users

    except Exception as e:
        raise RuntimeError("Error in identity_read_users: " + str(e.args))

##########################################################################
# Load user api keys
##########################################################################
def identity_read_user_api_key(identity, user):

    print("Loading Users...")
    try:
        user_api_keys = oci.pagination.list_call_get_all_results(
            identity.list_api_keys,
            user.id
        ).data


        print("    Total " + str(len(users)) + " api keys loaded.")
        return user_api_keys

    except Exception as e:
        raise RuntimeError("Error in identity_read_user_api_key: " + str(e.args))


##########################################################################
# Arg Parsing function to be updated 
##########################################################################
def set_parser_arguments():

    parser = argparse.ArgumentParser()
    parser.add_argument(
        '-i',
        type=argparse.FileType('r'),
        dest='input',
        help="Input JSON File"
        )
    parser.add_argument(
        '-o',
        type=argparse.FileType('w'),
        dest='output_csv',
        help="CSV Output prefix")
    result = parser.parse_args()

    if len(sys.argv) < 3:
        parser.print_help()
        return None

    return result

##########################################################################
# execute_report
##########################################################################
def execute_report():
    cmd = set_parser_arguments()
    if cmd is None:
        return

##########################################################################
# Main
##########################################################################

# Get Command Line Parser
parser = argparse.ArgumentParser()
parser.add_argument('-t', default="", dest='config_profile', help='Config file section to use (tenancy profile)')
parser.add_argument('-p', default="", dest='proxy', help='Set Proxy (i.e. www-proxy-server.com:80) ')
parser.add_argument('-ip', action='store_true', default=False, dest='is_instance_principals', help='Use Instance Principals for Authentication')
parser.add_argument('-dt', action='store_true', default=False, dest='is_delegation_token', help='Use Delegation Token for Authentication')
cmd = parser.parse_args()

# Start print time info
start_time = str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
print_header("Running CIS Reports")
print("Code base By Adi Zohar, June 2020")
print("Written By Andre Luiz Correa Neto & Josh Hammer, November 2020")
print("Starts at " + str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")))
print("Command Line : " + ' '.join(x for x in sys.argv[1:]))

# Identity extract compartments
config, signer = create_signer(cmd.config_profile, cmd.is_instance_principals, cmd.is_delegation_token)
compartments = []
tenancy = None
try:
    print("\nConnecting to Identity Service...")
    identity = oci.identity.IdentityClient(config, signer=signer)
    if cmd.proxy:
        identity.base_client.session.proxies = {'https': cmd.proxy}

    tenancy = identity.get_tenancy(config["tenancy"]).data
    regions = identity.list_region_subscriptions(tenancy.id).data

    print("Tenant Name : " + str(tenancy.name))
    print("Tenant Id   : " + tenancy.id)
    print("")

    compartments = identity_read_compartments(identity, tenancy)
    users = identity_read_users(identity, tenancy)
    print(users[0])

    key = identity_read_user_api_key(identity, users[0])
    print(key)

except Exception as e:
    raise RuntimeError("\nError extracting compartments section - " + str(e))
