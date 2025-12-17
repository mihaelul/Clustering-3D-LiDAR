#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT" || exit 1

echo "[INFO] Cleaning old simulation..."
rm -f sim clusters_out.txt

echo "[INFO] Compiling Verilog (DBSCAN)..."
iverilog -o sim \
    rtl_dbscan/dbscan_top.v \
    rtl_dbscan/dbscan_fsm.v \
    rtl_dbscan/dbscan_point_memory.v \
    rtl_dbscan/dbscan_distance_unit.v \
    tb/dbscan_top_tb.v || exit 1

echo "[INFO] Running DBSCAN simulation..."
vvp sim

echo "[INFO] Plotting clusters..."
python3 dbscan_plot_clusters.py
