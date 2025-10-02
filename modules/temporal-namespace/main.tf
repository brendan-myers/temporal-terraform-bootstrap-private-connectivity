terraform {
  required_providers {
    temporalcloud = {
        source = "temporalio/temporalcloud"
    }
  }
}

resource "temporalcloud_connectivity_rule" "this" {
  connectivity_type = "private"
  connection_id     = var.connection_id
  region            = var.region
}

resource "temporalcloud_namespace" "this" {
  name           = var.namespace
  regions        = [var.region]
  api_key_auth   = true
  retention_days = 14

  connectivity_rule_ids = [
    temporalcloud_connectivity_rule.this.id
  ]
}

resource "temporalcloud_service_account" "this" {
  name           = "${var.namespace}-service-account"
  account_access = "read"

  namespace_accesses = [ {
    namespace_id = temporalcloud_namespace.this.id,
    permission   = "admin"
  } ]
}

resource "temporalcloud_apikey" "this" {
  display_name = "${var.namespace}-key"
  owner_type   = "service-account"
  owner_id     = temporalcloud_service_account.this.id
  expiry_time  = timeadd(timestamp(), "8760h") # 365d * 24h
}