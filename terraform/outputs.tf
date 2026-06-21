output "app_service_name" {
  value       = kubernetes_service.app.metadata[0].name
  description = "Name of the app service"
}

output "app_service_port" {
  value       = kubernetes_service.app.spec[0].port[0].port
  description = "Port of the app service"
}
