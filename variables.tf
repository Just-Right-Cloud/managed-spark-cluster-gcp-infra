variable "project_id" {
  description = "The ID of the project in which the resources will be created."
  type        = string
  default     = "eighth-duality-468907-t2"
}

variable "location" {
  description = "The region to use for infrastructure."
  type        = string
  default     = "asia-south1"
}

variable "github_application_id" {
  description = "The ID of the GitHub application."
  type        = string
}

variable "github_application_installation_id" {
  description = "The installation ID of the GitHub application."
  type        = string
}

variable "github_application_private_key" {
  description = "The private key for the GitHub application."
  type        = string
  sensitive   = true
}

variable "github_repository_name" {
  description = "The name of the GitHub repository containing the Kubernetes manifests."
  type        = string
  default     = "Just-Right-Cloud/argo-cd"
}
