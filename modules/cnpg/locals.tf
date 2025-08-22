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
  pgadmin_servers = {
    for client in concat(var.var.clients, [{ user = "keycloak", database = "keycloak" }]) : "${index(var.var.clients, client) + 1}" => {
      "Name"                = client.value.database
      "Group"               = "PostgreSQL Server Access",
      "Host"                = "${var.var.cluster_name}-rw"
      "Port"                = 5432
      "MaintainanceDB"      = client.value.database
      "Username"            = client.value.user
      "SSLMode"             = "verify-ca"
      "Comment"             = "PostgreSQL Server Access for Database: ${client.value.database}"
      "SSLCert"             = "/mnt/certs/${client.value.database}tls.crt"
      "SSLKey"              = "/mnt/certs/${client.value.database}/tls.key"
      "SSLRootCert"         = "/mnt/certs/${client.value.database}/ca.crt"
      "PasswordExecCommand" = "cat /mnt/passwords/${client.value.database}/password"
    }
  }
}
