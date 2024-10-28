import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import networkx as nx
import pandas as pd

data=pd.read_csv('../data/model/test.csv')
print(data)
# Create a directed graph
G = nx.DiGraph()

# Add edges to the graph
for base, branch in zip(data['base_id'], data['branch_id']):
    G.add_edge(branch, base)

# Define a hierarchical layout
def hierarchy_pos(G, root=None, width=3., vert_gap=0.5, vert_loc=0, xcenter=0.5):
    pos = _hierarchy_pos(G, root, width, vert_gap, vert_loc, xcenter)
    return pos

def _hierarchy_pos(G, root, width=3., vert_gap=0.5, vert_loc=0, xcenter=0.5, pos=None, parent=None, parsed=[]):
    if pos is None:
        pos = {root: (xcenter, vert_loc)}
    else:
        pos[root] = (xcenter, vert_loc)
    children = list(G.neighbors(root))
    if not isinstance(G, nx.DiGraph) and parent is not None:
        children.remove(parent)  
    if len(children) != 0:
        dx = width / len(children) 
        nextx = xcenter - width/2 - dx/2
        for child in children:
            nextx += dx
            pos = _hierarchy_pos(G, child, width=dx, vert_gap=vert_gap, vert_loc=vert_loc-vert_gap, xcenter=nextx, pos=pos, parent=root, parsed=parsed)
    return pos

# Draw the graph
plt.figure(figsize=(12, 8))
pos = hierarchy_pos(G, root='/')
nx.draw(G, pos, with_labels=False, node_size=1000, node_color="lightblue",  arrowsize=20)
# Add labels manually with rotation
labels = {node: node for node in G.nodes()}
for node, (x, y) in pos.items():
    plt.text(x, y, str(node), fontsize=10, ha='center', va='center', rotation=60,zorder=99)
    
plt.title("Hierarchical Tree Plot of all SEA Test Experiments", fontsize=20)
plt.savefig('../fig/tree.png', dpi=300, bbox_inches='tight')