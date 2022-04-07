### A Pluto.jl notebook ###
# v0.19.0

using Markdown
using InteractiveUtils

# ╔═╡ 27f62732-c909-11eb-27ee-e373dce148d9
begin
	using Pkg
	using PlutoUI
	
	using Graphs
	using CommunityDetection
	
	# I/O
	using GraphIO
	using SNAPDatasets
	using DataFrames
	
	# Visualização
	using GraphMakie
	using NetworkLayout
	using CairoMakie
	using AlgebraOfGraphics
	using Colors: JULIA_LOGO_COLORS
	
	# Extras
	using Statistics: mean
	
	# Seed
	using Random: seed!
	seed!(123);
end

# ╔═╡ 228e9bf1-cfd8-4285-8b68-43762e1ae8c7
begin
	using InteractiveUtils
	with_terminal() do
		versioninfo()
	end
end

# ╔═╡ cbc48ca5-f1a4-4e13-9323-2fd2c43d8612
TableOfContents(aside=true)

# ╔═╡ 7bb67403-d2ac-4dc9-b2f1-fdea7a795329
md"""
# Grafos e Análise Redes com `Graphs.jl`
"""

# ╔═╡ e8c26849-bdd0-4dd2-ad6a-e9ddf6f7ef86
Resource("https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg", :width => 120, :display => "inline")

# ╔═╡ 94b06d53-864f-43b0-ab90-0f364ef869ee
md"""
!!! danger "⚠️ Disciplina Ferramental"
    **Esta disciplina é uma disciplina ferramental!**

	Portanto, se você não sabe o que é uma rede ou um grafo, pegue um livro-texto e estude ou pergunte pro seu orientador.

	**Sugestão de fonte**: Newman, M. (2018). Networks (2nd Edition). Oxford university press. [(link)](https://global.oup.com/academic/product/networks-9780198805090?cc=us&lang=en&)
"""

# ╔═╡ fca4dd6b-974b-4567-b9e1-1e9ae56f2abe
md"""
!!! info "💁 LightGraphs.jl para Graphs.jl"
    A partir de Outubro de 2021 houve uma [mudança no desenvolvimento dos pacotes de grafos e redes de Julia](https://discourse.julialang.org/t/lightgraphs-jl-transition/69526). Os pacotes estavam peformáticos e estáveis, mas não estavam sendo atualizados regularmente. [Julia Computing](https://juliacomputing.com/) então tomou as rédeas dos pacotes de grafos e renomeou todos de `LightGraphs` para `Graphs`. Este notebook foi atualizado para refletir as novas direções de análise de grafos e redes em Julia com [`Graphs.jl`](https://github.com/JuliaGraphs/Graphs.jl). Os pacotes renomeados foram:

	* `LightGraphs.jl` → `Graphs.jl`
	* `LightGraphsExtras.jl` → `GraphsExtras.jl`
	* `LightGraphsMatchings.jl` → `GraphsMatchings.jl`
	* `LightGraphsFlows.jl` → `GraphsFlows.jl`
"""

# ╔═╡ 92bfdc9d-049f-4ebf-ae54-7056aeff738b
md"""
# Eu sei que vocês já sabem mas...

Julia é muito rápida!

Veja esses benchmarks entre cinco pacotes de grafos e redes:

- [NetworkX](https://networkx.github.io/), v2.4, Python 3.8
- [graph-tool](https://graph-tool.skewed.de/static/doc/quickstart.html), v2.31, Python 3.8
- [Igraph](https://igraph.org/python/), v0.8.2, Python 3.8
- [NetworKit](https://networkit.github.io/), v6.1.0, Python 3.8
- [SNAP](https://snap.stanford.edu/snap/), v5.0.0, Python 3.7
- [LightGraphs](https://juliagraphs.github.io/LightGraphs.jl/latest/), v2.0-dev, Julia 1.4

E três datasets:

- [Amazon product co-purchasing network from March 2 2003](https://snap.stanford.edu/data/amazon0302.html), 262k nodes, 1.2m edges
 - [Web graph from Google](https://snap.stanford.edu/data/web-Google.html), 875k nodes, 5.1m edges
- [Pokec online social network](https://snap.stanford.edu/data/soc-Pokec.html), 1.6m nodes, 30.6m edges

> Fonte: timrlx [blog](https://www.timlrx.com/blog/benchmark-of-popular-graph-network-packages-v2) e código [`timlrx/graph-benchmarks`](https://github.com/timlrx/graph-benchmarks)
"""

# ╔═╡ 811325db-bb90-440d-968c-bde2b975b09d
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/LightGraphs_benchmarks.png?raw=true")

# ╔═╡ 2c28dc38-77bb-4e3d-b80e-e5b2ab221171
md"""
# Análise de Redes (Grafos)

Uma **rede** (também chamada de **grafo** na literatura matemática) é, em sua forma mais simples, a **coleção de pontos unidos em pares por linhas**. Na nomenclatura do campo, um ponto é referido como um **nó** ou **vértice** e uma linha é referida como uma **aresta** (Newman, 2018).

Muitos sistemas de interesse nas ciências físicas, biológicas e sociais podem ser pensados em redes e pensar neles desta forma pode levar a *insights* novos e úteis.
"""

# ╔═╡ eb902545-63e1-4be0-b679-24122107f2cd
md"""
!!! info "💁 Nomenclatura Internacional"
	Rede/Grafo $\to$ Network/Graph
	
    Nó/Vértice $\to$ Node/Vertex
	
	Aresta $\to$ Edge
"""

# ╔═╡ ae931f3a-6953-4464-9eac-6d9b2b7462d6
md"""
| Network            | Node                             | Edge                              |
|-------------------|----------------------------------|-----------------------------------|
| Internet           | Computer or router               | Cable or wireless data connection |
| World Wide Web     | Web page                         | Hyperlink                         |
| Citation network   | Article, patent, or legal case   | Citation                          |
| Power grid         | Generating station or substation | Transmission line                 |
| Friendship network | Person                           | Friendship                        |
| Metabolic network  | Metabolite                       | Metabolic reaction                |
| Neural network     | Neuron                           | Synapse                           |
| Food web           | Species                          | Predation                         |

> Newman (2018)
"""

# ╔═╡ c74c2f4c-5fae-4fed-bdc7-70ceb63afed1
let
	g = erdos_renyi(10, 0.5)
	f, ax, p = graphplot(g; node_size=20)
	hidedecorations!(ax)
	hidespines!(ax)
	f
end

# ╔═╡ 771106a8-4e23-4bcf-a40a-75cbfc464d37
md"""
# JuliaGraph

Todos os pacotes pertinentes à análise de redes em Julia estão na organização [JuliaGraph](https://github.com/JuliaGraphs):

* **Pacote principal**:
   * [`Graphs.jl`](https://github.com/JuliaGraphs/Graphs.jl): implementações em Julia de algoritmos e análises padrão de redes.


* **Mais algoritmos**:
   * [`GraphsExtras.jl`](https://github.com/JuliaGraphs/GraphsExtras.jl): algoritmos de interdição em redes.

   * [`GraphsFlows.jl`](https://github.com/JuliaGraphs/GraphsFlows.jl): algoritmos de fluxo.

   * [`GraphsMatching.jl`](https://github.com/JuliaGraphs/GraphsMatching.jl): algoritmos de correspondência.

   * [`CommunityDetection.jl`](https://github.com/JuliaGraphs/CommunityDetection.jl): algoritmos de detecção de comunidade.


* Mais tipos de redes:
   * [`SimpleWeightedGraphs.jl`](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl): implementação eficiente de redes simples com arestas ponderadas.

   * [`MetaGraphs.jl`](https://github.com/JuliaGraphs/MetaGraphs.jl):  implementação de redes com metadados de rede, vértice e aresta.

   * [`StaticGraphs.jl`](https://github.com/JuliaGraphs/StaticGraphs.jl): `Graphs` imutáveis (estáticos) com eficiência de memória.


* Input/Output:
   * [`GraphIO.jl`](https://github.com/JuliaGraphs/GraphIO.jl): I/O para vários formatos.

   * [`SNAPDatasets.jl`](https://github.com/JuliaGraphs/SNAPDatasets.jl): arquivos de redes formatados em `Graphs.jl` retirados da coleção de [datasets SNAP de Stanford](https://snap.stanford.edu/data/index.html).

* Visualização:
   * [`GraphPlot.jl`](https://github.com/JuliaGraphs/GraphPlot.jl): visualização de redes. Baseado em `Compose.jl`, **não recomendo** pois é o *backend* de `Gadfly.jl` (péssimo dev e mal-mantido)

   * [`NetworkLayout.jl`](https://github.com/JuliaGraphs/NetworkLayout.jl): algoritmos de layout para redes e árvores em Julia.

   * [`GraphRecipes.jl`](https://github.com/JuliaPlots/GraphRecipes.jl): visualizações com `Plots.jl` e todos seus *backends* e atributos.

   * [`GraphMakie.jl`](https://github.com/JuliaPlots/GraphMakie.jl): visualizações com `Makie.jl` e todos seus *backends* e atributos. Este **eu recomendo!**

   * [`TikzGraphs.jl`](https://github.com/JuliaTeX/TikzGraphs.jl): converte visualizações em formato $\LaTeX$ com TikZ.

* Outros:
   * [`GraphDataFrameBridge.jl`](https://github.com/JuliaGraphs/GraphDataFrameBridge.jl): ferramentas para interoperabilidade entre objetos `DataFrame` e código de objetos `Graphs` e `MetaGraphs`.

   * [`Graph500.jl`](https://github.com/JuliaGraphs/Graph500.jl): benchmarks [**Graph500**](https://graph500.org/) escritos em Julia usando `Graphs`.
"""

