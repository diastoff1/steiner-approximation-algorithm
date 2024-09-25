import random
from itertools import combinations

# Função para calcular a árvore geradora mínima (AGM)
def mst(G):
    return G.min_spanning_tree(by_weight=True)

# Fechamento métrico de um grafo G
def metric_closure(G):
    MC = Graph.complete_graph(G.order())
    for u, v in MC.edge_iterator(labels=False):
        MC.set_edge_label(u, v, G.distance(u, v, by_weight=True))
    return MC

# Função para calcular o peso total das arestas
def weight(edges):
    return sum(weight for (u, v, weight) in edges)

# Contrai as três arestas de uma dada tripla
def contract_triple(G, triple):
    edges = [(triple[i], triple[j], G.edge_label(triple[i], triple[j])) for i in range(2) for j in range(i+1, 3)]
    for u, v, _ in edges:
        G.set_edge_label(u, v, 0)
    return G

# Calcula a soma das distâncias entre um vértice específico v e um conjunto de vértices
def total_distance(G, v, vertices):
    return sum(G.distance(v, s, by_weight=True) for s in vertices)

# Implementa o algoritmo de aproximação 11/6 para o problema de Steiner
def steiner_tree_11_6approximation(G, n, t):
    vertices = list(range(n))
    terminal_vertices = vertices[:t]
    steiner_vertices = vertices[t:]

    G_mc = metric_closure(G)
    G_ind = G_mc.subgraph(vertices=terminal_vertices)

    G.plot(layout="circular", edge_labels=True).show()
    G_mc.plot(layout="circular", edge_labels=True).show()
    G_ind.plot(layout="circular", edge_labels=True).show()

    W = set()
    F = G_ind.copy()
    Triples = list(combinations(terminal_vertices, 3))
    d = {}
    v = {}

    # Para cada tripla, encontra o vértice de Steiner que minimiza o somatório das distâncias
    for z in Triples:
        v[z] = min(steiner_vertices, key=lambda vert: total_distance(G, vert, z))
        d[z] = total_distance(G, v[z], z)

    while True:
        z = max(Triples, key=lambda z: weight(mst(F)) - weight(mst(contract_triple(F.copy(), z))) - d[z])
        win = weight(mst(F)) - weight(mst(contract_triple(F.copy(), z))) - d[z]

        if win <= 0:
            break

        F = contract_triple(F, z)
        W.add(v[z])

    induced_subgraph = G.subgraph(vertices=list(W) + terminal_vertices)
    mst_edges = mst(induced_subgraph)
    mst_graph = Graph(mst_edges, weighted=True)

    return mst_graph
