##########################################################################
# Copyright (c) 2016, 2020, Oracle and/or its affiliates.  All rights reserved.
# This software is dual-licensed to you under the Universal Permissive License (UPL) 1.0 as shown at https://oss.oracle.com/licenses/upl or Apache License 2.0 as shown at http://www.apache.org/licenses/LICENSE-2.0. You may choose either license.
#
# cis_reports.py
# @author base: Adi Zohar
# @author: Josh Hammer, Andre Correa and Chad Russell
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
            '1.1': {'section': 'Identity and Access Management', 'recommendation_#': '1.1', 'Title': 'Ensure service level admins are created to manage resources of particular service', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['5.4','6.7'], 'CCCS Guard Rail' : '2,3'},
            '1.2': {'section': 'Identity and Access Management', 'recommendation_#': '1.2', 'Title': 'Ensure permissions on all resources are given only to the tenancy administrator group', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['3.3'], 'CCCS Guard Rail' : '1,2,3'},
            '1.3': {'section': 'Identity and Access Management', 'recommendation_#': '1.3', 'Title': 'Ensure IAM administrators cannot update tenancy Administrators group', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['3.3','5.4'], 'CCCS Guard Rail' : '2,3'},
            '1.4': {'section': 'Identity and Access Management', 'recommendation_#': '1.4', 'Title': 'Ensure IAM password policy requires minimum length of 14 or greater', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.1','5.2'], 'CCCS Guard Rail' : '2,3'},
            '1.5': {'section': 'Identity and Access Management', 'recommendation_#': '1.5', 'Title': 'Ensure IAM password policy expires passwords within 365 days', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.1','5.2'], 'CCCS Guard Rail' : '2,3'},
            '1.6': {'section': 'Identity and Access Management', 'recommendation_#': '1.6', 'Title': 'Ensure IAM password policy prevents password reuse', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['5.2'], 'CCCS Guard Rail' : '2,3'},
            '1.7': {'section': 'Identity and Access Management', 'recommendation_#': '1.7', 'Title': 'Ensure MFA is enabled for all users with a console password', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['6.3','6.5'], 'CCCS Guard Rail' : '1,2,3,4'},
            '1.8': {'section': 'Identity and Access Management', 'recommendation_#': '1.8', 'Title': 'Ensure user API keys rotate within 90 days or less', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.1','4.4'], 'CCCS Guard Rail' : '6,7'},
            '1.9': {'section': 'Identity and Access Management', 'recommendation_#': '1.9', 'Title': 'Ensure user customer secret keys rotate within 90 days or less', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.1','5.2'], 'CCCS Guard Rail' : '6,7'},
            '1.10': {'section': 'Identity and Access Management', 'recommendation_#': '1.10', 'Title': 'Ensure user auth tokens rotate within 90 days or less', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.1','5.2'], 'CCCS Guard Rail' : '6,7'},
            '1.11': {'section': 'Identity and Access Management', 'recommendation_#': '1.11', 'Title': 'Ensure API keys are not created for tenancy administrator users', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['5.4'], 'CCCS Guard Rail' : '6,7'},
            '1.12': {'section': 'Identity and Access Management', 'recommendation_#': '1.12', 'Title': 'Ensure all OCI IAM user accounts have a valid and current email address', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['5.1'], 'CCCS Guard Rail' : '1,2,3'},
            '1.13': {'section': 'Identity and Access Management', 'recommendation_#': '1.13', 'Title': 'Ensure Dynamic Groups are used for OCI instances, OCI Cloud Databases and OCI Function to access OCI resources', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['6.8'], 'CCCS Guard Rail' : '6,7'},
            '1.14': {'section': 'Identity and Access Management', 'recommendation_#': '1.14', 'Title': 'Ensure storage service-level admins cannot delete resources they manage', 'Status': False, 'Level': 2, 'Findings': [], 'CISv8': ['5.4','6.8'], 'CCCS Guard Rail' : '2,3'},

            '2.1': {'section': 'Networking', 'recommendation_#': '2.1', 'Title': 'Ensure no security lists allow ingress from 0.0.0.0/0 to port 22', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.4','12.3'], 'CCCS Guard Rail' : '2,3,5,7,9'},
            '2.2': {'section': 'Networking', 'recommendation_#': '2.2', 'Title': 'Ensure no security lists allow ingress from 0.0.0.0/0 to port 3389', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.4','12.3'], 'CCCS Guard Rail' : '2,3,5,7,9'},
            '2.3': {'section': 'Networking', 'recommendation_#': '2.3', 'Title': 'Ensure no network security groups allow ingress from 0.0.0.0/0 to port 22', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.4','12.3'], 'CCCS Guard Rail' : '2,3,5,7,9'},
            '2.4': {'section': 'Networking', 'recommendation_#': '2.4', 'Title': 'Ensure no network security groups allow ingress from 0.0.0.0/0 to port 3389', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.4','12.3'], 'CCCS Guard Rail' : '2,3,5,7,9'},
            '2.5': {'section': 'Networking', 'recommendation_#': '2.5', 'Title': 'Ensure the default security list of every VCN restricts all traffic except ICMP', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['12.3'], 'CCCS Guard Rail' : '2,3,5,7,9'},
            '2.6': {'section': 'Networking', 'recommendation_#': '2.6', 'Title': 'Ensure Oracle Integration Cloud (OIC) access is restricted to allowed sources', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.4','12.3'], 'CCCS Guard Rail' : '2,3,5,7,9'},
            '2.7': {'section': 'Networking', 'recommendation_#': '2.7', 'Title': 'Ensure Oracle Analytics Cloud (OAC) access is restricted to allowed sources or deployed within a Virtual Cloud Network', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.4','12.3'], 'CCCS Guard Rail' : '2,3,5,7,9'},
            '2.8': {'section': 'Networking', 'recommendation_#': '2.8', 'Title': 'Ensure Oracle Autonomous Shared Database (ADB) access is restricted or deployed within a VCN', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.4','12.3'], 'CCCS Guard Rail' : '2,3,5,7,9'},

            '3.1': {'section': 'Logging and Monitoring', 'recommendation_#': '3.1', 'Title': 'Ensure audit log retention period is set to 365 days', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['8.10'], 'CCCS Guard Rail' : '11'},
            '3.2': {'section': 'Logging and Monitoring', 'recommendation_#': '3.2', 'Title': 'Ensure default tags are used on resources', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['1.1'], 'CCCS Guard Rail' : ''},
            '3.3': {'section': 'Logging and Monitoring', 'recommendation_#': '3.3', 'Title': 'Create at least one notification topic and subscription to receive monitoring alerts', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['8.2','8.11'], 'CCCS Guard Rail' : '11'},
            '3.4': {'section': 'Logging and Monitoring', 'recommendation_#': '3.4', 'Title': 'Ensure a notification is configured for Identity Provider changes', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11'},
            '3.5': {'section': 'Logging and Monitoring', 'recommendation_#': '3.5', 'Title': 'Ensure a notification is configured for IdP group mapping changes', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11'},
            '3.6': {'section': 'Logging and Monitoring', 'recommendation_#': '3.6', 'Title': 'Ensure a notification is configured for IAM group changes', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11'},
            '3.7': {'section': 'Logging and Monitoring', 'recommendation_#': '3.7', 'Title': 'Ensure a notification is configured for IAM policy changes', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11'},
            '3.8': {'section': 'Logging and Monitoring', 'recommendation_#': '3.8', 'Title': 'Ensure a notification is configured for user changes', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11'},
            '3.9': {'section': 'Logging and Monitoring', 'recommendation_#': '3.9', 'Title': 'Ensure a notification is configured for VCN changes', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11'},
            '3.10': {'section': 'Logging and Monitoring', 'recommendation_#': '3.10', 'Title': 'Ensure a notification is configured for  changes to route tables', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11'},
            '3.11': {'section': 'Logging and Monitoring', 'recommendation_#': '3.11', 'Title': 'Ensure a notification is configured for  security list changes', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11'},
            '3.12': {'section': 'Logging and Monitoring', 'recommendation_#': '3.12', 'Title': 'Ensure a notification is configured for  network security group changes', 'Status': False, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11'},
            '3.13': {'section': 'Logging and Monitoring', 'recommendation_#': '3.13', 'Title': 'Ensure a notification is configured for  changes to network gateways', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['4.2'], 'CCCS Guard Rail' : '11'},
            '3.14': {'section': 'Logging and Monitoring', 'recommendation_#': '3.14', 'Title': 'Ensure VCN flow logging is enabled for all subnets', 'Status': True, 'Level': 2, 'Findings': [], 'CISv8': ['8.2,''8.5','13.6'], 'CCCS Guard Rail' : ''},
            '3.15': {'section': 'Logging and Monitoring', 'recommendation_#': '3.15', 'Title': 'Ensure Cloud Guard is enabled in the root compartment of the tenancy', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['8.2','8.5','8.11'], 'CCCS Guard Rail' : '1,2,3'},
            '3.16': {'section': 'Logging and Monitoring', 'recommendation_#': '3.16', 'Title': 'Ensure customer created Customer Managed Key (CMK) is rotated at least annually', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': [], 'CCCS Guard Rail' : '6,7'},
            '3.17': {'section': 'Logging and Monitoring', 'recommendation_#': '3.17', 'Title': 'Ensure write level Object Storage logging is enabled for all buckets', 'Status': True, 'Level': 2, 'Findings': [], 'CISv8': ['8.2'], 'CCCS Guard Rail' : ''},

            '4.1.1': {'section': 'Storage - Object Storage', 'recommendation_#': '4.1.1', 'Title': 'Ensure no Object Storage buckets are publicly visible', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['3.3'], 'CCCS Guard Rail' : ''},
            '4.1.2': {'section': 'Storage - Object Storage', 'recommendation_#': '4.1.2', 'Title': 'Ensure Object Storage Buckets are encrypted with a Customer Managed Key (CMK)', 'Status': True, 'Level': 2, 'Findings': [], 'CISv8': ['3.11'], 'CCCS Guard Rail' : ''},
            '4.1.3': {'section': 'Storage - Object Storage', 'recommendation_#': '4.1.3', 'Title': 'Ensure Versioning is Enabled for Object Storage Buckets', 'Status': True, 'Level': 2, 'Findings': [], 'CISv8': ['3.11'], 'CCCS Guard Rail' : ''},
            '4.2.1': {'section': 'Storage - Block Volumes', 'recommendation_#': '4.2.1', 'Title': 'Ensure Block Volumes are encrypted with Customer Managed Keys', 'Status': True, 'Level': 2, 'Findings': [], 'CISv8': ['3.11'], 'CCCS Guard Rail' : ''},
            '4.2.2': {'section': 'Storage - Block Volumes', 'recommendation_#': '4.2.2', 'Title': 'Ensure Boot Volumes are encrypted with Customer Managed Key', 'Status': True, 'Level': 2, 'Findings': [], 'CISv8': ['3.11'], 'CCCS Guard Rail' : ''},
            '4.3.1': {'section': 'Storage - File Storage Service', 'recommendation_#': '4.3.1', 'Title': 'Ensure File Storage Systems are encrypted with Customer Managed Keys', 'Status': True, 'Level': 2, 'Findings': [], 'CISv8': ['3.11'], 'CCCS Guard Rail' : ''},


            '5.1': {'section': 'Asset Management', 'recommendation_#': '5.1', 'Title': 'Create at least one compartment in your tenancy to store cloud resources', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['3.1'], 'CCCS Guard Rail' : '2,3,8,12'},
            '5.2': {'section': 'Asset Management', 'recommendation_#': '5.2', 'Title': 'Ensure no resources are created in the root compartment', 'Status': True, 'Level': 1, 'Findings': [], 'CISv8': ['3.12'], 'CCCS Guard Rail' : '1,2,3'}
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
                'com.oraclecloud.identityControlPlane.createidpgroupmapping',
                'com.oraclecloud.identityControlPlane.deleteidpgroupmapping',
                'com.oraclecloud.identityControlPlane.updateidpgroupmapping'
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
                'com.oraclecloud.virtualnetwork.deletelocalpeeringgateway',
                'com.oraclecloud.virtualnetwork.updatelocalpeeringgateway',
                'com.oraclecloud.natgateway.changenatgatewaycompartment',
                'com.oraclecloud.natgateway.createnatgateway',
                'com.oraclecloud.natgateway.deletenatgateway',
                'com.oraclecloud.natgateway.updatenatgateway',
                'com.oraclecloud.servicegateway.attachserviceid',
                'com.oraclecloud.servicegateway.changeservicegatewaycompartment',
                'com.oraclecloud.servicegateway.createservicegateway',
                'com.oraclecloud.servicegateway.deleteservicegateway.begin',
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
        self.__network_vcns = {}
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
        self.__print_header("Running CIS Reports...")
        print("Updated November 16, 2022.")
        print("Tested oci-python-sdk version: 2.88.1")
        print("Your oci-python-sdk version: " + str(oci.__version__))
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
            raise RuntimeError("Invalid input regions must be comma separated with no : `us-ashburn-1,us-phoenix-1`")

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
                record = {
                    "id" : compartment.id,
                    "name" : compartment.name,
                    "compartment_id": compartment.compartment_id,
                    "defined_tags": compartment.defined_tags,
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
            root_compartment = {
                "id" : self.__tenancy.id,
                "name" : self.__tenancy.name,
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
                    group_record = {
                        "id": grp.id,
                        "name": grp.name,
                        "description": grp.description,
                        "lifecycle_state": grp.lifecycle_state,
                        "time_created": grp.time_created.strftime(self.__iso_time_format),
                        "user_id": member.user_id
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
                record = {
                    'id': user.id,
                    'defined_tags': user.defined_tags,
                    'description': user.description,
                    'email': user.email,
                    'email_verified': user.email_verified,
                    'external_identifier': user.external_identifier,
                    'identity_provider_id': user.identity_provider_id,
                    'is_mfa_activated': user.is_mfa_activated,
                    'lifecycle_state': user.lifecycle_state,
                    'time_created': user.time_created.strftime(self.__iso_time_format),
                    'name': user.name,
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
            print("\tProcessed " + str(len(self.__users)) + " users")
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
                record = {
                    'id': api_key.key_id,
                    'fingerprint': api_key.fingerprint,
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
                record = {
                    'id': token.id,
                    'description': token.description,
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
                record = {
                    'id': key.id,
                    'display_name': key.display_name,
                    'inactive_status': key.inactive_status,
                    'lifecycle_state': key.lifecycle_state,
                    # .strftime('%Y-%m-%d %H:%M:%S'),
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
                        record = {
                            "id": policy.id,
                            "name": policy.name,
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
                try:
                    record = {
                        "id": dynamic_group.id,
                        "name": dynamic_group.name,
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
                except Exception as e:
                    record = {
                        "id": "",
                        "name": "",
                        "description": "",
                        "matching_rule": "",
                        "time_created": "",
                        "inactive_status": "",
                        "lifecycle_state": "",
                        "defined_tags": "",
                        "freeform_tags": "",
                        "compartment_id": "",
                        "notes": str(e)
                    }
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
                                record = {
                                    "id": bucket_info.id,
                                    "name": bucket_info.name,
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
                                record = {
                                    "id": "",
                                    "name": bucket.name,
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
                                    "defined_tags" : "",
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
                            try:
                                record = {
                                    "id":volume.id,
                                    "display_name": volume.display_name,
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
                                    "id":"",
                                    "display_name": "",
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
                                try:
                                    record = {
                                        "id": boot_volume.id,
                                        "display_name": boot_volume.display_name,
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
                                        "id": "",
                                        "display_name": "",
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
                                try:
                                    record = {
                                        "id": fss.id,
                                        "display_name": fss.display_name,
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
                                        "id": "",
                                        "display_name": "",
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
                            record = {
                                "compartment_id": nsg.compartment_id,
                                "display_name": nsg.display_name,
                                "id": nsg.id,
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
                                rule_record = {

                                    "destination": rule.destination,
                                    "destination_type": rule.destination_type,
                                    "direction": rule.direction,
                                    "icmp_options": rule.icmp_options,
                                    "id": rule.id,
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
                            record = {
                                "compartment_id": security_list.compartment_id,
                                "display_name": security_list.display_name,
                                "id": security_list.id,
                                "lifecycle_state": security_list.lifecycle_state,
                                "time_created": security_list.time_created.strftime(self.__iso_time_format),
                                "vcn_id": security_list.vcn_id,
                                "region" : region_key,
                                "freeform_tags" : security_list.freeform_tags,
                                "defined_tags" : security_list.defined_tags,
                                "egress_security_rules": [],
                                "ingress_security_rules": []
                            }
                            for egress_rule in security_list.egress_security_rules:
                                erule = {
                                    "description": egress_rule.description,
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
                                record = {
                                    "id": subnet.id,
                                    "availability_domain": subnet.availability_domain,
                                    "cidr_block": subnet.cidr_block,
                                    "compartment_id": subnet.compartment_id,
                                    "dhcp_options_id": subnet.dhcp_options_id,
                                    "display_name": subnet.display_name,
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
                            record = {
                                "id": subnet.id,
                                "availability_domain": subnet.availability_domain,
                                "cidr_block": subnet.cidr_block,
                                "compartment_id": subnet.compartment_id,
                                "dhcp_options_id": subnet.dhcp_options_id,
                                "display_name": subnet.display_name,
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
            
            # Build a list of VCNs
            self.__network_build_network_vcn_subnets,
            return self.__network_subnets
        except Exception as e:
            raise RuntimeError(
                "Error in __network_read_network_subnets " + str(e.args))

    ##########################################################################
    # Build a Dictionary of VCN from the subnets indexed by vcn_id
    ##########################################################################
    def __network_build_network_vcn_subnets(self):
        for subnet in self.__network_subnets:
            try:
                self.__network_vcns[subnet['vcn_id']].append(subnet)
            except:
                self.__network_vcns[subnet['vcn_id']] = []
                self.__network_vcns[subnet['vcn_id']].append(subnet)
        
        print("\tProcessed " + str(len(self.__network_vcns)) + " Network VCNs")                        
        return self.__network_vcns


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
                            try:
                                record = {
                                "id": drg_attachment.id,
                                "display_name" : drg_attachment.display_name,
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
                            try:
                                record = {
                                    "id": drg.id,
                                    "display_name" : drg.display_name,
                                    "default_drg_route_tables" : drg.default_drg_route_tables,
                                    "default_ipsec_tunnel_route_table" : drg.default_drg_route_tables.ipsec_tunnel,
                                    "default_remote_peering_connection_route_table" : drg.default_drg_route_tables.remote_peering_connection,
                                    "default_vcn_table" : drg.default_drg_route_tables.vcn,
                                    "default_virtual_circuit_route_table" : drg.default_drg_route_tables.virtual_circuit,
                                    "default_export_drg_route_distribution_id" : drg.default_export_drg_route_distribution_id,
                                    "compartment_id" : drg.compartment_id,
                                    "lifecycle_state" : drg.lifecycle_state,
                                    "time_created" : drg.time_created.strftime(self.__iso_time_format),
                                    "freeform_tags" : drg.freeform_tags,
                                    "define_tags" : drg.defined_tags,
                                    "region" : region_key,
                                    "notes":""
                                }
                            except:
                                record = {
                                    "id": drg.id,
                                    "display_name" : drg.display_name,
                                    "default_drg_route_tables" : drg.default_drg_route_tables,
                                    "default_ipsec_tunnel_route_table" : "",
                                    "default_remote_peering_connection_route_table" : "",
                                    "default_vcn_table" : "",
                                    "default_virtual_circuit_route_table" : "",
                                    "default_export_drg_route_distribution_id" : drg.default_export_drg_route_distribution_id,
                                    "compartment_id" : drg.compartment_id,
                                    "lifecycle_state" : drg.lifecycle_state,
                                    "time_created" : drg.time_created.strftime(self.__iso_time_format),
                                    "freeform_tags" : drg.freeform_tags,
                                    "define_tags" : drg.defined_tags,
                                    "region" : region_key,
                                    "notes":""

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
                        try:
                            for fastconnect in fastconnect_data:
                                record = {
                                    "id": fastconnect.id,
                                    "display_name" : fastconnect.display_name,
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
                                    "id": "",
                                    "display_name" : "",
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
    # Load Customer Premises Equipments  
    ##########################################################################
    def __network_read_cpes(self):
        try:
            for region_key, region_values in self.__regions.items():
                # Looping through compartments in tenancy
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        cpe_data = oci.pagination.list_call_get_all_results(
                            region_values['network_client'].list_cpes,
                            compartment_id=compartment.id,
                        ).data
                        # Looping through CPEs in a compartment
                        try:
                            for cpe in cpe_data:
                                record = {
                                    "id": cpe.id,
                                    "display_name" : cpe.display_name,
                                    "cpe_device_shape_id" : cpe.cpe_device_shape_id,
                                    "ip_address" : cpe.ip_address,
                                    "compartment_id" : cpe.compartment_id,
                                    "time_created" : cpe.time_created.strftime(self.__iso_time_format),
                                    "freeform_tags" : cpe.freeform_tags,
                                    "define_tags" : cpe.defined_tags,
                                    "region" : region_key,
                                    "notes":""

                                }
                                # Adding CPEs to CPE list
                                self.__network_cpes.append(record)
                        except Exception as e:
                            record = {
                                    "id": "",
                                    "display_name" : "",
                                    "cpe_device_shape_id" : "",
                                    "ip_address" : "",
                                    "compartment_id" : compartment.id,
                                    "time_created" : "",
                                    "freeform_tags" : "",
                                    "define_tags" : "",
                                    "region" : region_key,
                                    "notes": str(e)

                            }
                            self.__network_cpes.append(record)
            print("\tProcessed " + str(len(self.__network_cpes)) + " Customer Premises Devices")                        
            return self.__network_cpes
        except Exception as e:
            raise RuntimeError(
                "Error in __network_read_cpes " + str(e.args))

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
                                record = {
                                    "id": ip_sec.id,
                                    "display_name" : ip_sec.display_name,
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
                                        tunnel_record = {
                                                "id" : tunnel.id,
                                                "cpe_ip" : tunnel.cpe_ip,
                                                "display_name" : tunnel.display_name,
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
                                            tunnel_record['tunnels_up'] = False
                                        record["tunnels"].append(tunnel_record)
                                except:
                                    print("\t Unable to tunnels for ip_sec_connection: " + ip_sec.display_name + " id: " + ip_sec.id)
                                    record['tunnels_up'] = False


                            except:
                                print("execption " * 10)
                                print(ip_sec)

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
                                if (adb.lifecycle_state != oci.database.models.AutonomousDatabaseSummary.LIFECYCLE_STATE_TERMINATED or
                                    adb.lifecycle_state != oci.database.models.AutonomousDatabaseSummary.LIFECYCLE_STATE_TERMINATING):
                                    record = {
                                                "id": adb.id,
                                                "display_name": adb.display_name,
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
                                try:
                                    record = {
                                        "id": oic_instance.id,
                                        "display_name": oic_instance.display_name,
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
                                        "id": "",
                                        "display_name": "",
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
                            try:  
                                record = {
                                    "id": oac_instance.id,
                                    "name": oac_instance.name,
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
                                    # "defined_tags" : oac_instance.defined_tags,
                                    # "freeform_tags" : oac_instance.freeform_tags,
                                    "region" : region_key,
                                    "notes":""
                                }
                            except Exception as e:
                                record = {
                                    "name": "",
                                    "description": "",
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
                                    # "defined_tags": "",
                                    # "freeform_tags": "",
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
                            record = {
                                "compartment_id": event_rule.compartment_id,
                                "condition": event_rule.condition,
                                "description": event_rule.description,
                                "display_name": event_rule.display_name,
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
                            record = {
                                "compartment_id": log_group.compartment_id,
                                "description": log_group.description,
                                "display_name": log_group.display_name,
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
                                log_record = {
                                    "compartment_id": log.compartment_id,
                                    "display_name": log.display_name,
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
                            vault_record = {
                                "compartment_id": vlt.compartment_id,
                                "crypto_endpoint": vlt.crypto_endpoint,
                                "display_name": vlt.display_name,
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
                                        key_record = {
                                            "compartment_id": key.compartment_id,
                                            "display_name": key.display_name,
                                            "id": key.id,
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
                
                record = {
                    "actual_spend" : budget.actual_spend,
                    "alert_rule_count" : budget.alert_rule_count,
                    "amount" : budget.amount,
                    "budget_processing_period_start_offset" : budget.budget_processing_period_start_offset,
                    "compartment_id": budget.compartment_id,
                    "description" : budget.description,
                    "display_name": budget.display_name,
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

            print("\tProcessed " + str(len(self.__budgets)) + " budgets")
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
                print("\t***Access to audit retention requires the user to be part of the Administrator group")
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
            print("***Cloud Guard service requires a PayGo account")


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
                            
                            record = {
                                "compartment_id": target.compartment_id,
                                "defined_tags": target.defined_tags,
                                "display_name": target.display_name,
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
            print("***Cloud Guard service requires a PayGo account")

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
                print("\t***Access to password policies in this tenancy requires elevated permissions.")
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
                            record = {
                                "id": sub.id,
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
                record = {
                    "id": tag.id,
                    "compartment_id": tag.compartment_id,
                    "value": tag.value,
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
                            try:
                                service_connector = region_values['sch_client'].get_service_connector(
                                    service_connector_id=connector.id
                                    ).data
                                record = {
                                    "id": service_connector.id,
                                    "display_name": service_connector.display_name,
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
        
        print("\tProcessed " + str(len(self.__resources_in_root_compartment)) + " resource in the root compartment")                        
        return self.__resources_in_root_compartment

    ##########################################################################
    # Analyzes Tenancy Data for CIS Report
    ##########################################################################
    def __report_cis_analyze_tenancy_data(self):
        
        # 1.1 Check - checking if there are additional policies
        policy_counter = 0
        for policy in self.__policies:
            for statement in policy['statements']:
                if "allow group".upper() in statement.upper() \
                    and not("to manage all-resources in tenancy".upper() in statement.upper()) \
                        and policy['name'].upper() != "Tenant Admin Policy".upper():
                    policy_counter += 1
            if policy_counter < 3:
                self.cis_foundations_benchmark_1_2['1.1']['Status'] = False
                self.cis_foundations_benchmark_1_2['1.1']['Findings'].append(
                    policy)

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
            if user['external_identifier'] is None and not(user['is_mfa_activated']) and user['lifecycle_state'] == 'ACTIVE':
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
                            print(" I am an excption " * 5)
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
                print("*** Invalid Event Condition for event: " + event['display_name'] + " ***")
                event_dict = {}
            
            if event_dict:
                for key, changes in self.cis_monitoring_checks.items():
                    # Checking if all cis change list is a subset of event condition
                    # if(all(x in test_list for x in sub_list)):
                    if event_dict != {}:
                        if(all(x in event_dict['eventtype'] for x in changes)):
                            self.cis_foundations_benchmark_1_2[key]['Status'] = True

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
                    # Checking if a the compartment being logged is the Tenancy and it has all child compartments
                    if source['compartment_id'] == self.__tenancy.id and source['log_group_id'].upper() == "_Audit_Include_Subcompartment".upper():
                        self.__obp_regional_checks[sch_values['region']]['Audit']['tenancy_level_audit'] = True
                        self.__obp_regional_checks[sch_values['region']]['Audit']['tenancy_level_include_sub_comps'] = True
                    # Since it is not the Tenancy we should add the compartment to the list and check if sub compartment are included
                    elif source['log_group_id'].upper() == "_Audit_Include_Subcompartment".upper():
                        self.__obp_regional_checks[sch_values['region']]['Audit']['compartments'] = self.__get_children(source['compartment_id'],dict_of_compartments) + self.__obp_regional_checks[sch_values['region']]['Audit']['compartments']
                    elif source['log_group_id'].upper() == "_Audit".upper():
                        self.__obp_regional_checks[sch_values['region']]['Audit']['compartments'].append(source['compartment_id'])
        
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
                finding = list(filter(lambda source: source['id']== compartment, self.__raw_compartment ))[0]
                finding['region'] = region_key
                self.obp_foundations_checks['SIEM_Audit_Log_All_Comps']['Findings'].append(finding)
            # Compartment logs that are not missed in the region
            for compartment in region_values['Audit']['compartments']:
                finding = list(filter(lambda source: source['id'] == compartment, self.__raw_compartment ))[0]
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
                    if attachment['network_id'] in self.__network_vcns:
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
                record = {
                    "Recommendation #": key,
                    "Section": recommendation['section'],
                    "Level": str(recommendation['Level']),
                    "Compliant": ('Yes' if recommendation['Status'] else 'No'),
                    "Findings": (str(len(recommendation['Findings'])) if len(recommendation['Findings']) > 0 else " "),
                    "Title": recommendation['Title'],
                    "CIS v8": recommendation['CISv8'],
                    "CCCS Guard Rail": recommendation['CCCS Guard Rail']
                }
                # Add record to summary report for CSV output
                summary_report.append(record)
            
            # Generate Findings report
            # self.__print_to_csv_file("cis", recommendation['section'] + "_" + recommendation['recommendation_#'], recommendation['Findings'] )

        # Screen output for CIS Summary Report
        self.__print_header("CIS Foundations Benchmark 1.2 Summary Report")
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
        self.__print_header("Writing CIS reports to CSV")
        summary_file_name = self.__print_to_csv_file(
            self.__report_directory, "cis", "summary_report", summary_report)
        
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
    # Orchestrates analysis and report generation
    ##########################################################################
    def __report_generate_obp_report(self):

        obp_summary_report = []
        # Screen output for CIS Summary Report
        self.__print_header("OCI Best Practices Findings")
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

        self.__print_header("Writing Oracle Best Practices reports to CSV")

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
                # self.__network_read_cpes,
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
                        items_to_redact = re.findall('ocid1\.[a-z,0-9]*\.[a-z,0-9]*\.[a-z,0-9,-]*\.[a-z,0-9,\.]{20,}',str_item)
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
        self.__print_header("Finished in: " + str(end_datetime - self.start_datetime))

        return self.__report_directory

    ##########################################################################
    # Print header centered
    ##########################################################################
    def __print_header(self, name):
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


def create_signer(file_location, config_profile, is_instance_principals, is_delegation_token):

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
    cmd = parser.parse_args()

    config, signer = create_signer(cmd.file_location, cmd.config_profile, cmd.is_instance_principals, cmd.is_delegation_token)
    report = CIS_Report(config, signer, cmd.proxy, cmd.output_bucket, cmd.report_directory, cmd.print_to_screen, cmd.regions, cmd.raw, cmd.obp, cmd.redact_output)
    csv_report_directory = report.generate_reports(int(cmd.level))

    if OUTPUT_TO_XLSX:
        workbook = Workbook(csv_report_directory + '/Consolidated_Report.xlsx', {'in_memory': True})
        for csvfile in glob.glob(csv_report_directory + '/*.csv'):
            worksheet_name = csvfile.split("/")[-1].replace(".csv","").replace("raw_data_","raw_").replace("Findings","fds").replace("Best_Practices","bps")
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
            with open(csvfile, 'rt', encoding='utf8') as f:
                reader = csv.reader(f)
                for r, row in enumerate(reader):
                    for c, col in enumerate(row):
                        worksheet.write(r, c, col)
        
        workbook.close()


##########################################################################
# Main
##########################################################################
execute_report()
