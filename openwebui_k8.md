# open-webui ![Version: 3.1.9](https://img.shields.io/badge/Version-3.1.8-informational?style=flat-square) 

**Open WebUI** is an [extensible](https://github.com/open-webui/pipelines), feature-rich, and user-friendly self-hosted WebUI designed to operate entirely offline. It supports various LLM runners, including Ollama and OpenAI-compatible APIs. 

![Open WebUI Demo](https://github.com/open-webui/open-webui/blob/main/demo.gif)

## Resources 
See **[Homepage](https://www.openwebui.com)**   and **[doc](https://docs.openwebui.com/)**
* <https://github.com/open-webui/helm-charts>
* <https://github.com/open-webui/open-webui/pkgs/container/open-webui>
* <https://github.com/otwld/ollama-helm/>
* <https://hub.docker.com/r/ollama/ollama>

# Alternative Installation of Ollama & Open WebUI (kustomize)
- For cpu-only pod
```
git clone https://github.com/open-webui/open-webui.git
cd ./open-webui
kubectl apply -f ./kubernetes/manifest/base
```
- For gpu-enabled pod
```
kubectl apply -k ./kubernetes/manifest
```
# Open WebUI Helm Charts
The charts are hosted at https://helm.openwebui.com. 
## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://helm.openwebui.com | pipelines | >=0.0.1 |
| https://otwld.github.io/ollama-helm/ | ollama | >=0.24.0 |
# Installing Both Ollama and Open WebUI Using Helm​
**INFO**
The new github repo is  https://github.com/open-webui/helm-charts

## Installing

- You can add the : `open-webui` Helm repo  to [Helm](https://helm.sh)  with 

```shell
helm repo add open-webui https://helm.openwebui.com/
helm repo update
```

- Now you can install the chart:

```shell
helm upgrade --install open-webui open-webui/open-webui --namespace open-webui --create-namespace --values openwebui_values.yml
```
- Check the [kubernetes/helm/values.yaml](https://github.com/open-webui/helm-charts/blob/main/charts/open-webui/values.yaml) file to know more values are available for customization


# Monitoring tool install
```
git clone --depth 1 https://github.com/cjbassi/gotop /tmp/gotop
/tmp/gotop/scripts/download.sh
```
# Node selector

```bash
kubectl label nodes 10.20.15.69 role=openwebui
```
2. Update Helm Values with Node Affinity or Node Selector:
For Ollama (ollama_values_simple.yml):
```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: role
          operator: In
          values:
          - openwebui
```
or
```yaml
nodeSelector:
  role: openwebui
```

# create a Docker Hub credential secret
```
kubectl create secret docker-registry my-dockerhub-secret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=klouddude \
  --docker-password=<password> \
  --docker-email=kouss.hd@gmail.com  -n ollama
```
## helm Values

- See [values.yaml](https://github.com/open-webui/helm-charts/blob/main/charts/open-webui/values.yaml) to see the Chart's default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for pod assignment |
| annotations | object | `{}` |  |
| clusterDomain | string | `"cluster.local"` | Value of cluster domain |
| containerSecurityContext | object | `{}` | Configure container security context ref: <https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-containe> |
| extraEnvVars | list | `[{"name":"OPENAI_API_KEY","value":"0p3n-w3bu!"}]` | Additional environments variables on the output Deployment definition. Most up-to-date environment variables can be found here: https://docs.openwebui.com/getting-started/env-configuration/ |
| extraEnvVars[0] | object | `{"name":"OPENAI_API_KEY","value":"0p3n-w3bu!"}` | Default API key value for Pipelines. Should be updated in a production deployment, or be changed to the required API key if not using Pipelines |
| image | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/open-webui/open-webui","tag":"latest"}` | Open WebUI image tags can be found here: https://github.com/open-webui/open-webui/pkgs/container/open-webui |
| imagePullSecrets | list | `[]` | Configure imagePullSecrets to use private registry ref: <https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry> |
| ingress.annotations | object | `{}` | Use appropriate annotations for your Ingress controller, e.g., for NGINX: nginx.ingress.kubernetes.io/rewrite-target: / |
| ingress.class | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.existingSecret | string | `""` |  |
| ingress.host | string | `""` |  |
| ingress.tls | bool | `false` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` | Node labels for pod assignment. |
| ollama.enabled | bool | `true` | Automatically install Ollama Helm chart from https://otwld.github.io/ollama-helm/. Use [Helm Values](https://github.com/otwld/ollama-helm/#helm-values) to configure |
| ollama.fullnameOverride | string | `"open-webui-ollama"` | If enabling embedded Ollama, update fullnameOverride to your desired Ollama name value, or else it will use the default ollama.name value from the Ollama chart |
| ollamaUrls | list | `[]` | A list of Ollama API endpoints. These can be added in lieu of automatically installing the Ollama Helm chart, or in addition to it. |
| openaiBaseApiUrl | string | `""` | OpenAI base API URL to use. Defaults to the Pipelines service endpoint when Pipelines are enabled, and "https://api.openai.com/v1" if Pipelines are not enabled and this value is blank |
| persistence.accessModes | list | `["ReadWriteOnce"]` | If using multiple replicas, you must update accessModes to ReadWriteMany |
| persistence.annotations | object | `{}` |  |
| persistence.enabled | bool | `true` |  |
| persistence.existingClaim | string | `""` | Use existingClaim if you want to re-use an existing Open WebUI PVC instead of creating a new one |
| persistence.selector | object | `{}` |  |
| persistence.size | string | `"2Gi"` |  |
| persistence.storageClass | string | `""` |  |
| pipelines.enabled | bool | `true` | Automatically install Pipelines chart to extend Open WebUI functionality using Pipelines: https://github.com/open-webui/pipelines |
| pipelines.extraEnvVars | list | `[]` | This section can be used to pass required environment variables to your pipelines (e.g. Langfuse hostname) |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` | Configure pod security context ref: <https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-containe> |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| service | object | `{"annotations":{},"containerPort":8080,"labels":{},"loadBalancerClass":"","nodePort":"","port":80,"type":"ClusterIP"}` | Service values to expose Open WebUI pods to cluster |
| tolerations | list | `[]` | Tolerations for pod assignment |
| topologySpreadConstraints | list | `[]` | Topology Spread Constraints for pod assignment |

----------------------------------------------
## TLS (Self signed)

**Step 1**: Generate a Private Key using RSA
```bash
openssl genpkey -algorithm RSA -out tls.key -pkeyopt rsa_keygen_bits:2048
```
**Step 2:** Generate a CSR (Certificate Signing Request)
```bash
openssl req -new -key tls.key -out tls.csr
```

**Step 3**: Generate a Self-Signed Certificate
Signature ok
subject=C = CA, ST = ON, L = TO, O = Cloudthrill
Getting Private key
```bash
openssl x509 -req -days 365 -in tls.csr -signkey tls.key -out tls.crt
```

Or 
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=40.233.69.157" -addext "subjectAltName=IP:40.233.69.157"
```
**components**
- tls.key: Your private key
- tls.csr: Your Certificate Signing Request
- tls.crt: Your self-signed certificate


**Create a Kubernetes TLS Secret**

```bash
kubectl create secret tls openwebui-tls-secret --cert=tls.crt --key=tls.key -n open-webui
```

**Update Helm Ingress Values**
- Modify your Helm values to use this secret for TLS in your Ingress configuration:
```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  hosts:
    - host: openwebui.domain
      paths:
        - path: /
          pathType: Prefix
  tls:
    - hosts:
        - openwebui.domain
      existingSecret: "openwebui-tls-secret"  # Use the TLS secret you just created

```

## Key Features of Open WebUI ⭐

- 🚀 **Effortless Setup**: Install seamlessly using Docker or Kubernetes (kubectl, kustomize or helm) for a hassle-free experience with support for both `:ollama` and `:cuda` tagged images.

- 🤝 **Ollama/OpenAI API Integration**: Effortlessly integrate OpenAI-compatible APIs for versatile conversations alongside Ollama models. Customize the OpenAI API URL to link with **LMStudio, GroqCloud, Mistral, OpenRouter, and more**.

- 🧩 **Pipelines, Open WebUI Plugin Support**: Seamlessly integrate custom logic and Python libraries into Open WebUI using [Pipelines Plugin Framework](https://github.com/open-webui/pipelines). Launch your Pipelines instance, set the OpenAI URL to the Pipelines URL, and explore endless possibilities. [Examples](https://github.com/open-webui/pipelines/tree/main/examples) include **Function Calling**, User **Rate Limiting** to control access, **Usage Monitoring** with tools like Langfuse, **Live Translation with LibreTranslate** for multilingual support, **Toxic Message Filtering** and much more.

- 📱 **Responsive Design**: Enjoy a seamless experience across Desktop PC, Laptop, and Mobile devices.

- 📱 **Progressive Web App (PWA) for Mobile**: Enjoy a native app-like experience on your mobile device with our PWA, providing offline access on localhost and a seamless user interface.

- ✒️🔢 **Full Markdown and LaTeX Support**: Elevate your LLM experience with comprehensive Markdown and LaTeX capabilities for enriched interaction.

- 🎤📹 **Hands-Free Voice/Video Call**: Experience seamless communication with integrated hands-free voice and video call features, allowing for a more dynamic and interactive chat environment.

- 🛠️ **Model Builder**: Easily create Ollama models via the Web UI. Create and add custom characters/agents, customize chat elements, and import models effortlessly through [Open WebUI Community](https://openwebui.com/) integration.

- 🐍 **Native Python Function Calling Tool**: Enhance your LLMs with built-in code editor support in the tools workspace. Bring Your Own Function (BYOF) by simply adding your pure Python functions, enabling seamless integration with LLMs.

- 📚 **Local RAG Integration**: Dive into the future of chat interactions with groundbreaking Retrieval Augmented Generation (RAG) support. This feature seamlessly integrates document interactions into your chat experience. You can load documents directly into the chat or add files to your document library, effortlessly accessing them using the `#` command before a query.

- 🔍 **Web Search for RAG**: Perform web searches using providers like `SearXNG`, `Google PSE`, `Brave Search`, `serpstack`, `serper`, `Serply`, `DuckDuckGo` and `TavilySearch` and inject the results directly into your chat experience.

- 🌐 **Web Browsing Capability**: Seamlessly integrate websites into your chat experience using the `#` command followed by a URL. This feature allows you to incorporate web content directly into your conversations, enhancing the richness and depth of your interactions.

- 🎨 **Image Generation Integration**: Seamlessly incorporate image generation capabilities using options such as AUTOMATIC1111 API or ComfyUI (local), and OpenAI's DALL-E (external), enriching your chat experience with dynamic visual content.

- ⚙️ **Many Models Conversations**: Effortlessly engage with various models simultaneously, harnessing their unique strengths for optimal responses. Enhance your experience by leveraging a diverse set of models in parallel.

- 🔐 **Role-Based Access Control (RBAC)**: Ensure secure access with restricted permissions; only authorized individuals can access your Ollama, and exclusive model creation/pulling rights are reserved for administrators.

- 🌐🌍 **Multilingual Support**: Experience Open WebUI in your preferred language with our internationalization (i18n) support. Join us in expanding our supported languages! We're actively seeking contributors!
