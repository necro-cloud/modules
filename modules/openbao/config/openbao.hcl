ui = true

listener "tcp" {
  tls_disable = 0
  address = "[::]:8200"
  cluster_address = "[::]:8201"

  # TLS Configuration
  tls_cert_file = "/openbao/userconfig/${cert_secret_name}/tls.crt"
  tls_key_file  = "/openbao/userconfig/${cert_secret_name}/tls.key"
  tls_client_ca_file = "/openbao/userconfig/${cert_secret_name}/ca.crt"
}

storage "raft" {
  path = "/openbao/data"
  retry_join {
    auto_join = "provider=k8s namespace=${namespace} label_selector=\"app.kubernetes.io/instance=openbao,component=server\""
    auto_join_scheme = "https"
    
    leader_ca_cert_file = "/openbao/userconfig/${cert_secret_name}/ca.crt"
    leader_tls_servername = "openbao-internal.${namespace}.svc"
  }
}

seal "static" {
  current_key_id = "k3d-local-v1"
  current_key    = "env://OPENBAO_STATIC_UNSEAL_KEY"
}

service_registration "kubernetes" {}
