variable "owner" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }
variable "managed_identity_name" {
  type    = string
  default = "github-oidc-identity"
}
variable "fic_main_name" {
  type    = string
  default = "github-federated-identity-main"
}
variable "fic_feat_name" {
  type    = string
  default = "github-federated-identity-feat-terraform-config"
}

variable "fic_pr_name" {
  type    = string
  default = "github-federated-identity-pr"
}
variable "role_definition_name" {
  type    = string
  default = "creator-role"
}