#Run if you haven't installed igraph
#install.packages("igraph")
#install.packages("sna")
#install.packages("stringr")

library("igraph")
library("sna")
library("stringr")

#==========================
#read data from file & preprocessing
#==========================
inp = read.csv(file = "../edgeList.csv")
#a few possible simplifications: removing edges with fewer than 50 emails (that's most edges) and removing 1-cycles (emails to self)
simpler <- subset(inp, Weight > 50)
simpler <- subset(simpler, To != From)

#simplify--turn a graph into a simple graph by using the simplify function
is.simple(simpleGraph)
##[1] FALSE
simpleGraph=simplify(simpleGraph)
is.simple(simpleGraph)
##[1] TRUE

emailNames = read.csv(file = "../NamesToIndices.csv")

myGraph = graph_from_data_frame(inp,directed=TRUE) 
simpleGraph = graph_from_data_frame(simpler,directed=FALSE) #undirected graph
DirectedGraph = graph_from_data_frame(simpler,directed=TRUE) #directed graph

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
#undirected degree
deg = degree(graph = simpleGraph)
hist(deg,main = "Histogram of node degree")
print(max(deg))

#directed degree-only count the "in" mail 
inDeg=degree(DirectedGraph, mode="in")
hist(inDeg,main="Histogram of in-node degree")
#Frequency of degree distribution
inDegDist=degree_distribution(DirectedGraph, cumulative = FALSE,mode = "in")

inDegDist=inDegDist*100
plot(x=0:max(inDeg), y=inDegDist, col="orange",
     xlab = "Degree", ylab = "Frequency*100")

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
gsize(simpleGraphwithout1213) # 3742

#Function 10:diameter
#A network diameter is the longest geodesic distance (length of the shortest path between two nodes) in the network. 
#In igraph, diameter() returns the distance, while get_diameter() returns the nodes along the first found path of that distance.
diameter(myGraph,directed=FALSE,weights = NA)
##[1] 13
diameter(simpleGraph,directed=FALSE,weights = NA)
##[1] 15
diam=get_diameter(simpleGraph,directed=FALSE,weights = NA)
##+ 16/362 vertices, named:
## [1] 9703  1639  8114  4150  5969  1750  6887  3609  3573  10266
##[11] 10688 2792  10475 7680  5033  7044 

#Function 11: Centrality & centralization
#(e)power centrality?
centr_degree(DirectedGraph, mode="in", normalized=TRUE)
#Closeness
closeness(DirectedGraph, mode="in", weights=NA) 
centr_clo(DirectedGraph, mode="in", normalized=T)
#Eigenvector(centrality based on distance to others in the graph)
eigen_centrality(DirectedGraph, directed=T, weights=NA)
centr_eigen(DirectedGraph, directed=T, normalized=T) 

#Function 12: Hubs and authorities
# Hubs were expected to contain catalogs with a large number of outgoing links;
# while authorities would get many incoming links from hubs
hs <- hub_score(DirectedGraph )$vector
as <- authority_score(DirectedGraph)$vector

par(mfrow=c(1,2))
plot(DirectedGraph,vertex.label=NA, vertex.size=hs*50, main="Hubs")
plot(DirectedGraph,vertex.label=NA,  vertex.size=as*30, main="Authorities")


