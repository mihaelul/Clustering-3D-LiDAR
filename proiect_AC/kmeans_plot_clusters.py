import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

points = []
with open("clusters_out.txt") as f:
    for line in f:
        line = line.strip()
        if not line or not line[0].isdigit():
            continue
        x, y, z, label = map(int, line.split())
        points.append((x, y, z, label))

colors = ['red', 'blue', 'green']  # EXACT 3 clustere

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

for x, y, z, label in points:
    if label in [0,1,2]:
        ax.scatter(x, y, z, color=colors[label], s=80)
    else:
        ax.scatter(x, y, z, color='black', s=80)  # eroare / noise

ax.set_xlabel("X")
ax.set_ylabel("Y")
ax.set_zlabel("Z")
ax.set_title("K-means clustering (HDL)")

plt.show()
