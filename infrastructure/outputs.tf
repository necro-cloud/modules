output "deployment_summary" {
  value       = <<EOT

  Necronizer's Cloud Deployment is Complete!
  
  Service Access URLs:
  --------------------------------------------------
  Vault:         https://secrets.${var.domain}
  Monitoring:    https://observability.${var.domain}
  PostgreSQL:    https://sql.${var.domain}
  NoSQL/Mongo:   https://nosql.${var.domain}
  Identity:      https://auth.${var.domain}
  --------------------------------------------------

  Security & Credentials:
  
  To access these services, you need to retrieve your credentials from OpenBao.
  
  1. Extract your Root Token:
     kubectl get secret bao-init-recovery -n openbao -o jsonpath='{.data.keys\.json}' | base64 -d | jq -r '.root_token'
  
  2. Find Your Passwords:
     Log in to the UI and navigate to:
     secret/{SERVICE}/credentials/ui/*

  Note: If you just scaled or recreated the cluster, wait a moment for the 
  Raft storage to sync.
EOT
}
