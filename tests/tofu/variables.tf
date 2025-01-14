variable "google" {
  type = object({
    project_id = string
    region = optional(string, "eu-west9")
  })
  description = "google provider configuration"
}

variable "mirror" {
  type = object({
    name = optional(string, "docker-mirror")
  })
  default = {}
}

variable "gke" {
  type = object({
    location = string
    cluster_name = string
    namespace = optional(string, "docker-mirror")
  })
  description = "target cluster configuration"
}