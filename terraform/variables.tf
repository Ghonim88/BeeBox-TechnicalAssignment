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
    behave like real servers (systemctl, apt, lynis). Pin by digest for full
    reproducibility, e.g. "geerlingguy/docker-debian12-ansible@sha256:<digest>".
  EOT
  type        = string
  default     = "geerlingguy/docker-debian12-ansible:latest"
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
