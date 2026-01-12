resource "kubernetes_job" "ferret_permissions" {
  metadata {
    name = "ferret-sql-permissions"
    namespace = kubernetes_namespace.namespace.metadata[0].name
    labels = {
      app = var.app_name
      component = "job"
    }
  }

  spec {
    template {
      metadata {
        name = "ferret-sql-permissions"
      }

      spec {
        restart_policy = "OnFailure"

        container {
          name = "grant-permissions"
          image = "postgres:17-alpine"

          env {
            name  = "PGHOST"
            value = "ferret-postgresql-cluster-rw"
          }
          env {
            name  = "PGDATABASE"
            value = "ferret"
          }
          env {
            name = "PGUSER"
            value_from {
              secret_key_ref {
                name = "ferret-postgresql-cluster-superuser"
                key  = "username"
              }
            }
          }
          env {
            name = "PGPASSWORD"
            value_from {
              secret_key_ref {
                name = "ferret-postgresql-cluster-superuser"
                key  = "password"
              }
            }
          }

          command = [
            "/bin/bash",
            "-c"
          ]
          args = [
            <<EOF
# Wait for DB to be reachable
until pg_isready; do echo "Waiting for DB..."; sleep 2; done;

# Run the Fixed Grant Script
psql <<SQL
-- 1. Grant access to the internal API schema
GRANT USAGE ON SCHEMA documentdb_api_internal TO ferret;
GRANT ALL ON ALL TABLES IN SCHEMA documentdb_api_internal TO ferret;
GRANT ALL ON ALL SEQUENCES IN SCHEMA documentdb_api_internal TO ferret;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA documentdb_api_internal TO ferret;

-- 2. Conditionally grant access to RUM schema
DO \$\$
BEGIN
   IF EXISTS (SELECT 1 FROM information_schema.schemata WHERE schema_name = 'documentdb_rum') THEN
       EXECUTE 'GRANT USAGE ON SCHEMA documentdb_rum TO ferret';
       EXECUTE 'GRANT ALL ON ALL TABLES IN SCHEMA documentdb_rum TO ferret';
       EXECUTE 'GRANT ALL ON ALL FUNCTIONS IN SCHEMA documentdb_rum TO ferret';
       RAISE NOTICE 'Granted permissions on documentdb_rum';
   ELSE
       RAISE NOTICE 'Schema documentdb_rum not found, skipping.';
   END IF;
END
\$\$;
SQL
EOF
          ]
        }
      }
    }

    backoff_limit = 4
  }

  depends_on = [ kubernetes_manifest.ferret_database ]
}
