###############################################################################
# BeeBox infrastructure (local Docker, VM-like systemd containers)
#
# Topology: 1 load balancer + N web servers + 1 database, all on a private
# user-defined bridge network. Containers run systemd as PID 1 so that Ansible
# can manage them exactly like real servers (services, apt, lynis).
###############################################################################

locals {
  # Single source of truth for every node. Web servers are generated from
  # var.web_replica_count; db and lb are fixed singletons.
  web_nodes = {
    for i in range(1, var.web_replica_count + 1) :
    "web-${i}" => { role = "webserver" }
  }

  nodes = merge(
    {
      db = { role = "database" }
      lb = { role = "loadbalancer" }
    },
    local.web_nodes,
  )
}

# Pull the systemd-enabled base image once; reused by every node.
resource "docker_image" "base" {
  name         = var.base_image
  keep_locally = true # don't delete the image after the container is destroyed, faster iterations
}

# Private network so nodes resolve each other by name (db, web-1, web-2, lb).
resource "docker_network" "beebox" {
  name   = var.network_name
  driver = "bridge"

  labels {
    label = "com.beebox.project"
    value = var.project_name
  }
}

resource "docker_container" "node" {
  for_each = local.nodes

  name     = each.key
  hostname = each.key # so the app's socket.gethostname() reports web-1 / web-2
  image    = docker_image.base.image_id

  # --- systemd-in-container requirements  to behave like VMs so Ansible can manage them---
  privileged    = true
  cgroupns_mode = "host"
  command       = ["/lib/systemd/systemd"]
  stop_signal   = "SIGRTMIN+3" # systemd's clean-shutdown signal
  stop_timeout  = 15

  tmpfs = {
    "/run"      = "rw,noexec,nosuid,size=64m"
    "/run/lock" = "rw,noexec,nosuid,size=8m"
  }

  volumes {
    host_path      = "/sys/fs/cgroup"
    container_path = "/sys/fs/cgroup"
    read_only      = false
  }

  # --- lifecycle ---
  restart  = var.restart_policy
  must_run = true

  # --- networking ---
  networks_advanced {
    name    = docker_network.beebox.name
    aliases = [each.key]
  }

  # Only the load balancer is published to the host.
  dynamic "ports" {
    for_each = each.key == "lb" ? [1] : []
    content {
      internal = 80
      external = var.lb_port
      protocol = "tcp"
    }
  }

  labels {
    label = "com.beebox.project"
    value = var.project_name
  }

  labels {
    label = "com.beebox.role"
    value = each.value.role
  }
}
