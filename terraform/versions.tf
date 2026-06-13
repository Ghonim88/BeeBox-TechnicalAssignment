terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# The provider talks to the LOCAL Docker daemon. By design no host is hardcoded:
#   - leave var.docker_host empty to use the active docker context / DOCKER_HOST
#   - or set it explicitly (e.g. Colima: unix://$HOME/.colima/default/docker.sock)
# This keeps the configuration portable across Colima, Docker Desktop and Linux.
provider "docker" {
  host = var.docker_host != "" ? var.docker_host : null
}
