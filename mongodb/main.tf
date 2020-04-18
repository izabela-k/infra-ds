resource "kubernetes_stateful_set" "mongodb" {
  metadata {
    name = "mongodb"
  }

  spec {
    service_name = "mongodb"
    replicas = 1 
    revision_history_limit = 2

    selector {
      match_labels = {
        k8s-app = "mongodb"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "mongodb"
        }

        annotations = {}
      }

      spec {
        container {
          name = "mongodb-standalone"
          image = "mongo:4"
          image_pull_policy = "IfNotPresent"

          env {
            name = "MONGO_INITDB_ROOT_USERNAME"
            value = "admin"
          }

          env {
            name = "MONGO_INITDB_ROOT_PASSWORD"
            value = "initial_password"
          }

          volume_mount {
            name       = "mongodb-data"
            mount_path = "/data"
          }

          liveness_probe {
            exec {
              command = ["mongo", "--eval", "db.adminCommand('ping')"]
            }

            initial_delay_seconds = 30
            timeout_seconds       = 5
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }

          readiness_probe {
            exec {
              command = ["mongo", "--eval", "db.adminCommand('ping')"]
            }

            initial_delay_seconds = 5
            timeout_seconds       = 1
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }
        }
      }
    }

    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 1
      }
    }
    volume_claim_template {
      metadata {
        name = "mongodb-data"
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "csi-cinder-high-speed"

        resources {
          requests = {
            storage = "5Gi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mongodb" {
  metadata {
    name = "mongdb"
  }
  spec {
    selector = {
      app = "mongodb"
    }

    port {
      port = 27017
      target_port = 27017
    }

    cluster_ip = "None"
    type = "ClusterIP"
    publish_not_ready_addresses = true
  }
}