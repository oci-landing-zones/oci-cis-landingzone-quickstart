# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


output alarms {
    description = "The alarms, indexed by display name."
    value = {for alarm in oci_monitoring_alarm.these : alarm.display_name => alarm}
}
