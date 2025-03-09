# -------------- CLUSTER ISSUER VARIABLES -------------- #
variable "cluster_issuer_name" {
  description = "Name of the Self Signed Cluster Issuer"
  type        = string
  default     = "private-cluster-issuer"
}
