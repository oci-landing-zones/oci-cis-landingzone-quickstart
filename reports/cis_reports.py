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
DAYS_OLD = 90


cis_foundations_benchmark_1_1 = [
    {'section' : 'Identity and Access Management', 'recommendation_# ' : '1.1', 
        'Title' : 'Ensure service level admins are created to manage resources of particular service',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Identity and Access Management', 'recommendation_# ' : '1.2', 
        'Title' : 'Ensure permissions on all resources are given only to the tenancy administrator group',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Identity and Access Management', 'recommendation_# ' : '1.3', 
        'Title' : 'Ensure IAM administrators cannot update tenancy Administrators group',
        'Level' : 1,
        'Flag' : False
    },
    {'section' : 'Identity and Access Management', 'recommendation_# ' : '1.4', 
        'Title' : 'Ensure IAM password policy requires minimum length of 14 or greater',
        'Level' : 1,
        'Flag' : False
    },
    {'section' : 'Identity and Access Management', 'recommendation_# ' : '1.5', 
        'Title' : 'Ensure IAM password policy expires passwords within 365 days',
        'Level' : 1,
        'Flag' : False  
    },
    {'section' : 'Identity and Access Management', 'recommendation_# ' : '1.6', 
        'Title' : 'Ensure IAM password policy prevents password reuse',
        'Level' : 1,
        'Flag' : False  
        },
    {'section' : 'Identity and Access Management', 'recommendation_# ' : '1.7', 
        'Title' : 'Ensure MFA is enabled for all users with a console password',
        'Level' : 1,
        'Flag' : False  
        },
    {'section' : 'Identity and Access Management', 'recommendation_# ' : '1.8', 
        'Title' : 'Ensure user API keys rotate within 90 days or less',
        'Level' : 1,
        'Flag' : False  
        },
    {'section' : 'Identity and Access Management', 'recommendation_# ' : '1.9', 
        'Title' : 'Ensure user customer secret keys rotate within 90 days or less',
        'Level' : 1,
        'Flag' : False  
        },
    {'section' : 'Identity and Access Management', 'recommendation_# ' : '1.10', 
        'Title' : 'Ensure user auth tokens rotate within 90 days or less',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Identity and Access Management', 'recommendation_# ' : '1.11', 
        'Title' : 'Ensure API keys are not created for tenancy administrator users',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Identity and Access Management', 'recommendation_# ' : '1.12', 
        'Title' : 'Ensure all OCI IAM user accounts have a valid and current email address',
        'Level' : 1,
        'Flag' : False
        },

    {'section' : 'Networking', 'recommendation_# ' : '2.1', 
        'Title' : 'Ensure no security lists allow ingress from 0.0.0.0/0 to port 22',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Networking', 'recommendation_# ' : '2.2',
        'Title' : 'Ensure no security lists allow ingress from 0.0.0.0/0 to port 3389',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Networking', 'recommendation_# ' : '2.3', 
        'Title' : 'Ensure no network security groups allow ingress from 0.0.0.0/0 to port 22',
        'Level' : 1,
        'Flag' : False  
        },
    {'section' : 'Networking', 'recommendation_# ' : '2.4', 
        'Title' : 'Ensure no network security groups allow ingress from 0.0.0.0/0 to port 3389',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Networking', 'recommendation_# ' : '2.5', 
        'Title' : 'Ensure the default security list of every VCN restricts all traffic except ICMP',
        'Level' : 1,
        'Flag' : False
        },

    {'section' : 'Logging and Monitoring', 'recommendation_# ' : '3.1', 
        'Title' : 'Ensure audit log retention period is set to 365 days',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Logging and Monitoring', 'recommendation_# ' : '3.2', 
        'Title' : 'Ensure default tags are used on resources',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Logging and Monitoring', 'recommendation_# ' : '3.3', 
        'Title' : 'Create at least one notification topic and subscription to receive monitoring alerts',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Logging and Monitoring', 'recommendation_# ' : '3.4', 
        'Title' : 'Ensure a notification is configured for Identity Provider changes',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Logging and Monitoring', 'recommendation_# ' : '3.5', 
        'Title' : 'Ensure a notification is configured for IdP group mapping changes',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Logging and Monitoring', 'recommendation_# ' : '3.6', 
        'Title' : 'Ensure a notification is configured for IAM group changes',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Logging and Monitoring', 'recommendation_# ' : '3.7', 
        'Title' : 'Ensure a notification is configured for IAM policy changes',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Logging and Monitoring', 'recommendation_# ' : '3.8', 
    'Title' : 'Ensure a notification is configured for user changes',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Logging and Monitoring', 'recommendation_# ' : '3.9', 
        'Title' : 'Ensure a notification is configured for VCN changes',
        'Level' : 1,
        'Flag' : False
    },
    {'section' : 'Logging and Monitoring', 'recommendation_# ' : '3.10', 
        'Title' : 'Ensure a notification is configured for changes to route tables',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Logging and Monitoring', 'recommendation_# ' : '3.11', 
        'Title' : 'Ensure a notification is configured for security list changes',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Logging and Monitoring', 'recommendation_# ' : '3.12', 
        'Title' : 'Ensure a notification is configured for network security group changes',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Logging and Monitoring', 'recommendation_# ' : '3.13', 
        'Title' : 'Ensure a notification is configured for changes to network gateways',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Logging and Monitoring', 'recommendation_# ' : '3.14', 
        'Title' : 'Ensure VCN flow logging is enabled for all subnets',
        'Level' : 2,
        'Flag' : False
        },
    {'section' : 'Logging and Monitoring', 'recommendation_# ' : '3.15', 
        'Title' : 'Ensure Cloud Guard is enabled in the root compartment of the tenancy',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Logging and Monitoring', 'recommendation_# ' : '3.16', 
        'Title' : 'Ensure customer created Customer Managed Key (CMK) is rotated at least annually',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Logging and Monitoring', 'recommendation_# ' : '3.17', 
        'Title' : 'Ensure write level Object Storage logging is enabled for all buckets',
        'Level' : 2,
        'Flag' : False
        },

    {'section' : 'Object Storage', 'recommendation_# ' : '4.1', 
        'Title' : 'Ensure no Object Storage buckets are publicly visible',
        'Level' : 1,
        'Flag' : False
        },
    {'section' : 'Object Storage', 'recommendation_# ' : '4.2', 
        'Title' : 'Ensure Object Storage Buckets are encrypted with a Customer Managed Key (CMK)',
        'Level' : 2,
        'Flag' : False},

    {'section' : 'Asset Management', 'recommendation_# ' : '5.1', 
        'Title' : 'Create at least one compartment in your tenancy to store cloud resources',
        'Level' : 1,
        'Flag' : False},
    {'section' : 'Asset Management', 'recommendation_# ' : '5.2', 
        'Title' : 'Ensure no resources are created in the root compartment',
        'Level' : 1,
        'Flag' : False
        },
]