# ╔═╡ d7471179-87b7-41a8-903e-78f720bf3195
md"""
# Input e Output de Redes
"""

# ╔═╡ 103d0652-4595-4cc7-8dc4-18068d300f0d
md"""
## [`GraphIO.jl`](https://github.com/JuliaGraphs/GraphIO.jl)

Format        | Read | Write | Multiple Graphs| Format Name  |
--------------|------|-------|----------------|--------------|
[EdgeList]    |   ✓  |  ✓    |                |EdgeListFormat|
[GML]         |   ✓  |  ✓    | ✓              |GMLFormat     |
[Graph6]      |   ✓  |  ✓    | ✓              |Graph6Format  |
[GraphML]     |   ✓  |  ✓    | ✓              |GraphMLFormat |
[Pajek NET]   |   ✓  |  ✓    |                |NETFormat     |
[GEXF]        |      |  ✓    |                |GEXFFormat    |
[DOT]         |   ✓  |       | ✓              |DOTFormat     |
[CDF]         |   ✓  |       |                |CDFFormat     |

* **`[EdgeList]`**: [uma lista simples de origem-destinos separados por espaço em branco e/ou vírgula, um par por linha](https://en.wikipedia.org/wiki/Edge_list).
* **`[GML]`**: [Graph Modeling Language](https://en.wikipedia.org/wiki/Graph_Modelling_Language)
* **`[Graph6]`**: [formatos para armazenar grafos não-direcionados de maneira compacta](https://users.cecs.anu.edu.au/~bdm/data/formats.html)
* **`[GraphML]`**: [formato XML](https://en.wikipedia.org/wiki/GraphML)
* **`[Pajek NET]`**: [formato NET de Pajek](https://gephi.org/users/supported-graph-formats/pajek-net-format/)
* **`[GEXF]`**: [Formato GEXF de Gephi](https://gephi.org/gexf/format/)
* **`[DOT]`**: [Formato de GraphViz](https://en.wikipedia.org/wiki/DOT_(graph_description_language))

As redes são lidas usando a função **`loadgraph`** ou, para formatos que suportam várias redes em um único arquivo, a função **`loadgraphs`**:

* **`loadgraph`** retorna um objeto `Graph`.
* **`loadgraphs`** retorna um **dicionário** de objetos `Graph`.

Por exemplo, um arquivo em formato `EdgeList` pode ser carregado como:

```julia
g = loadgraph("my_edgelist.txt", "graph_key", EdgeListFormat())
```

Para salvar um arquivo em formato `EdgeList` use o `savegraph`:

```julia
savegraph("my_edgelist.txt", g, gname="graph_key", format=EdgeListFormat())
```

> OBS: `savegraph` também tem um método com `Dict` que salva múltiplos `Graph`s.
"""

# ╔═╡ 30c461b2-70b0-4487-bf94-60d92b229d07
md"""
## `DataFrame`s com [`GraphDataFrameBridge.jl`](https://github.com/JuliaGraphs/GraphDataFrameBridge.jl)

* Redes **não-direcionadas**:

  ```julia
  g = MetaGraph(df, origin, destination;
                weight=Symbol,
                edge_attributes=Vector{Symbol},
                vertex_attributes=DataFrame
                vertex_id_col=Symbol)
  ```

* Redes **direcionadas**:

  ```julia
  g = MetaDiGraph(df, origin, destination;
                weight=Symbol,
                edge_attributes=Vector{Symbol},
                vertex_attributes=DataFrame
                vertex_id_col=Symbol)
  ```

* **`df`** é um `DataFrame` formatado como `EdgeList`.
* **`origin`** é o `Symbol` da coluna para origem de cada edge.
* **`destination`** é o `Symbol` da coluna para origem de cada edge.
"""

# ╔═╡ bc1a7dd9-c5a7-495d-92b5-60781fe182da
md"""
!!! info "💁 Criando Redes"
    Além de I/O, é possível também criar seu próprio `Graph`. Veja a [documentação de `Graphs.jl`](https://juliagraphs.org/Graphs.jl/dev/generators/).

	Isto pode ser útil se você está criando algum algoritmo ou fazendo alguma operação que cria os nodes e edges de maneira iterativa.
"""

# ╔═╡ f7f056fe-9908-4957-81e0-c45466d9818f
md"""
# Exemplo com o Clube de Karatê

O clássico [clube de karatê de Zachary(1977)](https://en.wikipedia.org/wiki/Zachary%27s_karate_club) se tornou um exemplo popular de estrutura de comunidade em redes após seu uso por Girvan e Newman em 2002 no paper da PNAS (Girvan & Newman, 2002).

Uma rede social de um clube de caratê foi estudada por um período de três anos de 1970 a 1972.
A rede contém 34 membros de um clube de caratê, documentando ligações entre pares de membros que interagiam fora do clube.
Durante o estudo, surgiu um **conflito entre o administrador "John A" e o instrutor "Mr. Hi" (pseudônimos), o que levou à divisão do clube em dois**.
Metade dos membros formaram um novo clube em torno do Sr. Hi; membros da outra parte encontraram um novo instrutor ou desistiram do caratê.

> Zachary, W. W. (1977). "An Information Flow Model for Conflict and Fission in Small Groups". _Journal of Anthropological Research_. 33 (4): 452–473.
>
> Girvan, M.; Newman, M. E. J. (2002). "Community structure in social and biological networks". _Proceedings of the National Academy of Sciences_. 99: 7821–7826. doi:10.1073/pnas.122653799. PMC 122977. PMID 12060727.
"""

# ╔═╡ 31c81884-97cd-4fbe-8c4c-fcb70e14dacb
md"""
Aqui vemos que a rede é não-direcionada com 34 nodes e 78 edges.
"""

# ╔═╡ 9e8b7b3c-26a0-44ee-8121-daa5ec976a87
g = smallgraph(:karate)

# ╔═╡ 4c4c7d3f-ebe3-4119-a319-96b92a5c43fa
typeof(g)

# ╔═╡ 771109fa-b48f-466c-b547-f4edf0a9f6ac
supertypes(typeof(g))

# ╔═╡ bcde3b6b-2bfd-4373-91df-1045a98e9145
md"""
## Tipos de `Graphs`

* **Concretos**:
   * **`SimpleGraph`**: não-direcionado
   * **`SimpleDiGraph`**: direcionado

* **Abstratos**:
   * **`AbstractSimpleGraph`**
   * **`AbstractGraph`**

Além de fornecer implementações `SimpleGraph` e` SimpleDiGraph`, `Graphs.jl` também serve como uma estrutura para outros tipos de grafos. Atualmente, existem vários tipos de grafos alternativos, cada um com seu próprio pacote:

- [`SimpleWeightedGraphs.jl`](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl) fornece uma estrutura para grafos (não-)direcionados com a capacidade de especificar **pesos (valores) nas arestas**.
- [`MetaGraphs.jl`](https://github.com/JuliaGraphs/MetaGraphs.jl) fornece uma estrutura de grafos (não)-direcionados que suportam propriedades (**metadados**) definidas pelo usuário no grafo, vértices e arestas.
- [`StaticGraphs.jl`](https://github.com/JuliaGraphs/StaticGraphs.jl) oferece suporte a estruturas grafo muito grandes de maneira **eficiente** em termos de espaço e tempo, mas como o nome indica, **não permite a modificação do grafo depois de criado**.

### Qual tipo de grafo devo usar?

Estas são orientações gerais para ajudá-lo a selecionar o tipo de grafo adequado:

- Em geral, prefira as estruturas nativas `SimpleGraphs`/`SimpleDiGraphs` em [`Graphs.jl`](https://github.com/JuliaGraphs/Graphs.jl).
- Se você precisa de pesos (valores) de arestas e não exige um grande número de modificações de grafos, use [`SimpleWeightedGraphs.jl`](https://github.com/JuliaGraphs/SimpleWeightedGraphs.jl).
- Se você precisar rotular vértices ou arestas, use [`MetaGraphs.jl`](https://github.com/JuliaGraphs/MetaGraphs.jl).
- Se você trabalha com grafos muito grandes (bilhões a dezenas de bilhões de arestas) e não precisa de mutabilidade, use [`StaticGraphs.jl`](https://github.com/JuliaGraphs/StaticGraphs.jl).
"""

