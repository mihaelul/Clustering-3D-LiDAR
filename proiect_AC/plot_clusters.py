import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

points = []

with open("clusters_out.txt", "r") as f:
    for line in f:
        x, y, z, label = map(int, line.split())
        points.append((x, y, z, label))

# extragem clusterele unice
cluster_ids = sorted(set(p[3] for p in points))
num_clusters = len(cluster_ids)

# mapare cluster_id → culoare
cmap = plt.cm.get_cmap("tab10", num_clusters)
color_map = {cid: cmap(i) for i, cid in enumerate(cluster_ids)}

fig = plt.figure()
ax = fig.add_subplot(111, projection="3d")

for x, y, z, cid in points:
    ax.scatter(x, y, z, color=color_map[cid], s=80)

ax.set_xlabel("X")
ax.set_ylabel("Y")
ax.set_zlabel("Z")
ax.set_title("3D Point Cloud Clustering (from HDL output)")

plt.show()
