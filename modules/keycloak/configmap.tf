# Realm JSON File to be used for setting up the Keycloak Clients
resource "kubernetes_config_map" "realm_configuration" {
  metadata {
    name      = "realm-configuration"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app       = var.app_name
      component = "configmap"
    }
  }

  data = {
    "realm.json" = "${file("${path.module}/realm.json")}"
  }
}
