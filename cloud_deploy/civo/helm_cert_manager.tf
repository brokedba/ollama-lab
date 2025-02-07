resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true" # Install Custom Resource Definitions
  }

  set {
    name  = "global.leaderElection.namespace"
    value = "cert-manager"
  }


  # Optional: Pin the version if necessary
  # version = "v1.16.3"
}

#############################
# Self-signed ClusterIssuer #
#############################

#  Define a ClusterIssuer for cert-manager to generate self-signed certificates

resource "kubectl_manifest" "self_signed_cluster_issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: self-signed-cluster-issuer
spec:
  selfSigned: {}
YAML
depends_on = [helm_release.cert_manager]
}


# resource "kubernetes_manifest" "self_signed_cluster_issuer" {
#   depends_on = [helm_release.cert_manager]

#   manifest = {
#     apiVersion = "cert-manager.io/v1"
#     kind       = "ClusterIssuer"
#     metadata = {
#       name = "self-signed-cluster-issuer"
#     }
#     spec = {
#       selfSigned = {}
#     }
#   }
# }




###############################
#    Open-web-ui certificat   #
###############################
# Add Certificate resource will reference the selfsigned-clusterissuer 
# and create the openwebui-tls-secret

resource "kubectl_manifest" "openwebui_certificate" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: openwebui-tls
  namespace: open-webui
spec:
  secretName: openwebui-tls-secret
  issuerRef:
    name: self-signed-cluster-issuer
    kind: ClusterIssuer
  dnsNames:
    - "${data.external.openwebui_ingress.result.hostname}"
YAML
# - ${data.civo_kubernetes_cluster.cluster.dns_entry}
  depends_on = [kubectl_manifest.self_signed_cluster_issuer,kubernetes_namespace.webui_ns]
}
# - "${data.kubernetes_ingress.openwebui_ingress.status.0.load_balancer.0.ingress.0.hostname}"

# resource "kubernetes_manifest" "openwebui_certificate" {
#   manifest = {
#     apiVersion = "cert-manager.io/v1"
#     kind       = "Certificate"
#     metadata = {
#       name      = "openwebui-tls"
#       namespace = "open-webui"
#     }
#     spec = {
#       secretName = "openwebui-tls-secret"
#       issuerRef = {
#         name = "self-signed-cluster-issuer"
#         kind = "ClusterIssuer"
#       }
#       dnsNames = ["placeholder.local"]
#       ipAddresses = ["127.0.0.1"]
#       # dnsNames = [
#       #   # Access the first item in the ingress list
#       # try(
#       #     data.kubernetes_ingress.open_webui_ingress.status[0].loadBalancer.ingress.0.hostname,
#       #     "placeholder.local"
#       #   )
#       # ]
#       # ipAddresses = [
#       #   # Access the first item in the ingress list
#       #   try(
#       #     data.kubernetes_ingress.open_webui_ingress.status[0].loadBalancer.ingress.0.ip,
#       #     "127.0.0.1"
#       #   )
#       # ]
#     }
#   }

#   depends_on = [kubernetes_manifest.self_signed_cluster_issuer, helm_release.cert_manager, helm_release.open_webui]
# }


# Namespace: Matches the namespace of the open-webui Helm release (open-webui). 
# secretName: Generates secret openwebui-tls-secret automatically, which is used by the ingress for TLS.
# issuerRef: Points to the selfsigned-clusterissuer created earlier.
# dnsNames and ipAddresses: Dynamically fetch the hostname and IP of the load balancer associated with the open-webui ingres
# commands to check open-webui ingress and its hostname and IP 
# kubectl get ingress open-webui -n open-webui -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
# kubectl get ingress open-webui -n open-webui -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
# kubectl describe ingress open-webui -n open-webui
# command to check secret the issuer and openwebui-tls-secret:
#      1. kubectl describe clusterissuer selfsigned-clusterissuer
#      2. kubectl get secret openwebui-tls-secret -n open-webui
#      3. kubectl describe certificate openwebui-tls -n open-webui

# The Certificate resource will create the openwebui-tls-secret in the open-webui namespace, which is used by the ingress to secure the connection.
# The Certificate resource will reference the selfsigned-clusterissuer to generate the self-signed certificate.
# The Certificate resource will use the hostname and IP of the open-webui ingress to generate the certificate.
# The Certificate resource will depend on the cert-manager Helm release and the open-webui Helm release.