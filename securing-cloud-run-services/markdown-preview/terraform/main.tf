resource "google_service_account" "renderer" {
  provider     = google-beta
  account_id   = "renderer-identity"
  display_name = "Markdown preview renderer service identity"
}

resource "google_cloud_run_v2_service" "renderer" {
  provider = google-beta
  name     = "renderer"
  location = var.gcp_region
  template {
    containers {
      image = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/markdown-preview/renderer:latest"
    }
    service_account = google_service_account.renderer.email
  }
  labels = {
    owner = var.gcp_label_owner
    team  = var.gcp_label_team
  }
}

resource "google_service_account" "editor" {
  provider     = google-beta
  account_id   = "editor-identity"
  display_name = "Markdown preview editor service identity"
}

resource "google_cloud_run_service_iam_member" "editor_invokes_renderer" {
  provider = google-beta
  location = google_cloud_run_v2_service.renderer.location
  service  = google_cloud_run_v2_service.renderer.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.editor.email}"
}

resource "google_cloud_run_v2_service" "editor" {
  provider = google-beta
  name     = "editor"
  location = var.gcp_region
  template {
    containers {
      image = "${var.gcp_region}-docker.pkg.dev/${var.gcp_project_id}/markdown-preview/editor:latest"

      # Include a reference to the private Cloud Run
      # service's URL as an environment variable.
      env {
        name  = "EDITOR_UPSTREAM_RENDER_URL"
        value = google_cloud_run_v2_service.editor.uri
      }
    }
    service_account = google_service_account.editor.email
  }
  labels = {
    owner = var.gcp_label_owner
    team  = var.gcp_label_team
  }
}

# Allow allUsers (public) access to the editor service
data "google_iam_policy" "noauth" {
  provider = google-beta
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  provider = google-beta
  location = google_cloud_run_v2_service.editor.location
  project  = google_cloud_run_v2_service.editor.project
  service  = google_cloud_run_v2_service.editor.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
