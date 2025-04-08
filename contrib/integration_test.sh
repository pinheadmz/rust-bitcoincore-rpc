#!/usr/bin/env bash
#
# Run the integration test optionally downloading Bitcoin Core binary if BITCOINVERSION is set.

set -euo pipefail

REPO_DIR=$(git rev-parse --show-toplevel)

# Make all cargo invocations verbose.
export CARGO_TERM_VERBOSE=true

main() {
    download_binary

    need_cmd bitcoind

    cd integration_test
    ./run.sh
}

download_binary() {
    sudo apt-get install -y build-essential cmake pkgconf python3 libevent-dev libboost-dev libzmq3-dev libsqlite3-dev libdb-dev libdb++-dev
    git clone --depth 1 --branch http-rewrite-13march2025 https://github.com/pinheadmz/bitcoin
    cd bitcoin
    cmake -B build -DWITH_BDB=ON -DWITH_ZMQ=ON -DBUILD_GUI=OFF -DBUILD_BENCH=OFF -DBUILD_FUZZ_BINARY=OFF -DBUILD_GUI_TESTS=OFF -DBUILD_TESTS=OFF -DBUILD_UTIL=OFF -DBUILD_TX=OFF -DBUILD_WALLET_TOOL=OFF
    cmake --build build -j$(nproc)
    export PATH=$PATH:$(pwd)/build/bin
    cd ..
}

err() {
    echo "$1" >&2
    exit 1
}

need_cmd() {
    if ! command -v "$1" > /dev/null 2>&1
    then err "need '$1' (command not found)"
    fi
}

#
# Main script
#
main "$@"
exit 0
