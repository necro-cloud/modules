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
    for index, client in concat(var.clients, [{ user = "keycloak", database = "keycloak" }]) : "${index + 1}" => {
      "Name"                = client.database
      "Group"               = "PostgreSQL Server Access",
      "Host"                = "${var.cluster_name}-rw"
      "Port"                = 5432
      "MaintainanceDB"      = client.database
      "Username"            = client.user
      "SSLMode"             = "verify-ca"
      "Comment"             = "PostgreSQL Server Access for Database: ${client.database}"
      "SSLCert"             = "/mnt/certs/${client.user}/tls.crt"
      "SSLKey"              = "/mnt/certs/${client.user}/tls.key"
      "SSLRootCert"         = "/mnt/certs/${client.user}/ca.crt"
      "PasswordExecCommand" = "cat /mnt/passwords/${client.user}/password"
    }
  }
}
