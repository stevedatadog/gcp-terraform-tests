provider "google" {
  credentials = var.sa-key-file
  project     = var.project_id
  region      = var.region
}

resource "google_cloud_run_service" "default" {
  name     = "terraform-cloud-run"
  location = var.region

  # Metadata for the service
  metadata {
    labels = {
      owner = "steve_calnan"
      team  = "training"
    }
  }

  template {
    # Metadata for the revision
    metadata {
      labels = {
        owner = "steve_calnan"
        team  = "training"
      }
    }
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_binding" "run_invoker" {
  location    = google_cloud_run_service.default.location
  project     = var.project_id
  service     = google_cloud_run_service.default.name
  role        = "roles/run.invoker"

  members = [
    "allUsers",
  ]
}

output "cloud_run_service_url" {
  value = google_cloud_run_service.default.status[0].url
  description = "The URL of the deployed Cloud Run service"
}

variable "project_id" {
  description = "The project ID to deploy resources"
  default     = ""
}

variable "region" {
  description = "The region to deploy resources"
  default     = ""
}

variable "sa-key-file" {
  description = "The path to the service account key file"
  default     = ""
}
