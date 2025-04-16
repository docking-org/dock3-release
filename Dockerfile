# syntax=docker/dockerfile:1
FROM centos:7

# Copy over and install the NVIDIA HPC SDK (PGI)
COPY nvhpc_2023_237_Linux_x86_64_cuda_multi.tar.gz /opt/nvidia/
RUN cd /opt/nvidia && \
    tar -xzf nvhpc_2023_237_Linux_x86_64_cuda_multi.tar.gz && \
    cd /opt/nvidia/nvhpc_2023_237_Linux_x86_64_cuda_multi && \
    ./install -accept-license -default && \
    rm /opt/nvidia/nvhpc_2023_237_Linux_x86_64_cuda_multi.tar.gz && \
    rm -r /opt/nvidia/nvhpc_2023_237_Linux_x86_64_cuda_multi

# Update yum repos to use "vault" instead of "mirror" (b/c centos 7 is old)
RUN sed -i \
    -e 's/^mirrorlist/#mirrorlist/g' \
    -e 's/^#baseurl=http:\/\/mirror./baseurl=https:\/\/vault./g' \
    /etc/yum.repos.d/CentOS-Base.repo

# Install some dependenices
RUN yum -y install epel-release
RUN yum -y install wget make gcc bzip2-devel libffi-devel zlib-devel perl

# TODO: Make getting python3 easy ... 
# Usually would just do yum install centos-release-scl and yum install rh-python39 
# but I can't get the repos to work because Centos7 is EOL

# Build OpenSSL 1.1.1 from source (required for poetry) (I can't get anything else working...)
RUN --mount=type=tmpfs,target=/usr/local/src \
    cd /usr/local/src && \
    wget https://www.openssl.org/source/openssl-1.1.1u.tar.gz && \
    tar -xzf openssl-1.1.1u.tar.gz && \
    cd openssl-1.1.1u && \
    ./config --prefix=/usr/local/openssl11 --openssldir=/usr/local/openssl11 shared zlib && \
    make -j$(nproc) && \
    make install

# Add built OpenSSL path to the dynamic linker cache
RUN echo "/usr/local/openssl11/lib" > /etc/ld.so.conf.d/openssl11.conf && \
    ldconfig

# Explcitly link against our built OpenSSL
ENV LDFLAGS="-L/usr/local/openssl11/lib -Wl,-rpath,/usr/local/openssl11/lib" \
    CPPFLAGS="-I/usr/local/openssl11/include"

# Install python3.9 from source (also can't get anything working ... Centos7 sucks)
RUN --mount=type=tmpfs,target=/usr/local/src \
    cd /usr/local/src && \
    wget https://www.python.org/ftp/python/3.9.6/Python-3.9.6.tgz && \
    tar -xzf Python-3.9.6.tgz && \
    cd Python-3.9.6 && \
    ./configure --prefix=/usr/local --with-openssl=/usr/local/openssl11 && \
    make -j$(nproc) && \
    make altinstall

# ensure SSL certs are available
RUN yum install -y ca-certificates && \
    update-ca-trust
ENV SSL_CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt

# Install Poetry
ENV POETRY_HOME="/opt/poetry"
ENV PATH="$POETRY_HOME/bin:$PATH"
RUN curl -sSL https://install.python-poetry.org | python3.9 -

# # Set PGI compiler environment
ENV NVHPC=/opt/nvidia/hpc_sdk
ENV PATH=$NVHPC/Linux_x86_64/23.7/compilers/bin:$PATH
ENV PGPATH=$NVHPC/Linux_x86_64/23.7/compilers/bin
ENV LD_LIBRARY_PATH=$NVHPC/Linux_x86_64/23.7/compilers/lib:$LD_LIBRARY_PATH

# Complete PGI setup
RUN $PGPATH/makelocalrc -x $PGPATH

WORKDIR /release
ENTRYPOINT ["./make_release.sh"]
CMD []