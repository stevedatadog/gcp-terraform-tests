variable "gcp_credentials" {
  description = "Path to the GCP credentials JSON file"
  type        = string
}

variable "gcp_project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "gcp_project_number" {
  description = "The GCP Project number"
  type        = number
  # gcloud projects describe $GCP_PROJECT_ID --format='value(projectNumber)'
}

variable "gcp_region" {
  description = "The GCP region to deploy resources in"
  type        = string
  default     = "us-west2" # Optional: Set a default region
}

variable "gcp_label_owner" {
  description = "The GCP label for the human owner of the resource"
  type        = string
}

variable "gcp_label_team" {
  description = "The GCP label for the team that the  owner belongs to"
  type        = string
}
