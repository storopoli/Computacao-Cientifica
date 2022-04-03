### A Pluto.jl notebook ###
# v0.18.4

using Markdown
using InteractiveUtils

# ╔═╡ 27f62732-c909-11eb-27ee-e373dce148d9
begin
	using Pkg
	using PlutoUI
	
	# MLJ.jl
	using MLJ
	import EvoTrees
	
	# Dados
	using CSV
	using DataFrames
	
	# Visualizações
	using Plots
	
	# evitar conflitos com o transform de DataFrames
	using MLJ: transform
	
	# Seed
	using Random:seed!
	seed!(123);
end

# ╔═╡ ed893aee-f1a2-46c0-819d-321103d3d0c2
using MLJBase

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
# *Machine Learning* com `MLJ.jl`
"""

# ╔═╡ 92b94192-3647-49b7-baba-6d5d81d7ea19
Resource("https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg", :width => 120, :display => "inline")

# ╔═╡ 68e825fd-3c99-4bce-8377-1153949fdf77
md"""
!!! danger "⚠️ Disciplina Ferramental"
	**Esta disciplina é uma disciplina ferramental!**

	Portanto, se você não sabe o que é aprendizagem de máquina, pegue um livro-texto e estude ou pergunte pro seu orientador.

	**Sugestão de fontes**:

	Bishop, C. M. (2006). Pattern Recognition and Machine Learning. Springer. [(link)](https://www.microsoft.com/en-us/research/uploads/prod/2006/01/Bishop-Pattern-Recognition-and-Machine-Learning-2006.pdf)

	Duda, R. O., Hart, P. E., & Stork, D. G. (2012). Pattern Classification. John Wiley & Sons. [(link)](https://www.amazon.com/Pattern-Classification-Pt-1-Richard-Duda/dp/0471056693)

	Mitchell, T. M. (1997). Machine Learning. McGraw Hill. [(link)](https://www.cs.cmu.edu/~tom/mlbook.html)

	Murphy, K. P. (2012). Machine Learning: A Probabilistic Perspective (Illustrated edition). The MIT Press. [(link)](https://www.amazon.com/Machine-Learning-Probabilistic-Perspective-Computation/dp/0262018020)

"""

# ╔═╡ e2eecd6f-56f3-464d-976e-e49966064e42
md"""
# Aprendizagem de Máquina

**Aprendizagem de Máquina é uma área de estudo que fornece aos computadores a habilidade de aprender sem serem explicitamente programados**.

> Um programa de computador que aprende a partir da experiência $E$ em relação a algum tipo de tarefa $T$ e alguma medida de desempenho $P$, se o seu desempenho em $T$, conforme medido por $P$, melhora com a experiência $E$.

> Mitchell, T. M. (1997). Machine Learning. McGraw-Hill, New York.

#### Experiência ($E$)

Em aprendizagem de máquina um programa de computador **aprende sem ser explicitamente programado**. Ele aprende a partir de um **conjunto de dados que expressa toda experiência ($E$)** que desejamos ensina-lo. Esse conjunto de dados é chamado de **conjunto de treinamento** (ou treino).

* **Aprendizagem Supervisionada**: o conjunto de treinamento é composto por amostras de **entradas**/**saídas**.
* **Aprendizagem Não-Supervisionada**: conjunto de treinamento é composto por amostras de **entradas apenas**.
* **$(HTML("<s>Aprendizagem por Reforço</s>"))**

#### Tarefas ($T$)

* **Classificação**: Supervisionada qualitativa
* **Regressão**: Supervisionada quantitativa
* **Agrupamento**: Não-supervisionada

#### Desempenho ($P$)

Para medir o desempenho de um algoritmo de aprendizagem de máquina é preciso de uma medida de desempenho para mensurar a qualidade do processo de aprendizagem. Essa medida é conhecida como **função de custo** ou **função de erro**. Essa função é definida de acordo com o **tipo de problema** (aprendizagem supervisionada ou não-supervisionada). Essa função contém um conjunto de parâmetros a serem otimizados pelo algoritmo de aprendizagem de máquina.

De maneira geral, pode-se dizer que o **objetivo do algoritmo de aprendizagem de máquina é otimizar (aprender) o conjunto de parâmetros de tal forma que resultado da função seja o mínimo possível**. Isso significa que algoritmo tem uma **alta taxa de aprendizagem** e uma **baixa taxa de erro**.

* Dividir os dados em
   * **Treino**
   * **Teste**: aqui eu mensuro desempenho ($P$)
"""

# ╔═╡ 1006f0c6-d06c-4584-bff9-6834fa360734
let
	# https://discourse.julialang.org/t/plotting-decision-boundary-regions-for-classifier/21397/5
	
	N = 3
	r = 0:.002:1
	p = rand(ComplexF64, 40, N)

	# classifier: returns 1, 2, or 3 for any given (x, y)
	f(x, y) = findmin(sum(abs.(x + y*im .- p); dims=1)[:])[2]

	# colors for the N regions
	c = [cgrad(:lighttest)[z] for z=0:1/(N-1):1]'

	# animate!
	anim = @animate for d = 0:.03:5π
		contour(r, r, f, f=true, nlev=N, c=:lighttest, leg=:none)
    	display(scatter!(reim(p)..., c=c, lims=(0,1)))
   		p += .005([cis(4sin(.3d)+2n*π/N) for n=1:N]'.+.5(1+im).-p)
	end
	
	gif(anim, fps=30)
end

# ╔═╡ 5f41f994-4107-438c-9035-491fb9a123cb
md"""
!!! tip "💡 No Free Lunch Theorem (NFL)"
    “Se você faz nenhum pressuposto dos dados, não há razão para preferir um modelo por outro”

	> Wolpert, D. H. (1996). The Lack of a Priori Distinctions between Learning Algorithms. Neural Computation, 8(7), 1341–1390. <https://doi.org/10.1162/neco.1996.8.7.1341>


"""

# ╔═╡ 2131aedb-5b69-46cf-857a-c66b0479be21
md"""
# Dataset `palmerpenguins`

É um dataset aberto sobre pinguins que foram encontrados próximos da estação de Palmer na Antártica.

344 penguins e 8 variáveis:

- `species`: uma das três espécies (Adélie, Chinstrap ou Gentoo)
- `island`: uma das ilhas no arquipélago Palmer na Antartica (Biscoe, Dream ou Torgersen)
- `bill_length_mm`: comprimento do bico em milímetros
- `bill_depth_mm`: altura do bico em milímetros
- `flipper_length_mm`: largura da asa em milímetros
- `body_mass_g`: massa corporal em gramas
- `sex`: sexo (female ou male)

Ele está na minha pasta `data/` tanto como `penguins.csv` como `penguins.xlsx`

> Dataset com licença creative commons de [`allisonhorst/palmerpenguins`](https://github.com/allisonhorst/palmerpenguins).
"""

# ╔═╡ 6de77848-8e4f-4246-8d34-c97f2560fc66
md"""
$(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/palmerpenguins_1.png?raw=true", :width => 338))
$(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/palmerpenguins_2.png?raw=true", :width => 338))
"""

# ╔═╡ 6a59a026-6ed7-4230-91d5-7efd97ab22b5
begin
	penguins_file = joinpath(pwd(), "..", "data", "penguins.csv")
	penguins = CSV.read(penguins_file, DataFrame; missingstring="NA")
	dropmissing!(penguins)
end

# ╔═╡ bb1c629d-d600-471b-887b-6fc354c51411
md"""
# [`MLJ.jl`](https://github.com/alan-turing-institute/MLJ.jl)
"""

# ╔═╡ b332694c-01a3-47b1-a910-29f7ef1397d8
Resource("https://github.com/alan-turing-institute/MLJ.jl/blob/dev/material/MLJLogo2.svg?raw=true", :width => 200)

# ╔═╡ 63723f2f-4cb2-4428-822c-240847f22caf
md"""
`MLJ.jl` (Machine Learning in Julia) é uma caixa de ferramentas escrita em Julia, fornecendo uma interface comum e meta-algoritmos para **selecionar**, **ajustar**, **avaliar**, **compor** e **comparar** os modelos de **aprendizagem de máquina** escrito em Julia e outras linguagens. Em particular, o MLJ também engloba um grande número de modelos [`scikit-learn`](https://scikit-learn.org/stable/).

!!! tip "💡 Paralelismo de MLJ.jl"
    Por padrão [**`MLJ.jl` executa de maneira serial**](https://alan-turing-institute.github.io/MLJ.jl/dev/acceleration_and_parallelism/) na CPU pelo recurso computacional `CPU1()`. Para ver qual recurso computacional `MLJ.jl` está usando use `MLJ.default_resource()`. Para **trocar** use:

	```julia
	# Computação Distribuída
	MLJ.default_resource(CPUProcesses())

	# Multithreaded
	MLJ.default_resource(CPUThreads())
	```

## Funcionalidades de `MLJ.jl`

* **Agnóstico de Dados**, treina modelos em quaisquer dados suportados pela interface [`Tables.jl`](https://github.com/JuliaData/Tables.jl) (isso inclui `DataFrames.jl`),

* Suporte extensivo para **composição de modelos** (*pipelines* e redes de aprendizagem),

* **Sintaxe conveniente** para afinar (_tune_) e avaliar modelos (composicionais).

* Interface consistente para lidar com **previsões probabilísticas**.

* Interface de **afinamento** (_tuning_) extensível, com um número crescente de estratégias de **otimização** e boa interface com **composição de modelos**.

> Mais informações estão disponíveis no [`MLJ.jl` _design paper_](https://github.com/alan-turing-institute/MLJ.jl/blob/master/paper/paper.md).
"""

# ╔═╡ 9a0cd5b8-2012-4fda-8fb4-5df8f5e6c4a0
md"""
## Patrocinadores do `MLJ.jl`

`MLJ.jl` tem os seguintes patrocinadores:
"""

# ╔═╡ a908f333-be8a-4fe8-a34d-66b539fbd9aa
md"""
$(Resource("https://github.com/alan-turing-institute/MLJ.jl/blob/dev/material/Turing_logo.png?raw=true", :width => 100))
$(Resource("https://github.com/alan-turing-institute/MLJ.jl/blob/dev/material/UoA_logo.png?raw=true", :width=> 100))
$(Resource("https://github.com/alan-turing-institute/MLJ.jl/blob/dev/material/IQVIA_logo.png?raw=true", :width=> 100))
$(Resource("https://github.com/alan-turing-institute/MLJ.jl/blob/dev/material/warwick.png?raw=true", :width=> 100))
$(Resource("https://github.com/alan-turing-institute/MLJ.jl/blob/dev/material/julia.png?raw=true", :width=> 100))
"""

# ╔═╡ 6aa06b7f-c169-4dc6-88ac-c422015667f9
md"""
## Modelos

Mais de 160 modelos ([lista completa](https://alan-turing-institute.github.io/MLJ.jl/dev/list_of_supported_models/)):
"""

# ╔═╡ 21574085-1021-4ae5-9e84-d3b5b1641981
MLJ.models() |> DataFrame

# ╔═╡ 1b6458e1-1fca-4077-bbc5-a9ee5bbff938
md"""
## Construção de Modelos com [`machine`](https://alan-turing-institute.github.io/MLJ.jl/dev/machines/#Constructing-machines)

`MLJ.jl` usa um construtor de modelos com a função [`machine`](https://alan-turing-institute.github.io/MLJ.jl/dev/machines/#Constructing-machines). Temos dois construtores principais:

```julia
machine(model::Unsupervised, X)   # Não-Supervisionado
machine(model::Supervised, X, y)  # Supervisionado
```

Para treinar os algoritmos usamos o **`fit!(machine)`**.

Para informações sobre os modelos use o `info`:

> OBS: note nos campos `is_pure_julia`, `input_scitype` e `target_scitype`
"""

# ╔═╡ d3689c37-5175-4dd9-8002-8d1173dbcb4a
info_trees = info("EvoTreeClassifier")

# ╔═╡ b82c5e3d-2c17-4017-8b63-1d79f4b64eaf
info_trees.is_pure_julia # 😎

# ╔═╡ 0b3a9f17-2232-47a2-9e12-5ac0c367c988
info_trees.input_scitype

# ╔═╡ ab35f314-d336-422e-9bd3-1a73ef31dd93
info_trees.target_scitype

# ╔═╡ 2c31507c-db7c-475a-9c0f-f3539b536936
info_cluster = info("KMeans", pkg="Clustering")

# ╔═╡ 92765af5-ecc2-4f19-9008-322a762a2e16
info_cluster.is_pure_julia # 😎

# ╔═╡ 4a6c5b51-a0d0-42e6-955f-920465c93809
info_cluster.input_scitype

# ╔═╡ a857f289-a8c0-471d-8317-679856a96cd9
md"""
## `ScientificTypes`

Além disso, `MLJ.jl` usa um sistema de tipos "científicos" com base em [`JuliaAI/ScientificTypes.jl`](https://github.com/JuliaAI/ScientificTypes.jl) para definir qual o tipo dos *inputs* `X` e `y`.

Os tipos científicos básicos escalar (unidimensional) são `Continuous`, `Multiclass{N}`, `OrderedFactor{N}` and `Count`.
"""

# ╔═╡ 297b317f-cbf9-4ce9-894e-2907cb808900
Resource("https://github.com/alan-turing-institute/MLJ.jl/blob/dev/docs/src/img/scitypes.png?raw=true")

# ╔═╡ 396d2361-01a6-44cd-8367-1c579c8e272f
scitype(3.14)

# ╔═╡ 9fe2e789-37fa-4ef9-a227-d883a5cfaf0a
scitype(42)

# ╔═╡ a87a0495-6743-4ad7-a206-2f02c8b65cea
md"""
Você pode convertê-los com função `coerce`:
"""

# ╔═╡ 9b9a99e7-4b76-47ad-8b16-650e16d72334
x1 = coerce(["yes", "no", "yes", "maybe"], Multiclass)

# ╔═╡ 993da359-7e9d-4ba1-8a2a-81cf10caf833
scitype(x1)

# ╔═╡ 3f55b463-8061-4a00-a5d6-63b345f74828
X = DataFrame(; x1, x2=rand(4), x3=rand(4))

# ╔═╡ 42b0a1e9-7fd5-4124-b5c9-b90b5a862f4d
scitype(X)

# ╔═╡ 71c4fc48-b1ea-4a0e-adcb-9a53f5593e0c
md"""
## Dados Tabulares

Todos os contêineres de dados compatíveis com a interface [`Tables.jl`](https://github.com/JuliaData/Tables.jl) (que inclui todos os formatos de origem listados [aqui](https://github.com/JuliaData/Tables.jl/blob/master/INTEGRATIONS.md)) têm o tipo científico `Table{K}`, onde `K` depende dos tipos científicos das colunas, que podem ser inspecionados individualmente usando **`schema`**:
"""

# ╔═╡ 7fff29b7-11f6-4288-bc0b-60b34bfe531d
schema(X)

# ╔═╡ c64b7d51-0496-4c56-b5de-da351b098cf6
md"""
!!! danger "⚠️ Matrizes em MLJ"
    `MLJ.jl` **não aceita matrizes**. Você precisa convertê-la para `MLJ.table`:

	```julia
	MLJ.table(X)
	```
"""

# ╔═╡ e4f67d26-43ce-4001-97bd-0fc89f8c832c
schema(MLJ.table(Matrix(X)))

# ╔═╡ 40f8ceda-3e45-491f-9f71-922929da2ac4
md"""
## Modelos e `ScientificTypes`

A maioria dos dados tabulares devem ser tratados para os modelos de `MLJ.jl`.
"""

# ╔═╡ 06357615-29ac-4e9d-8dae-28a4e74e9cd1
md"""
!!! tip "💡 Continuous"
    O ideal é deixar quase tudo de `X` como `Continuous`.
"""

# ╔═╡ c63657cc-d735-4db2-b9c1-29789989d7f1
md"""
!!! danger "⚠️ Dados Categóricos"
    Variáveis categóricas são sempre um problema para algoritmos de aprendizagem de máquina. `MLJ.jl` lida com variáveis qualitativas tratando-as como **`Multiclass`**.

	> Para mais detalhes de dados categóricos veja a [documentação do `MLJ.jl`](https://alan-turing-institute.github.io/MLJ.jl/dev/working_with_categorical_data/#Working-with-Categorical-Data).
"""

# ╔═╡ 8d4d3743-bb81-47e2-98f4-6e09e712fdce
describe(penguins)

# ╔═╡ 380ff0ef-58a6-4ac5-847c-6c6f6b21b989
md"""
### `coerce`

Precisamos fazer umas alterações com o `coerce`:
"""

# ╔═╡ b419612d-cf8c-4b7e-8b46-ada8104590dd
penguins_coerced = coerce(
	penguins,
	:species => Multiclass,
	:island => Multiclass,
	:sex => Multiclass,
	:year => Count
)

# ╔═╡ 03c31d2a-d9f6-4600-8839-054944efaa5a
md"""
### `unpack`

`unpack` divide qualquer tabela compatível com `Tables.jl` em tabelas (ou vetores) menores conforme as seleções das funções de filtragem. A sintaxe é assim:

```julia
t1, t2, ..., tk = unpack(table, f1, f2, ... fk;
                           shuffle=false)
```

> `shuffle` se for `true` as linhas da `table` serão embaralhadas.
"""

# ╔═╡ 18bf93dd-cb23-4c3a-be11-5a9c74305422
X_penguins, y_penguins = unpack(
	penguins_coerced,
	≠(:species),      # todas as que não são :species
	colname -> true;  # todas as restantes (apenas :species)
	shuffle=true      # embaralha por favor...
)

# ╔═╡ 7e336b78-7557-4212-b1bf-cc6160fcc8f7
first(X_penguins, 3)

# ╔═╡ 671f8b90-a02a-4bda-a5dd-501c77405ead
first(y_penguins, 3) # olha CategoricalArrays fazendo uma aparição especial...

# ╔═╡ 0b0103e8-fb07-448c-8fe1-f1b48c8f06a9
md"""
### Transformadores de Dados

Além disso muitas vezes precisamos **transformar variáveis**.

`MLJ.`jl possui alguns [transformadores](https://alan-turing-institute.github.io/MLJ.jl/dev/transformers/):

* **`Standardizer`**: `μ=0` e `σ=1`.


* **`OneHotEncoder`**: quebra `var_cat` em variáveis binárias `var_cat_1`, `var_cat_2`, ..., `var_cat_k`. `drop_last=true` mantém em `k-1`.


* **`ContinuousEncoder`**: similar ao `OneHotEncoder` mas forçando para variáveis `OrderedFactor` para continuous ao invés de fazer variáveis binárias. `drop_last=true` mantém em `k-1`.


* **`FeatureSelector`**: seletor de variáveis.


* **`FillImputer`**: inputor de dados faltantes, pega todos os valores `missing` e inputa com alguma função que você quiser. Por padrão `Continous => median`, `Count => round(median)` e `Multiclass/OrderedFactor => mode`.
"""

# ╔═╡ 1445afb0-a67a-4465-982e-4dd511db1b2d
one_hot = OneHotEncoder()

# ╔═╡ 35835160-cb4f-4e67-ae0f-d7654e20cef1
mach_one_hot = machine(one_hot, X_penguins)

# ╔═╡ 84fab6a3-b877-427f-b9b6-81c0d7ec4f12
fit!(mach_one_hot)

# ╔═╡ afd7f8eb-8691-4ea8-ab3b-113bb1a9943d
X_penguins_one_hot = transform(mach_one_hot, X_penguins)

# ╔═╡ af993b4c-7809-4450-9656-8a5d47f3a7a5
scitype(X_penguins_one_hot) # tudo `Continuous` e `Count`

# ╔═╡ e0173c12-56bd-44b0-9193-325a184d18c2
md"""
Ainda falta uma variável como `Count` para `Continuous`:
"""

# ╔═╡ fd9c308f-795d-44f3-9258-c683bbc7faed
cont_enc = ContinuousEncoder()

# ╔═╡ 5de484ef-473e-44ea-87ee-3da637b096e6
mach_enc = machine(cont_enc, X_penguins_one_hot)

# ╔═╡ 5ead921a-8ac6-47e6-a40f-ea0d5e530de6
fit!(mach_enc)

# ╔═╡ 8f9e9882-d98d-46e4-ab9d-979baaf44f4a
X_penguins_cont = transform(mach_enc, X_penguins_one_hot)

# ╔═╡ 898f907c-118f-43c0-a70d-fb205009191b
scitype(X_penguins_cont) # tudo `Continuous`

# ╔═╡ 6788ff40-771a-4424-85ad-a80ad483a74f
md"""
### `matching`

A função [`matching`](https://alan-turing-institute.github.io/MLJ.jl/dev/model_search/#Matching-models-to-data) mostra quais modelos de `MLJ.jl` você pode usar com seus dados:

* **Supervisionada**: `models(matching(X, y))`
* **Não-Supervisionada**: `models(matching(X))`

Agora só escolher qual modelo você quer usar com seu `X` e `y`:
"""

# ╔═╡ 05f05f8a-2e34-48a0-966d-1fcae607b3f4
# Supervisionada
models(matching(X_penguins_cont, y_penguins))

# ╔═╡ 32a329a4-defb-40e6-b7c6-efcdef282237
# Não-Supervisionada
models(matching(X_penguins_cont))

# ╔═╡ 37d62fc2-85cb-4d78-86ff-3f510515c441
md"""
## Instanciar Modelos com [`machine`](https://alan-turing-institute.github.io/MLJ.jl/dev/machines/)

Agora vem a parte divertida! Treinar o modelo de aprendizagem de máquina com seus dados. Para isso vou usar o [`EvoTrees.jl`](https://github.com/Evovest/EvoTrees.jl) que é uma  implementação pura em Julia  de [*Gradient Boosting*](https://en.wikipedia.org/wiki/Gradient_boosting) (_XGBoost_) que roda tanto na CPU quanto na GPU.

Primeiro vamos carregar o pacote `EvoTrees.jl` com o [`@load`](https://alan-turing-institute.github.io/MLJ.jl/dev/loading_model_code/):
"""

# ╔═╡ ea9dd6d0-ac12-45a8-9a40-bc9e182fe7c1
EvoTree = @load EvoTreeClassifier

# ╔═╡ 822ca4dd-5e4c-4c4c-a549-bc88f2cb9e17
md"""
E agora criamos um objeto do `EvoTreeClassifier` usando o construtor padrão que nos dá alguns parâmetros padrões já definidos:
"""

# ╔═╡ d06ade6e-7a11-4c88-b8fc-047721d2e233
evotree = EvoTree() # se tiver GPU coloca `device="gpu"`

# ╔═╡ 169aa931-4de5-4cd2-86d8-71d63b8c33d1
md"""
### Funções de Custo/Erro

Como você viu `evotree` foi instanciado com `metric=:mlogloss`. Você pode escolher outra função de custo/erro se quiser.

Tem uma porrada:
"""

# ╔═╡ f803b32f-b2ce-4ee4-ba53-33bc75eb4641
measures()

# ╔═╡ ecaeb2e1-0387-4bae-a264-986d483b8962
md"""
Ainda bem que o nosso modelo já define uma padrão...
"""

# ╔═╡ 4155d37a-c01c-4521-aaa6-ab9330a05741
md"""
### Acoplar Modelos com Dados com [`machine`](https://alan-turing-institute.github.io/MLJ.jl/dev/machines/#Constructing-machines)

Um `machine` acopla um modelo (i.e. algoritmo + hiperparâmetros) para os dados:
"""

# ╔═╡ 486c686b-35c2-4b5f-964e-c5107263e7ba
mach_evotree = machine(evotree, X_penguins_cont, y_penguins)

# ╔═╡ 0cb3093f-319b-496e-b0d0-1bcae576fbca
md"""
### Quebrar Dados em Treino e Teste com [`partition`](https://alan-turing-institute.github.io/MLJ.jl/dev/getting_started/#Fit-and-predict)

A função `partition` particiona os dados em treino e teste, basta passar o tamanho da partição como um `Float` entre `0` e `1` e se é para embaralhar as observações ou não com `shuffle`:
"""

# ╔═╡ 968e1ccc-cc91-46c6-8ebd-31997c29a0de
train, test = partition(eachindex(y_penguins), 0.7; shuffle=true)

# ╔═╡ 28f46f69-1068-4de1-addf-b9d619c065c3
md"""
### Treinar Modelos com [`fit!`](https://alan-turing-institute.github.io/MLJ.jl/dev/getting_started/#Fit-and-predict)

Um  `machine` instanciado pode ser treinado com `fit!`.

É claro que queremos apenas que o modelo aprenda com os dados de treino, portanto passamos o vetor `train` de índices retornado pelo `partition` como argumento para `rows`:
"""

# ╔═╡ 473ac112-40b0-4ca6-8b22-c06d146d929b
fit!(mach_evotree, rows=train)

# ╔═╡ aab92abc-9184-4335-958b-241a5c5bae48
md"""
### Fazer Predições de Modelos com [`predict`](https://alan-turing-institute.github.io/MLJ.jl/dev/getting_started/#Fit-and-predict)

Agora com o modelo treinado precisamos fazer a predição com a função `predict`.

Agora queremos prever os dados de teste com o vetor `test` de índices retornado pelo `partition` como indexador da matriz de dados:
"""

# ╔═╡ 28f80ee6-8924-4e0a-893a-6a0333e7f5ae
ŷ = predict(mach_evotree, X_penguins_cont[test, :]) #Python y_hat Julia é \hat <TAB> y

# ╔═╡ a7717b28-050c-4f0e-8ef2-000df5f57f6f
md"""
Por padrão (em alguns modelos) `predict` retorna uma distribuição, para conseguirmos um único valor precisamo usar a função `predict_mode`:
"""

# ╔═╡ 22660ebc-77fc-452d-a146-a0fa9832b4eb
ŷ_mode = predict_mode(mach_evotree, X_penguins_cont[test, :])

# ╔═╡ 6ffa49fe-405f-4bde-9f56-a15dfc976539
md"""
## [Métricas de Desempenho](https://alan-turing-institute.github.io/MLJ.jl/dev/performance_measures/)

* **`accuracy`**: Acurácia
* **`confusion_matrix`**: Matriz de Confusão
* **`roc_curve`**: Curva ROC
"""

# ╔═╡ c46221e9-3a4f-4833-8995-287981d2601b
accuracy(ŷ_mode, y_penguins[test])

# ╔═╡ 2f62cedd-0596-4fff-83ae-8243dd958bb4
confusion_matrix(ŷ_mode, y_penguins[test])

# ╔═╡ 6e2e8861-5961-4bf0-a1f1-52f063958288
# False Positive Rate - fpr
# True Positive Rate - tpr
# Threshold - tr
fpr, tpr, ts = roc_curve(ŷ, y_penguins[test])

# ╔═╡ 43501e8c-a934-47c8-adb6-13cd28adf827
plot(fpr, tpr)

# ╔═╡ ff46cab0-38a5-43c1-9419-bc7c1d916714
md"""
## Validação Cruzada com [`evaluate`](https://alan-turing-institute.github.io/MLJ.jl/dev/getting_started/#Choosing-and-evaluating-a-model)

Se você quiser avaliar seu modelo com [**Validação Cruzada**](https://pt.wikipedia.org/wiki/Valida%C3%A7%C3%A3o_cruzada) existe a função `evaluate` (aceita um modelo, `X` e `y`) e a função `evaluate!` (aceita um `machine` apenas). Como argumentos temos:

* **`resampling`**: um dos subtipos de `MLJ.ResamplingStrategy`, por padrão `CV()` (_**C**ross-**V**alidation_)/
* **`measure`**: medida de desempenho, por padrão usa a do modelo/`machine`.
* **`rows`**: vetor de índices de linhas a serem usadas para a avaliação.
* **`operation`**: uma operação para predição, padrão é `predict`, mas pode `predict_mean`, `predict_mode` or `predict_median`.
"""

# ╔═╡ c7681745-c6d1-41e1-b15d-c214940dc662
subtypes(MLJ.ResamplingStrategy)

# ╔═╡ 10783f9c-1326-4554-bfe5-51291f51a877
evaluate(
	evotree,          # modelo
	X_penguins_cont,  # X completo
	y_penguins;       # y completo
	resampling=CV(
		nfolds=6,     # padrão é 6
		shuffle=true  # padrão é nothing
		)
	)

# ╔═╡ d9499aef-d45f-481c-81b5-35c47fc9d766
evaluate(
	evotree,               # modelo
	X_penguins_cont,       # X completo
	y_penguins;            # y completo
	resampling=CV(
		nfolds=6,          # padrão é 6
		shuffle=true       # padrão é nothing
		),
	measure=accuracy,      # acurácia
	operation=predict_mode # prever a moda da distribuição
)

# ╔═╡ dbd7dd09-2aa9-41a5-8103-ffa8d71fda43
md"""
## Ajuste (_Tuning_) de Hiperparâmetros com [`TunedModel`](https://alan-turing-institute.github.io/MLJ.jl/dev/tuning_models/)

O _tuning_ de hiperparâmetros pode ser [feito de várias maneiras](https://github.com/JuliaAI/MLJTuning.jl#what-is-provided-here) mas as três principais são:

* **`Grid`**: busca em um _grid_ multidimensional.
* **`RandomSearch`**: busca aleatória.
* **`LatinHypercube`**: busca usando um _Latin hypercube_.

Vou demonstar um `RandomSearch`. Primeiro vemos que hiperparâmetros nosso modelo tem:
"""

# ╔═╡ e0856fbb-e9c7-41cb-a3cd-141bb400ff80
evotree

# ╔═╡ 74df1556-2f1d-4451-a79f-bb107fc7d208
md"""
Vamos "tunar" o `nrounds` e a regularização L2 `λ`. Para isso criamos um objeto `range` com os valores plausíveis dos hiperparâmetros:
"""

# ╔═╡ d8776d26-2d32-495f-a9a0-4b34fa0467df
r_nrounds = range(evotree, :nrounds; lower=1, upper=20, scale=:linear)

# ╔═╡ b799b2ac-b9cf-4558-b17e-211773225a82
r_λ = range(evotree, :λ; lower=0.01, upper=10.0, scale=:log)

# ╔═╡ 563e68a3-b9af-4672-91cc-f8f0ae0c3ed9
md"""
Agora instanciamos um `TunedModel` com nosso modelo os `range`s criados e passando `tuning=RandomSearch()`:
"""

# ╔═╡ 2e22a842-a678-4c86-87e0-b604d08f5f67
tuning_tree = TunedModel(model=evotree, # seu modelo
                         tuning=RandomSearch(),
                         resampling=CV(nfolds=6),
                         range=[r_nrounds, r_λ]);

# ╔═╡ d13452ee-4af5-44eb-b03e-eaa4a369d592
md"""
Por fim, criamos um `machine` com esse `TunedModel` e damos um `fit!`:
"""

# ╔═╡ 6a8cceaf-f760-40ed-8265-d36db29b1d6d
mach_tuning_tree = machine(tuning_tree, X_penguins_cont, y_penguins)

# ╔═╡ a82d5b42-d883-4730-a4b8-3b12941e771d
fit!(mach_tuning_tree)

# ╔═╡ 2cc32659-9ce8-4faf-ab15-9cfc616d1f52
md"""
E vemos o melhor modelo com `fitted_params` do `best_model` do `machine`:
"""

# ╔═╡ d81bc8da-d814-4eb4-90d3-be3f11c00aff
fitted_params(mach_tuning_tree).best_model

# ╔═╡ 6fa97a3e-9d00-4cfc-975e-a0905206b073
md"""
Para informações mais detalhadas veja o `report(machine)`:
"""

# ╔═╡ a403a2a9-7f60-42c0-bfd7-3292eb1b871e
report(mach_tuning_tree).best_model

# ╔═╡ 4a0e0b0c-464e-48d3-8819-a135aff2ab3b
evaluate!(
	mach_tuning_tree;      # machine
	resampling=CV(
		nfolds=6,          # padrão é 6
		shuffle=true       # padrão é nothing
		),
	measure=accuracy,      # acurácia
	operation=predict_mode # prever a moda da distribuição
)

# ╔═╡ 58723900-8aa3-42a8-8853-2b6ef025f2fb
md"""
!!! tip "💡 Tuning de Hiperparâmetros"
    Tem MUITAS maneiras de "tunar"os hiperparâmetros do seu modelo. Não deixe de ver a [documentação de `MLJ.jl`](https://alan-turing-institute.github.io/MLJ.jl/dev/tuning_models)
"""

# ╔═╡ 20753d0b-149a-48c1-917f-8b8828bbbb20
md"""
Podemos plotar os `TunedModel` com a função `plot` de `Plots.jl`:

> Há uma "receita" (*recipe*) pré-definida já.
"""

# ╔═╡ a4237bda-06fa-4569-b917-bdf9e80f0bed
plot(mach_tuning_tree)

# ╔═╡ fe42d84b-e76c-464f-8d7e-78f3b7edf63c
md"""
## Composição de Modelos com [`@pipeline`](https://alan-turing-institute.github.io/MLJ.jl/dev/composing_models/)

O legal do `MLJ.jl` é que eu consigo fazer tudo isso que fizemos até agora virar um modelo gigante composicional:
"""

# ╔═╡ fc456ae3-5094-4034-9740-5092f581ec2a
pipe = @pipeline(OneHotEncoder(),
				 ContinuousEncoder(),
				 evotree,
				 name="Meu Pipeline"
)

# ╔═╡ 0f29120d-35da-472c-a7e5-ea9128a057d6
evaluate(
	pipe,
	X_penguins,                      # X_coerced
	y_penguins;                      # y transformado
	resampling=CV(
		nfolds=6,                    # padrão é 6
		shuffle=true                 # padrão é nothing
		),
	measure=accuracy,                # acurácia
	operation=predict_mode           # prever a moda da distribuição
)

# ╔═╡ 8e95732c-72c3-4b59-b78c-35c273252c33
md"""
!!! info "💁 Fairness.jl"
    Muito tem se falado sobre **discriminação algorítmica**. Então se você quer saber **se o seu algoritmo é justo** veja o [`Fairness.jl`](https://github.com/ashryaagr/Fairness.jl) que tem uma interface excelente com `MLJ.jl`.
"""

# ╔═╡ cd83c034-edfe-4696-973b-55ec100eb5ab
HTML("
<style>.embed-container { position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; } .embed-container iframe, .embed-container object, .embed-container embed { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }</style><div class='embed-container'><iframe src='https://www.youtube.com/embed/Ij0exPwmT2w' frameborder='0' allowfullscreen></iframe></div>
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

# ╔═╡ 7b455b83-b223-4b95-bd82-e7a5380633f4
md"""
# Licença

Este conteúdo possui licença [Creative Commons Attribution-ShareAlike 4.0 Internacional](http://creativecommons.org/licenses/by-sa/4.0/).

[![CC BY-SA 4.0](https://licensebuttons.net/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
EvoTrees = "f6006082-12f8-11e9-0c9c-0d5d367ab1e5"
InteractiveUtils = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
MLJ = "add582a8-e3ab-11e8-2d5e-e98b27df1bc7"
MLJBase = "a7f614a8-145f-11e9-1d2a-a57a1082229d"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
CSV = "~0.10.4"
DataFrames = "~1.3.2"
EvoTrees = "~0.9.6"
MLJ = "~0.17.3"
MLJBase = "~0.19.8"
Plots = "~1.27.4"
PlutoUI = "~0.7.38"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ARFFFiles]]
deps = ["CategoricalArrays", "Dates", "Parsers", "Tables"]
git-tree-sha1 = "e8c8e0a2be6eb4f56b1672e46004463033daa409"
uuid = "da404889-ca92-49ff-9e8b-0aa6b4d38dc8"
version = "1.4.1"

[[AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "6f1d9bc1c08f9f4a8fa92e3ea3cb50153a1b40d4"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.1.0"

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "af92965fb30777147966f58acb05da51c5616b5f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.3"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[BFloat16s]]
deps = ["LinearAlgebra", "Printf", "Random", "Test"]
git-tree-sha1 = "a598ecb0d717092b5539dbbe890c98bac842b072"
uuid = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"
version = "0.2.0"

[[BSON]]
git-tree-sha1 = "306bb5574b0c1c56d7e1207581516c557d105cad"
uuid = "fbb218c0-5317-5bc6-957e-2ee96dd4b1f0"
version = "0.3.5"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "873fb188a4b9d76549b81465b1f75c82aaf59238"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.4"

[[CUDA]]
deps = ["AbstractFFTs", "Adapt", "BFloat16s", "CEnum", "CompilerSupportLibraries_jll", "ExprTools", "GPUArrays", "GPUCompiler", "LLVM", "LazyArtifacts", "Libdl", "LinearAlgebra", "Logging", "Printf", "Random", "Random123", "RandomNumbers", "Reexport", "Requires", "SparseArrays", "SpecialFunctions", "TimerOutputs"]
git-tree-sha1 = "a28686d7c83026069cc2505016269cca77506ed3"
uuid = "052768ef-5323-5732-b1bb-66c8b64840ba"
version = "3.8.5"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "109664d3a6f2202b1225478335ea8fea3cd8706b"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.5"

[[CategoricalDistributions]]
deps = ["CategoricalArrays", "Distributions", "Missings", "OrderedCollections", "Random", "ScientificTypesBase", "UnicodePlots"]
git-tree-sha1 = "8c340dc71d2dc9177b1f701726d08d2255d2d811"
uuid = "af321ab8-2d2e-40a6-b165-3d674595d28e"
version = "0.1.5"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "9950387274246d08af38f6eef8cb5480862a435f"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.14.0"

[[ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "12fc73e5e0af68ad3137b886e3f7c1eacfca2640"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.17.1"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "3f1f500312161f1ae067abe07d13b40f78f32e07"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.8"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "96b0bc6c52df76506efc8a441c6cf1adcb1babc4"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.42.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f74e9d5388b8620b4cee35d4c5a618dd4dc547f4"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.3.0"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "ae02104e835f219b8930c7664b8012c93475c340"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.2"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "5a4168170ede913a2cd679e53c2123cb4b889795"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.53"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[EarlyStopping]]
deps = ["Dates", "Statistics"]
git-tree-sha1 = "98fdf08b707aaf69f524a6cd0a67858cefe0cfb6"
uuid = "792122b4-ca99-40de-a6bc-6742525f08b6"
version = "0.3.0"

[[EvoTrees]]
deps = ["BSON", "CUDA", "CategoricalArrays", "Distributions", "MLJModelInterface", "NetworkLayout", "Random", "RecipesBase", "SpecialFunctions", "StaticArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "fdbf496dd4939fd308753865828b7060efbf0009"
uuid = "f6006082-12f8-11e9-0c9c-0d5d367ab1e5"
version = "0.9.6"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[ExprTools]]
git-tree-sha1 = "56559bbef6ca5ea0c0818fa5c90320398a6fbf8d"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.8"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "80ced645013a5dbdc52cf70329399c35ce007fae"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.13.0"

[[FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "129b104185df66e408edd6625d480b7f9e9823a0"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.18"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "246621d23d1f43e3b9c368bf3b72b2331a27c286"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.2"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "cabd77ab6a6fdff49bfd24af2ebe76e6e018a2b4"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.0.0"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FreeTypeAbstraction]]
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics", "StaticArrays"]
git-tree-sha1 = "8e76bcd47f98ee25c8f8be4b9a1c60f48efa4f9e"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.9.7"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "51d2dfe8e590fbd74e7a842cf6d13d8a2f45dc01"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.6+0"

[[GPUArrays]]
deps = ["Adapt", "LLVM", "LinearAlgebra", "Printf", "Random", "Serialization", "Statistics"]
git-tree-sha1 = "9010083c218098a3695653773695a9949e7e8f0d"
uuid = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
version = "8.3.1"

[[GPUCompiler]]
deps = ["ExprTools", "InteractiveUtils", "LLVM", "Libdl", "Logging", "TimerOutputs", "UUIDs"]
git-tree-sha1 = "647a54f196b5ffb7c3bc2fec5c9a57fa273354cc"
uuid = "61eb1bfa-7361-4325-ad38-22787b887f55"
version = "0.13.14"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "RelocatableFolders", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "af237c08bda486b74318c8070adb96efa6952530"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.64.2"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "cd6efcf9dc746b06709df14e462f0a3fe0786b1e"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.64.2+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "83ea630384a13fc4f002b77690bc0afeb4255ac9"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.2"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "SpecialFunctions", "Test"]
git-tree-sha1 = "65e4589030ef3c44d3b90bdc5aac462b4bb05567"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.8"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "61feba885fac3a407465726d0c330b3055df897f"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "91b5dcf362c5add98049e6c29ee756910b03051d"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.3"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[IterationControl]]
deps = ["EarlyStopping", "InteractiveUtils"]
git-tree-sha1 = "d7df9a6fdd82a8cfdfe93a94fcce35515be634da"
uuid = "b3c1a2ee-3fec-4384-bf48-272ea71de57c"
version = "0.5.3"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[JLSO]]
deps = ["BSON", "CodecZlib", "FilePathsBase", "Memento", "Pkg", "Serialization"]
git-tree-sha1 = "e00feb9d56e9e8518e0d60eef4d1040b282771e2"
uuid = "9da8a3cd-07a3-59c0-a743-3fdc52c30d11"
version = "2.6.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[LLVM]]
deps = ["CEnum", "LLVMExtra_jll", "Libdl", "Printf", "Unicode"]
git-tree-sha1 = "c9b86064be5ae0f63e50816a5a90b08c474507ae"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "4.9.1"

[[LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5558ad3c8972d602451efe9d81c78ec14ef4f5ef"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.14+2"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "6f14549f7760d84b2db7a9b10b88cd3cc3025730"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.14"

[[LatinHypercubeSampling]]
deps = ["Random", "StableRNGs", "StatsBase", "Test"]
git-tree-sha1 = "42938ab65e9ed3c3029a8d2c58382ca75bdab243"
uuid = "a5e1c1ea-c99a-51d3-a14d-a9a37257b02d"
version = "1.8.0"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[LearnBase]]
git-tree-sha1 = "a0d90569edd490b82fdc4dc078ea54a5a800d30a"
uuid = "7f8f8fb0-2700-5f03-b4bd-41f8cfc144b6"
version = "0.4.1"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "c9551dd26e31ab17b86cbd00c2ede019c08758eb"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+1"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "58f25e56b706f95125dcb796f39e1fb01d913a71"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.10"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[LossFunctions]]
deps = ["InteractiveUtils", "LearnBase", "Markdown", "RecipesBase", "StatsBase"]
git-tree-sha1 = "0f057f6ea90a84e73a8ef6eebb4dc7b5c330020f"
uuid = "30fc2ffe-d236-52d8-8643-a9d8f7c094a7"
version = "0.7.2"

[[MLJ]]
deps = ["CategoricalArrays", "ComputationalResources", "Distributed", "Distributions", "LinearAlgebra", "MLJBase", "MLJEnsembles", "MLJIteration", "MLJModels", "MLJSerialization", "MLJTuning", "OpenML", "Pkg", "ProgressMeter", "Random", "ScientificTypes", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "ecd156a5494894ea125548ee58226541ee368329"
uuid = "add582a8-e3ab-11e8-2d5e-e98b27df1bc7"
version = "0.17.3"

[[MLJBase]]
deps = ["CategoricalArrays", "CategoricalDistributions", "ComputationalResources", "Dates", "DelimitedFiles", "Distributed", "Distributions", "InteractiveUtils", "InvertedIndices", "LinearAlgebra", "LossFunctions", "MLJModelInterface", "Missings", "OrderedCollections", "Parameters", "PrettyTables", "ProgressMeter", "Random", "ScientificTypes", "StatisticalTraits", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "2e41aab645157a8d9b53c478672459317d0a3ad9"
uuid = "a7f614a8-145f-11e9-1d2a-a57a1082229d"
version = "0.19.8"

[[MLJEnsembles]]
deps = ["CategoricalArrays", "CategoricalDistributions", "ComputationalResources", "Distributed", "Distributions", "MLJBase", "MLJModelInterface", "ProgressMeter", "Random", "ScientificTypesBase", "StatsBase"]
git-tree-sha1 = "4279437ccc8ece8f478ded5139334b888dcce631"
uuid = "50ed68f4-41fd-4504-931a-ed422449fee0"
version = "0.2.0"

[[MLJIteration]]
deps = ["IterationControl", "MLJBase", "Random"]
git-tree-sha1 = "9ea78184700a54ce45abea4c99478aa5261ed74f"
uuid = "614be32b-d00c-4edb-bd02-1eb411ab5e55"
version = "0.4.5"

[[MLJModelInterface]]
deps = ["Random", "ScientificTypesBase", "StatisticalTraits"]
git-tree-sha1 = "74d7fb54c306af241c5f9d4816b735cb4051e125"
uuid = "e80e1ace-859a-464e-9ed9-23947d8ae3ea"
version = "1.4.2"

[[MLJModels]]
deps = ["CategoricalArrays", "CategoricalDistributions", "Dates", "Distances", "Distributions", "InteractiveUtils", "LinearAlgebra", "MLJModelInterface", "Markdown", "OrderedCollections", "Parameters", "Pkg", "PrettyPrinting", "REPL", "Random", "ScientificTypes", "StatisticalTraits", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "5d9003012e93f086744373168ed5c6fc8695c66a"
uuid = "d491faf4-2d78-11e9-2867-c94bc002c0b7"
version = "0.15.7"

[[MLJSerialization]]
deps = ["IterationControl", "JLSO", "MLJBase", "MLJModelInterface"]
git-tree-sha1 = "cc5877ad02ef02e273d2622f0d259d628fa61cd0"
uuid = "17bed46d-0ab5-4cd4-b792-a5c4b8547c6d"
version = "1.1.3"

[[MLJTuning]]
deps = ["ComputationalResources", "Distributed", "Distributions", "LatinHypercubeSampling", "MLJBase", "ProgressMeter", "Random", "RecipesBase"]
git-tree-sha1 = "a443cc088158b949876d7038a1aa37cfc8c5509b"
uuid = "03970b2e-30c4-11ea-3135-d1576263f10f"
version = "0.6.16"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[MarchingCubes]]
deps = ["StaticArrays"]
git-tree-sha1 = "5f768e0a0c3875df386be4c036f78c8bd4b1a9b6"
uuid = "299715c1-40a9-479a-aaf9-4a633d36f717"
version = "0.1.2"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Memento]]
deps = ["Dates", "Distributed", "Requires", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "9b0b0dbf419fbda7b383dc12d108621d26eeb89f"
uuid = "f28f55f0-a522-5efc-85c2-fe41dfb9b2d9"
version = "1.3.0"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "737a5957f387b17e74d4ad2f440eb330b39a62c5"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.0"

[[NetworkLayout]]
deps = ["GeometryBasics", "LinearAlgebra", "Random", "Requires", "SparseArrays"]
git-tree-sha1 = "cac8fc7ba64b699c678094fa630f49b80618f625"
uuid = "46757867-2c16-5918-afeb-47bfcb05e46a"
version = "0.4.4"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenML]]
deps = ["ARFFFiles", "HTTP", "JSON", "Markdown", "Pkg"]
git-tree-sha1 = "06080992e86a93957bfe2e12d3181443cedf2400"
uuid = "8b6db2d4-7670-4922-a472-f9537c81ab66"
version = "0.2.0"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ab05aa4cc89736e95915b01e7279e61b1bfe33b8"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.14+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "e8185b83b9fc56eb6456200e873ce598ebc7f262"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.7"

[[Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "621f4f3b4977325b9128d5fae7a8b4829a0c2222"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.4"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "bb16469fd5224100e422f0b027d26c5a25de1200"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.2.0"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "edec0846433f1c1941032385588fd57380b62b59"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.27.4"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "670e559e5c8e191ded66fa9ea89c97f10376bb4c"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.38"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "28ef6c7ce353f0b35d0df0d5930e0d072c1f5b9b"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.1"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "d3538e7f8a790dc8903519090857ef8e1283eecd"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.5"

[[PrettyPrinting]]
git-tree-sha1 = "4be53d093e9e37772cc89e1009e8f6ad10c4681b"
uuid = "54e16d92-306c-5ea0-a30b-337be88ac337"
version = "0.4.0"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "d7a7aef8f8f2d537104f170139553b14dfe39fe9"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.2"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Random123]]
deps = ["Random", "RandomNumbers"]
git-tree-sha1 = "afeacaecf4ed1649555a19cb2cad3c141bbc9474"
uuid = "74087812-796a-5b5d-8853-05524746bad3"
version = "1.5.0"

[[RandomNumbers]]
deps = ["Random", "Requires"]
git-tree-sha1 = "043da614cc7e95c703498a491e2c21f58a2b8111"
uuid = "e6cf234a-135c-5ec9-84dd-332b85af5143"
version = "1.5.3"

[[RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "dc1e451e15d90347a7decc4221842a022b011714"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.5.2"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "cdbd3b1338c72ce29d9584fdbe9e9b70eeb5adca"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.1.3"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[ScientificTypes]]
deps = ["CategoricalArrays", "ColorTypes", "Dates", "Distributions", "PrettyTables", "Reexport", "ScientificTypesBase", "StatisticalTraits", "Tables"]
git-tree-sha1 = "ba70c9a6e4c81cc3634e3e80bb8163ab5ef57eb8"
uuid = "321657f4-b219-11e9-178b-2701a2544e81"
version = "3.0.0"

[[ScientificTypesBase]]
git-tree-sha1 = "a8e18eb383b5ecf1b5e6fc237eb39255044fd92b"
uuid = "30f210dd-8aff-4c5f-94ba-8e64358c1161"
version = "3.0.0"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "6a2f7d70512d205ca8c7ee31bfa9f142fe74310c"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.12"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "5ba658aeecaaf96923dce0da9e703bd1fe7666f9"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.4"

[[StableRNGs]]
deps = ["Random", "Test"]
git-tree-sha1 = "3be7d49667040add7ee151fefaf1f8c04c8c8276"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "4f6ec5d99a28e1a749559ef7dd518663c5eca3d5"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.4.3"

[[StatisticalTraits]]
deps = ["ScientificTypesBase"]
git-tree-sha1 = "271a7fea12d319f23d55b785c51f6876aadb9ac0"
uuid = "64bff920-2084-43da-a3e6-9bb72801c0c9"
version = "3.0.0"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c3d8ba7f3fa0625b062b82853a7d5229cb728b6b"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.2.1"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "8977b17906b0a1cc74ab2e3a05faa16cf08a8291"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.16"

[[StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "25405d7016a47cf2bd6cd91e66f4de437fd54a07"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.16"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "57617b34fa34f91d536eb265df67c2d4519b8b98"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.5"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "d60b0c96a16aaa42138d5d38ad386df672cb8bd8"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.16"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[UnicodePlots]]
deps = ["ColorTypes", "Contour", "Crayons", "Dates", "FileIO", "FreeTypeAbstraction", "LinearAlgebra", "MarchingCubes", "NaNMath", "SparseArrays", "StaticArrays", "StatsBase", "Unitful"]
git-tree-sha1 = "e7b68f6d25a79dff79acbd3bcf324db4385c2c6f"
uuid = "b8865327-cd53-5732-bb35-84acbb429228"
version = "2.10.1"

[[Unitful]]
deps = ["ConstructionBase", "Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "b649200e887a487468b71821e2644382699f1b0f"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.11.0"

[[Unzip]]
git-tree-sha1 = "34db80951901073501137bdbc3d5a8e7bbd06670"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.1.2"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─cbc48ca5-f1a4-4e13-9323-2fd2c43d8612
# ╟─7bb67403-d2ac-4dc9-b2f1-fdea7a795329
# ╟─92b94192-3647-49b7-baba-6d5d81d7ea19
# ╠═27f62732-c909-11eb-27ee-e373dce148d9
# ╟─68e825fd-3c99-4bce-8377-1153949fdf77
# ╟─e2eecd6f-56f3-464d-976e-e49966064e42
# ╟─1006f0c6-d06c-4584-bff9-6834fa360734
# ╟─5f41f994-4107-438c-9035-491fb9a123cb
# ╟─2131aedb-5b69-46cf-857a-c66b0479be21
# ╟─6de77848-8e4f-4246-8d34-c97f2560fc66
# ╠═6a59a026-6ed7-4230-91d5-7efd97ab22b5
# ╟─bb1c629d-d600-471b-887b-6fc354c51411
# ╟─b332694c-01a3-47b1-a910-29f7ef1397d8
# ╟─63723f2f-4cb2-4428-822c-240847f22caf
# ╟─9a0cd5b8-2012-4fda-8fb4-5df8f5e6c4a0
# ╟─a908f333-be8a-4fe8-a34d-66b539fbd9aa
# ╟─6aa06b7f-c169-4dc6-88ac-c422015667f9
# ╠═21574085-1021-4ae5-9e84-d3b5b1641981
# ╟─1b6458e1-1fca-4077-bbc5-a9ee5bbff938
# ╠═d3689c37-5175-4dd9-8002-8d1173dbcb4a
# ╠═b82c5e3d-2c17-4017-8b63-1d79f4b64eaf
# ╠═0b3a9f17-2232-47a2-9e12-5ac0c367c988
# ╠═ab35f314-d336-422e-9bd3-1a73ef31dd93
# ╠═2c31507c-db7c-475a-9c0f-f3539b536936
# ╠═92765af5-ecc2-4f19-9008-322a762a2e16
# ╠═4a6c5b51-a0d0-42e6-955f-920465c93809
# ╟─a857f289-a8c0-471d-8317-679856a96cd9
# ╟─297b317f-cbf9-4ce9-894e-2907cb808900
# ╠═396d2361-01a6-44cd-8367-1c579c8e272f
# ╠═9fe2e789-37fa-4ef9-a227-d883a5cfaf0a
# ╟─a87a0495-6743-4ad7-a206-2f02c8b65cea
# ╠═9b9a99e7-4b76-47ad-8b16-650e16d72334
# ╠═993da359-7e9d-4ba1-8a2a-81cf10caf833
# ╠═3f55b463-8061-4a00-a5d6-63b345f74828
# ╠═42b0a1e9-7fd5-4124-b5c9-b90b5a862f4d
# ╟─71c4fc48-b1ea-4a0e-adcb-9a53f5593e0c
# ╠═7fff29b7-11f6-4288-bc0b-60b34bfe531d
# ╟─c64b7d51-0496-4c56-b5de-da351b098cf6
# ╠═e4f67d26-43ce-4001-97bd-0fc89f8c832c
# ╟─40f8ceda-3e45-491f-9f71-922929da2ac4
# ╟─06357615-29ac-4e9d-8dae-28a4e74e9cd1
# ╟─c63657cc-d735-4db2-b9c1-29789989d7f1
# ╠═8d4d3743-bb81-47e2-98f4-6e09e712fdce
# ╟─380ff0ef-58a6-4ac5-847c-6c6f6b21b989
# ╠═b419612d-cf8c-4b7e-8b46-ada8104590dd
# ╟─03c31d2a-d9f6-4600-8839-054944efaa5a
# ╠═18bf93dd-cb23-4c3a-be11-5a9c74305422
# ╠═7e336b78-7557-4212-b1bf-cc6160fcc8f7
# ╠═671f8b90-a02a-4bda-a5dd-501c77405ead
# ╟─0b0103e8-fb07-448c-8fe1-f1b48c8f06a9
# ╠═1445afb0-a67a-4465-982e-4dd511db1b2d
# ╠═35835160-cb4f-4e67-ae0f-d7654e20cef1
# ╠═84fab6a3-b877-427f-b9b6-81c0d7ec4f12
# ╠═afd7f8eb-8691-4ea8-ab3b-113bb1a9943d
# ╠═af993b4c-7809-4450-9656-8a5d47f3a7a5
# ╟─e0173c12-56bd-44b0-9193-325a184d18c2
# ╠═fd9c308f-795d-44f3-9258-c683bbc7faed
# ╠═5de484ef-473e-44ea-87ee-3da637b096e6
# ╠═5ead921a-8ac6-47e6-a40f-ea0d5e530de6
# ╠═8f9e9882-d98d-46e4-ab9d-979baaf44f4a
# ╠═898f907c-118f-43c0-a70d-fb205009191b
# ╟─6788ff40-771a-4424-85ad-a80ad483a74f
# ╠═05f05f8a-2e34-48a0-966d-1fcae607b3f4
# ╠═32a329a4-defb-40e6-b7c6-efcdef282237
# ╟─37d62fc2-85cb-4d78-86ff-3f510515c441
# ╠═ea9dd6d0-ac12-45a8-9a40-bc9e182fe7c1
# ╟─822ca4dd-5e4c-4c4c-a549-bc88f2cb9e17
# ╠═d06ade6e-7a11-4c88-b8fc-047721d2e233
# ╟─169aa931-4de5-4cd2-86d8-71d63b8c33d1
# ╠═f803b32f-b2ce-4ee4-ba53-33bc75eb4641
# ╟─ecaeb2e1-0387-4bae-a264-986d483b8962
# ╟─4155d37a-c01c-4521-aaa6-ab9330a05741
# ╠═486c686b-35c2-4b5f-964e-c5107263e7ba
# ╟─0cb3093f-319b-496e-b0d0-1bcae576fbca
# ╠═968e1ccc-cc91-46c6-8ebd-31997c29a0de
# ╟─28f46f69-1068-4de1-addf-b9d619c065c3
# ╠═473ac112-40b0-4ca6-8b22-c06d146d929b
# ╟─aab92abc-9184-4335-958b-241a5c5bae48
# ╠═28f80ee6-8924-4e0a-893a-6a0333e7f5ae
# ╟─a7717b28-050c-4f0e-8ef2-000df5f57f6f
# ╠═22660ebc-77fc-452d-a146-a0fa9832b4eb
# ╟─6ffa49fe-405f-4bde-9f56-a15dfc976539
# ╠═c46221e9-3a4f-4833-8995-287981d2601b
# ╠═2f62cedd-0596-4fff-83ae-8243dd958bb4
# ╠═6e2e8861-5961-4bf0-a1f1-52f063958288
# ╠═43501e8c-a934-47c8-adb6-13cd28adf827
# ╟─ff46cab0-38a5-43c1-9419-bc7c1d916714
# ╠═c7681745-c6d1-41e1-b15d-c214940dc662
# ╠═10783f9c-1326-4554-bfe5-51291f51a877
# ╠═d9499aef-d45f-481c-81b5-35c47fc9d766
# ╟─dbd7dd09-2aa9-41a5-8103-ffa8d71fda43
# ╠═e0856fbb-e9c7-41cb-a3cd-141bb400ff80
# ╟─74df1556-2f1d-4451-a79f-bb107fc7d208
# ╠═d8776d26-2d32-495f-a9a0-4b34fa0467df
# ╠═b799b2ac-b9cf-4558-b17e-211773225a82
# ╟─563e68a3-b9af-4672-91cc-f8f0ae0c3ed9
# ╠═2e22a842-a678-4c86-87e0-b604d08f5f67
# ╟─d13452ee-4af5-44eb-b03e-eaa4a369d592
# ╠═6a8cceaf-f760-40ed-8265-d36db29b1d6d
# ╠═a82d5b42-d883-4730-a4b8-3b12941e771d
# ╟─2cc32659-9ce8-4faf-ab15-9cfc616d1f52
# ╠═d81bc8da-d814-4eb4-90d3-be3f11c00aff
# ╟─6fa97a3e-9d00-4cfc-975e-a0905206b073
# ╠═a403a2a9-7f60-42c0-bfd7-3292eb1b871e
# ╠═4a0e0b0c-464e-48d3-8819-a135aff2ab3b
# ╟─58723900-8aa3-42a8-8853-2b6ef025f2fb
# ╟─20753d0b-149a-48c1-917f-8b8828bbbb20
# ╠═a4237bda-06fa-4569-b917-bdf9e80f0bed
# ╟─fe42d84b-e76c-464f-8d7e-78f3b7edf63c
# ╠═ed893aee-f1a2-46c0-819d-321103d3d0c2
# ╠═fc456ae3-5094-4034-9740-5092f581ec2a
# ╠═0f29120d-35da-472c-a7e5-ea9128a057d6
# ╟─8e95732c-72c3-4b59-b78c-35c273252c33
# ╟─cd83c034-edfe-4696-973b-55ec100eb5ab
# ╟─d548bc1a-2e20-4b7f-971b-1b07faaa4c13
# ╟─228e9bf1-cfd8-4285-8b68-43762e1ae8c7
# ╟─23974dfc-7412-4983-9dcc-16e7a3e7dcc4
# ╟─7b455b83-b223-4b95-bd82-e7a5380633f4
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
