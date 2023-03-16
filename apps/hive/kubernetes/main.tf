resource "kubernetes_secret" "secret-conf" {
  metadata {
    name      = "hive-${var.name}-secret-conf"
    namespace = var.namespace
  }

  data        = var.config_files
  binary_data = var.binary_config_files
}

resource "kubernetes_deployment" "hive" {
  metadata {
    name      = "hive-${var.name}-metastore"
    namespace = var.namespace
    labels = {
      app     = "hive-${var.name}-metastore"
      version = var.hive_version
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app     = "hive-${var.name}-metastore"
        version = var.hive_version
      }
    }

    template {
      metadata {
        labels = {
          app     = "hive-${var.name}-metastore"
          version = var.hive_version
        }
      }

      spec {

        volume {
          name = "secret-conf-volume"
          secret {
            secret_name = "hive-${var.name}-secret-conf"
          }
        }

        container {
          image = "${var.container_repo}:${var.container_tag}"
          name  = "hive-metastore"

          volume_mount {
            mount_path = "/opt/hive/conf"
            name       = "secret-conf-volume"
          }

          resources {
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
            requests = {
              cpu    = var.cpu_request
              memory = var.memory_request
            }
          }

          port {
            container_port = var.thrift_port
          }

          liveness_probe {
            tcp_socket {
              port = var.thrift_port
            }

            initial_delay_seconds = var.healthcheck_delay_seconds
            period_seconds        = var.healthcheck_period_seconds
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "hive" {
  metadata {
    namespace = var.namespace
    name      = "hive-${var.name}"
  }
  spec {
    selector = {
      app = kubernetes_deployment.hive.metadata.0.labels.app
    }

    port {
      port        = var.thrift_port
      target_port = var.thrift_port
    }

    type = "ClusterIP"
  }
}
