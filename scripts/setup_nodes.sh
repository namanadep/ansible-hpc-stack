#!/usr/bin/env bash
# Spin up three bare Ubuntu containers to act as HPC compute nodes.
# Each publishes its SSH port to a distinct localhost port (2201/2202/2203)
# so Ansible (running on the host) can reach them.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE="hpc-node:latest"

# Generate the Ansible SSH keypair on first run (kept out of git).
if [ ! -f "$REPO/keys/id_hpc" ]; then
    echo "[setup] Generating SSH keypair for Ansible …"
    mkdir -p "$REPO/keys"
    ssh-keygen -t ed25519 -N "" -f "$REPO/keys/id_hpc" -C "ansible-hpc-stack" >/dev/null
    chmod 600 "$REPO/keys/id_hpc"
fi

# The Dockerfile COPYs id_hpc.pub, so place it in the build context.
cp "$REPO/keys/id_hpc.pub" "$REPO/docker/id_hpc.pub"

echo "[setup] Building node image ($IMAGE) …"
docker build -t "$IMAGE" "$REPO/docker"

echo "[setup] Starting compute-node containers …"
i=1
for port in 2201 2202 2203; do
    name="node${i}"
    docker rm -f "$name" >/dev/null 2>&1 || true
    docker run -d --name "$name" --hostname "$name" \
        -p "127.0.0.1:${port}:22" "$IMAGE" >/dev/null
    echo "  - $name  ->  127.0.0.1:${port}"
    i=$((i + 1))
done

echo "[setup] Waiting for SSH to come up …"
until docker exec node3 ls /run/sshd >/dev/null 2>&1; do sleep 1; done
sleep 2
echo "[setup] Done. Nodes ready for provisioning."
