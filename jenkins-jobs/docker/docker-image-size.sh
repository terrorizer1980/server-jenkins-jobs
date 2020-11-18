#!/bin/bash

set -Eeufx -o pipefail

# Default docker tag to pull.
# latest  = latest LTS release
# rolling = latest LTS (regardless of LTS status)
# devel   = current development snapshot
: Docker tag: "${DOCKERTAG:=latest}"

# Default size limit
: Maximum size: "${MAXSIZE:=90}"

container="docker-$DOCKERTAG-image-size-test"

function cleanup {
    # Is there a better way to check if a given LXD container exists?
    ! lxc info "$container" &>/dev/null || lxc delete "$container" --force
}

trap cleanup EXIT

cleanup
lxc launch ubuntu: "$container" --quiet --ephemeral

# Wait for the container to be fully initialized.
lxc exec "$container" -- cloud-init status --wait

lxc exec "$container" -- apt-get -q update
lxc exec "$container" -- apt-get -qy install docker.io
lxc exec "$container" -- mkdir /etc/systemd/system/docker.service.d
lxc exec "$container" -- sh -c 'printf '\''[Service]\nEnvironment="HTTPS_PROXY=http://squid.internal:3128/"\n'\'' > /etc/systemd/system/docker.service.d/https-proxy.conf'
lxc exec "$container" -- systemctl daemon-reload
lxc exec "$container" -- systemctl restart docker
lxc exec "$container" -- docker pull "ubuntu:$DOCKERTAG"
size=$(lxc exec "$container" -- docker image ls "ubuntu:$DOCKERTAG" --format "{{.Size}}")
cleanup

size=$(echo "$size" | grep -o '^[0-9]*')
: "Maximum allowed size: ${MAXSIZE}MB"
: "Current size: ${size}MB"

test "$size" -le "$MAXSIZE"
