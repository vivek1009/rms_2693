# ------ Get Network Compartment Name for Policies
data "oci_identity_compartment" "network_compartment" {
  id = var.network_compartment_ocid
}


# ------ Get list of availability domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# ------ Get the latest Oracle Linux image
data "oci_core_images" "InstanceImageOCID" {
  compartment_id = var.compute_compartment_ocid
  # operating_system         = var.instance_os
  # operating_system_version = var.linux_os_version

  shape = var.spoke_vm_compute_shape

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

# ------ Get the Oracle Tenancy ID
data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}


# ------ Get Your Home Region
data "oci_identity_regions" "home-region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenancy.home_region_key]
  }
}

# ------ Get the Tenancy ID and AD Number
data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.availability_domain_number
}

# ------ Get the Tenancy ID and ADs
data "oci_identity_availability_domains" "ads" {
  #Required
  compartment_id = var.tenancy_ocid
}

# ------ Get the Faulte Domain within AD 
data "oci_identity_fault_domains" "fds" {
  availability_domain = "${data.oci_identity_availability_domain.ad.name}"
  compartment_id      = var.compute_compartment_ocid

  depends_on = [
    data.oci_identity_availability_domain.ad,
  ]
}

# ------ Get the Allow All Security Lists for Subnets in Firewall VCN
data "oci_core_security_lists" "allow_all_security" {
  compartment_id = var.compute_compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.hub.0.id
  filter {
    name   = "display_name"
    values = ["AllowAll"]
  }
  depends_on = [
    oci_core_security_list.allow_all_security,
  ]
}

# ------ Get the Allow All Security Lists for Subnets in Firewall VCN
data "oci_core_security_lists" "allow_all_security_web" {
  compartment_id = var.compute_compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.web.0.id
  filter {
    name   = "display_name"
    values = ["AllowAll"]
  }
  depends_on = [
    oci_core_security_list.allow_all_security_web,
  ]
}

# ------ Get the Allow All Security Lists for Subnets in Firewall VCN
data "oci_core_security_lists" "allow_all_security_db" {
  compartment_id = var.compute_compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.db.0.id
  filter {
    name   = "display_name"
    values = ["AllowAll"]
  }
  depends_on = [
    oci_core_security_list.allow_all_security_db,
  ]
}

# ------ Get the attachement based on Public Subnet
data "oci_core_vnic_attachments" "untrust_attachments" {
  compartment_id = var.network_compartment_ocid
  instance_id    = oci_core_instance.vm-a.0.id

  filter {
    name   = "subnet_id"
    values = [local.use_existing_network ? var.untrust_subnet_id : oci_core_subnet.untrust_subnet[0].id]
  }

  depends_on = [
    oci_core_vnic_attachment.vnic_attach_untrust_a,
  ]
}

# ------ Get the attachement based on Private Subnet
data "oci_core_vnic_attachments" "trust_attachments" {
  compartment_id = var.network_compartment_ocid
  instance_id    = oci_core_instance.vm-a.0.id

  filter {
    name   = "subnet_id"
    values = [local.use_existing_network ? var.trust_subnet_id : oci_core_subnet.trust_subnet[0].id]
  }

  depends_on = [
    oci_core_vnic_attachment.vnic_attach_trust_a,
  ]
}