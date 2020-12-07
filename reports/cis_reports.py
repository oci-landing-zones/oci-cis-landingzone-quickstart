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
import pytz
import oci
import json
import os
import csv
#DAYS_OLD = 90


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
    '3.9': {'section' : 'Lexogging and Monitoring', 'recommendation_#' : '3.9', 'Title' : 'Ensure a notification is configured for VCN changes','Status' : False, 'Level' : 1 , 'Findings' : []},
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

##########################################################################
# CIS Reporting Class
##########################################################################
class CIS_Report:
    # Class variables
    _DAYS_OLD = 90
    _KMS_DAYS_OLD = 365
    # Tenancy Data
    _tenancy = None
    cloud_guard_config = None
    tenancy_password_policy = None
    compartments = []
    policies = []
    
    users = []
    groups_to_users = []
    tag_defaults = []

    buckets = []

    network_security_groups = []
    network_security_lists = []
    network_subnets = []

    event_rules = []

    logging_list = []
    # For Logging & Monitoring checks
    _subnet_logs = []
    _write_bucket_logs = []

    vaults = []
    
    subscriptions = []

    resources_in_root_compartment =[]

    # Start print time info
    start_datetime = datetime.datetime.now().replace(tzinfo=pytz.UTC)
    start_time_str = str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    
    key_time_max_datetime = start_datetime - datetime.timedelta(days=_DAYS_OLD)

    kms_key_time_max_datetime = start_datetime - datetime.timedelta(days=_KMS_DAYS_OLD)


    def __init__(self, config, signer):
        # Start print time info
        self._config = config
        self._signer = signer
        print(self._config)
        print(self._signer)
        try:
            print("\nConnecting to Identity Service...")
            self._identity = oci.identity.IdentityClient(self._config, signer=self._signer)
            if cmd.proxy:
                self._identity.base_client.session.proxies = {'https': cmd.proxy}

            print("\nConnecting to Audit Service...")
            self._audit = oci.audit.AuditClient(self._config, signer=self._signer)
            if cmd.proxy:
                self._audit.base_client.session.proxies = {'https': cmd.proxy}
            
            print("\nConnecting to Cloud Guard Service...")
            self._cloud_guard = oci.cloud_guard.CloudGuardClient(self._config, signer=self._signer)
            if cmd.proxy:
                self._cloud_guard.base_client.session.proxies = {'https': cmd.proxy}

            print("\nConnecting to Advance Search Service...")
            self._search = oci.resource_search.ResourceSearchClient(self._config, signer=self._signer)
            if cmd.proxy:
                self._search.base_client.session.proxies = {'https': cmd.proxy}

            print("\nConnecting to Network Service...")
            self._network = oci.core.VirtualNetworkClient(self._config, signer=self._signer)
            if cmd.proxy:
                self._network.base_client.session.proxies = {'https': cmd.proxy}

            print("\nConnecting to Events Service...")
            self._events = oci.events.EventsClient(self._config, signer=self._signer)
            if cmd.proxy:
                self._events.base_client.session.proxies = {'https': cmd.proxy}

            print("\nConnecting to Logging Service...")
            self._logging = oci.logging.LoggingManagementClient(self._config, signer=self._signer)
            if cmd.proxy:
                self._logging.base_client.session.proxies = {'https': cmd.proxy}

            print("\nConnecting to Object Storage Service...")
            self._os_client = oci.object_storage.ObjectStorageClient(self._config, signer=self._signer)
            if cmd.proxy:
                self._os_client.base_client.session.proxies = {'https': cmd.proxy}
            
            print("\nConnecting to Vault Service...")
            self._vault = oci.key_management.KmsVaultClient(self._config, signer=self._signer)
            if cmd.proxy:
                self._vault.session.proxies = {'https': cmd.proxy}

            print("\nConnecting to Subscriptions Service...")
            self._ons_subs = oci.ons.NotificationDataPlaneClient(self._config, signer=self._signer)
            if cmd.proxy:
                self._ons_subs.session.proxies = {'https': cmd.proxy}


            self._tenancy = self._identity.get_tenancy(config["tenancy"]).data
            self._regions = self._identity.list_region_subscriptions(self._tenancy.id).data
            self.compartments = self._identity_read_compartments()

        except Exception as e:
                raise RuntimeError("Failed to create service objects" + str(e.args))
    
    ##########################################################################
    # Check for Managed PaaS Compartment
    ##########################################################################
    def _if_not_managed_paas_compartment(self,name):
        return name != "ManagedCompartmentForPaaS"
      
    ##########################################################################
    # Load compartments
    ##########################################################################
    def _identity_read_compartments(self):

        print("Loading Compartments...")
        try:
            compartments = oci.pagination.list_call_get_all_results(
                self._identity.list_compartments,
                self._tenancy.id,
                compartment_id_in_subtree=True
            ).data

            # Add root compartment which is not part of the list_compartments
            compartments.append(self._tenancy)

            print("    Total " + str(len(compartments)) + " compartments loaded.")
            return compartments

        except Exception as e:
            raise RuntimeError("Error in identity_read_compartments: " + str(e.args))

    ##########################################################################
    # Load Groups and Group membership
    ##########################################################################
    def identity_read_groups_and_membership(self):
        print("Loading User Groups and Group Membership...")
        try:
            # Getting all Groups in the Tenancy
            groups_data = oci.pagination.list_call_get_all_results(
                self._identity.list_groups,
                self._tenancy.id
            ).data
            # For each group in the tenacy getting the group's membership
            for grp in groups_data:
                membership = oci.pagination.list_call_get_all_results(
                    self._identity.list_user_group_memberships,
                    self._tenancy.id,
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
                    self.groups_to_users.append(group_record)
            return self.groups_to_users
        except Exception as e:
            RuntimeError("Error in identity_read_groups_and_membership" + str(e.args))

    ##########################################################################
    # Load users
    ##########################################################################
    def identity_read_users(self):
        print("Loading Users...")
        try:
            # Getting all users in the Tenancy
            users_data = oci.pagination.list_call_get_all_results(
                self._identity.list_users,
                self._tenancy.id
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
                for group in self.groups_to_users:
                    if user.id == group['user_id']:
                        record['groups'].append(group['name'])
                
                record['api_keys'] = self._identity_read_user_api_key(user.id)
                record['auth_tokens'] = self._identity_read_user_auth_token(user.id)
                record['customer_secret_keys'] = self._identity_read_user_customer_secret_key(user.id)

                self.users.append(record)

            print("    Total " + str(len(self.users)) + " users loaded.")
            return self.users

        except Exception as e:
            raise RuntimeError("Error in identity_read_users: " + str(e.args))

    ##########################################################################
    # Load user api keys
    ##########################################################################
    def _identity_read_user_api_key(self,user_ocid):
        api_keys = []
        try:
            user_api_keys_data = oci.pagination.list_call_get_all_results(
                self._identity.list_api_keys,
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


            #print("    Total " + str(len(api_keys)) + " api keys loaded.")
            return api_keys

        except Exception as e:
            raise RuntimeError("Error in identity_read_user_api_key: " + str(e.args))

    ##########################################################################
    # Load user auth tokens
    ##########################################################################
    def _identity_read_user_auth_token(self, user_ocid):
        auth_tokens = []
        try:
            auth_tokens_data = oci.pagination.list_call_get_all_results(
                self._identity.list_auth_tokens,
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
    def _identity_read_user_customer_secret_key(self,user_ocid):
        customer_secret_key = []
        try:
            customer_secret_key_data = oci.pagination.list_call_get_all_results(
                self._identity.list_customer_secret_keys,
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
    def identity_read_tenancy_policies(self):

        print("Loading Tenancy Policies...")
        # Get all policy at the tenacy level
        try:
            for compartment in self.compartments:
                policies_data = oci.pagination.list_call_get_all_results(
                    self._identity.list_policies,
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
                    self.policies.append(record)

            print("    Total " + str(len(self.policies)) + " compartments loaded.")
            return self.policies

        except Exception as e:
            raise RuntimeError("Error in identity_read_tenancy_policies: " + str(e.args))

    ##########################################################################
    # Get Objects Store Buckets
    ##########################################################################
    def os_read_buckets(self):
        print("Loading Object Store Buckets")
        # Getting OS Namespace
        try: 
            os_namespace = self._os_client.get_namespace().data
        except Exception as e:
            raise RuntimeError("Error in os_read_buckets could not load namespace " + str(e.args))

        try:
            for compartment in self.compartments:
                # Skipping the managed pass compartment
                print("Loading Buckets from compartment: " + compartment.name)

                if self._if_not_managed_paas_compartment(compartment.name):
                    buckets_data = oci.pagination.list_call_get_all_results(
                        self._os_client.list_buckets,
                        os_namespace,
                        compartment.id
                    ).data

                    # Getting Bucket Info
                    for bucket in buckets_data:
                        bucket_info = self._os_client.get_bucket(os_namespace,bucket.name).data
                        record = {
                            "id" : bucket_info.id,
                            "name" : bucket_info.name,
                            "kms_key_id" : bucket_info.kms_key_id,
                            "namespace" : bucket_info.namespace,
                            "object_events_enabled" : bucket_info.object_events_enabled,
                            "public_access_type" : bucket_info.public_access_type,
                            "replication_enabled" : bucket_info.replication_enabled,
                            "is_read_only" : bucket_info.is_read_only,
                            "storage_tier" : bucket_info.storage_tier,
                            "time_created" : bucket_info.time_created,
                            "versioning" : bucket_info.versioning
                        }
                        self.buckets.append(record)
            # Returning Buckets
            return self.buckets
        except Exception as e:
            raise RuntimeError("Error in os_read_buckets " + str(e.args))

    ##########################################################################
    # Network Security Groups
    ##########################################################################
    def network_read_network_security_groups_rules(self):
        
        print("Loading Network Security Groups...")
        # print(network)
        # print(compartments)
        # Loopig Through Compartments Except Mnaaged
        try:
            for compartment in self.compartments:
                if self._if_not_managed_paas_compartment(compartment.name):
                    nsgs_data = oci.pagination.list_call_get_all_results(
                            self._network.list_network_security_groups,
                            compartment.id
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
                            self._network.list_network_security_group_security_rules,
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
                        self.network_security_groups.append(record)


            return self.network_security_groups
        except Exception as e:
            raise RuntimeError("Error in network_read_network_security_groups_rules " + str(e.args))

    ##########################################################################
    # Network Security Lists
    ##########################################################################
    def network_read_network_security_lists(self):
        
        print("Loading Network Security Lists...")
        # print(network)
        # print(compartments)
        # Loopig Through Compartments Except Mnaaged
        try:
            for compartment in self.compartments:
                if self._if_not_managed_paas_compartment(compartment.name):
                    security_lists_data = oci.pagination.list_call_get_all_results(
                            self._network.list_security_lists,
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
                        self.network_security_lists.append(record)

            return self.network_security_lists
        except Exception as e:
            raise RuntimeError("Error in network_read_network_security_lists " + str(e.args))

    ##########################################################################
    # Network Subnets Lists
    ##########################################################################
    def network_read_network_subnets(self):
        print("Loading Network Subnets...")
        try:
            # Looping through compartments in tenancy
            for compartment in self.compartments:
                if self._if_not_managed_paas_compartment(compartment.name):
                    subnets_data = oci.pagination.list_call_get_all_results(
                        self._network.list_subnets,
                        compartment.id
                    ).data
                    # Looping through subnets in a compartment
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
                            "ipv6_public_cidr_block" : subnet.ipv6_public_cidr_block,
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
                        self.network_subnets.append(record)
            return self.network_subnets
        except Exception as e:
            raise RuntimeError("Error in network_read_network_subnets " + str(e.args))

    ##########################################################################
    # Events
    ##########################################################################
    def events_read_event_rules(self):

        print("Loading Event Rules...")
        try:
            for compartment in self.compartments:
                if self._if_not_managed_paas_compartment(compartment.name):
                    events_rules_data = oci.pagination.list_call_get_all_results(
                        self._events.list_rules,
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
                        self.event_rules.append(record)
            
            return self.event_rules
        except Exception as e:
            raise RuntimeError("Error in events_read_rules " + str(e.args))

    ##########################################################################
    # Logging - Log Groups and Logs
    ##########################################################################
    def logging_read_log_groups_and_logs(self):

        print("Loading Log Groups and Logs...")

        try:
            # Looping through compartments
            for compartment in self.compartments:
                # Checking if Managed Compartment cause I can't query it
                if self._if_not_managed_paas_compartment(compartment.name):
                    # Getting Log Groups in compartment
                    log_groups = oci.pagination.list_call_get_all_results(
                            self._logging.list_log_groups,
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
                            self._logging.list_logs,
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
                                    print("VCN  Log")
                                    self._subnet_logs.append(log.configuration.source.resource)
                                    print("Added: " + str(log.configuration.source.resource))
                                elif log.configuration.source.service == 'objectstorage' and 'write' in log.configuration.source.category:
                                    #Only write logs 
                                    self._write_bucket_logs.append(log.configuration.source.resource)
                                    print("Added: " + str(log.configuration.source.resource))
                            except: 
                                pass
                            # Append Log to log List
                            record['logs'].append(log_record)
                        self.logging_list.append(record)

            return self.logging_list
        except Exception as e:
            raise RuntimeError("Error in network_read_network_security_groups_rules " + str(e.args))

    ##########################################################################
    # Vault Keys 
    ##########################################################################
    def vault_read_vaults(self):
        print("Loading Vaults and Keys...")
        # Iterating through compartments
        for compartment in self.compartments:
            if self._if_not_managed_paas_compartment(compartment.name):
                vaults_data = oci.pagination.list_call_get_all_results(
                    self._vault.list_vaults,
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
                    
                    print("\nConnecting to Key Management Service...")
                    cur_key_client = oci.key_management.KmsManagementClient(self._config, vlt.management_endpoint)
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

                    self.vaults.append(vault_record)
        
        return self.vaults

    ##########################################################################
    # Audit Configuration
    ##########################################################################
    def audit_read_tenancy_audit_configuration(self):
        # Pulling the Audit Configuration
        print("Loading Audit Configuration...")

        try:
            self.audit_retention_period = self._audit.get_configuration(self._tenancy.id).data.retention_period_days
            return self.audit_retention_period
        except Exception as e:
            raise RuntimeError("Error in get_tenancy_audit_configuration " + str(e.args))

    ##########################################################################
    # Cloud Guard Configuration
    ##########################################################################
    def cloud_guard_read_cloud_guard_configuration(self):
        print("Loading Cloud Guard configuration..")
        try:
            self.cloud_guard_config = self._cloud_guard.get_configuration(self._tenancy.id).data
            return self.cloud_guard_config
        except Exception as e:
            raise RuntimeError("Error in cloud_guard_read_cloud_guard_configuration " + str(e.args))

    ##########################################################################
    # Identity Password Policy 
    ##########################################################################
    def identity_read_tenancy_password_policy(self):
        print("Loading Tenancy Password Policy...")
        try:
            self.tenancy_password_policy = self._identity.get_authentication_policy(self._tenancy.id).data

        except Exception as e:
            raise RuntimeError("Error in identity_read_tenancy_password_policy " + str(e.args))

    ##########################################################################
    # Oracle Notifications Services for Subscriptions
    ##########################################################################
    def ons_read_subscriptions(self):
        print("Loading Subscriptions..")
        try:
            # Iterate through compartments to get all subscriptions
            for compartment in self.compartments:
                if self._if_not_managed_paas_compartment(compartment.name):
                    subs_data = oci.pagination.list_call_get_all_results(
                        self._ons_subs.list_subscriptions,
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
                        self.subscriptions.append(record)
            return self.subscriptions

        except Exception as e:
            raise RuntimeError("Error in ons_read_subscription " + str(e.args))

    ##########################################################################
    # Identity Tag Default
    ##########################################################################
    def identity_read_tag_defaults(self):
        print("Loading Tag Defaults..")
        try:
            # Getting Tag Default for the Root Compartment - Only
            tag_defaults = oci.pagination.list_call_get_all_results(
                self._identity.list_tag_defaults,
                compartment_id=self._tenancy.id
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
                self.tag_defaults.append(record)
            return self.tag_defaults

        except Exception as e:
            raise RuntimeError("Error in identity_read_tag_defaults " + str(e.args))
    
    ##########################################################################
    # Run advanced search structure query
    ##########################################################################
    def search_run_structured_query(self, query):
        try:
            structured_search = oci.resource_search.models.StructuredSearchDetails(query=query, type='Structured', 
                matching_context_type=oci.resource_search.models.SearchDetails.MATCHING_CONTEXT_TYPE_NONE)
            search_results = self._search.search_resources(structured_search).data.items

            return search_results
        
        except Exception as e:
            raise RuntimeError("Error in search_run_structure_query " + str(e.args))

    ##########################################################################
    # Resources in root compartment
    ##########################################################################
    def search_resources_in_root_compartment(self):
        query = "query VCN, instance, volume, filesystem, bucket, autonomousdatabase, database, dbsystem resources where compartmentId = '" + self._tenancy.id + "'"
        print("Load resources in root compartment...")
        resources_in_root_data = self.search_run_structured_query(query)
        for item in resources_in_root_data:
            record = {
                "display_name" : item.display_name,
                "id" : item.identifier
            }
            self.resources_in_root_compartment.append(record)
    
        return self.resources_in_root_compartment

    ##########################################################################
    # Analyzes Tenancy Data for CIS Report 
    ##########################################################################
    def report_analyze_tenancy_data(self):
        print("Running CIS Report...")

        # 1.2 Check
        for policy in self.policies:
            for statement in policy['statements']:
                #print("looping through policy statement")
                #print(statement)
                if "to manage all-resources in tenancy".upper() in statement.upper():
                    cis_foundations_benchmark_1_1['1.2']['Status'] = False
                    cis_foundations_benchmark_1_1['1.2']['Findings'].append(policy)

                    break
                
        print_header(cis_foundations_benchmark_1_1['1.2']['Title'])
        print("Status: " + str(cis_foundations_benchmark_1_1['1.2']['Status']))

        # 1.3 Check - May want to add a service check
        for policy in self.policies:
            for statement in policy['statements']:
                if ("to use groups in tenancy".upper() in statement.upper() or \
                    "to use users in tenancy".upper() in statement.upper() or \
                        "to manage groups in tenancy".upper() in statement.upper() or 
                        "to manage users in tenancy".upper() in statement.upper()):
                    cis_foundations_benchmark_1_1['1.3']['Status'] = False

                    cis_foundations_benchmark_1_1['1.3']['Findings'].append(policy)
                    # Moving to the next policy 
                    break

        print_header(cis_foundations_benchmark_1_1['1.3']['Title'])
        print("Status: " + str(cis_foundations_benchmark_1_1['1.3']['Status']))


        # 1.4 Check
        if self.tenancy_password_policy.password_policy.is_lowercase_characters_required:
            cis_foundations_benchmark_1_1['1.4']['Status'] = True
        print_header(cis_foundations_benchmark_1_1['1.4']['Title'])
        print("Status: " + str(cis_foundations_benchmark_1_1['1.4']['Status']))
        print("Finding: " + str(cis_foundations_benchmark_1_1['1.4']['Findings']))


        
        for user in self.users:
            if user['external_identifier'] == None and not(user['is_mfa_activated']) and user['lifecycle_state'] == 'ACTIVE':
                cis_foundations_benchmark_1_1['1.7']['Status'] = False
                cis_foundations_benchmark_1_1['1.7']['Findings'].append(user)
        

        print_header(cis_foundations_benchmark_1_1['1.7']['Title'])
        print("Status: " + str(cis_foundations_benchmark_1_1['1.8']['Status']))
        print("Number of Findings: " + str(len(cis_foundations_benchmark_1_1['1.7']['Findings'])))


        
        for user in self.users:
            if user['api_keys']:
                for key in user['api_keys']:
                    if self.key_time_max_datetime >= key['time_created'] and key['lifecycle_state'] == 'ACTIVE':
                        cis_foundations_benchmark_1_1['1.8']['Status'] = False
                        finding = {
                            "user_name" : user['name'],
                            "user_id" : user['id'],
                            "key_id" : key['id'],
                            'fingerprint' : key['fingerprint'],
                            'inactive_status' : key['inactive_status'],
                            'lifecycle_state' : key['lifecycle_state'],
                            'time_created' : key['time_created']
                        }
                        
                        cis_foundations_benchmark_1_1['1.8']['Findings'].append(finding)
                
        

        print_header(cis_foundations_benchmark_1_1['1.8']['Title'])
        print("Status: " + str(cis_foundations_benchmark_1_1['1.8']['Status']))
        print("Number of Findings: " + str(len(cis_foundations_benchmark_1_1['1.8']['Findings'])))


        # CIS 1.9 Check
        for user in self.users:
            if user['customer_secret_keys']:
                for key in user['customer_secret_keys']:
                    if self.key_time_max_datetime >= key['time_created'] and key['lifecycle_state'] == 'ACTIVE':
                        cis_foundations_benchmark_1_1['1.9']['Status'] = False

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
                        
                        cis_foundations_benchmark_1_1['1.9']['Findings'].append(finding)
                

        print_header(cis_foundations_benchmark_1_1['1.9']['Title'])
        print("Status: " + str(cis_foundations_benchmark_1_1['1.9']['Status']))
        print("Number of Findings: " + str(len(cis_foundations_benchmark_1_1['1.9']['Findings'])))

        
        # CIS 1.10 Check
        for user in self.users:
            if user['auth_tokens']:
                for key in user['auth_tokens']:
                    if self.key_time_max_datetime >= key['time_created'] and key['lifecycle_state'] == 'ACTIVE':
                        cis_foundations_benchmark_1_1['1.10']['Status'] = False

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
                        
                        cis_foundations_benchmark_1_1['1.10']['Findings'].append(finding)
                
        

        print_header(cis_foundations_benchmark_1_1['1.10']['Title'])
        print("Status: " + str(cis_foundations_benchmark_1_1['1.10']['Status']))
        print("Number of Findings: " + str(len(cis_foundations_benchmark_1_1['1.10']['Findings'])))


        # CIS 1.11 Check
        # Iterrating through all users to see if they have API Keys and if they are active users
        for user in self.users:
            if 'Administrators' in user['groups'] and user['api_keys'] and user['lifecycle_state'] == 'ACTIVE':
                cis_foundations_benchmark_1_1['1.11']['Status'] = False
                cis_foundations_benchmark_1_1['1.11']['Findings'].append(user)


        print_header(cis_foundations_benchmark_1_1['1.11']['Title'])
        print("Status: " + str(cis_foundations_benchmark_1_1['1.11']['Status']))
        print("Number of Findings: " + str(len(cis_foundations_benchmark_1_1['1.11']['Findings'])))


        # CIS 1.12 Check - This check is complete uses email verification
        # Iterrating through all users to see if they have API Keys and if they are active users
        for user in self.users:
            if user['external_identifier'] == None and user['lifecycle_state'] == 'ACTIVE' and not(user['email_verified']):
                cis_foundations_benchmark_1_1['1.12']['Status'] = False
                cis_foundations_benchmark_1_1['1.12']['Findings'].append(user)

        print_header(cis_foundations_benchmark_1_1['1.12']['Title'])
        print("Status: " + str(cis_foundations_benchmark_1_1['1.12']['Status']))
        print("Number of Findings: " + str(len(cis_foundations_benchmark_1_1['1.12']['Findings'])))
 
        
       # CIS 2.1, 2.2, & 2.5 Check - Security List Ingress from 0.0.0.0/0 on port 22, 3389

        # Iterrating through all users to see if they have API Keys and if they are active users
        for sl in self.network_security_lists:
            for irule in sl['ingress_security_rules']:
                if irule['source'] == "0.0.0.0/0" and irule['protocol'] == '6':
                    if irule['tcp_options']:
                        if irule['tcp_options'].destination_port_range.min == 22 and irule['tcp_options'].destination_port_range.max == 22:
                            cis_foundations_benchmark_1_1['2.1']['Status'] = False
                            cis_foundations_benchmark_1_1['2.1']['Findings'].append(sl)
                        elif irule['tcp_options'].destination_port_range.min == 3389 and irule['tcp_options'].destination_port_range.max == 3389:
                            cis_foundations_benchmark_1_1['2.2']['Status'] = False
                            cis_foundations_benchmark_1_1['2.2']['Findings'].append(sl)
                # CIS 2.5 Check - any rule with 0.0.0.0 where protocol not 1 (ICMP)
                if irule['source'] == "0.0.0.0/0" and irule['protocol'] != '1':
                    cis_foundations_benchmark_1_1['2.5']['Status'] = False
                    cis_foundations_benchmark_1_1['2.5']['Findings'].append(sl) 


       # CIS 2.3 and 2.4 Check - Network Security Groups Ingress from 0.0.0.0/0 on port 22 or 3389
        # Iterrating through all users to see if they have API Keys and if they are active users
        for nsg in self.network_security_groups:
            for rule in nsg['rules']:
                if rule['source'] == "0.0.0.0/0" and rule['protocol'] == '6':
                    if rule['tcp_options']:
                        if rule['tcp_options'].destination_port_range.min == 22 or rule['tcp_options'].destination_port_range.max == 22:
                            cis_foundations_benchmark_1_1['2.3']['Status'] = False           
                            cis_foundations_benchmark_1_1['2.3']['Findings'].append(nsg)
                        elif rule['tcp_options'].destination_port_range.min == 3389 or rule['tcp_options'].destination_port_range.max == 3389:
                            cis_foundations_benchmark_1_1['2.4']['Status'] = False
                            cis_foundations_benchmark_1_1['2.4']['Findings'].append(nsg)

        
        # CIS 3.1 Check - Ensure Audit log retention == 365
        if self.audit_retention_period >= 365:
            cis_foundations_benchmark_1_1['3.1']['Status'] = True

        # CIS Check 3.2 - Check for Default Tags in Root Compartment
        # Iterate through tags looking for ${iam.principal.name}
        for tag in self.tag_defaults:
            if tag['value'] == "${iam.principal.name}":
                cis_foundations_benchmark_1_1['3.2']['Status'] = True

      # CIS Check 3.3 - Check for Active Notification and Subscription
        if len(self.subscriptions) > 0:
            cis_foundations_benchmark_1_1['3.3']['Status'] = True


        # CIS Checks 3.4 - 3.13 
        #Iterate through all event rules
        for event in self.event_rules:
            # Convert Event Condition to dict
            jsonable_str = event['condition'].lower().replace("'", "\"")
            event_dict = json.loads(jsonable_str)
            
            for key,changes in cis_monitoring_checks.items():
                #Checking if all cis change list is a subset of event condition
                # if(all(x in test_list for x in sub_list)): 
                if(all(x in event_dict['eventtype'] for x in changes)):
                    cis_foundations_benchmark_1_1[key]['Status'] = True
                
        for key,changes in cis_monitoring_checks.items():
            print_header(cis_foundations_benchmark_1_1[key]['Title'])
            print("Status is: " + str(cis_foundations_benchmark_1_1[key]['Status']))

        # CIS Check 3.14 - VCN FlowLog enable
        # Generate list of subnets IDs
        for subnet in self.network_subnets:
            if not(subnet['id'] in self._subnet_logs):
                cis_foundations_benchmark_1_1['3.14']['Status'] = False
                cis_foundations_benchmark_1_1['3.14']['Findings'].append(subnet)
            else:
                print("*** founda a subnet logged***")


        # if(all(x in self._subnet_logs for x in all_subnet_ids)):
        #     cis_foundations_benchmark_1_1['3.14']['Status'] = True
        # else:
        #     cis_foundations_benchmark_1_1['3.14']['Status'] = False

        # CIS Check 3.15 - Cloud Guard enabled
        if self.cloud_guard_config.status == 'ENABLED':
            cis_foundations_benchmark_1_1['3.15']['Status'] = True
        else:
            cis_foundations_benchmark_1_1['3.15']['Status'] = False


        # CIS Check 3.16 - Encryption keys over 365
        for vault in self.vaults:
            for key in vault['keys']:
                #print(key['time_created'] + ' >= ' + self.kms_key_time_max_datetime)
                if self.kms_key_time_max_datetime >= key['time_created'] :
                    cis_foundations_benchmark_1_1['3.16']['Status'] = False
                    cis_foundations_benchmark_1_1['3.16']['Findings'].append(key)
        

        # CIS Check 3.17 - Object Storage with Logs
        # Generating list of buckets names
        for bucket in self.buckets:
            if not(bucket['name'] in self._write_bucket_logs):
                cis_foundations_benchmark_1_1['3.17']['Status'] = False
                cis_foundations_benchmark_1_1['3.17']['Findings'].append(bucket)
            else:
                print("*** founda a bucket with write logged***")

        # for bucket in all
        # # if(all(x in test_list for x in sub_list)) Checking if all buckets have write enabeled 
        # if(all(x in  all_bucket_names for x in self._write_bucket_logs)):
        #     cis_foundations_benchmark_1_1['3.17']['Status'] = True
        # else:
        #     cis_foundations_benchmark_1_1['3.17']['Status'] = False


        # CIS Section 4 Checks
        for bucket in self.buckets:
            if bucket['public_access_type'] != 'NoPublicAccess':
                cis_foundations_benchmark_1_1['4.1']['Status'] = False
                cis_foundations_benchmark_1_1['4.1']['Findings'].append(bucket)
            elif not(bucket['kms_key_id']):
                cis_foundations_benchmark_1_1['4.2']['Findings'].append(bucket)
                cis_foundations_benchmark_1_1['4.2']['Status'] = False


        # CIS Section 5 Checks
        # Checking if more than one compartment becuae of the ManagedPaaS Compartment 
        if len(self.compartments) < 2:
            cis_foundations_benchmark_1_1['5.1']['Status'] = False
        
        if len(self.resources_in_root_compartment) > 0:
            for item in self.resources_in_root_compartment:
                cis_foundations_benchmark_1_1['5.2']['Status'] = False
                cis_foundations_benchmark_1_1['5.2']['Findings'].append(item)

    def report_generate_output_csv(self):
        # This function reports generates CSV reports
        #     
        summary_report = []
        for key, recommendation in cis_foundations_benchmark_1_1.items():            
            record = {
                "Recommendation #" : key,
                "Section" : recommendation['section'],
                "Level" : str(recommendation['Level']),
                "Status" : str(recommendation['Status']),
                "Findings" : str(len(recommendation['Findings'])),
                "Title" : recommendation['Title']
            }
            # Add record to summary report for CSV output
            summary_report.append(record)

            # Generate Findings report
            self.__print_to_csv_file("cis", recommendation['section'] + "_" + recommendation['recommendation_#'], recommendation['Findings'] )            
        
        # Generate CIS Summary Report
        print_header("CIS Foundations Benchmark 1.1 Summary Report")
        for finding in summary_report:
            print(finding['Recommendation #'] + "\t" + " Level: " + \
            finding['Level'] + "\t" "Status: " + finding['Status'] + "\t" +
                    "Findings:  " + finding['Findings'] + "\t" + finding['Title'])
        self.__print_to_csv_file("cis", "summary_report", summary_report)
        
    ##########################################################################
    # Print to CSV 
    ##########################################################################
    def __print_to_csv_file(self, header, file_subject, data):

        try:
            # if no data
            if len(data) == 0:
                return

            # get the file name of the CSV
            file_name =  header + "_" + file_subject + ".csv"
            
            # add start_date to each dictionary
            result = [dict(item, extract_date=self.start_time_str) for item in data]

            # generate fields
            fields = [key for key in result[0].keys()]

            with open(file_name, mode='w', newline='') as csv_file:
                writer = csv.DictWriter(csv_file, fieldnames=fields)

                # write header
                writer.writeheader()

                for row in result:
                    writer.writerow(row)

            print("CSV: " + file_subject.ljust(22) + " --> " + file_name)

        except Exception as e:
            raise Exception("Error in print_to_csv_file: " + str(e.args))

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
start_time_datetime = datetime.datetime.utcnow()
start_time_str = str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
#key_time_max_datetime = start_time_datetime - datetime.timedelta(days=DAYS_OLD)
#key_time_max_datetime = key_time_max_datetime.strftime('%Y-%m-%d %H:%M:%S')


print_header("Running CIS Reports")
print("Code base By Adi Zohar, June 2020")
print("Written By Andre Luiz Correa Neto & Josh Hammer, November 2020")
print("Starts at " + str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")))
print("Command Line : " + ' '.join(x for x in sys.argv[1:]))

# Identity extract compartments
config, signer = create_signer(cmd.config_profile, cmd.is_instance_principals, cmd.is_delegation_token)
report = CIS_Report(config,signer)

# logs = report.logging_read_log_groups_and_logs()

# for log_group in logs:
#     for log in log_group['logs']:
#         print(log['source_category'])
#         print(type(log['source_category']))
#         print(len(log['source_category']))
#         print(log['source_category'][0])

# print("Audit Configuration is : "+ str(audit_config))

cg = report.cloud_guard_read_cloud_guard_configuration()
vaults = report.vault_read_vaults()
audit_config = report.audit_read_tenancy_audit_configuration()
report.identity_read_tenancy_password_policy()
policies = report.identity_read_tenancy_policies()
groups = report.identity_read_groups_and_membership()
users = report.identity_read_users()
buckets = report.os_read_buckets()

log_groups = report.logging_read_log_groups_and_logs()
root_resources = report.search_resources_in_root_compartment()



events = report.events_read_event_rules()
subscriptions = report.ons_read_subscriptions()

sls = report.network_read_network_security_lists()

nsgs = report.network_read_network_security_groups_rules()

subnets = report.network_read_network_subnets()

tags = report.identity_read_tag_defaults()


report.report_analyze_tenancy_data()

report.report_generate_output_csv()