# ╔═╡ f642d550-0b64-4a17-9fc3-35970ca622f8
md"""
## Propriedades de Grafos

- `nv`: **n**úmero de **v**értices do grafo.
- `ne`: **n**úmero de **e**dges do grafo.
- `vertices`: objeto iterável de todos os vértices do grafo.
- `edges`: objeto iterável de todas as arestas do grafo.
- `has_vertex`: verifica se o grafo inclui um vértice.
- `has_edge(g, s, d)`: verifica se o grafo inclui uma aresta de uma determinada fonte (_source_) `s` para um determinado destino `d`.
- `has_edge(g, e)` retornará verdadeiro se houver uma aresta em `g` que satisfaça `e == f` para qualquer `f ∈ edges(g)`. Este é um teste de igualdade estrito que pode exigir que todas as propriedades de `e` sejam iguais.

## Propriedades do Vértice

- `neighbours`: retorna uma array de vizinhos de um vértice. Se o grafo for direcionado, a saída é equivalente a `outneighbours`.
- `all_neighbors`: Retorna uma array de todos os vizinhos (ambos `inneighbors` e `outneighbors`). Para grafos não-direcionados, equivalente a `neighbors`.
- `inneighbors`: Retorna uma array de *in*-neighbours. Equivalente a `neighbors` para grafos não-direcionados.
- `outneighbours`: Retorna uma array de *out*-neighbours. Equivalente a `neighbors` para grafos não-direcionados.

## Propriedades da Aresta

- `src`: fornece o vértice de origem de uma aresta.
- `dst`: fornece o vértice de destino de uma aresta.
- `reverse`: cria uma nova aresta executando na direção oposta da aresta passada.
"""

# ╔═╡ e4a843fa-da54-46be-a08f-918f84a3294a
md"""
## Representações Matriciais

Todo grafo pode ser representado como uma matriz.
"""

# ╔═╡ c4d5b924-fe4c-45c8-a416-0303f38671f6
adjacency_matrix(g) # Matriz de Adjacência

# ╔═╡ fdc099e2-8411-4a9b-be25-0fcd1095b585
adjacency_spectrum(g) # Eigenvalues/Autovalores da Matriz de Adjacência

# ╔═╡ e044f97a-a83f-464f-add2-189e7bb7ae68
incidence_matrix(g) # Matriz de Incidência

# ╔═╡ 6d821d78-0549-4afb-8075-9b596981a4f4
laplacian_matrix(g) # Matriz Laplaciana

# ╔═╡ 37d436a7-bad8-4d6d-a3ec-34296392de57
laplacian_spectrum(g) # Eigenvalues/Autovalores da Matriz Laplaciana

# ╔═╡ 1b805029-d4ac-4fca-be7c-cd17eec4d649
md"""
## Visualizações com [`GraphMakie.jl`](https://github.com/JuliaPlots/GraphMakie.jl) e [`NetworkLayout.jl`](https://github.com/JuliaGraphs/NetworkLayout.jl)

A primeira coisa que vamos ver é **como visualizar redes**.
"""

# ╔═╡ 24cf0f75-171c-4fa2-83f5-2a71734b0256
md"""
!!! info "💁 GraphMakie.jl"
    Para melhores gráficos e controle maior das visualizações de redes, **eu recomendo** [`GraphMakie.jl`](https://github.com/JuliaPlots/GraphMakie.jl).
"""

# ╔═╡ f56f0e36-4c9f-4c62-9c58-f07ce3d0d5a5
md"""
!!! danger "⚠️ GraphPlot.jl"
    `GraphPlot.jl` é baseado em `Compose.jl` e `Gadly.jl`. Eu **não recomendo usar** pois está praticamente abandonado além do desenvolvedor (1) não aceitar sugestões e contribuições da comunidade e (2) ser [irresponsável com *type piracy*](https://github.com/JuliaPlots/AlgebraOfGraphics.jl/issues/215#issuecomment-866032991).
"""

# ╔═╡ bb246ca8-e894-4283-a912-256d3e29671a
md"""
### Plotar Redes com [`GraphMakie.jl`](https://github.com/JuliaPlots/GraphMakie.jl)

Função [**`graphplot`**](http://juliaplots.org/GraphMakie.jl/dev/#The-graphplot-Recipe):
"""

# ╔═╡ b1597dba-e7c2-4602-9ff2-a09f1d6ccd38
graphplot(g)

# ╔═╡ 8bf47d42-87d3-42ab-a3e2-32a4f2fdbc37
md"""
#### Atributos de `graphplot`

Assim como vimos atributos de `Makie.jl` na [**Aula 6 - Visualização de Dados com `Plots.jl`, `StatsPlots.jl` e `AlgebraOfGraphics.jl`**](https://storopoli.io/Computacao-Cientifica/6_Plots/), também temos atributos de **`graphplot`**:

* **Atributos Principais**:
   * `layout=Spring()`: determina o layout (mais sobre isso em breve).
   * `node_color`: cor dos nodes
   * `node_size`: tamanho dos nodes.
   * `node_marker`: formato dos nodes.
   * `node_attr=(;)`: `NamedTuple` de argumentos dos nodes.
   * `edge_color`: cor das edges. Se passar um vetor com duas cores você cria gradientes de cor.
   * `edge_width`: largura das edges.
   * `edge_attr=(;)`: `NamedTuple` de argumentos das edges.
   * `arrow_show`: `Bool`, indica se as direções das edge são representadas com `arrowheads`? Padrão `true` para `SimpleDiGraph` e `false` caso contrário.
   * `arrow_size`: tamanho das `arrowheads`.
   * `arrow_attr=(;)`: `NamedTuple` de argumentos das `arrowheads`.
"""

# ╔═╡ 099d2ffa-fe76-4d07-a4fe-68451c029c75
graphplot(
	g;
	node_color=:blue,
	node_size=15,
	node_marker=:rect,
	edge_color=:gray,
	edge_width=2
)

# ╔═╡ bad73037-2d01-4d60-b5ec-d268b20d34e5
md"""
* **Node Labels**:

   * `nlabels=nothing`: `Vector{String}` com labels para cada node.
   * `nlabels_align=(:left, :bottom)`: âncora do texto do label.
   * `nlabels_distance=0.0`: distância em pixels do node em direção ao `align`.
   * `nlabels_color`: cor do label.
   * `nlabels_textsize`: tamanho do label.
   * `nlabels_attr=(;)`: `NamedTuple` de argumentos dos labels.
"""

# ╔═╡ 71b9d4bd-e280-4def-93b5-73250616e165
graphplot(
	g;
	nlabels=string.(vertices(g)),
	nlabels_align=(:right, :top),
	nlabels_distance=5,
	nlabels_color=:blue,
	nlabels_textsize=16
)

# ╔═╡ ed731efa-3bc9-456a-87ea-ad7ef36b960c
md"""
* **Edge Labels**:

   * `elabels=nothing`: `Vector{String}` com labels para cada edge.
   * `elabels_align=(:center, :bottom)`: âncora do texto do label.
   * `elabels_distance=0.0`: distância em pixels do node em direção ao `align`.
   * `elabels_rotation=nothing`: angulo de rotação do label.
   * `elabels_color`: cor do label.
   * `elabels_textsize`: tamanho do label.
   * `elabels_attr=(;)`: `NamedTuple` de argumentos dos labels.
"""

# ╔═╡ bad4cb62-9a6c-4a36-8fe9-3d194f3bccdc
graphplot(
	g;
	elabels=string.(1:ne(g)),
	elabels_align=(:center, :bottom),
	elabels_distance=0,
	elabels_color=:blue,
	elabels_textsize=12
)

# ╔═╡ 8229f4f6-ff0c-4e59-a18b-027aae6b80e1
md"""
!!! tip "💡 Remover os Eixos"
    `graphplot` retorna uma tupla de (`Figure`, `Axis` e um objeto `graphplot`)

	Você pode usar o `Axis` na função **`hidedecorations!`** para remover todas as "decorações" do eixos `x` e `y` (`label`, `ticklabels`, `ticks` e `grid`)

	Você pode usar o `Axis` na função **`hidespines!`** para remover todas as "espinhas".
"""

# ╔═╡ ebb677f5-bdf9-4d14-a568-f18fef0120b5
let
	f, ax, p = graphplot(g)
	hidedecorations!(ax)
	hidespines!(ax)
	f
end

# ╔═╡ 37989421-2f2b-4331-9169-ef4d78edaa7f
md"""
### Layouts com [`NetworkLayout.jl`](https://github.com/JuliaGraphs/NetworkLayout.jl)

Temos **vários algoritmos de layouts** para as redes:

> OBS: note que é a mesma rede do Clube do Karatê.
"""

