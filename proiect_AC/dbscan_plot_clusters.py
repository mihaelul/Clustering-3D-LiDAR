import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

points = []

with open("clusters_out.txt") as f:
    next(f)
    for line in f:
        x, y, z, label = map(int, line.split())
        points.append((x, y, z, label))

colors = ['red','blue','green','purple','orange','cyan','brown','pink']

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

for x,y,z,label in points:
    if label == 0:
        c = 'black'
    else:
        c = colors[(label-1) % len(colors)]
    ax.scatter(x,y,z,color=c,s=80)

ax.set_xlabel('X')
ax.set_ylabel('Y')
ax.set_zlabel('Z')
ax.set_title('DBSCAN clustering (HDL)')

plt.show()
