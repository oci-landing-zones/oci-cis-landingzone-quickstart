import datetime
import importlib.util
import sys
import types
import unittest
from pathlib import Path


def install_module_stub(name, **attributes):
    try:
        __import__(name)
    except ModuleNotFoundError:
        module = types.ModuleType(name)
        for attribute, value in attributes.items():
            setattr(module, attribute, value)
        sys.modules[name] = module


install_module_stub('pytz', UTC=datetime.timezone.utc)
install_module_stub('oci')
install_module_stub('requests')

SCRIPT_PATH = Path(__file__).resolve().parents[1] / 'scripts' / 'cis_reports.py'
SPEC = importlib.util.spec_from_file_location('cis_reports', SCRIPT_PATH)
cis_reports = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(cis_reports)


class NetworkMapCollectionTests(unittest.TestCase):
    def new_report(self):
        report = object.__new__(cis_reports.CIS_Report)
        report._CIS_Report__errors = []
        report._CIS_Report__network_route_tables = []
        report._CIS_Report__network_route_rules = []
        report._CIS_Report__network_internet_gateways = []
        report._CIS_Report__network_nat_gateways = []
        report._CIS_Report__network_service_gateways = []
        report._CIS_Report__network_local_peering_gateways = []
        report._CIS_Report__network_remote_peering_connections = []
        report._CIS_Report__network_cpes = []
        report._CIS_Report__network_drg_route_tables = []
        report._CIS_Report__network_drg_route_rules = []
        report._CIS_Report__network_bgp_received_routes = []
        report._CIS_Report__network_bgp_advertised_routes = []
        return report

    def test_collects_route_table_rules_and_search_discovered_gateway(self):
        report = self.new_report()
        resource = types.SimpleNamespace(
            identifier='rt-1', display_name='route-table', compartment_id='compartment-1',
            lifecycle_state='AVAILABLE', time_created='2026-10-01T00:00:00',
            freeform_tags={}, defined_tags={}, additional_details={})
        gateway = types.SimpleNamespace(
            identifier='igw-1', display_name='internet-gateway', compartment_id='compartment-1',
            lifecycle_state='AVAILABLE', time_created='2026-10-01T00:00:00',
            freeform_tags={}, defined_tags={}, additional_details={'vcnId': 'vcn-1'})
        route_rule = types.SimpleNamespace(
            destination='0.0.0.0/0', destination_type='CIDR_BLOCK', network_entity_id='igw-1',
            description='internet access', route_type='STATIC', is_blackhole=False)
        route_table = types.SimpleNamespace(
            id='rt-1', display_name='route-table', compartment_id='compartment-1', vcn_id='vcn-1',
            lifecycle_state='AVAILABLE', time_created='2026-10-01T00:00:00', freeform_tags={},
            defined_tags={}, route_rules=[route_rule])
        client = types.SimpleNamespace(get_route_table=lambda identifier: types.SimpleNamespace(data=route_table))
        report._CIS_Report__regions = {'region-1': {'network_client': client}}
        report._CIS_Report__search_resource_in_region = lambda resource_type, _: {
            'RouteTable': [resource], 'InternetGateway': [gateway]}.get(resource_type, [])

        report._CIS_Report__network_read_network_map_resources()

        self.assertEqual(report._CIS_Report__network_route_tables[0]['id'], 'rt-1')
        self.assertEqual(report._CIS_Report__network_route_rules[0]['network_entity_id'], 'igw-1')
        self.assertEqual(report._CIS_Report__network_internet_gateways[0]['vcn_id'], 'vcn-1')

    def test_collects_received_and_advertised_bgp_routes(self):
        report = self.new_report()
        ip_sec = types.SimpleNamespace(identifier='ipsec-1')
        tunnel = types.SimpleNamespace(id='tunnel-1')
        route = types.SimpleNamespace(route='10.0.0.0/16', as_path='65000', next_hop='169.254.0.1', origin_asn='65000', is_overlapping=False)
        cis_reports.oci.util = types.SimpleNamespace(to_dict=lambda value: {'route': value.route})
        cis_reports.oci.pagination = types.SimpleNamespace(
            list_call_get_all_results=lambda *args, **kwargs: types.SimpleNamespace(data=[route]))
        client = types.SimpleNamespace(list_ip_sec_connection_tunnel_routes=lambda **kwargs: None)

        report._CIS_Report__network_read_ipsec_bgp_routes(
            'region-1', {'network_client': client}, ip_sec, tunnel)

        self.assertEqual(report._CIS_Report__network_bgp_received_routes[0]['advertiser'], 'CUSTOMER')
        self.assertEqual(report._CIS_Report__network_bgp_advertised_routes[0]['advertiser'], 'ORACLE')

    def test_collects_drg_route_tables_and_rules(self):
        report = self.new_report()
        drg = types.SimpleNamespace(id='drg-1')
        route_table = types.SimpleNamespace(
            id='drg-route-table-1', display_name='drg-route-table', compartment_id='compartment-1',
            is_ecmp_enabled=True, lifecycle_state='AVAILABLE', time_created='2026-10-01T00:00:00',
            freeform_tags={}, defined_tags={})
        route_rule = types.SimpleNamespace(
            id='drg-route-rule-1', destination='10.0.0.0/16', destination_type='CIDR_BLOCK',
            next_hop_drg_attachment_id='attachment-1', route_type='STATIC',
            route_provenance='STATIC', is_blackhole=False)
        cis_reports.oci.pagination = types.SimpleNamespace(
            list_call_get_all_results=lambda *args, **kwargs: types.SimpleNamespace(
                data=[route_table] if 'drg_id' in kwargs else [route_rule]))
        client = types.SimpleNamespace(
            list_drg_route_tables=lambda **kwargs: None,
            list_drg_route_rules=lambda **kwargs: None)

        report._CIS_Report__network_read_drg_route_tables('region-1', {'network_client': client}, drg)

        self.assertEqual(report._CIS_Report__network_drg_route_tables[0]['drg_id'], 'drg-1')
        self.assertEqual(report._CIS_Report__network_drg_route_rules[0]['next_hop_drg_attachment_id'], 'attachment-1')
