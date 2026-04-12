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

# NGINX Configuration for SSL-ing requests to the container
resource "kubernetes_config_map" "ui_nginx_conf" {
  metadata {
    name      = "garage-ui-nginx-conf"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }
  data = {
    "nginx.conf" = <<EOF
      pid /tmp/nginx.pid;
      events {}
      http {

        client_body_temp_path /tmp/client_temp;
        proxy_temp_path       /tmp/proxy_temp_path;
        fastcgi_temp_path     /tmp/fastcgi_temp;
        uwsgi_temp_path       /tmp/uwsgi_temp;
        scgi_temp_path        /tmp/scgi_temp;
        client_max_body_size 500M;

        server {
          listen 8443 ssl;

          server_name valkey-ui-service.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local;

          ssl_certificate     /mnt/ssl/tls.crt;
          ssl_certificate_key /mnt/ssl/tls.key;

          # ssl_session_cache builtin:1000 shared:SSL:10m;
          ssl_protocols TLSv1.2 TLSv1.3;
          ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
          ssl_prefer_server_ciphers off;
          ssl_session_timeout 1d;
          ssl_session_cache shared:SSL:10m;
          ssl_session_tickets off;

          location / {
              proxy_set_header X-Script-Name /;
              proxy_set_header X-Scheme $scheme;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              
              proxy_set_header Host $host;

              proxy_pass http://127.0.0.1:8081;
              proxy_redirect off;

              proxy_http_version 1.1;
              proxy_set_header Connection "";
          }
        }
      }
    EOF
  }
}
