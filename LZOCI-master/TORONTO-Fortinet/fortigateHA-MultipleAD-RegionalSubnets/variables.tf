variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}

variable "private_key_path" {}

variable "region" {
  default = "us-ashburn-1"
}

##VCN and SUBNET ADDRESSESS
variable "vcn_cidr" {
  default = "10.1.0.0/16"
}

variable "mgmt_subnet_cidr" {
  default = "10.1.1.0/24"
}

variable "mgmt_subnet_gateway" {
  default = "10.1.1.1"
}


variable "untrust_subnet_cidr" {
  default = "10.1.10.0/24"
}

variable "untrust_subnet_gateway" {
  default = "10.1.10.1"
}

variable "untrust_public_ip_lifetime" {
  default = "RESERVED"
  //or EPHEMERAL
}


variable "trust_subnet_cidr" {
  default = "10.1.100.0/24"
}

variable "trust_subnet_gateway" {
  default = "10.1.100.1"
}

variable "hb_subnet_cidr" {
  default = "10.1.200.0/24"
}


#FIREWALL IPs

#FLOATING/FAILOVER
variable "untrust_floating_private_ip" {
  default = "10.1.10.10"
}

variable "trust_floating_private_ip" {
  default = "10.1.100.10"
}


#ACTIVE NODE
variable "mgmt_private_ip_primary_a" {
  default = "10.1.1.2"
}

variable "untrust_private_ip_primary_a" {
  default = "10.1.10.2"
}

variable "trust_private_ip_primary_a" {
  default = "10.1.100.2"
}

variable "hb_private_ip_primary_a" {
  default = "10.1.200.2"
}

#PASSIVE NODE
variable "mgmt_private_ip_primary_b" {
  default = "10.1.1.20"
}

variable "untrust_private_ip_primary_b" {
  default = "10.1.10.20"
}

variable "trust_private_ip_primary_b" {
  default = "10.1.100.20"
}

variable "hb_private_ip_primary_b" {
  default = "10.1.200.20"
}




variable "vm_image_ocid" {
	//Marketplace Image 6.2.5: ocid1.image.oc1..aaaaaaaar23fvwn7vie6lnwbdpqhohsiojj4oeqdmqpdvpdjm7glncxailxa
	//Marketplace Image 6.4.4: ocid1.image.oc1..aaaaaaaauxqbpkvj3uabe7efecnk75mmaui7lvzif6yckhplblm4sfirygwq
	//Or Replace OCID with custom Image OCID
	
	//Default = Marketplace Image 6.2.5
   default = "ocid1.image.oc1..aaaaaaaar23fvwn7vie6lnwbdpqhohsiojj4oeqdmqpdvpdjm7glncxailxa"
}

// variable "vm_image_ocid" {
//  type = "map"

//  default = {
    // See https://docs.us-phoenix-1.oraclecloud.com/images/
    // FortiGate-6.0.3-emulated"
	// Example:
//    us-ashburn-1="ocid1.image.oc1.iad.aaaaaaaawp3jbcejr5w7mgeuodeotmvwm36g7csiymvxd6nfesz2dj4hpq4q"
//  }
//}

variable "instance_shape" {
  default = "VM.Standard2.4"
}

# Choose an Availability Domain (1,2,3)
variable "availability_domain-a" {
  default = "1"
}

variable "availability_domain-b" {
  default = "2"
}

variable "volume_size" {
  default = "50" //GB
}

variable "bootstrap_vm-a" {
  default = "./userdata/bootstrap_vm-a.tpl"
}

variable "license_vm-a" {
  default = "./license/FGT-A-license-filename.lic"
}


variable "bootstrap_vm-b" {
 default = "./userdata/bootstrap_vm-b.tpl"
}

variable "license_vm-b" {
  default = "./license/FGT-B-license-filename.lic"
}

