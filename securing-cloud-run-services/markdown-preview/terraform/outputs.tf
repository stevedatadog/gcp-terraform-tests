output "editor_service_url" {
  description = "The public URL of the Cloud Run service for the editor"
  value       = google_cloud_run_v2_service.editor.uri
}

