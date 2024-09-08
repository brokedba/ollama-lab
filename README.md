# ollama_lab
Deploy your Local LLM Web App in Kubernetes using Ollama and OpenWebUI 
![logo](image.png)
# Table of Contents
1. [OLLAMA and LLMs](#ollama)
2. [Designing the Chatbot](#designing-the-chatbot)
3. [Streamlit](#streamlit)
   - [Integrating Ollama with Streamlit](#integrating-ollama-with-streamlit)
   - [OCI OKE Use Case](#oci-oke-use-case)
9. [Multimodal Vision Language Models](#multimodal-vision-language-models)
10. [Vision Models (GGUF)](#vision-models-gguf)

# OLLAMA:

Get up and running with large language models.
[ ollama.com]([ollama.com/](https://ollama.com/))

**Donwload and Install**
- [Windows](https://ollama.com/download/OllamaSetup.exe)
- **Linux**
```
curl -fsSL https://ollama.com/install.sh | sh

wsl.exe --install --no-distribution
wsl  --set-version Ubuntu-18.04 2
```
https://ollama.com/search?q=&p=1

1. **Models:**
```
llama2-uncensored
llama2
codellama    => debug code
mistral
llava        => multi modal / images vision transformer
bakllava
```
georgesung/llama2_7b_chat_uncensored

**CAN MY MACHINE RUN LLM ?**
go to this HF portal and check: [can-it-run-llm](https://huggingface.co/spaces/Vokturz/can-it-run-llm)
```
ollama -h
commands : 
Available Commands:
  serve       Start ollama
  create      Create a model from a Modelfile
  show        Show information for a model
  run         Run a model
  pull        Pull a model from a registry
  push        Push a model to a registry
  list        List models
  cp          Copy a model
  rm          Remove a model
  help        Help about any command
```
3. Ollama Commands
- Start Ollama Server
```
ollama serve
```
- Run Ollama Model 
```
ollama run llama2-uncensored
```
- Download Ollama Model
 ```
ollama pull llama2-uncensored
```
- List Installed Ollama Models
```
ollama list
```
- Delete Installed Ollama Models
 ```
ollama rm llama2-uncensored
```



----------------------
**HuggingFace and vs ollama** 
 - Hf takes the weights and ollama uses a model which includes weights and system prompt and template etc.

1. **Where are models stored?**
- macOS : `~/.ollama/models.`
- Linux : `/usr/share/ollama/.ollama/models.`
- Windows : `C:\Users\%username%\.ollama\models.`
2. **VRAM PREREQ:**
> Remember that you will need a GPU with sufficient memory (VRAM) to run models with Ollama.
 You can check out a calculator HuggingFace created called "Model Memory Calculator" here model_size_estimator
 here is an article that runs you through the exact mathematical calculation for "[Calculating GPU memory for serving LLMs](https://www.substratus.ai/blog/calculating-gpu-memory-for-llm)".

3. **CPU compatible Modells:**

**llama.cpp** can run using CPU only :
  - llama.cpp. The source project for GGUF. Offers a CLI and a server option.

**How:**
  - Applies a custom quantization approach to compress the models in a GGUF format. This reduces their size and resource needs.
  
**Where** 
- Lamma3: Thanks to The [Bloke](https://huggingface.co/TheBloke), there are already pre-made models which can be used directly with the mentioned framework.
- Example: [Llama-2-7B-Chat-GGUF](https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGUF/tree/main) 
   - smallest => [llama-2–7b-chat.Q2_K.gguf](https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGUF/tree/main#:~:text=llama%2D2%2D7b%2Dchat.Q2_K.gguf) which is the most compressed version of the 7B chat model and requires the least resources.

- llama3.1: GGUF models are also available thanks to accounts like [Bartowski](https://huggingface.co/bartowski) with his [Meta-Llama-3.1-8B-Instruct-GGUF](https://huggingface.co/bartowski/Meta-Llama-3.1-8B-Instruct-GGUF) model  
 
 
# Designing the Chatbot: 
- Guidelines on designing the chatbot's functionality, including understanding user inputs, generating responses, and handling different types of conversations.


**Test using docker**

1. Install python
- ```
  pip install llama-cpp-python
  pip install llama-cpp-python --extra-index-url https://abetlen.github.io/llama-cpp-python/whl/cpu
  pip-versions  latest llama-cpp-python
  ```
2. Create a python script  `llama_cpu.py` to query the API 

```
from llama_cpp import Llama

# Put the location of to the GGUF model that you've download from HuggingFace here
model_path = "**path to your llama-2–7b-chat.Q2_K.gguf**"

# Create a llama model
model = Llama(model_path=model_path)

# Prompt creation
system_message = "You are a helpful assistant"
user_message = "Generate a list of 5 funny dog names"

prompt = f"""<s>[INST] <<SYS>>
{system_message}
<</SYS>>
{user_message} [/INST]"""

# Model parameters
max_tokens = 100

# Run the model
output = model(prompt, max_tokens=max_tokens, echo=True)

# Print the model output
print(output)
```
3. Run the script:
- ```python llama_cpu.py```
![demo](1_cVGBBifDFCOJTW0H8BQ0xA.gif)

# Pull HugginFace GGUF MODELS Manually using Ollama
1. Donwload model using HF CLI:
[QuantFactory/Meta-Llama-3-8B-Instruct-GGUF](https://huggingface.co/QuantFactory/Meta-Llama-3-8B-Instruct-GGUF): [Meta-Llama-3-8B-Instruct.Q3_K_S.gguf-3.67GB](https://huggingface.co/QuantFactory/Meta-Llama-3-8B-Instruct-GGUF/blob/main/Meta-Llama-3-8B-Instruct.Q3_K_S.gguf)

```
--- install cli
 pip install huggingface-hub
 pip install --upgrade huggingface_hub 

--- download model

huggingface-cli download \
  QuantFactory/Meta-Llama-3-8B-Instruct-GGUF Meta-Llama-3-8B-Instruct.Q3_K_S.gguf \
  --local-dir ai_models  --local-dir-use-symlinks False
 ```

 2. Create llama<*>.loc modelfile 
**lamma3.loc**
```
# set the base model 
FROM ./ai_models/Meta-Llama-3-8B-Instruct.Q3_K_S.gguf

# Set custom paramter values
PARAMETER temperature 1

PARAMETER stop <|start_header_id|>
PARAMETER stop <|end_header_id|>
PARAMETER stop <|eot_id|>
PARAMETER stop <|reserved_special_token

# Set the model template
TEMPLATE """
{{ if .System }}<|start_header_id|>system<|end_header_id|>
{{ .System }}<|eot_id|>{{ end }}{{ if .Prompt }}<|start_header_id|>user<|end_header_id|>
{{ .Prompt }}<|eot_id|>{{ end }}<|start_header_id|>assistant<|end_header_id|>
{{ .Response }}<|eot_id|>
"""

# Set the system message
SYSTEM You are a helpful AI assistant named Llama3 Droid
```

 3. We then build an Ollama model using the following command:
```
ollama create llama2 -f llama2.loc
ollama create llama3 -f llama3.loc
---
    transferring model data
    using existing layer sha256:774ba422eeac30b2390e72960694b35eba746acd82785b2d644c92716ed479bb
    creating new layer sha256:549c786ef375489a2379ecfe1d244fde24c5ab78b9398a9343375556fffc6a14
    creating new layer sha256:0d6f8e890c228c44821390929a20714ca1990ac586ca2abf9e78ac907d33d173
    creating new layer sha256:319eccebdb61c018484f30aa1f24c381dff9843888b02daef9d1795a4f27cbad
    creating new layer sha256:b2d73007e6a1f6485fb56a0e73a6ede58416132abff6de29c00791425ebb71c8
    writing manifest
    success
    
> ollama list
NAME            ID              SIZE    MODIFIED
ollama3:latest  37773b35f97c    3.7 GB  7 seconds ago
```
 4. And now let’s see if we can get the model to tell us all about Famous king of Pop:
 ```
   ollama run ollama2 "Who is Michael jackson?"
  --- Use Ctrl + d or /bye to exit.
 ```

**lamma31.loc**

1. donwload
```
huggingface-cli download bartowski/Meta-Llama-3.1-8B-Instruct-GGUF Meta-Llama-3.1-8B-Instruct-Q4_K_S.gguf \
  --local-dir ai_models \
  --local-dir-use-symlinks False
 ```
2. modelfile
```
# set the base model 
FROM ./ai_models/Meta-Llama-3.1-8B-Instruct-Q4_K_S.gguf
# Set custom parameter values
PARAMETER temperature 1.0
PARAMETER stop <|start_header_id|>
PARAMETER stop <|end_header_id|>
PARAMETER stop <|eot_id|>

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

Given the following functions, please respond with a JSON for a function call with its proper arguments that best answers
the given prompt.

Respond in the format {"name": function name, "parameters": dictionary of argument name and its value}. Do not use variables.
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
SYSTEM You are a helpful AI assistant named e-llmo Assistant
```
3. load te model in ollama
 ```
 ollama create llama3.1 -f llama31.loc
 ```

![streamlit](image-2.png)

# Streamlit
Streamlit is a popular Python library that makes it easy to create and deploy web applications for machine learning and data science projects. It's widely used for its simplicity in turning Python scripts into interactive web apps.

**install** 
- ```pip install llama-cpp-python streamlit```
# Integrating Ollama with Streamlit:
Detailed steps on how to integrate the chatbot model or framework (Ollama) into a Streamlit web application, including handling user inputs from the web interface and displaying responses.

**Description**
- `ollama_chatbot.py` uses Streamlit to create a web-based chat interface with the Ollama language models.
-  The `config.py` sets up the configuration for the **app**, including available models and page title,
-  the `requirements.txt` specifies the Python dependencies needed.
- the `helpers/llm_helper.py` module defines the logic for interacting with the Ollama models and parsing the streamed responses.
  
- **Chatbot Features**:

   - a. Ability to select different Ollama models to be used by the chatbot
   - b. Streaming output when responding to users like ChatGPT

**Step 1: Prepare the Dockerfile**

Create a Dockerfile in the root directory of your application with the following content:

```
# Use an official Python runtime as a parent image
FROM python:3.8

# Set the working directory in the container to /app
WORKDIR /app

# Copy the requirements.txt file and install Python dependencies
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application files and folders into the container at /app
COPY . /app

# Expose the port Streamlit will run on
EXPOSE 8501

# If ollama runs on a different port, expose it as well
# EXPOSE <ollama_port>
EXPOSE 11434

# Start the Ollama model server and the Streamlit app
#CMD ["streamlit", "run", "ollama_chatbot.py"]
CMD ollama serve & streamlit run ollama_chatbot.py
```
> Note: You might want to consider using a process manager like supervisord to handle multiple processes in a container more robustly.

**Step 2: Build the Docker Image**
 - Run the following command in the same directory as your Dockerfile to build your Docker image:

```
docker build -t streamlit-ollama-chatbot .
```

**Step 3: Run the Docker Container:**
 - Once the image is built, you can run your container:
  ```
  docker run -p 8501:8501 -p 11434:11434 streamlit-ollama-chatbot
  ```
 - This command starts the streamlit-ollama-chatbot container, maps the local port the container's `8501`, and runs your web app.



# OCI OKE Use Case:

# Streamlit-Ollama-Chatbot on OCI

This guide walks you through the process of containerizing the Streamlit-Ollama-Chatbot, pushing the Docker image to Oracle Container Registry, and deploying it to a Kubernetes cluster.

**Step 1: Create Docker Image with the Model preloaded**

2 options :  
- Either include the model in your Docker image.
- Or add the model download task to the `Dockerfile` (during the build process).

**Step 2: Build the Docker Image**

Execute the following command in your project directory to build your Docker image:

```
docker build -t your-username/streamlit-ollama-chatbot:latest .
```

**Step 3: Log in to Oracle Container Registry**
- Use the Docker CLI to log in to the Oracle Container Registry:Enter your Oracle Cloud credentials when prompted.
  ```
  docker login container-registry.oracle.com
  ```
**Step 4: Push the Docker Image**
- After logging in, push your Docker image to the Oracle Container Registry: Ensure image name/tag match OCR repo's.
  ``` 
  docker push your-username/streamlit-ollama-chatbot:latest
  ```
**Step 5: Deploy to OCI Kubernetes engine**

*Create a Kubernetes Deployment*

Write a Kubernetes manifestthat referencing the app image in the OCR.
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: streamlit-ollama-chatbot-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: streamlit-ollama-chatbot
  template:
    metadata:
      labels:
        app: streamlit-ollama-chatbot
    spec:
      containers:
      - name: streamlit-ollama-chatbot
        image: container-registry.oracle.com/your-username/streamlit-ollama-chatbot:latest
        ports:
        - containerPort: 8501 # Streamlit's port
        - containerPort: 11434 # Ollama's port, for internal communication only
```
> Streamlit app can communicate with Ollama API over `localhost:11434` within the pod, but this port won't be accessible from outside the pod. 

*Create a Kubernetes Service*
- Expose your application to the internet by creating a service of type LoadBalancer.
- If external access to the Ollama API is not required, you don't need to expose the Ollama port (11434) through the Kubernetes service. 

```yaml
apiVersion: v1
kind: Service
metadata:
  name: streamlit-ollama-chatbot-service
spec:
  selector:
    app: streamlit-ollama-chatbot
  ports:
    - protocol: TCP
      port: 80         # This is the port you'll access externally, like through a LoadBalancer
      targetPort: 8501 # This is the internal port on which Streamlit is running
  type: LoadBalancer
  ```
**Apply Your Configuration**
Apply the configuration to your Kubernetes cluster:
```
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

**Step 6: Access Your Application**
Retrieve the external IP address assigned to your service by Oracle's cloud infrastructure:
```
kubectl get service streamlit-ollama-chatbot-service
```
Access your Streamlit app in the browser via http://[external-ip].

**Oracle Cloud Infrastructure Specifics**

Ensure your oci-cli is configured correctly to manage your container registry and Kubernetes cluster.
Set the proper permissions and policies within OCI to allow your Kubernetes cluster to pull images from your container registry.
Secure sensitive data using Kubernetes secrets or a secure mechanism; never include it in your Dockerfile or image.



--------
# Multimodal Vision Language Models
**text to Image**
- [1111 DirectML](https://github.com/LykosAI/StabilityMatrix?tab=readme-ov-file)
 list see [link] (https://medium.com/ai-bytes/top-6-open-source-text-to-image-generation-models-in-2024-ee5a2fc39046)
 - DeepFloyd IF
 - Stable Diffusion v1–5
 - [OpenJourney] (https://github.com/paddleboard-ai/useful-notebooks/blob/main/LocalJourney_CPU.ipynb)
 - DreamShaper
 - Dreamlike Photoreal
 - Waifu Diffusion

# Vision Models (GGUF)
- [Llava 1.6](https://huggingface.co/cmp-nct/llava-1.6-gguf): llama.cpp now natively supported
- [Bakllava](https://huggingface.co/advanced-stack/bakllava-mistral-v1-gguf)
- ShareGPT4V
- Obsidian
- Yi-VL
