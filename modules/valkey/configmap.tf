resource "kubernetes_config_map" "valkey_conf" {
  metadata {
    name      = "valkey-configuration"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "configmap"
    }
  }
  data = {
    "valkey.conf" = <<EOF
      port 0
      tls-port 6379

      protected-mode no
      appendonly yes

      dir /data

      # This is critical. Replicas need this to auth with a newly promoted primary.
      primaryauth VALKEY_PASSWORD

      # TLS Configuration
      tls-replication yes
      tls-cert-file /etc/valkey/tls/tls.crt
      tls-key-file /etc/valkey/tls/tls.key
      tls-ca-cert-file /etc/valkey/tls/ca.crt
    EOF
  }
}
