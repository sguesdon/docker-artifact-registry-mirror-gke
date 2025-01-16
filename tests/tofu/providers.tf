provider "google" {
  project = var.google.project_id
  region  = var.google.region
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.this.endpoint}"
  token                  = data.google_client_config.this.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.this.master_auth.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.google_container_cluster.this.endpoint
    token                  = data.google_client_config.this.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.this.master_auth.0.cluster_ca_certificate)
  }
}