# ╔═╡ b8bb5987-8c90-4697-abfd-de26e1d2047a
let
	f, ax, p = graphplot(g; layout=SFDP())
	hidedecorations!(ax)
	hidespines!(ax)
	f[0,1] = title = Label(f, "Scalable Force Directed Placement", textsize=30)
	f
end

# ╔═╡ 4eab17d0-6d18-461e-bcbf-c47a95155627
let
	f, ax, p = graphplot(g; layout=Spring())
	hidedecorations!(ax)
	hidespines!(ax)
	f[0,1] = title = Label(f, "Spring/Repulsion Model", textsize=30)
	f
end

# ╔═╡ 900b6d60-6ff2-42a2-8e2b-b2858cedf4c0
let
	f, ax, p = graphplot(g; layout=Stress())
	hidedecorations!(ax)
	hidespines!(ax)
	f[0,1] = title = Label(f, "Stress Majorization", textsize=30)
	f
end

# ╔═╡ af824068-9ce8-4d05-bebc-4535c3d0a0bc
let
	f, ax, p = graphplot(g; layout=Shell())
	hidedecorations!(ax)
	hidespines!(ax)
	f[0,1] = title = Label(f, "Shell/Circular Layout", textsize=30)
	f
end

# ╔═╡ bffc3d2a-daa2-47ce-8b40-4a331aa68375
let
	f, ax, p = graphplot(g; layout=SquareGrid())
	hidedecorations!(ax)
	hidespines!(ax)
	f[0,1] = title = Label(f, "SquareGrid Layout", textsize=30)
	f
end

# ╔═╡ b0a4683a-9a33-4e91-8b09-4497b9f7ac9f
let
	f, ax, p = graphplot(g; layout=Spectral(dim=2))
	hidedecorations!(ax)
	hidespines!(ax)
	f[0,1] = title = Label(f, "Spectral Layout", textsize=30)
	f
end

# ╔═╡ 28a3ad4f-3304-432e-8cec-6b2d93ab2073
md"""
!!! info "💁 LayeredLayouts.jl"
    Para mais layouts veja também [`LayeredLayouts.jl`](https://github.com/oxinabox/LayeredLayouts.jl).
"""

# ╔═╡ 1e4bb2b4-ff3d-4887-b106-cdf8e72503bc
md"""
## Graph Metrics (Métricas de Grafos)

- **Average Degree** (*Grau Médio*): número médio de arestas por nó.


- **Average Weighted Degree** (*Grau Valorado Médio*): média da soma dos valores das arestas entre os nós (somente para weighted graphs -- grafos valorados)


- **Network Diameter** (*Diâmetro da Rede*): a distância máxima entre qualquer par de nós no grafo.


- **Modularity** (*Modularidade*): modularidade é uma medida da estrutura de redes ou grafos. Ela foi projetada para medir a força da divisão de uma rede em módulos (também chamados de grupos, clusters ou comunidades). Redes com alta modularidade têm conexões densas entre os nós dentro dos módulos, mas conexões esparsas entre nós em módulos diferentes.


- **Connected Components** (*Componentes Conectados*) - um componente conectado (ou apenas componente) de um grafo não-direcionado é um subgrafo no qual quaisquer dois vértices estão conectados um ao outro por caminhos, e que não está conectado a nenhum vértice adicional no supergrafo.
"""

# ╔═╡ 07316d91-8833-41dc-83ae-60b74a587a40
degree_centrality(g; normalize=false) |> mean

# ╔═╡ 7a6ead52-a666-48dc-960e-4fbd1f1c2660
diameter(g)

# ╔═╡ 181f0e3f-d234-4bad-bb4e-03e645c5284c
modularity(
	g,
	rand([1, 2], nv(g)) # precisa de um partition vector 
)

# ╔═╡ 3b59f57d-04be-4387-b5da-079b0078dbfc
connected_components(g) # um único giant component

# ╔═╡ d632ccc4-29e9-4806-adb9-cc0f6c8f4855
is_connected(g) # true pq é um único giant component

# ╔═╡ 38b29ff9-fec5-4e04-8c45-06dcd3a77eab
md"""
## Centrality (centralidade)

A centralidade refere-se a **indicadores que identificam os vértices mais importantes de um grafo**.

Temos várias medidas:

* **degree**: centralidade de grau
* **eigenvector**: centralidade de autovetor
* **closeness**: centralidade de proximidade
* **betweenness**: centralidade de intermediação
* **PageRank**: centralidade PageRank (algoritmo do Larry Page -- Google)
"""

# ╔═╡ ae1f1a30-c8f0-4a25-a74a-bbd4a417d57d
centrality_df = DataFrame(;
	node=vertices(g),
	degree=degree_centrality(g; normalize=false), # normalizado entre 0 e 1
	ndegree=degree_centrality(g),
	eigenvector=eigenvector_centrality(g),
	closeness=closeness_centrality(g),            # normalizado entre 0 e 1
	betweenness=betweenness_centrality(g),        # normalizado entre 0 e 1
	pagerank=pagerank(g)
)

# ╔═╡ 65bc471b-5a4d-4920-a1ec-d4d1af388161
md"""
### Degree (centralidade de grau)

O grau de um nó em um grafo não-direcionada é o número de arestas conectadas a ele.
"""

# ╔═╡ 69a39b60-e9e4-4d2f-a356-668d20e8720f
describe(centrality_df; cols=:degree)

# ╔═╡ 2ea69d44-cd00-4ae9-9bbc-9d9fbe0e0180
md"""
!!! tip "💡 Degree em redes direcionadas"
    Os degrees de nodes são mais complicados em **redes direcionadas**.

	Em uma rede direcionada, **cada node tem dois degrees**: o *in*-degree é o número de edges de entrada conectadas a um node e o *out*-degree é o número de edges de saída de um node.

	`Graphs.jl` tem as funções **`indegree_centrality`** e **`outdegree_centrality`**.
"""

# ╔═╡ 7b0cbbd0-723e-4913-9065-329344e1143f
md"""
#### Distribuição dos Degrees

Uma coisa legal de se ver é distribuição dos degrees.

Ela segue quase sempre uma *power law* (qualquer coisa que pode ser escrita como $y=ax^k$), i.e. uma distribuição assimétrica exponencial.
"""

# ╔═╡ 88b4a637-bbcc-4305-8991-6ce296bf231f
data(centrality_df) *
	mapping(:degree) *
	visual(color=JULIA_LOGO_COLORS.purple) *
	histogram() |> draw

# ╔═╡ 4023b2c1-8910-46d6-b04b-5e8973480a4f
data(centrality_df) *
	mapping(:degree) *
	visual(color=JULIA_LOGO_COLORS.purple) *
	AlgebraOfGraphics.density() |> draw

# ╔═╡ dea222a5-2938-4cd3-bf88-e3f02fd57883
md"""
### Eigenvector (centralidade de autovetor)

A centralidade de autovetor é uma medida da influência de um nó em uma rede. Ele atribui **pontuações relativas a todos os nós da rede com base no conceito de que as conexões com os nós de alta pontuação contribuem mais para a pontuação do nó em questão do que conexões iguais com o nó de baixa pontuação**.

Chama-se autovetor porquê usa os autovetores e autovalores da matriz de adjacência do grafo.
"""

# ╔═╡ e2401207-84aa-4a73-a2ac-2800ee1ea153
describe(centrality_df; cols=:eigenvector)

# ╔═╡ 701e6154-441e-4aba-952f-cf18b841c734
md"""
### Closeness (centralidade de proximidade)

Em grafos conectados, há uma métrica de distância natural entre todos os pares de nós, definida pelo **comprimento de seus caminhos mais curtos**.

A distância de um nó é definida como a **soma de suas distâncias a todos os outros nós, e sua proximidade é definida como o recíproco da distância**. Assim, **quanto mais central é um nó, menor é sua distância total a todos os outros nós**.
"""

# ╔═╡ 2bdc89aa-cae4-4f50-af9a-da9dfd4173f2
describe(centrality_df; cols=:closeness) # normalizado entre 0 e 1

# ╔═╡ d829ce22-437e-4741-9a9e-116aefbb89f1
md"""
### Betweenness (centralidade de intermediação)

Intermediação é uma medida de centralidade de um vértice dentro de um grafo (também há intermediação de arestas, que não é discutida aqui).

A centralidade de intermediação **quantifica o número de vezes que um nó atua como uma ponte ao longo do caminho mais curto entre dois outros nós**.
"""

# ╔═╡ 6c51600f-6d1e-4366-84be-efbff514c8d8
describe(centrality_df; cols=:betweenness) # normalizado entre 0 e 1

