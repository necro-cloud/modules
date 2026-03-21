output "deployment_summary" {
  value       = <<EOT

  ${local.bold}${local.green}🚀 Necronizer's Cloud Deployment is Complete!${local.reset}
  
  ${local.bold}🌐 Service Access URLs:${local.reset}
  --------------------------------------------------
  ${local.cyan}Vault:${local.reset}         https://secrets.${var.domain}
  ${local.cyan}Monitoring:${local.reset}    https://observability.${var.domain}
  ${local.cyan}PostgreSQL:${local.reset}    https://sql.${var.domain}
  ${local.cyan}NoSQL/Mongo:${local.reset}   https://nosql.${var.domain}
  ${local.cyan}Identity:${local.reset}      https://auth.${var.domain}
  --------------------------------------------------

  ${local.bold}${local.yellow}🔐 Security & Credentials:${local.reset}
  
  To access these services, you need to retrieve your credentials from OpenBao.
  
  1️⃣  ${local.bold}Extract your Root Token:${local.reset}
      kubectl get secret bao-init-recovery -n openbao -o jsonpath='{.data.keys\.json}' | base64 -d | jq -r '.root_token'
  
  2️⃣  ${local.bold}Find Your Passwords:${local.reset}
      Log in to the UI and navigate to:
      ${local.blue}secret/{SERVICE}/credentials/ui/*${local.reset}

  ${local.bold}Note:${local.reset} If you just scaled or recreated the cluster, wait a moment for the 
  Raft storage to sync (${local.cyan}vault_raft_storage_stats_applied_index${local.reset}) before 
  fetching secrets.

EOT
}
