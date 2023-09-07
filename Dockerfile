# Base image
FROM ghcr.io/huggingface/text-generation-inference:latest
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory
WORKDIR /

# Update and upgrade the system packages (Worker Template)
COPY builder/setup.sh /setup.sh
RUN /bin/bash /setup.sh && \
    rm /setup.sh

# Install Python dependencies (Worker Template)
COPY builder/requirements.txt /requirements.txt
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --upgrade -r /requirements.txt --no-cache-dir && \
    rm /requirements.txt

# Add src files (Worker Template)
ADD src .

# Prepare the models inside the docker image
ARG HUGGING_FACE_HUB_TOKEN=
ENV HUGGING_FACE_HUB_TOKEN=$HUGGING_FACE_HUB_TOKEN

# Whether to download the model into /runpod-volume or not.
ARG DOWNLOAD_MODEL=
ENV DOWNLOAD_MODEL=$DOWNLOAD_MODEL

# Set environment variables
ARG HF_MODEL_ID=
ENV HF_MODEL_ID=$HF_MODEL_ID

ARG HF_MODEL_REVISION=
ENV HF_MODEL_REVISION=$HF_MODEL_REVISION

ARG SM_NUM_GPUS=
ENV SM_NUM_GPUS=$SM_NUM_GPUS

ARG HF_MODEL_QUANTIZE=
ENV HF_MODEL_QUANTIZE=$HF_MODEL_QUANTIZE

ARG HF_MODEL_TRUST_REMOTE_CODE=
ENV HF_MODEL_TRUST_REMOTE_CODE=$HF_MODEL_TRUST_REMOTE_CODE

ARG MODEL_BASE_PATH="/runpod-volume/"
ENV MODEL_BASE_PATH=$MODEL_BASE_PATH

ARG HUGGING_FACE_HUB_TOKEN=
ENV HUGGING_FACE_HUB_TOKEN=$HUGGING_FACE_HUB_TOKEN

# Prepare the hugging face directories for caching datasets, models, and more.
ENV HF_DATASETS_CACHE="/runpod-volume/huggingface-cache/datasets"
ENV HUGGINGFACE_HUB_CACHE="/runpod-volume/huggingface-cache/hub"
ENV TRANSFORMERS_CACHE="/runpod-volume/huggingface-cache/hub"

# Run the Python script to download the model only if DOWNLOAD_MODEL is equal to 1
RUN if [ "$DOWNLOAD_MODEL" = "1" ]; then \
    python -u /download_model.py; \
  fi

# COPY src/server.py /opt/conda/lib/python3.9/site-packages/text_generation_server/server.py 

# Quick temporary updates
RUN pip install git+https://github.com/runpod/runpod-python@a2#egg=runpod --compile

# Start the TGI service in the background via nohup
# RUN HF_MODEL_ID=HF_MODEL_ID HF_MODEL_REVISION=HF_MODEL_REVISION SM_NUM_GPUS=SM_NUM_GPUS HF_MODEL_QUANTIZE=HF_MODEL_QUANTIZE HF_MODEL_TRUST_REMOTE_CODE=HF_MODEL_TRUST_REMOTE_CODE MODEL_BASE_PATH=MODEL_BASE_PATH HUGGING_FACE_HUB_TOKEN=HUGGING_FACE_HUB_TOKEN nohup text-generation-launcher --port 8080 &

# Start the handler
# CMD python3 -u /handler.py

ENTRYPOINT ["./entrypoint.sh"]
CMD sleep infinity
