output "endpoints" {
  description = "Array containing the full resource object and attributes for all endpoints created"
  value       = [for k, v in aws_vpc_endpoint.this : v.id]
}
