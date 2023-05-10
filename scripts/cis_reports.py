##########################################################################
# Copyright (c) 2016, 2023, Oracle and/or its affiliates.  All rights reserved.
# This software is dual-licensed to you under the Universal Permissive License (UPL) 1.0 as shown at https://oss.oracle.com/licenses/upl or Apache License 2.0 as shown at http://www.apache.org/licenses/LICENSE-2.0. You may choose either license.
#
# cis_reports.py
# @author base: Adi Zohar
# @author: Josh Hammer, Andre Correa, Chad Russell, and Olaf Heimburger
#
# Supports Python 3 and above
#
# coding: utf-8
##########################################################################

from __future__ import print_function
from concurrent.futures import thread
import sys
import argparse
import datetime
import pytz
import oci
import json
import os
import csv
import itertools
from threading import Thread
import hashlib
import re

try:
    from xlsxwriter.workbook import Workbook    
    import glob
    OUTPUT_TO_XLSX = True
except:
    OUTPUT_TO_XLSX = False

RELEASE_VERSION = "2.5.10"
PYTHON_SDK_VERSION = "2.99.1"
UPDATED_DATE = "May 12, 2023"

##########################################################################
# Print header centered
##########################################################################
def print_header(name):
    chars = int(90)
    print('')
    print('#' * chars)
    print('#' + name.center(chars - 2, ' ') + '#')
    print('#' * chars)

def show_version(verbose=False):
    script_version = f'CIS Reports - Release {RELEASE_VERSION}'
    script_updated = f'Updated {UPDATED_DATE}'
    if verbose:
        print_header('Running ' + script_version)
        print(script_updated)
        print(f'Tested oci-python-sdk version: {PYTHON_SDK_VERSION}')
        print('Your oci-python-sdk version: ' + str(oci.__version__))
    else:
        print(script_version)
        print(script_updated)

