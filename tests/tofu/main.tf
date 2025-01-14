resource "google_artifact_registry_repository" "this" {
  repository_id = var.mirror.name
  format        = "DOCKER"
  description   = "Mirror repository for dockerhub images"
  location      = "europe"
  mode          = "REMOTE_REPOSITORY"
  remote_repository_config {
    description = "docker hub"
    docker_repository {
      public_repository = "DOCKER_HUB"
    }
  }
}

resource "google_service_account" "this" {
  account_id   = var.mirror.name
  display_name = "wisa for ${var.mirror.name}"
}

resource "google_artifact_registry_repository_iam_binding" "this" {
  repository    = google_artifact_registry_repository.this.name
  location = google_artifact_registry_repository.this.location
  role          = "roles/artifactregistry.reader"
  members       = ["serviceAccount:${google_service_account.this.email}"]
}

resource "google_service_account_iam_binding" "this" {
  service_account_id = google_service_account.this.name
  role               = "roles/iam.workloadIdentityUser"
  members            = ["serviceAccount:${var.google.project_id}.svc.id.goog[${var.gke.namespace}/${var.mirror.name}]"]
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.mirror.name
  }
}

resource "helm_release" "this" {
  name       = var.mirror.name
  namespace  = var.mirror.name

  chart      = "docker-gcp-private-mirror"
  repository = "oci://registry-1.docker.io/sguesdon"
  version    = "0.0.1"

  set {
    name  = "fullnameOverride"
    value = var.mirror.name
  }

  set {
    name  = "nginx.proxy.upstreamHost"
    value = "${google_artifact_registry_repository.this.location}-docker.pkg.dev"
  }

  set {
    name  = "nginx.proxy.rewritePath"
    value = "${google_artifact_registry_repository.this.project}/${google_artifact_registry_repository.this.repository_id}"
  }

  set {
    name  = "serviceAccount.annotations.iam\\.gke\\.io\\/gcp-service-account"
    value = google_service_account.this.email
  }

  depends_on = [ kubernetes_namespace.this ]
}
