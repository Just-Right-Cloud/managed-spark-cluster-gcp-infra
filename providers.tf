terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.48.0"
    }
  }
  backend "gcs" {
    #backend info set in pipeline
  }
}

provider "google" {
  #identity configured in pipeline
}
