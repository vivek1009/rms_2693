# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "lz_security_topic" {
  source                         = "../modules/monitoring/topics"
  depends_on                     = [ null_resource.slow_down_topics ]
  compartment_id                 = module.lz_compartments.compartments[local.security_compartment.key].id
  notification_topic_name        = "tpc-landingzone-securite"
  notification_topic_description = "Topic de notification de sécurité pour la Landing Zone."
  subscriptions = { for e in var.security_admin_email_endpoints: e => {protocol = "EMAIL", endpoint = e}
    
    ### Examples of other subscription methods:
    /* 
    {protocol = "CUSTOM_HTTPS", endpoint = "https://www.oracle.com"},
    {protocol = "CUSTOM_HTTPS", endpoint = "https://www.google.com"}
    {protocol = "PAGER_DUTY", endpoint = "https://your.pagerduty.endpoint.url"}
    {protocol = "SLACK", endpoint = "https://your.slack.endpoint.url"}
    {protocol = "ORACLE_FUNCTIONS", endpoint = "<function_ocid>"} 
    */
  }
}

module "lz_network_topic" {
  source                         = "../modules/monitoring/topics"
  depends_on                     = [ null_resource.slow_down_topics ]
  compartment_id                 = module.lz_compartments.compartments[local.security_compartment.key].id
  notification_topic_name        = "tpc-landingzone-reseau"
  notification_topic_description = "Topic de notification de réseautique de la Landing Zone."

  subscriptions = { for e in var.network_admin_email_endpoints: e => {protocol = "EMAIL", endpoint = e}

    ### Examples of other subscription methods:
    /* 
    {protocol = "CUSTOM_HTTPS", endpoint = "https://www.oracle.com"},
    {protocol = "CUSTOM_HTTPS", endpoint = "https://www.google.com"}
    {protocol = "PAGER_DUTY", endpoint = "https://your.pagerduty.endpoint.url"}
    {protocol = "SLACK", endpoint = "https://your.slack.endpoint.url"}
    {protocol = "ORACLE_FUNCTIONS", endpoint = "<function_ocid>"} 
    */
  }
}

resource "null_resource" "slow_down_topics" {
   depends_on = [ module.lz_compartments ]
   provisioner "local-exec" {
     command = "sleep ${local.delay_in_secs}" # Wait for compartments to be available.
   }
}
