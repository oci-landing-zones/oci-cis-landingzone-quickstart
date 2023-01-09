# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

from fileinput import filename
import os
import sys
import argparse
import csv
import glob
from os.path import exists

script_files = {
    'cis_Asset_Management_5-2.csv': { 'columns' : [1],  'exists' : None, 'pass' : None},
    'cis_Identity_and_Access_Management_1-1.csv': { 'columns' : [0],  'exists' : None, 'pass' : None},
    'cis_Identity_and_Access_Management_1-2.csv': { 'columns' : [0],  'exists' : None, 'pass' : None},
    'cis_Identity_and_Access_Management_1-3.csv': { 'columns' : [0],  'exists' : None, 'pass' : None},
    'cis_Identity_and_Access_Management_1-10.csv': { 'columns' : [1,2], 'exists' : None, 'pass' : None},
    'cis_Identity_and_Access_Management_1-11.csv': { 'columns' : [0,3],  'exists' : None, 'pass' : None},
    'cis_Identity_and_Access_Management_1-12.csv':{ 'columns' : [0],  'exists' : None, 'pass' : None},
    'cis_Identity_and_Access_Management_1-14.csv':  { 'columns' : [0],  'exists' : None, 'pass' : None},
    'cis_Identity_and_Access_Management_1-2.csv':  {'exists' : None, 'pass' : None},
    'cis_Identity_and_Access_Management_1-3.csv':   { 'exists' : None, 'pass' : None},
    'cis_Identity_and_Access_Management_1-7.csv':  { 'columns' : [0], 'exists' : None, 'pass' : None},
    'cis_Identity_and_Access_Management_1-8.csv':  { 'columns' : [1,2], 'exists' : None, 'pass' : None},
    'cis_Identity_and_Access_Management_1-9.csv':  { 'columns' : [0,1,2], 'exists' : None, 'pass' : None},
    'cis_Logging_and_Monitoring_3-14.csv' : { 'columns' : [0],  'exists' : None, 'pass' : None},
    'cis_Logging_and_Monitoring_3-16.csv' :   { 'columns' : [0,1,2], 'exists' : None, 'pass' : None},
    'cis_Logging_and_Monitoring_3-17.csv' :  { 'exists' : None, 'pass' : None},
    'cis_Networking_2-1.csv' :  { 'columns' : [2], 'exists' : None, 'pass' : None},
    'cis_Networking_2-2.csv' :   { 'columns' : [2],'exists' : None, 'pass' : None},
    'cis_Networking_2-3.csv' :   { 'columns' : [2],'exists' : None, 'pass' : None},
    'cis_Networking_2-4.csv' :  { 'columns' : [2], 'exists' : None, 'pass' : None},
    'cis_Networking_2-5.csv' :   { 'columns' : [2],'exists' : None, 'pass' : None},
    'cis_Networking_2-6.csv' :  { 'columns' : [0], 'exists' : None, 'pass' : None},
    'cis_Networking_2-7.csv' :   { 'columns' : [0],'exists' : None, 'pass' : None},
    'cis_Networking_2-8.csv' :   { 'columns' : [0], 'exists' : None, 'pass' : None},
    'cis_Storage_Block_Volumes_4-2-1.csv' :{ 'columns' : [0,1],  'exists' : None, 'pass' : None},
    'cis_Storage_Block_Volumes_4-2-2.csv' :  { 'columns' : [0,1],'exists' : None, 'pass' : None},
    'cis_Storage_File_Storage_Service_4-3-1.csv' : { 'columns' : [0,1], 'exists' : None, 'pass' : None},
    'cis_Storage_Object_Storage_4-1-1.csv' : { 'columns' : [0,1], 'exists' : None, 'pass' : None},
    'cis_Storage_Object_Storage_4-1-2.csv' : { 'columns' : [0,1], 'exists' : None, 'pass' : None},
    'cis_Storage_Object_Storage_4-1-3.csv' : { 'columns' : [0,1], 'exists' : None, 'pass' : None},
    'cis_summary_report.csv' :    { 'columns' : [0,4],'exists' : None, 'pass' : None},
    'obp_SIEM_Audit_Incl_Sub_Comp_Best_Practices.csv' : {'columns' : [0], 'exists' : None, 'pass' : None},
    'obp_SIEM_Audit_Log_All_Comps_Best_Practices.csv' : {'columns' : [0,2], 'exists' : None, 'pass' : None},
    'obp_SIEM_Audit_Incl_Sub_Comp_Findings.csv' : {'columns' : [0], 'exists' : None, 'pass' : None},
    'obp_SIEM_Audit_Log_All_Comps_Findings.csv' : {'columns' : [0], 'exists' : None, 'pass' : None},

    'obp_Cloud_Guard_Config_Findings.csv' : {'columns' : [0,1,2,3,4,5,6,7,8,9,10,11,12], 'exists' : None, 'pass' : None},
    'obp_Cost_Tracking_Budgets_Best_Practices.csv' : {'columns' : [7], 'exists' : None, 'pass' : None},
    'obp_Cost_Tracking_Budgets_Findings.csv' : {'columns' : [7], 'exists' : None, 'pass' : None},
    'obp_Networking_Connectivity_Findings.csv' : {'columns' : [0], 'exists' : None, 'pass' : None},

    'obp_OBP_Summary.csv' : {'columns' : [0,1,2], 'exists' : None, 'pass' : None},
    
    'obp_SIEM_Read_Bucket_Logs_Findings.csv' : {'columns' : [0], 'exists' : None, 'pass' : None},
    'obp_SIEM_VCN_Flow_Logging_Best_Practices.csv' : {'columns' : [0], 'exists' : None, 'pass' : None},
    'obp_SIEM_VCN_Flow_Logging_Findings.csv' : {'columns' : [0], 'exists' : None, 'pass' : None},

    'obp_SIEM_Write_Bucket_Logs_Best_Practices.csv' : {'columns' : [0], 'exists' : None, 'pass' : None},
    'obp_SIEM_Write_Bucket_Logs_Findings.csv' : {'columns' : [0], 'exists' : None, 'pass' : None},


    'raw_data_autonomous_databases.csv' : {'columns' : [6,7], 'exists' : None, 'pass' : None },
    'raw_data_budgets.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_analytics_instances.csv'  :  { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_block_volumes.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_boot_volumes.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_file_stroage_system.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},     # remove after  1/1/2023
    # 'raw_data_file_storage_system.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_event_rules.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_cloud_guard_target.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},

    'raw_data_identity_groups_and_membership.csv' :  { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_identity_compartments.csv' :  { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_identity_dyanmic_groups.csv' :  { 'columns' : [0], 'exists' : None, 'pass' : None},     # remove after  1/1/2023
    # 'raw_data_identity_dynamic_groups.csv' :  { 'columns' : [0], 'exists' : None, 'pass' : None},

    'raw_data_identity_policies.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_identity_tags.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_identity_users.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_integration_instances.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_log_groups_and_logs.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_network_drgs.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_network_fastconnects.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_network_ipsec_connections.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_network_security_groups.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},

    'raw_data_network_security_lists.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_network_subnets.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_object_storage_buckets.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_ons_subscriptions.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_regions.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_service_connectors.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_vaults_and_keys.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},
    'raw_data_service_connectors.csv' : { 'columns' : [0], 'exists' : None, 'pass' : None},

    'Consolidated_Report.xlsx' : { 'columns' : [0], 'exists' : True, 'pass' : True}, # not checked

}


def set_parser_arguments():

    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--dir1',
        dest='dir1',
        help="First CSV file for comparison"
    )
    parser.add_argument(
        '--dir2',
        dest='dir2',
        help="First CSV file for comparison")
    result = parser.parse_args()


    if len(sys.argv) < 3:
        parser.print_help()
        return None

    return result


