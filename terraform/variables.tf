# Azure Tenancy:

variable "subscriptionid" {
  type    = string
  default = "97f3768f-9c10-476a-973b-fcadf178d70a"
}

# Locations:

variable "location" {
  type        = string
  default     = "australiaeast"
  description = "Location to deploy environment to."
}

# Deployment Details:
variable "rgname" {
  type        = string
  default     = "sjr-fermium-rg"
  description = "RG name to deploy to."
}

variable "vmbasename" {
  type        = string
  default     = "prod-ferm-vm"
  description = "VM base name."
}

variable "vmcount" {
  default     = 1
  description = "Amount of VMs to deploy."
}

variable "username" {
  type    = string
  default = "azureuser"
}

variable "password" {
  type    = string
  default = "IC1labP@ssw0rd"
}
