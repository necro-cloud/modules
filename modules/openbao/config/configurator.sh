#!/bin/sh
set -e

# Installing required dependencies
echo "Installing required dependencies..."
apk add --no-cache curl jq

# Required Environment Variables
NAMESPACE=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
K8S_API="https://kubernetes.default.svc"
K8S_TOKEN=$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)
K8S_CACERT="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"

# OpenBao TLS Setup
BAO_ADDR="https://openbao-internal.$NAMESPACE.svc:8200"
BAO_CACERT="/openbao/userconfig/${cert_secret_name}/ca.crt"

export BAO_ADDR=$BAO_ADDR
export BAO_CACERT=$BAO_CACERT

# Wait for OpenBao API to respond over HTTPS
echo "Waiting for OpenBao API at $BAO_ADDR..."
until curl -s --cacert "$BAO_CACERT" "$BAO_ADDR/v1/sys/health" | grep -q 'initialized'; do
  echo "Still waiting..."
  sleep 5
done

# Initialize the Cluster
if ! bao operator init -status > /dev/null 2>&1; then
  echo "Initializing OpenBao Cluster..."
  bao operator init -format=json > /tmp/keys.json
  
  ROOT_TOKEN=$(jq -r '.root_token' /tmp/keys.json)
  export BAO_TOKEN=$ROOT_TOKEN

  # Save Keys to K8s Secret
  echo "Persisting recovery keys to Kubernetes..."
  B64_DATA=$(cat /tmp/keys.json | base64 | tr -d '\n')
  
  curl -s --cacert "$K8S_CACERT" \
    -X POST \
    -H "Authorization: Bearer $K8S_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"apiVersion\": \"v1\",
      \"kind\": \"Secret\",
      \"metadata\": { \"name\": \"bao-init-recovery\" },
      \"data\": { \"keys.json\": \"$B64_DATA\" }
    }" \
    "$K8S_API/api/v1/namespaces/$NAMESPACE/secrets"

  # Configure Kubernetes Auth for External Secrets Operator
  echo "Configuring Kubernetes Auth..."
  bao auth enable kubernetes
  bao write auth/kubernetes/config \
      kubernetes_host="$K8S_API" \
      kubernetes_ca_cert="@$K8S_CACERT" \
      disable_iss_validation=true

  # Setup ESO Access
  bao secrets enable -path=secret kv-v2
  bao policy write eso-policy - <<EOF
# Capabilities for the actual secret data
path "secret/data/*" { 
  capabilities = ["create", "read", "update", "delete", "list"] 
}

# Capabilities for secret metadata
path "secret/metadata/*" { 
  capabilities = ["create", "read", "update", "delete", "list"] 
}
EOF

  bao write auth/kubernetes/role/eso-role \
      bound_service_account_names="external-secrets" \
      bound_service_account_namespaces="external-secrets" \
      policies="eso-policy" \
      ttl=1h

  echo "Provisioning Complete!"
else
  echo "Cluster already initialized."
fi
