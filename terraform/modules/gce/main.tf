resource "google_compute_instance" "default" {
  name         = "flask-vm"
  machine_type = "f1-micro"
  zone         = var.zone
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # Install Flask
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python3-pip rsync; pip install flask"

  network_interface {
    subnetwork = var.network_id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}
