output "namespace" {
    value = temporalcloud_namespace.this.id
}

output "api_key" {
    value = temporalcloud_apikey.this.token
    sensitive = true
}