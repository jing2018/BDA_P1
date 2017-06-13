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
