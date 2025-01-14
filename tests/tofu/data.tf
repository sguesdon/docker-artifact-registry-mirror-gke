data "google_client_config" "this" {}

data "google_container_cluster" "this" {
  name     = var.gke.cluster_name
  location = var.gke.location
}
