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

      replication_factor = 3
      consistency_mode = "consistent"
      compression_level = 1

      rpc_bind_addr = "[::]:3901"

      bootstrap_peers = []

      [kubernetes_discovery]
      namespace = "${kubernetes_namespace.namespace.metadata[0].name}"
      service_name = "${kubernetes_service.garage-service.metadata[0].name}"
      skip_crd = false

      [s3_api]
      api_bind_addr = "[::]:3900"
      s3_region = "garage"
      root_domain = ".svc.cluster.local"

      [admin]
      api_bind_addr = "[::]:3903"
    EOF
  }
}

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
    
      server {
        listen [::]:3940 ssl;

        ssl_certificate     /mnt/crt/tls.crt;
        ssl_certificate_key /mnt/crt/tls.key;

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
        listen [::]:3942 ssl;

        ssl_certificate     /mnt/crt/tls.crt;
        ssl_certificate_key /mnt/crt/tls.key;

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
        listen [::]:3943 ssl;

        ssl_certificate     /mnt/crt/tls.crt;
        ssl_certificate_key /mnt/crt/tls.key;

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
