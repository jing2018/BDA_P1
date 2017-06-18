#Run if you haven't installed igraph
#install.packages("igraph")

library(igraph)

inp = read.csv(file = "../edgeList.csv")
#a few possible simplifications: removing edges with fewer than 50 emails (that's most edges) and removing 1-cycles (emails to self)
simpler <- subset(inp, Weight > 10)
simpler <- subset(inp, To != From)
emailNames = read.csv(file = "../NamesToIndices.csv")

myGraph = graph_from_data_frame(inp,directed=TRUE)
simpleGraph = graph_from_data_frame(simpler,directed=FALSE)

#function 1: igraph.plot implements the generic plot function, so we can just call plot()
#even when we only keep edges with > 20 emails, we still see a very dense graph.
#similarly, we see there are some clusters of people who only email each other (along the outside of the graph)
plot.igraph(simpleGraph,vertex.label=NA,vertex.size = 6)

#Function 2: igraph.clique.number:
#Finds the maximum clique size in the graph
clq = clique.number(simpleGraph)

#Function 3: betweenness centrality:
#Calculates the approximate betweenness centrality of each vertex, using a cutoff for distance
btwn_cent = betweenness.estimate(simpleGraph,cutoff=6)
btwn_cent <- sort(btwn_cent,decreasing = TRUE)
for (i in c(1,2,3,4,5)){
  ind = as.numeric(names(btwn_cent[i]))
  print(subset(emailNames,Index==ind)["Name"][1])
}

#Function 4: Degree
deg = degree(graph = simpleGraph)
print(max(deg))

#Functions 5-7: Basic descriptive analytics

#Function 5: gorder counts number of vertices (i.e., Enron employees in graph)
gorder(simpleGraph)  #1644

#Function 6: gsize counts number of edges (i.e., relationships between employees)
gsize(simpleGraph)  #3746

#Function 7: measure density of simpleGraph 
# (higher density means employees are more interconnected, communications are not siloed, and network can resist more link failures)
# =edgeCount / total number of possible edges
# 3746/(n(n-1)/2)) where n = 1644
edge_density(simpleGraph) #0.002773693

#Function 8: list employees in contact with employee 1213 within simpleGraph
E(simpleGraph) [ from ("1213") ]
# prints 4 edges out of 3746 total
# 406--1213  2253--1213  6887--1213  1213--10765

#Function 9: remove employee 1213 because he was fired and compare edge and vertex count
gorder(simpleGraph) # 1644
gsize(simpleGraph) # 3746
simpleGraphwithout1213 <- delete_vertices(simpleGraph, "1213")
gorder(simpleGraphwithout1213) # 1643
gsize(sipmleGraphwithout1213) # 3742
