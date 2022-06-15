# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### This Terraform configuration creates a custom tag namespace and tags in the specified tag_namespace_compartment_id 
### and tag defaults in the specified tag_defaults_compartment_id. 
### But only if there are no tag defaults for the oracle default namespace in the tag_defaults_compartment_id (checked by module).

module "lz_tags" {
  source                       = "../modules/monitoring/tags"
  providers                    = { oci = oci.home }
  tenancy_ocid                 = var.tenancy_ocid
  tag_namespace_compartment_id = local.parent_compartment_id
  tag_namespace_name           = local.tag_namespace_name
  tag_namespace_description    = "Tag Namespace de la Landing Zone ${var.service_label}"
  tag_defaults_compartment_id  = local.parent_compartment_id

  tags = { # the map keys are meant to be the tag names.
#    (local.createdby_tag_name) = {
#      tag_description         = "Tag prédéfini de la Landing Zone qui identtifie le créateur d'une ressource. (Automatique)"
#      tag_is_cost_tracking    = true
#      tag_is_retired          = false
#      make_tag_default        = true
#      tag_default_value       = "$${iam.principal.name}"
#      tag_default_is_required = false
#    },
#    (local.createdon_tag_name) = {
#      tag_description         = "Tag prédéfini de la Landing Zone qui identifie la date ou la ressource a été créée. (Automatique)"
#      tag_is_cost_tracking    = false
#      tag_is_retired          = false
#      make_tag_default        = true
#      tag_default_value       = "$${oci.datetime}"
#      tag_default_is_required = false
#    },  (local.serveur_tag_name) = {
#      tag_description         = "Tag identifiant le serveur auquel la ressource est affiliée."
#      tag_is_cost_tracking    = false
#      tag_is_retired          = false
#      make_tag_default        = false
#      tag_default_value       = ""
#      tag_default_is_required = false
#    },  (local.sensibilite_tag_name) = {
#     tag_description         = "Tag indiquant le niveau de sensibilité des données traitées/stockées par le composant."
#      tag_is_cost_tracking    = false
#      tag_is_retired          = false
#      make_tag_default        = false
#      tag_default_value       = ""
#      tag_default_is_required = false
#      validator {
#        validator_type = "ENUM"
#        values = [
#          "Publique",
#          "Interne",
#          "Confidentielle",
#          "Haute confidentialité",
#          "Non applicable",
#       ]
#     }
#    },  (local.criticite_tag_name) = {
#      tag_description         = "Tag indiquant la criticité de la ressource."
#      tag_is_cost_tracking    = false
#      tag_is_retired          = false
#      make_tag_default        = false
#      tag_default_value       = ""
#      tag_default_is_required = false
#      #validator {
      #  validator_type = "ENUM"
      #  values = [
      #    "Faible",
      #    "Moyenne",
      #    "Haute (Sectoriel)",
      #    "Haute (Ministère)",
      #    "Haute (Cabinet ministériel)",
      #  ]
      #}
#    },  (local.responsableti_tag_name) = {
#      tag_description         = "Tag indiquand le responsable TI de la ressource."
#      tag_is_cost_tracking    = false
#      tag_is_retired          = false
#      make_tag_default        = false
#      tag_default_value       = ""
#      tag_default_is_required = false
#    },  (local.responsableaffaires_tag_name) = {
#      tag_description         = "Tag indiquand le responsable au niveau affaires de la resource."
#      tag_is_cost_tracking    = false
#      tag_is_retired          = false
#      make_tag_default        = false
#      tag_default_value       = ""
#      tag_default_is_required = false
#    },  (local.palier_tag_name) = {
#      tag_description         = "Tag indiquant le palier de la ressource (PROD,UNIT,FONC,ACCP,FORM)"
#      tag_is_cost_tracking    = false
#      tag_is_retired          = false
#      make_tag_default        = false
#      tag_default_value       = ""
#      tag_default_is_required = false
      #validator {
      #  validator_type = "ENUM"
      #  values = [
      #    "Laboratoire",
      #    "Unitaire",
      #    "Acceptation",
      #    "Formation",
      #    "Production",
      #    "Paliers multiples",
      #    "Infrastructure/Gestion",
      #    "Aucun",
      #  ]
      #}
 #   },  (local.systeme_tag_name) = {
 #     tag_description         = "Tag indiquant le système global dont la ressource fait partie."
 #     tag_is_cost_tracking    = false
 #     tag_is_retired          = false
 #     make_tag_default        = false
 #     tag_default_value       = ""
 #     tag_default_is_required = false
 #   },  (local.centrebudgetaire_tag_name) = {
 #     tag_description         = "Tag indiquant le centre budgétaire associé à la ressource (numéro d'UA)."
 #     tag_is_cost_tracking    = false
 #     tag_is_retired          = false
 #     make_tag_default        = false
 #     tag_default_value       = ""
 #     tag_default_is_required = false
 #   },  (local.datefin_tag_name) = {
 #     tag_description         = "Tag indiquant la date prévue de décomission de la ressource."
 #     tag_is_cost_tracking    = false
 #     tag_is_retired          = false
 #     make_tag_default        = false
 #     tag_default_value       = ""
 #     tag_default_is_required = false
 #   },  (local.secteur_tag_name) = {
 #     tag_description         = "Tag indiquant la direction générale étant cliente principale du service offert par la ressource."
 #     tag_is_cost_tracking    = false
 #     tag_is_retired          = false
 #     make_tag_default        = false
 #     tag_default_value       = ""
 #     tag_default_is_required = false
      #validator {
      #  validator_type = "ENUM"
      #  values = [
      #    "Ministère",
      #    "Administration",
      #    "Communications",
      #    "Ressources financières",
      #    "Ressources humaines",
      #    "Ressources informationnelles",
      #    "Ressources matérielles",
      #    "Gestion Documentaire",
      #    "Cabinet Ministériel",
      #  ]
      #}
#    },  (local.plagedispo_tag_name) = {
#      tag_description         = "Tag indiquant la plage de disponibilité de la ressource."
#      tag_is_cost_tracking    = false
#      tag_is_retired          = false
#      make_tag_default        = false
#      tag_default_value       = ""
#      tag_default_is_required = false
#      #validator {
      #  validator_type = "ENUM"
      #  values = [
      #    "Jour (7h-16h)",
      #    "Jour + Soir (7h-00h)",
      #    "24h sur 24 (Lundi-Venredi))",
      #    "24h sur 24",
      #    "Spéciale",
      #  ]
      #}
#    },  (local.plagemaintenance_tag_name) = {
#      tag_description         = "Tag indiquand la plage de maintenance de la ressource."
#      tag_is_cost_tracking    = false
#      tag_is_retired          = false
#      make_tag_default        = false
#      tag_default_value       = ""
#      tag_default_is_required = false
#      #validator {
      #  validator_type = "ENUM"
      #  values = [
      #    "Jour (7h-16h)",
      #    "Soir (16h-00h)",
      #    "Nuit (00h-7h)",
      #    "Soir + Nuit (16h-7h)",
      #    "Fin de semaine",
      #    "Spéciale",
      #  ]
      #}
#    },  (local.prioritereleve_tag_name) = {
#      tag_description         = "Tag indiquant la prioritée de relève de la ressource (1-5)."
#      tag_is_cost_tracking    = false
#      tag_is_retired          = false
#      make_tag_default        = false
#      tag_default_value       = ""
#      tag_default_is_required = false
      #validator {
      #  validator_type = "ENUM"
      #  values = [
      #    "1-Prioritaire",
      #    "2-Urgente",
      #    "3-Normale",
      #    "4-Faible",
      #    "5-Aucune",
      #  ]
      #}
#    },  (local.typereleve_tag_name) = {
#      tag_description         = "Tag indiquand la méthode privilégiée de relève de la ressource."
#      tag_is_cost_tracking    = false
#      tag_is_retired          = false
#      make_tag_default        = false
#      tag_default_value       = ""
#      tag_default_is_required = false
      #validator {
      #  validator_type = "ENUM"
      #  values = [
      #    "Redondance active (basculement automatique)",
      #    "Redondance passive (basculement manuel)",
      #    "Restauration de backup",
      #    "Remontage à neuf",
      #    "Aucune",
      #  ]
      #}
#    },  (local.gestionautomatique_tag_name) = {
#      tag_description         = "Tag indiquand si la ressource est affectée par un groupe de gestion automatique d'ouverture/fermeture planifiée."
#      tag_is_cost_tracking    = false
#      tag_is_retired          = false
#      make_tag_default        = false
#      tag_default_value       = ""
#      tag_default_is_required = false
#    },  (local.notesimportantes_tag_name) = {
#      tag_description         = "Tag textuel indiquant les informations critique concernant la ressource."
#      tag_is_cost_tracking    = false
#      tag_is_retired          = false
#      make_tag_default        = false
#      tag_default_value       = ""
#      tag_default_is_required = false
#    }
  }
} 
