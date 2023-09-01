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

# Prepare argument for the model and tokenizer
ARG MODEL_NAME=""
ENV MODEL_NAME=$MODEL_NAME
ARG MODEL_REVISION="main"
ENV MODEL_REVISION=$MODEL_REVISION
ARG MODEL_BASE_PATH="/runpod-volume/"
ENV MODEL_BASE_PATH=$MODEL_BASE_PATH
ARG TOKENIZER=
ENV TOKENIZER=$TOKENIZER
ARG STREAMING=
ENV STREAMING=$STREAMING

ENV HF_DATASETS_CACHE="/runpod-volume/huggingface-cache/datasets"
ENV HUGGINGFACE_HUB_CACHE="/runpod-volume/huggingface-cache/hub"
ENV TRANSFORMERS_CACHE="/runpod-volume/huggingface-cache/hub"

# Set environment variables
ENV MODEL_NAME=$MODEL_NAME \
    MODEL_REVISION=$MODEL_REVISION \
    MODEL_BASE_PATH=$MODEL_BASE_PATH \
    HUGGING_FACE_HUB_TOKEN=$HUGGING_FACE_HUB_TOKEN

# Run the Python script to download the model
RUN python -u /download_model.py

COPY src/server.py /opt/conda/lib/python3.9/site-packages/text_generation_server/server.py 

# Quick temporary updates
RUN pip install git+https://github.com/runpod/runpod-python@a2#egg=runpod --compile

# Start the handler
CMD python3 -u /handler.py