# ╔═╡ 1d4932be-8c49-48ca-bd5f-f67c7b8cbef1
md"""
### PageRank

Originalmente feito para grafos representando a internet. PageRank é um algoritmo utilizado pelo Google para posicionar websites entre os resultados de suas buscas. O PageRank mede a importância de uma nó contabilizando a quantidade e qualidade de arestas apontando para ela.

Foi patenteado e é oriundo da tese de doutorado do Larry Page em Stanford.
"""

# ╔═╡ 0d5c48ea-0722-4075-a841-7a2bf02d87d8
describe(centrality_df; cols=:pagerank)

# ╔═╡ fe4d6481-c546-4826-931a-fb7dc4d0adfc
md"""
### Plotando Centralidade
"""

# ╔═╡ 3e3de8b8-c96a-4d4c-9db7-de84bf42de23
let
	f, ax, p = graphplot(
		g;
		node_size=degree_centrality(g) .* 1e2
	)
	hidedecorations!(ax)
	hidespines!(ax)
	f[0,1] = title = Label(f, "Centralidade de Grau", textsize=30)
	f
end

# ╔═╡ b3f7d8f3-8cd2-4deb-a64d-b4e074921f53
let
	f, ax, p = graphplot(
		g;
		node_size=closeness_centrality(g) .* 1e2
	)
	hidedecorations!(ax)
	hidespines!(ax)
	f[0,1] = title = Label(f, "Centralidade de Proximidade", textsize=30)
	f
end

# ╔═╡ baaf6c4e-d38c-4328-90ff-f393f02226fe
let
	f, ax, p = graphplot(
		g;
		node_size=betweenness_centrality(g) .* 1e2
	)
	hidedecorations!(ax)
	hidespines!(ax)
	f[0,1] = title = Label(f, "Centralidade de Intermediação", textsize=30)
	f
end

# ╔═╡ d7cf904e-7dd5-42a9-a4bf-ff7961bf5dce
let
	f, ax, p = graphplot(
		g;
		node_size=pagerank(g) .* 1e3
	)
	hidedecorations!(ax)
	hidespines!(ax)
	f[0,1] = title = Label(f, "Centralidade de PageRank", textsize=30)
	f
end

# ╔═╡ 0ee8bcd2-29f1-4dce-b8eb-8e12fe155e51
md"""
## Deteção de Comunidades com [`CommunityDetection.jl`](https://github.com/JuliaGraphs/CommunityDetection.jl)

[`CommunityDetection.jl`](https://github.com/JuliaGraphs/CommunityDetection.jl) ainda é um pacote bem incipiente (oportunidade de pesquisa e contribuição opensource).

Temos **apenas dois algoritmos de detecção de comunidades**, ambos baseados em agrupamento espectral (*spectral clustering*, provavelmente manipulações com autovetores):

* **`community_detection_nback`**: matriz "nonbacktracking"
* **`community_detection_bethe`**: também baseado em matriz "nonbacktracking" mas usa uma matriz Hessiana com o operador Bethe (também conhecida como matriz Laplaciana deformada)

> Krzakala, F., Moore, C., Mossel, E., Neeman, J., Sly, A., Zdeborová, L., & Zhang, P. (2013). Spectral redemption in clustering sparse networks. Proceedings of the National Academy of Sciences, 110(52), 20935–20940. https://doi.org/10/f5kvh4
>
> Saade, A., Krzakala, F., & Zdeborová, L. (2014). Spectral Clustering of graphs with the Bethe Hessian. Advances in Neural Information Processing Systems, 27. https://proceedings.neurips.cc/paper/2014/hash/63923f49e5241343aa7acb6a06a751e7-Abstract.html


Em especial eu adoraria ver o [algoritmo de Louvain](https://github.com/JuliaGraphs/CommunityDetection.jl/pull/3) (Blondel et. al, 2008) e [algoritmo de Leiden](https://discourse.julialang.org/t/leiden-algorithim-implementation-in-julia/55910) (Traag, Waltman & van Eck, 2019) implementados (baseados em modularidade).

> Blondel, V. D., Guillaume, J.-L., Lambiotte, R., & Lefebvre, E. (2008). Fast unfolding of communities in large networks. Journal of Statistical Mechanics: Theory and Experiment, 2008(10), P10008. https://doi.org/10.1088/1742-5468/2008/10/P10008
>
> Traag, V. A., Waltman, L., & van Eck, N. J. (2019). From Louvain to Leiden: Guaranteeing well-connected communities. Scientific Reports, 9(1), 5233. https://doi.org/10.1038/s41598-019-41695-z

Caso se interesse veja os links acima e também esse PR em [`EcoJulia/EcologicalNetworks.jl`](https://github.com/EcoJulia/EcologicalNetworks.jl/pull/183).
"""

# ╔═╡ 1c816bc7-d5f1-4abd-a26b-e6f0c76cbead
# precisa passar o número de comunidades
karate_nback = community_detection_nback(g, 2)

# ╔═╡ c04569e8-2efb-4b71-86a8-6f184576cecb
# precisa passar o número de comunidades
karate_bethe = community_detection_bethe(g, 2)

# ╔═╡ 12724ba8-995b-4ab3-be6b-d575f36cfcd7
let
	f, ax, p = graphplot(
		g;
		node_size=degree_centrality(g) .* 1e2,
		node_color=karate_nback)
	hidedecorations!(ax)
	hidespines!(ax)
	f
end

# ╔═╡ 1cba3d46-9853-4646-999e-ecf0ecd2fa9e
md"""
## Subgrafos

`Graphs.jl` também consegue criar subgrafos com base em uma lista de vértices `vlist` ou lista de arestas `elist` usando a função **`induced_subgraph`**.

Com comunidades detectadas podemos usar a `vlist` para criar os subgrafos:
"""

# ╔═╡ 3e49645d-7203-412a-9384-c5a63e4b3c5e
# primeiro precisamos de uma máscara booleana
bool_mask = karate_nback .== 1

# ╔═╡ b0efd6e0-55a9-4020-9ebc-cc60d4e8717a
vlist_1 = vertices(g)[bool_mask]

# ╔═╡ 23b98c4c-b474-474d-b44f-929649442c7b
vlist_2 = vertices(g)[.!bool_mask] # .! not vetorizado 😎

# ╔═╡ 9e30d937-2a72-4fd3-b95e-df670e2a4634
md"""
!!! danger "⚠️ induced_subgraph"
    Cuidado `induced_subgraph` retorna uma tupla de `(g, vmap)` aonde `g` é o subgrafo e `vmap` é a lista de vértices do grafo original.
"""

# ╔═╡ 7b8075c3-89a8-4295-9809-2c73c8f96906
karate_1, vmap_1 = induced_subgraph(g, vlist_1)

# ╔═╡ 1ffd0624-e663-4b43-9be3-2a39e2ecf8a7
karate_2, vmap_2 = induced_subgraph(g, vlist_2)

# ╔═╡ ee5c877b-cca7-4453-85e2-69653b8bd552
md"""
!!! tip "💡 Indexação de Graphs"
    Sim! Você consegue indexar `Graphs` com `g[vlist]`.
"""

# ╔═╡ 3d6aa0c8-1333-4f43-bed8-25f458ba5efa
g[vlist_1]

# ╔═╡ 2a4c3340-1eb0-4bd2-8db3-56d387f0ee3f
let
	f, ax, p = graphplot(karate_1)
	hidedecorations!(ax)
	hidespines!(ax)
	f
end

# ╔═╡ 4ac4e273-4e9d-46e6-92c4-c508ae2255c1
let
	f, ax, p = graphplot(karate_2)
	hidedecorations!(ax)
	hidespines!(ax)
	f
end

# ╔═╡ c77d2f63-3005-4ea2-8d22-678f3a4ae679
md"""
## Shortest Path (Caminhos Mínimos)

Na teoria de grafos, o problema do caminho mínimo consiste na minimização do *custo* de travessia de um grafo entre dois nós (ou vértices); custo este dado pela soma dos pesos (ou valores) de cada aresta percorrida.

`Graphs.jl` tem vários algoritmos de caminhos mínimos:
* **`bellman_ford_shortest_paths`**
* **`dijkstra_shortest_paths`**
* **`floyd_warshall_shortest_paths`**
* **`johnson_shortest_paths`**

Todos aceitam um grafo `g` e computa as distâncias mínimas entre uma lista de `srcs` e todos os outros vértices
"""

# ╔═╡ 21d31cfd-650b-4f97-98cc-3689e1c35545
dijkstra_shortest_paths(g, 1) # apenas o nó 1

# ╔═╡ ed2f0654-0819-49ce-b396-e1dae579e737
md"""
### Algoritmo $A^*$

Para conseguir o caminho mínimo você pode usar o algoritmo [$A^*$ (A-star)](https://pt.wikipedia.org/wiki/Algoritmo_A*) com a função **`a_star`**:
"""

# ╔═╡ 435a8d08-05f7-41e5-9bb6-6e6b4107cebb
caminho_minimo_11_27 = a_star(g, 11, 27)

