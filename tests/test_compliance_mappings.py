import ast
import csv
import datetime
import importlib.util
import json
import re
import sys
import tempfile
import types
import unittest
from pathlib import Path
from unittest.mock import patch


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
SPEC = importlib.util.spec_from_file_location('cis_reports_mappings', SCRIPT_PATH)
cis_reports = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(cis_reports)


class ComplianceMappingTests(unittest.TestCase):
    def test_default_table(self):
        self.assertEqual(cis_reports.ComplianceMappings.get_mapping_names(),
                         ('CIS v8', 'CCCS Guard Rail', 'Oracle SaaS v1'))

    def test_validation_reports_all_rows_and_ignores_key_order(self):
        class Mappings(cis_reports.ComplianceMappings):
            MAPPING_NAMES = ('A', 'B')
            mappings = {
                'ordered-differently': {'B': [], 'A': []},
                'missing': {'A': []},
                'extra': {'A': [], 'B': [], 'C': []},
                'invalid': {'A': 'not a list', 'B': []},
                'not-a-dict': [],
            }

        with self.assertRaises(ValueError) as error:
            Mappings.get_mapping_names()
        message = str(error.exception)
        self.assertIn("missing: missing framework names ['B']", message)
        self.assertIn("extra: unexpected framework names ['C']", message)
        self.assertIn('invalid:', message)
        self.assertIn('not-a-dict:', message)
        self.assertNotIn('ordered-differently:', message)

    def test_duplicate_and_empty_configuration(self):
        class Mappings(cis_reports.ComplianceMappings):
            MAPPING_NAMES = ('A', 'A')
            mappings = {'one': {'A': []}}

        with self.assertRaisesRegex(ValueError, 'Duplicate'):
            Mappings.get_mapping_names()
        Mappings.mappings = {}
        self.assertEqual(Mappings.get_mapping_names(), ())


class ComplianceReportTests(unittest.TestCase):
    def test_xlsx_import_preserves_unicode_csv_headers(self):
        tree = ast.parse(SCRIPT_PATH.read_text())
        execute_report = next(node for node in tree.body
                              if isinstance(node, ast.FunctionDef) and node.name == 'execute_report')
        add_sheet = next(node for node in ast.walk(execute_report)
                         if isinstance(node, ast.FunctionDef) and node.name == 'add_sheet')
        module = ast.fix_missing_locations(ast.Module(body=[add_sheet], type_ignores=[]))
        namespace = {'csv': csv, 're': re, 'worksheet_name': 'summary'}
        exec(compile(module, str(SCRIPT_PATH), 'exec'), namespace)
        written = []
        sheet = types.SimpleNamespace(
            write=lambda row, column, value: written.append(value),
            autofilter=lambda *args: None,
            autofit=lambda: None)
        workbook = types.SimpleNamespace(add_worksheet=lambda name: sheet)
        with tempfile.TemporaryDirectory() as directory:
            csv_path = Path(directory) / 'summary.csv'
            csv_path.write_text('客户框架\ncontrol-1\n', encoding='utf-8')
            namespace['add_sheet'](workbook, str(csv_path), 'summary')
        self.assertEqual(written, ['客户框架', 'control-1'])

    def test_frameworks_flow_through_cis_obp_csv_json_and_html(self):
        names = ('CIS v8', 'ISO 27001', 'NIST 800-53', 'PCI DSS', '客户 "<test>"')
        mappings = {name: [f'control {index}'] for index, name in enumerate(names)}
        report = object.__new__(cis_reports.CIS_Report)
        report.cis_foundations_benchmark_3_0 = {
            '1.1': {'id': 'IAM-1', 'section': 'Identity', 'recommendation_#': '1.1',
                    'Title': 'CIS title', 'Status': True, 'Level': 1,
                    'Total': [], 'Findings': []}}
        report.obp_foundations_checks = {
            'check': {'id': 'OBP-1', 'section': 'OBP', 'Title': 'OBP title',
                      'Status': True, 'Findings': [], 'OBP': [], 'Documentation': ''}}
        report.cis_report_data = {'1.1': {'Remediation': 'Fix it'}}
        report._CIS_Report__report_prefix = ''
        report._CIS_Report__regions_to_run_in = ['region-1']
        report._CIS_Report__print_to_screen = False
        report._CIS_Report__output_bucket = None
        report._CIS_Report__report_summary_json = True
        report._CIS_Report__redact_output = False
        report._CIS_Report__generated_csv_files = []
        report._CIS_Report__tenancy = types.SimpleNamespace(name='test tenancy')

        with tempfile.TemporaryDirectory() as directory, \
             patch.object(cis_reports.ComplianceMappings, 'MAPPING_NAMES', names), \
             patch.object(cis_reports.ComplianceMappings, 'mappings',
                          {'IAM-1': mappings, 'OBP-1': mappings}), \
             patch.object(cis_reports, 'OUTPUT_DIAGRAMS', False), \
             patch.object(cis_reports, 'debug'):
            report._CIS_Report__get_output_file_path = lambda header, subject, suffix: str(
                Path(directory) / f'{header}_{subject}{suffix}')
            report._CIS_Report__map_compliance_to_script()
            cis_rows = report._CIS_Report__report_generate_cis_report(1)
            obp_rows = report._CIS_Report__report_generate_obp_report()
            html_path = report._CIS_Report__report_generate_html_summary_report(
                'cis', 'summary_report', cis_rows, obp_rows)

            for row in (cis_rows[0], obp_rows[0]):
                self.assertEqual([name for name in row if name in names], list(names))
                for name in names:
                    self.assertEqual(row[name], mappings[name])

            for filename in ('cis_summary_report.csv', 'obp_OBP_Summary.csv'):
                with open(Path(directory) / filename, newline='') as file:
                    row = next(csv.DictReader(file))
                for name in names:
                    self.assertIn(name, row)
                    self.assertIn(mappings[name][0], row[name])
            for filename in ('cis_summary_report.json', 'obp_summary_report.json'):
                row = json.loads((Path(directory) / filename).read_text())[0]
                for name in names:
                    self.assertEqual(row[name], mappings[name])

            html = Path(html_path).read_text(encoding='utf-8')
            payload = json.loads(html.split('<script>const D=', 1)[1].split(',FRAMEWORKS=', 1)[0])
            self.assertEqual(payload['frameworks'], list(names))
            for row in (payload['findings'][0], payload['obp_findings'][0]):
                for name in names:
                    self.assertEqual(row[name], mappings[name])
            self.assertIn('<th>Framework mappings</th>', html)
            self.assertIn('FRAMEWORKS=D.frameworks||[]', html)
            self.assertIn('frameworkMappings(row)', html)
            self.assertNotIn('<b>Framework mappings</b>', html)
            self.assertNotIn('客户 "<test>"', html)


if __name__ == '__main__':
    unittest.main()
