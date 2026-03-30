# --------------------------------------------------------------------------------------- #
# ----------------- REQUIRED FUNCTIONS TO RUN THE SCRIPT FOR DEPLOYMENT ----------------- #
# --------------------------------------------------------------------------------------- #

# Function to pull in secrets from the KeePassXC Database
function get_secret () {

  # Function parameters
  local secret_name=$1
  local attribute=$2

  # Pulling in the secret from the KeePassXC Database
  secret=$(echo "$KPXC_PASSWORD" | keepassxc-cli show -k "$KPXC_LOGIN_KEY" "$KPXC_DATABASE" "$secret_name" -s -a "$attribute" 2>/dev/null)
  
  # Check if the secret was actually found
  if [ -z "$secret" ]; then
    echo "Error: Could not find $attribute in $secret_name" >&2
    return 1
  fi

  # Return the secret
  echo $secret
}

# Function to setup the TFVARS file for deployments
function setup_tfvars() {
  echo "Setting up TFVARS File using KeePassXC for deployment..."

  # Pulling all the required secrets from KeePassXC for filling up the
  # OpenTofu TFVARS File for Deployment of resources
  echo "[1/8] Loading Cloudflare Email Address for DNS Verification"
  local cloudflare_email="$(get_secret 'Cloudflare Token' 'username')"
  
  echo "[2/8] Loading Cloudflare Token for DNS Verification"
  local cloudflare_token="$(get_secret 'Cloudflare Token' 'password')"
  
  echo "[3/8] Loading Domain to be used for DNS"
  local domain="$(get_secret 'Domain' 'url')"

  echo "[4/8] Loading SMTP URL to be used for SMTP Settings"
  local smtp_host="$(get_secret 'SMTP Settings' 'url')"

  echo "[5/8] Loading SMTP Port to be used for SMTP Settings"
  local smtp_port="$(get_secret 'SMTP Settings' 'port')"

  echo "[6/8] Loading SMTP Email to be used for SMTP Settings"
  local smtp_mail="$(get_secret 'SMTP Settings' 'email')"

  echo "[7/8] Loading SMTP Username to be used for SMTP Settings"
  local smtp_username="$(get_secret 'SMTP Settings' 'username')"

  echo "[8/8] Loading SMTP Password to be used for SMTP Settings"
  local smtp_password="$(get_secret 'SMTP Settings' 'password')"

  # Using JQ for populating the entries in the JSON file
  jq -n \
    --arg cloudflare_email "$cloudflare_email" \
    --arg cloudflare_token "$cloudflare_token" \
    --arg domain "$domain" \
    --arg smtp_host "$smtp_host" \
    --argjson smtp_port "$smtp_port" \
    --arg smtp_mail "$smtp_mail" \
    --arg smtp_username "$smtp_username" \
    --arg smtp_password "$smtp_password" \
    '{
      "cloudflare_email": $cloudflare_email,
      "cloudflare_token": $cloudflare_token,
      "domain": $domain,
      "smtp_host": $smtp_host,
      "smtp_port": $smtp_port,
      "smtp_mail": $smtp_mail,
      "smtp_username": $smtp_username,
      "smtp_password": $smtp_password
    }' > terraform.tfvars.json  
  
  echo "TFVARS File has been setup using KeePassXC for deployment"
}

# Function to shred TFVARS file after deployment is completed
function shred_tfvars() {
  echo "Shredding TFVARS File after deployment..."
  shred -u -n 3 -f terraform.tfvars.json 2>/dev/null
  echo "Shredded TFVARS File after deployment!"
}

# Function for core tofu functions to execute
function tofu_execute() {

  local command="$1"

  # Setting up some variables for initialization
  export KUBECONFIG="$HOME/.kube/config"
  export KUBECONFIG_FOLDER="$HOME/.kube"
  export KUBE_CONFIG_PATH="$HOME/.kube/config"

  # Setting up the TFVARS file
  if setup_tfvars; then

    # Executing the command here
    echo "Command being run: $command"
    eval "$command"
    local tofucode=$?

    # Shredding the TFVARS file after use
    shred_tfvars
    # Cleaning up environment variables
    unset KUBECONFIG KUBECONFIG_FOLDER KUBE_CONFIG_PATH

    
    return $tofucode
  else
    echo "ERROR: Could not setup TFVARS file hence failing execution"
    # Cleaning up environment variables
    unset KUBECONFIG KUBECONFIG_FOLDER KUBE_CONFIG_PATH

    return 1
  fi

}

# -------------------------------------------------------- #
# ----------------- ACTUAL SCRIPT STARTS ----------------- #
# -------------------------------------------------------- #

# Check if env file exists
# to communicate with KeePassXC
# for required secrets
if [ -f "kpxc.env" ]; then
    source kpxc.env
else
    echo "Error: kpxc.env file missing." >&2
    exit 1
fi

# Sanity checking for required environment variables
if [[ -z "$KPXC_PASSWORD" || -z "$KPXC_DATABASE" || -z "$KPXC_LOGIN_KEY" ]]; then
    echo "Error: One or more KPXC environment variables are empty in kpxc.env" >&2
    exit 1
fi

# Executing action passed to the script
# ACTUAL INPUT OF THE SCRIPT
ACTION=$1
case "$ACTION" in
    "initialize")
        tofu_execute "tofu init && tofu apply --target=module.helm"
        ;;
    "plan")
        tofu_execute "tofu plan"
        ;;
    "apply")
        tofu_execute "tofu apply"
        ;;
    "destroy")
        tofu_execute "tofu destroy"
        ;;
    "initialize-apply")
        tofu_execute "tofu init && tofu apply --target=module.helm && tofu apply"
        ;;
    "cleanup")
        shred_tfvars
        ;;
    "full-cleanup")
        shred_tfvars
        rm -rf .terraform*
        ;;
    *)
        echo "Usage: $0 {initialize|plan|apply|destroy|initialize-apply}"
        exit 1
        ;;
esac

# Cleanup environment variables when done
unset KPXC_PASSWORD KPXC_DATABASE KPXC_LOGIN_KEY
