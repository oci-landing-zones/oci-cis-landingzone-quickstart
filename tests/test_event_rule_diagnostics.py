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

    def test_partial_and_invalid_conditions_do_not_interrupt(self):
        self.report._CIS_Report__event_rules = [self.rule(condition='not json'),
            self.rule(id='partial', condition='{"eventType": ["event.create"]}')]
        self.report._CIS_Report__cis_check_tagging_and_monitoring()
        finding = self.report.cis_foundations_benchmark_3_0['4.3']['Findings'][0]
        self.assertIn('event.update', finding['reason'])


if __name__ == '__main__':
    unittest.main()
