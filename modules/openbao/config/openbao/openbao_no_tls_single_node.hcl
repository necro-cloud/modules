ui = ${enable_ui}

listener "tcp" {
  tls_disable = 1
  address = "[::]:8200"
  cluster_address = "[::]:8201"

  telemetry {
    unauthenticated_metrics_access = true
  }
}

storage "raft" {
  path = "/openbao/data"
}

seal "static" {
  current_key_id = "k3d-local-v1"
  current_key    = "env://OPENBAO_STATIC_UNSEAL_KEY"
}

service_registration "kubernetes" {}

telemetry {
  prometheus_retention_time = "30m"
  usage_gauge_period = "1m"
  disable_hostname = true
}
