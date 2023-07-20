#!/usr/bin/env python
''' Contains the handler function that will be called by the serverless. '''

import runpod
import asyncio

# Import here after the logger is added to log potential import exceptions
from text_generation_server import server
from text_generation_server.tracing import setup_tracing
from enum import Enum


class Quantization(str, Enum):
    bitsandbytes = "bitsandbytes"
    gptq = "gptq"

class Dtype(str, Enum):
    float16 = "float16"
    bloat16 = "bfloat16"

QUANTIZE = Quantization.bitsandbytes
DTYPE = Dtype.bloat16
 
# Downgrade enum into str for easier management later on
quantize = None # None if QUANTIZE is None else QUANTIZE.value
dtype = None if DTYPE is None else DTYPE.value

if dtype is not None and quantize is not None:
    raise RuntimeError(
        "Only 1 can be set between `dtype` and `quantize`, as they both decide how goes the final model."
    )

# Serve the hugging face model with text-generation-server
MODEL_ID = 'WizardLM/WizardCoder-15B-V1.0'
REVISION = None
SHARDED = False
TRUST_REMOTE_CODE = True
UDS_PATH = "/tmp/text-generation-server"
text_generation_inference = server.serve(
    MODEL_ID, REVISION, SHARDED, quantize, dtype, TRUST_REMOTE_CODE, UDS_PATH,
)

# https://github.com/huggingface/text-generation-inference/blob/main/server/text_generation_server/server.py#L99
# We need to keep track of the size of the 'next_batch' once it approaches some number N, then we should auto-scale.
text_generation_inference['serve_inner']()


def handler_fully_utilized() -> bool:
    # Compute pending sequences
    cache_keys = text_generation_inference['cache'].cache.keys()
    return len(cache_keys) > 10


async def handler(job):
    '''
    This is the handler function that will be called by the serverless.
    '''
    # Start the server.
    if text_generation_inference['started'] == False:
        asyncio.create_task(text_generation_inference['serve_inner']())

    # Get job input
    job_input = job['input']

    # Prompts
    prompt = job_input['prompt']

    # Streaming
    streaming = job_input.get('streaming', False)

    # Validate the inputs
    sampling_params = job_input.get('sampling_params', {})

    # Hugging face has built-in validation for parameter types.
    # https://github.com/huggingface/text-generation-inference/blob/5a1512c0253e759fb07142029127292d639ab117/clients/python/text_generation/types.py#L43
    Parameters(**sampling_params)

    # Enable HTTP Streaming
    async def stream_output():
        # Streaming case
        async for response in client.generate_stream(prompt, **sampling_params):
            if not response.token.special:
                text_outputs = response.token.text
                ret = {"text": text_outputs}
                yield ret

    # Regular submission
    async def submit_output():
        # Non-streaming case
        response = await client.generate(prompt, **sampling_params).generated_text
        ret = {"outputs": response.generated_text}
        return ret

    if streaming:
        return await stream_output()
    else:
        return await submit_output()

runpod.serverless.start({"handler": handler, "handler_fully_utilized": handler_fully_utilized})

# python /usr/src/server/text_generation_server/cli.py download-weights WizardLM/WizardCoder-15B-V1.0
# python /usr/src/server/text_generation_server/cli.py serve WizardLM/WizardCoder-15B-V1.0
