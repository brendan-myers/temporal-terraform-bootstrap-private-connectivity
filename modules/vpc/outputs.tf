output "vpc_id" {
    value = aws_vpc.this.id
}

output "subnet_id" {
    value = aws_subnet.this.id
}

output "security_group_id" {
    value = aws_security_group.this.id
}

output "temporal_endpoint_id" {
    value = aws_vpc_endpoint.temporal.id
}

output "temporal_endpoint_address" {
    value = aws_vpc_endpoint.temporal.dns_entry[0].dns_name
}