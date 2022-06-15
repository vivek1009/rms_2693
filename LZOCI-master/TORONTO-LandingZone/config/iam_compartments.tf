# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration provisions compartments in the tenancy.

module "lz_top_compartment" {
  count     = var.use_enclosing_compartment == true && var.existing_enclosing_compartment_ocid == null ? 1 : 0
  source    = "../modules/iam/iam-compartment"
  providers = { oci = oci.home }
  compartments = {
    (local.default_enclosing_compartment.key) = {
      parent_id     = var.tenancy_ocid
      name          = local.default_enclosing_compartment.name
      description   = "Compartiment global de la Landing Zone (contenant tous els compartiments de la landing zone)."
      enable_delete = local.enable_cmp_delete
    }
  }
}

locals {
  default_cmps = {
    (local.security_compartment.key) = {
      parent_id     = local.parent_compartment_id
      name          = local.security_compartment.name
      description   = "Compartiment de la Landing Zone pour tous les objets reliés à la sécurité (vaults, topics, notifications, logging, scanning, etc.)"
      enable_delete = local.enable_cmp_delete
    },
    (local.network_compartment.key) = {
      parent_id     = local.parent_compartment_id
      name          = local.network_compartment.name
      description   = "Compartiment de la Landing Zone pour tous les objets reliés à la réseautique (VCNs, subnets, network gateways, security lists, NSGs, load balancers, VNICs, etc.)"
      enable_delete = local.enable_cmp_delete
    },
    (local.appdev_compartment.key) = {
      parent_id     = local.parent_compartment_id
      name          = local.appdev_compartment.name
      description   = "Compartiment de la Landing Zone pour tous les objets reliés au développement applicatif en PROD (compute instances, storage, functions, OKE, API Gateway, streaming, etc.)"
      enable_delete = local.enable_cmp_delete
    },
    (local.database_compartment.key) = {
      parent_id     = local.parent_compartment_id
      name          = local.database_compartment.name
      description   = "Compartiment de la Landing Zone compartment pour les bases de données de PROD."
      enable_delete = local.enable_cmp_delete
    },
    #Edit Remy - Ajout des compartiments preprod
    (local.appdevpreprod_compartment.key) = {
      parent_id     = local.parent_compartment_id
      name          = local.appdevpreprod_compartment.name
      description   = "Compartiment de la Landing Zone pour tous les objets reliés au développement applicatif en PREPROD (compute instances, storage, functions, OKE, API Gateway, streaming, etc.)"
      enable_delete = local.enable_cmp_delete
    },
    (local.databasepreprod_compartment.key) = {
      parent_id     = local.parent_compartment_id
      name          = local.databasepreprod_compartment.name
      description   = "Compartiment de la Landing Zone compartment pour les bases de données de PREPROD."
      enable_delete = local.enable_cmp_delete
    }
    #End Edit Remy
  }

  exainfra_cmp = length(var.exacs_vcn_cidrs) > 0 && var.deploy_exainfra_cmp == true ? {
    (local.exainfra_compartment.key) = {
      parent_id     = local.parent_compartment_id
      name          = local.exainfra_compartment.name
      description   = "Compartiment  de la Landing Zone pour l'infrastrucutre Exadata."
      enable_delete = local.enable_cmp_delete
    }
  } : {}

  cmps = merge(local.default_cmps, local.exainfra_cmp)

}
module "lz_compartments" {
  source    = "../modules/iam/iam-compartment"
  providers = { oci = oci.home }
  compartments = local.cmps
}
