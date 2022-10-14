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
import sys
import argparse
import datetime
import pytz
import oci
import json
import os
import csv


##########################################################################
# CIS Reporting Class
##########################################################################
class CIS_Report:

    # Class variables
    _DAYS_OLD = 90
    __KMS_DAYS_OLD = 365
    __home_region = []

    
    # Start print time info
    start_datetime = datetime.datetime.now().replace(tzinfo=pytz.UTC)
    start_time_str = str(start_datetime.strftime("%Y-%m-%d %H:%M:%S"))
    report_datetime = str(start_datetime.strftime("%Y-%m-%d_%H-%M"))
    # For User based key checks
    api_key_time_max_datetime = start_datetime - \
        datetime.timedelta(days=_DAYS_OLD)

    # For KMS check
    kms_key_time_max_datetime = start_datetime - \
        datetime.timedelta(days=__KMS_DAYS_OLD)

    def __init__(self, config, signer, proxy, output_bucket, report_directory, print_to_screen, regions_to_run_in, raw_data):

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

        # CIS monitoring notifications check
        self.cis_monitoring_checks = {
            "3.4": [
                'com.oraclecloud.identitycontrolplane.createidentityprovider',
                'com.oraclecloud.identitycontrolplane.deleteidentityprovider',
                'com.oraclecloud.identitycontrolplane.updateidentityprovider'
            ],
            "3.5": [
                'com.oraclecloud.identitycontrolplane.createpolicy',
                'com.oraclecloud.identitycontrolplane.deletepolicy',
                'com.oraclecloud.identitycontrolplane.updatepolicy'
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
        
        # For Autonomous Database Checks
        self.__autonomous_databases = []

        # For Oracle Analytics Cloud Checks
        self.__analytics_instances = []

        # For Oracle Integration Cloud Checks
        self.__integration_instances = []

        # For Logging & Monitoring checks
        self.__event_rules = []
        self.__logging_list = []
        self.__subnet_logs = []
        self.__write_bucket_logs = []

        # For Storage Checks
        self.__buckets = []
        self.__boot_volumes = []
        self.__block_volumes = []
        self.__file_storage_system = []

        # For Vaults and Keys checks
        self.__vaults = []

        # For Region
        self.__regions = {}
        self.__home_region = None

        # For ONS Subscriptions
        self.__subscriptions = []

        # Results from Advanced search query
        self.__resources_in_root_compartment = []

        # Setting list of regions to run in

        # Start print time info
        self.__print_header("Running CIS Reports...")
        print("Updated June 30, 2022.")
        print("oci-python-sdk version: " + str(oci.__version__))
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
                    "identity_client" : self.__identity
                }
            elif region.region_name in self.__regions_to_run_in or self.__run_in_all_regions: 
                self.__regions[region.region_name] = {
                    "is_home_region": region.is_home_region,
                    "region_key": region.region_key,
                    "region_name": region.region_name,
                    "status": region.status,
                    }
  
        
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
                self.__tenancy.id,
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
                    "time_created": compartment.time_created
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
                "time_created": ""
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
        print("Processing User Groups and Group Memberships...")
        try:
            # Getting all Groups in the Tenancy
            groups_data = oci.pagination.list_call_get_all_results(
                self.__regions[self.__home_region]['identity_client'].list_groups,
                self.__tenancy.id
            ).data
            # For each group in the tenacy getting the group's membership
            for grp in groups_data:
                membership = oci.pagination.list_call_get_all_results(
                    self.__regions[self.__home_region]['identity_client'].list_user_group_memberships,
                    self.__tenancy.id,
                    group_id=grp.id
                ).data
                for member in membership:
                    group_record = {
                        "id": grp.id,
                        "name": grp.name,
                        "description": grp.description,
                        "lifecycle_state": grp.lifecycle_state,
                        "time_created": grp.time_created,
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
        print("Processing Users...")
        try:
            # Getting all users in the Tenancy
            users_data = oci.pagination.list_call_get_all_results(
                self.__regions[self.__home_region]['identity_client'].list_users,
                self.__tenancy.id
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
                    'time_created': user.time_created,
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
                user_ocid
            ).data

            for api_key in user_api_keys_data:
                record = {
                    'id': api_key.key_id,
                    'fingerprint': api_key.fingerprint,
                    'inactive_status': api_key.inactive_status,
                    'lifecycle_state': api_key.lifecycle_state,
                    # .strftime('%Y-%m-%d %H:%M:%S')
                    'time_created': api_key.time_created,
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
                user_ocid
            ).data

            for token in auth_tokens_data:
                record = {
                    'id': token.id,
                    'description': token.description,
                    'inactive_status': token.inactive_status,
                    'lifecycle_state': token.lifecycle_state,
                    # .strftime('%Y-%m-%d %H:%M:%S'),
                    'time_created': token.time_created,
                    'time_expires': token.time_expires,
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
                user_ocid
            ).data

            for key in customer_secret_key_data:
                record = {
                    'id': key.id,
                    'display_name': key.display_name,
                    'inactive_status': key.inactive_status,
                    'lifecycle_state': key.lifecycle_state,
                    # .strftime('%Y-%m-%d %H:%M:%S'),
                    'time_created': key.time_created,
                    'time_expires': key.time_expires,

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
        print("Processing IAM Policies...")
        # Get all policy at the tenancy level
        try:
            for compartment in self.__compartments:
                if self.__if_not_managed_paas_compartment(compartment.name):
                    policies_data = oci.pagination.list_call_get_all_results(
                        self.__regions[self.__home_region]['identity_client'].list_policies,
                        compartment.id
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
        print("Processing IAM Dynamic Groups...")
        try:
            dynamic_groups_data = oci.pagination.list_call_get_all_results(
                self.__regions[self.__home_region]['identity_client'].list_dynamic_groups,
                self.__tenancy.id
                ).data
            for dynamic_group in dynamic_groups_data:
                try:
                    record = {
                        "id": dynamic_group.id,
                        "name": dynamic_group.name,
                        "description": dynamic_group.description,
                        "matching_rule": dynamic_group.matching_rule,
                        "time_created": dynamic_group.time_created,
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
        print("Processing Availability Domains...")
        try:
            for region_key, region_values in self.__regions.items():
                region_values['availability_domains'] = oci.pagination.list_call_get_all_results(
                    region_values['identity_client'].list_availability_domains,
                    self.__tenancy.id
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

        print("Processing Object Store Buckets...")
        

        try:
            # looping through regions
            for region_key, region_values in self.__regions.items():
                # Collecting buckets from each compartment
                for compartment in self.__compartments:
                    # Skipping the managed paas compartment
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        buckets_data = oci.pagination.list_call_get_all_results(
                            region_values['os_client'].list_buckets,
                            self.__os_namespace,
                            compartment.id
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
                                    "time_created": bucket_info.time_created,
                                    "versioning": bucket_info.versioning,
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
                                    "time_created": bucket.time_created,
                                    "versioning": "",
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
        print("Processing Block Volumes...")

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
                                    "time_created": volume.time_created,
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
        print("Processing Boot Volumes...")
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
                                        "time_created": boot_volume.time_created,
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
        print("Processing File Storage service...")
        try:
            for region_key, region_values in self.__regions.items():
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        # Iterating through ADs in region
                        for ad in region_values['availability_domains']:
                            fss_data = oci.pagination.list_call_get_all_results(
                                    region_values['fss_client'].list_file_systems,
                                    compartment.id,
                                    ad.name
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
                                        "time_created": fss.time_created,
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
        print("Processing Network Security Groups...")
        # print(network)
        # print(compartments)
        # Loopig Through Compartments Except Mnaaged
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
                                "time_created": nsg.time_created,
                                "vcn_id": nsg.vcn_id,
                                "region" : region_key,
                                "rules": []
                            }
                            nsg_rules = oci.pagination.list_call_get_all_results(
                                region_values['network_client'].list_network_security_group_security_rules,
                                nsg.id
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
                                    "time_created": rule.time_created,
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
        print("Processing Network Security Lists...")
        # print(network)
        # print(compartments)
        # Looping Through Compartments Except Mnaaged
        try:
            for region_key, region_values in self.__regions.items():
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        security_lists_data = oci.pagination.list_call_get_all_results(
                            region_values['network_client'].list_security_lists,
                            compartment.id
                        ).data
                        # Looping through Security Lists to to get
                        for security_list in security_lists_data:
                            record = {
                                "compartment_id": security_list.compartment_id,
                                "display_name": security_list.display_name,
                                "id": security_list.id,
                                "lifecycle_state": security_list.lifecycle_state,
                                "time_created": security_list.time_created,
                                "vcn_id": security_list.vcn_id,
                                "region" : region_key,
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
        print("Processing Network Subnets...")
        try:
            for region_key, region_values in self.__regions.items():
                # Looping through compartments in tenancy
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        subnets_data = oci.pagination.list_call_get_all_results(
                            region_values['network_client'].list_subnets,
                            compartment.id,
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
                                    "time_created": subnet.time_created,
                                    "vcn_id": subnet.vcn_id,
                                    "virtual_router_ip": subnet.virtual_router_ip,
                                    "virtual_router_mac": subnet.virtual_router_mac,
                                    "region" : region_key,
                                    "notes":""

                                }
                                # Adding subnet to subnet list
                                self.__network_subnets.append(record)
                        except:
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
                                "time_created": subnet.time_created,
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


     ############################################
     # Load Autonomous Databases
     ############################################
    def __adb_read_adbs(self):
        print("Processing Autonomous Databases...")
        try:
            for region_key, region_values in self.__regions.items():
                for compartment in self.__compartments: 
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        autonomous_databases = oci.pagination.list_call_get_all_results(
                        region_values['adb_client'].list_autonomous_databases, 
                                compartment.id
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
                                                "source_id": adb.source_id,
                                                "standby_whitelisted_ips": adb.standby_whitelisted_ips,
                                                "subnet_id": adb.subnet_id,
                                                "supported_regions_to_clone_to": adb.supported_regions_to_clone_to,
                                                "system_tags": adb.system_tags,
                                                "time_created": adb.time_created,
                                                "time_data_guard_role_changed": adb.time_data_guard_role_changed,
                                                "time_deletion_of_free_autonomous_database": adb.time_deletion_of_free_autonomous_database,
                                                "time_local_data_guard_enabled": adb.time_local_data_guard_enabled,
                                                "time_maintenance_begin": adb.time_maintenance_begin,
                                                "time_maintenance_end": adb.time_maintenance_end,
                                                "time_of_last_failover": adb.time_of_last_failover,
                                                "time_of_last_refresh": adb.time_of_last_refresh,
                                                "time_of_last_refresh_point": adb.time_of_last_refresh_point,
                                                "time_of_last_switchover": adb.time_of_last_switchover,
                                                "time_of_next_refresh": adb.time_of_next_refresh,
                                                "time_reclamation_of_free_autonomous_database": adb.time_reclamation_of_free_autonomous_database,
                                                "time_until_reconnect_clone_enabled": adb.time_until_reconnect_clone_enabled,
                                                "used_data_storage_size_in_tbs": adb.used_data_storage_size_in_tbs,
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
        print("Processing Oracle Integration Instances...")
        try:
            for region_key, region_values in self.__regions.items():
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        oic_instances = oci.pagination.list_call_get_all_results(
                            region_values['oic_client'].list_integration_instances,
                            compartment.id
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
                                        "time_created": oic_instance.time_created,
                                        "time_updated": oic_instance.time_updated,
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
        print("Processing Oracle Analytics Instances...")
        try:
            for region_key, region_values in self.__regions.items():
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        oac_instances = oci.pagination.list_call_get_all_results(
                            region_values['oac_client'].list_analytics_instances,
                            compartment.id
                        ).data
                        for oac_instance in oac_instances:
                            try:  
                                record = {
                                    "id": oac_instance.id,
                                    "name": oac_instance.name,
                                    "description": oac_instance.description,
                                    "network_endpoint_details": oac_instance.network_endpoint_details,
                                    "compartment_id": oac_instance.compartment_id,
                                    "lifecycle_state": oac_instance.lifecycle_state,
                                    "email_notification": oac_instance.email_notification,
                                    "feature_set": oac_instance.feature_set,
                                    "service_url": oac_instance.service_url,
                                    "capacity": oac_instance.capacity,
                                    "license_type": oac_instance.license_type,
                                    "time_created": oac_instance.time_created,
                                    "time_updated": oac_instance.time_updated,
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
        
        print("Processing Event Rules...")
        try:
            for region_key, region_values in self.__regions.items():
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        events_rules_data = oci.pagination.list_call_get_all_results(
                            region_values['events_client'].list_rules,
                            compartment.id
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
                                "time_created": event_rule.time_created,
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
        
        print("Processing Log Groups and Logs...")

        try:
            for region_key, region_values in self.__regions.items():
                # Looping through compartments
                for compartment in self.__compartments:
                    # Checking if Managed Compartment cause I can't query it
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        # Getting Log Groups in compartment
                        log_groups = oci.pagination.list_call_get_all_results(
                            region_values['logging_client'].list_log_groups,
                            compartment.id
                        ).data
                        # Looping through log groups to get logs
                        for log_group in log_groups:
                            record = {
                                "compartment_id": log_group.compartment_id,
                                "description": log_group.description,
                                "display_name": log_group.display_name,
                                "id": log_group.id,
                                "time_created": log_group.time_created,
                                "time_last_modified": log_group.time_last_modified,
                                "region" : region_key,
                                "logs": []
                            }

                            logs = oci.pagination.list_call_get_all_results(
                                region_values['logging_client'].list_logs,
                                log_group.id
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
                                    "time_created": log.time_created,
                                    "time_last_modified": log.time_last_modified,

                                }
                                try:
                                    if log.configuration:
                                        log_record["configuration_compartment_id"] = log.configuration.compartment_id,
                                        log_record["source_category"] = log.configuration.source.category,
                                        log_record["source_parameters"] = log.configuration.source.parameters,
                                        log_record["source_resource"] = log.configuration.source.resource,
                                        log_record["source_service"] = log.configuration.source.service,
                                        log_record["source_source_type"] = log.configuration.source.source_type
                                    if log.configuration.source.service == 'flowlogs':
                                        self.__subnet_logs.append(
                                            log.configuration.source.resource)
                                    elif log.configuration.source.service == 'objectstorage' and 'write' in log.configuration.source.category:
                                        # Only write logs
                                        self.__write_bucket_logs.append(
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
        print("Processing Vaults and Keys...")
        try:
            for region_key, region_values in self.__regions.items():
                # Iterating through compartments
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        vaults_data = oci.pagination.list_call_get_all_results(
                            region_values['vault_client'].list_vaults,
                            compartment.id
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
                                "time_created": vlt.time_created,
                                "vault_type": vlt.time_created,
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
                                            # .strftime('%Y-%m-%d %H:%M:%S'),
                                            "time_created": key.time_created,
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
    # Audit Configuration
    ##########################################################################
    def __audit_read__tenancy_audit_configuration(self):
        # Pulling the Audit Configuration
        print("Processing Audit Configuration...")
        try:
            self.__audit_retention_period = self.__regions[self.__home_region]['audit_client'].get_configuration(
                self.__tenancy.id).data.retention_period_days
        except Exception as e:
            if "NotAuthorizedOrNotFound" in str(e):
                self.__audit_retention_period = -1
                print("\t***Access to audit retention requires the user to be part of the Administrator group")
            else:
                raise RuntimeError("Error in __audit_read__tenancy_audit_configuration " + str(e.args))
            
        return self.__audit_retention_period

    ##########################################################################
    # Cloud Guard Configuration
    ##########################################################################
    def __cloud_guard_read_cloud_guard_configuration(self):
        print("Processing Cloud Guard Configuration...")
        try:
            self.__cloud_guard_config = self.__regions[self.__home_region]['cloud_guard_client'].get_configuration(
                self.__tenancy.id).data.status
            return self.__cloud_guard_config
        except Exception as e:
            self.__cloud_guard_config = 'DISABLED'
            print("***Cloud Guard service requires a PayGo account")

    ##########################################################################
    # Identity Password Policy
    ##########################################################################
    def __identity_read_tenancy_password_policy(self):
        print("Processing Tenancy Password Policy...")
        try:
            self.__tenancy_password_policy = self.__regions[self.__home_region]['identity_client'].get_authentication_policy(
                self.__tenancy.id).data

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
        print("Processing Subscriptions...")
        try:
            for region_key, region_values in self.__regions.items():
                # Iterate through compartments to get all subscriptions
                for compartment in self.__compartments:
                    if self.__if_not_managed_paas_compartment(compartment.name):
                        subs_data = oci.pagination.list_call_get_all_results(
                            region_values['ons_subs_client'].list_subscriptions,
                            compartment.id
                        ).data
                        for sub in subs_data:
                            record = {
                                "id": sub.id,
                                "compartment_id": sub.compartment_id,
                                "created_time": sub.created_time,
                                "endpoint": sub.endpoint,
                                "protocol": sub.protocol,
                                "topic_id": sub.topic_id,
                                "lifecycle_state": sub.lifecycle_state,
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
        print("Processing Tag Defaults..")
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
                    "time_created": tag.time_created,
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
    # Resources in root compartment
    ##########################################################################
    def __search_resources_in_root_compartment(self):
        
        # query = []
        # resources_in_root_data = []
        # record = []
        query = "query VCN, instance, volume, filesystem, bucket, autonomousdatabase, database, dbsystem resources where compartmentId = '" + self.__tenancy.id + "'"
        print("Processing resources in the root compartment...")
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
    def __report_analyze_tenancy_data(self):
        
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
                    if self.api_key_time_max_datetime >= key['time_created'] and key['lifecycle_state'] == 'ACTIVE':
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
                    if self.api_key_time_max_datetime >= key['time_created'] and key['lifecycle_state'] == 'ACTIVE':
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
                    if self.api_key_time_max_datetime >= key['time_created'] and key['lifecycle_state'] == 'ACTIVE':
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
            if not(analytics_instance['network_endpoint_details']):
                self.cis_foundations_benchmark_1_2['2.7']['Status'] = False
                self.cis_foundations_benchmark_1_2['2.7']['Findings'].append(
                    analytics_instance)    
            elif analytics_instance['network_endpoint_details']:
                if "0.0.0.0/0" in str(analytics_instance['network_endpoint_details']):
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
            event_dict = json.loads(jsonable_str)
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
        if self.__cloud_guard_config == 'ENABLED':
            self.cis_foundations_benchmark_1_2['3.15']['Status'] = True
        else:
            self.cis_foundations_benchmark_1_2['3.15']['Status'] = False

        # CIS Check 3.16 - Encryption keys over 365
        # Generating list of keys
        for vault in self.__vaults:
            for key in vault['keys']:
                if self.kms_key_time_max_datetime >= key['time_created']:
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
    # Orchestrates data collection - analysis and report generation
    ##########################################################################

    def report_generate_cis_report(self, level=2):
        # This function reports generates CSV reports

        # Collecting all the tenancy data
        self.__report_collect_tenancy_data()

        # Analyzing Data in reports
        self.__report_analyze_tenancy_data()

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
        self.__print_header("Writing reports to CSV")
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

        if self.__output_raw_data:
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
                    self.__report_directory, "raw_data", "identity_dyanmic_groups", self.__dynamic_groups)
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
                    self.__report_directory, "raw_data", "file_stroage_system", self.__file_storage_system)
            list_report_file_names.append(report_file_name)
            
            report_file_name = self.__print_to_csv_file(
                    self.__report_directory, "raw_data", "vaults_and_keys", self.__vaults)
            list_report_file_names.append(report_file_name)
    
            report_file_name = self.__print_to_csv_file(
                    self.__report_directory, "raw_data", "ons_subscriptions", self.__subscriptions)
            list_report_file_names.append(report_file_name)
    
            if self.__output_bucket:
                for raw_report in list_report_file_names:
                    if raw_report:
                        self.__os_copy_report_to_object_storage(
                            self.__output_bucket, raw_report)
    
    
    
    def __report_collect_tenancy_data(self):
        
        ######  Runs identity functions only in home region
        self.__identity_read_groups_and_membership()
        self.__identity_read_compartments()
        self.__identity_read_users()
        self.__identity_read_tenancy_password_policy()
        self.__identity_read_dynamic_groups()
        self.__audit_read__tenancy_audit_configuration()
        self.__identity_read_tag_defaults()
        self.__identity_read_tenancy_policies()
        self.__cloud_guard_read_cloud_guard_configuration()

        # The above checks are run in the home region 
        if self.__home_region not in self.__regions_to_run_in and not(self.__run_in_all_regions):
            self.__regions.pop(self.__home_region)

        self.__identity_read_availability_domains()
        self.__search_resources_in_root_compartment()
        self.__vault_read_vaults()
        self.__os_read_buckets()
        self.__logging_read_log_groups_and_logs()
        self.__events_read_event_rules()
        self.__ons_read_subscriptions()
        self.__network_read_network_security_lists()
        self.__network_read_network_security_groups_rules()
        self.__network_read_network_subnets()
        self.__adb_read_adbs()
        self.__oic_read_oics()
        self.__oac_read_oacs()
        self.__block_volume_read_block_volumes()
        self.__boot_volume_read_boot_volumes()
        self.__fss_read_fsss()

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
    parser.add_argument('-ip', action='store_true', default=False,
                        dest='is_instance_principals', help='Use Instance Principals for Authentication ')
    parser.add_argument('-dt', action='store_true', default=False,
                        dest='is_delegation_token', help='Use Delegation Token for Authentication in Cloud Shell' )
    cmd = parser.parse_args()

    config, signer = create_signer(cmd.file_location, cmd.config_profile, cmd.is_instance_principals, cmd.is_delegation_token)
    report = CIS_Report(config, signer, cmd.proxy, cmd.output_bucket, cmd.report_directory, cmd.print_to_screen, cmd.regions, cmd.raw)
    report.report_generate_cis_report(int(cmd.level))



##########################################################################
# Main
##########################################################################
execute_report()
