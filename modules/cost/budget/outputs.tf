# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "budget" {
  description = "Budget information."
  value       = length(oci_budget_budget.these) > 0 ? oci_budget_budget.these : null
}

