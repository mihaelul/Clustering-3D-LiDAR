#!/bin/bash

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT" || exit 1

rm -f sim clusters_out.txt

iverilog -o sim \
    rtl_dbscan/dbscan_distance_unit.v \
    rtl_dbscan/dbscan_point_memory.v \
    rtl_dbscan/dbscan_fsm.v \
    rtl_dbscan/dbscan_top.v \
    tb/dbscan_top_tb.v || exit 1

vvp sim

# CORECT: scriptul e în root
python3 dbscan_plot_clusters.py