##########################################################################
# CIS Reporting Class
##########################################################################
class CIS_Report:

    # Class variables
    _DAYS_OLD = 90
    __KMS_DAYS_OLD = 365
    __home_region = []

    
    # Time Format
    __iso_time_format = "%Y-%m-%dT%H:%M:%S"

    # OCI Link 
    __oci_cloud_url = "https://cloud.oracle.com"
    __oci_users_uri = __oci_cloud_url + "/identity/users/"
    __oci_policies_uri = __oci_cloud_url + "/identity/policies/"
    __oci_groups_uri = __oci_cloud_url + "/identity/groups/"
    __oci_dynamic_groups_uri = __oci_cloud_url + "/identity/dynamicgroups/"
    __oci_buckets_uri = __oci_cloud_url + "/object-storage/buckets/"
    __oci_boot_volumes_uri = __oci_cloud_url + "/block-storage/boot-volumes/"
    __oci_block_volumes_uri = __oci_cloud_url + "/block-storage/volumes/"
    __oci_fss_uri = __oci_cloud_url + "/fss/file-systems/"
    __oci_networking_uri = __oci_cloud_url +"/networking/vcns/"
    __oci_adb_uri = __oci_cloud_url +"/db/adb/"
    __oci_oicinstance_uri = __oci_cloud_url +"/oic/integration-instances/"
    __oci_oacinstance_uri = __oci_cloud_url +"/analytics/instances/"
    __oci_compartment_uri = __oci_cloud_url +"/identity/compartments/"
    __oci_drg_uri = __oci_cloud_url +"/networking/drgs/"
    __oci_cpe_uri = __oci_cloud_url +"/networking/cpes/"
    __oci_ipsec_uri = __oci_cloud_url +"/networking/vpn-connections/"
    __oci_events_uri = __oci_cloud_url +"/events/rules/"
    __oci_loggroup_uri = __oci_cloud_url +"/logging/log-groups/"
    __oci_vault_uri = __oci_cloud_url +"/security/kms/vaults/"
    __oci_budget_uri = __oci_cloud_url +"/usage/budgets/"
    __oci_cgtarget_uri = __oci_cloud_url +"/cloud-guard/targets/"
    __oci_onssub_uri = __oci_cloud_url +"/notification/subscriptions/"
    __oci_serviceconnector_uri = __oci_cloud_url +"/connector-hub/service-connectors/"
    __oci_fastconnect_uri = __oci_cloud_url +"/networking/fast-connect/virtual-circuit/"

    __oci_ocid_pattern = r'ocid1\.[a-z,0-9]*\.[a-z,0-9]*\.[a-z,0-9,-]*\.[a-z,0-9,\.]{20,}'

    # Start print time info
    start_datetime = datetime.datetime.now().replace(tzinfo=pytz.UTC)
    start_time_str = str(start_datetime.strftime(__iso_time_format))
    report_datetime = str(start_datetime.strftime("%Y-%m-%d_%H-%M-%S"))
    # For User based key checks
    api_key_time_max_datetime = start_datetime - \
        datetime.timedelta(days=_DAYS_OLD)

    str_api_key_time_max_datetime = api_key_time_max_datetime.strftime(__iso_time_format)
    api_key_time_max_datetime = datetime.datetime.strptime(str_api_key_time_max_datetime, __iso_time_format)
    
    # For KMS check
    kms_key_time_max_datetime = start_datetime - \
        datetime.timedelta(days=__KMS_DAYS_OLD)
    str_kms_key_time_max_datetime = kms_key_time_max_datetime.strftime(__iso_time_format)
    kms_key_time_max_datetime = datetime.datetime.strptime(str_kms_key_time_max_datetime, __iso_time_format)

    def __init__(self, config, signer, proxy, output_bucket, report_directory, print_to_screen, regions_to_run_in, raw_data, obp, redact_output):

        # CIS Foundation benchmark 1.2
        self.cis_foundations_benchmark_1_2 = {
            '1.1': {'section': 'Identity and Access Management', 'recommendation_#': '1.1', 'Title': 'Ensure service level admins are created to manage resources of particular service', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['5.4','6.7'], 'CCCS Guard Rail' : '2,3','Remediation':[]},
            '1.2': {'section': 'Identity and Access Management', 'recommendation_#': '1.2', 'Title': 'Ensure permissions on all resources are given only to the tenancy administrator group', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['3.3'], 'CCCS Guard Rail' : '1,2,3','Remediation':[]},
            '1.3': {'section': 'Identity and Access Management', 'recommendation_#': '1.3', 'Title': 'Ensure IAM administrators cannot update tenancy Administrators group', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['3.3','5.4'], 'CCCS Guard Rail' : '2,3','Remediation':[]},
            '1.4': {'section': 'Identity and Access Management', 'recommendation_#': '1.4', 'Title': 'Ensure IAM password policy requires minimum length of 14 or greater', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.1','5.2'], 'CCCS Guard Rail' : '2,3','Remediation':[]},
            '1.5': {'section': 'Identity and Access Management', 'recommendation_#': '1.5', 'Title': 'Ensure IAM password policy expires passwords within 365 days', 'Status': None, 'Level': 1, 'Findings': [], 'CISv8': ['4.1','5.2'], 'CCCS Guard Rail' : '2,3','Remediation':[]},
            '1.6': {'section': 'Identity and Access Management', 'recommendation_#': '1.6', 'Title': 'Ensure IAM password policy prevents password reuse', 'Status': None, 'Level': 1, 'Findings': [], 'CISv8': ['5.2'], 'CCCS Guard Rail' : '2,3','Remediation':[]},
            '1.7': {'section': 'Identity and Access Management', 'recommendation_#': '1.7', 'Title': 'Ensure MFA is enabled for all users with a console password', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['6.3','6.5'], 'CCCS Guard Rail' : '1,2,3,4','Remediation':[]},
            '1.8': {'section': 'Identity and Access Management', 'recommendation_#': '1.8', 'Title': 'Ensure user API keys rotate within 90 days or less', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.1','4.4'], 'CCCS Guard Rail' : '6,7','Remediation':[]},
            '1.9': {'section': 'Identity and Access Management', 'recommendation_#': '1.9', 'Title': 'Ensure user customer secret keys rotate within 90 days or less', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.1','5.2'], 'CCCS Guard Rail' : '6,7','Remediation':[]},
            '1.10': {'section': 'Identity and Access Management', 'recommendation_#': '1.10', 'Title': 'Ensure user auth tokens rotate within 90 days or less', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.1','5.2'], 'CCCS Guard Rail' : '6,7','Remediation':[]},
            '1.11': {'section': 'Identity and Access Management', 'recommendation_#': '1.11', 'Title': 'Ensure API keys are not created for tenancy administrator users', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['5.4'], 'CCCS Guard Rail' : '6,7','Remediation':[]},
            '1.12': {'section': 'Identity and Access Management', 'recommendation_#': '1.12', 'Title': 'Ensure all OCI IAM user accounts have a valid and current email address', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['5.1'], 'CCCS Guard Rail' : '1,2,3','Remediation':[]},
            '1.13': {'section': 'Identity and Access Management', 'recommendation_#': '1.13', 'Title': 'Ensure Dynamic Groups are used for OCI instances, OCI Cloud Databases and OCI Function to access OCI resources', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['6.8'], 'CCCS Guard Rail' : '6,7','Remediation':[]},
            '1.14': {'section': 'Identity and Access Management', 'recommendation_#': '1.14', 'Title': 'Ensure storage service-level admins cannot delete resources they manage', 'Status': False, 'Level': 2, 'Findings': [], 'CISv8': ['5.4','6.8'], 'CCCS Guard Rail' : '2,3','Remediation':[]},

            '2.1': {'section': 'Networking', 'recommendation_#': '2.1', 'Title': 'Ensure no security lists allow ingress from 0.0.0.0/0 to port 22.', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.4','12.3'], 'CCCS Guard Rail' : '2,3,5,7,9','Remediation':[]},
            '2.2': {'section': 'Networking', 'recommendation_#': '2.2', 'Title': 'Ensure no security lists allow ingress from 0.0.0.0/0 to port 3389.', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.4','12.3'], 'CCCS Guard Rail' : '2,3,5,7,9','Remediation':[]},
            '2.3': {'section': 'Networking', 'recommendation_#': '2.3', 'Title': 'Ensure no network security groups allow ingress from 0.0.0.0/0 to port 22.', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.4','12.3'], 'CCCS Guard Rail' : '2,3,5,7,9','Remediation':[]},
            '2.4': {'section': 'Networking', 'recommendation_#': '2.4', 'Title': 'Ensure no network security groups allow ingress from 0.0.0.0/0 to port 3389.', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.4','12.3'], 'CCCS Guard Rail' : '2,3,5,7,9','Remediation':[]},
            '2.5': {'section': 'Networking', 'recommendation_#': '2.5', 'Title': 'Ensure the default security list of every VCN restricts all traffic except ICMP.', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['12.3'], 'CCCS Guard Rail' : '2,3,5,7,9','Remediation':[]},
            '2.6': {'section': 'Networking', 'recommendation_#': '2.6', 'Title': 'Ensure Oracle Integration Cloud (OIC) access is restricted to allowed sources.', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.4','12.3'], 'CCCS Guard Rail' : '2,3,5,7,9','Remediation':[]},
            '2.7': {'section': 'Networking', 'recommendation_#': '2.7', 'Title': 'Ensure Oracle Analytics Cloud (OAC) access is restricted to allowed sources or deployed within a Virtual Cloud Network.', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.4','12.3'], 'CCCS Guard Rail' : '2,3,5,7,9','Remediation':[]},
            '2.8': {'section': 'Networking', 'recommendation_#': '2.8', 'Title': 'Ensure Oracle Autonomous Shared Database (ADB) access is restricted or deployed within a VCN.', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.4','12.3'], 'CCCS Guard Rail' : '2,3,5,7,9','Remediation':[]},

            '3.1': {'section': 'Logging and Monitoring', 'recommendation_#': '3.1', 'Title': 'Ensure audit log retention period is set to 365 days.', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['8.10'], 'CCCS Guard Rail' : '11','Remediation':[]},
            '3.2': {'section': 'Logging and Monitoring', 'recommendation_#': '3.2', 'Title': 'Ensure default tags are used on resources.', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['1.1'], 'CCCS Guard Rail' : '','Remediation':[]},
            '3.3': {'section': 'Logging and Monitoring', 'recommendation_#': '3.3', 'Title': 'Create at least one notification topic and subscription to receive monitoring alerts.', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['8.2','8.11'], 'CCCS Guard Rail' : '11','Remediation':[]},
            '3.4': {'section': 'Logging and Monitoring', 'recommendation_#': '3.4', 'Title': 'Ensure a notification is configured for Identity Provider changes.', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11','Remediation':[]},
            '3.5': {'section': 'Logging and Monitoring', 'recommendation_#': '3.5', 'Title': 'Ensure a notification is configured for IdP group mapping changes.', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11','Remediation':[]},
            '3.6': {'section': 'Logging and Monitoring', 'recommendation_#': '3.6', 'Title': 'Ensure a notification is configured for IAM group changes.', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11','Remediation':[]},
            '3.7': {'section': 'Logging and Monitoring', 'recommendation_#': '3.7', 'Title': 'Ensure a notification is configured for IAM policy changes.', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11','Remediation':[]},
            '3.8': {'section': 'Logging and Monitoring', 'recommendation_#': '3.8', 'Title': 'Ensure a notification is configured for user changes.', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11','Remediation':[]},
            '3.9': {'section': 'Logging and Monitoring', 'recommendation_#': '3.9', 'Title': 'Ensure a notification is configured for VCN changes.', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11','Remediation':[]},
            '3.10': {'section': 'Logging and Monitoring', 'recommendation_#': '3.10', 'Title': 'Ensure a notification is configured for changes to route tables.', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11','Remediation':[]},
            '3.11': {'section': 'Logging and Monitoring', 'recommendation_#': '3.11', 'Title': 'Ensure a notification is configured for security list changes.', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11','Remediation':[]},
            '3.12': {'section': 'Logging and Monitoring', 'recommendation_#': '3.12', 'Title': 'Ensure a notification is configured for network security group changes.', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11','Remediation':[]},
            '3.13': {'section': 'Logging and Monitoring', 'recommendation_#': '3.13', 'Title': 'Ensure a notification is configured for changes to network gateways.', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11','Remediation':[]},
            '3.14': {'section': 'Logging and Monitoring', 'recommendation_#': '3.14', 'Title': 'Ensure VCN flow logging is enabled for all subnets.', 'Status': True, 'Level': 2, 'Findings': [], 'CISv8': ['8.2','8.5','13.6'], 'CCCS Guard Rail' : '','Remediation':[]},
            '3.15': {'section': 'Logging and Monitoring', 'recommendation_#': '3.15', 'Title': 'Ensure Cloud Guard is enabled in the root compartment of the tenancy.', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['8.2','8.5','8.11'], 'CCCS Guard Rail' : '1,2,3','Remediation':[]},
            '3.16': {'section': 'Logging and Monitoring', 'recommendation_#': '3.16', 'Title': 'Ensure customer created Customer Managed Key (CMK) is rotated at least annually.', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': [], 'CCCS Guard Rail' : '6,7','Remediation':[]},
            '3.17': {'section': 'Logging and Monitoring', 'recommendation_#': '3.17', 'Title': 'Ensure write level Object Storage logging is enabled for all buckets.', 'Status': True, 'Level': 2, 'Findings': [], 'CISv8': ['8.2'], 'CCCS Guard Rail' : '','Remediation':[]},

            '4.1.1': {'section': 'Storage - Object Storage', 'recommendation_#': '4.1.1', 'Title': 'Ensure no Object Storage buckets are publicly visible.', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['3.3'], 'CCCS Guard Rail' : '','Remediation':[]},
            '4.1.2': {'section': 'Storage - Object Storage', 'recommendation_#': '4.1.2', 'Title': 'Ensure Object Storage Buckets are encrypted with a Customer-Managed Key (CMK).', 'Status': True, 'Level': 2, 'Findings': [], 'CISv8': ['3.11'], 'CCCS Guard Rail' : '','Remediation':[]},
            '4.1.3': {'section': 'Storage - Object Storage', 'recommendation_#': '4.1.3', 'Title': 'Ensure Versioning is Enabled for Object Storage Buckets.', 'Status': True, 'Level': 2, 'Findings': [], 'CISv8': ['3.11'], 'CCCS Guard Rail' : '','Remediation':[]},
            '4.2.1': {'section': 'Storage - Block Volumes', 'recommendation_#': '4.2.1', 'Title': 'Ensure Block Volumes are encrypted with Customer-Managed Keys.', 'Status': True, 'Level': 2, 'Findings': [], 'CISv8': ['3.11'], 'CCCS Guard Rail' : ''},
            '4.2.2': {'section': 'Storage - Block Volumes', 'recommendation_#': '4.2.2', 'Title': 'Ensure Boot Volumes are encrypted with Customer-Managed Key.', 'Status': True, 'Level': 2, 'Findings': [], 'CISv8': ['3.11'], 'CCCS Guard Rail' : ''},
            '4.3.1': {'section': 'Storage - File Storage Service', 'recommendation_#': '4.3.1', 'Title': 'Ensure File Storage Systems are encrypted with Customer-Managed Keys.', 'Status': True, 'Level': 2, 'Findings': [], 'CISv8': ['3.11'], 'CCCS Guard Rail' : '','Remediation':[]},


            '5.1': {'section': 'Asset Management', 'recommendation_#': '5.1', 'Title': 'Create at least one compartment in your tenancy to store cloud resources.', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['3.1'], 'CCCS Guard Rail' : '2,3,8,12','Remediation':[]},
            '5.2': {'section': 'Asset Management', 'recommendation_#': '5.2', 'Title': 'Ensure no resources are created in the root compartment.', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['3.12'], 'CCCS Guard Rail' : '1,2,3','Remediation':[]}
        }
        # Remediation Report
        self.cis_report_data = {
            "1.1":{ "Description":"To apply least-privilege security principle, one can create service-level administrators in corresponding groups and assigning specific users to each service-level administrative group in a tenancy. This limits administrative access in a tenancy.<br><br>It means service-level administrators can only manage resources of a specific service.<br><br>Example policies for global/tenant level service-administrators\n<pre>\nAllow group VolumeAdmins to manage volume-family in tenancy\nAllow group ComputeAdmins to manage instance-family in tenancy\nAllow group NetworkAdmins to manage virtual-network-family in tenancy\n</pre>\nOrganizations have various ways of defining service-administrators. Some may prefer creating service administrators at a tenant level and some per department or per project or even per application environment (dev/test/production etc.). Either approach works so long as the policies are written to limit access given to the service-administrators.<br><br>Example policies for compartment level service-administrators <br><br><pre>Allow group NonProdComputeAdmins to manage instance-family in compartment dev\nAllow group ProdComputeAdmins to manage instance-family in compartment production\nAllow group A-Admins to manage instance-family in compartment Project-A\nAllow group A-Admins to manage volume-family in compartment Project-A\n</pre>",
            "Rationale":"Creating service-level administrators helps in tightly controlling access to Oracle Cloud Infrastructure (OCI) services to implement the least-privileged security principle.",
            "Impact":"",
            "Remediation":"Refer to the policy syntax document and create new policies if the audit results indicate that the required policies are missing.",
            "Recommendation":"",
            "Observation": "custom IAM policy that grants tenancy administrative access."
            },
            "1.2":{ "Description":"There is a built-in OCI IAM policy enabling the Administrators group to perform any action within a tenancy. In the OCI IAM console, this policy reads:<br><br><pre>\nAllow group Administrators to manage all-resources in tenancy\n</pre><br><br>Administrators create more users, groups, and policies to provide appropriate access to other groups.<br><br>Administrators should not allow any-other-group full access to the tenancy by writing a policy like this:<br><br><pre>\nAllow group any-other-group to manage all-resources in tenancy\n</pre><br><br>The access should be narrowed down to ensure the least-privileged principle is applied.",
            "Rationale":"Permission to manage all resources in a tenancy should be limited to a small number of users in the 'Administrators' group for break-glass situations and to set up users/groups/policies when a tenancy is created.<br><br>No group other than 'Administrators' in a tenancy should need access to all resources in a tenancy, as this violates the enforcement of the least privilege principle.",
            "Impact":"",
            "Remediation":"Remove any policy statement that allows any group other than Administrators or any service access to manage all resources in the tenancy.",
            "Recommendation":"Evaluate if tenancy-wide administrative access is needed for the identified policy and update it to be more restrictive.",
            "Observation":"custom IAM policy that grants tenancy administrative access."
            },
            "1.3":{ "Description":"Tenancy administrators can create more users, groups, and policies to provide other service administrators access to OCI resources.<br><br>For example, an IAM administrator will need to have access to manage\n resources like compartments, users, groups, dynamic-groups, policies, identity-providers, tenancy tag-namespaces, tag-definitions in the tenancy.<br><br>The policy that gives IAM-Administrators or any other group full access to 'groups' resources should not allow access to the tenancy 'Administrators' group.<br><br>The policy statements would look like:<br><br><pre>\nAllow group IAMAdmins to inspect users in tenancy\nAllow group IAMAdmins to use users in tenancy where target.group.name != 'Administrators'\nAllow group IAMAdmins to inspect groups in tenancy\nAllow group IAMAdmins to use groups in tenancy where target.group.name != 'Administrators'\n</pre><br><br><b>Note:</b> You must include separate statements for 'inspect' access, because the target.group.name variable is not used by the ListUsers and ListGroups operations",
            "Rationale":"These policy statements ensure that no other group can manage tenancy administrator users or the membership to the 'Administrators' group thereby gain or remove tenancy administrator access.",
            "Impact":"",
            "Remediation":"Verify the results to ensure that the policy statements that grant access to use or manage users or groups in the tenancy have a condition that excludes access to Administrators group or to users in the Administrators group.",
            "Recommendation":"Evaluate if tenancy-wide administrative access is needed for the identified policy and update it to be more restrictive.",
            "Observation":"custom IAM policy that grants tenancy administrative access."
            },
            "1.4":{ "Description":"Password policies are used to enforce password complexity requirements. IAM password policies can be used to ensure password are at least a certain length and are composed of certain characters.<br><br>It is recommended the password policy require a minimum password length 14 characters and contain 1 non-alphabetic\ncharacter (Number or 'Special Character').",
            "Rationale":"In keeping with the overall goal of having users create a password that is not overly weak, an eight-character minimum password length is recommended for an MFA account, and 14 characters for a password only account. In addition, maximum password length should be made as long as possible based on system/software capabilities and not restricted by policy.<br><br>In general, it is true that longer passwords are better (harder to crack), but it is also true that forced password length requirements can cause user behavior that is predictable and undesirable. For example, requiring users to have a minimum 16-character password may cause them to choose repeating patterns like fourfourfourfour or passwordpassword that meet the requirement but aren't hard to guess. Additionally, length requirements increase the chances that users will adopt other insecure practices, like writing them down, re-using them or storing them unencrypted in their documents. <br><br>Password composition requirements are a poor defense against guessing attacks. Forcing users to choose some combination of upper-case, lower-case, numbers, and special characters has a negative impact. It places an extra burden on users and many\nwill use predictable patterns (for example, a capital letter in the first position, followed by lowercase letters, then one or two numbers, and a “special character” at the end). Attackers know this, so dictionary attacks will often contain these common patterns and use the most common substitutions like, $ for s, @ for a, 1 for l, 0 for o.<br><br>Passwords that are too complex in nature make it harder for users to remember, leading to bad practices. In addition, composition requirements provide no defense against common attack types such as social engineering or insecure storage of passwords.",
            "Impact":"",
            "Remediation":"Update the password policy such as minimum length to 14, password must contain expected special characters and numeric characters.",
            "Recommendation":"It is recommended the password policy require a minimum password length 14 characters and contain 1 non-alphabetic character (Number or 'Special Character').",
            "Observation":"password policy/policies that do not enforce sufficient password complexity requirements."
            },
            "1.5":{ "Description":"IAM password policies can require passwords to be rotated or expired after a given number of days. It is recommended that the password policy expire passwords after 365 and are changed immediately based on events.",
            "Rationale":"Excessive password expiration requirements do more harm than good, because these requirements make users select predictable passwords, composed of sequential words and numbers that are closely related to each other.10 In these cases, the next password can be predicted based on the previous one (incrementing a number used in the password for example). Also, password expiration requirements offer no containment benefits because attackers will often use credentials as soon as they compromise them. Instead, immediate password changes should be based on key events including, but not\nlimited to:<br><br>1. Indication of compromise\n1. Change of user roles\n1. When a user leaves the organization.<br><br>Not only does changing passwords every few weeks or months frustrate the user, it's been suggested that it does more harm than good, because it could lead to bad practices by the user such as adding a character to the end of their existing password.<br><br>In addition, we also recommend a yearly password change. This is primarily because for all their good intentions users will share credentials across accounts. Therefore, even if a breach is publicly identified, the user may not see this notification, or forget they have an account on that site. This could leave a shared credential vulnerable indefinitely. Having an organizational policy of a 1-year (annual) password expiration is a reasonable compromise to mitigate this with minimal user burden.",
            "Impact":"",
            "Remediation":"Update the password policy by setting number of days configured in Expires after to 365.",
            "Recommendation":"Evaluate password rotation policies are inline with your organizational standard.",
            "Observation":"password policy/policies that do not require rotation."
            },
            "1.6":{ "Description":"IAM password policies can prevent the reuse of a given password by the same user. It is recommended the password policy prevent the reuse of passwords.",
            "Rationale":"Enforcing password history ensures that passwords are not reused in for a certain period of time by the same user. If a user is not allowed to use last 24 passwords, that window of time is greater. This helps maintain the effectiveness of password security.",
            "Impact":"",
            "Remediation":"Update the number of remembered passwords in previous passwords remembered setting to 24 in the password policy.",
            "Recommendation":"Evaluate password reuse policies are inline with your organizational standard.",
            "Observation":"password policy/policies that do not prevent reuse."
            },
            "1.7":{ "Description":"Multi-factor authentication is a method of authentication that requires the use of more than one factor to verify a user's identity.<br><br>With MFA enabled in the IAM service, when a user signs in to Oracle Cloud Infrastructure, they are prompted for their user name and password, which is the first factor (something that they know). The user is then prompted to provide a second verification code from a registered MFA device, which is the second factor (something that they have). The two factors work together, requiring an extra layer of security to verify the user's identity and complete the sign-in process.<br><br>OCI IAM supports two-factor authentication using a password (first factor) and a device that can generate a time-based one-time password (TOTP) (second factor).<br><br>See [OCI documentation](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Tasks/usingmfa.htm) for more details.",
            "Rationale":"Multi factor authentication adds an extra layer of security during the login process and makes it harder for unauthorized users to gain access to OCI resources.",
            "Impact":"",
            "Remediation":"Each user must enable MFA for themselves using a device they will have access to every time they sign in. An administrator cannot enable MFA for another user but can enforce MFA by identifying the list of non-complaint users, notifying them or disabling access by resetting password for non-complaint accounts.",
            "Recommendation":"Evaluate if local users are required. For Break Glass accounts ensure MFA is in place.",
            "Observation":"users with Password access but not MFA."
            },
            "1.8":{ "Description":"API keys are used by administrators, developers, services and scripts for accessing OCI APIs directly or via SDKs/OCI CLI to search, create, update or delete OCI resources.<br><br>The API key is an RSA key pair. The private key is used for signing the API requests and the public key is associated with a local or synchronized user's profile.",
            "Rationale":"It is important to secure and rotate an API key every 90 days or less as it provides the same level of access that a user it is associated with has.<br><br>In addition to a security engineering best practice, this is also a compliance requirement. For example, PCI-DSS Section 3.6.4 states, \"Verify that key-management procedures include a defined cryptoperiod for each key type in use and define a process for key changes at the end of the defined crypto period(s).\"",
            "Impact":"",
            "Remediation":"Delete any API Keys with a date of 90 days or older under the Created column of the API Key table.",
            "Recommendation":"Evaluate if APIs Keys are still used/required and rotate API Keys It is important to secure and rotate an API key every 90 days or less as it provides the same level of access that a user it is associated with has.",
            "Observation":"user(s) with APIs that have not been rotated with 90 days."
            },
            "1.9":{ "Description":"Object Storage provides an API to enable interoperability with Amazon S3. To use this Amazon S3 Compatibility API, you need to generate the signing key required to authenticate with Amazon S3.<br><br>This special signing key is an Access Key/Secret Key pair. Oracle generates the Customer Secret key to pair with the Access Key.",
            "Rationale":"It is important to secure and rotate an customer secret key every 90 days or less as it provides the same level of object storage access that a user is associated with has.",
            "Impact":"",
            "Remediation":"Delete any Access Keys with a date of 90 days or older under the Created column of the Customer Secret Keys.",
            "Recommendation":"Evaluate if Customer Secret Keys are still used/required and rotate the Keys accordingly.",
            "Observation":"users with Customer Secret Keys that have not been rotated with 90 days."
            },
            "1.10":{ "Description":"Auth tokens are authentication tokens generated by Oracle. You use auth tokens to authenticate with APIs that do not support the Oracle Cloud Infrastructure signature-based authentication. If the service requires an auth token, the service-specific documentation instructs you to generate one and how to use it.",
            "Rationale":"It is important to secure and rotate an auth token every 90 days or less as it provides the same level of access to APIs that do not support the OCI signature-based authentication as the user associated to it.",
            "Impact":"",
            "Remediation":"Delete any auth token with a date of 90 days or older under the Created column of the Auth Tokens.",
            "Recommendation":"Evaluate if Auth Tokens are still used/required and rotate Auth tokens.",
            "Observation":"user(s) with auth tokens that have not been rotated in 90 days."
            },
            "1.11":{ "Description":"Tenancy administrator users have full access to the organization's OCI tenancy. API keys associated with user accounts are used for invoking the OCI APIs via custom programs or clients like CLI/SDKs. The clients are typically used for performing day-to-day operations and should never require full tenancy access. Service-level administrative users with API keys should be used instead.",
            "Rationale":"For performing day-to-day operations tenancy administrator access is not needed.\nService-level administrative users with API keys should be used to apply privileged security principle.",
            "Impact":"",
            "Remediation":"For each tenancy administrator user who has an API key,select API Keys from the menu and delete any associated keys from the API Keys table.",
            "Recommendation":"Evaluate if a user with API Keys requires Administrator access and use a least privilege approach.",
            "Observation":"users with Administrator access and API Keys."
            },
            "1.12":{ "Description":"All OCI IAM local user accounts have an email address field associated with the account. It is recommended to specify an email address that is valid and current.<br><br>If you have an email address in your user profile, you can use the Forgot Password link on the sign on page to have a temporary password sent to you.",
            "Rationale":"Having a valid and current email address associated with an OCI IAM local user account allows you to tie the account to identity in your organization. It also allows that user to reset their password if it is forgotten or lost.",
            "Impact":"",
            "Remediation":"Update the current email address in the email text box on exch non compliant user.",
            "Recommendation":"Add emails to users to allow them to use the 'Forgot Password' feature and uniquely identify the user. For service accounts it could be a mail alias.",
            "Observation":"without an email."
            },
            "1.13":{ "Description":"OCI instances, OCI database and OCI functions can access other OCI resources either via an OCI API key associated to a user or by being including in a Dynamic Group that has an IAM policy granting it the required access. Access to OCI Resources refers to making API calls to another OCI resource like Object Storage, OCI Vaults, etc.",
            "Rationale":"Dynamic Groups reduces the risks related to hard coded credentials. Hard coded API keys can be shared and require rotation which can open them up to being compromised. Compromised credentials could allow access to OCI services outside of the expected radius.",
            "Impact":"For an OCI instance that contains embedded credential audit the scripts and environment variables to ensure that none of them contain OCI API Keys or credentials.",
            "Remediation":"Create Dynamic group and Enter Matching Rules to that includes the instances accessing your OCI resources. Refer:\"https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/managingdynamicgroups.htm\".",
            "Recommendation":"Evaluate how your instances, functions, and autonomous database interact with other OCI services.",
            "Observation":"Dynamic Groups reduces the risks related to hard coded credentials. Hard coded API keys can be shared and require rotation which can open them up to being compromised. Compromised credentials could allow access to OCI services outside of the expected radius."
            },
            "1.14":{ "Description":"To apply the separation of duties security principle, one can restrict service-level administrators from being able to delete resources they are managing. It means service-level administrators can only manage resources of a specific service but not delete resources for that specific service.<br><br>Example policies for global/tenant level for block volume service-administrators:\n<pre>\nAllow group VolumeUsers to manage volumes in tenancy where request.permission!='VOLUME_DELETE'\nAllow group VolumeUsers to manage volume-backups in tenancy where request.permission!='VOLUME_BACKUP_DELETE'\n</pre><br>Example policies for global/tenant level for file storage system service-administrators:<br><pre>\nAllow group FileUsers to manage file-systems in tenancy where request.permission!='FILE_SYSTEM_DELETE'\nAllow group FileUsers to manage mount-targets in tenancy where request.permission!='MOUNT_TARGET_DELETE'\nAllow group FileUsers to manage export-sets in tenancy where request.permission!='EXPORT_SET_DELETE'\n</pre><br><br>Example policies for global/tenant level for object storage system service-administrators:<br><pre>\nAllow group BucketUsers to manage objects in tenancy where request.permission!='OBJECT_DELETE'\nAllow group BucketUsers to manage buckets in tenancy where request.permission!='BUCKET_DELETE'\n</pre>",
            "Rationale":"Creating service-level administrators without the ability to delete the resource they are managing helps in tightly controlling access to Oracle Cloud Infrastructure (OCI) services by implementing the separation of duties security principle.",
            "Impact":"",
            "Remediation":"Add the appropriate where condition to any policy statement that allows the storage service-level to manage the storage service.",
            "Recommendation":"To apply a separation of duties security principle, it is recommended to restrict service-level administrators from being able to delete resources they are managing.",
            "Observation":"IAM Policies that give service administrator the ability to delete service resources."
            },
            "2.1":{ "Description":"Security lists provide stateful or stateless filtering of ingress/egress network traffic to OCI resources on a subnet level. It is recommended that no security group allows unrestricted ingress access to port 22.",
            "Rationale":"Removing unfettered connectivity to remote console services, such as Secure Shell (SSH), reduces a server's exposure to risk.",
            "Impact":"For updating an existing environment, care should be taken to ensure that administrators currently relying on an existing ingress from 0.0.0.0/0 have access to ports 22 and/or 3389 through another network security group or security list.",
            "Remediation":"For each security list in the returned results, click the security list name. Either edit the ingress rule to be more restrictive, delete the ingress rule or click on the VCN and terminate the security list as appropriate.",
            "Recommendation":"Review the security lists. If they are not used(attached to a subnet) they should be deleted if possible or empty. For attached security lists it is recommended to restrict the CIDR block to only allow access to Port 22 from known networks.",
            "Observation":"Security lists that allow internet access to port 22. (Note this does not necessarily mean external traffic can reach a compute instance)."
            },
            "2.2":{ "Description":"Security lists provide stateful or stateless filtering of ingress/egress network traffic to OCI resources on a subnet level. It is recommended that no security group allows unrestricted ingress access to port 3389.",
            "Rationale":"Removing unfettered connectivity to remote console services, such as Remote Desktop Protocol (RDP), reduces a server's exposure to risk.",
            "Impact":"For updating an existing environment, care should be taken to ensure that administrators currently relying on an existing ingress from 0.0.0.0/0 have access to ports 22 and/or 3389 through another network security group or security list.",
            "Remediation":"For each security list in the returned results, click the security list name. Either edit the ingress rule to be more restrictive, delete the ingress rule or click on the VCN and terminate the security list as appropriate.",
            "Recommendation":"Review the security lists. If they are not used(attached to a subnet) they should be deleted if possible or empty. For attached security lists it is recommended to restrict the CIDR block to only allow access to Port 3389 from known networks.",
            "Observation":"Security lists that allow internet access to port 3389. (Note this does not necessarily mean external traffic can reach a compute instance)."
            },
            "2.3":{ "Description":"Network security groups provide stateful filtering of ingress/egress network traffic to OCI resources. It is recommended that no security group allows unrestricted ingress access to port 22.",
            "Rationale":"Removing unfettered connectivity to remote console services, such as Secure Shell (SSH), reduces a server's exposure to risk.",
            "Impact":"For updating an existing environment, care should be taken to ensure that administrators currently relying on an existing ingress from 0.0.0.0/0 have access to ports 22 and/or 3389 through another network security group or security list.",
            "Remediation":"Using the details returned from the audit procedure either Remove the security rules or Update the security rules.",
            "Recommendation":"Review the network security groups. If they are not used(attached to a subnet) they should be deleted if possible or empty. For attached security lists it is recommended to restrict the CIDR block to only allow access to Port 3389 from known networks.",
            "Observation":"Network security groups that allow internet access to port 22. (Note this does not necessarily mean external traffic can reach a compute instance)."
            },
            "2.4":{ "Description":"Network security groups provide stateful filtering of ingress/egress network traffic to OCI resources. It is recommended that no security group allows unrestricted ingress access to port 3389.",
            "Rationale":"Removing unfettered connectivity to remote console services, such as Remote Desktop Protocol (RDP), reduces a server's exposure to risk.",
            "Impact":"For updating an existing environment, care should be taken to ensure that administrators currently relying on an existing ingress from 0.0.0.0/0 have access to ports 22 and/or 3389 through another network security group or security list.",
            "Remediation":"Using the details returned from the audit procedure either Remove the security rules or Update the security rules.",
            "Recommendation":"Review the network security groups. If they are not used(attached to a subnet) they should be deleted if possible or empty. For attached network security groups it is recommended to restrict the CIDR block to only allow access to Port 3389 from known networks.",
            "Observation":"Network security groups that allow internet access to port 3389. (Note this does not necessarily mean external traffic can reach a compute instance)."
            },
            "2.5":{ "Description":"A default security list is created when a Virtual Cloud Network (VCN) is created. Security lists provide stateful filtering of ingress and egress network traffic to OCI resources. It is recommended no security list allows unrestricted ingress access to Secure Shell (SSH) via port 22.",
            "Rationale":"Removing unfettered connectivity to remote console services, such as SSH on port 22, reduces a server's exposure to unauthorized access.",
            "Impact":"For updating an existing environment, care should be taken to ensure that administrators currently relying on an existing ingress from 0.0.0.0/0 have access to ports 22 and/or 3389 through another security group.",
            "Remediation":"Select Default Security List for <VCN Name> and Remove the Ingress Rule with Source 0.0.0.0/0, IP Protocol 22 and Destination Port Range 22.",
            "Recommendation":"Create specific custom security lists with workload specific rules and attach to subnets.",
            "Observation":"Default Security lists that allow more traffic then ICMP."
            },
            "2.6":{ "Description":"Oracle Integration (OIC) is a complete, secure, but lightweight integration solution that enables you to connect your applications in the cloud. It simplifies connectivity between your applications and connects both your applications that live in the cloud and your applications that still live on premises. Oracle Integration provides secure, enterprise-grade connectivity regardless of the applications you are connecting or where they reside. OIC instances are created within an Oracle managed secure private network with each having a public endpoint. The capability to configure ingress filtering of network traffic to protect your OIC instances from unauthorized network access is included. It is recommended that network access to your OIC instances be restricted to your approved corporate IP Addresses or Virtual Cloud Networks (VCN)s.",
            "Rationale":"Restricting connectivity to OIC Instances reduces an OIC instance's exposure to risk.",
            "Impact":"When updating ingress filters for an existing environment, care should be taken to ensure that IP addresses and VCNs currently used by administrators, users, and services to access your OIC instances are included in the updated filters.",
            "Remediation":"For each OIC instance in the returned results, select the OIC Instance name,edit the Network Access to be more restrictive.",
            "Recommendation":"It is recommended that OIC Network Access is restricted to your corporate IP Addresses or VCNs for OIC Instances.",
            "Observation":"OIC Instances that allow unfiltered public ingress traffic (Authentication and authorization is still required)."
            },
            "2.7":{ "Description":"Oracle Analytics Cloud (OAC) is a scalable and secure public cloud service that provides a full set of capabilities to explore and perform collaborative analytics for you, your workgroup, and your enterprise. OAC instances provide ingress filtering of network traffic or can be deployed with in an existing Virtual Cloud Network VCN. It is recommended that all new OAC instances be deployed within a VCN and that the Access Control Rules are restricted to your corporate IP Addresses or VCNs for existing OAC instances.",
            "Rationale":"Restricting connectivity to Oracle Analytics Cloud instances reduces an OAC instance's exposure to risk.",
            "Impact":"When updating ingress filters for an existing environment, care should be taken to ensure that IP addresses and VCNs currently used by administrators, users, and services to access your OAC instances are included in the updated filters. Also, these changes will temporarily bring the OAC instance offline.",
            "Remediation":"For each OAC instance in the returned results, select the OAC Instance name edit the Access Control Rules by clicking +Another Rule and add rules as required.",
            "Recommendation":"It is recommended that all new OAC instances be deployed within a VCN and that the Access Control Rules are restricted to your corporate IP Addresses or VCNs for existing OAC instances.",
            "Observation":"OAC Instances that allow unfiltered public ingress traffic (Authentication and authorization is still required)."
            },
            "2.8":{ "Description":"Oracle Autonomous Database Shared (ADB-S) automates database tuning, security, backups, updates, and other routine management tasks traditionally performed by DBAs. ADB-S provide ingress filtering of network traffic or can be deployed within an existing Virtual Cloud Network (VCN). It is recommended that all new ADB-S databases be deployed within a VCN and that the Access Control Rules are restricted to your corporate IP Addresses or VCNs for existing ADB-S databases.",
            "Rationale":"Restricting connectivity to ADB-S Databases reduces an ADB-S database's exposure to risk.",
            "Impact":"When updating ingress filters for an existing environment, care should be taken to ensure that IP addresses and VCNs currently used by administrators, users, and services to access your ADB-S instances are included in the updated filters.",
            "Remediation":"For each ADB-S database in the returned results, select the ADB-S database name edit the Access Control Rules by clicking +Another Rule and add rules as required.",
            "Recommendation":"It is recommended that all new ADB-S databases be deployed within a VCN and that the Access Control Rules are restricted to your corporate IP Addresses or VCNs for existing ADB-S databases.",
            "Observation":"ADB-S Instances that allow unfiltered public ingress traffic (Authentication and authorization is still required)."
            },
            "3.1":{ "Description":"Ensuring audit logs are kept for 365 days.",
            "Rationale":"Log retention controls how long activity logs should be retained. Studies have shown that The Mean Time to Detect (MTTD) a cyber breach is anywhere from 30 days in some sectors to up to 206 days in others. Retaining logs for at least 365 days or more will provide the ability to respond to incidents.",
            "Impact":"There is no performance impact when enabling the above described features but additional audit data will be retained.",
            "Remediation":"Go to the Tenancy Details page and edit Audit Retention Policy by setting AUDIT RETENTION PERIOD to 365.",
            "Recommendation":"",
            "Observation":""
            },
            "3.2":{ "Description":"Using default tags is a way to ensure all resources that support tags are tagged during creation. Tags can be based on static values or based on computed values. It is recommended to setup default tags early on to ensure all created resources will get tagged.\nTags are scoped to Compartments and are inherited by Child Compartments. The recommendation is to create default tags like “CreatedBy” at the Root Compartment level to ensure all resources get tagged.\nWhen using Tags it is important to ensure that Tag Namespaces are protected by IAM Policies otherwise this will allow users to change tags or tag values.\nDepending on the age of the OCI Tenancy there may already be Tag defaults setup at the Root Level and no need for further action to implement this action.",
            "Rationale":"In the case of an incident having default tags like “CreatedBy” applied will provide info on who created the resource without having to search the Audit logs.",
            "Impact":"There is no performance impact when enabling the above described features",
            "Remediation":"Update the root compartments tag default link.In the Tag Defaults table verify that there is a Tag with a value of \"${iam.principal.names}\" and a Tag Key Status of Active. Also cretae a Tag key definition by providing a Tag Key, Description and selecting 'Static Value' for Tag Value Type.",
            "Recommendation":"",
            "Observation":""
            },
            "3.3":{ "Description":"Notifications provide a multi-channel messaging service that allow users and applications to be notified of events of interest occurring within OCI. Messages can be sent via eMail, HTTPs, PagerDuty, Slack or the OCI Function service. Some channels, such as eMail require confirmation of the subscription before it becomes active.",
            "Rationale":"Creating one or more notification topics allow administrators to be notified of relevant changes made to OCI infrastructure.",
            "Impact":"There is no performance impact when enabling the above described features but depending on the amount of notifications sent per month there may be a cost associated.",
            "Remediation":"Create a Topic in the notifications service under the appropriate compartment and add the subscriptions with current email address and correct protocol.",
            "Recommendation":"",
            "Observation":""
            },
            "3.4":{ "Description":"It is recommended to setup an Event Rule and Notification that gets triggered when Identity Providers are created, updated or deleted. Event Rules are compartment scoped and will detect events in child compartments. It is recommended to create the Event rule at the root compartment level.",
            "Rationale":"OCI Identity Providers allow management of User ID / passwords in external systems and use of those credentials to access OCI resources. Identity Providers allow users to single sign-on to OCI console and have other OCI credentials like API Keys.\nMonitoring and alerting on changes to Identity Providers will help in identifying changes to the security posture.",
            "Impact":"There is no performance impact when enabling the above described features but depending on the amount of notifications sent per month there may be a cost associated.",
            "Remediation":"Create a Rule Condition in the Events services by selecting Identity in the Service Name Drop-down and selecting Identity Provider – Create, Identity Provider - Delete and Identity Provider – Update. In the Actions section select Notifications as Action Type and selct the compartment and topic to be used.",
            "Recommendation":"",
            "Observation":""
            },
            "3.5":{ "Description":"It is recommended to setup an Event Rule and Notification that gets triggered when Identity Provider Group Mappings are created, updated or deleted. Event Rules are compartment scoped and will detect events in child compartments. It is recommended to create the Event rule at the root compartment level",
            "Rationale":"IAM Policies govern access to all resources within an OCI Tenancy. IAM Policies use OCI Groups for assigning the privileges. Identity Provider Groups could be mapped to OCI Groups to assign privileges to federated users in OCI. Monitoring and alerting on changes to Identity Provider Group mappings will help in identifying changes to the security posture.",
            "Impact":"There is no performance impact when enabling the above described features but depending on the amount of notifications sent per month there may be a cost associated.",
            "Remediation":"Find and click the Rule that handles Idp Group Mapping Changes. Click the Edit Rule button and verify that the RuleConditions section contains a condition for the Service Identity and Event Types: Idp Group Mapping – Create, Idp Group Mapping – Delete, and Idp Group Mapping – Update and confirm Action Type contains: Notifications and that a valid Topic is referenced.",
            "Recommendation":"",
            "Observation":""
            },
            "3.6":{ "Description":"It is recommended to setup an Event Rule and Notification that gets triggered when IAM Groups are created, updated or deleted. Event Rules are compartment scoped and will detect events in child compartments, it is recommended to create the Event rule at the root compartment level.",
            "Rationale":"IAM Groups control access to all resources within an OCI Tenancy.\n Monitoring and alerting on changes to IAM Groups will help in identifying changes to satisfy least privilege principle.",
            "Impact":"There is no performance impact when enabling the above described features but depending on the amount of notifications sent per month there may be a cost associated.",
            "Remediation":"Create a Rule Condition by selecting Identity in the Service Name Drop-down and selecting Group – Create, Group – Delete and Group – Update. In the Actions section select Notifications as Action Type and selct the compartment and topic to be used.",
            "Recommendation":"",
            "Observation":""
            },
            "3.7":{ "Description":"It is recommended to setup an Event Rule and Notification that gets triggered when IAM Policies are created, updated or deleted. Event Rules are compartment scoped and will detect events in child compartments, it is recommended to create the Event rule at the root compartment level.",
            "Rationale":"IAM Policies govern access to all resources within an OCI Tenancy.\n Monitoring and alerting on changes to IAM policies will help in identifying changes to the security posture.",
            "Impact":"There is no performance impact when enabling the above described features but depending on the amount of notifications sent per month there may be a cost associated.",
            "Remediation":"Create a Rule Condition by selecting Identity in the Service Name Drop-down and selecting Policy – Change Compartment, Policy – Create, Policy - Delete and Policy – Update. In the Actions section select Notifications as Action Type and selct the compartment and topic to be used.",
            "Recommendation":"",
            "Observation":""
            },
            "3.8":{ "Description":"It is recommended to setup an Event Rule and Notification that gets triggered when IAM Users are created, updated, deleted, capabilities updated, or state updated. Event Rules are compartment scoped and will detect events in child compartments, it is recommended to create the Event rule at the root compartment level.",
            "Rationale":"Users use or manage Oracle Cloud Infrastructure resources.\n Monitoring and alerting on changes to Users will help in identifying changes to the security posture.",
            "Impact":"There is no performance impact when enabling the above described features but depending on the amount of notifications sent per month there may be a cost associated.",
            "Remediation":"Edit Rule that handles IAM User Changes and verify that the Rule Conditions section contains a condition for the Service Identity and Event Types: User – Create, User – Delete, User – Update, User Capabilities – Update, User State – Update.",
            "Recommendation":"",
            "Observation":""
            },
            "3.9":{ "Description":"It is recommended to setup an Event Rule and Notification that gets triggered when Virtual Cloud Networks are created, updated or deleted. Event Rules are compartment scoped and will detect events in child compartments, it is recommended to create the Event rule at the root compartment level.",
            "Rationale":"Virtual Cloud Networks (VCNs) closely resembles a traditional network.\n Monitoring and alerting on changes to VCNs will help in identifying changes to the security posture.",
            "Impact":"There is no performance impact when enabling the above described features but depending on the amount of notifications sent per month there may be a cost associated.",
            "Remediation":"Edit Rule that handles VCN Changes and verify that the RuleConditions section contains a condition for the Service Networking and Event Types: VCN – Create, VCN - Delete, and VCN – Update.",
            "Recommendation":"",
            "Observation":""
            },
            "3.10":{ "Description":"It is recommended to setup an Event Rule and Notification that gets triggered when route tables are created, updated or deleted. Event Rules are compartment scoped and will detect events in child compartments, it is recommended to create the Event rule at the root compartment level.",
            "Rationale":"Route tables control traffic flowing to or from Virtual Cloud Networks and Subnets.\n Monitoring and alerting on changes to route tables will help in identifying changes these traffic flows.",
            "Impact":"There is no performance impact when enabling the above described features but depending on the amount of notifications sent per month there may be a cost associated.",
            "Remediation":"Edit Rule that handles Route Table Changes and verify that the RuleConditions section contains a condition for the Service Networking and Event Types: Route Table – Change Compartment, Route Table – Create, Route Table - Delete, and Route Table – Update.",
            "Recommendation":"",
            "Observation":""
            },
            "3.11":{ "Description":"It is recommended to setup an Event Rule and Notification that gets triggered when security lists are created, updated or deleted. Event Rules are compartment scoped and will detect events in child compartments, it is recommended to create the Event rule at the root compartment level.",
            "Rationale":"Security Lists control traffic flowing into and out of Subnets within a Virtual Cloud Network.\n Monitoring and alerting on changes to Security Lists will help in identifying changes to these security controls.",
            "Impact":"There is no performance impact when enabling the above described features but depending on the amount of notifications sent per month there may be a cost associated.",
            "Remediation":"Edit Rule that handles Security List Changes and verify that the RuleConditions section contains a condition for the Service Networking and Event Types: Security List – Change Compartment, Security List – Create, Security List - Delete, and Security List – Update.",
            "Recommendation":"",
            "Observation":""
            },
            "3.12":{ "Description":"It is recommended to setup an Event Rule and Notification that gets triggered when network security groups are created, updated or deleted. Event Rules are compartment scoped and will detect events in child compartments, it is recommended to create the Event rule at the root compartment level.",
            "Rationale":"Network Security Groups control traffic flowing between Virtual Network Cards attached to Compute instances.\n Monitoring and alerting on changes to Network Security Groups will help in identifying changes these security controls.",
            "Impact":"There is no performance impact when enabling the above described features but depending on the amount of notifications sent per month there may be a cost associated.",
            "Remediation":"Edit Rule that handles Network Security Group Changes and verify that the RuleConditions section contains a condition for the Service Networking and Event Types: Network Security Group – Change Compartment, Network Security Group – Create, Network Security Group - Delete, and Network Security Group – Update.",
            "Recommendation":"",
            "Observation":""
            },
            "3.13":{ "Description":"It is recommended to setup an Event Rule and Notification that gets triggered when Network Gateways are created, updated, deleted, attached, detached, or moved. This recommendation includes Internet Gateways, Dynamic Routing Gateways, Service Gateways, Local Peering Gateways, and NAT Gateways. Event Rules are compartment scoped and will detect events in child compartments, it is recommended to create the Event rule at the root compartment level.",
            "Rationale":"Network Gateways act as routers between VCNs and the Internet, Oracle Services Networks, other VCNS, and on-premise networks.\n Monitoring and alerting on changes to Network Gateways will help in identifying changes to the security posture.",
            "Impact":"There is no performance impact when enabling the above described features but depending on the amount of notifications sent per month there may be a cost associated.",
            "Remediation":"Edit Rule that handles Network Gateways Changes and verify that the RuleConditions section contains a condition for the Service Networking and Event Types: DRG – Create, DRG - Delete, DRG - Update, DRG Attachment – Create, DRG Attachment – Delete, DRG Attachment - Update, Internet Gateway – Create, Internet Gateway – Delete, Internet Gateway - Update, Internet Gateway – Change Compartment, Local Peering Gateway – Create, Local Peering Gateway – Delete, Local Peering Gateway - Update, Local Peering Gateway – Change Compartment, NAT Gateway – Create, NAT Gateway – Delete, NAT Gateway - Update, NAT Gateway – Change Compartment.",
            "Recommendation":"",
            "Observation":""
            },
            "3.14":{ "Description":"VCN flow logs record details about traffic that has been accepted or rejected based on the security list rule.",
            "Rationale":"Enabling VCN flow logs enables you to monitor traffic flowing within your virtual network and can be used to detect anomalous traffic.",
            "Impact":"Enabling VCN flow logs will not affect the performance of your virtual network but it will generate additional use of object storage that should be controlled via object lifecycle management.<br><br>By default, VCN flow logs are stored for 30 days in object storage. Users can specify a longer retention period.",
            "Remediation":"Enable Flow Logs (all records) on Virtual Cloud Networks (subnets) under the relevant resource compartment. Before hand create Log group if not exist in the Log services.",
            "Recommendation":"",
            "Observation":""
            },
            "3.15":{ "Description":"Cloud Guard detects misconfigured resources and insecure activity within a tenancy and provides security administrators with the visibility to resolve these issues. Upon detection, Cloud Guard can suggest, assist, or take corrective actions to mitigate these issues. Cloud Guard should be enabled in the root compartment of your tenancy with the default configuration, activity detectors and responders.",
            "Rationale":"Cloud Guard provides an automated means to monitor a tenancy for resources that are configured in an insecure manner as well as risky network activity from these resources.",
            "Impact":"There is no performance impact when enabling the above described features, but additional IAM policies will be required.",
            "Remediation":"Enable the cloud guard by selecting the services in the menu and provide appropriate reporting region and other configurations.",
            "Recommendation":"",
            "Observation":""
            },
            "3.16":{ "Description":"Oracle Cloud Infrastructure Vault securely stores master encryption keys that protect your encrypted data. You can use the Vault service to rotate keys to generate new cryptographic material. Periodically rotating keys limits the amount of data encrypted by one key version.",
            "Rationale":"Rotating keys annually limits the data encrypted under one key version. Key rotation thereby reduces the risk in case a key is ever compromised.",
            "Impact":"",
            "Remediation":"Select the security service and select vault. Ensure the date of each Master Encryption Key under the Created column of the Master Encryption key is no more than 365 days old.",
            "Recommendation":"",
            "Observation":""
            },
            "3.17":{ "Description":"Object Storage write logs will log all write requests made to objects in a bucket.",
            "Rationale":"Enabling an Object Storage write log, the 'requestAction' property would contain values of 'PUT', 'POST', or 'DELETE'. This will provide you more visibility into changes to objects in your buckets.",
            "Impact":"There is no performance impact when enabling the above described features, but will generate additional use of object storage that should be controlled via object lifecycle management.<br><br>By default, Object Storage logs are stored for 30 days in object storage. Users can specify a longer retention period.",
            "Remediation":"To the relevant bucket enable log by providing Write Access Events from the Log Category. Beforehand create log group if required.",
            "Recommendation":"",
            "Observation":""
            },
            "4.1.1":{ "Description":"A bucket is a logical container for storing objects. It is associated with a single compartment that has policies that determine what action a user can perform on a bucket and on all the objects in the bucket. It is recommended that no bucket be publicly accessible.",
            "Rationale":"Removing unfettered reading of objects in a bucket reduces an organization's exposure to data loss.",
            "Impact":"For updating an existing bucket, care should be taken to ensure objects in the bucket can be accessed through either IAM policies or pre-authenticated requests.",
            "Remediation":"Edit the visibility into 'private' for each Bucket.",
            "Recommendation":"",
            "Observation":""
            },
            "4.1.2":{ "Description":"Oracle Object Storage buckets support encryption with a Customer Managed Key (CMK). By default, Object Storage buckets are encrypted with an Oracle managed key.",
            "Rationale":"Encryption of Object Storage buckets with a Customer Managed Key (CMK) provides an additional level of security on your data by allowing you to manage your own encryption key lifecycle management for the bucket.",
            "Impact":"Encrypting with a Customer Managed Keys requires a Vault and a Customer Master Key. In addition, you must authorize Object Storage service to use keys on your behalf.<br><br>Required Policy:\n<pre>\nAllow service objectstorage-&lt;region_name>, to use keys in compartment &ltcompartment-id> where target.key.id = '&lt;key_OCID>'<br><br></pre>",
            "Remediation":"Assign Master encryption key to Encryption key in every Object storage under Bucket name by clicking assign and select vault.",
            "Recommendation":"",
            "Observation":""
            },
            "4.1.3":{ "Description":"A bucket is a logical container for storing objects. Object versioning is enabled at the bucket level and is disabled by default upon creation. Versioning directs Object Storage to automatically create an object version each time a new object is uploaded, an existing object is overwritten, or when an object is deleted. You can enable object versioning at bucket creation time or later.",
            "Rationale":"Versioning object storage buckets provides for additional integrity of your data. Management of data integrity is critical to protecting and accessing protected data. Some customers want to identify object storage buckets without versioning in order to apply their own data lifecycle protection and management policy.",
            "Impact":"",
            "Remediation":"Enable Versioning by clicking on every bucket by editing the bucket configuration.",
            "Recommendation":"",
            "Observation":""
            },
            "4.2.1":{ "Description":"Oracle Cloud Infrastructure Block Volume service lets you dynamically provision and manage block storage volumes. By default, the Oracle service manages the keys that encrypt this block volume. Block Volumes can also be encrypted using a customer managed key.",
            "Rationale":"Encryption of block volumes provides an additional level of security for your data. Management of encryption keys is critical to protecting and accessing protected data. Customers should identify block volumes encrypted with Oracle service managed keys in order to determine if they want to manage the keys for certain volumes and then apply their own key lifecycle management to the selected block volumes.",
            "Impact":"Encrypting with a Customer Managed Keys requires a Vault and a Customer Master Key. In addition, you must authorize the Block Volume service to use the keys you create.\nRequired IAM Policy:\n<pre>\nAllow service blockstorage to use keys in compartment &ltcompartment-id> where target.key.id = '&lt;key_OCID>'\n</pre>",
            "Remediation":"For each block volumes from the result, assign the encryption key by Selecting the Vault Compartment and Vault, select the Master Encryption Key Compartment and Master Encryption key, click Assign.",
            "Recommendation":"",
            "Observation":""
            },
            "4.2.2":{ "Description":"When you launch a virtual machine (VM) or bare metal instance based on a platform image or custom image, a new boot volume for the instance is created in the same compartment. That boot volume is associated with that instance until you terminate the instance. By default, the Oracle service manages the keys that encrypt this boot volume. Boot Volumes can also be encrypted using a customer managed key.",
            "Rationale":"Encryption of boot volumes provides an additional level of security for your data. Management of encryption keys is critical to protecting and accessing protected data. Customers should identify boot volumes encrypted with Oracle service managed keys in order to determine if they want to manage the keys for certain boot volumes and then apply their own key lifecycle management to the selected boot volumes.",
            "Impact":"Encrypting with a Customer Managed Keys requires a Vault and a Customer Master Key. In addition, you must authorize the Boot Volume service to use the keys you create.\nRequired IAM Policy:\n<pre>\nAllow service Bootstorage to use keys in compartment &ltcompartment-id> where target.key.id = '&lt;key_OCID>'\n</pre>",
            "Remediation":"For each boot volumes from the result, assign the encryption key by Selecting the Vault Compartment and Vault, select the Master Encryption Key Compartment and Master Encryption key, click Assign.",
            "Recommendation":"",
            "Observation":""
            },
            "4.3.1":{ "Description":"Oracle Cloud Infrastructure File Storage service (FSS) provides a durable, scalable, secure, enterprise-grade network file system. By default, the Oracle service manages the keys that encrypt FSS file systems. FSS file systems can also be encrypted using a customer managed key.",
            "Rationale":"Encryption of FSS systems provides an additional level of security for your data. Management of encryption keys is critical to protecting and accessing protected data. Customers should identify FSS file systems that are encrypted with Oracle service managed keys in order to determine if they want to manage the keys for certain FSS file systems and then apply their own key lifecycle management to the selected FSS file systems.",
            "Impact":"Encrypting with a Customer Managed Keys requires a Vault and a Customer Master Key. In addition, you must authorize the File Storage service to use the keys you create.\nRequired IAM Policy:\n<pre>\nAllow service FssOc1Prod to use keys in compartment &ltcompartment-id> where target.key.id = '&lt;key_OCID>'\n</pre>",
            "Remediation":"For each file storage system from the result, assign the encryption key by Selecting the Vault Compartment and Vault, select the Master Encryption Key Compartment and Master Encryption key, click Assign.",
            "Recommendation":"",
            "Observation":""
            },
            "5.1":{ "Description":"When you sign up for Oracle Cloud Infrastructure, Oracle creates your tenancy, which is the root compartment that holds all your cloud resources. You then create additional compartments within the tenancy (root compartment) and corresponding policies to control access to the resources in each compartment.<br><br>Compartments allow you to organize and control access to your cloud resources. A compartment is a collection of related resources (such as instances, databases, virtual cloud networks, block volumes) that can be accessed only by certain groups that have been given permission by an administrator.",
            "Rationale":"Compartments are a logical group that adds an extra layer of isolation, organization and authorization making it harder for unauthorized users to gain access to OCI resources.",
            "Impact":"Once the compartment is created an OCI IAM policy must be created to allow a group to resources in the compartment otherwise only group with tenancy access will have access.",
            "Remediation":"Create the new compartment under the root compartment.",
            "Recommendation":"",
            "Observation":""
            },
            "5.2":{ "Description":"When you create a cloud resource such as an instance, block volume, or cloud network, you must specify to which compartment you want the resource to belong. Placing resources in the root compartment makes it difficult to organize and isolate those resources.",
            "Rationale":"Placing resources into a compartment will allow you to organize and have more granular access controls to your cloud resources.",
            "Impact":"Placing a resource in a compartment will impact how you write policies to manage access and organize that resource.",
            "Remediation":"For each item in the returned results,select Move Resource or More Actions then Move Resource and select compartment except root and choose new then move resources.",
            "Recommendation":"",
            "Observation":""
            }
        }

        # MAP Checks
        self.obp_foundations_checks = {
            'Cost_Tracking_Budgets' : {'Status' : False, 'Findings' : [], "OBP" : [], "Documentation" : ""},
            'SIEM_Audit_Log_All_Comps' : {'Status' : True, 'Findings' : [], "OBP" : [], "Documentation" : ""}, # Assuming True
            'SIEM_Audit_Incl_Sub_Comp' : {'Status' : True,'Findings' : [], "OBP" : [], "Documentation" : "" }, # Assuming True 
            'SIEM_VCN_Flow_Logging' : {'Status' : None, 'Findings' : [], "OBP" : [], "Documentation" : ""},
            'SIEM_Write_Bucket_Logs' : {'Status' : None, 'Findings' : [], "OBP" : [], "Documentation" : ""},
            'SIEM_Read_Bucket_Logs' : {'Status' : None, 'Findings' : [], "OBP" : [], "Documentation" : ""},
            'Networking_Connectivity' : {'Status' : True, 'Findings' : [], "OBP" : [], "Documentation" : "https://docs.oracle.com/en-us/iaas/Content/Network/Troubleshoot/drgredundancy.htm" },
            'Cloud_Guard_Config' : {'Status' : None, 'Findings' : [], "OBP" : [], "Documentation" : "" },
        }
        # MAP Regional Data
        self.__obp_regional_checks = {}


        # CIS monitoring notifications check
        self.cis_monitoring_checks = {
            "3.4": [
                'com.oraclecloud.identitycontrolplane.createidentityprovider',
                'com.oraclecloud.identitycontrolplane.deleteidentityprovider',
                'com.oraclecloud.identitycontrolplane.updateidentityprovider'
            ],
            "3.5": [
                'com.oraclecloud.identitycontrolplane.createidpgroupmapping',
                'com.oraclecloud.identitycontrolplane.deleteidpgroupmapping',
                'com.oraclecloud.identitycontrolplane.updateidpgroupmapping'
            ],
            "3.6": [
                'com.oraclecloud.identitycontrolplane.creategroup',
                'com.oraclecloud.identitycontrolplane.deletegroup',
                'com.oraclecloud.identitycontrolplane.updategroup'
            ],
            "3.7": [
                'com.oraclecloud.identitycontrolplane.createpolicy',
                'com.oraclecloud.identitycontrolplane.deletepolicy',
                'com.oraclecloud.identitycontrolplane.updatepolicy'
            ],
            "3.8": [
                'com.oraclecloud.identitycontrolplane.createuser',
                'com.oraclecloud.identitycontrolplane.deleteuser',
                'com.oraclecloud.identitycontrolplane.updateuser',
                'com.oraclecloud.identitycontrolplane.updateusercapabilities',
                'com.oraclecloud.identitycontrolplane.updateuserstate'
            ],
            "3.9": [
                'com.oraclecloud.virtualnetwork.createvcn',
                'com.oraclecloud.virtualnetwork.deletevcn',
                'com.oraclecloud.virtualnetwork.updatevcn'
            ],
            "3.10": [
                'com.oraclecloud.virtualnetwork.changeroutetablecompartment',
                'com.oraclecloud.virtualnetwork.createroutetable',
                'com.oraclecloud.virtualnetwork.deleteroutetable',
                'com.oraclecloud.virtualnetwork.updateroutetable'
            ],
            "3.11": [
                'com.oraclecloud.virtualnetwork.changesecuritylistcompartment',
                'com.oraclecloud.virtualnetwork.createsecuritylist',
                'com.oraclecloud.virtualnetwork.deletesecuritylist',
                'com.oraclecloud.virtualnetwork.updatesecuritylist'
            ],
            "3.12": [
                'com.oraclecloud.virtualnetwork.changenetworksecuritygroupcompartment',
                'com.oraclecloud.virtualnetwork.createnetworksecuritygroup',
                'com.oraclecloud.virtualnetwork.deletenetworksecuritygroup',
                'com.oraclecloud.virtualnetwork.updatenetworksecuritygroup'
            ],
            "3.13": [
                'com.oraclecloud.virtualnetwork.createdrg',
                'com.oraclecloud.virtualnetwork.deletedrg',
                'com.oraclecloud.virtualnetwork.updatedrg',
                'com.oraclecloud.virtualnetwork.createdrgattachment',
                'com.oraclecloud.virtualnetwork.deletedrgattachment',
                'com.oraclecloud.virtualnetwork.updatedrgattachment',
                'com.oraclecloud.virtualnetwork.changeinternetgatewaycompartment',
                'com.oraclecloud.virtualnetwork.createinternetgateway',
                'com.oraclecloud.virtualnetwork.deleteinternetgateway',
                'com.oraclecloud.virtualnetwork.updateinternetgateway',
                'com.oraclecloud.virtualnetwork.changelocalpeeringgatewaycompartment',
                'com.oraclecloud.virtualnetwork.createlocalpeeringgateway',
                'com.oraclecloud.virtualnetwork.deletelocalpeeringgateway.end',
                'com.oraclecloud.virtualnetwork.updatelocalpeeringgateway',
                'com.oraclecloud.natgateway.changenatgatewaycompartment',
                'com.oraclecloud.natgateway.createnatgateway',
                'com.oraclecloud.natgateway.deletenatgateway',
                'com.oraclecloud.natgateway.updatenatgateway',
                'com.oraclecloud.servicegateway.attachserviceid',
                'com.oraclecloud.servicegateway.changeservicegatewaycompartment',
                'com.oraclecloud.servicegateway.createservicegateway',
                'com.oraclecloud.servicegateway.deleteservicegateway.end',
                'com.oraclecloud.servicegateway.detachserviceid',
                'com.oraclecloud.servicegateway.updateservicegateway'

            ]
        }
        
        # CIS IAM  check
        self.cis_iam_checks = {
            "1.3": {"targets": ["target.group.name!=Administrators"]},
            "1.13": {"resources": ["fnfunc", "instance", "autonomousdatabase", "resource.compartment.id"]},
            "1.14": {"all-resources": ["request.permission!=BUCKET_DELETE", "request.permission!=OBJECT_DELETE", "request.permission!=EXPORT_SET_DELETE", 
                                "request.permission!=MOUNT_TARGET_DELETE", "request.permission!=FILE_SYSTEM_DELETE", "request.permission!=VOLUME_BACKUP_DELETE", 
                                "request.permission!=VOLUME_DELETE", "request.permission!=FILE_SYSTEM_DELETE_SNAPSHOT"], 
                    "file-family": ["request.permission!=EXPORT_SET_DELETE", "request.permission!=MOUNT_TARGET_DELETE", 
                        "request.permission!=FILE_SYSTEM_DELETE", "request.permission!=FILE_SYSTEM_DELETE_SNAPSHOT"],
                    "file-systems" : ["request.permission!=FILE_SYSTEM_DELETE", "request.permission!=FILE_SYSTEM_DELETE_SNAPSHOT"],
                    "mount-targets": ["request.permission!=MOUNT_TARGET_DELETE"],
                    "object-family": ["request.permission!=BUCKET_DELETE", "request.permission!=OBJECT_DELETE"],
                    "buckets": ["request.permission!=BUCKET_DELETE"],
                    "objects": ["request.permission!=OBJECT_DELETE"],
                    "volume-family": ["request.permission!=VOLUME_BACKUP_DELETE", "request.permission!=VOLUME_DELETE", "request.permission!=BOOT_VOLUME_BACKUP_DELETE"],
                    "volumes": ["request.permission!=VOLUME_DELETE"],
                    "volume-backups": ["request.permission!=VOLUME_BACKUP_DELETE"],
                    "boot-volume-backups": ["request.permission!=BOOT_VOLUME_BACKUP_DELETE"]}}

        # Tenancy Data
        self.__tenancy = None
        self.__cloud_guard_config = None
        self.__cloud_guard_config_status = None
        self.__os_namespace = None
        
        # For IAM Checks
        self.__tenancy_password_policy = None
        self.__compartments = []
        self.__raw_compartment = []
        self.__policies = []
        self.__users = []
        self.__groups_to_users = []
        self.__tag_defaults = []
        self.__dynamic_groups = []

        # For Networking checks
        self.__network_security_groups = []
        self.__network_security_lists = []
        self.__network_subnets = []
        self.__network_fastconnects = {} # Indexed by DRG ID
        self.__network_drgs = {} # Indexed by DRG ID
        self.__raw_network_drgs = []

        self.__network_cpes = []        
        self.__network_ipsec_connections = {} # Indexed by DRG ID
        self.__network_drg_attachments = {} # Indexed by DRG ID

        # For Autonomous Database Checks
        self.__autonomous_databases = []

        # For Oracle Analytics Cloud Checks
        self.__analytics_instances = []

        # For Oracle Integration Cloud Checks
        self.__integration_instances = []

        # For Logging & Monitoring checks
        self.__event_rules = []
        self.__logging_list = []
        self.__subnet_logs = {}
        self.__write_bucket_logs = {}
        self.__read_bucket_logs = {}
        self.__load_balancer_access_logs = []
        self.__load_balancer_error_logs = []
        self.__api_gateway_access_logs = []
        self.__api_gateway_error_logs = []

        # Cloud Guard checks
        self.__cloud_guard_targets = {}


        # For Storage Checks
        self.__buckets = []
        self.__boot_volumes = []
        self.__block_volumes = []
        self.__file_storage_system = []

        # For Vaults and Keys checks
        self.__vaults = []

        # For Region
        self.__regions = {}
        self.__raw_regions = []
        self.__home_region = None

        # For ONS Subscriptions
        self.__subscriptions = []

        # Results from Advanced search query
        self.__resources_in_root_compartment = []

        # For Budgets
        self.__budgets = []

        # For Service Connector
        self.__service_connectors = {}

        # Setting list of regions to run in

        # Start print time info
        show_version(verbose=True)
        print("Starts at " + self.start_time_str)
        self.__config = config
        self.__signer = signer

        # By Default it is passed True to print all output
        if print_to_screen.upper() == 'TRUE':
            self.__print_to_screen = True
        else:
            self.__print_to_screen = False

        # creating list of regions to run
        try:
            if regions_to_run_in:
                self.__regions_to_run_in = regions_to_run_in.split(",")
                self.__run_in_all_regions = False
            else:
                # If no regions are passed I will run them in all
                self.__regions_to_run_in = regions_to_run_in
                self.__run_in_all_regions = True
            print("Regions to run in: " + ("all regions" if self.__run_in_all_regions else str(self.__regions_to_run_in)))

        except Exception as e:
            raise RuntimeError("Invalid input regions must be comma separated with no : 'us-ashburn-1,us-phoenix-1'")

        try:
          
            self.__identity = oci.identity.IdentityClient(
                self.__config, signer=self.__signer)
            if proxy:
                self.__identity.base_client.session.proxies = {'https': proxy}

            # Getting Tenancy Data and Region data
            self.__tenancy = self.__identity.get_tenancy(
                config["tenancy"]).data
            regions = self.__identity.list_region_subscriptions(
                self.__tenancy.id).data

        except Exception as e:
            raise RuntimeError("Failed to get identity information." + str(e.args))     


        try:
            self.__budget_client = oci.budget.BudgetClient(
                self.__config, signer=self.__signer)
            if proxy:
                self.__budget_client.base_client.session.proxies = {'https': proxy}
        except Exception as e:
            raise RuntimeError("Failed to get create budgets client" + str(e.args))

        # Creating a record for home region and a list of all regions including the home region
        for region in regions:
            if region.is_home_region:
                self.__home_region = region.region_name
                print("Home region for tenancy is " + self.__home_region)
                self.__regions[region.region_name]  = {
                    "is_home_region": region.is_home_region,
                    "region_key": region.region_key,
                    "region_name": region.region_name,
                    "status": region.status,
                    "identity_client" : self.__identity,
                    "budget_client" : self.__budget_client
                }
            elif region.region_name in self.__regions_to_run_in or self.__run_in_all_regions: 
                self.__regions[region.region_name] = {
                    "is_home_region": region.is_home_region,
                    "region_key": region.region_key,
                    "region_name": region.region_name,
                    "status": region.status,
                    }

            record = {
                    "is_home_region": region.is_home_region,
                    "region_key": region.region_key,
                    "region_name": region.region_name,
                    "status": region.status,
                }
            self.__raw_regions.append(record)    

        
        # By Default it is today's date
        if report_directory:
            self.__report_directory = report_directory + "/"
        else:
            self.__report_directory = self.__tenancy.name + "-" + self.report_datetime

        # Creating signers and config for all regions           
        self.__create_regional_signers(proxy)

        # Setting os_namespace based on home region
        try:
            if not(self.__os_namespace):
                self.__os_namespace =self.__regions[self.__home_region]['os_client'].get_namespace().data
        except Exception as e:
            raise RuntimeError(
                "Failed to get tenancy namespace." + str(e.args))
        
        # Determining if a need a object storage client for output
        self.__output_bucket = output_bucket
        if self.__output_bucket:
            self.__output_bucket_client = self.__regions[self.__home_region]['os_client']

        # Determining if all raw data will be output
        self.__output_raw_data = raw_data

        # Determining if OCI Best Practices will be checked and output
        self.__obp_checks = obp

        # Determining if CSV report OCIDs will be redacted
        self.__redact_output = redact_output


    ##########################################################################
    # Create regional config, signers adds appends them to self.__regions object
    ##########################################################################
    def __create_regional_signers(self, proxy):
        print("Creating regional signers and configs...")
        for region_key, region_values in self.__regions.items():
            # Creating regional configs and signers
            region_signer = self.__signer
            region_signer.region_name = region_key
            region_config = self.__config
            region_config['region'] = region_key


            try:
                identity = oci.identity.IdentityClient(
                region_config, signer=region_signer)
                if proxy:
                    identity.base_client.session.proxies = {'https': proxy}
                region_values['identity_client'] =  identity

                audit = oci.audit.AuditClient(
                region_config, signer=region_signer)
                if proxy:
                    audit.base_client.session.proxies = {'https': proxy}
                region_values['audit_client'] =  audit
                
                cloud_guard = oci.cloud_guard.CloudGuardClient(
                    region_config, signer=region_signer)
                if proxy:
                    cloud_guard.base_client.session.proxies = {'https': proxy}
                region_values['cloud_guard_client'] =  cloud_guard
             
                search = oci.resource_search.ResourceSearchClient(
                    region_config, signer=region_signer)
                if proxy:
                    search.base_client.session.proxies = {'https': proxy}
                region_values['search_client'] = search

                network = oci.core.VirtualNetworkClient(
                    region_config, signer=region_signer)
                if proxy:
                    network.base_client.session.proxies = {'https': proxy}
                region_values['network_client'] = network

                events = oci.events.EventsClient(
                    region_config, signer=region_signer)
                if proxy:
                    events.base_client.session.proxies = {'https': proxy}
                region_values['events_client'] = events

                logging = oci.logging.LoggingManagementClient(
                    region_config, signer=region_signer)
                if proxy:
                    logging.base_client.session.proxies = {'https': proxy}
                region_values['logging_client'] = logging

                os_client = oci.object_storage.ObjectStorageClient(
                    region_config, signer=region_signer)
                if proxy:
                    os_client.base_client.session.proxies = {'https': proxy}
                region_values['os_client'] = os_client

                vault = oci.key_management.KmsVaultClient(
                    region_config, signer=region_signer)
                if proxy:
                    vault.session.proxies = {'https': proxy}
                region_values['vault_client'] = vault

                ons_subs = oci.ons.NotificationDataPlaneClient(
                    region_config, signer=region_signer)
                if proxy:
                    ons_subs.session.proxies = {'https': proxy}
                region_values['ons_subs_client'] = ons_subs

                adb = oci.database.DatabaseClient(
                    region_config, signer=region_signer)
                if proxy:
                    adb.base_client.session.proxies = {'https': proxy}
                region_values['adb_client'] = adb

                oac = oci.analytics.AnalyticsClient(
                    region_config, signer=region_signer)
                if proxy:
                    oac.base_client.session.proxies = {'https': proxy}
                region_values['oac_client'] = oac

                oic = oci.integration.IntegrationInstanceClient(
                    region_config, signer=region_signer)
                if proxy:
                    oic.base_client.session.proxies = {'https': proxy}
                region_values['oic_client'] = oic

                bv = oci.core.BlockstorageClient(
                    region_config, signer=region_signer)
                if proxy:
                    bv.base_client.session.proxies = {'https': proxy}
                region_values['bv_client'] = bv

                fss = oci.file_storage.FileStorageClient(
                    region_config, signer=region_signer)
                if proxy:
                    fss.base_client.session.proxies = {'https': proxy}
                region_values['fss_client'] = fss

                sch = oci.sch.ServiceConnectorClient(
                    region_config, signer=region_signer)
                if proxy:
                    sch.base_client.session.proxies = {'https': proxy}
                region_values['sch_client'] = sch  

            except Exception as e:
                raise RuntimeError("Failed to create regional clients for data collection: " + str(e))

    ##########################################################################
    # Check for Managed PaaS Compartment
    ##########################################################################
    def __if_not_managed_paas_compartment(self, name):
        return name != "ManagedCompartmentForPaaS"

    ##########################################################################
    # Load compartments
    ##########################################################################
    def __identity_read_compartments(self):
        print("Processing Compartments...")
        try:
            self.__compartments = oci.pagination.list_call_get_all_results(
                self.__regions[self.__home_region]['identity_client'].list_compartments,
                compartment_id = self.__tenancy.id,
                compartment_id_in_subtree=True,
                lifecycle_state = "ACTIVE"
            ).data
            # Need to convert for raw output
            for compartment in self.__compartments:
                deep_link = self.__oci_compartment_uri + compartment.id
                record = {
                    'id': compartment.id,
                    'name' : compartment.name,
                    "deep_link": self.__generate_csv_hyperlink(deep_link, compartment.name),
                    'compartment_id': compartment.compartment_id,
                    'defined_tags': compartment.defined_tags,
                    "description": compartment.description,
                    "freeform_tags": compartment.freeform_tags,
                    "inactive_status": compartment.inactive_status,
                    "is_accessible": compartment.is_accessible,
                    "lifecycle_state": compartment.lifecycle_state,
                    "time_created": compartment.time_created.strftime(self.__iso_time_format),
                    "region" : ""
                    }
                self.__raw_compartment.append(record)
            
            # Add root compartment which is not part of the list_compartments
            self.__compartments.append(self.__tenancy)
            deep_link = self.__oci_compartment_uri + compartment.id
            root_compartment = {
                "id" : self.__tenancy.id,
                "name" : self.__tenancy.name,
                "deep_link": self.__generate_csv_hyperlink(deep_link, self.__tenancy.name),
                "compartment_id": "(root)",
                "defined_tags": self.__tenancy.defined_tags,
                "description": self.__tenancy.description,
                "freeform_tags": self.__tenancy.freeform_tags,
                "inactive_status": "",
                "is_accessible": "",
                "lifecycle_state": "",
                "time_created": "",
                "region" : ""

            }
            self.__raw_compartment.append(root_compartment)

            print("\tProcessed " + str(len(self.__compartments)) + " Compartments")                        
            return self.__compartments

        except Exception as e:
            raise RuntimeError(
                "Error in identity_read_compartments: " + str(e.args))

    ##########################################################################
    # Load Groups and Group membership
    ##########################################################################
    def __identity_read_groups_and_membership(self):
        try:
            # Getting all Groups in the Tenancy
            groups_data = oci.pagination.list_call_get_all_results(
                self.__regions[self.__home_region]['identity_client'].list_groups,
                compartment_id = self.__tenancy.id
            ).data
            # For each group in the tenacy getting the group's membership
            for grp in groups_data:
                membership = oci.pagination.list_call_get_all_results(
                    self.__regions[self.__home_region]['identity_client'].list_user_group_memberships,
                    compartment_id = self.__tenancy.id,
                    group_id=grp.id
                ).data
                for member in membership:
                    grp_deep_link = self.__oci_groups_uri + grp.id
                    user_deep_link = self.__oci_users_uri + member.user_id
                    group_record = {
                        "id": grp.id,
                        "name": grp.name,
                        "deep_link": self.__generate_csv_hyperlink(grp_deep_link, grp.name),
                        "description": grp.description,
                        "lifecycle_state": grp.lifecycle_state,
                        "time_created": grp.time_created.strftime(self.__iso_time_format),
                        "user_id": member.user_id,
                        "user_id_link": self.__generate_csv_hyperlink(user_deep_link,member.user_id)
                    }
                    # Adding a record per user to group
                    self.__groups_to_users.append(group_record)
            return self.__groups_to_users
        except Exception as e:
            RuntimeError(
                "Error in __identity_read_groups_and_membership" + str(e.args))

    ##########################################################################
    # Load users
    ##########################################################################
    def __identity_read_users(self):
        try:
            # Getting all users in the Tenancy
            users_data = oci.pagination.list_call_get_all_results(
                self.__regions[self.__home_region]['identity_client'].list_users,
                compartment_id = self.__tenancy.id
            ).data
            # Adding record to the users
            for user in users_data:
                deep_link = self.__oci_users_uri + user.id
                record = {
                    'id': user.id,
                    'name': user.name,
                    'deep_link': self.__generate_csv_hyperlink(deep_link, user.name),
                    'defined_tags': user.defined_tags,
                    'description': user.description,
                    'email': user.email,
                    'email_verified': user.email_verified,
                    'external_identifier': user.external_identifier,
                    'identity_provider_id': user.identity_provider_id,
                    'is_mfa_activated': user.is_mfa_activated,
                    'lifecycle_state': user.lifecycle_state,
                    'time_created': user.time_created.strftime(self.__iso_time_format),
                    'can_use_api_keys': user.capabilities.can_use_api_keys,
                    'can_use_auth_tokens': user.capabilities.can_use_auth_tokens,
                    'can_use_console_password': user.capabilities.can_use_console_password,
                    'can_use_customer_secret_keys': user.capabilities.can_use_customer_secret_keys,
                    'can_use_db_credentials': user.capabilities.can_use_db_credentials,
                    'can_use_o_auth2_client_credentials': user.capabilities.can_use_o_auth2_client_credentials,
                    'can_use_smtp_credentials': user.capabilities.can_use_smtp_credentials,
                    'groups': []
                }
                # Adding Groups to the user
                for group in self.__groups_to_users:
                    if user.id == group['user_id']:
                        record['groups'].append(group['name'])

                record['api_keys'] = self.__identity_read_user_api_key(user.id)
                record['auth_tokens'] = self.__identity_read_user_auth_token(
                    user.id)
                record['customer_secret_keys'] = self.__identity_read_user_customer_secret_key(
                    user.id)

                self.__users.append(record)
            print("\tProcessed " + str(len(self.__users)) + " Users")
            return self.__users

        except Exception as e:
            raise RuntimeError(
                "Error in __identity_read_users: " + str(e.args))

    ##########################################################################
    # Load user api keys
    ##########################################################################
    def __identity_read_user_api_key(self, user_ocid):
        api_keys = []
        try:
            user_api_keys_data = oci.pagination.list_call_get_all_results(
                self.__regions[self.__home_region]['identity_client'].list_api_keys,
                user_id = user_ocid
            ).data

            for api_key in user_api_keys_data:
                deep_link = self.__oci_users_uri + user_ocid + "/api-keys"
                record = {
                    'id': api_key.key_id,
                    'fingerprint': api_key.fingerprint,
                    'deep_link': self.__generate_csv_hyperlink(deep_link, api_key.fingerprint),
                    'inactive_status': api_key.inactive_status,
                    'lifecycle_state': api_key.lifecycle_state,
                    'time_created': api_key.time_created.strftime(self.__iso_time_format),
                }
                api_keys.append(record)

            return api_keys

        except Exception as e:
            raise RuntimeError(
                "Error in identity_read_user_api_key: " + str(e.args))

    ##########################################################################
    # Load user auth tokens
    ##########################################################################
    def __identity_read_user_auth_token(self, user_ocid):
        auth_tokens = []
        try:
            auth_tokens_data = oci.pagination.list_call_get_all_results(
                self.__regions[self.__home_region]['identity_client'].list_auth_tokens,
                user_id = user_ocid
            ).data

            for token in auth_tokens_data:
                deep_link = self.__oci_users_uri + user_ocid + "/swift-credentials"
                record = {
                    'id': token.id,
                    'description': token.description,
                    'deep_link': self.__generate_csv_hyperlink(deep_link, token.description),
                    'inactive_status': token.inactive_status,
                    'lifecycle_state': token.lifecycle_state,
                    # .strftime('%Y-%m-%d %H:%M:%S'),
                    'time_created': token.time_created.strftime(self.__iso_time_format),
                    'time_expires': str(token.time_expires),
                    'token': token.token

                }
                auth_tokens.append(record)

            return auth_tokens

        except Exception as e:
            raise RuntimeError(
                "Error in identity_read_user_auth_token: " + str(e.args))


    ##########################################################################
    # Load user customer secret key
    ##########################################################################
    def __identity_read_user_customer_secret_key(self, user_ocid):
        customer_secret_key = []
        try:
            customer_secret_key_data = oci.pagination.list_call_get_all_results(
                self.__regions[self.__home_region]['identity_client'].list_customer_secret_keys,
                user_id = user_ocid
            ).data

            for key in customer_secret_key_data:
                deep_link = self.__oci_users_uri + user_ocid + "/secret-keys"
                record = {
                    'id': key.id,
                    'display_name': key.display_name,
                    'deep_link': self.__generate_csv_hyperlink(deep_link, key.display_name),
                    'inactive_status': key.inactive_status,
                    'lifecycle_state': key.lifecycle_state,
                    'time_created': key.time_created.strftime(self.__iso_time_format),
                    'time_expires': str(key.time_expires),

                }
                customer_secret_key.append(record)

            return customer_secret_key

        except Exception as e:
            raise RuntimeError(
                "Error in identity_read_user_customer_secret_key: " + str(e.args))

    ##########################################################################
    # Tenancy IAM Policies
    ##########################################################################
    def __identity_read_tenancy_policies(self):
        # Get all policy at the tenancy level
        try:
            for compartment in self.__compartments:
                if self.__if_not_managed_paas_compartment(compartment.name):
                    policies_data = oci.pagination.list_call_get_all_results(
                        self.__regions[self.__home_region]['identity_client'].list_policies,
                        compartment_id = compartment.id
                    ).data
                    for policy in policies_data:
                        deep_link = self.__oci_policies_uri + policy.id
                        record = {
                            "id": policy.id,
                            "name": policy.name,
                            'deep_link': self.__generate_csv_hyperlink(deep_link, policy.name),
                            "compartment_id": policy.compartment_id,
                            "description": policy.description,
                            "lifecycle_state": policy.lifecycle_state,
                            "statements": policy.statements
                        }
                        self.__policies.append(record)
            
            print("\tProcessed " + str(len(self.__policies)) + " IAM Policies")                        
            return self.__policies
            
        except Exception as e:
            raise RuntimeError("Error in __identity_read_tenancy_policies: " + str(e.args))

    ############################################
    # Load Identity Dynamic Groups
    ############################################
    def __identity_read_dynamic_groups(self):
        try:
            dynamic_groups_data = oci.pagination.list_call_get_all_results(
                self.__regions[self.__home_region]['identity_client'].list_dynamic_groups,
                compartment_id = self.__tenancy.id
                ).data
            for dynamic_group in dynamic_groups_data:
                deep_link = self.__oci_dynamic_groups_uri + dynamic_group.id
                # try:
                record = {
                    "id": dynamic_group.id,
                    "name": dynamic_group.name,
                    "deep_link": self.__generate_csv_hyperlink(deep_link, dynamic_group.name),
                    "description": dynamic_group.description,
                    "matching_rule": dynamic_group.matching_rule,
                    "time_created": dynamic_group.time_created.strftime(self.__iso_time_format),
                    "inactive_status": dynamic_group.inactive_status,
                    "lifecycle_state": dynamic_group.lifecycle_state,
                    "defined_tags": dynamic_group.defined_tags,
                    "freeform_tags": dynamic_group.freeform_tags,
                    "compartment_id": dynamic_group.compartment_id,
                    "notes": ""
                }
                # except Exception as e:
                #     record = {
                #         "id": dynamic_group.id,
                #         "name": dynamic_group.name,
                #         "deep_link": self.__generate_csv_hyperlink(deep_link, dynamic_group.name),
                #         "description": "",
                #         "matching_rule": "",
                #         "time_created": "",
                #         "inactive_status": "",
                #         "lifecycle_state": "",
                #         "defined_tags": "",
                #         "freeform_tags": "",
                #         "compartment_id": "",
                #         "notes": str(e)
                #     }
                self.__dynamic_groups.append(record)
            
            print("\tProcessed " + str(len(self.__dynamic_groups)) + " Dynamic Groups")                        
            return self.__dynamic_groups
        except Exception as e:
            raise RuntimeError("Error in __identity_read_dynamic_groups: " + str(e.args))
        pass
    
    ############################################
    # Load Availlability Domains
    ############################################
    def __identity_read_availability_domains(self):
        try:
            for region_key, region_values in self.__regions.items():
                region_values['availability_domains'] = oci.pagination.list_call_get_all_results(
                    region_values['identity_client'].list_availability_domains,
                    compartment_id = self.__tenancy.id
                ).data
                print("\tProcessed " + str(len(region_values['availability_domains'])) + " Availability Domains in " + region_key)                        

        except Exception as e:
            raise RuntimeError(
                "Error in __identity_read_availability_domains: " + str(e.args))
    
    ##########################################################################
    # Get Objects Store Buckets
    ##########################################################################
    def __os_read_buckets(self):
        
        # Getting OS Namespace        
        try:
            # looping through regions
            for region_key, region_values in self.__regions.items():
                # Collecting buckets from each compartment
                for compartment in self.__compartments:
                    # Skipping the managed paas compartment
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        buckets_data = oci.pagination.list_call_get_all_results(
                            region_values['os_client'].list_buckets,
                            namespace_name = self.__os_namespace,
                            compartment_id = compartment.id
                        ).data
                        # Getting Bucket Info
                        for bucket in buckets_data:
                            try:
                                bucket_info = region_values['os_client'].get_bucket(
                                    self.__os_namespace, bucket.name).data
                                
                                deep_link = self.__oci_buckets_uri + bucket_info.namespace + \
                                     "/" + bucket_info.name + "/objects?region=" + region_key
                                record = {
                                    "id": bucket_info.id,
                                    "name": bucket_info.name,
                                    "deep_link": self.__generate_csv_hyperlink(deep_link, bucket_info.name),                                    
                                    "kms_key_id": bucket_info.kms_key_id,
                                    "namespace": bucket_info.namespace,
                                    "compartment_id": bucket_info.compartment_id,
                                    "object_events_enabled": bucket_info.object_events_enabled,
                                    "public_access_type": bucket_info.public_access_type,
                                    "replication_enabled": bucket_info.replication_enabled,
                                    "is_read_only": bucket_info.is_read_only,
                                    "storage_tier": bucket_info.storage_tier,
                                    "time_created": bucket_info.time_created.strftime(self.__iso_time_format),
                                    "versioning": bucket_info.versioning,
                                    "defined_tags" : bucket_info.defined_tags,
                                    "freeform_tags" : bucket_info.freeform_tags,
                                    "region" : region_key,
                                    "notes": ""
                                }
                                self.__buckets.append(record)
                            except Exception as e:
                                deep_link = self.__oci_buckets_uri + bucket.namespace + \
                                     "/" + bucket.name + "/objects?region=" + region_key
                                record = {
                                    "id": "",
                                    "name":  bucket.name,
                                    "deep_link": self.__generate_csv_hyperlink(deep_link, bucket.name),
                                    "kms_key_id": "",
                                    "namespace": bucket.namespace,
                                    "compartment_id": bucket.compartment_id,
                                    "object_events_enabled": "",
                                    "public_access_type": "",
                                    "replication_enabled": "",
                                    "is_read_only": "",
                                    "storage_tier": "",
                                    "time_created": bucket.time_created.strftime(self.__iso_time_format),
                                    "versioning": "",
                                    "defined_tags" : bucket.defined_tags,
                                    "freeform_tags" : "",
                                    "region" : region_key,
                                    "notes": str(e)
                                }
                                self.__buckets.append(record)
                # Returning Buckets
            print("\tProcessed " + str(len(self.__buckets)) + " Buckets")            
            return self.__buckets
        except Exception as e:
            raise RuntimeError("Error in __os_read_buckets " + str(e.args))

    ############################################
    # Load Block Volumes
    ############################################
    def __block_volume_read_block_volumes(self):
        try:
            for region_key, region_values in self.__regions.items():
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        volumes_data = oci.pagination.list_call_get_all_results(
                            region_values['bv_client'].list_volumes,
                            compartment_id=compartment.id
                        ).data
                        # Getting Block Volume inf
                        for volume in volumes_data:
                            deep_link = self.__oci_block_volumes_uri + volume.id + '?region=' + region_key
                            try:
                                record = {
                                    "id": volume.id,
                                    "display_name": volume.display_name,
                                    "deep_link": self.__generate_csv_hyperlink(deep_link, volume.display_name),
                                    "kms_key_id": volume.kms_key_id,
                                    "lifecycle_state": volume.lifecycle_state,
                                    "compartment_id": volume.compartment_id,
                                    "size_in_gbs": volume.size_in_gbs,
                                    "size_in_mbs": volume.size_in_mbs,
                                    "source_details": volume.source_details,
                                    "time_created": volume.time_created.strftime(self.__iso_time_format),
                                    "volume_group_id": volume.volume_group_id,
                                    "vpus_per_gb": volume.vpus_per_gb,
                                    "auto_tuned_vpus_per_gb": volume.auto_tuned_vpus_per_gb,
                                    "availability_domain" : volume.availability_domain,
                                    "block_volume_replicas": volume.block_volume_replicas,
                                    "is_auto_tune_enabled": volume.is_auto_tune_enabled,
                                    "is_hydrated": volume.is_hydrated,
                                    "defined_tags": volume.defined_tags,
                                    "freeform_tags": volume.freeform_tags,
                                    "system_tags": volume.system_tags,
                                    "region" : region_key,
                                    "notes": ""
                                }
                            except Exception as e:
                                record = {
                                    "id": volume.id,
                                    "display_name": volume.display_name,
                                    "deep_link": self.__generate_csv_hyperlink(deep_link, volume.display_name),
                                    "kms_key_id": "",
                                    "lifecycle_state": "",
                                    "compartment_id": "",
                                    "size_in_gbs": "",
                                    "size_in_mbs": "",
                                    "source_details": "",
                                    "time_created":"",
                                    "volume_group_id": "",
                                    "vpus_per_gb": "",
                                    "auto_tuned_vpus_per_gb": "",
                                    "availability_domain" : "",
                                    "block_volume_replicas": "",
                                    "is_auto_tune_enabled": "",
                                    "is_hydrated": "",
                                    "defined_tags": "",
                                    "freeform_tags": "",
                                    "system_tags": "",
                                    "region" : region_key,
                                    "notes": str(e)
                                    }
                            self.__block_volumes.append(record)
            print("\tProcessed " + str(len(self.__block_volumes)) + " Block Volumes")
            return self.__block_volumes
        except Exception as e:
            raise RuntimeError("Error in __block_volume_read_block_volumes " + str(e.args))            

    ############################################
    # Load Boot Volumes
    ############################################
    def __boot_volume_read_boot_volumes(self):
        try:
            for region_key, region_values in self.__regions.items():
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        # Iterating through ADs in region
                        for ad in region_values['availability_domains']:
                            boot_volumes_data = oci.pagination.list_call_get_all_results(
                                    region_values['bv_client'].list_boot_volumes,
                                    availability_domain=ad.name,
                                    compartment_id=compartment.id
                                ).data
                            for boot_volume in boot_volumes_data:
                                deep_link = self.__oci_boot_volumes_uri + boot_volume.id + '?region=' + region_key
                                try:
                                    record = {
                                        "id": boot_volume.id,
                                        "display_name": boot_volume.display_name,
                                        "deep_link": self.__generate_csv_hyperlink(deep_link, boot_volume.display_name),
                                        "image_id": boot_volume.image_id,
                                        "kms_key_id": boot_volume.kms_key_id,
                                        "lifecycle_state": boot_volume.lifecycle_state,
                                        "size_in_gbs": boot_volume.size_in_gbs,
                                        "size_in_mbs": boot_volume.size_in_mbs,
                                        "availability_domain": boot_volume.availability_domain,
                                        "time_created": boot_volume.time_created.strftime(self.__iso_time_format),
                                        "compartment_id": boot_volume.compartment_id,
                                        "auto_tuned_vpus_per_gb": boot_volume.auto_tuned_vpus_per_gb,
                                        "boot_volume_replicas": boot_volume.boot_volume_replicas,
                                        "is_auto_tune_enabled": boot_volume.is_auto_tune_enabled,
                                        "is_hydrated": boot_volume.is_hydrated,
                                        "source_details": boot_volume.source_details,
                                        "vpus_per_gb": boot_volume.vpus_per_gb,
                                        "system_tags": boot_volume.system_tags,
                                        "defined_tags": boot_volume.defined_tags,
                                        "freeform_tags": boot_volume.freeform_tags,
                                        "region" : region_key,
                                        "notes": ""
                                    }
                                except Exception as e:
                                    record = {
                                        "id": boot_volume.id,
                                        "display_name": boot_volume.display_name,
                                        "deep_link": self.__generate_csv_hyperlink(deep_link, boot_volume.display_name),
                                        "image_id": "",
                                        "kms_key_id": "",
                                        "lifecycle_state": "",
                                        "size_in_gbs": "",
                                        "size_in_mbs": "",
                                        "availability_domain": "",
                                        "time_created": "",
                                        "compartment_id": "",
                                        "auto_tuned_vpus_per_gb": "",
                                        "boot_volume_replicas": "",
                                        "is_auto_tune_enabled": "",
                                        "is_hydrated": "",
                                        "source_details": "",
                                        "vpus_per_gb": "",
                                        "system_tags": "",
                                        "defined_tags": "",
                                        "freeform_tags": "",
                                        "region" : region_key,
                                        "notes": str(e)
                                    }
                                self.__boot_volumes.append(record)
            print("\tProcessed " + str(len(self.__boot_volumes)) + " Boot Volumes")
            return(self.__boot_volumes)
        except Exception as e:
            raise RuntimeError("Error in __boot_volume_read_boot_volumes " + str(e.args))            

    ############################################
    # Load FSS
    ############################################
    def __fss_read_fsss(self):
        try:
            for region_key, region_values in self.__regions.items():
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        # Iterating through ADs in region
                        for ad in region_values['availability_domains']:
                            fss_data = oci.pagination.list_call_get_all_results(
                                    region_values['fss_client'].list_file_systems,
                                    compartment_id = compartment.id,
                                    availability_domain = ad.name
                                ).data
                            for fss in fss_data:
                                deep_link = self.__oci_fss_uri + fss.id + '?region=' + region_key
                                try:
                                    record = {
                                        "id": fss.id,
                                        "display_name": fss.display_name,
                                        "deep_link": self.__generate_csv_hyperlink(deep_link, fss.display_name),
                                        "kms_key_id": fss.kms_key_id,
                                        "lifecycle_state": fss.lifecycle_state,
                                        "lifecycle_details": fss.lifecycle_details,
                                        "availability_domain": fss.availability_domain,
                                        "time_created": fss.time_created.strftime(self.__iso_time_format),
                                        "compartment_id": fss.compartment_id,
                                        "is_clone_parent": fss.is_clone_parent,
                                        "is_hydrated": fss.is_hydrated,
                                        "metered_bytes": fss.metered_bytes,
                                        "source_details": fss.source_details,
                                        "defined_tags": fss.defined_tags,
                                        "freeform_tags": fss.freeform_tags,
                                        "region" : region_key,
                                        "notes": ""
                                    }
                                except Exception as e:
                                    record = {
                                        "id": fss.id,
                                        "display_name": fss.display_name,
                                        "deep_link": self.__generate_csv_hyperlink(deep_link, fss.display_name),
                                        "kms_key_id": "",
                                        "lifecycle_state": "",
                                        "lifecycle_details": "",
                                        "availability_domain": "",
                                        "time_created": "",
                                        "compartment_id": "",
                                        "is_clone_parent": "",
                                        "is_hydrated": "",
                                        "metered_bytes": "",
                                        "source_details": "",
                                        "defined_tags": "",
                                        "freeform_tags": "",
                                        "region" : region_key,
                                        "notes": str(e)
                                    }
                                self.__file_storage_system.append(record)
            print("\tProcessed " + str(len(self.__file_storage_system)) + " File Storage service")
            return(self.__file_storage_system)
        except Exception as e:
            raise RuntimeError("Error in __fss_read_fsss " + str(e.args)) 
           

    ##########################################################################
    # Network Security Groups
    ##########################################################################
    def __network_read_network_security_groups_rules(self):
        self.__network_security_groups = []
        # Loopig Through Compartments Except Managed
        try:
            for region_key, region_values in self.__regions.items():
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        nsgs_data = oci.pagination.list_call_get_all_results(
                            region_values['network_client'].list_network_security_groups,
                            compartment_id=compartment.id
                        ).data
                        # Looping through NSGs to to get
                        for nsg in nsgs_data:
                            deep_link = self.__oci_networking_uri + nsg.vcn_id + \
                                "/network-security-groups/" + nsg.id +  '?region=' + region_key
                            record = {
                                "id": nsg.id,
                                "compartment_id": nsg.compartment_id,
                                "display_name": nsg.display_name,
                                "deep_link": self.__generate_csv_hyperlink(deep_link, nsg.display_name),
                                "lifecycle_state": nsg.lifecycle_state,
                                "time_created": nsg.time_created.strftime(self.__iso_time_format),
                                "vcn_id": nsg.vcn_id,
                                "freeform_tags" : nsg.freeform_tags,
                                "defined_tags" : nsg.defined_tags,
                                "region" : region_key,
                                "rules": []
                            }
                            nsg_rules = oci.pagination.list_call_get_all_results(
                                region_values['network_client'].list_network_security_group_security_rules,
                                network_security_group_id = nsg.id
                            ).data
                            for rule in nsg_rules:
                                deep_link = self.__oci_networking_uri + nsg.vcn_id + \
                                "/network-security-groups/" + nsg.id + "/nsg-rules" + '?region=' + region_key
                                rule_record = {
                                    "id": rule.id,
                                    "deep_link": self.__generate_csv_hyperlink(deep_link, rule.id),
                                    "destination": rule.destination,
                                    "destination_type": rule.destination_type,
                                    "direction": rule.direction,
                                    "icmp_options": rule.icmp_options,
                                    "is_stateless": rule.is_stateless,
                                    "is_valid": rule.is_valid,
                                    "protocol": rule.protocol,
                                    "source": rule.source,
                                    "source_type": rule.source_type,
                                    "tcp_options": rule.tcp_options,
                                    "time_created": rule.time_created.strftime(self.__iso_time_format),
                                    "udp_options": rule.udp_options,

                                }
                                # Append NSG Rules to NSG
                                record['rules'].append(rule_record)
                            # Append NSG to list of NSGs
                            self.__network_security_groups.append(record)
            print("\tProcessed " + str(len(self.__network_security_groups)) + " Network Security Groups")
            return self.__network_security_groups
        except Exception as e:
            raise RuntimeError(
                "Error in __network_read_network_security_groups_rules " + str(e.args))

    ##########################################################################
    # Network Security Lists
    ##########################################################################
    def __network_read_network_security_lists(self):
        # Looping Through Compartments Except Managed
        try:
            for region_key, region_values in self.__regions.items():
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        security_lists_data = oci.pagination.list_call_get_all_results(
                            region_values['network_client'].list_security_lists,
                            compartment_id = compartment.id
                        ).data
                        # Looping through Security Lists to to get
                        for security_list in security_lists_data:
                            deep_link = self.__oci_networking_uri + security_list.vcn_id + \
                                "/security-lists/" + security_list.id + '?region=' + region_key
                            record = {
                                "id": security_list.id,
                                "compartment_id": security_list.compartment_id,
                                "display_name": security_list.display_name,
                                "deep_link": self.__generate_csv_hyperlink(deep_link, security_list.display_name),
                                "lifecycle_state": security_list.lifecycle_state,
                                "time_created": security_list.time_created.strftime(self.__iso_time_format),
                                "vcn_id": security_list.vcn_id,
                                "region" : region_key,
                                "freeform_tags" : security_list.freeform_tags,
                                "defined_tags" : security_list.defined_tags,
                                "ingress_security_rules": [],
                                "egress_security_rules": []
                            }
                            for egress_rule in security_list.egress_security_rules:
                                erule = {
                                    "description": egress_rule.description,
                                    "destination": egress_rule.destination,
                                    "destination_type": egress_rule.destination_type,
                                    "icmp_options": egress_rule.icmp_options,
                                    "is_stateless": egress_rule.is_stateless,
                                    "protocol": egress_rule.protocol,
                                    "tcp_options": egress_rule.tcp_options,
                                    "udp_options": egress_rule.udp_options
                                }
                                record['egress_security_rules'].append(erule)

                            for ingress_rule in security_list.ingress_security_rules:
                                irule = {
                                    "description": ingress_rule.description,
                                    "source": ingress_rule.source,
                                    "source_type": ingress_rule.source_type,
                                    "icmp_options": ingress_rule.icmp_options,
                                    "is_stateless": ingress_rule.is_stateless,
                                    "protocol": ingress_rule.protocol,
                                    "tcp_options": ingress_rule.tcp_options,
                                    "udp_options": ingress_rule.udp_options
                                }
                                record['ingress_security_rules'].append(irule)

                            # Append Security List to list of NSGs
                            self.__network_security_lists.append(record)
                
            print("\tProcessed " + str(len(self.__network_security_lists)) + " Security Lists")                        
            return self.__network_security_lists
        except Exception as e:
            raise RuntimeError(
                "Error in __network_read_network_security_lists " + str(e.args))

    ##########################################################################
    # Network Subnets Lists
    ##########################################################################
    def __network_read_network_subnets(self):
        try:
            for region_key, region_values in self.__regions.items():
                # Looping through compartments in tenancy
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        subnets_data = oci.pagination.list_call_get_all_results(
                            region_values['network_client'].list_subnets,
                            compartment_id = compartment.id,
                            lifecycle_state="AVAILABLE"
                        ).data
                        # Looping through subnets in a compartment
                        try:
                            for subnet in subnets_data:
                                deep_link = self.__oci_networking_uri + subnet.vcn_id + \
                                    "/subnets/" + subnet.id + '?region=' + region_key
                                record = {
                                    "id": subnet.id,
                                    "availability_domain": subnet.availability_domain,
                                    "cidr_block": subnet.cidr_block,
                                    "compartment_id": subnet.compartment_id,
                                    "dhcp_options_id": subnet.dhcp_options_id,
                                    "display_name": subnet.display_name,
                                    "deep_link": self.__generate_csv_hyperlink(deep_link, subnet.display_name),
                                    "dns_label": subnet.dns_label,
                                    "ipv6_cidr_block": subnet.ipv6_cidr_block,
                                    "ipv6_virtual_router_ip": subnet.ipv6_virtual_router_ip,
                                    "lifecycle_state": subnet.lifecycle_state,
                                    "prohibit_public_ip_on_vnic": subnet.prohibit_public_ip_on_vnic,
                                    "route_table_id": subnet.route_table_id,
                                    "security_list_ids": subnet.security_list_ids,
                                    "subnet_domain_name": subnet.subnet_domain_name,
                                    "time_created": subnet.time_created.strftime(self.__iso_time_format),
                                    "vcn_id": subnet.vcn_id,
                                    "virtual_router_ip": subnet.virtual_router_ip,
                                    "virtual_router_mac": subnet.virtual_router_mac,
                                    "freeform_tags" : subnet.freeform_tags,
                                    "define_tags" : subnet.defined_tags,
                                    "region" : region_key,
                                    "notes":""

                                }
                                # Adding subnet to subnet list
                                self.__network_subnets.append(record)
                        except Exception as e:
                            deep_link = self.__oci_networking_uri + subnet.vcn_id + \
                                    "/subnet/" + subnet.id + '?region=' + region_key
                            record = {
                                "id": subnet.id,
                                "availability_domain": subnet.availability_domain,
                                "cidr_block": subnet.cidr_block,
                                "compartment_id": subnet.compartment_id,
                                "dhcp_options_id": subnet.dhcp_options_id,
                                "display_name": subnet.display_name,
                                "deep_link": self.__generate_csv_hyperlink(deep_link, subnet.display_name),
                                "dns_label": subnet.dns_label,
                                "ipv6_cidr_block": "",
                                "ipv6_virtual_router_ip": "",
                                "lifecycle_state": subnet.lifecycle_state,
                                "prohibit_public_ip_on_vnic": subnet.prohibit_public_ip_on_vnic,
                                "route_table_id": subnet.route_table_id,
                                "security_list_ids": subnet.security_list_ids,
                                "subnet_domain_name": subnet.subnet_domain_name,
                                "time_created": subnet.time_created.strftime(self.__iso_time_format),
                                "vcn_id": subnet.vcn_id,
                                "virtual_router_ip": subnet.virtual_router_ip,
                                "virtual_router_mac": subnet.virtual_router_mac,
                                "region" : region_key,
                                "notes": str(e)

                            }
                            self.__network_subnets.append(record)
            print("\tProcessed " + str(len(self.__network_subnets)) + " Network Subnets")                        
            

            return self.__network_subnets
        except Exception as e:
            raise RuntimeError(
                "Error in __network_read_network_subnets " + str(e.args))


    ##########################################################################
    # Load DRG Attachments
    ##########################################################################
    def __network_read_drg_attachments(self):
        count_of_drg_attachments = 0
        try:
            for region_key, region_values in self.__regions.items():
                # Looping through compartments in tenancy
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        drg_attachment_data = oci.pagination.list_call_get_all_results(
                            region_values['network_client'].list_drg_attachments,
                            compartment_id=compartment.id,
                            lifecycle_state="ATTACHED",
                            attachment_type="ALL"
                        ).data
                        # Looping through DRG Attachments in a compartment
                        for drg_attachment in drg_attachment_data:
                            deep_link = self.__oci_drg_uri + drg_attachment.drg_id + "/drg-attachment/" + drg_attachment.id + '?region=' + region_key
                            try:
                                record = {
                                "id": drg_attachment.id,
                                "display_name" : drg_attachment.display_name,
                                "deep_link": self.__generate_csv_hyperlink(deep_link, drg_attachment.display_name),
                                "drg_id" : drg_attachment.drg_id,
                                "vcn_id" : drg_attachment.vcn_id,
                                "drg_route_table_id" : str(drg_attachment.drg_route_table_id),
                                "export_drg_route_distribution_id" : str(drg_attachment.export_drg_route_distribution_id),
                                "is_cross_tenancy" : drg_attachment.is_cross_tenancy,
                                "lifecycle_state" : drg_attachment.lifecycle_state,
                                "network_details" : drg_attachment.network_details,
                                "network_id" : drg_attachment.network_details.id,
                                "network_type" : drg_attachment.network_details.type,
                                "freeform_tags" : drg_attachment.freeform_tags,
                                "define_tags" : drg_attachment.defined_tags,
                                "time_created" : drg_attachment.time_created.strftime(self.__iso_time_format),
                                "region" : region_key,
                                "notes":""

                            }
                            except:
                                record = {
                                "id": drg_attachment.id,
                                "display_name" : drg_attachment.display_name,
                                "deep_link": self.__generate_csv_hyperlink(deep_link, drg_attachment.display_name),
                                "drg_id" : drg_attachment.drg_id,
                                "vcn_id" : drg_attachment.vcn_id,
                                "drg_route_table_id" : str(drg_attachment.drg_route_table_id),
                                "export_drg_route_distribution_id" : str(drg_attachment.export_drg_route_distribution_id),
                                "is_cross_tenancy" : drg_attachment.is_cross_tenancy,
                                "lifecycle_state" : drg_attachment.lifecycle_state,
                                "network_details" : drg_attachment.network_details,
                                "network_id" : "",
                                "network_type" : "",
                                "freeform_tags" : drg_attachment.freeform_tags,
                                "define_tags" : drg_attachment.defined_tags,
                                "time_created" : drg_attachment.time_created.strftime(self.__iso_time_format),
                                "region" : region_key,
                                "notes":""
                                }

                            # Adding DRG Attachment to DRG Attachments list
                            try:
                                self.__network_drg_attachments[drg_attachment.drg_id].append(record)
                            except:
                                self.__network_drg_attachments[drg_attachment.drg_id] = []
                                self.__network_drg_attachments[drg_attachment.drg_id].append(record)
                            # Counter
                            count_of_drg_attachments +=1

                                
            print("\tProcessed " + str(count_of_drg_attachments) + " DRG Attachments")                        
            return self.__network_drg_attachments
        except Exception as e:
            raise RuntimeError(
                "Error in __network_read_drg_attachments " + str(e.args))

    ##########################################################################
    # Load DRGs  
    ##########################################################################
    def __network_read_drgs(self):
        try:
            for region_key, region_values in self.__regions.items():
                # Looping through compartments in tenancy
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        drg_data = oci.pagination.list_call_get_all_results(
                            region_values['network_client'].list_drgs,
                            compartment_id=compartment.id,
                        ).data
                        # Looping through DRGs in a compartment
                        for drg in drg_data:
                            deep_link = self.__oci_drg_uri + drg.id + '?region=' + region_key
                            #Fetch DRG Upgrade status
                            try:
                                upgrade_status = region_values['network_client'].get_upgrade_status(drg.id).data.status
                            except:
                                upgrade_status = "Not Available"
                                
                            try:
                                record = {
                                    "id": drg.id,
                                    "display_name" : drg.display_name,
                                    "deep_link": self.__generate_csv_hyperlink(deep_link, drg.display_name),
                                    "default_drg_route_tables" : drg.default_drg_route_tables,
                                    "default_ipsec_tunnel_route_table" : drg.default_drg_route_tables.ipsec_tunnel,
                                    "default_remote_peering_connection_route_table" : drg.default_drg_route_tables.remote_peering_connection,
                                    "default_vcn_table" : drg.default_drg_route_tables.vcn,
                                    "default_virtual_circuit_route_table" : drg.default_drg_route_tables.virtual_circuit,
                                    "default_export_drg_route_distribution_id" : drg.default_export_drg_route_distribution_id,
                                    "compartment_id" : drg.compartment_id,
                                    "lifecycle_state" : drg.lifecycle_state,
                                    "upgrade_status" : upgrade_status,                                    
                                    "time_created" : drg.time_created.strftime(self.__iso_time_format),
                                    "freeform_tags" : drg.freeform_tags,
                                    "define_tags" : drg.defined_tags,
                                    "region" : region_key,
                                    "notes":""
                                }
                            except Exception as e:
                                record = {
                                    "id": drg.id,
                                    "display_name" : drg.display_name,
                                    "deep_link": self.__generate_csv_hyperlink(deep_link, drg.display_name),
                                    "default_drg_route_tables" : drg.default_drg_route_tables,
                                    "default_ipsec_tunnel_route_table" : "",
                                    "default_remote_peering_connection_route_table" : "",
                                    "default_vcn_table" : "",
                                    "default_virtual_circuit_route_table" : "",
                                    "default_export_drg_route_distribution_id" : drg.default_export_drg_route_distribution_id,
                                    "compartment_id" : drg.compartment_id,
                                    "lifecycle_state" : drg.lifecycle_state,
                                    "upgrade_status" : upgrade_status,                                    
                                    "time_created" : drg.time_created.strftime(self.__iso_time_format),
                                    "freeform_tags" : drg.freeform_tags,
                                    "define_tags" : drg.defined_tags,
                                    "region" : region_key,
                                    "notes": str(e)

                                }
                            # for Raw Data
                            self.__raw_network_drgs.append(record)
                            # For Checks data
                            self.__network_drgs[drg.id] = record



            print("\tProcessed " + str(len(self.__network_drgs)) + " Dynamic Routing Gateways")                        
            return self.__network_drgs
        except Exception as e:
            raise RuntimeError(
                "Error in __network_read_drgs " + str(e.args))

    ##########################################################################
    # Load Network FastConnect 
    ##########################################################################
    def __network_read_fastonnects(self):
        count_of_fast_connects = 0
        try:
            for region_key, region_values in self.__regions.items():
                # Looping through compartments in tenancy
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        fastconnect_data = oci.pagination.list_call_get_all_results(
                            region_values['network_client'].list_virtual_circuits,
                            compartment_id=compartment.id,
                            # lifecycle_state="PROVISIONED"
                        ).data
                        # Looping through fastconnects in a compartment
                        for fastconnect in fastconnect_data:
                            deep_link = self.__oci_fastconnect_uri + fastconnect.id + '?region=' + region_key
                            try:
                                    record = {
                                        "id": fastconnect.id,
                                        "display_name" : fastconnect.display_name,
                                        "deep_link": self.__generate_csv_hyperlink(deep_link, fastconnect.display_name),
                                        "bandwidth_shape_name" : fastconnect.bandwidth_shape_name,
                                        "bgp_admin_state" : fastconnect.bgp_admin_state,
                                        "bgp_ipv6_session_state" : fastconnect.bgp_ipv6_session_state,
                                        "bgp_management" : fastconnect.bgp_management, 
                                        "bgp_session_state" : fastconnect.bgp_session_state,
                                        "compartment_id" : fastconnect.compartment_id,
                                        "cross_connect_mappings" : fastconnect.cross_connect_mappings,
                                        "customer_asn" : fastconnect.customer_asn,
                                        "customer_bgp_asn" : fastconnect.customer_bgp_asn,
                                        "gateway_id" : fastconnect.gateway_id,
                                        "ip_mtu" : fastconnect.ip_mtu,
                                        "is_bfd_enabled" : fastconnect.is_bfd_enabled,
                                        "lifecycle_state" : fastconnect.lifecycle_state,
                                        "oracle_bgp_asn" : fastconnect.oracle_bgp_asn,
                                        "provider_name" : fastconnect.provider_name,
                                        "provider_service_id" : fastconnect.provider_service_id,
                                        "provider_service_key_name" : fastconnect.provider_service_key_name,
                                        "provider_service_name" : fastconnect.provider_service_name,
                                        "provider_state" : fastconnect.provider_state,
                                        "public_prefixes" : fastconnect.public_prefixes,
                                        "reference_comment" : fastconnect.reference_comment,
                                        "fastconnect_region" : fastconnect.region,
                                        "routing_policy" : fastconnect.routing_policy,
                                        "service_type" : fastconnect.service_type,
                                        "time_created" : fastconnect.time_created.strftime(self.__iso_time_format),
                                        "type" : fastconnect.type,
                                        "freeform_tags" : fastconnect.freeform_tags,
                                        "define_tags" : fastconnect.defined_tags,
                                        "region" : region_key,
                                        "notes":""

                                    }
                                    # Adding fastconnect to fastconnect dict
                                    try:
                                        self.__network_fastconnects[fastconnect.gateway_id].append(record)
                                    except:
                                        self.__network_fastconnects[fastconnect.gateway_id] = []
                                        self.__network_fastconnects[fastconnect.gateway_id].append(record)
                                    count_of_fast_connects += 1

                            except Exception as e:
                                record = {
                                        "id": fastconnect.id,
                                        "display_name" :  fastconnect.display_name,
                                        "deep_link": self.__generate_csv_hyperlink(deep_link, fastconnect.display_name),
                                        "bandwidth_shape_name" : "",
                                        "bgp_admin_state" : "",
                                        "bgp_ipv6_session_state" : "",
                                        "bgp_management" : "", 
                                        "bgp_session_state" : "",
                                        "compartment_id" : compartment.id,
                                        "cross_connect_mappings" : "",
                                        "customer_asn" : "",
                                        "customer_bgp_asn" : "",
                                        "gateway_id" : "",
                                        "ip_mtu" : "",
                                        "is_bfd_enabled" : "",
                                        "lifecycle_state" : "",
                                        "oracle_bgp_asn" : "",
                                        "provider_name" : "",
                                        "provider_service_id" : "",
                                        "provider_service_key_name" : "",
                                        "provider_service_name" : "",
                                        "provider_state" : "",
                                        "public_prefixes" : "",
                                        "reference_comment" : "",
                                        "fastconnect_region" : "",
                                        "routing_policy" : "",
                                        "service_type" : "",
                                        "time_created" : "",
                                        "type" : "",
                                        "freeform_tags" : "",
                                        "define_tags" : "",
                                        "region" : region_key,
                                        "notes": str(e)

                                }
                            
                            # Adding fastconnect to fastconnect dict
                            try:
                                self.__network_fastconnects[compartment.id].append(record)
                            except:
                                self.__network_fastconnects[compartment.id] = []
                                self.__network_fastconnects[compartment.id].append(record)
                            count_of_fast_connects += 1

            print("\tProcessed " + str(count_of_fast_connects) + " FastConnects")                        
            return self.__network_fastconnects
        except Exception as e:
            raise RuntimeError(
                "Error in __network_read_fastonnects " + str(e.args))


    ##########################################################################
    # Load IP Sec Connections
    ##########################################################################
    def __network_read_ip_sec_connections(self):
        count_of_ip_sec_connections = 0
        try:
            for region_key, region_values in self.__regions.items():
                # Looping through compartments in tenancy
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        ip_sec_connections_data = oci.pagination.list_call_get_all_results(
                            region_values['network_client'].list_ip_sec_connections,
                            compartment_id=compartment.id,
                        ).data
                        # Looping through IP SEC Connections in a compartment
                        
                        for ip_sec in ip_sec_connections_data:
                            try:
                                deep_link = self.__oci_ipsec_uri + ip_sec.id + '?region=' + region_key
                                record = {
                                    "id": ip_sec.id,
                                    "display_name" : ip_sec.display_name,
                                    "deep_link": self.__generate_csv_hyperlink(deep_link, ip_sec.display_name),
                                    "cpe_id" : ip_sec.cpe_id,
                                    "drg_id" : ip_sec.drg_id,
                                    "compartment_id" : ip_sec.compartment_id,
                                    "cpe_local_identifier" : ip_sec.cpe_local_identifier,
                                    "cpe_local_identifier_type" : ip_sec.cpe_local_identifier_type,
                                    "lifecycle_state" : ip_sec.lifecycle_state,
                                    "freeform_tags" : ip_sec.freeform_tags,
                                    "define_tags" : ip_sec.defined_tags,
                                    "region" : region_key,
                                    "tunnels" : [],
                                    "number_tunnels_up" : 0,
                                    "tunnels_up" : True, # It is true unless I find out otherwise
                                    "notes":""
                                }
                                # Getting Tunnel Data
                                try:
                                    ip_sec_tunnels_data = oci.pagination.list_call_get_all_results(
                                        region_values['network_client'].list_ip_sec_connection_tunnels,
                                        ipsc_id=ip_sec.id,
                                    ).data
                                    for tunnel in ip_sec_tunnels_data:
                                        deep_link = self.__oci_ipsec_uri + ip_sec.id + "/tunnels/" + tunnel.id + '?region=' + region_key
                                        tunnel_record = {
                                                "id" : tunnel.id,
                                                "cpe_ip" : tunnel.cpe_ip,
                                                "display_name" : tunnel.display_name,
                                                "deep_link": self.__generate_csv_hyperlink(deep_link, tunnel.display_name),
                                                "vpn_ip" : tunnel.vpn_ip,
                                                "ike_version" : tunnel.ike_version,
                                                "encryption_domain_config" : tunnel.encryption_domain_config,
                                                "lifecycle_state" : tunnel.lifecycle_state,
                                                "nat_translation_enabled" : tunnel.nat_translation_enabled,
                                                "bgp_session_info" : tunnel.bgp_session_info,
                                                "oracle_can_initiate" : tunnel.oracle_can_initiate,
                                                "routing" : tunnel.routing,
                                                "status" : tunnel.status,
                                                "compartment_id" : tunnel.compartment_id,
                                                "dpd_mode" : tunnel.dpd_mode,
                                                "dpd_timeout_in_sec" : tunnel.dpd_timeout_in_sec,
                                                "time_created" : tunnel.time_created.strftime(self.__iso_time_format),
                                                "time_status_updated" : str(tunnel.time_status_updated),
                                                "notes" : ""
                                            }
                                        if tunnel_record['status'].upper() == "UP":
                                            record['number_tunnels_up'] += 1
                                        else:
                                            record['tunnels_up'] = False
                                        record["tunnels"].append(tunnel_record)
                                except:
                                    print("\t Unable to tunnels for ip_sec_connection: " + ip_sec.display_name + " id: " + ip_sec.id)
                                    record['tunnels_up'] = False


                            except:
                                record = {
                                    "id": ip_sec.id,
                                    "display_name" : ip_sec.display_name,
                                    "deep_link": self.__generate_csv_hyperlink(deep_link, ip_sec.display_name),
                                    "cpe_id" : "",
                                    "drg_id" : "",
                                    "compartment_id" : ip_sec.compartment_id,
                                    "cpe_local_identifier" : "",
                                    "cpe_local_identifier_type" : "",
                                    "lifecycle_state" : "",
                                    "freeform_tags" : "",
                                    "define_tags" : "",
                                    "region" : region_key,
                                    "tunnels" : [],
                                    "number_tunnels_up" : 0,
                                    "tunnels_up" : False, 
                                    "notes":""
                                }
                                
                            try:
                                self.__network_ipsec_connections[ip_sec.drg_id].append(record)
                            except:
                                self.__network_ipsec_connections[ip_sec.drg_id] = []
                                self.__network_ipsec_connections[ip_sec.drg_id].append(record)
                            count_of_ip_sec_connections += 1

            print("\tProcessed " + str(count_of_ip_sec_connections) + " IP SEC Conenctions")                        
            return self.__network_ipsec_connections
        except Exception as e:
            raise RuntimeError(
                "Error in __network_read_ip_sec_connections " + str(e.args))

     ############################################
     # Load Autonomous Databases
     ############################################
    def __adb_read_adbs(self):
        try:
            for region_key, region_values in self.__regions.items():
                for compartment in self.__compartments: 
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        autonomous_databases = oci.pagination.list_call_get_all_results(
                        region_values['adb_client'].list_autonomous_databases, 
                                compartment_id = compartment.id
                            ).data
                        for adb in autonomous_databases:
                            try: 
                                deep_link = self.__oci_adb_uri + adb.id + '?region=' + region_key
                                if (adb.lifecycle_state != oci.database.models.AutonomousDatabaseSummary.LIFECYCLE_STATE_TERMINATED or
                                    adb.lifecycle_state != oci.database.models.AutonomousDatabaseSummary.LIFECYCLE_STATE_TERMINATING):
                                    record = {
                                                "id": adb.id,
                                                "display_name": adb.display_name,
                                                "deep_link": self.__generate_csv_hyperlink(deep_link, adb.display_name),
                                                "apex_details": adb.apex_details,
                                                "are_primary_whitelisted_ips_used": adb.are_primary_whitelisted_ips_used,
                                                "autonomous_container_database_id": adb.autonomous_container_database_id,
                                                "autonomous_maintenance_schedule_type": adb.autonomous_maintenance_schedule_type,
                                                "available_upgrade_versions": adb.available_upgrade_versions,
                                                "backup_config": adb.backup_config,
                                                "compartment_id": adb.compartment_id,
                                                "connection_strings": adb.connection_strings,
                                                "connection_urls": adb.connection_urls,
                                                "cpu_core_count": adb.cpu_core_count,
                                                "customer_contacts": adb.cpu_core_count,
                                                "data_safe_status": adb.data_safe_status,
                                                "data_storage_size_in_gbs": adb.data_storage_size_in_gbs,
                                                "data_storage_size_in_tbs": adb.data_storage_size_in_tbs,
                                                "database_management_status": adb.database_management_status,
                                                "dataguard_region_type": adb.dataguard_region_type,
                                                "db_name": adb.db_name,
                                                "db_version": adb.db_version,
                                                "db_workload": adb.db_workload,
                                                "defined_tags": adb.defined_tags,
                                                "failed_data_recovery_in_seconds": adb.failed_data_recovery_in_seconds,
                                                "freeform_tags": adb.freeform_tags,
                                                "infrastructure_type": adb.infrastructure_type,
                                                "is_access_control_enabled": adb.is_access_control_enabled,
                                                "is_auto_scaling_enabled": adb.is_auto_scaling_enabled,
                                                "is_data_guard_enabled": adb.is_data_guard_enabled,
                                                "is_dedicated": adb.is_dedicated,
                                                "is_free_tier": adb.is_free_tier,
                                                "is_mtls_connection_required": adb.is_mtls_connection_required,
                                                "is_preview": adb.is_preview,
                                                "is_reconnect_clone_enabled": adb.is_reconnect_clone_enabled,
                                                "is_refreshable_clone": adb.is_refreshable_clone,
                                                "key_history_entry": adb.key_history_entry,
                                                "key_store_id": adb.key_store_id,
                                                "key_store_wallet_name": adb.key_store_wallet_name,
                                                "kms_key_id": adb.kms_key_id,
                                                "kms_key_lifecycle_details": adb.kms_key_lifecycle_details,
                                                "kms_key_version_id": adb.kms_key_version_id,
                                                "license_model": adb.license_model,
                                                "lifecycle_details": adb.lifecycle_details,
                                                "lifecycle_state": adb.lifecycle_state,
                                                "nsg_ids": adb.nsg_ids,
                                                "ocpu_count": adb.ocpu_count,
                                                "open_mode": adb.open_mode,
                                                "operations_insights_status": adb.operations_insights_status,
                                                "peer_db_ids": adb.peer_db_ids,
                                                "permission_level": adb.permission_level,
                                                "private_endpoint": adb.private_endpoint,
                                                "private_endpoint_ip": adb.private_endpoint_ip,
                                                "private_endpoint_label": adb.private_endpoint_label,
                                                "refreshable_mode": adb.refreshable_mode,
                                                "refreshable_status": adb.refreshable_status,
                                                "role": adb.role,
                                                "scheduled_operations": adb.scheduled_operations,
                                                "service_console_url": adb.service_console_url,
                                                "source_id": adb.source_id,
                                                "standby_whitelisted_ips": adb.standby_whitelisted_ips,
                                                "subnet_id": adb.subnet_id,
                                                "supported_regions_to_clone_to": adb.supported_regions_to_clone_to,
                                                "system_tags": adb.system_tags,
                                                "time_created": adb.time_created.strftime(self.__iso_time_format),
                                                "time_data_guard_role_changed": str(adb.time_data_guard_role_changed),
                                                "time_deletion_of_free_autonomous_database": str(adb.time_deletion_of_free_autonomous_database),
                                                "time_local_data_guard_enabled": str(adb.time_local_data_guard_enabled),
                                                "time_maintenance_begin": str(adb.time_maintenance_begin),
                                                "time_maintenance_end": str(adb.time_maintenance_end),
                                                "time_of_last_failover": str(adb.time_of_last_failover),
                                                "time_of_last_refresh": str(adb.time_of_last_refresh),
                                                "time_of_last_refresh_point": str(adb.time_of_last_refresh_point),
                                                "time_of_last_switchover": str(adb.time_of_last_switchover),
                                                "time_of_next_refresh": str(adb.time_of_next_refresh),
                                                "time_reclamation_of_free_autonomous_database": str(adb.time_reclamation_of_free_autonomous_database),
                                                "time_until_reconnect_clone_enabled": str(adb.time_until_reconnect_clone_enabled),
                                                "used_data_storage_size_in_tbs": str(adb.used_data_storage_size_in_tbs),
                                                "vault_id": adb.vault_id,
                                                "whitelisted_ips": adb.whitelisted_ips,
                                                "region" : region_key,
                                                "notes" : ""
                                            }
                                else:
                                    record = {
                                                "id": adb.id,
                                                "display_name": adb.display_name,
                                                "deep_link": self.__generate_csv_hyperlink(deep_link, adb.display_name),
                                                "apex_details": "",
                                                "are_primary_whitelisted_ips_used": "",
                                                "autonomous_container_database_id": "",
                                                "autonomous_maintenance_schedule_type": "",
                                                "available_upgrade_versions": "",
                                                "backup_config": "",
                                                "compartment_id": adb.compartment_id,
                                                "connection_strings": "",
                                                "connection_urls": "",
                                                "cpu_core_count": "",
                                                "customer_contacts": "",
                                                "data_safe_status": "",
                                                "data_storage_size_in_gbs": "",
                                                "data_storage_size_in_tbs": "",
                                                "database_management_status": "",
                                                "dataguard_region_type": "",
                                                "db_name": "",
                                                "db_version": "",
                                                "db_workload": "",
                                                "defined_tags": "",
                                                "failed_data_recovery_in_seconds": "",
                                                "freeform_tags": "",
                                                "infrastructure_type": "",
                                                "is_access_control_enabled": "",
                                                "is_auto_scaling_enabled": "",
                                                "is_data_guard_enabled": "",
                                                "is_dedicated": "",
                                                "is_free_tier": "",
                                                "is_mtls_connection_required": "",
                                                "is_preview": "",
                                                "is_reconnect_clone_enabled": "",
                                                "is_refreshable_clone": "",
                                                "key_history_entry": "",
                                                "key_store_id": "",
                                                "key_store_wallet_name": "",
                                                "kms_key_id": "",
                                                "kms_key_lifecycle_details": "",
                                                "kms_key_version_id": "",
                                                "license_model": "",
                                                "lifecycle_details": "",
                                                "lifecycle_state": adb.lifecycle_state,
                                                "nsg_ids": "",
                                                "ocpu_count": "",
                                                "open_mode": "",
                                                "operations_insights_status": "",
                                                "peer_db_ids": "",
                                                "permission_level": "",
                                                "private_endpoint": "",
                                                "private_endpoint_ip":"",
                                                "private_endpoint_label": "",
                                                "refreshable_mode": "",
                                                "refreshable_status": "",
                                                "role": "",
                                                "scheduled_operations": "",
                                                "service_console_url": "",
                                                "source_id": "",
                                                "standby_whitelisted_ips": "",
                                                "subnet_id": "",
                                                "supported_regions_to_clone_to": "",
                                                "system_tags": "",
                                                "time_created": "",
                                                "time_data_guard_role_changed": "",
                                                "time_deletion_of_free_autonomous_database": "",
                                                "time_local_data_guard_enabled": "",
                                                "time_maintenance_begin": "",
                                                "time_maintenance_end": "",
                                                "time_of_last_failover": "",
                                                "time_of_last_refresh": "",
                                                "time_of_last_refresh_point": "",
                                                "time_of_last_switchover": "",
                                                "time_of_next_refresh": "",
                                                "time_reclamation_of_free_autonomous_database": "",
                                                "time_until_reconnect_clone_enabled": "",
                                                "used_data_storage_size_in_tbs": "",
                                                "vault_id": "",
                                                "whitelisted_ips": "",
                                                "region" : region_key,
                                                "notes": ""
                                            }
                            except Exception as e:
                                record = {
                                            "id":"",
                                            "display_name": "",
                                            "deep_link": "",
                                            "apex_details": "",
                                            "are_primary_whitelisted_ips_used": "",
                                            "autonomous_container_database_id": "",
                                            "autonomous_maintenance_schedule_type": "",
                                            "available_upgrade_versions": "",
                                            "backup_config": "",
                                            "compartment_id": "",
                                            "connection_strings": "",
                                            "connection_urls": "",
                                            "cpu_core_count": "",
                                            "customer_contacts": "",
                                            "data_safe_status": "",
                                            "data_storage_size_in_gbs": "",
                                            "data_storage_size_in_tbs": "",
                                            "database_management_status": "",
                                            "dataguard_region_type": "",
                                            "db_name": "",
                                            "db_version": "",
                                            "db_workload": "",
                                            "defined_tags": "",
                                            "failed_data_recovery_in_seconds": "",
                                            "freeform_tags": "",
                                            "infrastructure_type": "",
                                            "is_access_control_enabled": "",
                                            "is_auto_scaling_enabled": "",
                                            "is_data_guard_enabled": "",
                                            "is_dedicated": "",
                                            "is_free_tier": "",
                                            "is_mtls_connection_required": "",
                                            "is_preview": "",
                                            "is_reconnect_clone_enabled": "",
                                            "is_refreshable_clone": "",
                                            "key_history_entry": "",
                                            "key_store_id": "",
                                            "key_store_wallet_name": "",
                                            "kms_key_id": "",
                                            "kms_key_lifecycle_details": "",
                                            "kms_key_version_id": "",
                                            "license_model": "",
                                            "lifecycle_details": "",
                                            "lifecycle_state": "",
                                            "nsg_ids": "",
                                            "ocpu_count": "",
                                            "open_mode": "",
                                            "operations_insights_status": "",
                                            "peer_db_ids": "",
                                            "permission_level": "",
                                            "private_endpoint": "",
                                            "private_endpoint_ip":"",
                                            "private_endpoint_label": "",
                                            "refreshable_mode": "",
                                            "refreshable_status": "",
                                            "role": "",
                                            "scheduled_operations": "",
                                            "service_console_url": "",
                                            "source_id": "",
                                            "standby_whitelisted_ips": "",
                                            "subnet_id": "",
                                            "supported_regions_to_clone_to": "",
                                            "system_tags": "",
                                            "time_created": "",
                                            "time_data_guard_role_changed": "",
                                            "time_deletion_of_free_autonomous_database": "",
                                            "time_local_data_guard_enabled": "",
                                            "time_maintenance_begin": "",
                                            "time_maintenance_end": "",
                                            "time_of_last_failover": "",
                                            "time_of_last_refresh": "",
                                            "time_of_last_refresh_point": "",
                                            "time_of_last_switchover": "",
                                            "time_of_next_refresh": "",
                                            "time_reclamation_of_free_autonomous_database": "",
                                            "time_until_reconnect_clone_enabled": "",
                                            "used_data_storage_size_in_tbs": "",
                                            "vault_id": "",
                                            "whitelisted_ips": "",
                                            "region" : region_key,
                                            "notes": str(e)
                                }
                            self.__autonomous_databases.append(record)
                
            print("\tProcessed " + str(len(self.__autonomous_databases)) + " Autonomous Databases")                        
            return self.__autonomous_databases
        except Exception as e:
            raise RuntimeError (
                "Error in __adb_read_adbs " + str(e.args))
    
    ############################################
    # Load Oracle Integration Cloud
    ############################################
    def __oic_read_oics(self):
        try:
            for region_key, region_values in self.__regions.items():
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        oic_instances = oci.pagination.list_call_get_all_results(
                            region_values['oic_client'].list_integration_instances,
                            compartment_id = compartment.id
                        ).data
                        for oic_instance in oic_instances:
                            if oic_instance.lifecycle_state == 'ACTIVE' or oic_instance.LIFECYCLE_STATE_INACTIVE  == "INACTIVE":
                                deep_link = self.__oci_oicinstance_uri+ oic_instance.id + '?region=' + region_key
                                try:
                                    record = {
                                        "id": oic_instance.id,
                                        "display_name": oic_instance.display_name,
                                        "deep_link": self.__generate_csv_hyperlink(deep_link, oic_instance.display_name),
                                        "network_endpoint_details": oic_instance.network_endpoint_details,
                                        "compartment_id": oic_instance.compartment_id,
                                        "alternate_custom_endpoints": oic_instance.alternate_custom_endpoints,
                                        "consumption_model": oic_instance.consumption_model,
                                        "custom_endpoint": oic_instance.custom_endpoint,
                                        "instance_url": oic_instance.instance_url,
                                        "integration_instance_type": oic_instance.integration_instance_type,
                                        "is_byol": oic_instance.is_byol,
                                        "is_file_server_enabled": oic_instance.is_file_server_enabled,
                                        "is_visual_builder_enabled": oic_instance.is_visual_builder_enabled,
                                        "lifecycle_state": oic_instance.lifecycle_state,
                                        "message_packs": oic_instance.message_packs,
                                        "state_message": oic_instance.state_message,
                                        "time_created": oic_instance.time_created.strftime(self.__iso_time_format),
                                        "time_updated": str(oic_instance.time_updated),
                                        "region" : region_key,
                                        "notes": ""
                                    }
                                except Exception as e:
                                    record = {
                                        "id": oic_instance.id,
                                        "display_name": oic_instance.display_name,
                                        "deep_link": self.__generate_csv_hyperlink(deep_link, oic_instance.display_name),
                                        "network_endpoint_details": "",
                                        "compartment_id": "",
                                        "alternate_custom_endpoints": "",
                                        "consumption_model": "",
                                        "custom_endpoint": "",
                                        "instance_url": "",
                                        "integration_instance_type": "",
                                        "is_byol": "",
                                        "is_file_server_enabled": "",
                                        "is_visual_builder_enabled": "",
                                        "lifecycle_state": "",
                                        "message_packs": "",
                                        "state_message": "",
                                        "time_created":"",
                                        "time_updated":"",
                                        "region" : region_key,
                                        "notes": str(e)
                                    }
                                self.__integration_instances.append(record)
            print("\tProcessed " + str(len(self.__integration_instances)) + " Integration Instance")                        
            return self.__integration_instances
        except Exception as e:
            raise RuntimeError("Error in __oic_read_oics " + str(e.args))
    
    ############################################
    # Load Oracle Analytics Cloud
    ############################################
    def __oac_read_oacs(self):
        try:
            for region_key, region_values in self.__regions.items():
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        oac_instances = oci.pagination.list_call_get_all_results(
                            region_values['oac_client'].list_analytics_instances,
                            compartment_id=compartment.id
                        ).data
                        for oac_instance in oac_instances:
                            deep_link = self.__oci_oacinstance_uri+ oac_instance.id + '?region=' + region_key  
                            try:
                                record = {
                                    "id": oac_instance.id,
                                    "name": oac_instance.name,
                                    "deep_link": self.__generate_csv_hyperlink(deep_link, oac_instance.name),
                                    "description": oac_instance.description,
                                    "network_endpoint_details": oac_instance.network_endpoint_details,
                                    "network_endpoint_type": oac_instance.network_endpoint_details.network_endpoint_type,
                                    "compartment_id": oac_instance.compartment_id,
                                    "lifecycle_state": oac_instance.lifecycle_state,
                                    "email_notification": oac_instance.email_notification,
                                    "feature_set": oac_instance.feature_set,
                                    "service_url": oac_instance.service_url,
                                    "capacity": oac_instance.capacity,
                                    "license_type": oac_instance.license_type,
                                    "time_created": oac_instance.time_created.strftime(self.__iso_time_format),
                                    "time_updated": str(oac_instance.time_updated),
                                    "region" : region_key,
                                    "notes":""
                                }
                            except Exception as e:
                                record = {
                                    "id": oac_instance.id,
                                    "name": oac_instance.name,
                                    "deep_link": self.__generate_csv_hyperlink(deep_link, oac_instance.name),
                                    "network_endpoint_details": "",
                                    "compartment_id": "",
                                    "lifecycle_state": "",
                                    "email_notification": "",
                                    "feature_set": "",
                                    "service_url": "",
                                    "capacity": "",
                                    "license_type": "",
                                    "time_created": "",
                                    "time_updated": "",
                                    "region" : region_key,
                                    "notes":str(e)
                                }
                            self.__analytics_instances.append(record)
                
            print("\tProcessed " + str(len(self.__analytics_instances)) + " Analytics Instances")                        
            return self.__analytics_instances
        except Exception as e:
            raise RuntimeError("Error in __oac_read_oacs " + str(e.args))
    
    ##########################################################################
    # Events
    ##########################################################################
    def __events_read_event_rules(self):
        
        try:
            for region_key, region_values in self.__regions.items():
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        events_rules_data = oci.pagination.list_call_get_all_results(
                            region_values['events_client'].list_rules,
                            compartment_id = compartment.id
                        ).data

                        for event_rule in events_rules_data:
                            deep_link = self.__oci_events_uri + event_rule.id + '?region=' + region_key
                            record = {
                                "compartment_id": event_rule.compartment_id,
                                "condition": event_rule.condition,
                                "description": event_rule.description,
                                "display_name": event_rule.display_name,
                                "deep_link": self.__generate_csv_hyperlink(deep_link, event_rule.display_name),
                                "id": event_rule.id,
                                "is_enabled": event_rule.is_enabled,
                                "lifecycle_state": event_rule.lifecycle_state,
                                "time_created": event_rule.time_created.strftime(self.__iso_time_format),
                                "region" : region_key
                            }
                            self.__event_rules.append(record)
                
            print("\tProcessed " + str(len(self.__event_rules)) + " Event Rules")                        
            return self.__event_rules
        except Exception as e:
            raise RuntimeError("Error in events_read_rules " + str(e.args))

    ##########################################################################
    # Logging - Log Groups and Logs
    ##########################################################################
    def __logging_read_log_groups_and_logs(self):
        
        try:
            for region_key, region_values in self.__regions.items():
                # Looping through compartments
                for compartment in self.__compartments:
                    # Checking if Managed Compartment cause I can't query it
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        # Getting Log Groups in compartment
                        log_groups = oci.pagination.list_call_get_all_results(
                            region_values['logging_client'].list_log_groups,
                            compartment_id = compartment.id
                        ).data
                        # Looping through log groups to get logs
                        for log_group in log_groups:
                            deep_link = self.__oci_loggroup_uri + log_group.id + '?region=' + region_key
                            record = {
                                "compartment_id": log_group.compartment_id,
                                "description": log_group.description,
                                "display_name": log_group.display_name,
                                "deep_link": self.__generate_csv_hyperlink(deep_link, log_group.display_name),
                                "id": log_group.id,
                                "time_created": log_group.time_created.strftime(self.__iso_time_format),
                                "time_last_modified": str(log_group.time_last_modified),
                                "defined_tags" : log_group.defined_tags,
                                "freeform_tags" : log_group.freeform_tags,
                                "region" : region_key,
                                "logs": []
                            }

                            logs = oci.pagination.list_call_get_all_results(
                                region_values['logging_client'].list_logs,
                                log_group_id=log_group.id
                            ).data
                            for log in logs:
                                deep_link = self.__oci_loggroup_uri + log_group.id + "/logs/" + log.id + '?region=' + region_key
                                log_record = {
                                    "compartment_id": log.compartment_id,
                                    "display_name": log.display_name,
                                    "deep_link": self.__generate_csv_hyperlink(deep_link, log.display_name),
                                    "id": log.id,
                                    "is_enabled": log.is_enabled,
                                    "lifecycle_state": log.lifecycle_state,
                                    "log_group_id": log.log_group_id,
                                    "log_type": log.log_type,
                                    "retention_duration": log.retention_duration,
                                    "time_created": log.time_created.strftime(self.__iso_time_format),
                                    "time_last_modified": str(log.time_last_modified),
                                    "defined_tags" : log.defined_tags,
                                    "freeform_tags" : log.freeform_tags
                                }
                                try:
                                    if log.configuration:
                                        log_record["configuration_compartment_id"] = log.configuration.compartment_id,
                                        log_record["source_category"] = log.configuration.source.category,
                                        log_record["source_parameters"] = log.configuration.source.parameters,
                                        log_record["source_resource"] = log.configuration.source.resource,
                                        log_record["source_service"] = log.configuration.source.service,
                                        log_record["source_source_type"] = log.configuration.source.source_type
                                        log_record["archiving_enabled"] = log.configuration.archiving.is_enabled

                                    if log.configuration.source.service == 'flowlogs':
                                        self.__subnet_logs[log.configuration.source.resource] = {"log_group_id" : log.log_group_id, "log_id": log.id}
                                            
                                    elif log.configuration.source.service == 'objectstorage' and 'write' in log.configuration.source.category:
                                        # Only write logs
                                        self.__write_bucket_logs[log.configuration.source.resource] = {"log_group_id" : log.log_group_id, "log_id": log.id}

                                    elif log.configuration.source.service == 'objectstorage' and 'read' in log.configuration.source.category:
                                        # Only read logs
                                        self.__read_bucket_logs[log.configuration.source.resource] = {"log_group_id" : log.log_group_id, "log_id": log.id}

                                    elif log.configuration.source.service == 'loadbalancer' and 'error' in log.configuration.source.category:
                                        self.__load_balancer_error_logs.append(
                                            log.configuration.source.resource)
                                    elif log.configuration.source.service == 'loadbalancer' and 'access' in log.configuration.source.category:
                                        self.__load_balancer_access_logs.append(
                                            log.configuration.source.resource)
                                    elif log.configuration.source.service == 'apigateway' and 'access' in log.configuration.source.category:
                                        self.__api_gateway_access_logs.append(
                                            log.configuration.source.resource)
                                    elif log.configuration.source.service == 'apigateway' and 'error' in log.configuration.source.category:
                                        self.__api_gateway_error_logs.append(
                                            log.configuration.source.resource)
                                except:
                                    pass
                                # Append Log to log List
                                record['logs'].append(log_record)
                            self.__logging_list.append(record)
                
            print("\tProcessed " + str(len(self.__logging_list)) + " Log Group Logs")                        
            return self.__logging_list
        except Exception as e:
            raise RuntimeError(
                "Error in __logging_read_log_groups_and_logs " + str(e.args))

    ##########################################################################
    # Vault Keys
    ##########################################################################
    def __vault_read_vaults(self):
        self.__vaults = []
        try:
            for region_key, region_values in self.__regions.items():
                # Iterating through compartments
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        vaults_data = oci.pagination.list_call_get_all_results(
                            region_values['vault_client'].list_vaults,
                            compartment_id = compartment.id
                        ).data
                        # Get all Vaults in a compartment
                        for vlt in vaults_data:
                            deep_link = self.__oci_vault_uri + vlt.id + '?region=' + region_key
                            vault_record = {
                                "compartment_id": vlt.compartment_id,
                                "crypto_endpoint": vlt.crypto_endpoint,
                                "display_name": vlt.display_name,
                                "deep_link": self.__generate_csv_hyperlink(deep_link, vlt.display_name),
                                "id": vlt.id,
                                "lifecycle_state": vlt.lifecycle_state,
                                "management_endpoint": vlt.management_endpoint,
                                "time_created": vlt.time_created.strftime(self.__iso_time_format),
                                "vault_type": vlt.vault_type,
                                "freeform_tags": vlt.freeform_tags,
                                "defined_tags": vlt.defined_tags,
                                "region" : region_key,
                                "keys": []
                            }
                            # Checking for active Vaults only
                            if vlt.lifecycle_state == 'ACTIVE':
                                try:
                                    cur_key_client = oci.key_management.KmsManagementClient(
                                        self.__config, vlt.management_endpoint)
                                    keys = oci.pagination.list_call_get_all_results(
                                        cur_key_client.list_keys,
                                        compartment.id
                                    ).data
                                    # Iterrating through Keys in Vaults
                                    for key in keys:
                                        deep_link = self.__oci_vault_uri + vlt.id + "/vaults/" + key.id + '?region=' + region_key
                                        key_record = {
                                            "id": key.id,
                                            "display_name": key.display_name,
                                            "deep_link": self.__generate_csv_hyperlink(deep_link, key.display_name),
                                            "compartment_id": key.compartment_id,
                                            "lifecycle_state": key.lifecycle_state,
                                            "time_created": key.time_created.strftime(self.__iso_time_format),
                                        }
                                        # Getting Key Versions - Most current one is the first one in the list
                                        key_versions = oci.pagination.list_call_get_all_results(
                                            cur_key_client.list_key_versions,
                                            key.id
                                        ).data

                                        # Adding current key version to key_record
                                        key_record['current_key_version_date'] = key_versions[0].time_created
                                        # Adding key to vault
                                        vault_record['keys'].append(key_record)
                                
                                except Exception as e:
                                    self.__vaults.append(vault_record)


                            self.__vaults.append(vault_record)
                
            print("\tProcessed " + str(len(self.__vaults)) + " Vaults")                        
            return self.__vaults
        except Exception as e:
            raise RuntimeError(
                "Error in __vault_read_vaults " + str(e.args))

    ##########################################################################
    # OCI Budgets
    ##########################################################################
    def __budget_read_budgets(self):
        try:
            # Getting all budgets in tenancy of any type
            budgets_data = oci.pagination.list_call_get_all_results(
                self.__regions[self.__home_region]['budget_client'].list_budgets,
                compartment_id=self.__tenancy.id,
                target_type="ALL"
            ).data
            # Looping through Budgets to to get records
            for budget in budgets_data:
                try:
                    alerts_data = oci.pagination.list_call_get_all_results(
                            self.__regions[self.__home_region]['budget_client'].list_alert_rules,
                            budget_id=budget.id,
                        ).data
                except Exception as e:
                    print("\tFailed to get Budget Data for Budget Name: " + budget.display_name + " id: " + budget.id)
                    alerts_data = []
                deep_link = self.__oci_budget_uri + budget.id
                record = {
                    "actual_spend" : budget.actual_spend,
                    "alert_rule_count" : budget.alert_rule_count,
                    "amount" : budget.amount,
                    "budget_processing_period_start_offset" : budget.budget_processing_period_start_offset,
                    "compartment_id": budget.compartment_id,
                    "description" : budget.description,
                    "display_name": budget.display_name,
                    "deep_link": self.__generate_csv_hyperlink(deep_link, budget.display_name),
                    "id": budget.id,
                    "lifecycle_state" : budget.lifecycle_state,
                    "processing_period_type" : budget.processing_period_type,
                    "reset_period" : budget.reset_period,
                    "target_compartment_id" : budget.target_compartment_id,
                    "target_type" : budget.target_type,
                    "tagerts" : budget.targets,
                    "time_created": budget.time_created.strftime(self.__iso_time_format),
                    "time_spend_computed": str(budget.time_spend_computed),
                    "alerts" : []
                }
                
                for alert in alerts_data:
                    record['alerts'].append(alert)

                # Append Budget to list of Budgets
                self.__budgets.append(record)

            print("\tProcessed " + str(len(self.__budgets)) + " Budgets")
            return self.__budgets
        except Exception as e:
            raise RuntimeError(
                "Error in __budget_read_budgets " + str(e.args))


    ##########################################################################
    # Audit Configuration
    ##########################################################################
    def __audit_read_tenancy_audit_configuration(self):
        # Pulling the Audit Configuration
        try:
            self.__audit_retention_period = self.__regions[self.__home_region]['audit_client'].get_configuration(
                self.__tenancy.id).data.retention_period_days
        except Exception as e:
            if "NotAuthorizedOrNotFound" in str(e):
                self.__audit_retention_period = -1
                print("\t*** Access to audit retention requires the user to be part of the Administrator group ***")
            else:
                raise RuntimeError("Error in __audit_read_tenancy_audit_configuration " + str(e.args))
            
        print("\tProcessed Audit Configuration.")
        return self.__audit_retention_period

    ##########################################################################
    # Cloud Guard Configuration
    ##########################################################################
    def __cloud_guard_read_cloud_guard_configuration(self):
        try:
            self.__cloud_guard_config = self.__regions[self.__home_region]['cloud_guard_client'].get_configuration(
                self.__tenancy.id).data
            self.__cloud_guard_config_status = self.__cloud_guard_config.status
            
            print("\tProcessed Cloud Guard Configuration.")
            return self.__cloud_guard_config_status
        except Exception as e:
            self.__cloud_guard_config_status = 'DISABLED'
            print("*** Cloud Guard service requires a PayGo account ***")


    ##########################################################################
    # Cloud Guard Configuration
    ##########################################################################
    def __cloud_guard_read_cloud_guard_targets(self):
        cloud_guard_targets = 0
        try:
            for compartment in self.__compartments:
                if self.__if_not_managed_paas_compartment(compartment.name):
                    # Getting a compartments target
                    cg_targets = self.__regions[self.__cloud_guard_config.reporting_region]['cloud_guard_client'].list_targets(
                        compartment_id=compartment.id).data.items
                    # Looping throufh targets to get target data
                    for target in cg_targets:
                        try:
                            # Getting Target data like recipes 
                            try:
                                target_data = self.__regions[self.__cloud_guard_config.reporting_region]['cloud_guard_client'].get_target(
                                target_id=target.id).data
                            except Exception as e:
                                target_data = None
                            deep_link = self.__oci_cgtarget_uri + target.id
                            record = {
                                "compartment_id": target.compartment_id,
                                "defined_tags": target.defined_tags,
                                "display_name": target.display_name,
                                "deep_link": self.__generate_csv_hyperlink(deep_link, target.display_name),
                                "freeform_tags": target.freeform_tags,
                                "id": target.id,
                                "lifecycle_state": target.lifecycle_state,
                                "lifecyle_details": target.lifecyle_details,
                                "system_tags": target.system_tags,
                                "recipe_count" : target.recipe_count,
                                "target_resource_id": target.target_resource_id,
                                "target_resource_type": target.target_resource_type,
                                "time_created": target.time_created.strftime(self.__iso_time_format),
                                "time_updated": str(target.time_updated),
                                "inherited_by_compartments" : target_data.inherited_by_compartments if target_data else "",
                                "description" : target_data.description if target_data else "",
                                "target_details" : target_data.target_details if target_data else "",                            
                                "target_detector_recipes" : target_data.target_detector_recipes if target_data else "",
                                "target_responder_recipes" : target_data.target_responder_recipes if target_data else ""
                            }
                            # Indexing by compartment_id

                            self.__cloud_guard_targets[compartment.id] = record

                            cloud_guard_targets += 1
                        except Exception as e:
                            print("\t Failed to Cloud Guard Target Data for: " + target.display_name + " id: " + target.id)

            print("\tProcessed " + str(cloud_guard_targets) + " Cloud Guard Targets")                        
            return self.__cloud_guard_targets
        except Exception as e:
            print("*** Cloud Guard service requires a PayGo account ***")

    ##########################################################################
    # Identity Password Policy
    ##########################################################################
    def __identity_read_tenancy_password_policy(self):
        try:
            self.__tenancy_password_policy = self.__regions[self.__home_region]['identity_client'].get_authentication_policy(
                self.__tenancy.id).data
            
            print("\tProcessed Tenancy Password Policy...")
            return self.__tenancy_password_policy
        except Exception as e:
            if "NotAuthorizedOrNotFound" in str(e):
                self.__tenancy_password_policy = None
                print("\t*** Access to password policies in this tenancy requires elevated permissions. ***")
            else:
                raise RuntimeError(
                "Error in __identity_read_tenancy_password_policy " + str(e.args))

    ##########################################################################
    # Oracle Notifications Services for Subscriptions
    ##########################################################################
    def __ons_read_subscriptions(self):
        try:
            for region_key, region_values in self.__regions.items():
                # Iterate through compartments to get all subscriptions
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        subs_data = oci.pagination.list_call_get_all_results(
                            region_values['ons_subs_client'].list_subscriptions,
                            compartment_id = compartment.id
                        ).data
                        for sub in subs_data:
                            deep_link = self.__oci_onssub_uri + sub.id + '?region=' + region_key
                            record = {
                                "id": sub.id,
                                "deep_link": self.__generate_csv_hyperlink(deep_link, sub.id),
                                "compartment_id": sub.compartment_id,
                                "created_time": sub.created_time, # this is an INT
                                "endpoint": sub.endpoint,
                                "protocol": sub.protocol,
                                "topic_id": sub.topic_id,
                                "lifecycle_state": sub.lifecycle_state,
                                "defined_tags": sub.defined_tags,
                                "freeform_tags": sub.freeform_tags,
                                "region" : region_key

                            }
                            self.__subscriptions.append(record)
                
            print("\tProcessed " + str(len(self.__subscriptions)) + " Subscriptions")                        
            return self.__subscriptions

        except Exception as e:
            raise RuntimeError("Error in ons_read_subscription " + str(e.args))

    ##########################################################################
    # Identity Tag Default
    ##########################################################################
    def __identity_read_tag_defaults(self):
        try:
            # Getting Tag Default for the Root Compartment - Only
            tag_defaults = oci.pagination.list_call_get_all_results(
                self.__regions[self.__home_region]['identity_client'].list_tag_defaults,
                compartment_id=self.__tenancy.id
            ).data
            for tag in tag_defaults:
                deep_link = self.__oci_compartment_uri + tag.compartment_id + "/tag-defaults"
                record = {
                    "id": tag.id,
                    "compartment_id": tag.compartment_id,
                    "value": tag.value,
                    "deep_link": self.__generate_csv_hyperlink(deep_link, tag.value),
                    "time_created": tag.time_created.strftime(self.__iso_time_format),
                    "tag_definition_id": tag.tag_definition_id,
                    "tag_definition_name": tag.tag_definition_name,
                    "tag_namespace_id": tag.tag_namespace_id,
                    "lifecycle_state": tag.lifecycle_state

                }
                self.__tag_defaults.append(record)
            
            print("\tProcessed " + str(len(self.__tag_defaults)) + " Tag Defaults")                        
            return self.__tag_defaults

        except Exception as e:
            raise RuntimeError(
                "Error in __identity_read_tag_defaults " + str(e.args))

    ##########################################################################
    # Get Service Connectors
    ##########################################################################
    def __sch_read_service_connectors(self):
                
        try:
            # looping through regions
            for region_key, region_values in self.__regions.items():
                # Collecting Service Connectors from each compartment
                for compartment in self.__compartments:
                    # Skipping the managed paas compartment
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        # Only getting active service connectors
                        service_connectors_data = oci.pagination.list_call_get_all_results(
                            region_values['sch_client'].list_service_connectors,
                            compartment_id=compartment.id,
                            lifecycle_state='ACTIVE'
                        ).data
                        # Getting Bucket Info
                        for connector in service_connectors_data:
                            deep_link = self.__oci_serviceconnector_uri + connector.id + "/logging" + '?region=' + region_key
                            try:
                                service_connector = region_values['sch_client'].get_service_connector(
                                    service_connector_id=connector.id
                                    ).data
                                record = {
                                    "id": service_connector.id,
                                    "display_name": service_connector.display_name,
                                    "deep_link": self.__generate_csv_hyperlink(deep_link, service_connector.display_name),
                                    "description": service_connector.description,
                                    "freeform_tags": service_connector.freeform_tags,
                                    "defined_tags" : service_connector.defined_tags,
                                    "lifecycle_state" : service_connector.lifecycle_state,
                                    "lifecycle_details": service_connector.lifecyle_details,
                                    "system_tags": service_connector.system_tags,
                                    "time_created": service_connector.time_created.strftime(self.__iso_time_format),
                                    "time_updated": str(service_connector.time_updated),
                                    "target_kind" : service_connector.target.kind,
                                    "log_sources" : [],
                                    "region" : region_key,
                                    "notes": ""
                                }
                                for log_source in service_connector.source.log_sources:
                                    record['log_sources'].append({
                                            'compartment_id' : log_source.compartment_id,
                                            'log_group_id' : log_source.log_group_id,
                                            'log_id' : log_source.log_id
                                        }
                                    )
                                self.__service_connectors[service_connector.id] = record
                            except Exception as e:
                                record = {
                                    "id": connector.id,
                                    "display_name": connector.display_name,
                                    "deep_link": self.__generate_csv_hyperlink(deep_link, connector.display_name),
                                    "description": connector.description,
                                    "freeform_tags": connector.freeform_tags,
                                    "defined_tags" : connector.defined_tags,
                                    "lifecycle_state" : connector.lifecycle_state,
                                    "lifecycle_details": connector.lifecycle_details,
                                    "system_tags": "",
                                    "time_created": connector.time_created.strftime(self.__iso_time_format),
                                    "time_updated": str(connector.time_updated),
                                    "target_kind" : "",
                                    "log_sources" : [],
                                    "region" : region_key,
                                    "notes": str(e)
                                }
                                self.__service_connectors[connector.id] = record
            # Returning Service Connectors
            print("\tProcessed " + str(len(self.__service_connectors)) + " Service Connectors")
            return self.__service_connectors
        except Exception as e:
            raise RuntimeError("Error in __sch_read_service_connectors " + str(e.args))

    ##########################################################################
    # Resources in root compartment
    ##########################################################################
    def __search_resources_in_root_compartment(self):
        
        # query = []
        # resources_in_root_data = []
        # record = []
        query = "query VCN, instance, volume, filesystem, bucket, autonomousdatabase, database, dbsystem resources where compartmentId = '" + self.__tenancy.id + "'"
        # resources_in_root_data = self.__search_run_structured_query(query)

        for region_key, region_values in self.__regions.items():
            try:
                structured_search = oci.resource_search.models.StructuredSearchDetails(query=query, type='Structured',
                                                                                    matching_context_type=oci.resource_search.models.SearchDetails.MATCHING_CONTEXT_TYPE_NONE)
                search_results = region_values['search_client'].search_resources(
                    structured_search).data.items
                for item in search_results:
                    record = {
                        "display_name": item.display_name,
                        "id": item.identifier,
                        "region" : region_key
                    }
                    self.__resources_in_root_compartment.append(record)

            except Exception as e:
                raise RuntimeError(
                    "Error in __search_resources_in_root_compartment " + str(e.args))
        
        print("\tProcessed " + str(len(self.__resources_in_root_compartment)) + " resources in the root compartment")                        
        return self.__resources_in_root_compartment

    ##########################################################################
    # Analyzes Tenancy Data for CIS Report
    ##########################################################################
    def __report_cis_analyze_tenancy_data(self):
        
        # 1.1 Check - Checking for policy statements that are not restricted to a service
        for policy in self.__policies:
            for statement in policy['statements']:
                if "allow group".upper() in statement.upper() \
                    and ("to manage all-resources".upper() in statement.upper()) \
                        and policy['name'].upper() != "Tenant Admin Policy".upper():
                    # If there are more than manage all-resources in you don't meet this rule
                    self.cis_foundations_benchmark_1_2['1.1']['Status'] = False 
                    self.cis_foundations_benchmark_1_2['1.1']['Findings'].append(policy)
                    break
  
        # 1.2 Check
        for policy in self.__policies:
            for statement in policy['statements']:
                if "allow group".upper() in statement.upper() \
                        and "to manage all-resources in tenancy".upper() in statement.upper() \
                        and policy['name'].upper() != "Tenant Admin Policy".upper():

                    self.cis_foundations_benchmark_1_2['1.2']['Status'] = False
                    self.cis_foundations_benchmark_1_2['1.2']['Findings'].append(
                        policy)
        
        # 1.3 Check - May want to add a service check
        for policy in self.__policies:
          if policy['name'].upper() != "Tenant Admin Policy".upper() and policy['name'].upper() != "PSM-root-policy":
                for statement in policy['statements']:
                    if ("allow group".upper() in statement.upper() and "tenancy".upper() in statement.upper() and \
                         ("to manage ".upper() in statement.upper() or "to use".upper() in statement.upper()) and \
                             ("all-resources".upper() in statement.upper() or (" groups ".upper() in statement.upper() and " users ".upper() in statement.upper()))):
                        split_statement = statement.split("where")
                        # Checking if there is a where clause
                        if len(split_statement) == 2:
                            # If there is a where clause remove whitespace and quotes
                            clean_where_clause = split_statement[1].upper().replace(" ", "").replace("'", "")
                            if all(permission.upper() in clean_where_clause for permission in self.cis_iam_checks['1.3']["targets"]): 
                                pass
                            else:
                                self.cis_foundations_benchmark_1_2['1.3']['Findings'].append(policy)
                                self.cis_foundations_benchmark_1_2['1.3']['Status'] = False

                        else:
                            self.cis_foundations_benchmark_1_2['1.3']['Findings'].append(policy)
                            self.cis_foundations_benchmark_1_2['1.3']['Status'] = False



        # 1.4 Check - Password Policy - Only in home region
        if self.__tenancy_password_policy:
            if self.__tenancy_password_policy.password_policy.is_lowercase_characters_required:
                self.cis_foundations_benchmark_1_2['1.4']['Status'] = True
        else:
            self.cis_foundations_benchmark_1_2['1.4']['Status'] = None

        # 1.7 Check - Local Users w/o MFA
        for user in self.__users:
            if user['identity_provider_id'] is None and user['can_use_console_password'] and not(user['is_mfa_activated']) and user['lifecycle_state'] == 'ACTIVE':
                self.cis_foundations_benchmark_1_2['1.7']['Status'] = False
                self.cis_foundations_benchmark_1_2['1.7']['Findings'].append(
                    user)

        # 1.8 Check - API Keys over 90
        for user in self.__users:
            if user['api_keys']:
                for key in user['api_keys']:
                    if self.api_key_time_max_datetime >= datetime.datetime.strptime(key['time_created'], self.__iso_time_format) and key['lifecycle_state'] == 'ACTIVE':
                        self.cis_foundations_benchmark_1_2['1.8']['Status'] = False
                        finding = {
                            "user_name": user['name'],
                            "user_id": user['id'],
                            "key_id": key['id'],
                            'fingerprint': key['fingerprint'],
                            'inactive_status': key['inactive_status'],
                            'lifecycle_state': key['lifecycle_state'],
                            'time_created': key['time_created']
                        }

                        self.cis_foundations_benchmark_1_2['1.8']['Findings'].append(
                            finding)

        # CIS 1.9 Check - Old Customer Secrets
        for user in self.__users:
            if user['customer_secret_keys']:
                for key in user['customer_secret_keys']:
                    if self.api_key_time_max_datetime >= datetime.datetime.strptime(key['time_created'], self.__iso_time_format) and key['lifecycle_state'] == 'ACTIVE':
                        self.cis_foundations_benchmark_1_2['1.9']['Status'] = False

                        finding = {
                            "user_name": user['name'],
                            "user_id": user['id'],
                            "id": key['id'],
                            'display_name': key['display_name'],
                            'inactive_status': key['inactive_status'],
                            'lifecycle_state': key['lifecycle_state'],
                            'time_created': key['time_created'],
                            'time_expires': key['time_expires'],
                        }

                        self.cis_foundations_benchmark_1_2['1.9']['Findings'].append(
                            finding)

        # CIS 1.10 Check - Old Auth Tokens
        for user in self.__users:
            if user['auth_tokens']:
                for key in user['auth_tokens']:
                    if self.api_key_time_max_datetime >= datetime.datetime.strptime(key['time_created'], self.__iso_time_format) and key['lifecycle_state'] == 'ACTIVE':
                        self.cis_foundations_benchmark_1_2['1.10']['Status'] = False

                        finding = {
                            "user_name": user['name'],
                            "user_id": user['id'],
                            "id": key['id'],
                            "description": key['description'],
                            "inactive_status": key['inactive_status'],
                            "lifecycle_state": key['lifecycle_state'],
                            "time_created": key['time_created'],
                            "time_expires": key['time_expires'],
                            "token": key['token']
                        }

                        self.cis_foundations_benchmark_1_2['1.10']['Findings'].append(
                            finding)

        # CIS 1.11 Active Admins with API keys
        # Iterating through all users to see if they have API Keys and if they are active users
        for user in self.__users:
            if 'Administrators' in user['groups'] and user['api_keys'] and user['lifecycle_state'] == 'ACTIVE':
                self.cis_foundations_benchmark_1_2['1.11']['Status'] = False
                self.cis_foundations_benchmark_1_2['1.11']['Findings'].append(
                    user)

        # CIS 1.12 Check - This check is complete uses email verification
        # Iterating through all users to see if they have API Keys and if they are active users
        for user in self.__users:
            if user['external_identifier'] is None and user['lifecycle_state'] == 'ACTIVE' and not(user['email_verified']):
                self.cis_foundations_benchmark_1_2['1.12']['Status'] = False
                self.cis_foundations_benchmark_1_2['1.12']['Findings'].append(
                    user)
        
        # CIS 1.13 Check - Ensure Dynamic Groups are used for OCI instances, OCI Cloud Databases and OCI Function to access OCI resources
        # Iterating through all dynamic groups ensure there are some for fnfunc, instance or autonomous.  Using reverse logic so starts as a false
        for dynamic_group in self.__dynamic_groups:
            if any(oci_resource.upper() in str(dynamic_group['matching_rule'].upper()) for oci_resource in self.cis_iam_checks['1.13']['resources']):
                self.cis_foundations_benchmark_1_2['1.13']['Status'] = True
            else:
                self.cis_foundations_benchmark_1_2['1.13']['Findings'].append(
                    dynamic_group)
        # Clearing finding
        if self.cis_foundations_benchmark_1_2['1.13']['Status']:
            self.cis_foundations_benchmark_1_2['1.13']['Findings'] = []

        # CIS 1.14 Check - Ensure storage service-level admins cannot delete resources they manage. 
        # Iterating through all policies
        for policy in self.__policies:
            if policy['name'].upper() != "Tenant Admin Policy".upper() and policy['name'].upper() != "PSM-root-policy":
                for statement in policy['statements']:
                    for resource in self.cis_iam_checks['1.14']:
                        if  "allow group".upper() in statement.upper() and "manage".upper() in statement.upper() and resource.upper() in statement.upper():
                            split_statement = statement.split("where")
                            if len(split_statement) == 2:
                                clean_where_clause = split_statement[1].upper().replace(" ", "").replace("'", "")
                                if all(permission.upper() in clean_where_clause for permission in self.cis_iam_checks['1.14'][resource]):
                                    pass
                                else:
                                    self.cis_foundations_benchmark_1_2['1.14']['Findings'].append(policy)
                            else:
                                self.cis_foundations_benchmark_1_2['1.14']['Findings'].append(policy)

        # CIS 2.1, 2.2, & 2.5 Check - Security List Ingress from 0.0.0.0/0 on ports 22, 3389
        for sl in self.__network_security_lists:
            for irule in sl['ingress_security_rules']:

                if irule['source'] == "0.0.0.0/0" and irule['protocol'] == '6':
                    if irule['tcp_options']:
                        try:
                            if irule['tcp_options'].destination_port_range.min == 22 and irule['tcp_options'].destination_port_range.max == 22:
                                self.cis_foundations_benchmark_1_2['2.1']['Status'] = False
                                self.cis_foundations_benchmark_1_2['2.1']['Findings'].append(
                                    sl)
                            elif irule['tcp_options'].destination_port_range.min == 3389 and irule['tcp_options'].destination_port_range.max == 3389:
                                self.cis_foundations_benchmark_1_2['2.2']['Status'] = False
                                self.cis_foundations_benchmark_1_2['2.2']['Findings'].append(
                                    sl)
                        except (AttributeError):
                            # Temporarily adding unfettered access to rule 2.5. Move this once a proper rule is available.
                            # print(" I am an excption " * 5)
                            self.cis_foundations_benchmark_1_2['2.5']['Status'] = False
                            self.cis_foundations_benchmark_1_2['2.5']['Findings'].append(
                                sl)

                # CIS 2.5 Check - any rule with 0.0.0.0 where protocol not 1 (ICMP)
                if irule['source'] == "0.0.0.0/0" and irule['protocol'] != '1':
                    self.cis_foundations_benchmark_1_2['2.5']['Status'] = False
                    self.cis_foundations_benchmark_1_2['2.5']['Findings'].append(
                        sl)

        # CIS 2.3 and 2.4 Check - Network Security Groups Ingress from 0.0.0.0/0 on ports 22, 3389
        for nsg in self.__network_security_groups:
            for rule in nsg['rules']:
                if rule['source'] == "0.0.0.0/0" and rule['protocol'] == '6':
                    if rule['tcp_options']:
                        try:
                            if rule['tcp_options'].destination_port_range.min == 22 or rule['tcp_options'].destination_port_range.max == 22:
                                self.cis_foundations_benchmark_1_2['2.3']['Status'] = False
                                self.cis_foundations_benchmark_1_2['2.3']['Findings'].append(
                                    nsg)
                            elif rule['tcp_options'].destination_port_range.min == 3389 or rule['tcp_options'].destination_port_range.max == 3389:
                                self.cis_foundations_benchmark_1_2['2.4']['Status'] = False
                                self.cis_foundations_benchmark_1_2['2.4']['Findings'].append(
                                    nsg)
                        except (AttributeError):
                            # Temporarily adding unfettered access to rule 2.3. Move this once a proper rule is available.
                            self.cis_foundations_benchmark_1_2['2.3']['Status'] = False
                            self.cis_foundations_benchmark_1_2['2.3']['Findings'].append(
                                nsg)

        # CIS 2.6 - Ensure Oracle Integration Cloud (OIC) access is restricted to allowed sources
        # Iterating through OIC instance have network access rules and ensure 0.0.0.0/0 is not in the list
        for integration_instance in self.__integration_instances:
            if not(integration_instance['network_endpoint_details']):
                self.cis_foundations_benchmark_1_2['2.6']['Status'] = False
                self.cis_foundations_benchmark_1_2['2.6']['Findings'].append(
                    integration_instance)
            elif integration_instance['network_endpoint_details']:
                if "0.0.0.0/0" in str(integration_instance['network_endpoint_details']):
                    self.cis_foundations_benchmark_1_2['2.6']['Status'] = False
                    self.cis_foundations_benchmark_1_2['2.6']['Findings'].append(
                        integration_instance)                    

        # CIS 2.7 - Ensure Oracle Analytics Cloud (OAC) access is restricted to allowed sources or deployed within a VCN
        for analytics_instance in self.__analytics_instances:
            if analytics_instance['network_endpoint_type'].upper() == 'PUBLIC':
                if not(analytics_instance['network_endpoint_details'].whitelisted_ips):
                    self.cis_foundations_benchmark_1_2['2.7']['Status'] = False
                    self.cis_foundations_benchmark_1_2['2.7']['Findings'].append(
                    analytics_instance)    

                elif "0.0.0.0/0" in analytics_instance['network_endpoint_details'].whitelisted_ips:
                    self.cis_foundations_benchmark_1_2['2.7']['Status'] = False
                    self.cis_foundations_benchmark_1_2['2.7']['Findings'].append(
                        analytics_instance) 

        # CIS 2.8 Check - Ensure Oracle Autonomous Shared Databases (ADB) access is restricted to allowed sources or deployed within a VCN
        # Iterating through ADB Checking for null NSGs, whitelisted ip or allowed IPs 0.0.0.0/0 
        for autonomous_database in self.__autonomous_databases:
            if not(autonomous_database['whitelisted_ips']) and not(autonomous_database['nsg_ids']):
                self.cis_foundations_benchmark_1_2['2.8']['Status'] = False
                self.cis_foundations_benchmark_1_2['2.8']['Findings'].append(
                    autonomous_database)
            elif autonomous_database['whitelisted_ips']:
                for value in autonomous_database['whitelisted_ips']:
                    if '0.0.0.0/0' in str(autonomous_database['whitelisted_ips']):
                        self.cis_foundations_benchmark_1_2['2.8']['Status'] = False
                        self.cis_foundations_benchmark_1_2['2.8']['Findings'].append(
                            autonomous_database)

        # CIS 3.1 Check - Ensure Audit log retention == 365 - Only checking in home region
        if self.__audit_retention_period >= 365:
            self.cis_foundations_benchmark_1_2['3.1']['Status'] = True

        # CIS Check 3.2 - Check for Default Tags in Root Compartment
        # Iterate through tags looking for ${iam.principal.name}
        for tag in self.__tag_defaults:
            if tag['value'] == "${iam.principal.name}":
                self.cis_foundations_benchmark_1_2['3.2']['Status'] = True

        # CIS Check 3.3 - Check for Active Notification and Subscription
        if len(self.__subscriptions) > 0:
            self.cis_foundations_benchmark_1_2['3.3']['Status'] = True

        # CIS Checks 3.4 - 3.13
        # Iterate through all event rules
        for event in self.__event_rules:
            # Convert Event Condition to dict
            jsonable_str = event['condition'].lower().replace("'", "\"")
            try:
                event_dict = json.loads(jsonable_str)
            except:
                print("*** Invalid Event Condition for event (not in JSON format): " + event['display_name'] + " ***")
                event_dict = {}
            # Issue 256: 'eventtpye' not in event_dict (i.e. missing in event condition)
            if event_dict and 'eventtype' in event_dict:
                for key, changes in self.cis_monitoring_checks.items():
                    # Checking if all cis change list is a subset of event condition
                    try:
                        if(all(x in event_dict['eventtype'] for x in changes)):
                            self.cis_foundations_benchmark_1_2[key]['Status'] = True
                    except Exception as e:
                        print("*** Invalid Event Data for event: " + event['display_name'] + " ***")
        
        # CIS Check 3.14 - VCN FlowLog enable
        # Generate list of subnets IDs
        for subnet in self.__network_subnets:
            if not(subnet['id'] in self.__subnet_logs):
                self.cis_foundations_benchmark_1_2['3.14']['Status'] = False
                self.cis_foundations_benchmark_1_2['3.14']['Findings'].append(
                    subnet)

        # CIS Check 3.15 - Cloud Guard enabled
        if self.__cloud_guard_config_status == 'ENABLED':
            self.cis_foundations_benchmark_1_2['3.15']['Status'] = True
        else:
            self.cis_foundations_benchmark_1_2['3.15']['Status'] = False

        # CIS Check 3.16 - Encryption keys over 365
        # Generating list of keys
        for vault in self.__vaults:
            for key in vault['keys']:
                if self.kms_key_time_max_datetime >=  datetime.datetime.strptime(key['time_created'], self.__iso_time_format):
                    self.cis_foundations_benchmark_1_2['3.16']['Status'] = False
                    self.cis_foundations_benchmark_1_2['3.16']['Findings'].append(
                        key)

        # CIS Check 3.17 - Object Storage with Logs
        # Generating list of buckets names
        for bucket in self.__buckets:
            if not(bucket['name'] in self.__write_bucket_logs):
                self.cis_foundations_benchmark_1_2['3.17']['Status'] = False
                self.cis_foundations_benchmark_1_2['3.17']['Findings'].append(
                    bucket)

        # CIS Section 4.1 Bucket Checks
        # Generating list of buckets names
        for bucket in self.__buckets:
            if 'public_access_type' in bucket:
                if bucket['public_access_type'] != 'NoPublicAccess':
                    self.cis_foundations_benchmark_1_2['4.1.1']['Status'] = False
                    self.cis_foundations_benchmark_1_2['4.1.1']['Findings'].append(
                        bucket)

            if 'kms_key_id' in bucket:
                if not(bucket['kms_key_id']):
                    self.cis_foundations_benchmark_1_2['4.1.2']['Findings'].append(
                        bucket)
                    self.cis_foundations_benchmark_1_2['4.1.2']['Status'] = False
            
            if 'versioning' in bucket:
                if bucket['versioning'] != "Enabled":
                    self.cis_foundations_benchmark_1_2['4.1.3']['Findings'].append(
                        bucket)
                    self.cis_foundations_benchmark_1_2['4.1.3']['Status'] = False

        # CIS Section 4.2.1 Block Volume Checks
        # Generating list of block volumes names
        for volume in self.__block_volumes:
            if 'kms_key_id' in volume:
                if not(volume['kms_key_id']):
                    self.cis_foundations_benchmark_1_2['4.2.1']['Findings'].append(
                        volume)
                    self.cis_foundations_benchmark_1_2['4.2.1']['Status'] = False
        
        # CIS Section 4.2.2 Boot Volume Checks
        # Generating list of boot names
        for boot_volume in self.__boot_volumes:
            if 'kms_key_id' in boot_volume:
                if not(boot_volume['kms_key_id']):
                    self.cis_foundations_benchmark_1_2['4.2.2']['Findings'].append(
                        boot_volume)
                    self.cis_foundations_benchmark_1_2['4.2.2']['Status'] = False

        # CIS Section 4.3.1 FSS Checks
        # Generating list of FSS names
        for file_system in self.__file_storage_system:
            if 'kms_key_id' in file_system:
                if not(file_system['kms_key_id']):
                    self.cis_foundations_benchmark_1_2['4.3.1']['Findings'].append(
                        file_system)
                    self.cis_foundations_benchmark_1_2['4.3.1']['Status'] = False

        # CIS Section 5 Checks
        # Checking if more than one compartment because of the ManagedPaaS Compartment
        if len(self.__compartments) < 2:
            self.cis_foundations_benchmark_1_2['5.1']['Status'] = False

        if len(self.__resources_in_root_compartment) > 0:
            for item in self.__resources_in_root_compartment:
                self.cis_foundations_benchmark_1_2['5.2']['Status'] = False
                self.cis_foundations_benchmark_1_2['5.2']['Findings'].append(
                    item)

    ##########################################################################
    # Recursive function the gets the child compartments of a compartment
    ##########################################################################    
    
    def __get_children(self,parent, compartments):
        try:
            kids = compartments[parent]
        except:
            kids = []

        if kids:
            for kid in compartments[parent]:
                kids = kids + self.__get_children(kid, compartments)

        return kids


    ##########################################################################
    # Analyzes Tenancy Data for Oracle Best Practices Report
    ##########################################################################
    def __obp_analyze_tenancy_data(self):
        
        #######################################
        ### Budget Checks
        #######################################
        ## Determines if a Budget Exists with an alert rule
        if len(self.__budgets) > 0:
            for budget in self.__budgets:
                if budget['alert_rule_count'] > 0:
                    self.obp_foundations_checks['Cost_Tracking_Budgets']['Status'] = True
                    self.obp_foundations_checks['Cost_Tracking_Budgets']['OBP'].append(budget)
                else:
                    self.obp_foundations_checks['Cost_Tracking_Budgets']['Findings'].append(budget)

        # Stores Regional Checks 
        for region_key, region_values in self.__regions.items():
            self.__obp_regional_checks[region_key] = {"Audit" : {"tenancy_level_audit" : False, "tenancy_level_include_sub_comps" : False, "compartments" : [], "findings" : []}, 
                                               "VCN" :  {"subnets" : [], "findings" : []}, 
                                               "Write_Bucket" : {"buckets" : [], "findings" : []},
                                               "Read_Bucket" : {"buckets" : [], "findings" : []},
                                               "Network_Connectivity" : {"drgs" : [], "findings" : [], "status" : False},
                                               }

        #######################################
        ### OCI Audit Log Compartments Checks
        #######################################
        list_of_all_compartments = []
        dict_of_compartments = {}
        for compartment in self.__compartments:
            list_of_all_compartments.append(compartment.id)
        
        # Building a Hash Table of Parent Child Hieracrchy for Audit
        dict_of_compartments = {}
        for compartment in self.__compartments:
            if "tenancy" not in compartment.id:
                try:
                    dict_of_compartments[compartment.compartment_id].append(compartment.id)
                except:
                    dict_of_compartments[compartment.compartment_id] = []
                    dict_of_compartments[compartment.compartment_id].append(compartment.id)
    
        # This is used for comparing compartments that are audit to the full list of compartments
        set_of_all_compartments = set(list_of_all_compartments)

        ## Collecting Servie Connectors Logs related to compartments
        for sch_id, sch_values in self.__service_connectors.items():
            # Only Active SCH with a target that is configured
            if sch_values['lifecycle_state'].upper() == "ACTIVE" and sch_values['target_kind']:
                for source in sch_values['log_sources']:
                    try:
                        # Checking if a the compartment being logged is the Tenancy and it has all child compartments
                        if source['compartment_id'] == self.__tenancy.id and source['log_group_id'].upper() == "_Audit_Include_Subcompartment".upper():
                            self.__obp_regional_checks[sch_values['region']]['Audit']['tenancy_level_audit'] = True
                            self.__obp_regional_checks[sch_values['region']]['Audit']['tenancy_level_include_sub_comps'] = True
                        # Since it is not the Tenancy we should add the compartment to the list and check if sub compartment are included
                        elif source['log_group_id'].upper() == "_Audit_Include_Subcompartment".upper():
                            self.__obp_regional_checks[sch_values['region']]['Audit']['compartments'] = self.__get_children(source['compartment_id'],dict_of_compartments) + self.__obp_regional_checks[sch_values['region']]['Audit']['compartments']
                        elif source['log_group_id'].upper() == "_Audit".upper():
                            self.__obp_regional_checks[sch_values['region']]['Audit']['compartments'].append(source['compartment_id'])
                    except:
                        # There can be empty log groups
                        pass
        ## Analyzing Service Connector Audit Logs to see if each region has all compartments
        for region_key, region_values in self.__obp_regional_checks.items():
            # Checking if I already found the tenancy ocid with all child compartments included
            if not region_values['Audit']['tenancy_level_audit']:
                audit_findings = set_of_all_compartments - set(region_values['Audit']['compartments'])
                # If there are items in the then it is not auditing everything in the tenancy
                if audit_findings:
                    region_values['Audit']['findings'] = region_values['Audit']['findings'] + list(audit_findings)
                else:
                    region_values[region_key]['Audit']['tenancy_level_audit'] = True
        
        ## Consolidating Audit findings into the OBP Checks
        for region_key, region_values in self.__obp_regional_checks.items():
            # If this flag is set all compartments are not logged in region
            if not region_values['Audit']['tenancy_level_audit']:
                self.obp_foundations_checks['SIEM_Audit_Log_All_Comps']['Status'] = False
            
            # If this flag is set the region has the tenancy logging and all sub compartments flag checked
            if not region_values['Audit']['tenancy_level_include_sub_comps']:
                self.obp_foundations_checks['SIEM_Audit_Incl_Sub_Comp']['Status'] = False
                self.obp_foundations_checks['SIEM_Audit_Incl_Sub_Comp']['Findings'].append({"region_name" : region_key})
            else:
                self.obp_foundations_checks['SIEM_Audit_Incl_Sub_Comp']['OBP'].append({"region_name" : region_key})

            # Compartment Logs that are missed in the region
            for compartment in region_values['Audit']['findings']:
                try:
                    finding = list(filter(lambda source: source['id']== compartment, self.__raw_compartment ))[0]
                except Exception as e:
                    finding = {                
                        "id" : compartment,
                        "name" : "Compartment No Longer Exists",
                        "deep_link": "",
                        "compartment_id": "(root)",
                        "defined_tags": "",
                        "description": str(e),
                        "freeform_tags": "",
                        "inactive_status": "",
                        "is_accessible": "",
                        "lifecycle_state": "",
                        "time_created": "",
                        "region" : ""
                    }
                finding['region'] = region_key
                self.obp_foundations_checks['SIEM_Audit_Log_All_Comps']['Findings'].append(finding)
            # Compartment logs that are not missed in the region
            for compartment in region_values['Audit']['compartments']:
                try:
                    finding = list(filter(lambda source: source['id']== compartment, self.__raw_compartment ))[0]
                except Exception as e:
                    finding = {                
                        "id" : compartment,
                        "name" : "Compartment No Longer Exists",
                        "deep_link": "",
                        "compartment_id": "(root)",
                        "defined_tags": "",
                        "description": str(e),
                        "freeform_tags": "",
                        "inactive_status": "",
                        "is_accessible": "",
                        "lifecycle_state": "",
                        "time_created": "",
                        "region" : ""
                    }                
                    finding['region'] = region_key
                self.obp_foundations_checks['SIEM_Audit_Log_All_Comps']['OBP'].append(finding)

        
        
        #######################################
        ### Subnet and Bucket Log Checks
        #######################################
        for sch_id, sch_values in self.__service_connectors.items():
            # Only Active SCH with a target that is configured
            ### Subnet Logs Checks

            for subnet_id, log_values in self.__subnet_logs.items():
                
                log_id = log_values['log_id']
                log_group_id = log_values['log_group_id']

                subnet_log_group_in_sch = list(filter(lambda source: source['log_group_id'] == log_group_id, sch_values['log_sources'] ))
                subnet_log_in_sch = list(filter(lambda source: source['log_id'] == log_id, sch_values['log_sources'] ))

                # Checking if the Subnet's log id in is in the service connector's log sources if so I will add it
                if subnet_log_in_sch:
                    self.__obp_regional_checks[sch_values['region']]['VCN']['subnets'].append(subnet_id)
                    
                # Checking if the Subnets's log group in is in SCH's log sources & the log_id is empty so it covers everything in the log group 
                elif  subnet_log_group_in_sch and not(subnet_log_group_in_sch[0]['log_id']):
                    self.__obp_regional_checks[sch_values['region']]['VCN']['subnets'].append(subnet_id)

                else:
                    self.__obp_regional_checks[sch_values['region']]['VCN']['findings'].append(subnet_id)

            ### Bucket Write Logs Checks

            for bucket_name, log_values in self.__write_bucket_logs.items():
                log_id = log_values['log_id']
                log_group_id = log_values['log_group_id']

                bucket_log_group_in_sch = list(filter(lambda source: source['log_group_id'] == log_group_id, sch_values['log_sources'] ))
                bucket_log_in_sch = list(filter(lambda source: source['log_id'] == log_id, sch_values['log_sources']))

                # Checking if the Bucket's log Group in is in the service connector's log sources if so I will add it
                if bucket_log_in_sch:
                    self.__obp_regional_checks[sch_values['region']]['Write_Bucket']['buckets'].append(bucket_name)

                # Checking if the Bucket's log group in is in SCH's log sources & the log_id is empty so it covers everything in the log group 
                elif bucket_log_group_in_sch and not(bucket_log_group_in_sch[0]['log_id']):
                    self.__obp_regional_checks[sch_values['region']]['Write_Bucket']['buckets'].append(bucket_name)
                
                else:
                    self.__obp_regional_checks[sch_values['region']]['Write_Bucket']['findings'].append(bucket_name)
            
            ### Bucket Read Log Checks

            for bucket_name, log_values in self.__read_bucket_logs.items():

                log_id = log_values['log_id']
                log_group_id = log_values['log_group_id']

                bucket_log_group_in_sch = list(filter(lambda source: source['log_group_id'] == log_group_id, sch_values['log_sources'] ))
                bucket_log_in_sch = list(filter(lambda source: source['log_id'] == log_id, sch_values['log_sources']))  

                # Checking if the Bucket's log id in is in the service connector's log sources if so I will add it
                if bucket_log_in_sch:
                    self.__obp_regional_checks[sch_values['region']]['Read_Bucket']['buckets'].append(bucket_name)

                # Checking if the Bucket's log group in is in SCH's log sources & the log_id is empty so it covers everything in the log group 
                elif bucket_log_group_in_sch and not(bucket_log_group_in_sch[0]['log_id']):
                    self.__obp_regional_checks[sch_values['region']]['Read_Bucket']['buckets'].append(bucket_name)

                else:
                    self.__obp_regional_checks[sch_values['region']]['Read_Bucket']['findings'].append(bucket_name)

        
        ### Consolidating regional SERVICE LOGGING findings into centralized finding report 
        for region_key, region_values in self.__obp_regional_checks.items():
            for finding in region_values['VCN']['findings']:
                missing_subnet = list(filter(lambda subnet: subnet['id'] == finding, self.__network_subnets ))
                if missing_subnet:
                    self.obp_foundations_checks['SIEM_VCN_Flow_Logging']['Findings'].append(missing_subnet[0])
                else:
                    print("Missed this subnet: " + str(finding ))

            for finding in region_values['VCN']['subnets']:
                logged_subnet = list(filter(lambda subnet: subnet['id'] == finding, self.__network_subnets ))
                if logged_subnet:
                    self.obp_foundations_checks['SIEM_VCN_Flow_Logging']['OBP'].append(logged_subnet[0])
                else:
                    print("Found this subnet: " + str(finding))

            for finding in region_values['Write_Bucket']['findings']:
                missing_bucket = list(filter(lambda bucket: bucket['name'] == finding, self.__buckets ))
                if missing_bucket:
                    self.obp_foundations_checks['SIEM_Write_Bucket_Logs']['Findings'].append(missing_bucket[0])

            for finding in region_values['Write_Bucket']['buckets']:
                logged_bucket = list(filter(lambda bucket: bucket['name'] == finding, self.__buckets ))
                if logged_bucket:
                    self.obp_foundations_checks['SIEM_Write_Bucket_Logs']['OBP'].append(logged_bucket[0])

            for finding in region_values['Read_Bucket']['findings']:
                missing_bucket = list(filter(lambda bucket: bucket['name'] == finding, self.__buckets ))
                if missing_bucket:
                    self.obp_foundations_checks['SIEM_Read_Bucket_Logs']['Findings'].append(missing_bucket[0])

            for finding in region_values['Read_Bucket']['buckets']:
                logged_bucket = list(filter(lambda bucket: bucket['name'] == finding, self.__buckets ))
                if logged_bucket:
                    self.obp_foundations_checks['SIEM_Read_Bucket_Logs']['OBP'].append(logged_bucket[0])

        
        ## Adding Findings Unlogged items 
        self.obp_foundations_checks['SIEM_Write_Bucket_Logs']['Findings'] += self.cis_foundations_benchmark_1_2['3.17']['Findings']
        unlogged_read_buckets = []
        # Finding buckets that don't have read logging enable to add them to the findings
        for bucket in self.__buckets:
            if not(bucket['name'] in self.__read_bucket_logs):
                unlogged_read_buckets.append(bucket)
        self.obp_foundations_checks['SIEM_Read_Bucket_Logs']['Findings'] += unlogged_read_buckets
        ### Adding in Merging in CIS Finding
        self.obp_foundations_checks['SIEM_VCN_Flow_Logging']['Findings'] += self.cis_foundations_benchmark_1_2['3.14']['Findings']



        # Setting VCN Flow Logs Findings
        if self.obp_foundations_checks['SIEM_VCN_Flow_Logging']['Findings']:
            self.obp_foundations_checks['SIEM_VCN_Flow_Logging']['Status'] = False
        elif not self.__service_connectors:
            # If there are no service connectors then by default all subnets are not logged
            self.obp_foundations_checks['SIEM_VCN_Flow_Logging']['Status'] = False
            self.obp_foundations_checks['SIEM_VCN_Flow_Logging']['Findings'] += self.__network_subnets
        else:
            self.obp_foundations_checks['SIEM_VCN_Flow_Logging']['Status'] = True

        ## Setting Write Bucket Findings
        if self.obp_foundations_checks['SIEM_Write_Bucket_Logs']['Findings']:
            self.obp_foundations_checks['SIEM_Write_Bucket_Logs']['Status'] = False

        elif not self.__service_connectors:
            # If there are no service connectors then by default all buckets are not logged
            self.obp_foundations_checks['SIEM_Write_Bucket_Logs']['Status'] = False
            self.obp_foundations_checks['SIEM_Write_Bucket_Logs']['Findings'] += self.__buckets

        else:
            self.obp_foundations_checks['SIEM_Write_Bucket_Logs']['Status'] = True

        ## Setting Read Bucket Findings
        if self.obp_foundations_checks['SIEM_Read_Bucket_Logs']['Findings']:
            self.obp_foundations_checks['SIEM_Read_Bucket_Logs']['Status'] = False


        elif not self.__service_connectors:
            # If there are no service connectors then by default all buckets are not logged
            self.obp_foundations_checks['SIEM_Read_Bucket_Logs']['Status'] = False
            self.obp_foundations_checks['SIEM_Read_Bucket_Logs']['Findings'] += self.__buckets
        else:
            self.obp_foundations_checks['SIEM_Read_Bucket_Logs']['Status'] = True


        #######################################
        ### OBP Networking Checks 
        #######################################

        ### Fast Connect Connections 

        for drg_id, drg_values in self.__network_drg_attachments.items():
            number_of_valid_connected_vcns = 0
            number_of_valid_fast_connect_circuits = 0
            number_of_valid_site_to_site_connection = 0
            
            fast_connect_providers = set()
            customer_premises_equipment = set()
            

            for attachment in drg_values:
                if attachment['network_type'].upper() == 'VCN':
                    # Checking if DRG has a valid VCN attached to it
                    number_of_valid_connected_vcns += 1 

                elif attachment['network_type'].upper() == 'IPSEC_TUNNEL':
                    # Checking if the IPSec Connection has both tunnels up
                    for ipsec_connection in self.__network_ipsec_connections[drg_id]:
                        if ipsec_connection['tunnels_up']:
                            # Good IP Sec Connection increment valid site to site and track CPEs 
                            customer_premises_equipment.add(ipsec_connection['cpe_id'])
                            number_of_valid_site_to_site_connection +=1
                            

                elif attachment['network_type'].upper() == 'VIRTUAL_CIRCUIT':
                        
                    # Checking for Provision and BGP enabled Virtual Circuits and that it is associated 
                    for virtual_circuit in self.__network_fastconnects[attachment['drg_id']]:
                        if attachment['network_id'] == virtual_circuit['id']:
                            if virtual_circuit['lifecycle_state'].upper() == 'PROVISIONED' and virtual_circuit['bgp_session_state'].upper() == "UP":
                                # Good VC to increment number of VCs and append the provider name
                                fast_connect_providers.add(virtual_circuit['provider_name'])
                                number_of_valid_fast_connect_circuits += 1

            try:
                record = {
                    "drg_id" : drg_id,
                    "drg_display_name" : self.__network_drgs[drg_id]['display_name'],
                    "region" : self.__network_drgs[drg_id]['region'],
                    "number_of_connected_vcns" : number_of_valid_connected_vcns,
                    "number_of_customer_premises_equipment" : len(customer_premises_equipment),
                    "number_of_connected_ipsec_connections" : number_of_valid_site_to_site_connection,
                    "number_of_fastconnects_cicruits" : number_of_valid_fast_connect_circuits,
                    "number_of_fastconnect_providers" : len(fast_connect_providers),
                }
            except:
                record = {
                    "drg_id" : drg_id,
                    "drg_display_name" : "Deleted with an active attachement",
                    "region" : attachment['region'],
                    "number_of_connected_vcns" : 0,
                    "number_of_customer_premises_equipment" : 0,
                    "number_of_connected_ipsec_connections" : 0,
                    "number_of_fastconnects_cicruits" : 0,
                    "number_of_fastconnect_providers" : 0,
                }
                print(f"This DRG: {drg_id} is deleted with an active attachement: {attachment['display_name']}")

            #Checking if the DRG and connected resourcs are aligned with best practices
            # One attached VCN, One VPN connection and one fast connect
            if number_of_valid_connected_vcns and number_of_valid_site_to_site_connection and number_of_valid_fast_connect_circuits:
                self.__obp_regional_checks[record['region']]["Network_Connectivity"]["drgs"].append(record)
                self.__obp_regional_checks[record['region']]["Network_Connectivity"]["status"] = True
            # Two VPN site to site connections to seperate CPEs
            elif number_of_valid_connected_vcns and number_of_valid_site_to_site_connection and len(customer_premises_equipment) >= 2:
                self.__obp_regional_checks[record['region']]["Network_Connectivity"]["drgs"].append(record)
                self.__obp_regional_checks[record['region']]["Network_Connectivity"]["status"] = True
            # Two FastConnects from Different providers
            elif number_of_valid_connected_vcns and number_of_valid_fast_connect_circuits and len(fast_connect_providers) >= 2:
                self.__obp_regional_checks[record['region']]["Network_Connectivity"]["drgs"].append(record)
                self.__obp_regional_checks[record['region']]["Network_Connectivity"]["status"] = True
            else:
                self.__obp_regional_checks[record['region']]["Network_Connectivity"]["findings"].append(record)


        ### Consolidating Regional
        
        for region_key, region_values in self.__obp_regional_checks.items():
            # I assume you are well connected in all regions if find one region that is not it fails
            if not region_values["Network_Connectivity"]["status"]:
                self.obp_foundations_checks['Networking_Connectivity']['Status'] = False
            
            self.obp_foundations_checks["Networking_Connectivity"]["Findings"] += region_values["Network_Connectivity"]["findings"]
            self.obp_foundations_checks["Networking_Connectivity"]["OBP"] += region_values["Network_Connectivity"]["drgs"]

        #######################################
        ### Cloud Guard Checks
        ####################################### 
        cloud_guard_record = {
            "cloud_guard_endable" :  True  if self.__cloud_guard_config_status == 'ENABLED' else False,
            "target_at_root" : False,
            "targert_configuration_detector" : False,
            "targert_configuration_detector_customer_owned" : False,
            "target_activity_detector" : False,
            "target_activity_detector_customer_owned" : False,
            "target_threat_detector" : False,
            "target_threat_detector_customer_owned" : False,
            "target_responder_recipes" : False,
            "target_responder_recipes_customer_owned" : False,
            "target_responder_event_rule" : False,
        }
        
        try:
            # Cloud Guard Target attached to the root compartment with activity, config, and threat detector plus a responder
            if self.__cloud_guard_targets[self.__tenancy.id]:
                
                cloud_guard_record['target_at_root'] = True


                if self.__cloud_guard_targets[self.__tenancy.id]:
                    if self.__cloud_guard_targets[self.__tenancy.id]['target_detector_recipes']:
                        for recipe in self.__cloud_guard_targets[self.__tenancy.id]['target_detector_recipes']:
                            if recipe.detector.upper() == 'IAAS_CONFIGURATION_DETECTOR':
                                cloud_guard_record['targert_configuration_detector'] = True
                                if recipe.owner.upper() == "CUSTOMER":
                                    cloud_guard_record['targert_configuration_detector_customer_owned'] = True


                            elif recipe.detector.upper() == 'IAAS_ACTIVITY_DETECTOR':
                                cloud_guard_record['target_activity_detector'] = True
                                if recipe.owner.upper() == "CUSTOMER":
                                    cloud_guard_record['target_activity_detector_customer_owned'] = True

                            elif recipe.detector.upper() == 'IAAS_THREAT_DETECTOR':
                                cloud_guard_record['target_threat_detector'] = True
                                if recipe.owner.upper() == "CUSTOMER":
                                    cloud_guard_record['target_threat_detector_customer_owned'] = True


                    if self.__cloud_guard_targets[self.__tenancy.id]['target_responder_recipes']:
                        cloud_guard_record['target_responder_recipes'] = True
                        for recipe in self.__cloud_guard_targets[self.__tenancy.id]['target_responder_recipes']:
                            if recipe.owner.upper() == 'CUSTOMER':
                                cloud_guard_record['target_responder_recipes_customer_owned'] = True

                            for rule in recipe.effective_responder_rules:
                                if rule.responder_rule_id.upper() == 'EVENT' and rule.details.is_enabled:
                                    cloud_guard_record['target_responder_event_rule'] = True

                    cloud_guard_record['target_id'] = self.__cloud_guard_targets[self.__tenancy.id]['id']    
                    cloud_guard_record['target_name'] = self.__cloud_guard_targets[self.__tenancy.id]['display_name']             
        
        except:
            pass

        all_cloud_guard_checks = True
        for key,value in cloud_guard_record.items():
            if not(value):
                all_cloud_guard_checks = False
        
        self.obp_foundations_checks['Cloud_Guard_Config']['Status'] = all_cloud_guard_checks
        if all_cloud_guard_checks:
            self.obp_foundations_checks['Cloud_Guard_Config']['OBP'].append(cloud_guard_record)
        else:
            self.obp_foundations_checks['Cloud_Guard_Config']['Findings'].append(cloud_guard_record)



    ##########################################################################
    # Orchestrates data collection and CIS report generation
    ##########################################################################

    def __report_generate_cis_report(self, level):
        # This function reports generates CSV reportsffo

        # Creating summary report
        summary_report = []
        for key, recommendation in self.cis_foundations_benchmark_1_2.items():
            if recommendation['Level'] <= level:
                report_filename = "cis" + " "+ recommendation['section'] + "_" + recommendation['recommendation_#']
                report_filename = report_filename.replace(" ", "_").replace(".", "-").replace("_-_","_") + ".csv"
                if recommendation['Status']:
                    compliant_output = "Yes"
                elif recommendation['Status'] is None:
                    compliant_output = "Not Applicable"
                else:
                    compliant_output = "No"
                record = {
                    "Recommendation #": f"'{key}'", 
                    "Section": recommendation['section'],
                    "Level": str(recommendation['Level']),
                    "Compliant": compliant_output if compliant_output != "Not Applicable" else "N/A",
                    "Findings": (str(len(recommendation['Findings'])) if len(recommendation['Findings']) > 0 else " "),
                    "Title": recommendation['Title'],
                    "CIS v8": recommendation['CISv8'],
                    "CCCS Guard Rail": recommendation['CCCS Guard Rail'],
                    "Filename" : report_filename if len(recommendation['Findings']) > 0 else " ",
                    "Remediation" : self.cis_report_data[key]['Remediation']
                }
                # Add record to summary report for CSV output
                summary_report.append(record)
            
            # Generate Findings report
            # self.__print_to_csv_file("cis", recommendation['section'] + "_" + recommendation['recommendation_#'], recommendation['Findings'] )

        # Screen output for CIS Summary Report
        print_header("CIS Foundations Benchmark 1.2 Summary Report")
        print('Num' + "\t" + "Level " +
              "\t" "Compliant" + "\t" + "Findings  " + "\t" + 'Title')
        print('#' * 90)
        for finding in summary_report:
            # If print_to_screen is False it will only print non-compliant findings
            if not(self.__print_to_screen) and finding['Compliant'] == 'No':
                print(finding['Recommendation #'] + "\t" +
                      finding['Level'] + "\t" + finding['Compliant'] + "\t\t" +
                      finding['Findings'] + "\t\t" + finding['Title'])
            elif self.__print_to_screen:
                print(finding['Recommendation #'] + "\t" +
                      finding['Level'] + "\t" + finding['Compliant'] + "\t\t" +
                      finding['Findings'] + "\t\t" + finding['Title'])

        # Generating Summary report CSV
        print_header("Writing CIS reports to CSV")
        summary_file_name = self.__print_to_csv_file(
            self.__report_directory, "cis", "summary_report", summary_report)
        
        self.__report_generate_html_summary_report(
            self.__report_directory, "cis", "html_summary_report", summary_report)
                        
        # Outputting to a bucket if I have one
        if summary_file_name and self.__output_bucket:
            self.__os_copy_report_to_object_storage(
                self.__output_bucket, summary_file_name)
        
        for key, recommendation in self.cis_foundations_benchmark_1_2.items():
            if recommendation['Level'] <= level:
                report_file_name = self.__print_to_csv_file(
                    self.__report_directory, "cis", recommendation['section'] + "_" + recommendation['recommendation_#'], recommendation['Findings'])
                if report_file_name and self.__output_bucket:
                    self.__os_copy_report_to_object_storage(
                        self.__output_bucket, report_file_name)

    
    ##########################################################################
    # Generates an HTML report
    ##########################################################################
    def __report_generate_html_summary_report(self, report_directory, header, file_subject, data):
        try:
            # Creating report directory
            if not os.path.isdir(report_directory):
                os.mkdir(report_directory)

        except Exception as e:
            raise Exception(
                "Error in creating report directory: " + str(e.args))

        try:
            # if no data
            if len(data) == 0:
                return None
            
            # get the file name of the CSV
            
            file_name = header + "_" + file_subject
            file_name = (file_name.replace(" ", "_")
                         ).replace(".", "-").replace("_-_","_") + ".html"
            file_path = os.path.join(report_directory, file_name)

            # add report_datetimeto each dictionary
            result = [dict(item, extract_date=self.start_time_str)
                      for item in data]


            # If this flag is set all OCIDs are Hashed to redact them
            if self.__redact_output:
                redacted_result = []
                for item in result:
                    record = {}
                    for key in item.keys():
                        str_item = str(item[key])
                        items_to_redact = re.findall(self.__oci_ocid_pattern,str_item)
                        for redact_me in items_to_redact:
                            str_item = str_item.replace(redact_me,hashlib.sha256(str.encode(redact_me)).hexdigest() )
                        
                        record[key] = str_item

                    redacted_result.append(record)
                # Overriding result with redacted result
                result = redacted_result
            

            # generate fields
            fields = ['Recommendation #', 'Compliant', 'Section', 'Details']

            html_title = 'CIS OCI Foundations Benchmark 1.2 - Compliance Report'
            with open(file_path, mode='w') as html_file:
                # Creating table header
                html_file.write('<html class="js history hashchange cssgradients rgba no-touch boxshadow ishttps retina w11ready" lang="en-US"><head>')
                html_file.write('<title>' + html_title + '</title>')
                html_file.write("""<link data-wscss href=\"https://www.oracle.com/asset/web/css/ocom-v1-base.css\" rel=\"stylesheet\">
                <link data-wscss href=\"https://www.oracle.com/asset/web/css/ocom-v1-styles.css\" rel=\"preload\" as=\"style\" onload=\"this.rel='stylesheet'\" onerror=\"this.rel='stylesheet'\">
                <noscript><link href=\"https://www.oracle.com/asset/web/css/ocom-v1-styles.css\" rel=\"stylesheet\"></noscript>
                <link data-wsjs data-reqjq href=\"https://www.oracle.com/asset/web/js/ocom-v1-base.js\" rel=\"preload\" as=\"script\">
                <link data-wsjs data-reqjq href=\"https://www.oracle.com/asset/web/js/ocom-v1-lib.js\" rel=\"preload\" as=\"script\">
                <script data-wsjs src=\"https://www.oracle.com/asset/web/js/jquery-min.js\" async onload=\"$('head link[data-reqjq][rel=preload]').each(function(){var a = document.createElement('script');a.async=false;a.src=$(this).attr('href');this.parentNode.insertBefore(a, this);});$(function(){$('script[data-reqjq][data-src]').each(function(){this.async=true;this.src=$(this).data('src');});});\"></script>
                <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">
                <link rel=\"icon\" href=\"https://www.oracle.com/asset/web/favicons/favicon-32.png\" sizes=\"32x32\">
                <link rel=\"icon\" href=\"https://www.oracle.com/asset/web/favicons/favicon-128.png\" sizes=\"128x128\">
                <link rel=\"icon\" href=\"https://www.oracle.com/asset/web/favicons/favicon-192.png\" sizes=\"192x192\">
                <link rel=\"apple-touch-icon\" href=\"https://www.oracle.com/asset/web/favicons/favicon-120.png\" sizes=\"120x120\">
                <link rel=\"apple-touch-icon\" href=\"https://www.oracle.com/asset/web/favicons/favicon-152.png\" sizes=\"152x152\">
                <link rel=\"apple-touch-icon\" href=\"https://www.oracle.com/asset/web/favicons/favicon-180.png\" sizes=\"180x180\">
                <meta name=\"msapplication-TileColor\" content=\"#fcfbfa\"/><meta name=\"msapplication-square70x70logo\" content=\"favicon-128.png\"/>
                <meta name=\"msapplication-square150x150logo\" content=\"favicon-270.png\"/><meta name=\"msapplication-TileImage\" content=\"favicon-270.png\"/>
                <meta name=\"msapplication-config\" content=\"none\"/><meta name=\"referrer\" content=\"no-referrer-when-downgrade\"/>
                </head><body class=\"f11 f11v6\"><div class=\"f11w1\">
                <style>#u30{opacity:1 !important;filter:opacity(100%) !important;position:sticky;top:0} .u30v3{background:#3a3632;height:50px;overflow:hidden;border-top:5px solid #3a3632;border-bottom:5px solid #3a3632}
                 #u30nav,#u30tools{visibility:hidden} .u30v3 #u30logo {width:121px;height: 44px;display: inline-flex;justify-content: flex-start;} #u30:not(.u30mobile)
                 .u30-oicn-mobile,#u30.u30mobile .u30-oicn{display:none} #u30logo svg{height:auto;align-self:center}
                 .u30brand{height:50px;display:flex;flex-direction:column;justify-content:center;align-items:flex-start;max-width:1344px;padding:0 48px;margin:0 auto}
                 .u30brandw1{display:flex;flex-direction:row;color:#fff;text-decoration:none;align-items:center} @media (max-width:1024px){.u30brand{padding:0 24px}}
                 #u30skip2,#u30skip2content{transform:translateY(-100%);position:fixed} .rtl #u30{direction:rtl}</style>
                <style>	#td_override { background: #fff; border-bottom: 1px solid rgba(122,115,110,0.2) !important }</style>
                <section id=\"u30\" class=\"u30 u30v3 pause\" data-trackas=\"header\" role=\"banner\"><div class=\"u30w1 cwidth\" id=\"u30w1\"><div id=\"u30brand\" class=\"u30brand\"><div class=\"u30brandw1\"><a id=\"u30btitle\" href=\"https://www.oracle.com/\" data-lbl=\"logo\" aria-label=\"Home\"><div id=\"u30logo\"><svg class=\"u30-oicn-mobile\" xmlns=\"http://www.w3.org/2000/svg\" width=\"32\" height=\"21\" viewBox=\"0 0 32 21\"><path fill=\"#C74634\" d=\"M9.9,20.1c-5.5,0-9.9-4.4-9.9-9.9c0-5.5,4.4-9.9,9.9-9.9h11.6c5.5,0,9.9,4.4,9.9,9.9c0,5.5-4.4,9.9-9.9,9.9H9.9 M21.2,16.6c3.6,0,6.4-2.9,6.4-6.4c0-3.6-2.9-6.4-6.4-6.4h-11c-3.6,0-6.4,2.9-6.4,6.4s2.9,6.4,6.4,6.4H21.2\"/></svg><svg class=\"u30-oicn\" xmlns=\"http://www.w3.org/2000/svg\"  width=\"231\" height=\"30\" viewBox=\"0 0 231 30\" preserveAspectRatio=\"xMinYMid\"><path fill=\"#C74634\" d=\"M99.61,19.52h15.24l-8.05-13L92,30H85.27l18-28.17a4.29,4.29,0,0,1,7-.05L128.32,30h-6.73l-3.17-5.25H103l-3.36-5.23m69.93,5.23V0.28h-5.72V27.16a2.76,2.76,0,0,0,.85,2,2.89,2.89,0,0,0,2.08.87h26l3.39-5.25H169.54M75,20.38A10,10,0,0,0,75,.28H50V30h5.71V5.54H74.65a4.81,4.81,0,0,1,0,9.62H58.54L75.6,30h8.29L72.43,20.38H75M14.88,30H32.15a14.86,14.86,0,0,0,0-29.71H14.88a14.86,14.86,0,1,0,0,29.71m16.88-5.23H15.26a9.62,9.62,0,0,1,0-19.23h16.5a9.62,9.62,0,1,1,0,19.23M140.25,30h17.63l3.34-5.23H140.64a9.62,9.62,0,1,1,0-19.23h16.75l3.38-5.25H140.25a14.86,14.86,0,1,0,0,29.71m69.87-5.23a9.62,9.62,0,0,1-9.26-7h24.42l3.36-5.24H200.86a9.61,9.61,0,0,1,9.26-7h16.76l3.35-5.25h-20.5a14.86,14.86,0,0,0,0,29.71h17.63l3.35-5.23h-20.6\" transform=\"translate(-0.02 0)\" /></svg></div></a></div></div></div></section><section class="cb132 cb132v0 cpad"><div class="cb133 cwidth">""")
                html_file.write('<h5 id="table_top">' + html_title.replace('-', '&ndash;') + '</h5>')
                html_file.write('<h4>Tenancy Name: ' + self.__tenancy.name + '</h4>')
                # Get the extract date
                r = result[0]
                extract_date = r['extract_date'].replace('T',' ')
                html_file.write('<h3>Extract Date: ' + extract_date + ' UTC</h3>')
                html_file.write('</div></section><section class="cb133 cb133v0 cpad"><div class="cb133w1 cwidth"><div class="otable otable-scrolling"><div class="otable-w1">')
                html_file.write('<table class="otable-w2"><thead><tr>')
                for th in fields:
                    column_width = '63%'
                    if th == 'extract_date':
                        th = th.replace('_', ' ').title()
                        continue
                    elif th == 'Recommendation #':
                        column_width = '15%'
                    elif th == 'Compliant':
                        column_width = '10%'
                    elif th == 'Section':
                        column_width = '12%'
                    else:
                        column_width = '63%'
                    html_file.write('<th class="otable-col-head" style=" width:' + column_width + ';">' + th + '</th>')
                html_file.write('</tr></thead><tbody>')
                # Creating HTML Table of the summary report
                html_appendix = []
                for row in result:
                    compliant = row['Compliant']
                    text_color = 'green'
                    if compliant == 'No':
                        html_appendix.append(row['Recommendation #'].replace("'",""))
                        text_color = 'red'
                    # Print the row
                    html_file.write("<tr>")
                    v = row['Recommendation #'].replace("'","")
                    if compliant == 'No':
                        html_file.write('<td><a href="#' + v + '">' + v + '</a></td>\n')
                    else:
                        html_file.write('<td>' + v + '</td>\n')
                    html_file.write('<td><b style="color:' + text_color + ';">' + str(compliant) + '</b></td>\n')
                    html_file.write("<td>" + str(row['Section']) + "</td>\n")
                    # Details
                    html_file.write('<td><table><tr><td width="10%"><b>Title</b></td>')
                    html_file.write('<td colspan="3">' + str(row['Title']) + '</td></tr>')
                    html_file.write('<tr><td><b>Remediation</b></td>')
                    html_file.write('<td colspan="3">' + str(row['Remediation']) + '</td></tr>')
                    html_file.write('<tr><td><b>Level</b></td>')
                    html_file.write('<td id="td_override" style="width: 15%;"><b>CIS v8</b></td>')
                    html_file.write('<td id="td_override" style="width: 20%;"><b>CCCS Guard Rail</b></td>')
                    html_file.write('<td id="td_override" style="width: 55%;"><b>File</b></td></tr>')
                    html_file.write('<tr><td width="">' + str(row['Level']) + '</td>')
                    html_file.write('<td>' + str(row['CIS v8']).replace('[','').replace(']','').replace("'",'') + '</td>')
                    html_file.write('<td>' + str(row['CCCS Guard Rail']) + '</td>')
                    v = str(row['Filename'])
                    if v == ' ':
                        html_file.write('<td> </td>')
                    else:
                        html_file.write('<td><a href="' + v + '">' + v + '</a></td>')
                    html_file.write('</tr></table></td>')
                    html_file.write("</tr>")

                html_file.write("</tbody></table></div></div></section>\n")
                html_file.write('<section class="cb132 cb132v0 cpad"><div class="cb132w1 cwidth">')
                # Creating appendix for the report
                for finding in html_appendix:
                    html_file.write(f'<hr id="{finding}" /><h5>{finding} &ndash; {self.cis_foundations_benchmark_1_2[finding]["Title"]}</h5>\n')
                    for item_key, item_value in self.cis_report_data[finding].items():
                        if item_value != "":
                            html_file.write(f"<h4>{item_key.title()}</h4>")
                            if item_key == 'Observation':
                                html_file.write(f"<p><b>{str(len(self.cis_foundations_benchmark_1_2[finding]['Findings']))}</b> {item_value}</p>\n")
                            else:
                                v = item_value.replace('<pre>', '<pre style="font-size: 1.4rem;">')
                                html_file.write(f"<p>{v}</p>\n")
                html_file.write("</div></section>\n")
                # Closing HTML
                html_file.write("""<div class="u10 u10v6"><nav class="u10w1" aria-label="Main footer">
                <div class="u10w2"><div class="u10w3" aria-labelledby="resourcesfor"><a class="u10btn" tabindex="-1" aria-labelledby="resourcesfor"></a>
                <h4 class="u10ttl" id="resourcesfor">Resources</h4><ul>
                <li><a href="https://www.cisecurity.org/benchmark/Oracle_Cloud">CIS OCI Foundation Benchmark</a></li>
                <li><a href="https://docs.oracle.com/en/solutions/cis-oci-benchmark/index.html">Deploy a secure landing zone that meets the CIS Foundations Benchmark for Oracle Cloud</a></li>
                <li><a href="https://docs.oracle.com/en/solutions/oci-security-checklist/index.html">Security checklist for Oracle Cloud Infrastructure</a></li>
                <li><a href="https://docs.oracle.com/en-us/iaas/Content/Security/Concepts/security.htm">OCI Documentation – Securely configure your Oracle Cloud Infrastructure services and resources</a></li>
                <li><a href="https://docs.oracle.com/en/solutions/oci-best-practices/index.html">Best practices framework for Oracle Cloud Infrastructure</a></li>
                <li><a href="https://www.oracle.com/uk/security/cloud-security/what-is-cspm/">Cloud Security Posture Management</a></li>
                </ul></div></div><div class="u10w4"><hr></div></nav>
                <div class="u10w11"><nav class="u10w5 u10w10" aria-label="Site info">
                <ul class="u10-links"><li></li><li><a href="https://www.oracle.com/legal/copyright.html">© 2023 Oracle</a></li>
                </ul></nav></div>""")
                html_file.write("</div></div></body></html>\n")

            print("HTML: " + file_subject.ljust(22) + " --> " + file_path)
            # Used by Upload
               
            return file_path
           
        except Exception as e:
            raise Exception("Error in report_generate_html_report: " + str(e.args))
        
    ##########################################################################
    # Orchestrates analysis and report generation
    ##########################################################################
    def __report_generate_obp_report(self):

        obp_summary_report = []
        # Screen output for CIS Summary Report
        print_header("OCI Best Practices Findings")
        print('Category' + "\t\t\t\t" + "Compliant" + "\t" + "Findings  ")
        print('#' * 90)
        # Adding data to summary report
        for key, recommendation in self.obp_foundations_checks.items():
            padding = str(key).ljust(25, " ")
            print(padding + "\t\t" + str(recommendation['Status']) + "\t" + "\t" + str(len(recommendation['Findings'])))
            record = {
                "Recommendation" : str(key),
                "Compliant": ('Yes' if recommendation['Status'] else 'No'),
                "Findings" : (str(len(recommendation['Findings'])) if len(recommendation['Findings']) > 0 else " "),
                "Documentation" : recommendation['Documentation']
            }
            obp_summary_report.append(record)

        print_header("Writing Oracle Best Practices reports to CSV")

        summary_report_file_name = self.__print_to_csv_file(
                    self.__report_directory, "obp", "OBP_Summary", obp_summary_report)
        
        if summary_report_file_name and self.__output_bucket:
                    self.__os_copy_report_to_object_storage(
                        self.__output_bucket, summary_report_file_name)
        
        ## Printing Findings to CSV
        for key, value in self.obp_foundations_checks.items():
            report_file_name = self.__print_to_csv_file(
                    self.__report_directory, "obp", key + "_Findings", value['Findings'])

        ## Printing OBPs to CSV
        for key, value in self.obp_foundations_checks.items():
            report_file_name = self.__print_to_csv_file(
                    self.__report_directory, "obp", key + "_Best_Practices", value['OBP'])

            if report_file_name and self.__output_bucket:
                    self.__os_copy_report_to_object_storage(
                        self.__output_bucket, report_file_name)

    ##########################################################################
    # Coordinates calls of all the read function required for analyzing tenancy
    ##########################################################################
    def __collect_tenancy_data(self):
        
        ######  Runs identity functions only in home region
        

        thread_compartments =  Thread(target = self.__identity_read_compartments)
        thread_compartments.start()

        thread_identity_groups = Thread( target = self.__identity_read_groups_and_membership)
        thread_identity_groups.start()
        

        thread_compartments.join()
        thread_identity_groups.join()

        

        print("Processing Home Region resources...")


        cis_home_region_functions = [
            self.__identity_read_users,
            self.__identity_read_tenancy_password_policy,
            self.__identity_read_dynamic_groups,
            self.__audit_read_tenancy_audit_configuration,
            self.__identity_read_availability_domains,
            self.__identity_read_tag_defaults,
            self.__identity_read_tenancy_policies,
        ]

        # Budgets is global construct 
        if self.__obp_checks:
            self.__cloud_guard_read_cloud_guard_configuration()
            obp_home_region_functions = [
                self.__budget_read_budgets,
                self.__cloud_guard_read_cloud_guard_targets
            ]
        else:
            obp_home_region_functions = []

        # Threads for Home region checks
        home_threads = []        
        for home_func in cis_home_region_functions + obp_home_region_functions:
            t = Thread(target = home_func)
            t.start()
            home_threads.append(t)
        
        # Waiting for home threads to complete
        for t in home_threads:
            t.join()


        # The above checks are run in the home region 
        if self.__home_region not in self.__regions_to_run_in and not(self.__run_in_all_regions):
            self.__regions.pop(self.__home_region)
        

        print("Processing regional resources...")
        # Stores running threads
        regional_threads = []
        # List of functions for CIS 
        cis_regional_functions = [
            self.__search_resources_in_root_compartment,
            self.__vault_read_vaults,
            self.__os_read_buckets,
            self.__logging_read_log_groups_and_logs,
            self.__events_read_event_rules,
            self.__ons_read_subscriptions,
            self.__network_read_network_security_lists,
            self.__network_read_network_security_groups_rules,
            self.__network_read_network_subnets,
            self.__adb_read_adbs,
            self.__oic_read_oics,
            self.__oac_read_oacs,
            self.__block_volume_read_block_volumes,
            self.__boot_volume_read_boot_volumes,
            self.__fss_read_fsss,
        ]
        
        # Oracle Best practice functions
        if self.__obp_checks:
            obp_functions = [
                self.__network_read_fastonnects,
                self.__network_read_ip_sec_connections,
                self.__network_read_drgs,
                self.__network_read_drg_attachments,
                self.__sch_read_service_connectors,
            ]
        else: 
            obp_functions = []

        # Starting execution of functions
        for func in cis_regional_functions + obp_functions:
            t = Thread(target = func)
            t.start()
            regional_threads.append(t)

        # Waiting for execution of functions
        for t in regional_threads:
            t.join()
        

    ##########################################################################
    # Generate Raw Data Output
    ##########################################################################
    def __report_generate_raw_data_output(self):

        # List to store output reports if copying to object storage is required
        list_report_file_names = []

        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "identity_groups_and_membership", self.__groups_to_users)
        list_report_file_names.append(report_file_name)

        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "identity_users", self.__users)
        list_report_file_names.append(report_file_name)            
        
        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "identity_policies", self.__policies)
        list_report_file_names.append(report_file_name)  

        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "identity_dynamic_groups", self.__dynamic_groups)
        list_report_file_names.append(report_file_name)

        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "identity_tags", self.__tag_defaults)
        list_report_file_names.append(report_file_name)            
        
        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "identity_compartments", self.__raw_compartment)
        list_report_file_names.append(report_file_name)

        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "network_security_groups", self.__network_security_groups)
        list_report_file_names.append(report_file_name)            
        
        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "network_security_lists", self.__network_security_lists)
        list_report_file_names.append(report_file_name)            
        
        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "network_subnets", self.__network_subnets)
        list_report_file_names.append(report_file_name)            
        
        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "autonomous_databases", self.__autonomous_databases)
        list_report_file_names.append(report_file_name)            
        
        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "analytics_instances", self.__analytics_instances)
        list_report_file_names.append(report_file_name)            
        
        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "integration_instances", self.__integration_instances)
        list_report_file_names.append(report_file_name)            
        
        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "event_rules", self.__event_rules)
        list_report_file_names.append(report_file_name)            
        
        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "log_groups_and_logs", self.__logging_list)
        list_report_file_names.append(report_file_name)            
        
        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "object_storage_buckets", self.__buckets)
        list_report_file_names.append(report_file_name)            
        
        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "boot_volumes", self.__boot_volumes)
        list_report_file_names.append(report_file_name)

        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "block_volumes", self.__block_volumes)
        list_report_file_names.append(report_file_name)
        
        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "file_storage_system", self.__file_storage_system)
        list_report_file_names.append(report_file_name)
        
        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "vaults_and_keys", self.__vaults)
        list_report_file_names.append(report_file_name)

        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "ons_subscriptions", self.__subscriptions)
        list_report_file_names.append(report_file_name)

        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "budgets", self.__budgets)
        list_report_file_names.append(report_file_name)
        
        # Converting a one to one dict to a list
        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "service_connectors", list(self.__service_connectors.values()))
        list_report_file_names.append(report_file_name)
        
        # Converting a dict that is one to a list to a flat list
        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "network_fastconnects", list(itertools.chain.from_iterable(self.__network_fastconnects.values())))
        list_report_file_names.append(report_file_name)
        
        # Converting a dict that is one to a list to a flat list
        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "network_ipsec_connections", list(itertools.chain.from_iterable(self.__network_ipsec_connections.values())))
        list_report_file_names.append(report_file_name)

        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "network_drgs", self.__raw_network_drgs)
        list_report_file_names.append(report_file_name)


        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "cloud_guard_target", list(self.__cloud_guard_targets.values()))
        list_report_file_names.append(report_file_name)

        report_file_name = self.__print_to_csv_file(
                self.__report_directory, "raw_data", "regions", self.__raw_regions)
        list_report_file_names.append(report_file_name)


        if self.__output_bucket:
            for raw_report in list_report_file_names:
                if raw_report:
                    self.__os_copy_report_to_object_storage(
                        self.__output_bucket, raw_report)

   
    ##########################################################################
    # Copy Report to Object Storage
    ##########################################################################
    def __os_copy_report_to_object_storage(self, bucketname, filename):
        object_name = filename
        # print(self.__os_namespace)
        try:
            with open(filename, "rb") as f:
                try:
                    self.__output_bucket_client.put_object(
                        self.__os_namespace, bucketname, object_name, f)
                except Exception as e:
                    print("Failed to write " + object_name + " to bucket " + bucketname + ". Please check your bucket and IAM permissions.")

        except Exception as e:
            raise Exception(
                "Error opening file os_copy_report_to_object_storage: " + str(e.args))

    ##########################################################################
    # Print to CSV
    ##########################################################################
    def __print_to_csv_file(self, report_directory, header, file_subject, data):

        try:
            # Creating report directory
            if not os.path.isdir(report_directory):
                os.mkdir(report_directory)

        except Exception as e:
            raise Exception(
                "Error in creating report directory: " + str(e.args))

        try:
            # if no data
            if len(data) == 0:
                return None
            
            # get the file name of the CSV
            
            file_name = header + "_" + file_subject
            file_name = (file_name.replace(" ", "_")
                         ).replace(".", "-").replace("_-_","_") + ".csv"
            file_path = os.path.join(report_directory, file_name)

            # add report_datetimeto each dictionary
            result = [dict(item, extract_date=self.start_time_str)
                      for item in data]


            # If this flag is set all OCIDs are Hashed to redact them
            if self.__redact_output:
                redacted_result = []
                for item in result:
                    record = {}
                    for key in item.keys():
                        str_item = str(item[key])
                        items_to_redact = re.findall(self.__oci_ocid_pattern,str_item)
                        for redact_me in items_to_redact:
                            str_item = str_item.replace(redact_me,hashlib.sha256(str.encode(redact_me)).hexdigest() )
                        
                        record[key] = str_item

                    redacted_result.append(record)
                # Overriding result with redacted result
                result = redacted_result
            

            # generate fields
            fields = [key for key in result[0].keys()]

            with open(file_path, mode='w', newline='') as csv_file:
                writer = csv.DictWriter(csv_file, fieldnames=fields)

                # write header
                writer.writeheader()

                for row in result:
                    writer.writerow(row)
                    #print(row)

            print("CSV: " + file_subject.ljust(22) + " --> " + file_path)
            # Used by Upload
               
            return file_path
           
        except Exception as e:
            raise Exception("Error in print_to_csv_file: " + str(e.args))


    ##########################################################################
    # Orchestrates Data collection and reports
    ##########################################################################

    def generate_reports(self, level=2):
 
        # Collecting all the tenancy data
        self.__collect_tenancy_data()

        # Analyzing Data for CIS reports
        self.__report_cis_analyze_tenancy_data()

        # Generate CIS reports
        self.__report_generate_cis_report(level)

        if self.__obp_checks:
            # Analyzing Data for OBP reports
            self.__obp_analyze_tenancy_data()
            self.__report_generate_obp_report()
        
        if self.__output_raw_data:
            self.__report_generate_raw_data_output()
        
        end_datetime = datetime.datetime.now().replace(tzinfo=pytz.UTC)
        print_header("Finished in: " + str(end_datetime - self.start_datetime))

        return self.__report_directory

    def get_obp_checks(self):
        self.__obp_checks = True
        self.generate_reports()
        return self.obp_foundations_checks

    ##########################################################################
    # Create CSV Hyperlink
    ##########################################################################
    def __generate_csv_hyperlink(self,url, name):
        if len(url) < 255:
            return '=HYPERLINK("' + url + '","' + name +'")'
        else:
            return url


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


