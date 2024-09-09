![image](https://github.com/user-attachments/assets/69f1b794-aebf-4382-90ab-a75fa2b71933)

This Community Chart is for deploying [Ollama](https://github.com/ollama/ollama). 

## Requirements

- Kubernetes: `>= 1.16.0-0` for **CPU only**
- Kubernetes: `>= 1.26.0-0` for **GPU** stable support (NVIDIA and AMD)

*Not all GPUs are currently supported with ollama (especially with AMD)*

## Deploying Ollama chart

To install the `ollama` chart in the `ollama` namespace:

```console
helm repo add ollama-helm https://otwld.github.io/ollama-helm/
helm repo update
helm install ollama ollama-helm/ollama --namespace ollama --create-namespace --values ollama_values.yml
```

## Upgrading Ollama chart

First please read the [release notes](https://github.com/ollama/ollama/releases) of Ollama to make sure there are no backwards incompatible changes.

Make adjustments to your values as needed, then run `helm upgrade`:

```console
# -- This pulls the latest version of the ollama chart from the repo.
helm repo update
helm upgrade ollama ollama-helm/ollama --namespace ollama --values values.yaml
```

## Uninstalling Ollama chart

To uninstall/delete the `ollama` deployment in the `ollama` namespace:

```console
helm delete/uninstall ollama --namespace ollama
```
 See `helm delete --help` for a full reference on `delete` parameters and flags.


## Interact with Ollama

-  Ollama documentation can be found [HERE](https://github.com/ollama/ollama/tree/main/docs) 
- Interact with RESTful API: [Ollama API](https://github.com/ollama/ollama/blob/main/docs/api.md) 
- Interact with official clients libraries: [ollama-js](https://github.com/ollama/ollama-js#custom-client) and [ollama-python](https://github.com/ollama/ollama-python#custom-client)
- Interact with langchain: [langchain-js](https://github.com/ollama/ollama/blob/main/docs/tutorials/langchainjs.md) and [langchain-python](https://github.com/ollama/ollama/blob/main/docs/tutorials/langchainpy.md)


# check the ollama environment variables:
```
kubectl get pods -n ollama
NAME                      READY   STATUS    RESTARTS   AGE
ollama-7b8bcf4fdc-jgppl   1/1     Running   0          7m1s
kubectl exec -it ollama-7b8bcf4fdc-jgppl -n ollama -c ollama -- /bin/bash
... check predefined environment variables
root@ollama-7b8bcf4fdc-jgppl:/# set | grep OLLAMA
OLLAMA_HOST=0.0.0.0
OLLAMA_KEEP_ALIVE=-1
OLLAMA_PORT=tcp://10.96.36.99:11434
OLLAMA_PORT_11434_TCP=tcp://10.96.36.99:11434
OLLAMA_PORT_11434_TCP_ADDR=10.96.36.99
OLLAMA_PORT_11434_TCP_PORT=11434
OLLAMA_PORT_11434_TCP_PROTO=tcp
OLLAMA_SERVICE_HOST=10.96.36.99
OLLAMA_SERVICE_PORT=11434
OLLAMA_SERVICE_PORT_HTTP=11434
```

## Examples
It's highly recommended to run an updated version of Kubernetes for deploying ollama with GPU

**Basic `values.yaml` example with GPU and two models pulled at startup**
```
ollama:
  gpu:
    # -- Enable GPU integration
    enabled: true
    
    # -- GPU type: 'nvidia' or 'amd'
    type: 'nvidia'
    
    # -- Specify the number of GPU to 1
    number: 1
   
  # -- List of models to pull at container startup
  models: 
    - mistral
    - llama2
```
---
### Basic values.yaml example with Ingress
```
ollama:
  models:
    - llama2
  
ingress:
  enabled: true
    hosts:
    - host: ollama.domain.lan
      paths:
        - path: /
          pathType: Prefix
```

- *API is now reachable at `ollama.domain.lan`*

# Downloa top watch tool
```
git clone --depth 1 https://github.com/cjbassi/gotop /tmp/gotop
/tmp/gotop/scripts/download.sh
```
# node selector

```bash
kubectl label nodes 10.20.12.155 role=ollama
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
          - ollama
```
or
```yaml
nodeSelector:
  role: ollama
```
## Helm Values

- See [values.yaml](https://github.com/otwld/ollama-helm/blob/main/values.yaml) to see the Chart's default values.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity for pod assignment |
| autoscaling.enabled | bool | `false` | Enable autoscaling |
| autoscaling.maxReplicas | int | `100` | Number of maximum replicas |
| autoscaling.minReplicas | int | `1` | Number of minimum replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | CPU usage to target replica |
| extraArgs | list | `[]` | Additional arguments on the output Deployment definition. |
| extraEnv | list | `[]` | Additional environments variables on the output Deployment definition. |
| fullnameOverride | string | `""` | String to fully override template |
| hostIPC | bool | `false` | Use the host’s ipc namespace. |
| hostNetwork | bool | `false` | Use the host's network namespace. |
| hostPID | bool | `false` | Use the host’s pid namespace |
| image.pullPolicy | string | `"IfNotPresent"` | Docker pull policy |
| image.repository | string | `"ollama/ollama"` | Docker image registry |
| image.tag | string | `""` | Docker image tag, overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Docker registry secret names as an array |
| ingress.annotations | object | `{}` | Additional annotations for the Ingress resource. |
| ingress.className | string | `""` | IngressClass that will be used to implement the Ingress (Kubernetes 1.18+) |
| ingress.enabled | bool | `false` | Enable ingress controller resource |
| ingress.hosts[0].host | string | `"ollama.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.tls | list | `[]` | The tls configuration for hostnames to be covered with this ingress record. |
| initContainers | list | `[]` | Init containers to add to the pod |
| knative.containerConcurrency | int | `0` | Knative service container concurrency |
| knative.enabled | bool | `false` | Enable Knative integration |
| knative.idleTimeoutSeconds | int | `300` | Knative service idle timeout seconds |
| knative.responseStartTimeoutSeconds | int | `300` | Knative service response start timeout seconds |
| knative.timeoutSeconds | int | `300` | Knative service timeout seconds |
| livenessProbe.enabled | bool | `true` | Enable livenessProbe |
| livenessProbe.failureThreshold | int | `6` | Failure threshold for livenessProbe |
| livenessProbe.initialDelaySeconds | int | `60` | Initial delay seconds for livenessProbe |
| livenessProbe.path | string | `"/"` | Request path for livenessProbe |
| livenessProbe.periodSeconds | int | `10` | Period seconds for livenessProbe |
| livenessProbe.successThreshold | int | `1` | Success threshold for livenessProbe |
| livenessProbe.timeoutSeconds | int | `5` | Timeout seconds for livenessProbe |
| nameOverride | string | `""` | String to partially override template  (will maintain the release name) |
| nodeSelector | object | `{}` | Node labels for pod assignment. |
| ollama.gpu.enabled | bool | `false` | Enable GPU integration |
| ollama.gpu.number | int | `1` | Specify the number of GPU |
| ollama.gpu.nvidiaResource | string | `"nvidia.com/gpu"` | only for nvidia cards; change to (example) 'nvidia.com/mig-1g.10gb' to use MIG slice |
| ollama.gpu.type | string | `"nvidia"` | GPU type: 'nvidia' or 'amd' If 'ollama.gpu.enabled', default value is nvidia If set to 'amd', this will add 'rocm' suffix to image tag if 'image.tag' is not override This is due cause AMD and CPU/CUDA are different images |
| ollama.insecure | bool | `false` | Add insecure flag for pulling at container startup |
| ollama.models | list | `[]` | List of models to pull at container startup The more you add, the longer the container will take to start if models are not present models:  - llama2  - mistral |
| ollama.mountPath | string | `""` | Override ollama-data volume mount path, default: "/root/.ollama" |
| persistentVolume.accessModes | list | `["ReadWriteOnce"]` | Ollama server data Persistent Volume access modes Must match those of existing PV or dynamic provisioner Ref: http://kubernetes.io/docs/user-guide/persistent-volumes/ |
| persistentVolume.annotations | object | `{}` | Ollama server data Persistent Volume annotations |
| persistentVolume.enabled | bool | `false` | Enable persistence using PVC |
| persistentVolume.existingClaim | string | `""` | If you'd like to bring your own PVC for persisting Ollama state, pass the name of the created + ready PVC here. If set, this Chart will not create the default PVC. Requires server.persistentVolume.enabled: true |
| persistentVolume.size | string | `"30Gi"` | Ollama server data Persistent Volume size |
| persistentVolume.storageClass | string | `""` | Ollama server data Persistent Volume Storage Class If defined, storageClassName: <storageClass> If set to "-", storageClassName: "", which disables dynamic provisioning If undefined (the default) or set to null, no storageClassName spec is set, choosing the default provisioner.  (gp2 on AWS, standard on GKE, AWS & OpenStack) |
| persistentVolume.subPath | string | `""` | Subdirectory of Ollama server data Persistent Volume to mount Useful if the volume's root directory is not empty |
| persistentVolume.volumeMode | string | `""` | Ollama server data Persistent Volume Binding Mode If defined, volumeMode: <volumeMode> If empty (the default) or set to null, no volumeBindingMode spec is set, choosing the default mode. |
| persistentVolume.volumeName | string | `""` | Ollama server Persistent Volume name; can be used to force-attach the created PVC to a specific PV. |
| podAnnotations | object | `{}` | Map of annotations to add to the pods |
| podLabels | object | `{}` | Map of labels to add to the pods |
| podSecurityContext | object | `{}` | Pod Security Context |
| readinessProbe.enabled | bool | `true` | Enable readinessProbe |
| readinessProbe.failureThreshold | int | `6` | Failure threshold for readinessProbe |
| readinessProbe.initialDelaySeconds | int | `30` | Initial delay seconds for readinessProbe |
| readinessProbe.path | string | `"/"` | Request path for readinessProbe |
| readinessProbe.periodSeconds | int | `5` | Period seconds for readinessProbe |
| readinessProbe.successThreshold | int | `1` | Success threshold for readinessProbe |
| readinessProbe.timeoutSeconds | int | `3` | Timeout seconds for readinessProbe |
| replicaCount | int | `1` | Number of replicas |
| resources.limits | object | `{}` | Pod limit |
| resources.requests | object | `{}` | Pod requests |
| runtimeClassName | string | `""` | Specify runtime class |
| securityContext | object | `{}` | Container Security Context |
| service.annotations | object | `{}` | Annotations to add to the service |
| service.nodePort | int | `31434` | Service node port when service type is 'NodePort' |
| service.port | int | `11434` | Service port |
| service.type | string | `"ClusterIP"` | Service type |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials? |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | Tolerations for pod assignment |
| topologySpreadConstraints | object | `{}` | Topology Spread Constraints for pod assignment |
| updateStrategy | object | `{"type":""}` | How to replace existing pods |
| updateStrategy.type | string | `""` | Can be "Recreate" or "RollingUpdate". Default is RollingUpdate |
| volumeMounts | list | `[]` | Additional volumeMounts on the output Deployment definition. |
| volumes | list | `[]` | Additional volumes on the output Deployment definition. |
----------------------------------------------

## Persistant Storage (PVC)

If you don't have a storage class defined in your Kubernetes cluster, 
- You can manually create a PV and PVC, and reference that PVC in your Helm chart.
- This requires manual management but allows to work without relying on dynamic storage provisioning.

1. **Use an Existing Persistent Volume (PV):**

  - **Manually Provision a PV**: You can manually create a Persistent Volume (PV) that matches the specifications of your Persistent Volume Claim (PVC) in the Helm chart.

 - **Specify the PV in `*.existingClaim`:** Once you have a PV, you can create a PVC that binds to this PV and then specify that PVC in the `persistentVolume.existingClaim` field of your Helm values file.

2. **Create a PV Without a Storage Class:**

 - You can create a PV without specifying a storage class. where the PV won't automatically bind to any PVC unless you match it explicitly by name.
 - You would then need to create a PVC that matches the PV's specifications (size, access modes) and specify this PVC in `persistentVolume.existingClaim`.

3. **Set storageClass to `"-"`:**

- By setting `persistentVolume.storageClass`: "-", you tell Kubernetes that the PVC should not use dynamic provisioning. 
- This means Kubernetes will not automatically create a PV, and you must manually create one that the PVC can bind to.


## LOAD THE MODELS VIA INIT CONTAINERS
add this in the values 

```yaml
initContainers:
  - name: install-and-setup-model
    image: python:3.9  # Use an image with Python and pip pre-installed
    command: [sh, -c]
    args:
      - |
        pip install huggingface-cli;
        huggingface-cli download bartowski/Meta-Llama-3.1-8B-Instruct-GGUF Meta-Llama-3.1-8B-Instruct-Q4_K_S.gguf \
          --local-dir /root/.ollama/download \
          --local-dir-use-symlinks False;
        cat <<'EOF' > /root/.ollama/download/llama3.loc
        # Set the base model
        FROM /root/.ollama/download/Meta-Llama-3.1-8B-Instruct-Q4_K_S.gguf
        # Set custom parameter values
        PARAMETER temperature 1.0
        PARAMETER stop "<|start_header_id|>"
        PARAMETER stop "<|end_header_id|>"
        PARAMETER stop "<|eot_id|>"

        # Define the model template
        TEMPLATE """
        {{- if or .System .Tools }}<|start_header_id|>system<|end_header_id|>
        {{- if .System }}
        {{ .System }}
        {{- end }}
        {{- if .Tools }}
        Cutting Knowledge Date: December 2023
        When you receive a tool call response, use the output to format an answer to the original user question.
        You are a helpful assistant with tool calling capabilities.
        {{- end }}
        {{- end }}<|eot_id|>
        {{- range $i, $_ := .Messages }}
        {{- $last := eq (len (slice $.Messages $i)) 1 }}
        {{- if eq .Role "user" }}<|start_header_id|>user<|end_header_id|>
        {{- if and $.Tools $last }}

        Given following functions, please respond with a JSON for a function call with its proper arguments that best
 answers  the given prompt.
Respond in the format {"name": function name, "parameters": dictionary of argument name and its value}.
Do not use variables.

        {{ range $.Tools }}
        {{- . }}
        {{ end }}
        {{- end }}
        {{ .Content }}<|eot_id|>{{ if $last }}<|start_header_id|>assistant<|end_header_id|>
        {{ end }}
        {{- else if eq .Role "assistant" }}<|start_header_id|>assistant<|end_header_id|>
        {{- if .ToolCalls }}
        {{- range .ToolCalls }}{"name": "{{ .Function.Name }}", "parameters": {{ .Function.Arguments }}}{{ end }}
        {{- else }}
        {{ .Content }}{{ if not $last }}<|eot_id|>{{ end }}
        {{- end }}
        {{- else if eq .Role "tool" }}<|start_header_id|>ipython<|end_header_id|>
        {{ .Content }}<|eot_id|>{{ if $last }}<|start_header_id|>assistant<|end_header_id|>
        {{ end }}
        {{- end }}
        {{- end }}
        """
        # Set the system message
        SYSTEM You are a helpful AI assistant named e-llmo Assistant.
        EOF

        ollama create llama3 -f /root/.ollama/download/llama3.loc;
    volumeMounts:
      - name: ollama-storage
        mountPath: /root/.ollama  # Ensure this matches your mountPath 
```

# Interaction Between mountPath and Other Components 

1. **`ollama.mountPath`:**

- **Purpose**: This is where Ollama expects to find its data, such as models, configurations, and other necessary files.
- **Default Value**: The default value is `/root/.ollama`
- **Relation to volumeMounts**: Must match the mountPath specified in the `volumeMounts` section of your yaml pod config to ensure that data  is available at the correct location.

2. **`volumes` and `volumeMounts`:**

- **Purpose**: These define where PVC data will be available inside the container.
- **Relation to `ollama.mountPath`**:
The mountPath in `volumeMounts` must match the `ollama.mountPath` so that Ollama can correctly access the files it needs from the PVC.


# RAG
**Embedding**
```bash
--- Download embedding model
huggingface-cli download nomic-ai/nomic-embed-text-v1-GGUF nomic-embed-text-v1.f16.gguf \
    --local-dir /root/.ollama/download \
    --local-dir-use-symlinks False;

    -- or nomic-embed-text-v1.f16.gguf
        
2--- Edit modelfile      
cat << EOF > nomic-embed.loc
# Set the base model
FROM /root/.ollama/download/nomic-embed-text-v1.f16.gguf
PARAMETER num_ctx 8192 
EOF       

3--- create model
    ollama create nomic-embed-v1 -f /root/.ollama/download/nomic-embed.loc
```



# Example Without a Storage Class
Here’s a quick rundown of how you could proceed:

Create a PV:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ollama-pv
spec:
  capacity:
    storage: 15Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/data/ollama
```
This example uses a hostPath, which is useful for testing but not recommended for production.

Create a PVC:

```yaml 
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ollama-pvc
spec:
  volumeName: ollama-pv
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 15Gi
```      
Reference the Existing PVC in Helm:
In your ollama_values.yaml:

```yaml 
persistentVolume:
  enabled: true
  existingClaim: "ollama-pvc"  # Reference the manually created PVC
  size: 15Gi  # Should match the size of the PV
  storageClass: "-"  # No dynamic provisioning
```
## Support
- For questions, suggestions, and discussion about Ollama please refer to the [Ollama issue page](https://github.com/ollama/ollama/issues)
- For questions, suggestions, and discussion about this chart please visit [Ollama-Helm issue page](https://github.com/otwld/ollama-helm/issues) or join our [OTWLD Discord](https://discord.gg/U24mpqTynB)
