// Valkey Cluster Configuration for ports, memory, persistence and security
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
      # Ports to be exposed
      port 0
      tls-port 6379
      protected-mode no

      # Memory Management
      maxmemory 800mb
      maxmemory-policy allkeys-lru

      # Persistence for the Valkey node
      appendonly yes 
      dir /data

      # Password to be used for Replication
      primaryauth VALKEY_PASSWORD

      # TLS Configuration
      tls-replication yes
      tls-cert-file /etc/valkey/tls/tls.crt
      tls-key-file /etc/valkey/tls/tls.key
      tls-ca-cert-file /etc/valkey/tls/ca.crt
    EOF
  }
}
