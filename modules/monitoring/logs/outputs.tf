# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output log_group {
    description = "Log Group information."
    value = oci_logging_log_group.this
    
}

output logs {
    description = "The logs, indexed by display name."
    value = {for log in oci_logging_log.these : log.display_name => log}
}