def compare_csvs(file_name1, file_name2, interesting_cols):
    true_tracker = None
    with open(file_name1, 'r') as file1,\
        open(file_name2, 'r') as file2:

        reader1, reader2 = csv.reader(file1), csv.reader(file2)

        for line1, line2 in zip(reader1, reader2):
            equal = all(x == y
                for n, (x, y) in enumerate(zip(line1, line2))
                if n in interesting_cols
            )            
            if equal == False:
                true_tracker = False
                break
            else: 
                true_tracker = True


    return true_tracker

def execute():
    # file_to_open1 = 'ociateam-2022-11-29_17-37-15/raw_data_vaults_and_keys.csv'
    # file_to_open2 = 'ociateam-2022-11-29_16-49-55/raw_data_vaults_and_keys.csv'
    # print(compare_csvs(file_to_open1, file_to_open2, script_files['raw_data_vaults_and_keys.csv']['columns']))


    args = set_parser_arguments()
    print(args.dir1)
    print(args.dir2)
    # Same files in both directories
    # if os.listdir(args.dir1) == os.listdir(args.dir2):



    for file in script_files.keys():
        file_to_open1 = args.dir1 + file
        file_to_open2 = args.dir2 + file

        if exists(file_to_open1) and exists(file_to_open2) and '.csv' in file_to_open1:
            script_files[file]['exists'] = True
            try:

                script_files[file]['pass'] = compare_csvs(file_to_open1, file_to_open2, script_files[file]['columns'])

            except:
                script_files[file]['pass'] = False
    



    status = True
    for file, values in script_files.items():
        if values['pass'] is False :
            print("This file did not pass: " + file + " " + str(values))
            status = False
    print("*" * 40)
    print("Reports are the same: " + str(status))
    print("*" * 40)

    return status

    # else:
    #     # Directories don't match
    #     print("BAD")
    #     return False

execute()