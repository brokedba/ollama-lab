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
#**Final Output preview**#
```hcl
Apply complete! Resources: 14 added, 0 changed, 0 destroyed.
Outputs:
cluster_installed_applications = tolist([])
kubernetes_cluster_endpoint = "https://212.2.111.111:6443"
kubernetes_cluster_id = "d19dd60f-111-111-1111-529c8a1a5299"
kubernetes_cluster_name = "cloudthrill-cluster"
kubernetes_cluster_ready = true
kubernetes_cluster_status = "ACTIVE"
kubernetes_cluster_version = "talos-v1.5.0"
loadbalancer_dns = {
  "hostname" = "https://random-50a0-4ade-af55-9b253d0b5c8b.lb.civo.com" <---  use this link to log in 
}
master_ip = "212.2.111.111"
network_id = "33161f60-ed86-4f45-903b-94b7959fc991"
```
- Once you click on the loadbalancer dns link you will have the below page:
![image](https://github.com/user-attachments/assets/9367e8db-8888-4b10-8768-13e3cfc737ca)


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
