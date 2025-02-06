# 🚀 LLM Inference Deployment on Civo Cloud Talos K8s Cluster

## **Overview**
This repository provides an end-to-end solution for deploying a **local LLM (Large Language Model) inference** setup on a **Civo Cloud Talos Kubernetes Cluster**. 

The deployment includes:

- ✅ **Civo Kubernetes Cluster (Talos)**
- ✅ **Ollama LLM Server**
- ✅ **Open WebUI for model interaction**
- ✅ **Traefik as the Ingress Controller**
- ✅ **Cert-Manager for TLS (Self-Signed Certificate)**
- ✅ **Okta Authentication for Secure Access** (Optional)

---

## **1️⃣ Prerequisites**
Before you begin, ensure you have the following:

- 🛠 [Terraform](https://developer.hashicorp.com/terraform/downloads) (`>=1.5`)
- 🛠 [kubectl](https://kubernetes.io/docs/tasks/tools/) (`>=1.25`)
- 🛠 [Helm](https://helm.sh/docs/intro/install/) (`>=3.10`)
- ☁ **Civo Cloud Account** with an API key
- 🔑 **Okta Developer Account** (if enabling okta authentication)
- 💻 **Local or Cloud-Based Machine** to run the deployment

---

## **2️⃣ Setup Civo Kubernetes Cluster (Talos)**

### Use an env-vars File**
Export your **TF_VARS** i.e **Civo API Key** in the env-vars file :
```bash
export CIVO_TOKEN="your-civo-api-key"
export TF_VAR_region="NYC1"
#### [OKTA] Optional ##################
export TF_VAR_enable_okta="true"
export TF_VAR_okta_client_id="your-okta-client-id"
export TF_VAR_okta_client_secret="your-okta-client-secret"
export TF_VAR_okta_openid_provider="https://your-okta-domain/oauth2/default"
```
- Load the Variables into Your Shell Before running Terraform, source the env-vars file:
```bash
$ source env-vars
```
  
## **3️⃣ Run Terraform Now that the variables are set, run Terraform:**
```
terraform plan
terraform apply
```
# 4️⃣ Destroying the Infrastructure
To delete everything:
```
terraform destroy -auto-approve
```
# 5️⃣ Next Steps
- Add GPU Acceleration for LLM inference using nvidia drivers plugin  
- Implement Persistent Storage for Models like S3
- Optimize Autoscaling for Traffic Spikes

----
