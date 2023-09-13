<div align="center">

<h1>TGI Endpoint | Serverless Worker</h1> 

[![CI | Test Worker](https://github.com/runpod-workers/worker-template/actions/workflows/CI-test_worker.yml/badge.svg)](https://github.com/runpod-workers/worker-template/actions/workflows/CI-test_worker.yml)
&nbsp;
[![Docker Image](https://github.com/runpod-workers/worker-template/actions/workflows/CD-docker_dev.yml/badge.svg)](https://github.com/runpod-workers/worker-template/actions/workflows/CD-docker_dev.yml)

🚀 | This serverless worker utilizes vLLM (very Large Language Model) behind the scenes and is integrated into RunPod's serverless environment. It supports dynamic auto-scaling using the built-in RunPod autoscaling feature.
</div>

#### Docker Arguments:
1. `HUGGING_FACE_HUB_TOKEN`: Your private Hugging Face token. This token is essential for downloading models that require agreement to an End User License Agreement (EULA), such as the llama2 family of models.
2. `HF_MODEL_ID`: The Hugging Face model to use. Please ensure that the selected model is compatible with vLLM. Refer to the list of supported models for compatibility.
3. `DOWNLOAD_MODEL`: Indicates whether to include the model in the Docker image. If set to false, the image will need to pre-download the model to network storage using the command `text-generation-server download-weights $HF_MODEL_ID`. Make sure to set the appropriate environment variables below when downloading the model to network storage, and ensure that the network storage volume is named `/runpod-volume`.
   - Environment Variables:
     - `ENV HF_DATASETS_CACHE="/runpod-volume/huggingface-cache/datasets"`
     - `ENV HUGGINGFACE_HUB_CACHE="/runpod-volume/huggingface-cache/hub"`
     - `ENV TRANSFORMERS_CACHE="/runpod-volume/huggingface-cache/hub"`
4. `HF_MODEL_QUANTIZE`: Specifies the type of quantization algorithm to use when loading the model (e.g., gptq).
5. `SM_NUM_GPUS`: The number of GPUs to allocate for sharding the model.
6. `HF_MODEL_REVISION`: The revision branch for the Hugging Face model.

#### llama2 7B Chat, 4bit:
`docker build   --build-arg HF_MODEL_ID="TheBloke/Llama-2-7b-Chat-GPTQ"   --build-arg HF_MODEL_REVISION="main"   --build-arg SM_NUM_GPUS="1"   --build-arg HF_MODEL_QUANTIZE="gptq"   --build-arg HF_MODEL_TRUST_REMOTE_CODE="true" --build-arg HUGGING_FACE_HUB_TOKEN="your_hugging_face_token_here" --build-arg DOWNLOAD_MODEL="1" .`

#### llama2 13B Chat, 4bit:
`docker build   --build-arg HF_MODEL_ID="TheBloke/Llama-2-13b-Chat-GPTQ"   --build-arg HF_MODEL_REVISION="main"   --build-arg SM_NUM_GPUS="1"   --build-arg HF_MODEL_QUANTIZE="gptq"   --build-arg HF_MODEL_TRUST_REMOTE_CODE="true" --build-arg HUGGING_FACE_HUB_TOKEN="your_hugging_face_token_here" --build-arg DOWNLOAD_MODEL="1" .`

Please make sure to replace your_hugging_face_token_here with your actual Hugging Face token to enable model downloads that require it.

Ensure that you have Docker installed and properly set up before running the docker build commands. Once built, you can deploy this serverless worker in your desired environment with confidence that it will automatically scale based on demand. For further inquiries or assistance, feel free to contact our support team.


## Model Inputs
```markdown
| Argument            | Type                 | Default | Description                                                                                          |
|---------------------|----------------------|---------|---------------------------------------------------|
| do_sample           | bool                 | False   | Use sampling for text generation.                                                                  |
| max_new_tokens      | int                  | 20      | Max number of new tokens to generate for each prompt.                                              |
| repetition_penalty  | Optional[float]      | None    | Penalty for repeating tokens in the generated text.                                               |
| return_full_text    | bool                 | False   | Return full generated text or just the top `n` sequences.                                          |
| seed                | Optional[int]        | None    | Seed for controlling randomness in text generation.                                                |
| stop_sequences      | Optional[List[str]]  | None    | List of strings that stop text generation when encountered.                                        |
| temperature         | Optional[float]      | 1.0     | Control randomness of sampling. Lower values make it more deterministic, higher values more random. |
| top_k               | Optional[int]        | -1      | Number of top tokens to consider. Set to -1 to consider all tokens.                                |
| top_p               | Optional[float]      | 1.0     | Cumulative probability of top tokens to consider (0 < p <= 1). Set to 1 to consider all tokens.     |
| truncate            | Optional[int]        | None    | Max length of generated text (number of tokens).                                                    |
| watermark           | bool                 | False   | Add a watermark to the generated text.                                                             |
```


## Test Inputs
The following inputs can be used for testing the model:
```json
{
    "input": {
       "prompt": "Who is the president of the United States?",
       "sampling_params": {
           "max_new_tokens": 100
       }
    }
}
```