##########################################################################
# CIS Reporting Class
##########################################################################
class CIS_Report:
    # Class variables
    _DAYS_OLD = 90

    # Tenancy Data
    _tenancy = None
    compartments = []
    
    users = []
    buckets = []
    network_security_groups = []
    network_security_lists = []

    # Start print time info
    start_datetime = datetime.datetime.now()
    start_time = str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    key_time_max_datetime = start_datetime - datetime.timedelta(days=DAYS_OLD)
    key_time_max_datetime = key_time_max_datetime.strftime('%Y-%m-%d %H:%M:%S')

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
            
            self._tenancy = self._identity.get_tenancy(config["tenancy"]).data
            self._regions = self._identity.list_region_subscriptions(self._tenancy.id).data
            self.compartments = self._identity_read_compartments()

        except Exception as e:
            raise RuntimeError("Failed to create service objects")
    
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
                    'name' : user.name
                }
                
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
                    'time_created' : api_key.time_created.strftime('%Y-%m-%d %H:%M:%S')
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
                'time_created' : token.time_created.strftime('%Y-%m-%d %H:%M:%S'),
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
                'time_created' : key.time_created.strftime('%Y-%m-%d %H:%M:%S'),
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
            policies_data = oci.pagination.list_call_get_all_results(
                self._identity.list_policies,
                self._tenancy.id,
            ).data

            print("    Total " + str(len(policies_data)) + " compartments loaded.")
            return policies_data

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
                            "egress_security_rules" : security_list.egress_security_rules,
                            "ingress_security_rules" : security_list.ingress_security_rules
                        }

                        # Append NSG to list of NSGs
                        self.network_security_lists.append(record)

            return self.network_security_lists
        except Exception as e:
            raise RuntimeError("Error in network_read_network_security_lists " + str(e.args))


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
# Logging - Log Groups and Logs
##########################################################################
def logging_read_log_groups_and_logs(logging, compartments):
    log_list = []
    print("Loading Log Groups and Logs...")

    try:
        # Looping through compartments
        for compartment in compartments:
            # Checking if Managed Compartment cause I can't query it
            if if_not_managed_paas_compartment(compartment.name):
                # Getting Log Groups in compartment
                log_groups = oci.pagination.list_call_get_all_results(
                        logging.list_log_groups,
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
                        logging.list_logs,
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
                            "configuration" : {
                                "compartment_id" : log.configuration.compartment_id,
                                "source_category" : log.configuration.source.category,
                                "source_parameters" : log.configuration.source.parameters,
                                "source_resource" : log.configuration.source.resource,
                                "source_service" : log.configuration.source.service,
                                "source_source_type" : log.configuration.source.source_type
                            }
                        }
                        # Append Log to log List
                        record['logs'].append(log_record)
                    log_list.append(record)

        return log_list
    except Exception as e:
        raise RuntimeError("Error in network_read_network_security_groups_rules " + str(e.args))

