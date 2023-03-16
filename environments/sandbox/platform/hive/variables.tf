variable "azure_region" {
  type = string
}
variable "env" {
  type = string
}
variable "customer" {
  type    = string
  default = "CE"
}
variable "resource_group_name" {
  type = string
}

variable "thrift_port" {
  type    = string
  default = "9083"
}