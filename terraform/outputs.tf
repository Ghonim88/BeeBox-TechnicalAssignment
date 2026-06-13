output "lb_url" {
  description = "Public entry point for the system (add lb_hostname to /etc/hosts)."
  value       = "http://${var.lb_hostname}:${var.lb_port}"
}

output "network_name" {
  description = "Docker network all nodes are attached to."
  value       = docker_network.beebox.name
}

output "containers" {
  description = "Provisioned nodes mapped to their role."
  value       = { for name, cfg in local.nodes : name => cfg.role }
}

output "web_servers" {
  description = "Names of the web server nodes behind the load balancer."
  value       = sort(keys(local.web_nodes))
}
