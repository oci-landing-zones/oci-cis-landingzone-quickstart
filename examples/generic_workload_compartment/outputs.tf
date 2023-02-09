# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "compartments" {
  value = merge(module.cislz_compartments.level_1_compartments, module.cislz_compartments.level_2_compartments,
                module.cislz_compartments.level_3_compartments, module.cislz_compartments.level_4_compartments,
                module.cislz_compartments.level_5_compartments, module.cislz_compartments.level_6_compartments)
}