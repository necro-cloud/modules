locals {
  access_namespaces = [for config in var.clients : config.namespace]
  managed_roles = [for index, client in var.clients : {
    "bypassrls"       = false
    "comment"         = "${client.user} user for postgresql"
    "connectionLimit" = -1
    "createdb"        = true
    "createrole"      = true
    "ensure"          = "present"
    "inherit"         = true
    "login"           = true
    "name"            = client.user
    "passwordSecret" = {
      "name" = kubernetes_manifest.client_database_credentials_sync[index].object.spec.target.name
    }
    "replication" = false
    "superuser"   = false
  }]
}
