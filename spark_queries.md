# Setup
```
import org.apache.spark.graphx._
val csv = sc.textFile("hi5.txt")
val data = csv.map(line => line.split(",").map(elem => elem.trim))
val givers = data.map(line => (line(0), 1))
val receivers = data.map(line => (line(1), 1))
val users = data.flatMap(line => Seq(line(0), line(1))).distinct
val unique = data.map(r => (r(0) + ":" + r(1), r)).reduceByKey((a, b) => a).map(r => r._2)
```

# Counting

## All High Fives
```
data.count()
res0: Long = 2652
```

## Biggest Givers
```
givers.reduceByKey(_+_,1).sortBy(-_._2).take(10).foreach(println)

(MarkNg,211)
(ScottMcMullan,209)
(WillRoman,157)
(DerrickSchmidt,146)
(TianGeng,143)
(Yan-DavidErlich,120)
(AbhishekBelani,119)
(ZachKozac,104)
(EBNovak,90)
(HarishSrinivasan,76)
```

## Biggest Receivers
```
receivers.reduceByKey(_+_,1).sortBy(-_._2).take(10).foreach(println)

(MarkNg,133)
(DerrickSchmidt,124)
(TianGeng,97)
(WillRoman,93)
(HarishSrinivasan,92)
(AmyFong,89)
(GilZhaiek,86)
(Yan-DavidErlich,78)
(DevanshGupta,78)
(BethMatteucci,77)
```

## Biggest Receivers from Most People

```
unique.map(r => (r(1), 1)).reduceByKey(_+_, 1).sortBy(-_._2).take(10).foreach(println)

(BethMatteucci,35)
(Yan-DavidErlich,30)
(GilZhaiek,30)
(DevanshGupta,30)
(XichiZheng,29)
(MarkNg,29)
(ScottMcMullan,27)
(WillRoman,27)
(EsteraKorpos,27)
(RoryShevin,26)
```

## No. of high fives between pairs of people
```
def unqKey(s1: String, s2: String) : String = {
  if (s1.compareTo(s2) < 0) {
    return s1 + ":" + s2
  } else {
    return s2 + ":" + s1
  }
}

data.map(r => (unqKey(r(0), r(1)), 1)).reduceByKey(_+_, 1).sortBy(-_._2).take(10).foreach(println)

(DerrickSchmidt:MarkNg,53)
(MarkNg:TianGeng,45)
(DerrickSchmidt:TianGeng,38)
(GlennXian:MarkNg,29)
(AbhishekBelani:WillRoman,28)
(AmyFong:MarkNg,24)
(ScottMcMullan:Yan-DavidErlich,21)
(HarishSrinivasan:WillRoman,21)
(DerrickSchmidt:GlennXian,19)
(GlennXian:TianGeng,19)

```

# PageRank

## Across all High Fives

```
def userHash(name: String) : VertexId = { name.toLowerCase.hashCode.toLong }
val vertices = users.map(u => (userHash(u), u)).cache
val edges = data.map(line => Edge(userHash(line(0)), userHash(line(1)), 1.0))
val graph = Graph(vertices, edges, "")

val prGraph = graph.staticPageRank(5).cache
val nameAndPrGraph = graph.outerJoinVertices(prGraph.vertices) {
  (v, name, rank) => (rank.getOrElse(0.0), name)
}
nameAndPrGraph.vertices.top(10) {
  Ordering.by((entry: (VertexId, (Double, String))) => entry._2._1)
}.foreach(t => println(t._2._2 + ": " + t._2._1))
```

```
MarkNg: 1.2499382297705448
DerrickSchmidt: 1.2451246397801918
WillRoman: 1.0983363322836668
DevanshGupta: 1.0638125830330378
BethMatteucci: 1.0364392320864442
TianGeng: 1.001755362338309
HarishSrinivasan: 0.9555594988278595
Yan-DavidErlich: 0.8758176517364866
AbhishekBelani: 0.870670963043387
RoryShevin: 0.857014531961417
```

## Unique Pair of Users

```
val vertices = users.map(u => (userHash(u), u)).cache
val edges = unique.map(line => Edge(userHash(line(0)), userHash(line(1)), 1.0))
val graph = Graph(vertices, edges, "")

val prGraph = graph.staticPageRank(5).cache
val nameAndPrGraph = graph.outerJoinVertices(prGraph.vertices) {
  (v, name, rank) => (rank.getOrElse(0.0), name)
}
nameAndPrGraph.vertices.top(10) {
  Ordering.by((entry: (VertexId, (Double, String))) => entry._2._1)
}.foreach(t => println(t._2._2 + " => " + f"${t._2._1}%.2f"))
```

```
BethMatteucci: 1.09325239638219
DevanshGupta: 0.9877157581239916
WillRoman: 0.9362456302055084
MarkNg: 0.936004774783514
Yan-DavidErlich: 0.9030156909502901
GilZhaiek: 0.8715819552488304
DerrickSchmidt: 0.8508322510510121
EsteraKorpos: 0.842320014661676
HarishSrinivasan: 0.8254164168952589
ScottMcMullan: 0.8195907622735835
```




