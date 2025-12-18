#!/bin/bash
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT" || exit 1

echo "[INFO] Cleaning old simulation..."
rm -f sim clusters_out.txt

echo "[INFO] Compiling Verilog (K-means)..."
iverilog -o sim \
  rtl_kmeans/kmeans_top.v \
  rtl_kmeans/kmeans_fsm.v \
  rtl_kmeans/kmeans_point_memory.v \
  rtl_kmeans/kmeans_distance_unit.v \
  tb/kmeans_top_tb.v || exit 1

echo "[INFO] Running K-means simulation..."
vvp sim

echo "[INFO] Plotting clusters..."
python3 kmeans_plot_clusters.py
