# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "lz_dynamic_groups" {
  depends_on = [module.lz_compartments]
  source     = "../modules/iam/iam-dynamic-group"
  providers  = { oci = oci.home }
  dynamic_groups = var.use_existing_groups == false ? {
    ("dgrp-security-fun") = {
      compartment_id = var.tenancy_ocid
      description    = "Groupe dynamique de la Landing Zone pour les foncitons dans le compartiment ${local.security_compartment.name}."
      matching_rule  = "ALL {resource.type = 'fnfunc',resource.compartment.id = '${module.lz_compartments.compartments[local.security_compartment.key].id}'}"
    },
    ("dgrp-appdev-fun") = {
      compartment_id = var.tenancy_ocid
      description    = "Groupe dynamique de la Landing Zone pour les foncitons dans le compartiment ${local.appdev_compartment.name} (PRODUCTION)."
      matching_rule  = "ALL {resource.type = 'fnfunc',resource.compartment.id = '${module.lz_compartments.compartments[local.appdev_compartment.key].id}'}"
    },
    ("dgrp-database-kms") = {
      compartment_id = var.tenancy_ocid
      description    = "Groupe dynamique de la Landing Zone pour les bases de données dans le compartiment ${local.database_compartment.name}."
      matching_rule  = "ALL {resource.compartment.id = '${module.lz_compartments.compartments[local.database_compartment.key].id}'}"
    },
    #Edit Remy
    ("dgrp-appdevpreprod-fun") = {
      compartment_id = var.tenancy_ocid
      description    = "Groupe dynamique de la Landing Zone pour les foncitons dans le compartiment  ${local.appdevpreprod_compartment.name} (PREPRODUCTION)."
      matching_rule  = "ALL {resource.type = 'fnfunc',resource.compartment.id = '${module.lz_compartments.compartments[local.appdevpreprod_compartment.key].id}'}"
    },
    ("dgrp-databasepreprod-kms") = {
      compartment_id = var.tenancy_ocid
      description    = "Groupe dynamique de la Landing Zone pour les bases de données dans le compartiment ${local.databasepreprod_compartment.name}."
      matching_rule  = "ALL {resource.compartment.id = '${module.lz_compartments.compartments[local.databasepreprod_compartment.key].id}'}"
    }
    #Fin edit Remy
  } : {}
}

