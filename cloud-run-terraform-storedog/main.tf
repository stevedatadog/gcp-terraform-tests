provider "google" {
  credentials = file(var.sa_key_file)
  project     = var.project_id
  region      = var.region
}

variable "project_id" {
  description = "The project ID to deploy resources"
  default     = ""
}

variable "region" {
  description = "The region to deploy resources"
  default     = ""
}

variable "sa_key_file" {
  description = "The path to the service account key file"
  default     = ""
}

resource "google_cloud_run_service" "advertisements" {
  name     = "advertisements"
  depends_on = [google_cloud_run_service.database]
  location = var.region

  metadata {
    labels = {
      owner = "steve-calnan"
      team  = "training"
    }
  }

  template {
    metadata {
      labels = {
        owner = "steve-calnan"
        team  = "training"
      }
    }
    spec {
      containers {
        name = "advertisements"
        env {
          name = "POSTGRES_PASSWORD"
          value = "postgres"
        }
        env {
          name = "POSTGRES_USER"
          value = "postgres"
        }
        env {
          name = "POSTGRES_HOST"
          value = "database"
        }
        image = "gcr.io/datadog-community/advertisements-fixed:2.2.0"
        ports { 
          container_port = 9292 
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service" "storefront" {
  name     = "storefront"
  depends_on = [google_cloud_run_service.advertisements,google_cloud_run_service.discounts]
  location = var.region

  metadata {
    labels = {
      owner = "steve-calnan"
      team  = "training"
    }
  }

  template {
    metadata {
      labels = {
        owner = "steve-calnan"
        team  = "training"
      }
    }
    spec {
      containers {
        name = "storefront"
        env {
          name = "POSTGRES_PASSWORD"
          value = "postgres"
        }
        env {
          name = "POSTGRES_USER"
          value = "postgres"
        }
        env {
          name = "POSTGRES_HOST"
          value = "database"
        }
        image = "gcr.io/datadog-community/storefront-fixed:2.2.1"
        ports { 
          container_port = 3000 
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service" "discounts" {
  name     = "discounts"
  depends_on = [google_cloud_run_service.database]
  location = var.region

  metadata {
    labels = {
      owner = "steve-calnan"
      team  = "training"
    }
  }

  template {
    metadata {
      labels = {
        owner = "steve-calnan"
        team  = "training"
      }
    }
    spec {
      containers {
        name = "discounts"
        env {
          name = "POSTGRES_PASSWORD"
          value = "postgres"
        }
        env {
          name = "POSTGRES_USER"
          value = "postgres"
        }
        env {
          name = "POSTGRES_HOST"
          value = "database"
        }
        image = "gcr.io/datadog-community/discounts-fixed:2.2.0"
        ports { 
          container_port = 8282 
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service" "database" {
  name     = "database"
  location = var.region

  metadata {
    labels = {
      owner = "steve-calnan"
      team  = "training"
    }
  }

  template {
    metadata {
      labels = {
        owner = "steve-calnan"
        team  = "training"
      }
    }
    spec {
      containers {
        name = "database"
        image = "postgres:13-alpine"
        env {
          name = "POSTGRES_PASSWORD"
          value = "postgres"
        }
        env {
          name = "POSTGRES_USER"
          value = "postgres"
        }
        ports { 
          container_port = 5432 
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_member" "storefront_to_advertisements" {
  service = google_cloud_run_service.advertisements.name
  location = var.region
  role = "roles/run.invoker"
  member = "serviceAccount:${google_cloud_run_service.storefront.name}@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_cloud_run_service_iam_member" "storefront_to_discounts" {
  service = google_cloud_run_service.discounts.name
  location = var.region
  role = "roles/run.invoker"
  member = "serviceAccount:${google_cloud_run_service.storefront.name}@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_cloud_run_service_iam_member" "advertisements_to_database" {
  service = google_cloud_run_service.database.name
  location = var.region
  role = "roles/run.invoker"
  member = "serviceAccount:${google_cloud_run_service.advertisements.name}@${var.project_id}.iam.gserviceaccount.com"
}

resource "google_cloud_run_service_iam_member" "discounts_to_database" {
  service = google_cloud_run_service.database.name
  location = var.region
  role = "roles/run.invoker"
  member = "serviceAccount:${google_cloud_run_service.discounts.name}@${var.project_id}.iam.gserviceaccount.com"
}

output "advertisements_url" {
  value = google_cloud_run_service.advertisements.status[0].url
}

output "storefront_url" {
  value = google_cloud_run_service.storefront.status[0].url
}

output "discounts_url" {
  value = google_cloud_run_service.discounts.status[0].url
}

output "database_url" {
  value = google_cloud_run_service.database.status[0].url
}

