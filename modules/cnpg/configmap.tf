resource "kubernetes_config_map" "pgadmin_servers_configuration" {
  metadata {
    name      = "${var.cluster_name}-servers-configuration"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "configmap"
    }
  }

  data = {
    "servers.json" = jsonencode({
      "Servers" = local.pgadmin_servers
    })
  }
}

resource "kubernetes_config_map" "nginx_conf" {
  metadata {
    name      = "nginx-conf"
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
          listen 443 ssl;

          ssl_certificate     /mnt/ssl/tls.crt;
          ssl_certificate_key /mnt/ssl/tls.key;

          ssl_session_cache builtin:1000 shared:SSL:10m;
          ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
          ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
          ssl_prefer_server_ciphers on;

          location /pgadmin4/ {
              proxy_set_header X-Script-Name /pgadmin4;
              proxy_set_header X-Scheme $scheme;
              proxy_set_header Host $host;
              proxy_pass http://localhost:5050/;
              proxy_redirect off;
          }
        }
      }
    EOF
  }
}
