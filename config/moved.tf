# Copyright (c) 2022 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

#------------------------------------------------------------------------------------------------------
#-- Modules that moved as they became optional. Release 2.4.0. Requires Terraform 1.1
#------------------------------------------------------------------------------------------------------
moved {
  from = module.lz_buckets
  to   = module.lz_buckets[0]
}

moved {
  from = module.lz_vault
  to   = module.lz_vault[0]
}

moved {
  from = module.lz_keys
  to   = module.lz_keys[0]
}

moved {
  from = module.lz_service_connector
  to   = module.lz_service_connector[0]
}
