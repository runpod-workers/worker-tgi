# Base image
FROM ghcr.io/huggingface/text-generation-inference:0.9

ENV DEBIAN_FRONTEND=noninteractive

# Use bash shell with pipefail option
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]

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
RUN python3 /usr/src/server/text_generation_server/cli.py download-weights WizardLM/WizardCoder-15B-V1.0

COPY src/server.py /opt/conda/lib/python3.9/site-packages/text_generation_server/server.py 

# Including an entrypoint
ENTRYPOINT ["/usr/bin/env"]

# CMD python3 -u /handler.py
CMD sleep infinity

#  /usr/src/server/text_generation_server