##########################################################################
# Events
##########################################################################
def events_read_event_rules(events, compartments):
    event_rules = []
    print("Loading Event Rules...")
    try:
        for compartment in compartments:
            if if_not_managed_paas_compartment(compartment.name):
                events_rules_data = oci.pagination.list_call_get_all_results(
                    events.list_rules,
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
                    event_rules.append(record)
        
        return event_rules
    except Exception as e:
        raise RuntimeError("Error in events_read_rules " + str(e.args))



##########################################################################
# Run advanced search structure query
##########################################################################
def search_run_structured_query(search_client, query):
    print("Load resources in root compartment: \n" + query)
    try:
        structured_search = oci.resource_search.models.StructuredSearchDetails(query=query, type='Structured', 
            matching_context_type=oci.resource_search.models.SearchDetails.MATCHING_CONTEXT_TYPE_NONE)
        search_results = search_client.search_resources(structured_search).data.items

        return search_results
    
    except Exception as e:
        raise RuntimeError("Error in search_run_structure_query " + str(e.args))



def events_cis_check(event_rules):

    cis_3_4_identity_provider_changes = [
        'com.oraclecloud.identitycontrolplane.createidentityprovider',
        'com.oraclecloud.identitycontrolplane.deleteidentityprovider',
        'com.oraclecloud.identitycontrolplane.updateidentityprovider'
    ]
    for event in event_rules:
        if (set(
            cis_3_4_identity_provider_changes).issubset(
                set(event['condition']))
                and event['is_enabled']):
                cis_3_4_flag = True
                print("&&&" * 30)
                print("CIS_3_4 is set")

        # if (set(
        #     self.cis_3_5_identity_group_changes).issubset(
        #         set(json_conditions['eventType']))
        #         and event['is_enabled'] == "True"):
        #         self._cis_3_5_flag = True
        #         print("CIS_3_5 is set")

        # if (set(
        #     self.cis_3_6_iam_group_changes).issubset(
        #         set(json_conditions['eventType']))
        #         and event['is_enabled'] == "True"):
        #         self._cis_3_6_flag = True
        #         print("CIS_3_6 is set")                    

        # if (set(
        #     self.cis_3_7_iam_policy_changes).issubset(
        #         set(json_conditions['eventType']))
        #         and event['is_enabled'] == "True"):
        #         self._cis_3_6_flag = True
        #         print("CIS_3_7 is set")  
        # if (set(
        #     self.cis_3_8_user_changes).issubset(
        #         set(json_conditions['eventType']))
        #         and event['is_enabled'] == "True"):
        #         self._cis_3_8_flag = True
        #         print("CIS_3_8 is set")  
        # if (set(
        #     self.cis_3_9_vcn_changes).issubset(
        #         set(json_conditions['eventType']))
        #         and event['is_enabled'] == "True"):
        #         self._cis_3_9_flag = True
        #         print("CIS_3_9 is set")  
        # if (set(
        #     self.cis_3_10_route_table_changes).issubset(
        #         set(json_conditions['eventType']))
        #         and event['is_enabled'] == "True"):
        #         self._cis_3_10_flag = True
        #         print("CIS_3_10 is set")  

        # if (set(
        #     self.cis_3_11_security_list_changes).issubset(
        #         set(json_conditions['eventType']))
        #         and event['is_enabled'] == "True"):
        #         self._cis_3_11_flag = True
        #         print("CIS_3_11 is set")  

        # if (set(
        #     self.cis_3_12_security_groups_changes).issubset(
        #         set(json_conditions['eventType']))
        #         and event['is_enabled'] == "True"):
        #         self._cis_3_12_flag = True
        #         print("CIS_3_12 is set")  

        # if (set(
        #     self.cis_3_13_network_gateway_changes).issubset(
        #         set(json_conditions['eventType']))
        #         and event['is_enabled'] == "True"):
                
        #         self._cis_3_13_flag = True
        #         print("CIS_3_13 is set")  



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
start_datetime = datetime.datetime.now()
start_time = str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
key_time_max_datetime = start_datetime - datetime.timedelta(days=DAYS_OLD)
key_time_max_datetime = key_time_max_datetime.strftime('%Y-%m-%d %H:%M:%S')

print(start_datetime)
print(key_time_max_datetime)

print_header("Running CIS Reports")
print("Code base By Adi Zohar, June 2020")
print("Written By Andre Luiz Correa Neto & Josh Hammer, November 2020")
print("Starts at " + str(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")))
print("Command Line : " + ' '.join(x for x in sys.argv[1:]))

# Identity extract compartments
config, signer = create_signer(cmd.config_profile, cmd.is_instance_principals, cmd.is_delegation_token)
report = CIS_Report(config,signer)
buckets = report.os_read_buckets()
# print(buckets)
users = report.identity_read_users()
print(users)

sls = report.network_read_network_security_lists()
print(type(sls[0]['ingress_security_rules'][0]))

# compartments = []
# tenancy = None
# try:
#     print("\nConnecting to Identity Service...")
#     identity = oci.identity.IdentityClient(config, signer=signer)
#     if cmd.proxy:
#         identity.base_client.session.proxies = {'https': cmd.proxy}

#     print("\nConnecting to Audit Service...")
#     audit = oci.audit.AuditClient(config, signer=signer)
#     if cmd.proxy:
#         audit.base_client.session.proxies = {'https': cmd.proxy}

#     print("\nConnecting to Advance Search Service...")
#     search = oci.resource_search.ResourceSearchClient(config, signer=signer)
#     if cmd.proxy:
#         search.base_client.session.proxies = {'https': cmd.proxy}

#     print("\nConnecting to Network Service...")
#     network = oci.core.VirtualNetworkClient(config, signer=signer)
#     if cmd.proxy:
#         network.base_client.session.proxies = {'https': cmd.proxy}

#     print("\nConnecting to Events Service...")
#     events = oci.events.EventsClient(config, signer=signer)
#     if cmd.proxy:
#         events.base_client.session.proxies = {'https': cmd.proxy}

#     print("\nConnecting to Logging Service...")
#     logging = oci.logging.LoggingManagementClient(config, signer=signer)
#     if cmd.proxy:
#         logging.base_client.session.proxies = {'https': cmd.proxy}

#     print("\nConnecting to Object Storage Service...")
#     os_client = oci.object_storage.ObjectStorageClient(config, signer=signer)
#     if cmd.proxy:
#         os_client.base_client.session.proxies = {'https': cmd.proxy}
    
#     tenancy = identity.get_tenancy(config["tenancy"]).data
#     regions = identity.list_region_subscriptions(tenancy.id).data
#     audit_retention_period = audit.get_configuration(tenancy.id).data.retention_period_days


#     cis_resource_search_queries = [
#         {"recommendation_#" : "2.1",
#         "query" : """query SecurityList resources where 
#                     (IngressSecurityRules.source = '0.0.0.0/0' && 
#                     IngressSecurityRules.protocol = 6 && 
#                     IngressSecurityRules.tcpOptions.destinationPortRange.max = 22 && 
#                     IngressSecurityRules.tcpOptions.destinationPortRange.min = 22)"""
#         },
#         {"recommendation_#" : "2.2",
#         "query" : """query SecurityList resources where 
#             (IngressSecurityRules.source = '0.0.0.0/0' && 
#             IngressSecurityRules.protocol = 6 && 
#             IngressSecurityRules.tcpOptions.destinationPortRange.max = 3389 && 
#             IngressSecurityRules.tcpOptions.destinationPortRange.min = 3389)"""
#         },  
#         {"recommendation_#" : "3.4",
#         "query" : """query eventrule resources where condition = '{"eventType":["com.oraclecloud.identitycontrolplane.createidentityprovider",
#             "com.oraclecloud.identitycontrolplane.deleteidentityprovider",
#             "com.oraclecloud.identitycontrolplane.updateidentityprovider"],"data":{}}'""".upper()
#         },   
#         {"recommendation_#" : "4.1",
#         "query" : """query bucket resources where (publicAccessType == 'ObjectRead') || 
#             (publicAccessType == 'ObjectReadWithoutList')"""
#         },
#         {"recommendation_#" : "5.2",
#         "query" : "query VCN, instance, volume, filesystem, bucket, autonomousdatabase, database, dbsystem resources where compartmentId = '" + tenancy.id + "'"
#         }
#     ]

#     testcg = """query eventrule resources where
#     condition = '{"eventType":["com.oraclecloud.cloudguard.problemdetected"],"data":{}}'"""

#     testcg1 = """query eventrule resources where
#         condition = '{"eventType":["com.oraclecloud.identitycontrolplane.createidentityprovider",
#         "com.oraclecloud.identitycontrolplane.deleteidentityprovider",
#         "com.oraclecloud.identitycontrolplane.updateidentityprovider"],"data":{}}'"""
#     print("Tenant Name : " + str(tenancy.name))
#     print("Tenant Id   : " + tenancy.id)
#     print("")
#     print("Audit Period: " + str(audit_retention_period))
    
#     # print(cis_resource_search_queries[3]['query'])
#     # security_lists = search_run_structured_query(search,testcg)
#     # print(security_lists)

#     compartments = identity_read_compartments(identity, tenancy)
#     # policies = identity_read_tenancy_policies(identity, tenancy)
    
#     # nsgs = network_read_network_security_groups_rules(network, compartments)
#     # print(nsgs)

#     buckets = os_read_buckets(os_client, compartments)

#     print(buckets)

#     event_rules = events_read_event_rules(events,compartments)
#     print(event_rules)
#     print(len(event_rules))
#     for event in event_rules:
#         cis_3_4_identity_provider_changes = [
#         'com.oraclecloud.identitycontrolplane.createidentityprovider',
#         'com.oraclecloud.identitycontrolplane.deleteidentityprovider',
#         'com.oraclecloud.identitycontrolplane.updateidentityprovider'
#         ]
#         for rule in cis_3_4_identity_provider_changes:
#             if rule.upper() in event['condition'].upper():
#                 print("I have one")
#                 print(event['condition'])

#         print(type(event['condition']))

#     # events_cis_check(event_rules)

#     # logs = logging_read_log_groups_and_logs(logging,compartments)
#     # print(logs)

#     # print("###" * 30)
#     # for compartment in compartments:
#     #     print(compartment.name)
#     #     if not(if_managed_paas_compartment(compartment.name)):
#     #         nsgs_data = oci.pagination.list_call_get_all_results(
#     #                 network.list_network_security_groups,
#     #                 compartment.id
#     #             ).data
#     #         print(nsgs_data)


#     # for policy in policies:
#     #     for statement in policy.statements:
#     #         if "to manage all-resources in tenancy".upper() in statement.upper():
#     #             print("Bad Policy")
#     #             print(policy.name)

#    # users = identity_read_users(identity, tenancy)



#     # for user in users:
#     #     if 'hammer' in user['name']:

#     #         print(user)
#     #         print(user['customer_secret_keys'][0])
#     #         print(type(user['api_keys'][0]))
#     #         print("Key max time is:")
#     #         print(key_time_max_datetime)

#     #         for key in user['api_keys']:
#     #             print(type(key['time_created']))
#     #             if key_time_max_datetime > key['time_created']:
#     #                 print("Key Expired")
            

#     #         #print(type(user['auth_tokens'][0]))


# except Exception as e:
#     raise RuntimeError("\nError extracting compartments section - " + str(e))
