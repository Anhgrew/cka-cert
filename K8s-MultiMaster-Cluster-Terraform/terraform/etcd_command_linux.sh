#!/bin/bash -x
ETCD_VER=v3.5.15

# Choose either URL
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/etcd-io/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}

# Define paths
TEMP_DIR=/tmp/etcd-download
ZIP_FILE=${TEMP_DIR}/etcd-${ETCD_VER}-linux-amd64.tar.gz

# Cleanup any existing files
rm -f ${ZIP_FILE}
rm -rf ${TEMP_DIR} && mkdir -p ${TEMP_DIR}

# Download etcd binary
curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o ${ZIP_FILE}

# Extract the binaries
tar xzvf ${ZIP_FILE} -C ${TEMP_DIR} --strip-components=1
rm -f ${ZIP_FILE}

# Move binaries to /usr/local/bin
sudo mv ${TEMP_DIR}/etcd* /usr/local/bin/

# Clean up
rm -rf ${TEMP_DIR}

# Verify installation
etcd --version
etcdctl version
etcdutl version
