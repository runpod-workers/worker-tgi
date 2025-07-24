#!/bin/bash
set -e

# Set a default model if none is provided
if [[ -z "${HF_MODEL_ID}" ]]; then
  echo "HF_MODEL_ID not set, using default model: facebook/opt-125m"
  export HF_MODEL_ID="facebook/opt-125m"
fi
export MODEL_ID="${HF_MODEL_ID}"

if [[ -n "${HF_MODEL_REVISION}" ]]; then
  export REVISION="${HF_MODEL_REVISION}"
fi

if [[ -n "${SM_NUM_GPUS}" ]]; then
  export NUM_SHARD="${SM_NUM_GPUS}"
fi

if [[ -n "${HF_MODEL_QUANTIZE}" ]]; then
  export QUANTIZE="${HF_MODEL_QUANTIZE}"
fi

if [[ -n "${HF_MODEL_TRUST_REMOTE_CODE}" ]]; then
  export TRUST_REMOTE_CODE="${HF_MODEL_TRUST_REMOTE_CODE}"
fi

if [[ -n "${HF_MAX_TOTAL_TOKENS}" ]]; then
  export MAX_TOTAL_TOKENS="${HF_MAX_TOTAL_TOKENS}"
fi

if [[ -n "${HF_MAX_INPUT_LENGTH}" ]]; then
  export MAX_INPUT_LENGTH="${HF_MAX_INPUT_LENGTH}"
fi

if [[ -n "${HF_MAX_BATCH_TOTAL_TOKENS}" ]]; then
  export MAX_BATCH_TOTAL_TOKENS="${HF_MAX_BATCH_TOTAL_TOKENS}"
fi

if [[ -n "${HF_MAX_BATCH_PREFILL_TOKENS}" ]]; then
  export MAX_BATCH_PREFILL_TOKENS="${HF_MAX_BATCH_PREFILL_TOKENS}"
fi

echo "Starting text generation server with model: ${MODEL_ID}"

# Start the text generation server
nohup text-generation-launcher --port 8080 &
SERVER_PID=$!

# Wait for server to start
echo "Waiting for text generation server to start..."
sleep 10

# Check if server is running
if ! ps -p $SERVER_PID > /dev/null; then
  echo "Text generation server failed to start. Check logs."
  exit 1
fi

echo "Text generation server started successfully."

# Start the handler using python 3.10
echo "Starting handler..."
python3.10 -u /handler.py