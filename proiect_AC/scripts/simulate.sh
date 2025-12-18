#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT" || exit 1

echo "[INFO] Cleaning old simulation..."
rm -f sim clusters_out.txt

echo "[INFO] Compiling Verilog..."
iverilog -o sim rtl/top.v rtl/octree_stream.v tb/top_tb.v || exit 1

echo "[INFO] Running simulation..."
vvp sim

python3 plot_clusters.py
