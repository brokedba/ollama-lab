resource "helm_release" "ollama" {
  name  = "ollama"

  repository = "https://otwld.github.io/ollama-helm/"
  chart      = "ollama"
  # version    = var.chart_version # Optional: pin the chart version if needed
  wait       = true

  namespace        = "ollama"
  create_namespace = true

  # Include the Helm values file
  values = [
    file("helm/ollama_values.yaml") # Ensures relative path resolution
  ]

   depends_on = [helm_release.traefik_ingress]

  # Set timeout to 15 minutes
  timeout = 900
}

#######################
#   Okta Open WebUI   #
#######################

resource "local_file" "okta_values" {
  count = var.enable_okta ? 1 : 0
  filename = "${path.module}/helm/generated_okta_values.yaml"
  content  = templatefile("${path.module}/helm/okta_env_vars.tmpl", {
    OAUTH_CLIENT_ID     = var.okta_client_id
    OAUTH_CLIENT_SECRET = var.okta_client_secret
    OPENID_PROVIDER_URL = var.okta_openid_provider
  })
 lifecycle {
    precondition {
      condition = !var.enable_okta || (
        var.okta_client_id != null && var.okta_client_id != "" &&
        var.okta_client_secret != null && var.okta_client_secret != "" &&
        var.okta_openid_provider != null && var.okta_openid_provider != ""
      )
      error_message = "Okta integration is enabled, but one or more Okta credentials (Client ID, Client Secret, OpenID Provider URL) are missing or empty."
    }
  }
}

data "local_file" "okta_values_content" {
  count = var.enable_okta ? 1 : 0
  filename = local_file.okta_values[0].filename
  # filename = local_file.okta_values.filename
}

resource "helm_release" "open_webui" {
  name = "open-webui"

  repository = "https://helm.openwebui.com/"
  chart      = "open-webui"
  # version    = var.webui_chart_version # Optional: pin the chart version if needed
  wait       = true

  namespace        = "open-webui"
  create_namespace = true
  # Include the Helm values file
  # enable_okta will define if the Okta values are included
  values =  concat(
    [file("${path.module}/helm/webui_values.yaml")],        # Base file
    var.enable_okta ? [data.local_file.okta_values_content[0].content] : []  # Dynamic Okta values
  )
 depends_on = [helm_release.ollama]
  # Set timeout to 15 minutes
  timeout = 900
}

###############
# check ingress
###############
data "external" "openwebui_ingress" {
  program = ["bash", "${path.module}/get_ingress_hostname.sh"]

  query = {
    namespace = "open-webui"
    name      = "open-webui"
  }
  depends_on = [helm_release.open_webui]
}
  
# }

 output "loadbalancer_dns" {
   value = {
     hostname = format("https://%s", data.external.openwebui_ingress.result.hostname)
   }
 }

resource "kubectl_manifest" "patched_openwebui_ingress" {
  yaml_body = <<EOT
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: open-webui
  namespace: open-webui
annotations:
  kubernetes.io/ingress.class: "traefik"
  cert-manager.io/cluster-issuer: "self-signed-cluster-issuer"
spec:
  rules:
    - host: "${data.external.openwebui_ingress.result.hostname}"
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: open-webui
                port:
                  name: http
  tls:
    - hosts:
        - "${data.external.openwebui_ingress.result.hostname}"
      secretName: openwebui-tls-secret
EOT
  depends_on = [kubectl_manifest.openwebui_certificate]
}