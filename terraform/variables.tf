variable "docker_host" {
  description = "Docker daemon socket/endpoint. Empty = use active docker context or DOCKER_HOST env."
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Logical project name, used for container labels and the network."
  type        = string
  default     = "beebox"
}

variable "network_name" {
  description = "Name of the user-defined Docker bridge network the nodes share."
  type        = string
  default     = "beebox-net"
}

variable "base_image" {
  description = <<-EOT
    Systemd-enabled, Python-ready base image used for all nodes so containers
    behave like real servers (systemctl, apt, lynis). Pinned by digest for full
    reproducibility and to avoid the moving ":latest" tag. The digest below
    points at the multi-arch manifest index, so it resolves correctly on both
    linux/amd64 and linux/arm64.

    To bump: `docker buildx imagetools inspect geerlingguy/docker-debian12-ansible:latest`
    and copy the top-level "Digest:" value.
  EOT
  type        = string
  # Pinned by digest instead of ":latest" so the exact image bits are locked in:
  # reproducible across machines/CI, immune to silent upstream republishes, and
  # gives us a stable target for vulnerability scans (Trivy/Lynis reports stay
  # meaningful between runs). The validation below enforces this at plan time.
  default = "geerlingguy/docker-debian12-ansible@sha256:1f76107285118095a97e14673de67ee7a4372a840b35223cd0c1212fdd3cf5b3"

  validation {
    condition     = can(regex("@sha256:[0-9a-f]{64}$", var.base_image))
    error_message = "base_image must be pinned by digest, e.g. \"repo/name@sha256:<64-hex>\". Tagged refs like \":latest\" are not allowed."
  }
}

variable "web_replica_count" {
  description = "Number of web server nodes to provision (assignment requires 2)."
  type        = number
  default     = 2

  validation {
    condition     = var.web_replica_count >= 1
    error_message = "web_replica_count must be at least 1."
  }
}

variable "lb_port" {
  description = "Host port the load balancer is published on (http://<lb_hostname>:<lb_port>)."
  type        = number
  default     = 8080
}

variable "lb_hostname" {
  description = "Hostname the load balancer answers on (resolved via /etc/hosts)."
  type        = string
  default     = "ucpe.swisscom.com"
}

variable "restart_policy" {
  description = "Container restart policy."
  type        = string
  default     = "unless-stopped"
}
