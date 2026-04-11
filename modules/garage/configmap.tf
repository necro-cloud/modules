// Garage Storage Configuration
resource "kubernetes_config_map" "garage_config" {
  metadata {
    name      = "garage-config"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "configmap"
    }
  }

  data = {
    "garage.toml" = <<EOF
      metadata_dir = "/mnt/meta"
      data_dir = "/mnt/data"

      db_engine = "lmdb"
      block_size = 1048576

      replication_factor = ${var.cluster_nodes}
      consistency_mode = "consistent"
      compression_level = 1

      rpc_bind_addr = "[::]:3901"

      bootstrap_peers = []

      [kubernetes_discovery]
      namespace = "${kubernetes_namespace.namespace.metadata[0].name}"
      service_name = "${kubernetes_service.garage-headless.metadata[0].name}"
      skip_crd = false

      [s3_api]
      api_bind_addr = "[::]:3900"
      s3_region = "${var.garage_region}"
      root_domain = "api.${var.host_name}.${var.domain}"

      [admin]
      api_bind_addr = "[::]:3903"
      metrics_require_token = false
    EOF
  }
}

// Garage Storage NGINX Reverse Proxy Settings
resource "kubernetes_config_map" "nginx_config" {
  metadata {
    name      = "nginx-config"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "configmap"
    }
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
        listen 3940 ssl;

        ssl_certificate     /mnt/crt/tls.crt;
        ssl_certificate_key /mnt/crt/tls.key;
        server_name *.garage.garage.svc.cluster.local garage-headless.garage.svc.cluster.local *.garage-headless.garage.svc.cluster.local *.garage-service.garage.svc.cluster.local garage-service.garage.svc.cluster.local 127.0.0.1 localhost

        # HSTS (ngx_http_headers_module is required) (63072000 seconds)
        add_header Strict-Transport-Security "max-age=63072000" always; 

        location / {
          proxy_pass http://127.0.0.1:3900;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Host $http_host;

          # Disable buffering to a temporary file.
          proxy_max_temp_file_size 0;
        }
      }

      server {
        listen 3942 ssl;

        ssl_certificate     /mnt/crt/tls.crt;
        ssl_certificate_key /mnt/crt/tls.key;
        server_name *.garage.garage.svc.cluster.local garage-headless.garage.svc.cluster.local *.garage-headless.garage.svc.cluster.local *.garage-service.garage.svc.cluster.local garage-service.garage.svc.cluster.local 127.0.0.1 localhost

        # HSTS (ngx_http_headers_module is required) (63072000 seconds)
        add_header Strict-Transport-Security "max-age=63072000" always; 

        location / {
          proxy_pass http://127.0.0.1:3902;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Host $http_host;

          # Disable buffering to a temporary file.
          proxy_max_temp_file_size 0;
        }
      }

      server {
        listen 3943 ssl;

        ssl_certificate     /mnt/crt/tls.crt;
        ssl_certificate_key /mnt/crt/tls.key;
        server_name *.garage.garage.svc.cluster.local garage-headless.garage.svc.cluster.local *.garage-headless.garage.svc.cluster.local *.garage-service.garage.svc.cluster.local garage-service.garage.svc.cluster.local 127.0.0.1 localhost

        # HSTS (ngx_http_headers_module is required) (63072000 seconds)
        add_header Strict-Transport-Security "max-age=63072000" always; 

        location / {
          proxy_pass http://127.0.0.1:3903;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header Host $http_host;

          # Disable buffering to a temporary file.
          proxy_max_temp_file_size 0;
        }
      }
    }
    EOF
  }
}

// Garage Configrator Options
resource "kubernetes_config_map" "configurator-options" {
  metadata {
    name      = "configurator-options"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "configmap"
    }
  }

  data = {
    "configurator.json" = jsonencode(local.configurator_options)
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

          server_name garage-ui.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local;

          ssl_certificate     /mnt/crt/tls.crt;
          ssl_certificate_key /mnt/crt/tls.key;

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

              proxy_pass http://127.0.0.1:8080;
              proxy_redirect off;

              proxy_http_version 1.1;
              proxy_set_header Connection "";
          }
        }
      }
    EOF
  }
}


resource "kubernetes_config_map" "garage_ui_config" {
  metadata {
    name      = "garage-ui-config"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "configmap"
    }
  }

  data = {
    "config.yaml" = <<EOF

server:
  host: "0.0.0.0"
  port: 8080
  environment: "production" 
  domain: "localhost" 
  protocol: "http"
  root_url: "http://localhost:8080" 

  max_body_size: 524288000
  max_header_size: 1048576 
  read_buffer_size: 4096 
  write_buffer_size: 4096 

garage:
  endpoint: "https://${kubernetes_service.garage-service.metadata[0].name}.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local:3940" 
  region: "${var.garage_region}" 
  
  admin_endpoint: "https://${kubernetes_service.garage-service.metadata[0].name}.${kubernetes_namespace.namespace.metadata[0].name}.svc.cluster.local:3943" 
  admin_token: "" 

auth:
  admin:
    enabled: true

  oidc:
    enabled: false
    session_max_age: 3600

cors:
  enabled: true
  allowed_origins: ["*"] 
  allowed_methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  allow_credentials: false

logging:
  level: "debug"
  format: "text"
EOF

  }
}
