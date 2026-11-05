locals {
  // Namespaces requiring access to the database
  access_namespaces = [for config in var.clients : config.namespace]

  // CNPG Role mapping from module input
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

  // PG Admin Configuration Setup
  pgadmin_servers = {
    for index, client in concat(var.clients, [{ user = "keycloak", database = "keycloak" }]) : "${index + 1}" => {
      "Name"                = client.database
      "Group"               = "PostgreSQL Server Access",
      "Host"                = "${var.cluster_name}-rw"
      "Port"                = 5432
      "MaintenanceDB"       = client.database
      "Username"            = client.user
      "SSLMode"             = var.enable_internal_tls_certificates ? "require" : "disable"
      "Comment"             = "PostgreSQL Server Access for Database: ${client.database}"
      "SSLCert"             = var.enable_internal_tls_certificates ? "/mnt/certs/${client.user}/tls.crt" : null
      "SSLKey"              = var.enable_internal_tls_certificates ? "/mnt/certs/${client.user}/tls.key" : null
      "SSLRootCert"         = var.enable_internal_tls_certificates ? "/mnt/certs/${client.user}/ca.crt" : null
      "PasswordExecCommand" = "cat /mnt/passwords/${client.user}/password"
    }
  }

  // Cluster sizing for the PostgreSQL cluster
  size_lookup = {
    small  = 1
    medium = 2
    large  = 3
  }

  
  // Ingress IP addresses to be added to the host alias
  ingress_hosts = var.enable_sso ? [
    for ip in data.kubernetes_service_v1.ingress_ip_address[0].status[0].load_balancer[0].ingress : {
      ip        = ip.ip
      hostnames = ["${var.sso_host_name}.${var.domain}"]
    }
  ] : []
}
