##########################################################################
# Copyright (c) 2016, 2020, Oracle and/or its affiliates.  All rights reserved.
# This software is dual-licensed to you under the Universal Permissive License (UPL) 1.0 as shown at https://oss.oracle.com/licenses/upl or Apache License 2.0 as shown at http://www.apache.org/licenses/LICENSE-2.0. You may choose either license.
#
# cis_reports.py
# @author base: Adi Zohar
# @author: Josh Hammer and Andre Correa
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
    
    # CIS Foundation benchmark 1.1 
    cis_foundations_benchmark_1_1 = {
        '1.1': {'section' : 'Identity and Access Management', 'recommendation_#' : '1.1', 'Title' : 'Ensure service level admins are created to manage resources of particular service','Status' : True, 'Level' : 1 , 'Findings' : []},
        '1.2': {'section' : 'Identity and Access Management', 'recommendation_#' : '1.2', 'Title' : 'Ensure permissions on all resources are given only to the tenancy administrator group','Status' : True, 'Level' : 1 , 'Findings' : []},
        '1.3': {'section' : 'Identity and Access Management', 'recommendation_#' : '1.3', 'Title' : 'Ensure IAM administrators cannot update tenancy Administrators group','Status' : True, 'Level' : 1 , 'Findings' : []},
        '1.4': {'section' : 'Identity and Access Management', 'recommendation_#' : '1.4', 'Title' : 'Ensure IAM password policy requires minimum length of 14 or greater','Status' : True, 'Level' : 1 , 'Findings' : []},
        '1.5': {'section' : 'Identity and Access Management', 'recommendation_#' : '1.5', 'Title' : 'Ensure IAM password policy expires passwords within 365 days','Status' : True, 'Level' : 1 , 'Findings' : []},
        '1.6': {'section' : 'Identity and Access Management', 'recommendation_#' : '1.6', 'Title' : 'Ensure IAM password policy prevents password reuse','Status' : True, 'Level' : 1 , 'Findings' : []},
        '1.7': {'section' : 'Identity and Access Management', 'recommendation_#' : '1.7', 'Title' : 'Ensure MFA is enabled for all users with a console password','Status' : True, 'Level' : 1 , 'Findings' : []},
        '1.8': {'section' : 'Identity and Access Management', 'recommendation_#' : '1.8', 'Title' : 'Ensure user API keys rotate within 90 days or less','Status' : True, 'Level' : 1 , 'Findings' : []},
        '1.9': {'section' : 'Identity and Access Management', 'recommendation_#' : '1.9', 'Title' : 'Ensure user customer secret keys rotate within 90 days or less','Status' : True, 'Level' : 1 , 'Findings' : []},
        '1.10': {'section' : 'Identity and Access Management', 'recommendation_#' : '1.10', 'Title' : 'Ensure user auth tokens rotate within 90 days or less','Status' : True, 'Level' : 1 , 'Findings' : []},
        '1.11': {'section' : 'Identity and Access Management', 'recommendation_#' : '1.11', 'Title' : 'Ensure API keys are not created for tenancy administrator users','Status' : True, 'Level' : 1 , 'Findings' : []},
        '1.12': {'section' : 'Identity and Access Management', 'recommendation_#' : '1.12', 'Title' : 'Ensure all OCI IAM user accounts have a valid and current email address','Status' : True, 'Level' : 1 , 'Findings' : []},

        '2.1': {'section' : 'Networking', 'recommendation_#' : '2.1', 'Title' : 'Ensure no security lists allow ingress from 0.0.0.0/0 to port 22','Status' : True, 'Level' : 1 , 'Findings' : []},
        '2.2': {'section' : 'Networking', 'recommendation_#' : '2.2', 'Title' : 'Ensure no security lists allow ingress from 0.0.0.0/0 to port 3389','Status' : True, 'Level' : 1 , 'Findings' : []},
        '2.3': {'section' : 'Networking', 'recommendation_#' : '2.3', 'Title' : 'Ensure no network security groups allow ingress from 0.0.0.0/0 to port 22','Status' : True, 'Level' : 1 , 'Findings' : []},
        '2.4': {'section' : 'Networking', 'recommendation_#' : '2.4', 'Title' : 'Ensure no network security groups allow ingress from 0.0.0.0/0 to port 3389','Status' : True, 'Level' : 1 , 'Findings' : []},
        '2.5': {'section' : 'Networking', 'recommendation_#' : '2.5', 'Title' : 'Ensure the default security list of every VCN restricts all traffic except ICMP','Status' : True, 'Level' : 1 , 'Findings' : []},

        '3.1': {'section' : 'Logging and Monitoring', 'recommendation_#' : '3.1', 'Title' : 'Ensure audit log retention period is set to 365 days','Status' : True, 'Level' : 1 , 'Findings' : []},
        '3.2': {'section' : 'Logging and Monitoring', 'recommendation_#' : '3.2', 'Title' : 'Ensure default tags are used on resources','Status' : True, 'Level' : 1 , 'Findings' : []},
        '3.3': {'section' : 'Logging and Monitoring', 'recommendation_#' : '3.3', 'Title' : 'Create at least one notification topic and subscription to receive monitoring alerts','Status' : False, 'Level' : 1 , 'Findings' : []},
        '3.4': {'section' : 'Logging and Monitoring', 'recommendation_#' : '3.4', 'Title' : 'Ensure a notification is configured for Identity Provider changes','Status' : False, 'Level' : 1 , 'Findings' : []},
        '3.5': {'section' : 'Logging and Monitoring', 'recommendation_#' : '3.5', 'Title' : 'Ensure a notification is configured for IdP group mapping changes','Status' : False, 'Level' : 1 , 'Findings' : []},
        '3.6': {'section' : 'Logging and Monitoring', 'recommendation_#' : '3.6', 'Title' : 'Ensure a notification is configured for IAM group changes','Status' : False, 'Level' : 1 , 'Findings' : []},
        '3.7': {'section' : 'Logging and Monitoring', 'recommendation_#' : '3.7', 'Title' : 'Ensure a notification is configured for IAM policy changes','Status' : True, 'Level' : 1 , 'Findings' : []},
        '3.8': {'section' : 'Logging and Monitoring', 'recommendation_#' : '3.8', 'Title' : 'Ensure a notification is configured for user changes','Status' : False, 'Level' : 1 , 'Findings' : []},
        '3.9': {'section' : 'Logging and Monitoring', 'recommendation_#' : '3.9', 'Title' : 'Ensure a notification is configured for VCN changes','Status' : False, 'Level' : 1 , 'Findings' : []},
        '3.10': {'section' : 'Logging and Monitoring', 'recommendation_#' : '3.10', 'Title' : 'Ensure a notification is configured for  changes to route tables','Status' : False, 'Level' : 1 , 'Findings' : []},
        '3.11': {'section' : 'Logging and Monitoring', 'recommendation_#' : '3.11', 'Title' : 'Ensure a notification is configured for  security list changes','Status' : False, 'Level' : 1 , 'Findings' : []},
        '3.12': {'section' : 'Logging and Monitoring', 'recommendation_#' : '3.12', 'Title' : 'Ensure a notification is configured for  network security group changes','Status' : False, 'Level' : 1 , 'Findings' : []},
        '3.13': {'section' : 'Logging and Monitoring', 'recommendation_#' : '3.13', 'Title' : 'Ensure a notification is configured for  changes to network gateways','Status' : True, 'Level' : 1 , 'Findings' : []},
        '3.14': {'section' : 'Logging and Monitoring', 'recommendation_#' : '3.14', 'Title' : 'Ensure VCN flow logging is enabled for all subnets','Status' : True, 'Level' : 2 , 'Findings' : []},
        '3.15': {'section' : 'Logging and Monitoring', 'recommendation_#' : '3.15', 'Title' : 'Ensure Cloud Guard is enabled in the root compartment of the tenancy','Status' : True, 'Level' : 1 , 'Findings' : []},
        '3.16': {'section' : 'Logging and Monitoring', 'recommendation_#' : '3.16', 'Title' : 'Ensure customer created Customer Managed Key (CMK) is rotated at least annually','Status' : True, 'Level' : 1 , 'Findings' : []},
        '3.17': {'section' : 'Logging and Monitoring', 'recommendation_#' : '3.17', 'Title' : 'Ensure write level Object Storage logging is enabled for all buckets','Status' : True, 'Level' : 2 , 'Findings' : []},

        '4.1': {'section' : 'Object Storage', 'recommendation_#' : '4.1', 'Title' : 'Ensure no Object Storage buckets are publicly visible','Status' : True, 'Level' : 1 , 'Findings' : []},
        '4.2': {'section' : 'Object Storage', 'recommendation_#' : '4.2', 'Title' : 'Ensure Object Storage Buckets are encrypted with a Customer Managed Key (CMK)','Status' : True, 'Level' : 2,'Findings' : [] },

        '5.1': {'section' : 'Asset Management', 'recommendation_#' : '5.1', 'Title' : 'Create at least one compartment in your tenancy to store cloud resources','Status' : True, 'Level' : 1 , 'Findings' : []},
        '5.2': {'section' : 'Asset Management', 'recommendation_#' : '5.2', 'Title' : 'Ensure no resources are created in the root compartment','Status' : True, 'Level' : 1 , 'Findings' : []}
}
    # CIS monitoring notifications check
    cis_monitoring_checks = {
        "3.4" : [
            'com.oraclecloud.identitycontrolplane.createidentityprovider',
            'com.oraclecloud.identitycontrolplane.deleteidentityprovider',
            'com.oraclecloud.identitycontrolplane.updateidentityprovider'
        ],
        "3.5" : [
            'com.oraclecloud.identitycontrolplane.createpolicy',
            'com.oraclecloud.identitycontrolplane.deletepolicy',
            'com.oraclecloud.identitycontrolplane.updatepolicy'
        ],
        "3.6" : [
            'com.oraclecloud.identitycontrolplane.creategroup',
            'com.oraclecloud.identitycontrolplane.deletegroup',
            'com.oraclecloud.identitycontrolplane.updategroup'
        ],
        "3.7" : [
            'com.oraclecloud.identitycontrolplane.createpolicy',
            'com.oraclecloud.identitycontrolplane.deletepolicy',
            'com.oraclecloud.identitycontrolplane.updatepolicy'
        ],
        "3.8" : [
            'com.oraclecloud.identitycontrolplane.createuser',
            'com.oraclecloud.identitycontrolplane.deleteuser',
            'com.oraclecloud.identitycontrolplane.updateuser',
            'com.oraclecloud.identitycontrolplane.updateusercapabilities',
            'com.oraclecloud.identitycontrolplane.updateuserstate'
        ],
        "3.9" : [
            'com.oraclecloud.virtualnetwork.createvcn',
            'com.oraclecloud.virtualnetwork.deletevcn',
            'com.oraclecloud.virtualnetwork.updatevcn'
        ],
        "3.10" : [
            'com.oraclecloud.virtualnetwork.changeroutetablecompartment',
            'com.oraclecloud.virtualnetwork.createroutetable',
            'com.oraclecloud.virtualnetwork.deleteroutetable',
            'com.oraclecloud.virtualnetwork.updateroutetable'
        ],
        "3.11" : [
            'com.oraclecloud.virtualnetwork.changesecuritylistcompartment',
            'com.oraclecloud.virtualnetwork.createsecuritylist',
            'com.oraclecloud.virtualnetwork.deletesecuritylist',
            'com.oraclecloud.virtualnetwork.updatesecuritylist'
        ],
        "3.12" : [
            'com.oraclecloud.virtualnetwork.changenetworksecuritygroupcompartment',
            'com.oraclecloud.virtualnetwork.createnetworksecuritygroup',
            'com.oraclecloud.virtualnetwork.deletenetworksecuritygroup',
            'com.oraclecloud.virtualnetwork.updatenetworksecuritygroup'
        ],
        "3.13" : [
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

    # Class variables
    _DAYS_OLD = 90
    __KMS_DAYS_OLD = 365
    
    # Tenancy Data
    __tenancy = None
    __cloud_guard_config = None

    # For IAM Checks
    __tenancy_password_policy = None
    __compartments = []
    __policies = [] 
    __users = []
    __groups_to_users = []
    __tag_defaults = []

    __buckets = []

    # For Networking checks
    __network_security_groups = []
    __network_security_lists = []
    __network_subnets = []

    __event_rules = []

    __logging_list = []
    # For Logging & Monitoring checks
    __subnet_logs = []
    __write_bucket_logs = []

    # For Vaults and Keys checks
    __vaults = []
    
    # For ONS Subscriptions 
    __subscriptions = []

    # Results from Advanced search query
    __resources_in_root_compartment =[]

    # Start print time info
    start_datetime = datetime.datetime.now().replace(tzinfo=pytz.UTC)
    start_time_str = str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    
    # For User based key checks
    start_date = str(datetime.datetime.now().strftime("%Y-%m-%d"))
    api_key_time_max_datetime = start_datetime - datetime.timedelta(days=_DAYS_OLD)

    # For KMS check
    kms_key_time_max_datetime = start_datetime - datetime.timedelta(days=__KMS_DAYS_OLD)


    def __init__(self, config, signer, proxy, output_bucket, report_directory, print_to_screen):
        # Start print time info
        self.__print_header("Running CIS Reports...")
        print("Written by Josh Hammer & Andre Correa, updated June 4, 2021.")
        print("oci-python-sdk version 2.39.0")
        print("Starts at " + self.start_time_str )
        self.__config = config
        self.__signer = signer
        # Working with input variables from 
        self.__output_bucket = output_bucket
        # By Default it is today's date
        if report_directory:
            self.__report_directory = report_directory
        else:
            self.__report_directory = self.start_date

        # By Default it is passed True to print all output
        if print_to_screen.upper() == 'TRUE':
            self.__print_to_screen = True
        else:
            self.__print_to_screen = False

        try:
            self.__identity = oci.identity.IdentityClient(self.__config, signer=self.__signer)
            if proxy:
                self.__identity.base_client.session.proxies = {'https': proxy}

            self.__audit = oci.audit.AuditClient(self.__config, signer=self.__signer)
            if proxy:
                self.__audit.base_client.session.proxies = {'https': proxy}
            
            self.__cloud_guard = oci.cloud_guard.CloudGuardClient(self.__config, signer=self.__signer)
            if proxy:
                self.__cloud_guard.base_client.session.proxies = {'https': proxy}

            self.__search = oci.resource_search.ResourceSearchClient(self.__config, signer=self.__signer)
            if proxy:
                self.__search.base_client.session.proxies = {'https': proxy}

            self.__network = oci.core.VirtualNetworkClient(self.__config, signer=self.__signer)
            if proxy:
                self.__network.base_client.session.proxies = {'https': proxy}

            self.__events = oci.events.EventsClient(self.__config, signer=self.__signer)
            if proxy:
                self.__events.base_client.session.proxies = {'https': proxy}

            self.__logging = oci.logging.LoggingManagementClient(self.__config, signer=self.__signer)
            if proxy:
                self.__logging.base_client.session.proxies = {'https': proxy}

            self.__os_client = oci.object_storage.ObjectStorageClient(self.__config, signer=self.__signer)
            if proxy:
                self.__os_client.base_client.session.proxies = {'https': proxy}
            
            self.__vault = oci.key_management.KmsVaultClient(self.__config, signer=self.__signer)
            if proxy:
                self.__vault.session.proxies = {'https': proxy}

            self.__ons_subs = oci.ons.NotificationDataPlaneClient(self.__config, signer=self.__signer)
            if proxy:
                self.__ons_subs.session.proxies = {'https': proxy}

            # Getting Tenancy Data and Region data
            self.__tenancy = self.__identity.get_tenancy(config["tenancy"]).data
            self.__regions = self.__identity.list_region_subscriptions(self.__tenancy.id).data

        except Exception as e:
                raise RuntimeError("Failed to create service objects" + str(e.args))
    
    ##########################################################################
    # Check for Managed PaaS Compartment
    ##########################################################################
    def __if_not_managed_paas_compartment(self,name):
        return name != "ManagedCompartmentForPaaS"
      
    ##########################################################################
    # Load compartments
    ##########################################################################
    def __identity_read_compartments(self):

        print("Processing Compartments...")
        try:
            self.__compartments = oci.pagination.list_call_get_all_results(
                self.__identity.list_compartments,
                self.__tenancy.id,
                compartment_id_in_subtree=True
            ).data

            # Add root compartment which is not part of the list_compartments
            self.__compartments.append(self.__tenancy)

            return self.__compartments

        except Exception as e:
            raise RuntimeError("Error in identity_read_compartments: " + str(e.args))

    ##########################################################################
    # Load Groups and Group membership
    ##########################################################################
    def __identity_read_groups_and_membership(self):
        print("Processing User Groups and Group Memberships...")
        try:
            # Getting all Groups in the Tenancy
            groups_data = oci.pagination.list_call_get_all_results(
                self.__identity.list_groups,
                self.__tenancy.id
            ).data
            # For each group in the tenacy getting the group's membership
            for grp in groups_data:
                membership = oci.pagination.list_call_get_all_results(
                    self.__identity.list_user_group_memberships,
                    self.__tenancy.id,
                    group_id=grp.id
                ).data
                for member in membership:
                    group_record = {
                        "id" : grp.id,
                        "name" : grp.name,
                        "description" : grp.description,
                        "lifecycle_state" : grp.lifecycle_state,
                        "time_created" : grp.time_created,
                        "user_id" : member.user_id
                    }
                    # Adding a record per user to group
                    self.__groups_to_users.append(group_record)
            return self.__groups_to_users
        except Exception as e:
            RuntimeError("Error in __identity_read_groups_and_membership" + str(e.args))

    ##########################################################################
    # Load users
    ##########################################################################
    def __identity_read_users(self):
        print("Processing Users...")
        try:
            # Getting all users in the Tenancy
            users_data = oci.pagination.list_call_get_all_results(
                self.__identity.list_users,
                self.__tenancy.id
            ).data
            # Adding record to the users
            for user in users_data:
                record = {
                    'id' : user.id,
                    'defined_tags' : user.defined_tags,
                    'description' : user.description,
                    'email' : user.email,
                    'email_verified' : user.email_verified,
                    'external_identifier' : user.external_identifier,
                    'identity_provider_id' : user.identity_provider_id,
                    'is_mfa_activated' : user.is_mfa_activated,
                    'lifecycle_state' : user.lifecycle_state,
                    'time_created' : user.time_created,
                    'name' : user.name,
                    'groups' :[]
                }
                # Adding Groups to the user
                for group in self.__groups_to_users:
                    if user.id == group['user_id']:
                        record['groups'].append(group['name'])
                
                record['api_keys'] = self.__identity_read_user_api_key(user.id)
                record['auth_tokens'] = self.__identity_read_user_auth_token(user.id)
                record['customer_secret_keys'] = self.__identity_read_user_customer_secret_key(user.id)

                self.__users.append(record)

            return self.__users

        except Exception as e:
            raise RuntimeError("Error in __identity_read_users: " + str(e.args))

    ##########################################################################
    # Load user api keys
    ##########################################################################
    def __identity_read_user_api_key(self,user_ocid):
        api_keys = []
        try:
            user_api_keys_data = oci.pagination.list_call_get_all_results(
                self.__identity.list_api_keys,
                user_ocid
            ).data

            for api_key in user_api_keys_data:
                record = {
                    'id' : api_key.key_id,
                    'fingerprint' : api_key.fingerprint,
                    'inactive_status' : api_key.inactive_status,
                    'lifecycle_state' : api_key.lifecycle_state,
                    'time_created' : api_key.time_created, #.strftime('%Y-%m-%d %H:%M:%S')
                }
                api_keys.append(record)


            return api_keys

        except Exception as e:
            raise RuntimeError("Error in identity_read_user_api_key: " + str(e.args))

    ##########################################################################
    # Load user auth tokens
    ##########################################################################
    def __identity_read_user_auth_token(self, user_ocid):
        auth_tokens = []
        try:
            auth_tokens_data = oci.pagination.list_call_get_all_results(
                self.__identity.list_auth_tokens,
                user_ocid
            ).data

            for token in auth_tokens_data:
                record = {
                'id' : token.id,
                'description' : token.description,
                'inactive_status' : token.inactive_status,
                'lifecycle_state' : token.lifecycle_state,
                'time_created' : token.time_created, #.strftime('%Y-%m-%d %H:%M:%S'),
                'time_expires' : token.time_expires,
                'token' : token.token
                     
                }
                auth_tokens.append(record)

            return auth_tokens

        except Exception as e:
            raise RuntimeError("Error in identity_read_user_auth_token: " + str(e.args))

    ##########################################################################
    # Load user customer secret key
    ##########################################################################
    def __identity_read_user_customer_secret_key(self,user_ocid):
        customer_secret_key = []
        try:
            customer_secret_key_data = oci.pagination.list_call_get_all_results(
                self.__identity.list_customer_secret_keys,
                user_ocid
            ).data

            for key in customer_secret_key_data:
                record = {
                'id' : key.id,
                'display_name' : key.display_name,
                'inactive_status' : key.inactive_status,
                'lifecycle_state' : key.lifecycle_state,
                'time_created' : key.time_created, #.strftime('%Y-%m-%d %H:%M:%S'),
                'time_expires' : key.time_expires,              
                
                }
                customer_secret_key.append(record)

            return customer_secret_key

        except Exception as e:
            raise RuntimeError("Error in identity_read_user_customer_secret_key: " + str(e.args))

    ##########################################################################
    # Tenancy IAM Policies
    ##########################################################################
    def __identity_read_tenancy_policies(self):

        print("Processing IAM Policies in root...")
        # Get all policy at the tenacy level
        try:
            for compartment in self.__compartments:
                policies_data = oci.pagination.list_call_get_all_results(
                    self.__identity.list_policies,
                    compartment.id
                ).data
                for policy in policies_data:
                    record = {
                        "id" : policy.id,
                        "name" : policy.name,
                        "compartment_id" : policy.compartment_id,
                        "description" : policy.description,
                        "lifecycle_state" : policy.lifecycle_state,
                        "statements" : policy.statements
                    }
                    self.__policies.append(record)

            return self.__policies

        except Exception as e:
            raise RuntimeError("Error in __identity_read_tenancy_policies: " + str(e.args))

    ##########################################################################
    # Get Objects Store Buckets
    ##########################################################################
    def __os_read_buckets(self):
        print("Processing Object Store Buckets...")
        # Getting OS Namespace
        try: 
            self.__os_namespace = self.__os_client.get_namespace().data
        except Exception as e:
            raise RuntimeError("Error in __os_read_buckets could not load namespace " + str(e.args))

        try:
            # Collecting buckets from each compartment
            for compartment in self.__compartments:
                # Skipping the managed pass compartment
                if self.__if_not_managed_paas_compartment(compartment.name):
                    buckets_data = oci.pagination.list_call_get_all_results(
                        self.__os_client.list_buckets,
                        self.__os_namespace,
                        compartment.id
                    ).data

                    # Getting Bucket Info
                    for bucket in buckets_data:
                        try:
                            bucket_info = self.__os_client.get_bucket(self.__os_namespace,bucket.name).data
                            record = {
                                "id" : bucket_info.id,
                                "name" : bucket_info.name,
                                "kms_key_id" : bucket_info.kms_key_id,
                                "namespace" : bucket_info.namespace,
                                "compartment_id": bucket_info.compartment_id,
                                "object_events_enabled" : bucket_info.object_events_enabled,
                                "public_access_type" : bucket_info.public_access_type,
                                "replication_enabled" : bucket_info.replication_enabled,
                                "is_read_only" : bucket_info.is_read_only,
                                "storage_tier" : bucket_info.storage_tier,
                                "time_created" : bucket_info.time_created,
                                "versioning" : bucket_info.versioning,
                                "notes": ''
                            }
                            self.__buckets.append(record)
                        except Exception as e:
                            record = {
                                "id" : "",
                                "name" : bucket.name,
                                "kms_key_id" : "",
                                "namespace": bucket.namespace,
                                "compartment_id": bucket.compartment_id,
                                "object_events_enabled" : "",
                                "public_access_type" : "",
                                "replication_enabled" : "",
                                "is_read_only" : "",
                                "storage_tier" : "",
                                "time_created" : bucket.time_created,
                                "versioning" : "",
                                "notes": str(e)
                            }
                            self.__buckets.append(record)
            # Returning Buckets
            return self.__buckets
        except Exception as e:
            raise RuntimeError("Error in __os_read_buckets " + str(e.args))

    ##########################################################################
    # Network Security Groups
    ##########################################################################
    def __network_read_network_security_groups_rules(self):
        
        print("Processing Network Security Groups...")
        # print(network)
        # print(compartments)
        # Loopig Through Compartments Except Mnaaged
        try:
            for compartment in self.__compartments:
                if self.__if_not_managed_paas_compartment(compartment.name):
                    nsgs_data = oci.pagination.list_call_get_all_results(
                            self.__network.list_network_security_groups,
                            compartment_id=compartment.id
                        ).data
                    # Looping through NSGs to to get 
                    for nsg in nsgs_data:
                        record = {
                            "compartment_id" : nsg.compartment_id,
                            "display_name" : nsg.display_name,
                            "id" : nsg.id,
                            "lifecycle_state" : nsg.lifecycle_state,
                            "time_created" : nsg.time_created,
                            "vcn_id" : nsg.vcn_id,
                            "rules" : []
                        }
                        nsg_rules = oci.pagination.list_call_get_all_results( 
                            self.__network.list_network_security_group_security_rules,
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
                                "udp_options": rule.udp_options
                                
                            }
                            # Append NSG Rules to NSG
                            record['rules'].append(rule_record)
                        # Append NSG to list of NSGs
                        self.__network_security_groups.append(record)


            return self.__network_security_groups
        except Exception as e:
            raise RuntimeError("Error in __network_read_network_security_groups_rules " + str(e.args))

    ##########################################################################
    # Network Security Lists
    ##########################################################################
    def __network_read_network_security_lists(self):
        
        print("Processing Network Security Lists...")
        # print(network)
        # print(compartments)
        # Loopig Through Compartments Except Mnaaged
        try:
            for compartment in self.__compartments:
                if self.__if_not_managed_paas_compartment(compartment.name):
                    security_lists_data = oci.pagination.list_call_get_all_results(
                            self.__network.list_security_lists,
                            compartment.id
                        ).data
                    # Looping through Security Lists to to get 
                    for security_list in security_lists_data:
                        record = {
                            "compartment_id" : security_list.compartment_id,
                            "display_name" : security_list.display_name,
                            "id" : security_list.id,
                            "lifecycle_state" : security_list.lifecycle_state,
                            "time_created" : security_list.time_created,
                            "vcn_id" : security_list.vcn_id,
                            "egress_security_rules" : [],
                            "ingress_security_rules" : []
                        }
                        for egress_rule in security_list.egress_security_rules:
                            erule = {
                                "description" : egress_rule.description,
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
                                "description" : ingress_rule.description,
                                "source" : ingress_rule.source,
                                "source_type" : ingress_rule.source_type,
                                "icmp_options": ingress_rule.icmp_options,
                                "is_stateless": ingress_rule.is_stateless,
                                "protocol": ingress_rule.protocol,
                                "tcp_options": ingress_rule.tcp_options,
                                "udp_options": ingress_rule.udp_options
                            }
                            record['ingress_security_rules'].append(irule)

                        # Append Security List to list of NSGs
                        self.__network_security_lists.append(record)

            return self.__network_security_lists
        except Exception as e:
            raise RuntimeError("Error in __network_read_network_security_lists " + str(e.args))

    ##########################################################################
    # Network Subnets Lists
    ##########################################################################
    def __network_read_network_subnets(self):
        print("Processing Network Subnets...")
        try:
            # Looping through compartments in tenancy
            for compartment in self.__compartments:
                if self.__if_not_managed_paas_compartment(compartment.name):
                    subnets_data = oci.pagination.list_call_get_all_results(
                        self.__network.list_subnets,
                        compartment.id,
                        lifecycle_state="AVAILABLE"
                    ).data
                    # Looping through subnets in a compartment
                    try: 
                        for subnet in subnets_data:
                            record = {
                                "id" : subnet.id,
                                "availability_domain" : subnet.availability_domain,
                                "cidr_block" : subnet.cidr_block,
                                "compartment_id" : subnet.compartment_id,
                                "dhcp_options_id" : subnet.dhcp_options_id,
                                "display_name" : subnet.display_name,
                                "dns_label" : subnet.dns_label,
                                "ipv6_cidr_block" : subnet.ipv6_cidr_block,
                                "ipv6_virtual_router_ip" : subnet.ipv6_virtual_router_ip,
                                "lifecycle_state" : subnet.lifecycle_state,
                                "prohibit_public_ip_on_vnic" : subnet.prohibit_public_ip_on_vnic,
                                "route_table_id" : subnet.route_table_id,
                                "security_list_ids" : subnet.security_list_ids,
                                "subnet_domain_name" : subnet.subnet_domain_name,
                                "time_created" : subnet.time_created,
                                "vcn_id" : subnet.vcn_id,
                                "virtual_router_ip" : subnet.virtual_router_ip,
                                "virtual_router_mac" : subnet.virtual_router_mac

                            }
                            # Adding subnet to subnet list
                            self.__network_subnets.append(record)
                    except:
                            record = {
                                "id" : subnet.id,
                                "availability_domain" : subnet.availability_domain,
                                "cidr_block" : subnet.cidr_block,
                                "compartment_id" : subnet.compartment_id,
                                "dhcp_options_id" : subnet.dhcp_options_id,
                                "display_name" : subnet.display_name,
                                "dns_label" : subnet.dns_label,
                                "ipv6_cidr_block" : "",
                                "ipv6_virtual_router_ip" : "",                                
                                "lifecycle_state" : subnet.lifecycle_state,
                                "prohibit_public_ip_on_vnic" : subnet.prohibit_public_ip_on_vnic,
                                "route_table_id" : subnet.route_table_id,
                                "security_list_ids" : subnet.security_list_ids,
                                "subnet_domain_name" : subnet.subnet_domain_name,
                                "time_created" : subnet.time_created,
                                "vcn_id" : subnet.vcn_id,
                                "virtual_router_ip" : subnet.virtual_router_ip,
                                "virtual_router_mac" : subnet.virtual_router_mac

                            }
                            self.__network_subnets.append(record)

            return self.__network_subnets
        except Exception as e:
            raise RuntimeError("Error in __network_read_network_subnets " + str(e.args))

    ##########################################################################
    # Events
    ##########################################################################
    def __events_read_event_rules(self):

        print("Processing Event Rules...")
        try:
            for compartment in self.__compartments:
                if self.__if_not_managed_paas_compartment(compartment.name):
                    events_rules_data = oci.pagination.list_call_get_all_results(
                        self.__events.list_rules,
                        compartment.id
                        ).data

                    for event_rule in events_rules_data:
                        record = {
                            "compartment_id" : event_rule.compartment_id,
                            "condition" : event_rule.condition,
                            "description" : event_rule.description,
                            "display_name" : event_rule.display_name,
                            "id" : event_rule.id,
                            "is_enabled" : event_rule.is_enabled,
                            "lifecycle_state" : event_rule.lifecycle_state,
                            "time_created" : event_rule.time_created
                        }
                        self.__event_rules.append(record)
            
            return self.__event_rules
        except Exception as e:
            raise RuntimeError("Error in events_read_rules " + str(e.args))

    ##########################################################################
    # Logging - Log Groups and Logs
    ##########################################################################
    def __logging_read_log_groups_and_logs(self):

        print("Processing Log Groups and Logs...")

        try:
            # Looping through compartments
            for compartment in self.__compartments:
                # Checking if Managed Compartment cause I can't query it
                if self.__if_not_managed_paas_compartment(compartment.name):
                    # Getting Log Groups in compartment
                    log_groups = oci.pagination.list_call_get_all_results(
                            self.__logging.list_log_groups,
                            compartment.id
                        ).data
                    # Looping through log groups to get logs
                    for log_group in log_groups:
                        record = {
                            "compartment_id" : log_group.compartment_id,
                            "description" : log_group.description,
                            "display_name" : log_group.display_name,
                            "id" : log_group.id,
                            "time_created" : log_group.time_created,
                            "time_last_modified" : log_group.time_last_modified,
                            "logs" : []
                        }

                        logs = oci.pagination.list_call_get_all_results( 
                            self.__logging.list_logs,
                            log_group.id
                            ).data
                        for log in logs:
                            log_record = {
                                "compartment_id" : log.compartment_id,
                                "display_name" :  log.display_name,
                                "id" : log.id,
                                "is_enabled" : log.is_enabled,
                                "lifecycle_state" : log.lifecycle_state,
                                "log_group_id" : log.log_group_id,
                                "log_type" : log.log_type,
                                "retention_duration" : log.retention_duration,
                                "time_created" : log.time_created,
                                "time_last_modified" : log.time_last_modified,

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
                                    self.__subnet_logs.append(log.configuration.source.resource)
                                elif log.configuration.source.service == 'objectstorage' and 'write' in log.configuration.source.category:
                                    #Only write logs 
                                    self.__write_bucket_logs.append(log.configuration.source.resource)
                            except: 
                                pass
                            # Append Log to log List
                            record['logs'].append(log_record)
                        self.__logging_list.append(record)

            return self.__logging_list
        except Exception as e:
            raise RuntimeError("Error in __network_read_network_security_groups_rules " + str(e.args))

    ##########################################################################
    # Vault Keys 
    ##########################################################################
    def __vault_read_vaults(self):
        print("Processing Vaults and Keys...")
        # Iterating through compartments
        for compartment in self.__compartments:
            if self.__if_not_managed_paas_compartment(compartment.name):
                vaults_data = oci.pagination.list_call_get_all_results(
                    self.__vault.list_vaults,
                    compartment.id
                ).data
                # Get all Vaults in a compartment
                for vlt in vaults_data:
                    vault_record = {
                        "compartment_id" : vlt.compartment_id,
                        "crypto_endpoint" : vlt.crypto_endpoint,
                        "display_name" : vlt.display_name,
                        "id" : vlt.id,
                        "lifecycle_state" : vlt.lifecycle_state,
                        "management_endpoint" : vlt.management_endpoint,
                        "time_created" : vlt.time_created,
                        "vault_type" : vlt.time_created,
                        "keys" : []
                        }
                    # Checking for active Vaults only
                    if vlt.lifecycle_state == 'ACTIVE':
                        cur_key_client = oci.key_management.KmsManagementClient(self.__config, vlt.management_endpoint)
                        keys = oci.pagination.list_call_get_all_results(
                            cur_key_client.list_keys,
                            compartment.id
                        ).data
                        # Iterrating through Keys in Vaults
                        for key in keys:
                            key_record = {
                                "compartment_id" : key.compartment_id,
                                "display_name" : key.display_name,
                                "id" : key.id,
                                "lifecycle_state" : key.lifecycle_state,
                                "time_created" : key.time_created, #.strftime('%Y-%m-%d %H:%M:%S'),
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

                    self.__vaults.append(vault_record)
        
        return self.__vaults

    ##########################################################################
    # Audit Configuration
    ##########################################################################
    def __audit_read__tenancy_audit_configuration(self):
        # Pulling the Audit Configuration
        print("Processing Audit Configuration...")

        try:
            self.__audit_retention_period = self.__audit.get_configuration(self.__tenancy.id).data.retention_period_days
        except Exception as e:
            print(" Access to audit retention requires the user to be part of the Administrator group")
            self.__audit_retention_period = -1

        return self.__audit_retention_period
 
    ##########################################################################
    # Cloud Guard Configuration
    ##########################################################################
    def __cloud_guard_read_cloud_guard_configuration(self):
        print("Processing Cloud Guard Configuration...")
        try:
            self.__cloud_guard_config = self.__cloud_guard.get_configuration(self.__tenancy.id).data
            return self.__cloud_guard_config
        except Exception as e:
            raise RuntimeError("Error in __cloud_guard_read_cloud_guard_configuration " + str(e.args))

    ##########################################################################
    # Identity Password Policy 
    ##########################################################################
    def __identity_read_tenancy_password_policy(self):
        print("Processing Tenancy Password Policy...")
        try:
            self.__tenancy_password_policy = self.__identity.get_authentication_policy(self.__tenancy.id).data

        except Exception as e:
            raise RuntimeError("Error in __identity_read__tenancy_password_policy " + str(e.args))

    ##########################################################################
    # Oracle Notifications Services for Subscriptions
    ##########################################################################
    def __ons_read_subscriptions(self):
        print("Processing Subscriptions...")
        try:
            # Iterate through compartments to get all subscriptions
            for compartment in self.__compartments:
                if self.__if_not_managed_paas_compartment(compartment.name):
                    subs_data = oci.pagination.list_call_get_all_results(
                        self.__ons_subs.list_subscriptions,
                        compartment.id
                    ).data
                    for sub in subs_data:
                        record = {
                            "id" : sub.id,
                            "compartment_id" : sub.compartment_id,
                            "created_time" : sub.created_time,
                            "endpoint" : sub.endpoint,
                            "protocol" : sub.protocol,
                            "topic_id" : sub.topic_id,
                            "lifecycle_state" : sub.lifecycle_state
            
                        }
                        self.__subscriptions.append(record)
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
                self.__identity.list_tag_defaults,
                compartment_id=self.__tenancy.id
            ).data
            for tag in tag_defaults:
                record = {
                    "id" : tag.id,
                    "compartment_id" : tag.compartment_id,
                    "value" : tag.value,
                    "time_created" : tag.time_created,
                    "tag_definition_id" : tag.tag_definition_id,
                    "tag_definition_name" : tag.tag_definition_name,
                    "tag_namespace_id" : tag.tag_namespace_id,
                    "lifecycle_state" : tag.lifecycle_state
    
                }
                self.__tag_defaults.append(record)
            return self.__tag_defaults

        except Exception as e:
            raise RuntimeError("Error in __identity_read_tag_defaults " + str(e.args))
    
    ##########################################################################
    # Run advanced search structure query
    ##########################################################################
    def __search_run_structured_query(self, query):
        try:
            structured_search = oci.resource_search.models.StructuredSearchDetails(query=query, type='Structured', 
                matching_context_type=oci.resource_search.models.SearchDetails.MATCHING_CONTEXT_TYPE_NONE)
            search_results = self.__search.search_resources(structured_search).data.items

            return search_results
        
        except Exception as e:
            raise RuntimeError("Error in search_run_structure_query " + str(e.args))

    ##########################################################################
    # Resources in root compartment
    ##########################################################################
    def __search_resources_in_root_compartment(self):
        query = "query VCN, instance, volume, filesystem, bucket, autonomousdatabase, database, dbsystem resources where compartmentId = '" + self.__tenancy.id + "'"
        print("Processing resources in the root compartment...")
        resources_in_root_data = self.__search_run_structured_query(query)
        for item in resources_in_root_data:
            record = {
                "display_name" : item.display_name,
                "id" : item.identifier
            }
            self.__resources_in_root_compartment.append(record)
    
        return self.__resources_in_root_compartment

    ##########################################################################
    # Analyzes Tenancy Data for CIS Report 
    ##########################################################################
    def __report_analyze_tenancy_data(self):
        #print("Command Line : " + ' '.join(x for x in sys.argv[1:]))


        # 1.1 Check - checking if their are additional policies
        policy_counter = 0 
        for policy in self.__policies:
            for statement in policy['statements']:
                if "allow group".upper() in statement.upper() \
                    and not("to manage all-resources in tenancy".upper() in statement.upper()) \
                        and policy['name'].upper() != "Tenant Admin Policy".upper():
                    policy_counter+=1
            if policy_counter < 3:
                self.cis_foundations_benchmark_1_1['1.1']['Status'] = False
                self.cis_foundations_benchmark_1_1['1.1']['Findings'].append(policy)

        # 1.2 Check
        for policy in self.__policies:
            for statement in policy['statements']:
                if "allow group".upper() in statement.upper() \
                    and "to manage all-resources in tenancy".upper() in statement.upper() \
                    and policy['name'].upper() != "Tenant Admin Policy".upper():

                    self.cis_foundations_benchmark_1_1['1.2']['Status'] = False
                    self.cis_foundations_benchmark_1_1['1.2']['Findings'].append(policy)


        # 1.3 Check - May want to add a service check
        for policy in self.__policies:
            for statement in policy['statements']:
                if ("to use groups in tenancy".upper() in statement.upper() or \
                    "to use users in tenancy".upper() in statement.upper() or \
                        "to manage groups in tenancy".upper() in statement.upper() or 
                        "to manage users in tenancy".upper() in statement.upper()):
                    self.cis_foundations_benchmark_1_1['1.3']['Status'] = False
                    self.cis_foundations_benchmark_1_1['1.3']['Findings'].append(policy)
                    # Moving to the next policy 
                    break


        # 1.4 Check - Password Policy
        if self.__tenancy_password_policy.password_policy.is_lowercase_characters_required:
            self.cis_foundations_benchmark_1_1['1.4']['Status'] = True



        # 1.7 Check - Local Users w/o MFA
        for user in self.__users:
            if user['external_identifier'] == None and not(user['is_mfa_activated']) and user['lifecycle_state'] == 'ACTIVE':
                self.cis_foundations_benchmark_1_1['1.7']['Status'] = False
                self.cis_foundations_benchmark_1_1['1.7']['Findings'].append(user)

        # 1.8 Check - API Keys over 90
        for user in self.__users:
            if user['api_keys']:
                for key in user['api_keys']:
                    if self.api_key_time_max_datetime >= key['time_created'] and key['lifecycle_state'] == 'ACTIVE':
                        self.cis_foundations_benchmark_1_1['1.8']['Status'] = False
                        finding = {
                            "user_name" : user['name'],
                            "user_id" : user['id'],
                            "key_id" : key['id'],
                            'fingerprint' : key['fingerprint'],
                            'inactive_status' : key['inactive_status'],
                            'lifecycle_state' : key['lifecycle_state'],
                            'time_created' : key['time_created']
                        }
                        
                        self.cis_foundations_benchmark_1_1['1.8']['Findings'].append(finding)

        # CIS 1.9 Check - Old Customer Secrets
        for user in self.__users:
            if user['customer_secret_keys']:
                for key in user['customer_secret_keys']:
                    if self.api_key_time_max_datetime >= key['time_created'] and key['lifecycle_state'] == 'ACTIVE':
                        self.cis_foundations_benchmark_1_1['1.9']['Status'] = False

                        finding = {
                            "user_name" : user['name'],
                            "user_id" : user['id'],
                            "id" : key['id'],
                            'display_name' : key['display_name'],
                            'inactive_status' : key['inactive_status'],
                            'lifecycle_state' : key['lifecycle_state'],
                            'time_created' : key['time_created'],
                            'time_expires' : key['time_expires'],     
                        }
                        
                        self.cis_foundations_benchmark_1_1['1.9']['Findings'].append(finding)

        
        # CIS 1.10 Check - Old Auth Tokens
        for user in self.__users:
            if user['auth_tokens']:
                for key in user['auth_tokens']:
                    if self.api_key_time_max_datetime >= key['time_created'] and key['lifecycle_state'] == 'ACTIVE':
                        self.cis_foundations_benchmark_1_1['1.10']['Status'] = False

                        finding = {
                            "user_name" : user['name'],
                            "user_id" : user['id'],
                            "id" : key['id'],
                            "description" : key['description'],
                            "inactive_status" : key['inactive_status'],
                            "lifecycle_state" : key['lifecycle_state'],
                            "time_created" : key['time_created'],
                            "time_expires" : key['time_expires'],
                            "token" : key['token']   
                        }
                        
                        self.cis_foundations_benchmark_1_1['1.10']['Findings'].append(finding)

        # CIS 1.11 Active Admins with API keys
        # Iterrating through all users to see if they have API Keys and if they are active users
        for user in self.__users:
            if 'Administrators' in user['groups'] and user['api_keys'] and user['lifecycle_state'] == 'ACTIVE':
                self.cis_foundations_benchmark_1_1['1.11']['Status'] = False
                self.cis_foundations_benchmark_1_1['1.11']['Findings'].append(user)


        # CIS 1.12 Check - This check is complete uses email verification
        # Iterating through all users to see if they have API Keys and if they are active users
        for user in self.__users:
            if user['external_identifier'] == None and user['lifecycle_state'] == 'ACTIVE' and not(user['email_verified']):
                self.cis_foundations_benchmark_1_1['1.12']['Status'] = False
                self.cis_foundations_benchmark_1_1['1.12']['Findings'].append(user)

        
        # CIS 2.1, 2.2, & 2.5 Check - Security List Ingress from 0.0.0.0/0 on ports 22, 3389
        for sl in self.__network_security_lists:
            for irule in sl['ingress_security_rules']:
                
                if irule['source'] == "0.0.0.0/0" and irule['protocol'] == '6':
                    if irule['tcp_options']:
                        try:
                            if irule['tcp_options'].destination_port_range.min == 22 and irule['tcp_options'].destination_port_range.max == 22:
                                self.cis_foundations_benchmark_1_1['2.1']['Status'] = False
                                self.cis_foundations_benchmark_1_1['2.1']['Findings'].append(sl)
                            elif irule['tcp_options'].destination_port_range.min == 3389 and irule['tcp_options'].destination_port_range.max == 3389:
                                self.cis_foundations_benchmark_1_1['2.2']['Status'] = False
                                self.cis_foundations_benchmark_1_1['2.2']['Findings'].append(sl)
                        except (AttributeError):
                            #### Temporarily adding unfettered access to rule 2.5. Move this once a proper rule is available.
                            self.cis_foundations_benchmark_1_1['2.5']['Status'] = False
                            self.cis_foundations_benchmark_1_1['2.5']['Findings'].append(sl)
                
                # CIS 2.5 Check - any rule with 0.0.0.0 where protocol not 1 (ICMP)
                if irule['source'] == "0.0.0.0/0" and irule['protocol'] != '1':
                    self.cis_foundations_benchmark_1_1['2.5']['Status'] = False
                    self.cis_foundations_benchmark_1_1['2.5']['Findings'].append(sl) 


        # CIS 2.3 and 2.4 Check - Network Security Groups Ingress from 0.0.0.0/0 on ports 22, 3389
        for nsg in self.__network_security_groups:
            for rule in nsg['rules']:
                if rule['source'] == "0.0.0.0/0" and rule['protocol'] == '6':
                    if rule['tcp_options']:
                        try:
                            if rule['tcp_options'].destination_port_range.min == 22 or rule['tcp_options'].destination_port_range.max == 22:
                                self.cis_foundations_benchmark_1_1['2.3']['Status'] = False           
                                self.cis_foundations_benchmark_1_1['2.3']['Findings'].append(nsg)
                            elif rule['tcp_options'].destination_port_range.min == 3389 or rule['tcp_options'].destination_port_range.max == 3389:
                                self.cis_foundations_benchmark_1_1['2.4']['Status'] = False
                                self.cis_foundations_benchmark_1_1['2.4']['Findings'].append(nsg)
                        except (AttributeError):
                            #### Temporarily adding unfettered access to rule 2.3. Move this once a proper rule is available.
                            self.cis_foundations_benchmark_1_1['2.3']['Status'] = False
                            self.cis_foundations_benchmark_1_1['2.3']['Findings'].append(nsg)

        # CIS 3.1 Check - Ensure Audit log retention == 365
        if self.__audit_retention_period >= 365:
            self.cis_foundations_benchmark_1_1['3.1']['Status'] = True

        # CIS Check 3.2 - Check for Default Tags in Root Compartment
        # Iterate through tags looking for ${iam.principal.name}
        for tag in self.__tag_defaults:
            if tag['value'] == "${iam.principal.name}":
                self.cis_foundations_benchmark_1_1['3.2']['Status'] = True

      # CIS Check 3.3 - Check for Active Notification and Subscription
        if len(self.__subscriptions) > 0:
            self.cis_foundations_benchmark_1_1['3.3']['Status'] = True


        # CIS Checks 3.4 - 3.13 
        #Iterate through all event rules
        for event in self.__event_rules:
            # Convert Event Condition to dict
            jsonable_str = event['condition'].lower().replace("'", "\"")
            event_dict = json.loads(jsonable_str)
            
            for key,changes in self.cis_monitoring_checks.items():
                #Checking if all cis change list is a subset of event condition
                # if(all(x in test_list for x in sub_list)): 
                if(all(x in event_dict['eventtype'] for x in changes)):
                    self.cis_foundations_benchmark_1_1[key]['Status'] = True

        # CIS Check 3.14 - VCN FlowLog enable
        # Generate list of subnets IDs
        for subnet in self.__network_subnets:
            if not(subnet['id'] in self.__subnet_logs):
                self.cis_foundations_benchmark_1_1['3.14']['Status'] = False
                self.cis_foundations_benchmark_1_1['3.14']['Findings'].append(subnet)


        # if(all(x in self.__subnet_logs for x in all_subnet_ids)):
        #     self.cis_foundations_benchmark_1_1['3.14']['Status'] = True
        # else:
        #     self.cis_foundations_benchmark_1_1['3.14']['Status'] = False

        # CIS Check 3.15 - Cloud Guard enabled
        if self.__cloud_guard_config.status == 'ENABLED':
            self.cis_foundations_benchmark_1_1['3.15']['Status'] = True
        else:
            self.cis_foundations_benchmark_1_1['3.15']['Status'] = False


        # CIS Check 3.16 - Encryption keys over 365
        for vault in self.__vaults:
            for key in vault['keys']:
                #print(key['time_created'] + ' >= ' + self.kms_key_time_max_datetime)
                if self.kms_key_time_max_datetime >= key['time_created'] :
                    self.cis_foundations_benchmark_1_1['3.16']['Status'] = False
                    self.cis_foundations_benchmark_1_1['3.16']['Findings'].append(key)
        

        # CIS Check 3.17 - Object Storage with Logs
        # Generating list of buckets names
        for bucket in self.__buckets:
            if not(bucket['name'] in self.__write_bucket_logs):
                self.cis_foundations_benchmark_1_1['3.17']['Status'] = False
                self.cis_foundations_benchmark_1_1['3.17']['Findings'].append(bucket)


        # for bucket in all
        # # if(all(x in test_list for x in sub_list)) Checking if all buckets have write enabeled 
        # if(all(x in  all_bucket_names for x in self.__write_bucket_logs)):
        #     self.cis_foundations_benchmark_1_1['3.17']['Status'] = True
        # else:
        #     self.cis_foundations_benchmark_1_1['3.17']['Status'] = False


        # CIS Section 4 Checks
        for bucket in self.__buckets:
            if 'public_access_type' in bucket:
                if bucket['public_access_type'] != 'NoPublicAccess':
                    self.cis_foundations_benchmark_1_1['4.1']['Status'] = False
                    self.cis_foundations_benchmark_1_1['4.1']['Findings'].append(bucket)
            
            if 'kms_key_id' in bucket:
                if not(bucket['kms_key_id']):
                    self.cis_foundations_benchmark_1_1['4.2']['Findings'].append(bucket)
                    self.cis_foundations_benchmark_1_1['4.2']['Status'] = False
            else:
                self.cis_foundations_benchmark_1_1['4.2']['Findings'].append(bucket)
                self.cis_foundations_benchmark_1_1['4.2']['Status'] = False


        # CIS Section 5 Checks
        # Checking if more than one compartment becuae of the ManagedPaaS Compartment 
        if len(self.__compartments) < 2:
            self.cis_foundations_benchmark_1_1['5.1']['Status'] = False
        
        if len(self.__resources_in_root_compartment) > 0:
            for item in self.__resources_in_root_compartment:
                self.cis_foundations_benchmark_1_1['5.2']['Status'] = False
                self.cis_foundations_benchmark_1_1['5.2']['Findings'].append(item)

    
    ##########################################################################
    # Orchestras data collection - analysis and report generation
    ##########################################################################

    def report_generate_cis_report(self):
        # This function reports generates CSV reports
        
        # Collecting all the tenancy data
        self.__report_collect_tenancy_data()
        
        # Analyzing Data in reports 
        self.__report_analyze_tenancy_data()

        # Creating summary report
        summary_report = []
        for key, recommendation in self.cis_foundations_benchmark_1_1.items():            
            record = {
                "Recommendation #" : key,
                "Section" : recommendation['section'],
                "Level" : str(recommendation['Level']),
                "Compliant" : ('Yes' if recommendation['Status'] else 'No'),
                "Findings" : str(len(recommendation['Findings'])),
                "Title" : recommendation['Title']
            }
            # Add record to summary report for CSV output
            summary_report.append(record)

            # Generate Findings report
            #self.__print_to_csv_file("cis", recommendation['section'] + "_" + recommendation['recommendation_#'], recommendation['Findings'] )            
        
        # Screen output for CIS Summary Report
        self.__print_header("CIS Foundations Benchmark 1.1 Summary Report")
        print('Num' + "\t" + "Level " + \
              "\t" "Compliant" + "\t" + "Findings  " + "\t" +'Title')
        print('#' * 90)
        for finding in summary_report:
            # If print_to_screen is False it will only print non-compliant findings
            if not(self.__print_to_screen) and finding['Compliant'] == 'No':            
                print(finding['Recommendation #'] + "\t" + \
                finding['Level'] + "\t" + finding['Compliant'] + "\t\t" +
                        finding['Findings'] + "\t\t" + finding['Title'])
            elif self.__print_to_screen:
                print(finding['Recommendation #'] + "\t" + \
                finding['Level'] + "\t" + finding['Compliant'] + "\t\t" +
                        finding['Findings'] + "\t\t" + finding['Title'])
        
        # Generating Summary report CSV
        self.__print_header("Writing reports to CSV")
        summary_file_name = self.__print_to_csv_file(self.__report_directory, "cis", "summary_report", summary_report)
        # Out putting to a bucket if I have one
        if summary_file_name and self.__output_bucket:
            self.__os_copy_report_to_object_storage(self.__output_bucket, summary_file_name)

        for key, recommendation in self.cis_foundations_benchmark_1_1.items():
            report_file_name = self.__print_to_csv_file(self.__report_directory,  "cis", recommendation['section'] + "_" + recommendation['recommendation_#'], recommendation['Findings'] )
            if report_file_name and self.__output_bucket:
                self.__os_copy_report_to_object_storage(self.__output_bucket, report_file_name)
    
    def __report_collect_tenancy_data(self):
        
        self.__print_header("Processing Tenancy Data for " + self.__tenancy.name + "...")

        self.__compartments = self.__identity_read_compartments()
        self.__cloud_guard_read_cloud_guard_configuration()
        self.__vault_read_vaults()
        self.__audit_read__tenancy_audit_configuration()
        self.__identity_read_tenancy_password_policy()
        self.__identity_read_tenancy_policies()
        self.__identity_read_groups_and_membership()
        self.__identity_read_users()
        self.__os_read_buckets()
        self.__logging_read_log_groups_and_logs()
        self.__search_resources_in_root_compartment()
        self.__events_read_event_rules()
        self.__ons_read_subscriptions()
        self.__network_read_network_security_lists()
        self.__network_read_network_security_groups_rules()
        self.__network_read_network_subnets()
        self.__identity_read_tag_defaults()

    ##########################################################################
    # Copy Report to Object Storage
    ##########################################################################
    def __os_copy_report_to_object_storage(self, bucketname, filename):
        object_name = filename
        #print(self.__os_namespace)
        try:
            with open(filename, "rb") as f:
                try:
                    self.__os_client.put_object(self.__os_namespace, bucketname, object_name, f)
                except Exception as e:
                    raise Exception("Error uploading file os_copy_report_to_object_storage: " + str(e.args))
        except Exception as e:
            raise Exception("Error opening file os_copy_report_to_object_storage: " + str(e.args))

    ##########################################################################
    # Print to CSV 
    ##########################################################################
    def __print_to_csv_file(self, report_directory, header, file_subject, data):

        try:
            # Creating report directory 
            if not os.path.isdir(report_directory):
                os.mkdir(report_directory)

        except Exception as e:
            raise Exception("Error in creating report directory: " + str(e.args))
       
        try:
            # if no data
            if len(data) == 0:
                return None

            # get the file name of the CSV
            
            file_name =  header + "_" + file_subject
            file_name = (file_name.replace(" ","_")).replace(".","-")+ ".csv"
            file_path = os.path.join(report_directory, file_name)

            
            # add start_date to each dictionary
            result = [dict(item, extract_date=self.start_time_str) for item in data]

            # generate fields
            fields = [key for key in result[0].keys()]

            with open(file_path, mode='w', newline='') as csv_file:
                writer = csv.DictWriter(csv_file, fieldnames=fields)

                # write header
                writer.writeheader()

                for row in result:
                    writer.writerow(row)

            print("CSV: " + file_subject.ljust(22) + " --> " + file_path)
            # Used by Uplaoad to 
            return file_path

        except Exception as e:
            raise Exception("Error in print_to_csv_file: " + str(e.args))
            
    ##########################################################################
    # Print header centered
    ##########################################################################
    def __print_header(self,name):
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
        try:
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
        except Exception:
            print(f'** OCI Config was not found here : {oci.config.DEFAULT_LOCATION} or env varibles missing, aborting **')
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
    parser.add_argument('-t', default="", dest='config_profile', help='Config file section to use (tenancy profile)')
    parser.add_argument('-p', default="", dest='proxy', help='Set Proxy (i.e. www-proxy-server.com:80) ')
    parser.add_argument('--output-to-bucket', default="", dest='output_bucket', help='Set Output bucket name (i.e. my-reporting-bucket) ')
    parser.add_argument('--report-directory', default=None, dest='report_directory', help='Set Output report directory by default it is the current date (i.e. reports-date) ')
    parser.add_argument('--print-to-screen', default='True', dest='print_to_screen', help='Set to False if you want to see only non-compliant findings (i.e. False) ')
    parser.add_argument('-ip', action='store_true', default=False, dest='is_instance_principals', help='Use Instance Principals for Authentication')
    parser.add_argument('-dt', action='store_true', default=False, dest='is_delegation_token', help='Use Delegation Token for Authentication')
    cmd = parser.parse_args()
    # Getting  Command line  arguments
    # cmd = set_parser_arguments()
    # if cmd is None:
    #     pass
    #     # return

    # Identity extract compartments
    config, signer = create_signer(cmd.config_profile, cmd.is_instance_principals, cmd.is_delegation_token)
    report = CIS_Report(config, signer, cmd.proxy,cmd.output_bucket, cmd.report_directory, cmd.print_to_screen)

    report.report_generate_cis_report()
    

##########################################################################
# Main
##########################################################################

execute_report()