# ╔═╡ 6324f854-71ac-4419-80b1-282706840918
let
	# achar as arestas do caminho curto
	# tanto normais quanto reversas (grafo não-direcionado)
	arestas_caminho = findall(x -> x ∈ caminho_minimo_11_27 ||
			 				  x ∈ reverse.(caminho_minimo_11_27),
						collect(edges(g)))
	
	# achar os vertices do caminho curto
	# tanto src quanto dst (grafo não-direcionado)
	vertices_caminho = src.(caminho_minimo_11_27) ∪ dst.(caminho_minimo_11_27)
	
	# colorir todas as arestas de preto
	edgecolors = [:black for _ ∈ 1:ne(g)]
	
	# colorir as arestas do caminho curto de vermelho
	edgecolors[arestas_caminho] .= :red
	
	# colorir todos os vértices de preto
	nodecolors = [:black for _ ∈ 1:nv(g)]
	
	# colorir os vértices do caminho curto de vermelho
	nodecolors[vertices_caminho] .= :red
	
	# grafico
	f, ax, p = graphplot(
		g;
		node_size=degree_centrality(g) .* 1e2,
		edge_width=2,
		edge_color=edgecolors,
		node_color=nodecolors
	)
	hidedecorations!(ax)
	hidespines!(ax)
	f
end

# ╔═╡ fc57adf5-689d-4a0c-b91e-df9d6e44579f
md"""
# `Graphs.Parallel`

Diversas funções também possuem versões em execucão paralela 🚀 dentro do módulo `Graphs.Parallel`:

```julia
using Graphs
import Graphs.Parallel
```

* Medidas de Centralidade:
   * `Parallel.betweenness_centrality`
   * `Parallel.closeness_centrality`
   * `Parallel.pagerank`
   * `Parallel.radiality_centrality`
   * `Parallel.stress_centrality`

* Medidas de Distância:
   * `Parallel.center`
   * `Parallel.diameter`
   * `Parallel.eccentricity`
   * `Parallel.radius`

* Algoritmos de Caminhos Curtos (shortest paths):
   * `Parallel.bellman_ford_shortest_paths`
   * `Parallel.dijkstra_shortest_paths`
   * `Parallel.floyd_warshall_shortest_paths`
   * `Paralell.johnson_shortest_paths`

* Algoritmos de Traversal (Traversal):
   * `Parallel.bfs`
   * `Parallel.greedy_color`
"""

# ╔═╡ 7fee896e-c25d-42d8-8653-b6ededccf1cc
md"""
!!! tip "💡 As Sete Pontes de Königsberg"
    Se você gostou de teoria dos grafos, conheça sua história com o vídeo abaixo sobre as sete pontes de Königsberg com o grande [Clif Stroll](https://en.wikipedia.org/wiki/Clifford_Stoll).

	Se gostou, compre uma [Klein bottle](https://en.wikipedia.org/wiki/Klein_bottle) dele ou presenteie seu professor que ele vai amar. <https://www.kleinbottle.com/>
"""

