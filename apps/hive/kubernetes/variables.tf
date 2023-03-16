variable "namespace" {
  type = string
}
variable "name" {
  type = string
}

variable "config_files" {
  type = map(string)
}
variable "binary_config_files" {
  type = map(string)
}

variable "hive_version" {
  type = string
}
variable "container_repo" {
  type    = string
  default = "someregistry.azurecr.io/hive-metastore"
}
variable "container_tag" {
  type = string
}
variable "cpu_limit" {
  type    = string
  default = "2"
}
variable "memory_limit" {
  type    = string
  default = "2Gi"
}
variable "cpu_request" {
  type    = string
  default = "1"
}
variable "memory_request" {
  type    = string
  default = "1"
}
variable "thrift_port" {
  type    = string
  default = "9083"
}
variable "healthcheck_delay_seconds" {
  type    = number
  default = 120
}
variable "healthcheck_period_seconds" {
  type    = number
  default = 10
}
