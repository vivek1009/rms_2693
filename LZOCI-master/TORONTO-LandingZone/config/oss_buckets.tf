# Copyright (c) 2021 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

### Creates a bucket in the specified compartment 
module "lz_buckets" {
    depends_on   = [ null_resource.slow_down_oss ]
    source       = "../modules/object-storage/bucket"
    kms_key_id   = module.lz_keys.keys[local.oss_key_name].id
    buckets      = { 
        ("stbkt-oct-prod-appdev") = {
            compartment_id = module.lz_compartments.compartments[local.appdev_compartment.key].id
            name = "stbkt-oct-prod-appdev"
            namespace = data.oci_objectstorage_namespace.this.namespace
        },
        ("stbkt-oct-preprodprod-appdev") = {
            compartment_id = module.lz_compartments.compartments[local.appdevpreprod_compartment.key].id
            name = "stbkt-oct-preprod-appdev"
            namespace = data.oci_objectstorage_namespace.this.namespace
        }
    }
}

resource "null_resource" "slow_down_oss" {
   depends_on = [ module.lz_keys_policies ]
   provisioner "local-exec" {
     command = "sleep ${local.delay_in_secs}" # Wait for policies to be available.
   }
}

