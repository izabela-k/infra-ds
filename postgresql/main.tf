provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "ds1-terraform-state"
    key    = "terraform-state"
    region = "eu-west-1"
  }
}


resource "kubernetes_stateful_set" "postgresql" {
  metadata {
    name = "postgresql"
  }

  spec {
    service_name = "postgresql"
    replicas = 1
    revision_history_limit = 2

    selector {
      match_labels = {
        k8s-app = "postgresql"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "postgresql"
        }
        annotations = {}
      }

      spec {
        container {
          name = "postgresql"
          image = "postgres"
          image_pull_policy = "IfNotPresent"

          env {
            name = "POSTGRES_PASSWORD"
            value = "postgres"
          }

          volume_mount {
            name = "postgresql-data"
            mount_path = "/var/lib/postgresql/data"
            sub_path = "data"
          }
        }
      }
    } # end of template

    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 1
      }
    } # end of update_strategy

    volume_claim_template {
      metadata {
        name = "postgresql-data"
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
    } # end of volume_claim_template
  } # end of spec
}

resource "kubernetes_service" "postgresql" {
  metadata {
    name = "postgresql"
  }
  
  spec {
    selector = {
      app = "postgresql"
    }

    port {
      port = 5432
      target_port = 5432
    }
  }
}
