# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions Landing Zone groups.

locals {
  default_groups = {
    (local.network_admin_group_name) = {
      description  = "Groupe de la Landing Zone pour l'administration réseau dans le compartiment ${local.network_compartment.name}."
      user_ids     = []
      defined_tags = null
    },
    (local.security_admin_group_name) = {
      description  = "Groupe de la Landing Zone pour l'administration des services de sécurité dans le compartiment ${local.security_compartment.name}."
      user_ids     = []
      defined_tags = null
    },
    (local.appdev_admin_group_name) = {
      description  = "Groupe de la Landing Zone pour l'administration des services de développement applicatif de PRODUCTION dans le compartiment ${local.appdev_compartment.name}."
      user_ids     = []
      defined_tags = null
    },
    (local.database_admin_group_name) = {
      description  = "Groupe de la Landing Zone pour l'administration des bases de données de PRODUCTION dans le compartiment ${local.database_compartment.name}."
      user_ids     = []
      defined_tags = null
    },
    #Edit Remy
        (local.appdevpreprod_admin_group_name) = {
      description  = "Groupe de la Landing Zone pour l'administration des services de développement applicatif de PREPRODUCTION dans le compartiment  ${local.appdevpreprod_compartment.name}."
      user_ids     = []
      defined_tags = null
    },
    (local.databasepreprod_admin_group_name) = {
      description  = "Groupe de la Landing Zone pour l'administration des bases de données de PREPRODUCTION dans le compartiment ${local.databasepreprod_compartment.name}."
      user_ids     = []
      defined_tags = null
    },
    #End edit Remy
    (local.auditor_group_name) = {
      description  = "Groupe de la Landing Zone des auditeurs du tenant."
      user_ids     = []
      defined_tags = null
    },
    (local.announcement_reader_group_name) = {
      description  = "Groupe de la Landing Zone pour l'accès aux annonces de la Landing Zone.."
      user_ids     = []
      defined_tags = null
    },
    (local.iam_admin_group_name) = {
      description  = "Groupe de la Landing Zone pour l'administration des ressources IAM du tenant."
      user_ids     = []
      defined_tags = null
    },
    (local.cred_admin_group_name) = {
      description  = "Groupe de la Landing Zone pour l'administration des comptes utilisateur du tenant (limité aux credentials)."
      user_ids     = []
      defined_tags = null
    },
    (local.readonly_group_name) = {
      description  = "Groupe de la Landing Zone donnant accès en lecture seule au tenant."
      user_ids     = []
      defined_tags = null
    },
  }
  exainfra_group = length(var.exacs_vcn_cidrs) > 0 && var.deploy_exainfra_cmp == true ? {
    (local.exainfra_admin_group_name) = {
      description  = "Groupe de la Landing Zone pour l'administration de l'infrastructure Exadata."
      user_ids     = []
      defined_tags = null
    }
  } : {}
  
  groups = merge(local.default_groups,local.exainfra_group)

}
module "lz_groups" {
  source       = "../modules/iam/iam-group"
  providers    = { oci = oci.home }
  tenancy_ocid = var.tenancy_ocid
  groups = var.use_existing_groups == false ? local.groups : {}
}
