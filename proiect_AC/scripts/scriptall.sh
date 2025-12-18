#!/usr/bin/env bash
set -e

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=========================================="
echo "  3D LiDAR Clustering – FULL HDL PIPELINE  "
echo "=========================================="
echo ""

# -------------------------------------------------
# EUCLIDIAN
# -------------------------------------------------
echo "[EUCLIDIAN] Cleaning..."
rm -f "$ROOT_DIR/sim_euclidian" "$ROOT_DIR/clusters_out.txt"

echo "[EUCLIDIAN] Compiling..."
iverilog -o "$ROOT_DIR/sim_euclidian" \
    "$ROOT_DIR/rtl/top.v" \
    "$ROOT_DIR/rtl/octree_stream.v" \
    "$ROOT_DIR/tb/top_tb.v"

echo "[EUCLIDIAN] Running simulation..."
vvp "$ROOT_DIR/sim_euclidian"

echo "[EUCLIDIAN] Plotting..."
python3 "$ROOT_DIR/plot_clusters.py"

echo "[EUCLIDIAN] DONE"
echo ""

# -------------------------------------------------
# K-MEANS
# -------------------------------------------------
echo "[K-MEANS] Cleaning..."
rm -f "$ROOT_DIR/sim_kmeans" "$ROOT_DIR/clusters_out.txt"

echo "[K-MEANS] Compiling..."
iverilog -o "$ROOT_DIR/sim_kmeans" \
    "$ROOT_DIR/rtl_kmeans/kmeans_top.v" \
    "$ROOT_DIR/rtl_kmeans/kmeans_fsm.v" \
    "$ROOT_DIR/rtl_kmeans/kmeans_point_memory.v" \
    "$ROOT_DIR/rtl_kmeans/kmeans_distance_unit.v" \
    "$ROOT_DIR/tb/kmeans_top_tb.v"

echo "[K-MEANS] Running simulation..."
vvp "$ROOT_DIR/sim_kmeans"

echo "[K-MEANS] Plotting..."
python3 "$ROOT_DIR/kmeans_plot_clusters.py"

echo "[K-MEANS] DONE"
echo ""

# -------------------------------------------------
# DBSCAN
# -------------------------------------------------
echo "[DBSCAN] Cleaning..."
rm -f "$ROOT_DIR/sim_dbscan" "$ROOT_DIR/clusters_out.txt"

echo "[DBSCAN] Compiling..."
iverilog -o "$ROOT_DIR/sim_dbscan" \
    "$ROOT_DIR/rtl_dbscan/dbscan_distance_unit.v" \
    "$ROOT_DIR/rtl_dbscan/dbscan_point_memory.v" \
    "$ROOT_DIR/rtl_dbscan/dbscan_fsm.v" \
    "$ROOT_DIR/rtl_dbscan/dbscan_top.v" \
    "$ROOT_DIR/tb/dbscan_top_tb.v"

echo "[DBSCAN] Running simulation..."
vvp "$ROOT_DIR/sim_dbscan"

echo "[DBSCAN] Plotting..."
python3 "$ROOT_DIR/dbscan_plot_clusters.py"

echo "[DBSCAN] DONE"
echo ""

# -------------------------------------------------
# FCC (MAIN ARCHITECTURE)
# -------------------------------------------------
echo "[FCC] Cleaning..."
mkdir -p "$ROOT_DIR/sim"
rm -f "$ROOT_DIR/sim/sim_fcc" "$ROOT_DIR/fcc_clusters_out.txt"

echo "[FCC] Compiling..."
iverilog -g2005-sv -o "$ROOT_DIR/sim/sim_fcc" \
    "$ROOT_DIR/rtl_fcc/fcc_top.v" \
    "$ROOT_DIR/rtl_fcc/fcc_fsm.v" \
    "$ROOT_DIR/rtl_fcc/fcc_point_memory.v" \
    "$ROOT_DIR/rtl_fcc/fcc_distance_unit.v" \
    "$ROOT_DIR/rtl_fcc/fcc_union_find.v" \
    "$ROOT_DIR/tb/fcc_top_tb.v"

echo "[FCC] Running simulation..."
vvp "$ROOT_DIR/sim/sim_fcc"

echo "[FCC] Plotting..."
python3 "$ROOT_DIR/plot_fcc.py" "$ROOT_DIR/fcc_clusters_out.txt"

echo "[FCC] DONE"
echo ""
echo "=========================================="
echo "  ALL ALGORITHMS FINISHED SUCCESSFULLY ✔  "
echo "=========================================="
