output "thrift_connection_string" {
  value = "thrift://${kubernetes_service.hive.metadata.0.name}:${var.thrift_port}"
}
