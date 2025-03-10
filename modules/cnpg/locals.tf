locals {
  replication_namespaces = [for config in var.clients : config.namespace]
  managed_roles = [for secret in kubernetes_secret.client_database_credentials : {
    "bypassrls"       = false
    "comment"         = "${secret.data.username} user for postgresql"
    "connectionLimit" = -1
    "createdb"        = true
    "createrole"      = true
    "ensure"          = "present"
    "inherit"         = true
    "login"           = true
    "name"            = secret.data.username
    "passwordSecret" = {
      "name" = secret.metadata[0].name
    }
    "replication" = false
    "superuser"   = false
  }]
}
