# syntax=docker/dockerfile:1
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Copy over the NVIDIA HPC SDK (PGI)
COPY nvhpc_2023_237_Linux_x86_64_cuda_multi.tar.gz /opt/nvidia/
RUN cd /opt/nvidia && \
    tar -xzf nvhpc_2023_237_Linux_x86_64_cuda_multi.tar.gz

# Install basic tools and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    build-essential \
    ca-certificates \
    zlib1g-dev \
    python3.9 \
    python3.9-venv \
    python3.9-distutils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install NVIDIA HPC SDK (PGI)
RUN cd /opt/nvidia/nvhpc_2023_237_Linux_x86_64_cuda_multi && \
    ./install -accept-license -default && \
    rm /opt/nvidia/nvhpc_2023_237_Linux_x86_64_cuda_multi.tar.gz

# Install Poetry
ENV POETRY_HOME="/opt/poetry"
ENV PATH="$POETRY_HOME/bin:$PATH"
RUN curl -sSL https://install.python-poetry.org | python3.9 -

# Set PGI compiler environment
ENV NVHPC=/opt/nvidia/hpc_sdk
ENV PATH=$NVHPC/Linux_x86_64/23.7/compilers/bin:$PATH
ENV PGPATH=$NVHPC/Linux_x86_64/23.7/compilers/bin
ENV LD_LIBRARY_PATH=$NVHPC/Linux_x86_64/23.7/compilers/lib:$LD_LIBRARY_PATH

WORKDIR /release
ENTRYPOINT ["./make_release.sh"]
CMD []