def create_signer(file_location, config_profile, is_instance_principals, is_delegation_token, is_security_token):

    # if instance principals authentications
    if is_instance_principals:
        try:
            signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
            config = {'region': signer.region, 'tenancy': signer.tenancy_id}
            return config, signer

        except Exception:
            print("Error obtaining instance principals certificate, aborting")
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
                print(
                    "*** OCI_CONFIG_FILE and OCI_CONFIG_PROFILE env variables not found, abort. ***")
                print("")
                raise SystemExit

            config = oci.config.from_file(env_config_file, env_config_section)
            delegation_token_location = config["delegation_token_file"]

            with open(delegation_token_location, 'r') as delegation_token_file:
                delegation_token = delegation_token_file.read().strip()
                # get signer from delegation token
                signer = oci.auth.signers.InstancePrincipalsDelegationTokenSigner(
                    delegation_token=delegation_token)

                return config, signer

        except KeyError:
            print("* Key Error obtaining delegation_token_file")
            raise SystemExit

        except Exception:
            raise
    # ---------------------------------------------------------------------------
    # Security Token - Credit to Dave Knot (https://github.com/dns-prefetch)
    # ---------------------------------------------------------------------------
    elif is_security_token:

        try:
            # Read the token file from the security_token_file parameter of the .config file
            config = oci.config.from_file(
                oci.config.DEFAULT_LOCATION,
                (config_profile if config_profile else oci.config.DEFAULT_PROFILE)
            )

            token_file = config['security_token_file']
            token = None
            with open(token_file, 'r') as f:
              token = f.read()

            # Read the private key specified by the .config file.
            private_key = oci.signer.load_private_key_from_file(config['key_file'])

            signer = oci.auth.signers.SecurityTokenSigner(token, private_key)

            return config, signer

        except KeyError:
            print("* Key Error obtaining security_token_file")
            raise SystemExit

        except Exception:
            raise

    # -----------------------------
    # config file authentication
    # -----------------------------
    else:
         
        try:
            config = oci.config.from_file(
                file_location if file_location else oci.config.DEFAULT_LOCATION,
                (config_profile if config_profile else oci.config.DEFAULT_PROFILE)
            )
            signer = oci.signer.Signer(
                tenancy=config["tenancy"],
                user=config["user"],
                fingerprint=config["fingerprint"],
                private_key_file_location=config.get("key_file"),
                pass_phrase=oci.config.get_config_value_or_default(
                    config, "pass_phrase"),
                private_key_content=config.get("key_content")
            )
            return config, signer
        except Exception:
            print(
                f'** OCI Config was not found here : {oci.config.DEFAULT_LOCATION} or env varibles missing, aborting **')
            raise SystemExit


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

    # Get Command Line Parser
    parser = argparse.ArgumentParser()
    parser.add_argument('-c', default="", dest='file_location',
                        help='OCI config file location')
    parser.add_argument('-t', default="", dest='config_profile',
                        help='Config file section to use (tenancy profile) ')
    parser.add_argument('-p', default="", dest='proxy',
                        help='Set Proxy (i.e. www-proxy-server.com:80) ')
    parser.add_argument('--output-to-bucket', default="", dest='output_bucket',
                        help='Set Output bucket name (i.e. my-reporting-bucket) ')
    parser.add_argument('--report-directory', default=None, dest='report_directory',
                        help='Set Output report directory by default it is the current date (i.e. reports-date) ')
    parser.add_argument('--print-to-screen', default='True', dest='print_to_screen',
                        help='Set to False if you want to see only non-compliant findings (i.e. False) ')
    parser.add_argument('--level', default=2, dest='level',
                        help='CIS Recommendation Level options are: 1 or 2. Set to 2 by default ')
    parser.add_argument('--regions', default="", dest='regions',
                        help='Regions to run the compliance checks on, by default it will run in all regions. Sample input: us-ashburn-1,ca-toronto-1,eu-frankfurt-1')    
    parser.add_argument('--raw', action='store_true', default=False,
                            help='Outputs all resource data into CSV files')
    parser.add_argument('--obp', action='store_true', default=False,
                            help='Checks for OCI best practices')
    parser.add_argument('--redact_output', action='store_true', default=False,
                            help='Redacts OCIDs in output CSV files')
    parser.add_argument('-ip', action='store_true', default=False,
                        dest='is_instance_principals', help='Use Instance Principals for Authentication ')
    parser.add_argument('-dt', action='store_true', default=False,
                        dest='is_delegation_token', help='Use Delegation Token for Authentication in Cloud Shell' )
    parser.add_argument('-st',  action='store_true', default=False, dest='is_security_token', help='Authenticate using Security Token')
    parser.add_argument('-v', action='store_true', default=False,
                        dest='version', help='Show the version of the script and exit.' )
    cmd = parser.parse_args()

    if cmd.version:
        show_version()
        sys.exit()

    config, signer = create_signer(cmd.file_location, cmd.config_profile, cmd.is_instance_principals, cmd.is_delegation_token, cmd.is_security_token)
    report = CIS_Report(config, signer, cmd.proxy, cmd.output_bucket, cmd.report_directory, cmd.print_to_screen, cmd.regions, cmd.raw, cmd.obp, cmd.redact_output)
    csv_report_directory = report.generate_reports(int(cmd.level))

    try:
        if OUTPUT_TO_XLSX:
            workbook = Workbook(csv_report_directory + '/Consolidated_Report.xlsx', {'in_memory': True})
            for csvfile in glob.glob(csv_report_directory + '/*.csv'):

                worksheet_name = csvfile.split(os.path.sep)[-1].replace(".csv","").replace("raw_data_","raw_").replace("Findings","fds").replace("Best_Practices","bps")

                if "Identity_and_Access_Management" in worksheet_name:
                    worksheet_name = worksheet_name.replace("Identity_and_Access_Management", "IAM")
                elif "Storage_Object_Storage" in worksheet_name:
                    worksheet_name = worksheet_name.replace("Storage_Object_Storage", "Object_Storage")
                elif "raw_identity_groups_and_membership" in worksheet_name:
                    worksheet_name = worksheet_name.replace("raw_identity", "raw_iam")
                elif "Cost_Tracking_Budgets_Best_Practices" in worksheet_name:
                    worksheet_name = worksheet_name.replace("Cost_Tracking_","")
                elif "Storage_File_Storage_Service" in worksheet_name:
                    worksheet_name = worksheet_name.replace("Storage_File_Storage_Service", "FSS")
                elif "raw_cloud_guard_target" in worksheet_name:
                    # cloud guard targets are too large for a cell
                    continue
                elif len(worksheet_name) > 31:
                    worksheet_name = worksheet_name.replace("_","")

                worksheet = workbook.add_worksheet(worksheet_name)
                with open(csvfile, 'rt', encoding='unicode_escape') as f:
                    reader = csv.reader(f)
                    for r, row in enumerate(reader):
                        for c, col in enumerate(row):
                            # Skipping the deep link due to formating errors in xlsx
                            if "=HYPERLINK" not in col:
                                worksheet.write(r, c, col)
            workbook.close()
    except Exception as e:
        print("**Failed to output to excel. Please use CSV files.**")
        print(e)

##########################################################################
# Main
##########################################################################
execute_report()