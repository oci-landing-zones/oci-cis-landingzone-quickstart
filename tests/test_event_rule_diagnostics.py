import ast
import json
import pathlib
import types
import unittest


def load_checks():
    path = pathlib.Path(__file__).parents[1] / 'scripts' / 'cis_reports.py'
    tree = ast.parse(path.read_text())
    cls = next(node for node in tree.body if isinstance(node, ast.ClassDef) and node.name == 'CIS_Report')
    methods = [node for node in cls.body if isinstance(node, ast.FunctionDef) and node.name in {
        '__event_rule_failure_details', '__cis_check_tagging_and_monitoring'}]
    # Isolate the event-rule portion from unrelated subnet and storage checks.
    check = next(node for node in methods if node.name == '__cis_check_tagging_and_monitoring')
    check.body = [node for node in check.body if node.lineno < next(
        item.lineno for item in check.body
        if isinstance(item, ast.Expr) and isinstance(item.value, ast.Call)
        and isinstance(item.value.func, ast.Name) and item.value.func.id == 'debug'
        and item.value.args and isinstance(item.value.args[0], ast.Constant)
        and 'Flowlogs checking CIS 4.13' in str(item.value.args[0].value))]
    module = ast.fix_missing_locations(ast.Module(body=[ast.ClassDef(
        name='CIS_Report', bases=[], keywords=[], body=methods, decorator_list=[])], type_ignores=[]))
    namespace = {'json': json, 'debug': lambda *args: None}
    exec(compile(module, str(path), 'exec'), namespace)
    return namespace['CIS_Report']


class EventRuleDiagnosticsTests(unittest.TestCase):
    def setUp(self):
        self.report = object.__new__(load_checks())
        self.report._CIS_Report__tag_defaults = []
        self.report._CIS_Report__subscriptions = []
        self.report._CIS_Report__event_rules = []
        self.report._CIS_Report__tenancy = types.SimpleNamespace(id='root')
        self.report._CIS_Report__cis_regional_checks = {'4.3'}
        self.report._CIS_Report__cis_regional_findings_data = {'4.3': {'region-1': None, 'region-2': None}}
        self.report._CIS_Report__cloud_guard_config = None
        self.report._CIS_Report__home_region = 'region-1'
        self.report.cis_monitoring_checks = {'4.3': ['event.create', 'event.update']}
        self.report.cis_foundations_benchmark_3_0 = {
            key: {'Status': False, 'Total': [], 'Findings': []} for key in ('4.1', '4.2', '4.3')}

    def rule(self, **changes):
        event = {'id': 'rule-1', 'display_name': 'Rule', 'lifecycle_state': 'ACTIVE',
                 'compartment_id': 'root', 'region': 'region-1',
                 'condition': '{"eventType": ["event.create", "event.update"]}',
                 'actions': [{'actionType': 'ONS', 'topicId': 'topic'}]}
        event.update(changes)
        return event

    def test_failed_regions_keep_counts_and_explain_candidate(self):
        self.report._CIS_Report__event_rules = [self.rule()]
        self.report._CIS_Report__cis_check_tagging_and_monitoring()
        result = self.report.cis_foundations_benchmark_3_0['4.3']
        self.assertFalse(result['Status'])
        self.assertEqual(len(result['Total']), 2)
        self.assertEqual(len(result['Findings']), 2)
        self.assertIn('active subscription', result['Findings'][0]['reason'])
        self.assertIn('different region', result['Findings'][1]['reason'])

    def test_passing_candidate_and_non_ons_keep_existing_behavior(self):
        self.report._CIS_Report__event_rules = [self.rule(), self.rule(id='rule-2', actions=[{'actionType': 'FAAS'}])]
        self.report._CIS_Report__cis_check_tagging_and_monitoring()
        result = self.report.cis_foundations_benchmark_3_0['4.3']
        self.assertEqual(len(result['Findings']), 1)
        self.assertEqual(result['Findings'][0]['region'], 'region-2')

    def test_home_region_check_records_failure_and_success(self):
        for active_subscription in (False, True):
            with self.subTest(active_subscription=active_subscription):
                self.setUp()
                self.report._CIS_Report__cis_regional_findings_data = {}
                self.report.cis_monitoring_checks = {
                    '4.6': ['event.create', 'event.update'],
                    '4.15': ['cloudguard.event']}
                self.report.cis_foundations_benchmark_3_0.update({
                    key: {'Status': False, 'Total': [], 'Findings': []}
                    for key in ('4.6', '4.15')})
                self.report._CIS_Report__event_rules = [self.rule()]
                if active_subscription:
                    self.report._CIS_Report__subscriptions = [
                        {'topic_id': 'topic', 'lifecycle_state': 'ACTIVE'}]

                self.report._CIS_Report__cis_check_tagging_and_monitoring()

                result = self.report.cis_foundations_benchmark_3_0['4.6']
                self.assertEqual(result['Status'], active_subscription)
                self.assertEqual(result['Total'], [{'region': 'region-1'}])
                self.assertEqual(len(result['Findings']), 0 if active_subscription else 1)
                if not active_subscription:
                    self.assertEqual(result['Findings'][0]['region'], 'region-1')
                    self.assertIn('active subscription', result['Findings'][0]['reason'])
                self.assertEqual(self.report.cis_foundations_benchmark_3_0['4.15']['Total'], [])
                self.assertEqual(self.report.cis_foundations_benchmark_3_0['4.15']['Findings'], [])

    def test_partial_and_invalid_conditions_do_not_interrupt(self):
        self.report._CIS_Report__event_rules = [self.rule(condition='not json'),
            self.rule(id='partial', condition='{"eventType": ["event.create"]}')]
        self.report._CIS_Report__cis_check_tagging_and_monitoring()
        finding = self.report.cis_foundations_benchmark_3_0['4.3']['Findings'][0]
        self.assertIn('event.update', finding['reason'])

    def test_418_status_matches_regional_findings(self):
        for passing_regions in ((), ('region-1',), ('region-1', 'region-2')):
            with self.subTest(passing_regions=passing_regions):
                self.setUp()
                self.report._CIS_Report__cis_regional_checks = {'4.18'}
                self.report._CIS_Report__cis_regional_findings_data = {
                    '4.18': {'region-1': None, 'region-2': None}}
                self.report.cis_monitoring_checks = {'4.18': ['event.create', 'event.update']}
                self.report.cis_foundations_benchmark_3_0['4.18'] = {
                    'Status': True, 'Total': [], 'Findings': []}
                self.report._CIS_Report__event_rules = [
                    self.rule(region=region, actions=[{'actionType': 'FAAS'}])
                    for region in passing_regions]

                self.report._CIS_Report__cis_check_tagging_and_monitoring()

                result = self.report.cis_foundations_benchmark_3_0['4.18']
                self.assertEqual(result['Status'], len(passing_regions) == 2)
                self.assertEqual(len(result['Total']), 2)
                self.assertEqual(len(result['Findings']), 2 - len(passing_regions))
                self.assertEqual(len(result['Total']) - len(result['Findings']), len(passing_regions))


if __name__ == '__main__':
    unittest.main()
