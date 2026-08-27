locals {
  database_url_tls     = "jdbc:postgresql://postgresql-cluster-rw.postgres.svc/keycloak?ssl=true&sslmode=verify-full&sslrootcert=/mnt/certs/database/certificate-authority/ca.crt&sslcert=/mnt/certs/database/certificate/tls.crt&sslkey=/mnt/der/key.der"
  database_url_non_tls = "jdbc:postgresql://postgresql-cluster-rw.postgres.svc/keycloak?ssl=false&sslmode=disable"
  size_lookup = {
    small  = 1
    medium = 2
    large  = 3
  }
  port = var.enable_internal_tls_certificates ? 8443 : 8080
}