# ╔═╡ 82172216-cd56-4905-b3b3-18439c557de6
HTML("
<style>.embed-container { position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; } .embed-container iframe, .embed-container object, .embed-container embed { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }</style><div class='embed-container'><iframe src='https://www.youtube.com/embed/W18FDEA1jRQ' frameborder='0' allowfullscreen></iframe></div>
")

# ╔═╡ d548bc1a-2e20-4b7f-971b-1b07faaa4c13
md"""
# Ambiente
"""

# ╔═╡ 23974dfc-7412-4983-9dcc-16e7a3e7dcc4
with_terminal() do
	deps = [pair.second for pair in Pkg.dependencies()]
	deps = filter(p -> p.is_direct_dep, deps)
	deps = filter(p -> !isnothing(p.version), deps)
	list = ["$(p.name) $(p.version)" for p in deps]
	sort!(list)
	println(join(list, '\n'))
end

# ╔═╡ ff6dfa4b-73bb-48f2-b439-fe931ef7c89c
md"""
# Licença

Este conteúdo possui licença [Creative Commons Attribution-ShareAlike 4.0 Internacional](http://creativecommons.org/licenses/by-sa/4.0/).

[![CC BY-SA 4.0](https://licensebuttons.net/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AlgebraOfGraphics = "cbdf2221-f076-402e-a563-3d30da359d67"
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
CommunityDetection = "d427f087-d71a-5a1b-ace0-b93392eea9ff"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
GraphIO = "aa1b3936-2fda-51b9-ab35-c553d3a640a2"
GraphMakie = "1ecd5474-83a3-4783-bb4f-06765db800d2"
Graphs = "86223c79-3864-5bf0-83f7-82e725a168b6"
InteractiveUtils = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
NetworkLayout = "46757867-2c16-5918-afeb-47bfcb05e46a"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
SNAPDatasets = "fc66bc1b-447b-53fc-8f09-bc9cfb0b0c10"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
AlgebraOfGraphics = "~0.6.5"
CairoMakie = "~0.7.5"
Colors = "~0.12.8"
CommunityDetection = "~0.2.0"
DataFrames = "~1.3.2"
GraphIO = "~0.6.0"
GraphMakie = "~0.3.3"
Graphs = "~1.6.0"
NetworkLayout = "~0.4.4"
PlutoUI = "~0.7.38"
SNAPDatasets = "~0.2.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

manifest_format = "2.0"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "6f1d9bc1c08f9f4a8fa92e3ea3cb50153a1b40d4"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.1.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "af92965fb30777147966f58acb05da51c5616b5f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.3"

[[deps.AlgebraOfGraphics]]
deps = ["Colors", "Dates", "Dictionaries", "FileIO", "GLM", "GeoInterface", "GeometryBasics", "GridLayoutBase", "KernelDensity", "Loess", "Makie", "PlotUtils", "PooledArrays", "RelocatableFolders", "StatsBase", "StructArrays", "Tables"]
git-tree-sha1 = "032144cbb772cf0aef2954dfe5cc2c0bebeaaadd"
uuid = "cbdf2221-f076-402e-a563-3d30da359d67"
version = "0.6.5"

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e81c509d2c8e49592413bfb0bb3b08150056c79d"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[deps.ArrayInterface]]
deps = ["Compat", "IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "8d4a07999261b4461daae67b2d1e12ae1a097741"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "5.0.6"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Automa]]
deps = ["Printf", "ScanByte", "TranscodingStreams"]
git-tree-sha1 = "d50976f217489ce799e366d9561d56a98a30d7fe"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "0.8.2"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[deps.CairoMakie]]
deps = ["Base64", "Cairo", "Colors", "FFTW", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "SHA", "StaticArrays"]
git-tree-sha1 = "4a0de4f5aa2d5d27a1efa293aeabb1a081e46b2b"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.7.5"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "9950387274246d08af38f6eef8cb5480862a435f"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.14.0"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[deps.Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "75479b7df4167267d75294d14b58244695beb2ac"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.14.2"

[[deps.ColorBrewer]]
deps = ["Colors", "JSON", "Test"]
git-tree-sha1 = "61c5334f33d91e570e1d0c3eb5465835242582c4"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "12fc73e5e0af68ad3137b886e3f7c1eacfca2640"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.17.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "3f1f500312161f1ae067abe07d13b40f78f32e07"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.8"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.CommunityDetection]]
deps = ["ArnoldiMethod", "Clustering", "Graphs", "LinearAlgebra"]
git-tree-sha1 = "a57f873cf53496dcab9abee78f372507fbf9f411"
uuid = "d427f087-d71a-5a1b-ace0-b93392eea9ff"
version = "0.2.0"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "96b0bc6c52df76506efc8a441c6cf1adcb1babc4"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.42.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "ae02104e835f219b8930c7664b8012c93475c340"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.2"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.Dictionaries]]
deps = ["Indexing", "Random"]
git-tree-sha1 = "7e73a524c6c282e341de2b046e481abedbabd073"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.3.19"

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "5a4168170ede913a2cd679e53c2123cb4b889795"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.53"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[deps.EllipsisNotation]]
deps = ["ArrayInterface"]
git-tree-sha1 = "d064b0340db45d48893e7604ec95e7a2dc9da904"
uuid = "da5c29d0-fa7d-589e-88eb-ea29b0a81949"
version = "1.5.0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "505876577b5481e50d089c1c68899dfb6faebc62"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.6"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "80ced645013a5dbdc52cf70329399c35ce007fae"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.13.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "246621d23d1f43e3b9c368bf3b72b2331a27c286"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.2"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "cabd77ab6a6fdff49bfd24af2ebe76e6e018a2b4"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.0.0"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FreeTypeAbstraction]]
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics", "StaticArrays"]
git-tree-sha1 = "8e76bcd47f98ee25c8f8be4b9a1c60f48efa4f9e"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.9.7"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLM]]
deps = ["Distributions", "LinearAlgebra", "Printf", "Reexport", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "StatsModels"]
git-tree-sha1 = "609115155b0dc532fa5130de65ed086efd27bfbd"
uuid = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
version = "1.6.2"

[[deps.GeoInterface]]
deps = ["RecipesBase"]
git-tree-sha1 = "6b1a29c757f56e0ae01a35918a2c39260e2c4b98"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "0.5.7"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "83ea630384a13fc4f002b77690bc0afeb4255ac9"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.2"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[deps.GraphIO]]
deps = ["DelimitedFiles", "Graphs", "Requires", "SimpleTraits"]
git-tree-sha1 = "c243b56234de8afbb6838129e72a4dfccd230ccc"
uuid = "aa1b3936-2fda-51b9-ab35-c553d3a640a2"
version = "0.6.0"

[[deps.GraphMakie]]
deps = ["GeometryBasics", "Graphs", "LinearAlgebra", "Makie", "NetworkLayout", "StaticArrays"]
git-tree-sha1 = "1cbb534e0e0e8b529239500f52820e5a57016d0d"
uuid = "1ecd5474-83a3-4783-bb4f-06765db800d2"
version = "0.3.3"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "1c5a84319923bea76fa145d49e93aa4394c73fc2"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.1"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "57c021de207e234108a6f1454003120a1bf350c4"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.6.0"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "169c3dc5acae08835a573a8a3e25c62f689f8b5c"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.6.5"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "SpecialFunctions", "Test"]
git-tree-sha1 = "65e4589030ef3c44d3b90bdc5aac462b4bb05567"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.8"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[deps.ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "9a5c62f231e5bba35695a20988fc7cd6de7eeb5a"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.3"

[[deps.ImageIO]]
deps = ["FileIO", "JpegTurbo", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "464bdef044df52e6436f8c018bea2d48c40bb27b"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.1"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "87f7662e03a649cffa2e05bf19c303e168732d3e"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.2+0"

[[deps.Indexing]]
git-tree-sha1 = "ce1566720fd6b19ff3411404d4b977acd4814f9f"
uuid = "313cdc1a-70c2-5d6a-ae34-0150d3930a38"
version = "1.1.1"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "f5fc07d4e706b84f72d54eedcc1c13d92fb0871c"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.2"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "b15fc0a95c564ca2e0a7ae12c1f095ca848ceb31"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.5"

[[deps.IntervalSets]]
deps = ["Dates", "EllipsisNotation", "Statistics"]
git-tree-sha1 = "bcf640979ee55b652f3b01650444eb7bbe3ea837"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.5.4"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "91b5dcf362c5add98049e6c29ee756910b03051d"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.3"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "a77b273f1ddec645d1b7c4fd5fb98c8f90ad10a5"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.1"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "591e8dc09ad18386189610acafb970032c519707"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.3"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Loess]]
deps = ["Distances", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "46efcea75c890e5d820e670516dc156689851722"
uuid = "4345ca2d-374a-55d4-8d30-97f9976e7612"
version = "0.5.4"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "58f25e56b706f95125dcb796f39e1fb01d913a71"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.10"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "e595b205efd49508358f7dc670a940c790204629"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.0.0+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.Makie]]
deps = ["Animations", "Base64", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "Distributions", "DocStringExtensions", "FFMPEG", "FileIO", "FixedPointNumbers", "Formatting", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageIO", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MakieCore", "Markdown", "Match", "MathTeXEngine", "Observables", "OffsetArrays", "Packing", "PlotUtils", "PolygonOps", "Printf", "Random", "RelocatableFolders", "Serialization", "Showoff", "SignedDistanceFields", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "UnicodeFun"]
git-tree-sha1 = "63de3b8a5c1f764e4e3a036c7752a632b4f0b8d1"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.16.6"

[[deps.MakieCore]]
deps = ["Observables"]
git-tree-sha1 = "c5fb1bfac781db766f9e4aef96adc19a729bc9b2"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.2.1"

[[deps.MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Match]]
git-tree-sha1 = "1d9bc5c1a6e7ee24effb93f175c9342f9154d97f"
uuid = "7eb4fadd-790c-5f42-8a69-bfa0b872bfbf"
version = "1.2.0"

[[deps.MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "Test"]
git-tree-sha1 = "70e733037bbf02d691e78f95171a1fa08cdc6332"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.2.1"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "b34e3bc3ca7c94914418637cb10cc4d1d80d877d"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.3"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NaNMath]]
git-tree-sha1 = "b086b7ea07f8e38cf122f5016af580881ac914fe"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.7"

[[deps.NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "ded92de95031d4a8c61dfb6ba9adb6f1d8016ddd"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.10"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore"]
git-tree-sha1 = "18efc06f6ec36a8b801b23f076e3c6ac7c3bf153"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.2"

[[deps.NetworkLayout]]
deps = ["GeometryBasics", "LinearAlgebra", "Random", "Requires", "SparseArrays"]
git-tree-sha1 = "cac8fc7ba64b699c678094fa630f49b80618f625"
uuid = "46757867-2c16-5918-afeb-47bfcb05e46a"
version = "0.4.4"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "043017e0bdeff61cfbb7afeb558ab29536bbb5ed"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.8"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "923319661e9a22712f24596ce81c54fc0366f304"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.1+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ab05aa4cc89736e95915b01e7279e61b1bfe33b8"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.14+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "e8185b83b9fc56eb6456200e873ce598ebc7f262"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.7"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "eb4dbb8139f6125471aa3da98fb70f02dc58e49c"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.14"

[[deps.Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "1155f6f937fa2b94104162f01fa400e192e4272f"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.4.2"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "03a7a85b76381a3d04c7a1656039197e70eda03d"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.11"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3a121dfbba67c94a5bec9dde613c3d0cbcf3a12b"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.50.3+0"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "621f4f3b4977325b9128d5fae7a8b4829a0c2222"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.4"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "a7a7e1a88853564e551e4eba8650f8c38df79b37"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.1.1"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "bb16469fd5224100e422f0b027d26c5a25de1200"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.2.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "670e559e5c8e191ded66fa9ea89c97f10376bb4c"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.38"

[[deps.PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "28ef6c7ce353f0b35d0df0d5930e0d072c1f5b9b"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "d3538e7f8a790dc8903519090857ef8e1283eecd"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.5"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "d7a7aef8f8f2d537104f170139553b14dfe39fe9"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.2"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "dc84268fe0e3335a62e315a3a7cf2afa7178a734"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.3"

[[deps.RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "cdbd3b1338c72ce29d9584fdbe9e9b70eeb5adca"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.1.3"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.SIMD]]
git-tree-sha1 = "7dbc15af7ed5f751a82bf3ed37757adf76c32402"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.4.1"

[[deps.SNAPDatasets]]
deps = ["Graphs"]
git-tree-sha1 = "6c163282a557ac00ce86a37f605b7b8b8fa3124d"
uuid = "fc66bc1b-447b-53fc-8f09-bc9cfb0b0c10"
version = "0.2.0"

[[deps.ScanByte]]
deps = ["Libdl", "SIMD"]
git-tree-sha1 = "9cc2955f2a254b18be655a4ee70bc4031b2b189e"
uuid = "7b38b023-a4d7-4c5e-8d43-3f3097f304eb"
version = "0.3.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.ShiftedArrays]]
git-tree-sha1 = "22395afdcf37d6709a5a0766cc4a5ca52cb85ea0"
uuid = "1277b4bf-5013-50f5-be3d-901d8477a67a"
version = "1.0.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SignedDistanceFields]]
deps = ["Random", "Statistics", "Test"]
git-tree-sha1 = "d263a08ec505853a5ff1c1ebde2070419e3f28e9"
uuid = "73760f76-fbc4-59ce-8f25-708e95d2df96"
version = "0.4.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "8fb59825be681d451c246a795117f317ecbcaa28"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.2"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "5ba658aeecaaf96923dce0da9e703bd1fe7666f9"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.4"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.Static]]
deps = ["IfElse"]
git-tree-sha1 = "87e9954dfa33fd145694e42337bdd3d5b07021a6"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.6.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "4f6ec5d99a28e1a749559ef7dd518663c5eca3d5"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.4.3"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c3d8ba7f3fa0625b062b82853a7d5229cb728b6b"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.2.1"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "8977b17906b0a1cc74ab2e3a05faa16cf08a8291"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.16"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "25405d7016a47cf2bd6cd91e66f4de437fd54a07"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.16"

[[deps.StatsModels]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Printf", "REPL", "ShiftedArrays", "SparseArrays", "StatsBase", "StatsFuns", "Tables"]
git-tree-sha1 = "03c99c7ef267c8526953cafe3c4239656693b8ab"
uuid = "3eaba693-59b7-5ba5-a881-562e759f1c8d"
version = "0.6.29"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "57617b34fa34f91d536eb265df67c2d4519b8b98"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.5"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "aaa19086bc282630d82f818456bc40b4d314307d"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.5.4"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.isoband_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51b5eeb3f98367157a7a12a1fb0aa5328946c03c"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.3+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "78736dab31ae7a53540a6b752efc61f77b304c5b"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.8.6+1"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"
"""

# ╔═╡ Cell order:
# ╟─cbc48ca5-f1a4-4e13-9323-2fd2c43d8612
# ╟─7bb67403-d2ac-4dc9-b2f1-fdea7a795329
# ╟─e8c26849-bdd0-4dd2-ad6a-e9ddf6f7ef86
# ╠═27f62732-c909-11eb-27ee-e373dce148d9
# ╟─94b06d53-864f-43b0-ab90-0f364ef869ee
# ╟─fca4dd6b-974b-4567-b9e1-1e9ae56f2abe
# ╟─92bfdc9d-049f-4ebf-ae54-7056aeff738b
# ╟─811325db-bb90-440d-968c-bde2b975b09d
# ╟─2c28dc38-77bb-4e3d-b80e-e5b2ab221171
# ╟─eb902545-63e1-4be0-b679-24122107f2cd
# ╟─ae931f3a-6953-4464-9eac-6d9b2b7462d6
# ╟─c74c2f4c-5fae-4fed-bdc7-70ceb63afed1
# ╟─771106a8-4e23-4bcf-a40a-75cbfc464d37
# ╟─d7471179-87b7-41a8-903e-78f720bf3195
# ╟─103d0652-4595-4cc7-8dc4-18068d300f0d
# ╟─30c461b2-70b0-4487-bf94-60d92b229d07
# ╟─bc1a7dd9-c5a7-495d-92b5-60781fe182da
# ╟─f7f056fe-9908-4957-81e0-c45466d9818f
# ╟─31c81884-97cd-4fbe-8c4c-fcb70e14dacb
# ╠═9e8b7b3c-26a0-44ee-8121-daa5ec976a87
# ╠═4c4c7d3f-ebe3-4119-a319-96b92a5c43fa
# ╠═771109fa-b48f-466c-b547-f4edf0a9f6ac
# ╟─bcde3b6b-2bfd-4373-91df-1045a98e9145
# ╟─f642d550-0b64-4a17-9fc3-35970ca622f8
# ╟─e4a843fa-da54-46be-a08f-918f84a3294a
# ╠═c4d5b924-fe4c-45c8-a416-0303f38671f6
# ╠═fdc099e2-8411-4a9b-be25-0fcd1095b585
# ╠═e044f97a-a83f-464f-add2-189e7bb7ae68
# ╠═6d821d78-0549-4afb-8075-9b596981a4f4
# ╠═37d436a7-bad8-4d6d-a3ec-34296392de57
# ╟─1b805029-d4ac-4fca-be7c-cd17eec4d649
# ╟─24cf0f75-171c-4fa2-83f5-2a71734b0256
# ╟─f56f0e36-4c9f-4c62-9c58-f07ce3d0d5a5
# ╟─bb246ca8-e894-4283-a912-256d3e29671a
# ╠═b1597dba-e7c2-4602-9ff2-a09f1d6ccd38
# ╟─8bf47d42-87d3-42ab-a3e2-32a4f2fdbc37
# ╠═099d2ffa-fe76-4d07-a4fe-68451c029c75
# ╟─bad73037-2d01-4d60-b5ec-d268b20d34e5
# ╠═71b9d4bd-e280-4def-93b5-73250616e165
# ╟─ed731efa-3bc9-456a-87ea-ad7ef36b960c
# ╠═bad4cb62-9a6c-4a36-8fe9-3d194f3bccdc
# ╟─8229f4f6-ff0c-4e59-a18b-027aae6b80e1
# ╠═ebb677f5-bdf9-4d14-a568-f18fef0120b5
# ╟─37989421-2f2b-4331-9169-ef4d78edaa7f
# ╠═b8bb5987-8c90-4697-abfd-de26e1d2047a
# ╠═4eab17d0-6d18-461e-bcbf-c47a95155627
# ╠═900b6d60-6ff2-42a2-8e2b-b2858cedf4c0
# ╠═af824068-9ce8-4d05-bebc-4535c3d0a0bc
# ╠═bffc3d2a-daa2-47ce-8b40-4a331aa68375
# ╠═b0a4683a-9a33-4e91-8b09-4497b9f7ac9f
# ╟─28a3ad4f-3304-432e-8cec-6b2d93ab2073
# ╟─1e4bb2b4-ff3d-4887-b106-cdf8e72503bc
# ╠═07316d91-8833-41dc-83ae-60b74a587a40
# ╠═7a6ead52-a666-48dc-960e-4fbd1f1c2660
# ╠═181f0e3f-d234-4bad-bb4e-03e645c5284c
# ╠═3b59f57d-04be-4387-b5da-079b0078dbfc
# ╠═d632ccc4-29e9-4806-adb9-cc0f6c8f4855
# ╟─38b29ff9-fec5-4e04-8c45-06dcd3a77eab
# ╠═ae1f1a30-c8f0-4a25-a74a-bbd4a417d57d
# ╟─65bc471b-5a4d-4920-a1ec-d4d1af388161
# ╠═69a39b60-e9e4-4d2f-a356-668d20e8720f
# ╟─2ea69d44-cd00-4ae9-9bbc-9d9fbe0e0180
# ╟─7b0cbbd0-723e-4913-9065-329344e1143f
# ╠═88b4a637-bbcc-4305-8991-6ce296bf231f
# ╠═4023b2c1-8910-46d6-b04b-5e8973480a4f
# ╟─dea222a5-2938-4cd3-bf88-e3f02fd57883
# ╠═e2401207-84aa-4a73-a2ac-2800ee1ea153
# ╟─701e6154-441e-4aba-952f-cf18b841c734
# ╠═2bdc89aa-cae4-4f50-af9a-da9dfd4173f2
# ╟─d829ce22-437e-4741-9a9e-116aefbb89f1
# ╠═6c51600f-6d1e-4366-84be-efbff514c8d8
# ╟─1d4932be-8c49-48ca-bd5f-f67c7b8cbef1
# ╠═0d5c48ea-0722-4075-a841-7a2bf02d87d8
# ╟─fe4d6481-c546-4826-931a-fb7dc4d0adfc
# ╠═3e3de8b8-c96a-4d4c-9db7-de84bf42de23
# ╠═b3f7d8f3-8cd2-4deb-a64d-b4e074921f53
# ╠═baaf6c4e-d38c-4328-90ff-f393f02226fe
# ╠═d7cf904e-7dd5-42a9-a4bf-ff7961bf5dce
# ╟─0ee8bcd2-29f1-4dce-b8eb-8e12fe155e51
# ╠═1c816bc7-d5f1-4abd-a26b-e6f0c76cbead
# ╠═c04569e8-2efb-4b71-86a8-6f184576cecb
# ╠═12724ba8-995b-4ab3-be6b-d575f36cfcd7
# ╟─1cba3d46-9853-4646-999e-ecf0ecd2fa9e
# ╠═3e49645d-7203-412a-9384-c5a63e4b3c5e
# ╠═b0efd6e0-55a9-4020-9ebc-cc60d4e8717a
# ╠═23b98c4c-b474-474d-b44f-929649442c7b
# ╟─9e30d937-2a72-4fd3-b95e-df670e2a4634
# ╠═7b8075c3-89a8-4295-9809-2c73c8f96906
# ╠═1ffd0624-e663-4b43-9be3-2a39e2ecf8a7
# ╟─ee5c877b-cca7-4453-85e2-69653b8bd552
# ╠═3d6aa0c8-1333-4f43-bed8-25f458ba5efa
# ╠═2a4c3340-1eb0-4bd2-8db3-56d387f0ee3f
# ╠═4ac4e273-4e9d-46e6-92c4-c508ae2255c1
# ╟─c77d2f63-3005-4ea2-8d22-678f3a4ae679
# ╠═21d31cfd-650b-4f97-98cc-3689e1c35545
# ╟─ed2f0654-0819-49ce-b396-e1dae579e737
# ╠═435a8d08-05f7-41e5-9bb6-6e6b4107cebb
# ╠═6324f854-71ac-4419-80b1-282706840918
# ╟─fc57adf5-689d-4a0c-b91e-df9d6e44579f
# ╟─7fee896e-c25d-42d8-8653-b6ededccf1cc
# ╟─82172216-cd56-4905-b3b3-18439c557de6
# ╟─d548bc1a-2e20-4b7f-971b-1b07faaa4c13
# ╟─228e9bf1-cfd8-4285-8b68-43762e1ae8c7
# ╟─23974dfc-7412-4983-9dcc-16e7a3e7dcc4
# ╟─ff6dfa4b-73bb-48f2-b439-fe931ef7c89c
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
