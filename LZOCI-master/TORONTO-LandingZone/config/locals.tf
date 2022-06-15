# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {

  ### Discovering the home region name and region key.
  regions_map         = { for r in data.oci_identity_regions.these.regions : r.key => r.name } # All regions indexed by region key.
  regions_map_reverse = { for r in data.oci_identity_regions.these.regions : r.name => r.key } # All regions indexed by region name.
  home_region_key     = data.oci_identity_tenancy.this.home_region_key                         # Home region key obtained from the tenancy data source
  region_key          = lower(local.regions_map_reverse[var.region])                           # Region key obtained from the region name

  ### IAM
  # Default compartment names
  default_enclosing_compartment = {key:"cmp-top",               name:"cmp-top"}
  security_compartment          = {key:"cmp-securite",          name:"cmp-securite"}
  network_compartment           = {key:"cmp-reseau",            name:"cmp-reseau"}
  database_compartment          = {key:"cmp-database-prod",     name:"cmp-database-prod"}
  appdev_compartment            = {key:"cmp-appdev-prod",       name:"cmp-appdev-prod"}
  #Edit remy - compartiments prod/preprod (Laisser les keys de prod vanille pour éviter les bugs)
  databasepreprod_compartment   = {key:"cmp-database-preprod",  name:"cmp-database-preprod"}
  appdevpreprod_compartment     = {key:"cmp-appdev-preprod",    name:"cmp-appdev-preprod"}
  #End edit- Remy
    
  exainfra_compartment          = {key:"cmp-exainfra",     name:"cmp-exainfra"}
  
  # Whether compartments should be deleted upon resource destruction.
  enable_cmp_delete = false

  # Whether or not to create an enclosing compartment
  parent_compartment_id         = var.use_enclosing_compartment == true ? (var.existing_enclosing_compartment_ocid != null ? var.existing_enclosing_compartment_ocid : module.lz_top_compartment[0].compartments[local.default_enclosing_compartment.key].id) : var.tenancy_ocid
  parent_compartment_name       = var.use_enclosing_compartment == true ? (var.existing_enclosing_compartment_ocid != null ? data.oci_identity_compartment.existing_enclosing_compartment.name : local.default_enclosing_compartment.name) : "tenancy"
  policy_scope                  = local.parent_compartment_name == "tenancy" ? "tenancy" : "compartment ${local.parent_compartment_name}"
  use_existing_tenancy_policies = var.policies_in_root_compartment == "CREATE" ? false : true

  # Group names
  security_admin_group_name      = var.use_existing_groups == false ? "GOCI_Role_Security_Admin" : data.oci_identity_groups.existing_security_admin_group.groups[0].name
  network_admin_group_name       = var.use_existing_groups == false ? "GOCI_Role_Network_Admin" : data.oci_identity_groups.existing_network_admin_group.groups[0].name
  database_admin_group_name      = var.use_existing_groups == false ? "GOCI_Role_DB_Prod_Admin" : data.oci_identity_groups.existing_database_admin_group.groups[0].name
  appdev_admin_group_name        = var.use_existing_groups == false ? "GOCI_Role_App_DevProd_Admin" : data.oci_identity_groups.existing_appdev_admin_group.groups[0].name
  iam_admin_group_name           = var.use_existing_groups == false ? "GOCI_Role_IAM_Admin" : data.oci_identity_groups.existing_iam_admin_group.groups[0].name
  cred_admin_group_name          = var.use_existing_groups == false ? "GOCI_Role_Cred_Admin" : data.oci_identity_groups.existing_cred_admin_group.groups[0].name
  auditor_group_name             = var.use_existing_groups == false ? "GOCI_Role_Auditor" : data.oci_identity_groups.existing_auditor_group.groups[0].name
  announcement_reader_group_name = var.use_existing_groups == false ? "GOCI_Role_Announcement_Reader" : data.oci_identity_groups.existing_announcement_reader_group.groups[0].name
  exainfra_admin_group_name      = var.use_existing_groups == false ? "GOCI_Exainfra_Admin" : data.oci_identity_groups.existing_exainfra_admin_group.groups[0].name
  #Ajout Remy
  databasepreprod_admin_group_name      = var.use_existing_groups == false ? "GOCI_Role_DB_Preprod_Admin" : "grp-databasepreprod-admin"
  appdevpreprod_admin_group_name        = var.use_existing_groups == false ? "GOCI_Role_App_DevPreprod_Admin" : "grp-appdevpreprod-admin"
  readonly_group_name              = var.use_existing_groups == false ? "GOCI_Role_Reader_Tenant" : "grp-readonly-users"
    
  # Policy names
  security_admin_policy_name      = "pol-security-admin"
  security_admin_root_policy_name = "pol-security-admin-root"
  network_admin_policy_name       = "pol-network-admin"
  network_admin_root_policy_name  = "pol-network-admin-root"
  database_admin_policy_name      = "pol-databaseprod-admin"
  database_dynamic_group_policy_name = "$pol-databaseprod-dynamic_group"
  database_admin_root_policy_name = "pol-databaseprod-admin-root"
  appdev_admin_policy_name        = "pol-appdevprod-admin"
  appdev_admin_root_policy_name   = "pol-appdevprod-admin-root"
  iam_admin_policy_name           = "pol-iam-admin"
  iam_admin_root_policy_name      = "pol-iam-admin-root"
  cred_admin_policy_name          = "pol-credential-admin"
  auditor_policy_name             = "pol-auditor"
  announcement_reader_policy_name = "pol-announcement-reader"
  exainfra_admin_policy_name      = "pol-exainfra-admin"
  #Ajout Remy
  databasepreprod_admin_policy_name      = "pol-databasepreprod-admin"
  databasepreprod_admin_root_policy_name = "pol-databasepreprod-admin-root"
  databasepreprod_dynamic_group_policy_name = "pol-databasepreprod-dynamic_group"
  appdevpreprod_admin_policy_name        = "pol-appdevpreprod-admin"
  appdevpreprod_admin_root_policy_name   = "pol-appdevpreprod-admin-root"
  #Ajout Remy
  readonly_root_policy_name                   = "pol-readonly-root"
    
  services_policy_name   = "pol-services-landingzone"
  cloud_guard_statements = ["Allow service cloudguard to read keys in tenancy",
                            "Allow service cloudguard to read compartments in tenancy",
                            "Allow service cloudguard to read tenancies in tenancy",
                            "Allow service cloudguard to read audit-events in tenancy",
                            "Allow service cloudguard to read compute-management-family in tenancy",
                            "Allow service cloudguard to read instance-family in tenancy",
                            "Allow service cloudguard to read virtual-network-family in tenancy",
                            "Allow service cloudguard to read volume-family in tenancy",
                            "Allow service cloudguard to read database-family in tenancy",
                            "Allow service cloudguard to read object-family in tenancy",
                            "Allow service cloudguard to read load-balancers in tenancy",
                            "Allow service cloudguard to read users in tenancy",
                            "Allow service cloudguard to read groups in tenancy",
                            "Allow service cloudguard to read policies in tenancy",
                            "Allow service cloudguard to read dynamic-groups in tenancy",
                            "Allow service cloudguard to read authentication-policies in tenancy",
                            "Allow service cloudguard to use network-security-groups in tenancy"]
  vss_statements       = ["Allow service vulnerability-scanning-service to manage instances in tenancy",
                          "Allow service vulnerability-scanning-service to read compartments in tenancy",
                          "Allow service vulnerability-scanning-service to read vnics in tenancy",
                          "Allow service vulnerability-scanning-service to read vnic-attachments in tenancy"]
  os_mgmt_statements     = ["Allow service osms to read instances in tenancy"]

  #Intentionellement omis la preprod ; la gestion des clés doit rester en mode PROD par les admins PROD.
  database_kms_statements = ["Allow dynamic-group dgrp-database-kms-dynamic to manage vaults in compartment ${local.security_compartment.name}",
        "Allow dynamic-group dgrp-database-kms-dynamic to manage vaults in compartment ${local.security_compartment.name}"]


  # Tags
  tag_namespace_name = "tags-${var.service_label}-LandingZone"
