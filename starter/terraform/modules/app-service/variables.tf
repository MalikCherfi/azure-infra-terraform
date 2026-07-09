variable "owner" {
  type    = string
  default = "malik"
}
variable "resource_group_name" {
  type    = string
  default = "rg-malik-cherfi"
}
variable "location" {
  type    = string
  default = "francecentral"
}
variable "tags" {
  type = map(string)
  default = {
    "managed_by"  = "cli"
    "environment" = "tp"
    "owner"       = "malik-cherfi"
  }
}
variable "service_plan_id" {
  type    = string
  default = "5e683e0f-b00c-48d6-9769-5aaf598de8f1"
}

