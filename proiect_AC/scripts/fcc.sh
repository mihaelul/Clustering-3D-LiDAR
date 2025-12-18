#!/usr/bin/env bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT_DIR/sim"

iverilog -g2005-sv -o "$ROOT_DIR/sim/sim_fcc" \
  "$ROOT_DIR/rtl_fcc/fcc_top.v" \
  "$ROOT_DIR/rtl_fcc/fcc_fsm.v" \
  "$ROOT_DIR/rtl_fcc/fcc_point_memory.v" \
  "$ROOT_DIR/rtl_fcc/fcc_distance_unit.v" \
  "$ROOT_DIR/rtl_fcc/fcc_union_find.v" \
  "$ROOT_DIR/tb/fcc_top_tb.v"

vvp "$ROOT_DIR/sim/sim_fcc"

python3 "$ROOT_DIR/plot_fcc.py" "$ROOT_DIR/fcc_clusters_out.txt"
