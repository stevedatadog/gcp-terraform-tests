provider "google" {
  credentials = file(var.gcp_credentials)
  project     = var.gcp_project_id
  region      = var.gcp_region
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" # Choose a specific version or range
    }
  }

  required_version = ">= 1.0.0" # Optional: Specify the required Terraform version
}

