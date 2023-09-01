# Base image
FROM ghcr.io/huggingface/text-generation-inference:latest
ENV DEBIAN_FRONTEND=noninteractive

# Update to python 3.10
RUN conda install python=3.10

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

# Download the model
RUN python3 /usr/src/server/text_generation_server/cli.py download-weights Weni/WeniGPT-L-70

COPY src/server.py /opt/conda/lib/python3.9/site-packages/text_generation_server/server.py 

# Quick temporary updates
RUN pip install git+https://github.com/runpod/runpod-python@a2#egg=runpod --compile

# Start the handler
CMD python3 -u /handler.py
