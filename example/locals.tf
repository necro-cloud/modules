locals {
  keycloak_realm_settings = {
    display_name               = "Necronizer's Cloud"
    application_name           = "cloud"
    base_url                   = var.keycloak_authentication_base_url
    valid_login_redirect_path  = var.keycloak_authentication_valid_login_redirect_path
    valid_logout_redirect_path = var.keycloak_authentication_valid_logout_redirect_path
    smtp_host                  = var.smtp_host
    smtp_port                  = var.smtp_port
    smtp_mail                  = var.smtp_mail
    smtp_username              = var.smtp_username
    smtp_password              = var.smtp_password
  }
}
