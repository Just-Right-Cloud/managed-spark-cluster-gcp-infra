module "network" {
<<<<<<< Updated upstream
=======
  depends_on = [ google_project_service.project ]
>>>>>>> Stashed changes
  source  = "terraform-google-modules/network/google"
  version = "11.1.1"

  project_id = var.project_id
  network_name = "gke-vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name   = "gke-subnet"
      subnet_ip     = "10.0.0.0/16"
      subnet_region = var.location

      secondary_ip_ranges = {
        pods     = "10.1.0.0/16"
        services = "10.2.0.0/20"
      }
    }
  ]
}