
# Table of Contents
1. [LLAMA and LLMs](#llama)
2. [Quantization](#quantization)
3. [llama.cpp](#llamacpp)
   - [GGML](#ggml-georgi-gerganov-machine-learning)
   - [GGUF](#gguf-gpt-generated-unified-format)
4. [Supported Quantization Methods](#Supported-Quantization-Methods)
   - [Perplexity](#Perplexity)
5. [Recommendations](#Recommendations)
6. [Grouped Query Attention GQA](#Grouped-Query-Attention-GQA)

# Llama
![image](https://github.com/user-attachments/assets/af7512a6-3834-45f7-aa52-2fcb8e902950)

Llama is an Open Source Large Language Model released by Meta. It’s a chat model from 7 to 70 billions parameters (llama could go up to 400B) trained on a massive dataset of text from the internet.
# Quantization: 
Quantization involves reducing the precision of a model's weights and activations from floating-point numbers to integers, beneficial for deploying models on resource-limited devices to enhance computational efficiency and reduce memory usage.

**The Two Types of LLM Quantization: PTQ and QAT**
- **Post-Training Quantization (PTQ)**: Faster less training data with reduced accuracy from lost precision in the value of the weights. 
- **Quantization-Aware Training (QAT)**: fine-tuning on data with quantization in mind by integrating weight convertion, during the training stage. 
   
**What are Scaling Factors?**

Scaling factors are multipliers used to map low-precision quantized values (like 4-bit integers) back to their original floating-point range.
They ensure that quantized values approximate the original floating-point weights as closely as possible, reducing the accuracy loss during quantization.
- Example: A weight value `w` is stored as a `4-bit` integer `q`, and its approximation is calculated as:
  ```bash
  w  ≈ q × s
  ```
 Where `s` is the scaling factor.

 **Difference Between Q4_0 and Q4_1 Scaling:**
- `Q4_0`: One scaling factor per block of weights. To approximate the original floating-point precision of these weights
- `Q4_1`: Two scaling factors per block—one for most weights and an additional one for outliers.

- Below is a representation of acuracy loss from 32bit to 16bits Bfloat16
<p align="center">
  <img src="https://github.com/user-attachments/assets/8d64447a-41ca-474d-8ef8-9e35c85a9121" alt="streamlit" width="400"/>
</p>

**Fixed-Point Quantization:**
- is a quantization where the values are scaled to integers and interpreted as fixed-point numbers.
- Efficient for integer-only inference (e.g., in embedded systems).

**Key Differences**
| Aspect            | Q4_0/Q4_1                | INT8                        | Fixed-Point              |
|------------------|------------------------|-----------------------------|--------------------------|
| **Precision**    | 4 bits                  | 8 bits                      | Depends on fixed-point size |
| **Scaling Factors** | Per block (Q4_1 has two) | Per layer or tensor         | Fixed scaling, predefined |
| **Accuracy**     | Lower                   | Higher                       | Lower                     |
| **Memory Use**   | Very low (4 bits)       | Moderate (8 bits)            | Moderate                   |
| **Use Case**     | Extreme compression     | General-purpose quantization | Embedded systems           |


```
formula for scaling Factor 8int(8bits) : is taking the max value of the weight matrix and divide it by max 8bit positive value [127]
The new quantized value of each matrix value = round (value  x scaling factor)
  
```
<p align="center">
  <img src="https://github.com/user-attachments/assets/aee5874a-4699-452f-9a26-9496caffa7ce" alt="streamlit" width="300"/>
</p>

**Zero Point in Quantization?**

A zero point is a value used in asymmetric quantization to map floating-point numbers into integer values while preserving the range and scale. It allows quantized values to represent both positive and negative numbers using unsigned integers (e.g., INT8).

**INT8 quantized models** use zero points to represent signed numbers. 
- while floating-point values also include negative numbers. The zero point helps shift the quantized values so that zero in the floating-point range aligns with a specific integer (the middle of the dynamic range).

- Int8 Quantization Formula (With Zero Point)
```
q=round(x/s +z)
```
- `q` → Quantized integer value (e.g., INT8)
- `x` → Original floating-point value
- `s` → Scaling factor (determines how much precision is lost)
- `z` → Zero point (integer offset that aligns 0 in floating-point with an integer value)

If a model’s floating-point range is `[-2.5, 2.5]`, and we map it to an 8-bit integer (`0-255`):
- Scaling factor (s): `0.02`
- Zero point (z): `128` (aligns 0 in floating-point with the INT8 range)
- For a value x = `-2.5` :
```yaml
𝑞  = (−2.5 /0.02 )+ 128 = 0
-- same for 2.5  =>  (2.5/0.02)+128=0
```
# Model Quantization Naming Convention:
Quantization methods are denoted by  **"Q[Number]_K_Size"**.
- `"Q[Number]"` represents the bit depth of quantization.
- `"K"` signifies K-Quants or knowledge distillation.
- `"Size"` indicates the size of the model, with `"S"` for small, `"M"` for medium, and `"L"` for large.

# llama.cpp:
The `llama.cpp` is a C++ library for efficient inference of (LLMs) performing custom quantization approach to compress the models in a **GGUF format** developed by[ Georgi Gerganov](https://github.com/ggerganov).
- This reduces the size and resources needed.
- many inference engines (`ollama/vllm`) use `llama.cpp` under the hood to enable on-device LLM
- `llama.cpp` readz models saved in the `.GGML` or `.GGUF` format and enables them to run on CPU devices or GPUs. 
- Serving as a port of meta's LLaMA model, `llama.cpp` extends accessibility to a broader audience.
- allow `CPU+GPU` hybrid inference to accelerate models larger than total VRAM capacity.
- Various quantization options (`1.5-bit` to `8-bit` integer) for faster inference and reduced memory usage.
- Support for AVX, AVX2, and AVX512 instructions for x86 architectures.

# GGML (Georgi Gerganov Machine learning)
GGML is a C Tensor library designed for deploying (LLMs) on consumer hardware with effective CPU inferencing capabilities.
- ggml is similar to ML libraries such as PyTorch and TensorFlow
- It supports various quantization strategies (e.g., `4-bit`, `5-bit`, and `8-bit` quantization) to balance efficiency and performance.
- GGML offers a Python binding called C Transformers, which simplifies inferencing by providing a high-level API and eliminates boilerplate code.
- These community-supported libraries enable quick prototyping and experimentation with quantized LLMs and are worth considering for organizations exploring self-hosted LLM solutions.

# GGML format
GGML is also the binary file format used to store these quantized models, often referred to as the "GGML format" which is a binary format for distributing LLMs. It contains all necessary information to load a model. 

# GGUF (GPT-Generated Unified Format):
GGUF is a file format designed for efficient storage and fast LLM inference, Introduced as a successor to GGML format.
- GGUF encapsulates all necessary components for inference, including the `tokenizer` and `code`, within a single file.
- Adds support for the conversion of **non-Llama** models.
- Additionally, it facilitates model quantization to lower precisions to improve speed and memory efficiency on CPUs.

**GGUF advantages over GGML:**
- better tokenization, and support for special tokens. It is also supports metadata, and is designed to be extensible.
- Provides a powerful quantization format for faster inference on CPUs, seamless GPU acceleration, and enhanced future-proofing(new HW) for LLM development.
- Consolidates all metadata within a single file, streamlining LLM usage and ensuring long-term compatibility with new features without disrupting existing models.
- Enables CPU-based inference with optional GPU acceleration.

**Relation:**
- `llama.cpp` exclusively supports **GGUF**, discontinuing support for GGML.
- `llama.cpp` relies on **GGUF** as the primary file format for storing models, ensuring compatibility with newer features and optimizations while maintaining efficient model deployment on various hardware configurations.

# Supported Quantization Methods
We often write “GGUF quantization” but GGUF itself is only a file format, not a quantization method. 
- `llama.cpp` suport several quantization algorithms to reduce model size and serialize the resulting model in the GGUF format.
# Integer Quants (Q4_0, Q4_1, Q8_0):
  -   Basic and fast quantization methods.
  - Each layer is split into blocks, and weights are quantized with additional constants

# K-Quants (Q3_K_S, Q5_K_M, ...):
K qants were Introduced in llama.cpp PR [#1684](https://github.com/ggerganov/llama.cpp/pull/1684).
- It uses different bit widths depending on the chosen quant method. 
- Bits allocated more intelligently compared to legacy/interger quants.
- `Q4_K` The [weights](https://github.com/ggerganov/llama.cpp/pull/1684) superblocks of 8 blocks of 32 weights: with each block having one scaling factor based on the max weight value
- 1 scaling factor per block and an extra scaling factor per superblock:for outliers
- Supports different quantization types and sizes, offering lower quantization error.
- the most important weights are quantized to a higher-precision data type, while the rest are assigned to a lower-precision type.
   -  For example, the q2_k quant method converts the largest weights to 4-bit integers and the remaining weights to 2-bit. 

**New K-Quant Methods:**
- `GGML_TYPE_Q2_K`: 2-bit quantization with intelligent allocation of bits.
- `GGML_TYPE_Q3_K`: 3-bit quantization with improved quantization techniques.
- `GGML_TYPE_Q4_K`: 4-bit quantization with optimized block structures. result in 4.5 bitperweight.
- `GGML_TYPE_Q5_K`: 5-bit quantization for increased precision.
- `GGML_TYPE_Q6_K`: 6-bit quantization with advanced features.
- `GGML_TYPE_Q8_K`: 8-bit quantization for intermediate results with efficient dot product implementations.

These new methods offer a range of quantization options with varying levels of precision and efficiency, providing flexibility in model deployment and optimization.

# Perplexity
Intuitively, perplexity means to be **surprised**. We measure how much the model is surprised by seeing new data. 

The lower🔽 the perplexity, the better👍🏻 the training is.
- Perplexity is usually used only to determine how well a model has learned the training set.
- Lower perplexity indicates that the model is more certain about its predictions.
- In comparison, higher perplexity suggests the model is more uncertain.
- Perplexity is a crucial metric for evaluating the performance of LLMs in tasks like machine translation, speech recognition, and text generation.

**K-Quant Performance Summary:**

The following table summarizes the performance results (perplexity, model size, run time for single token prediction) based on `llama.cpp` team's evaluation:
| Model | Measure              | F16    | Q2_K   | Q3_K_S | Q3_K_M | Q3_K_L | Q4_K_S | Q4_K_M | Q5_K_S | Q5_K_M | Q6_K   |
|-------|----------------------|--------|--------|--------|--------|--------|--------|--------|--------|--------|--------|
| 7B    | perplexity           | 5.9066 | 6.7764 | 6.4571 | 6.1503 | 6.0869 | 6.0215 | 5.9601 | 5.9419 | 5.9208 | 5.9110 |
| 7B    | file size            | 13.0G  | 2.67G  | 2.75G  | 3.06G  | 3.35G  | 3.56G  | 3.80G  | 4.33G  | 4.45G  | 5.15G  |
| 7B    | ms/tok@4th, M2 Max   | 116    | 56     | 81     | 69     | 76     | 50     | 55     | 70     | 71     | 75     |
| 7B    | ms/tok@8th, M2 Max   | 111    | 36     | 46     | 36     | 46     | 36     | 40     | 44     | 46     | 51     |
| 7B    | ms/tok@4th, RTX-4080 | 60     | 15.5   | 18.6   | 17.0   | 17.7   | 15.5   | 16.0   | 16.7   | 16.9   | 18.3   |
| 7B    | ms/tok@4th, Ryzen7950X | 214   | 57     | 58     | 61     | 67     | 68     | 71     | 81     | 82     | 93     |


**Perplexity Increase Relative to Unquantized:**
| Model | Measure              | F16    | Q2_K   | Q3_K_M | Q4_K_S | Q5_K_S | Q6_K   |
|-------|----------------------|--------|--------|--------|--------|--------|--------|
| 7B    | perplexity           | 5.9066 | 6.7764 | 6.1503 | 6.0215 | 5.9419 | 5.9110 |
| 7B    | file size            | 13.0G  | 2.67G  | 3.06G  | 3.56G  | 4.33G  | 5.15G  |
| 7B    | ms/tok @ 4th, M2 Max | 116    | 56     | 69     | 50     | 70     | 75     |
| 7B    | ms/tok @ 8th, M2 Max | 111    | 36     | 36     | 36     | 44     | 51     |
| 7B    | ms/tok @ 4th, RTX-4080 | 60    | 15.5   | 17.0   | 15.5   | 16.7   | 18.3   |
| 7B    | ms/tok @ 4th, Ryzen  | 214    | 57     | 61     | 68     | 81     | 93     |



# Recommendations:
`k` models are k-quant models and generally have less perplexity loss relative to size.
- `Q4_K_M`, `Q5_K_S`, and `Q5_K_M` are considered "recommended" due to their balanced quality and relatively low perplexity increase.
- `Q2_K` shows extreme quality loss and is not recommended.
- `Q3_K_S` and `Q3_K_M` have high-quality loss but can be suitable for very small models.
- `K8_0` has virtually no quality loss but results in extremely large file sizes and is not recommended.
- `k_s` models for whatever reason are a little slower than k_m models (size  probably matters). 
- `q4_K_M` model will have much less perplexity loss than a q4_0 or even a q4_1 model.

**GGUF Models size:**
 - llama 3 GGuf QuantFactory/Meta-Llama-3-8B-Instruct-GGUF => Meta-Llama-3-8B-Instruct.Q3_K_S.gguf[3.67 GB]

# Grouped Query Attention GQA 
![image](https://github.com/user-attachments/assets/64692e25-8560-49c9-9fe0-52ab928127bf)

 Grouped Query Attention is primarily used during inference, not training. It simplifies how LLMs understand large amounts of text by bundling similar pieces/queries together into a single operation , optimizing computation/Memory overhead by
- Reducing redundancy and enhancing efficiency during attention calculation.
- This makes the model faster and smarter, as it can focus on groups of words at a time instead of each word individually, achieving high-quality results with reduced computational complexity and memory usage.
- GQA is employed in many ML libraries like `llama.cpp` , **HuggingFace** transformers (custom models), Vllm , llama models,  

**Quality**: Achieves a quality close to multi-head attention (MHA) by balancing between multi-query attention (MQA) and MHA.
**Speed**: Maintains a speed comparable to MQA, faster than MHA, by using an intermediate number of key-value heads.
# MOE VS MLA
![image](https://github.com/user-attachments/assets/5734164f-f9a3-4d0f-a7bc-93bb173ac5ac)

# Reference

- [Quantization guide for LLMs](https://symbl.ai/developers/blog/a-guide-to-quantization-in-llms/)
- [the_difference_between_quantization_methods](https://www.reddit.com/r/LocalLLaMA/comments/159nrh5/the_difference_between_quantization_methods_for/)
- [llama.cpp](https://github.com/ggerganov/llama.cpp/discussions/2094)
- [overview_of_gguf_quantization_methods](https://www.reddit.com/r/LocalLLaMA/comments/1ba55rj/overview_of_gguf_quantization_methods/)
- [my_head_is_spinning_with_all_the_quantization](https://www.reddit.com/r/LocalLLaMA/comments/143ozbn/my_head_is_spinning_with_all_the_quantization/)
- [gguf-quantization-with-imatrix-and-k-quantization-to-run-llms-on-your-cpu](https://towardsdatascience.com/gguf-quantization-with-imatrix-and-k-quantization-to-run-llms-on-your-cpu-02356b531926)
- [GPTQ 4bit quantization explanation](https://www.youtube.com/watch?v=mii-xFaPCrA&t=5s)

 ![image](https://github.com/user-attachments/assets/e872b259-bb9d-468c-879d-5a6d380a0c22)

