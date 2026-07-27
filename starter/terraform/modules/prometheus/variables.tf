variable "owner" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }
variable "prometheus_nic_id" {
  type        = string
  description = "ID du NIC à attacher à la VM Prometheus"
}