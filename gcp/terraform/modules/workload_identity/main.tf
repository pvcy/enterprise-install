data "google_project" "this" {
}

resource "google_project_iam_binding" "dns_access" {
  # this iam binding overwrites other bindings already present for this role
  # perhaps we could read all existing bindings on the role and then add this one to them
  project = data.google_project.this.id
  role    = "roles/dns.admin"
  members = [
    "principal://iam.googleapis.com/projects/${data.google_project.this.number}/locations/global/workloadIdentityPools/${data.google_project.this.project_id}.svc.id.goog/subject/ns/${var.external_dns_sa.namespace}/sa/${var.external_dns_sa.name}",
    "principal://iam.googleapis.com/projects/${data.google_project.this.number}/locations/global/workloadIdentityPools/${data.google_project.this.project_id}.svc.id.goog/subject/ns/${var.cert_manager_sa.namespace}/sa/${var.cert_manager_sa.name}",
  ]
}

resource "google_storage_bucket_iam_binding" "postgres" {
  bucket = var.storage_bucket_name
  role   = "roles/storage.admin"
  members = [
    "principal://iam.googleapis.com/projects/${data.google_project.this.number}/locations/global/workloadIdentityPools/${data.google_project.this.project_id}.svc.id.goog/subject/ns/${var.postgres_sa.namespace}/sa/${var.postgres_sa.name}",
  ]
}
