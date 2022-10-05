output "elk_endpoint" {
  value = aws_elasticsearch_domain.es.endpoint
}

output "elk_kibana_endpoint" {
  value = aws_elasticsearch_domain.es.kibana_endpoint
}