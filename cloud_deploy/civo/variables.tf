################################################################################
# CIVO Provider Variables
################################################################################
variable "region" {
  type        = string
  default     = "NYC1"
  description = "The region to provision the cluster against"
}

################################################################################
# Cluster 
################################################################################
variable "cluster_type" {
  type        = string
  description = "The type of Kubernetes cluster to create"
  default     = "talos"
}
# Please ensure your version matches the expected format, e.g., 'talos-vX.Y.Z'.
#│ Available versions for 'talos': - Stable: [talos-v1.5.0]
variable "kubernetes_version" {
  type        = string
  description = "The version of Kubernetes to use"
  default     = "talos-v1.5.0" # talos= talos-v1.5.0  k3s= 1.28.7-k3s1
}
variable "cluster_name_prefix" {
  description = "Prefix to append to the name of the cluster being created"
  type        = string
  default     = "cloudthrill-"
}
variable "label" {
  description = "Node pool label. If not provided, a default label will be generated."
  type        = string
  default     = "llama-pool"
}

variable "cluster_node_size" {
  type        = string
  default     = ""
  description = "The size of the nodes to provision. Run `civo size list` for all options"
}

variable "cluster_node_count" {
  description = "Number of nodes in the default pool"
  type        = number
  default     = 2
    validation {
    condition     = var.cluster_node_count >= 1
    error_message = "The node_count must be at least 1."
  }
}

variable "node_pool_labels" {
  description = "Additional labels for the node pool."
  type        = map(string)
  default     = {}
}

variable "taints" {
  description = "A list of taints to apply to the nodes in the node pool."
  default = [
    {
    key    = "ollama-workload"
    value  = "frontend"
    effect = "NoSchedule"
    }
  ]
}
variable "applications" {
  description = "Comma Separated list of Application to be installed"
  type        = string
  default     = "metrics-server,cert-manager,traefik2-nodeport" #  metrics-server,cert-manager,-traefik2-loadbalancer" 
}
################################################################################
# Variables: CIVO Networking
###############################################################################
variable "network_name" {
  description = "The name of the network"
  type        = string
  default     = "default"
}
variable "network_cidr" {
  type        = string
  default     = "10.20.0.0/16"
  description = "The CIDR block for the network"
}

variable "cni" {
  type        = string
  description = "The cni for the k3s to install"
  default     = "flannel" #"cilium"
}
# Firewall Access
variable "kubernetes_api_access" {
  description = "List of Subnets allowed to access the Kube API"
  type        = list(any)
  default     = ["0.0.0.0/0"]
}

variable "cluster_web_access" {
  description = "List of Subnets allowed to access port 80 via the Load Balancer"
  type        = list(any)
  default     = ["0.0.0.0/0"]
}

variable "cluster_websecure_access" {
  description = "List of Subnets allowed to access port 443 via the Load Balancer"
  type        = list(any)
  default     = ["0.0.0.0/0"]
}

variable "object_store_enabled" {
  description = "Should an object store be configured"
  type = bool
  default = false
}

variable "object_store_size" {
  description = "Size of the Object Store to create (multiples of 500)"
  type        = number
  default     = 500
}

variable "object_store_prefix" {
  description = "Prefix to append to the name of the object store being created"
  type        = string
  default     = "tf-template-"
}

variable "tags" {
  type        = string
  description = "Tags"
  default     = "terraform"
}

###################################
#   OKTA AUthentication Variables  #
####################################
variable "enable_okta" {
  type        = bool
  default     = false
  description = "Enable Okta authentication"
}
variable "okta_client_id" {
  description = "The Okta Client ID for OpenID integration"
  type        = string
  default     = null # Default to null to allow sourcing from environment variables
   sensitive = true
}

variable "okta_client_secret" {
  description = "The Okta Client Secret for OpenID integration"
  type        = string
  default     = null # Default to null to allow sourcing from environment variables
  sensitive   = true

}

variable "okta_openid_provider" {
  description = "The Okta OpenID Provider URL"
  type        = string
  default     = null
  sensitive   = true
}