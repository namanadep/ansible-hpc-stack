# Minimal "bare compute node" — a fresh Ubuntu box with nothing but SSH +
# Python, exactly what Ansible needs to connect and manage it. Everything an
# HPC node actually needs (compilers, OpenMPI, Lmod, libraries) is installed
# by the Ansible roles, NOT baked in here — that's the whole point.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
        openssh-server \
        python3 \
        sudo \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/sshd /root/.ssh \
    && chmod 700 /root/.ssh

# Ansible authenticates as root via this injected public key (no passwords).
COPY id_hpc.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D", "-e"]