#  createdby_tag_name = "CreatedBy"
#  createdon_tag_name = "CreatedOn"
  createdby_tag_name = "CreePar"
  createdon_tag_name = "CreeDate"
  serveur_tag_name = "Serveur"
  palier_tag_name = "Palier"
  sensibilite_tag_name = "Sensibilite"
  criticite_tag_name = "Criticite"
  responsableti_tag_name = "ResponsableTI"
  responsableaffaires_tag_name = "ResponsableAffaires"
  systeme_tag_name = "Systeme"
  centrebudgetaire_tag_name = "CentreBudgetaire"
  datefin_tag_name = "DateFin"
  secteur_tag_name = "Secteur"
  plagedispo_tag_name = "PlageDisponibilite"
  plagemaintenance_tag_name = "PlageMaintenance"
  prioritereleve_tag_name = "PrioriteReleve"
  typereleve_tag_name = "TypeReleve"
  gestionautomatique_tag_name = "GestionAutomatique"
  notesimportantes_tag_name = "NotesImportantes"
  #Fin Remy

  ### Network
  anywhere                    = "0.0.0.0/0"
  valid_service_gateway_cidrs = ["all-${local.region_key}-services-in-oracle-services-network", "oci-${local.region_key}-objectstorage"]

  # Subnet names
  # Subnet Names used can be changed first subnet will be Public if var.no_internet_access is false
  # Edit - Remy - Ajouts du subnets supplémentaires (Note : Les DEUX (2) premiers subnets de la liste sont PUBLIQUES ; le reste sont PRIVÉS)
  #spoke_subnet_names = ["web", "app", "db"]
  spoke_subnet_names = ["web", "app", "db", "gestion"]
    
  # Subnet Names used can be changed first subnet will be Public if var.no_internet_access is false
  dmz_subnet_names = ["outdoor", "indoor", "mgmt", "ha", "diag"]
  # Mgmg subnet is public by default.
  is_mgmt_subnet_public = true

  dmz_vcn_name = var.dmz_vcn_cidr != null ? {
    name = "vcn-oct-dmz"
    cidr = var.dmz_vcn_cidr
  } : {}

  ### Object Storage
  oss_key_name = "key-oct-landingzone-oss-key"
  bucket_name  = "stbckt-oct-landingzone-bucket"
  vault_name   = "kvl-oct-landingzone"
  vault_type   = "DEFAULT"

  ### Service Connector Hub
  sch_audit_display_name        = "sch-oct-landingzone-audit"
  sch_audit_bucket_name         = "stbkct-oct-sch-audit"
  sch_audit_target_rollover_MBs = 100
  sch_audit_target_rollover_MSs = 420000

  sch_vcnFlowLogs_display_name        = "log-sch-vcn-flow-logs"
  sch_vcnFlowLogs_bucket_name         = "stbckt-oct-sch-vcn-flow-logs"
  sch_vcnFlowLogs_target_rollover_MBs = 100
  sch_vcnFlowLogs_target_rollover_MSs = 420000

  sch_audit_policy_name       = "pol-landingzone-audit-sch"
  sch_vcnFlowLogs_policy_name = "pol-landingzone-vcn-flow-logs-sch"

  cg_target_name = "cgtgt-cloud-guard-root-target"

  ### Scanning
  scan_default_recipe_name = "cgrcp-landingzone-default-scan-recipe"
  security_cmp_target_name = "cgtgt-${local.security_compartment.key}-scan-target"
  network_cmp_target_name  = "cgtgt-${local.network_compartment.key}-scan-target"
  appdev_cmp_target_name   = "cgtgt-${local.appdev_compartment.key}-scan-target"
  database_cmp_target_name = "cgtgt-${local.database_compartment.key}-scan-target"
  #Edit remy ; ajout scan CMPs preprod
  appdevpreprod_cmp_target_name   = "cgtgt-${local.appdevpreprod_compartment.key}-scan-target"
  databasepreprod_cmp_target_name = "cgtgt-${local.databasepreprod_compartment.key}-scan-target"
  #End edit Remy

  # Delay in seconds for slowing down resource creation
  delay_in_secs = 60

  # Outputs display
  display_outputs = true

  bastion_name = "bst-zoneaccueil-001"
  bastion_max_session_ttl_in_seconds = 3 * 60 * 60 // 3 hrs.
}
