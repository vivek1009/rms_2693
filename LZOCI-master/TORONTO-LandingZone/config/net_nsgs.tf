# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration creates Landing Zone NSGs (Network Security Groups)

locals {
  bastions_nsgs = { for k, v in module.lz_vcn_spokes.vcns : "nsg-${k}-bastion" => {
    vcn_id : v.id,
    ingress_rules : merge({
      ssh-dmz-ingress-rule : {
        is_create : length(var.dmz_vcn_cidr) > 0,
        description : "Permet les connections SSH à partir des hôtes du VCN DMZ (${var.dmz_vcn_cidr}).",
        stateless : false,
        protocol : "6",
        src : length(var.dmz_vcn_cidr) > 0 ? module.lz_vcn_dmz.vcns[local.dmz_vcn_name.name].cidr_block : null,
        src_type : "CIDR_BLOCK",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }
      }, { for cidr in var.onprem_src_ssh_cidrs : "ssh-onprem-ingress-rule-${index(var.onprem_src_ssh_cidrs, cidr)}" => {
        is_create : (length(var.dmz_vcn_cidr) == 0 && length(var.onprem_src_ssh_cidrs) > 0),
        description : "Permet les connections SSH à partir des infrastructures on-premise (${cidr}).",
        stateless : false,
        protocol : "6",
        src : cidr,
        src_type : "CIDR_BLOCK",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }
      },
      { for cidr in var.public_src_bastion_cidrs : "ssh-public-ingress-rule-${index(var.public_src_bastion_cidrs, cidr)}" => {
        is_create : length(var.onprem_cidrs) == 0 && length(var.dmz_vcn_cidr) == 0 && !var.no_internet_access && length(var.public_src_bastion_cidrs) > 0,
        description : "Permet les connections SSH à partir des hôtes dans la plage ${cidr}.",
        protocol : "6",
        stateless : false,
        src : cidr,
        src_type : "CIDR_BLOCK",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
        }

    }),
    egress_rules : {
      app-egress_rule : {
        is_create : length(var.dmz_vcn_cidr) == 0,
        description : "Permet les connections SSH vers les hôtes dans le NSG nsg-${k}-app.",
        stateless : false,
        protocol : "6",
        dst      = "nsg-${k}-app",
        dst_type = "NSG_NAME",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      db-egress_rule : {
        is_create : length(var.dmz_vcn_cidr) == 0,
        description : "Permet les connections SSH vers les hôtes dans le NSG nsg-${k}-db.",
        stateless : false,
        protocol : "6",
        dst      = "nsg-${k}-db",
        dst_type = "NSG_NAME",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      lbr-egress_rule : {
        is_create : length(var.dmz_vcn_cidr) == 0,
        description : "Permet les connections SSH vers les hôtes dans le NSG nsg-${k}-lbr.",
        stateless : false,
        protocol : "6",
        dst      = "nsg-${k}-lbr",
        dst_type = "NSG_NAME",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      osn-services-egress-rule : {
        is_create : length(var.dmz_vcn_cidr) == 0,
        description : "Permet les connections HTTPS vers la plage ${local.valid_service_gateway_cidrs[0]}.",
        stateless : false,
        protocol : "6",
        dst      = local.valid_service_gateway_cidrs[0],
        dst_type = "SERVICE_CIDR_BLOCK",
        dst_port_min : 443,
        dst_port_max : 443,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }
    }
  } }

  lbr_nsgs = { for k, v in module.lz_vcn_spokes.vcns : "nsg-${k}-lbr" => {
    vcn_id : v.id,
    ingress_rules : merge({
      ssh-ingress-rule : {
        is_create : length(var.dmz_vcn_cidr) == 0,
        description : "Permet les connections SSH à partir des hôtes dans le NSG nsg-${k}-bastion.",
        stateless : false,
        protocol : "6",
        src : "nsg-${k}-bastion",
        src_type : "NSG_NAME",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      dmz-services-ingress-rule : {
        is_create : length(var.dmz_vcn_cidr) > 0,
        description : "Permet les connections HTTPS à partir des hôtes du VCN  (${var.dmz_vcn_cidr}).",
        stateless : false,
        protocol : "6",
        src : length(var.dmz_vcn_cidr) > 0 ? module.lz_vcn_dmz.vcns[local.dmz_vcn_name.name].cidr_block : null,
        src_type : "CIDR_BLOCK",
        dst_port_min : 443,
        dst_port_max : 443,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }
      }, { for cidr in var.onprem_cidrs : "http-onprem-ingress-rule-${index(var.onprem_cidrs, cidr)}" => {
        is_create : length(var.dmz_vcn_cidr) == 0 && length(var.onprem_cidrs) > 0,
        description : "Permet les connections HTTPS à partir des infrastructures on-premises (${cidr}).",
        stateless : false,
        protocol : "6",
        src : cidr,
        src_type : "CIDR_BLOCK",
        dst_port_min : 443,
        dst_port_max : 443,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }
      },
      { for cidr in var.public_src_lbr_cidrs : "http-public-ingress-rule-${index(var.public_src_lbr_cidrs, cidr)}" => {
        is_create : !var.no_internet_access && length(var.dmz_vcn_cidr) == 0 && length(var.public_src_lbr_cidrs) > 0,
        description : "Permet les connections HTTPS à partir des hôtes dans la plage ${cidr}.",
        stateless : false,
        protocol : "6",
        src : cidr,
        src_type : "CIDR_BLOCK",
        dst_port_min : 443,
        dst_port_max : 443,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
        }

    }),
    egress_rules : {
      app-egress_rule : {
        is_create : true,
        description : "Permet les connections HTTP vers les hôtes du NSG nsg-${k}-app.",
        stateless : false,
        protocol : "6",
        dst      = "nsg-${k}-app",
        dst_type = "NSG_NAME",
        dst_port_min : 80,
        dst_port_max : 80,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      osn-services-egress-rule : {
        is_create : true,
        description : "Permet les connections HTTPS vers la plage ${local.valid_service_gateway_cidrs[0]}.",
        stateless : false,
        protocol : "6",
        dst      = local.valid_service_gateway_cidrs[0],
        dst_type = "SERVICE_CIDR_BLOCK",
        dst_port_min : 443,
        dst_port_max : 443,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }
    }
  } }

  app_nsgs = { for k, v in module.lz_vcn_spokes.vcns : "nsg-${k}-app" => {
    vcn_id : v.id,
    ingress_rules : {
      ssh-ingress-rule : {
        is_create : length(var.dmz_vcn_cidr) == 0,
        description : "Permet les connections SSH à partir des hôtes dans le NSG nsg-${k}-bastion.",
        stateless : false,
        protocol : "6",
        src : "nsg-${k}-bastion",
        src_type : "NSG_NAME",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      http-ingress-rule : {
        is_create : true,
        description : "Permet les connections HTTP vers les hôtes dans le NSG nsg-${k}-lbr.",
        stateless : false,
        protocol : "6",
        src : "nsg-${k}-lbr",
        src_type : "NSG_NAME",
        dst_port_min : 80,
        dst_port_max : 80,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      }
    },
    egress_rules : merge({
      db-egress-rule : {
        is_create : true,
        description : "Permet les connections SQLNet vers les hôtes dans le NSG nsg-${k}-db.",
        stateless : false,
        protocol : "6",
        dst      = "nsg-${k}-db",
        dst_type = "NSG_NAME",
        src_port_min : null,
        src_port_max : null,
        dst_port_min : 1521,
        dst_port_max : 1522,
        icmp_code : null,
        icmp_type : null
      },
      osn-services-egress-rule : {
        is_create : true,
        description : "Permet les connections HTTPS vers la plage ${local.valid_service_gateway_cidrs[0]}.",
        stateless : false,
        protocol : "6",
        dst      = local.valid_service_gateway_cidrs[0],
        dst_type = "SERVICE_CIDR_BLOCK",
        src_port_min : null,
        src_port_max : null,
        dst_port_min : 443,
        dst_port_max : 443,
        icmp_code : null,
        icmp_type : null
      }},
      { for c in var.exacs_vcn_cidrs : "sqlnet-exacs-egress-rule-${index(var.exacs_vcn_cidrs,c)}" => {
        is_create : var.hub_spoke_architecture == true,
        description : "Permet les connections SQLNet vers le service Exadata Database dans la plage ${c} .",
        stateless : false,
        protocol : "6",
        dst      = c,
        dst_type = "CIDR_BLOCK",
        src_port_min : null,
        src_port_max : null,
        dst_port_min : 1521,
        dst_port_max : 1522,
        icmp_code : null,
        icmp_type : null
      }},
      { for c in var.exacs_vcn_cidrs : "ons-exacs-egress-rule-${index(var.exacs_vcn_cidrs,c)}" => {
        is_create : var.hub_spoke_architecture == true,
        description : "Permet les comunications de Oracle Notification Services (ONS) vers les hôtes dans la plage ${c} pour les Fast Application Notifications (FAN).",
        stateless : false,
        protocol : "6",
        dst      = c,
        dst_type = "CIDR_BLOCK",
        src_port_min : null,
        src_port_max : null,
        dst_port_min : 6200,
        dst_port_max : 6200,
        icmp_code : null,
        icmp_type : null
      }})
    } 
  }

  db_nsgs = { for k, v in module.lz_vcn_spokes.vcns : "nsg-${k}-db" => {
    vcn_id = v.id
    ingress_rules : {
      ssh-ingress-rule : {
        is_create : length(var.dmz_vcn_cidr) == 0,
        description : "Permet les connections SSH à partir des hôtes dans le NSG nsg-${k}-bastion.",
        stateless : false,
        protocol : "6",
        src : "nsk-${k}-bastion",
        src_type : "NSG_NAME",
        dst_port_min : 22,
        dst_port_max : 22,
        src_port_min : null,
        src_port_max : null,
        icmp_type : null,
        icmp_code : null
      },
      app-ingress-rule : {
        is_create : true,
        description : "Permet les connections SQLNet à partir des hôtes dans le NSG nsg-${k}-app.",
        stateless : false,
        protocol : "6",
        src : "nsg-${k}-app",
        src_type : "NSG_NAME",
        src_port_min : null,
        src_port_max : null,
        dst_port_min : 1521,
        dst_port_max : 1522,
        icmp_code : null,
        icmp_type : null
      }
    },
    egress_rules : {
      osn-services-egress-rule : {
        is_create : true,
        description : "Permet les connections HTTPS vers la plage ${local.valid_service_gateway_cidrs[0]}.",
        stateless : false,
        protocol : "6",
        dst      = local.valid_service_gateway_cidrs[0],
        dst_type = "SERVICE_CIDR_BLOCK",
        src_port_min : null,
        src_port_max : null,
        dst_port_min : 443,
        dst_port_max : 443,
        icmp_code : null,
        icmp_type : null
      }
    }
  } }

  public_dst_nsgs = length(var.public_dst_cidrs) > 0 && !var.no_internet_access && length(var.dmz_vcn_cidr) == 0 ? { for k, v in module.lz_vcn_spokes.vcns : "nsg-${k}-public-dst" => {
    vcn_id = v.id
    ingress_rules : {},
    egress_rules : merge({ for cidr in var.public_dst_cidrs : "https-public-dst-egress-rule-${index(var.public_dst_cidrs, cidr)}" => {
      is_create : var.public_dst_cidrs != null && !var.no_internet_access && length(var.dmz_vcn_cidr) == 0,
      description : "Permet les connections HTTPS vers la plage ${cidr}.",
      stateless : false,
      protocol : "6",
      dst      = cidr,
      dst_type = "CIDR_BLOCK",
      src_port_min : null,
      src_port_max : null,
      dst_port_min : 443,
      dst_port_max : 443,
      icmp_code : null,
      icmp_type : null
    } }, {})

    }
  } : {}
}

module "lz_nsgs_spokes" {
  depends_on     = [module.lz_vcn_spokes]
  source         = "../modules/network/security"
  compartment_id = module.lz_compartments.compartments[local.network_compartment.key].id
  nsgs           = merge(local.bastions_nsgs, local.lbr_nsgs, local.app_nsgs, local.db_nsgs, local.public_dst_nsgs)
}
