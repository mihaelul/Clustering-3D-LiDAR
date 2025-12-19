# Clustering of Point Clouds

## Overview

This project focuses on the study and implementation of several classical clustering algorithms for multidimensional data, with an emphasis on **2D/3D point clouds**.
The following algorithms are implemented:

* **K-Means**
* **DBSCAN (Density-Based Spatial Clustering of Applications with Noise)**
* **Euclidean Clustering**
* **FCC (Fast Channel Clustering)** – applied to a real dataset

The project highlights the differences between distance-based, density-based, and topology-based clustering approaches, as well as their limitations and suitability for real-world scenarios.

---

## Project Structure

```text
proiect_AC/
│
├── data/
│   ├── 0000000000.bin       
│   └── lidar_stream.txt           # real dataset (used for FCC), converted
│
├── rtl/   # Euclidian implementation
├── rtl_dbscan/ # DBSCAN implementation
├── rtl_fcc/   # FCC implementation
├── rtl_kmeans/   # K-Means implementation
├── scripts/
│   ├── scriptall.sh  # execution scripts     
│    
├── tb/ #testbenches
└── README.md             # project documentation
```

---

## Implemented Algorithms

### 1. Euclidean Clustering

Euclidean Clustering groups points based on **spatial proximity**, expanding clusters starting from a seed point using a Euclidean distance threshold.

**Characteristics:**

* conceptually similar to DBSCAN
* highly dependent on efficient neighbor search

**Usage in this project:**

* basic implementation for understanding spatial clustering
* tested on synthetic datasets

---
### 2. K-Means

K-Means is an iterative clustering algorithm that partitions the dataset into **K clusters**, each represented by a centroid. Every point is assigned to the nearest centroid using the Euclidean distance, and the centroids are updated until convergence.

**Key characteristics:**

* requires the number of clusters `K` to be specified in advance
* computationally efficient
* sensitive to initialization and outliers

**Usage in this project:**

* applied to synthetic datasets
* used as a baseline for comparison with DBSCAN

---

### 3. DBSCAN

DBSCAN groups points based on **density**, identifying dense regions separated by sparse areas. It can discover clusters of arbitrary shape and explicitly labels noise points.

**Main parameters:**

* `eps` – neighborhood radius
* `minPts` – minimum number of neighbors required to form a core point

**Advantages:**

* does not require the number of clusters beforehand
* robust to noise and outliers

**Usage in this project:**

* applied to synthetic datasets
* compared against K-Means in terms of clustering quality

---


### 4. Fast Channel Clustering (FCC)

Fast Channel Clustering is a clustering algorithm designed for **real-world LiDAR data**, exploiting the scanning structure of the sensor. The 3D point cloud is projected into a **2D range image**, and clustering is performed using local connectivity between channels.

**Main stages:**

1. Intra-channel grouping
2. Inter-channel grouping
3. Label resolution (Connected Component Labeling)

**Usage in this project:**

* applied to a real dataset
* demonstrates the advantages of topology-based approaches over classical methods

---

## Datasets

* **Synthetic datasets**

  * generated to evaluate algorithm behavior under controlled conditions
  * simple shapes, varying densities, and noise

* **Real dataset**

  * used exclusively for FCC
  * contains complex structures and sensor-specific noise

---

## Installation and Execution

### Requirements

* Python 3.8+
* Windows Subsystem for Linux (WSL)

The project was **developed and tested using WSL**, and execution is recommended in this environment.


### Running the project

To run all implementations, navigate to the `scripts/` directory and execute:

```bash
./scriptall
```

This script runs all clustering algorithms and generates the corresponding results.

---

## Results
<img width="600" alt="euclidian" src="https://github.com/user-attachments/assets/24cc28e6-179d-4001-a172-6c63a10a55a4" />
<img width="600" alt="kmeans" src="https://github.com/user-attachments/assets/41ce8127-ee88-4aaa-8dbb-965decf4c742" />
<img width="600" alt="dbscan" src="https://github.com/user-attachments/assets/4919bbb9-81fc-4a8a-bdda-a758ef7e89e5" />

---

## Conclusions

This project demonstrates that:

* **K-Means** is fast but conceptually limited
* **DBSCAN** and **Euclidean Clustering** are more flexible for spatial data
* **FCC** is significantly better suited for structured real-world data (e.g., LiDAR)

The choice of clustering algorithm strongly depends on the **data characteristics**, **scale**, and **real-time requirements**.

---

## Possible Extensions

* optimized neighbor search (KD-Tree, Octree)
* quantitative performance evaluation (runtime, memory)
* extension of FCC with ground removal
* parallelization or hardware acceleration

---

