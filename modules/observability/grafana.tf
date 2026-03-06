resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana-community.github.io/helm-charts"
  chart      = "grafana"
  version    = "11.1.7"

  namespace = kubernetes_namespace.namespace.metadata[0].name

  values = [
    yamlencode({

      // Authentication Credentials
      admin = {
        existingSecret = kubernetes_secret.observability_credentials.metadata[0].name
        userKey = "username"
        passwordKey = "password"
      }

      // Automatically install the VictoriaMetrics Logs plugin for native VictoriaLogs support
      plugins = [
        "victoriametrics-logs-datasource"
      ]

      // Provisioning of datasources during deployment
      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [
            {
              name      = "VictoriaMetrics"
              type      = "prometheus"
              url       = "http://victoria-metrics-victoria-metrics-single-server:8428"
              access    = "proxy"
              isDefault = true
            },
            {
              name   = "VictoriaLogs"
              type   = "victoriametrics-logs-datasource"
              url    = "http://victoria-logs-victoria-logs-single-server:9428"
              access = "proxy"
            }
          ]
        }
      }

      resources = {
        requests = {
          cpu    = "100m"
          memory = "256Mi"
        }
        limits = {
          cpu    = "500m"
          memory = "512Mi"
        }
      }

      // Persistence for dashboards, settings, and downloaded plugins
      persistence = {
        enabled          = true
        accessModes      = ["ReadWriteOnce"]
        size             = "5Gi"
        storageClassName = "local-path"
      }

      podLabels = {
        app       = var.app_name
        component = "dashboard"
      }

      // Mount Certificates and Attach them to the Grafana Instance
      extraSecretMounts = [
        {
          name        = kubernetes_manifest.internal_certificate.manifest.spec.secretName
          secretName  = kubernetes_manifest.internal_certificate.manifest.spec.secretName
          defaultMode = "0400"
          mountPath   = "/etc/grafana/ssl"
          readOnly    = true
        }
      ]

      
      "grafana.ini" = {
        server = {
          protocol  = "https"
          cert_file = "/etc/grafana/ssl/tls.crt" 
          cert_key  = "/etc/grafana/ssl/tls.key"
        }
      }

      // Health checks to use HTTPS instead of HTTP
      readinessProbe = {
        httpGet = {
          scheme = "HTTPS"
        }
      }
      livenessProbe = {
        httpGet = {
          scheme = "HTTPS"
        }
      }

      
      // Deploy dashboards to Grafana
      dashboardProviders = {
        "dashboardproviders.yaml" = {
          apiVersion = 1
          providers = [
            {
              name            = "Cloudnative PostgreSQL Database Dashboard"
              orgId           = 1
              folder          = "Database Dashboards"
              type            = "file"
              disableDeletion = false
              editable        = true
              options = {
                path = "/var/lib/grafana/dashboards/psql"
              },
            },
            {
              name            = "Garage S3 Object Storage Dashboard"
              orgId           = 1
              folder          = "Object Storage Dashboards"
              type            = "file"
              disableDeletion = false
              editable        = true
              options = {
                path = "/var/lib/grafana/dashboards/garage"
              },
            },
            {
              name            = "Keycloak Identity Management Dashboard"
              orgId           = 1
              folder          = "Application Services Dashboards"
              type            = "file"
              disableDeletion = false
              editable        = true
              options = {
                path = "/var/lib/grafana/dashboards/keycloak"
              },
            },
            {
              name            = "Valkey In Memory Database Dashboard"
              orgId           = 1
              folder          = "Database Dashboards"
              type            = "file"
              disableDeletion = false
              editable        = true
              options = {
                path = "/var/lib/grafana/dashboards/valkey"
              },
            }
          ]
        }
      }

      // Injecting the Dashboard JSON file into the Grafana container
      dashboards = {
        psql = {
          postgres-dashboard = {
            json = file("${path.module}/dashboards/postgresql.json")
          }
        }
        garage = {
          garage-dashboard = {
            json = file("${path.module}/dashboards/garage.json")
          }
        }
        keycloak = {
          keycloak-dashboard = {
            json = file("${path.module}/dashboards/keycloak.json")
          }
        }
        valkey = {
          valkey-dashboard = {
            json = file("${path.module}/dashboards/valkey.json")
          }
        }
      }
                  
      affinity = {
        nodeAffinity = {
          requiredDuringSchedulingIgnoredDuringExecution = {
            nodeSelectorTerms = [
              {
                matchExpressions = [
                  {
                    key      = "worker"
                    operator = "Exists"
                  }
                ]
              }
            ]
          }
        }
      }
    })
  ]

  depends_on = [
    helm_release.metrics,
    helm_release.logs
  ]
}
