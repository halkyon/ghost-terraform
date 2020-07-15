output "service_ip" {
  value = kubernetes_service.ghost.load_balancer_ingress.0.ip
}
