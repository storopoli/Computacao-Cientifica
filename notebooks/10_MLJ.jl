### A Pluto.jl notebook ###
# v0.15.1

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
	seed!(123)
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

	Bishop, C. M. (2006). Pattern Recognition and Machine Learning. Springer. [(linka)](https://www.microsoft.com/en-us/research/uploads/prod/2006/01/Bishop-Pattern-Recognition-and-Machine-Learning-2006.pdf)

	Duda, R. O., Hart, P. E., & Stork, D. G. (2012). Pattern Classification. John Wiley & Sons. [(link)](https://www.amazon.com/Pattern-Classification-Pt-1-Richard-Duda/dp/0471056693)

	Mitchell, T. M. (1997). Machine Learning. McGraw Hill. [(link)](https://www.cs.cmu.edu/~tom/mlbook.html)

	Murphy, K. P. (2012). Machine Learning: A Probabilistic Perspective (Illustrated edition). The MIT Press. [(link)](https://www.amazon.com/Machine-Learning-Probabilistic-Perspective-Computation/dp/0262018020)

"""

# ╔═╡ e2eecd6f-56f3-464d-976e-e49966064e42
md"""
# Aprendizagem de Máquina

**Aprendizagem de Máquina é uma área de estudo que fornece aos computadores a habilidade de aprender sem serem explicitamente programados**.

> Um programa de computador que aprende a partir da experiência E em relação a algum tipo de tarefa T e alguma medida de desempenho P, se o seu desempenho em T, conforme medido por P, melhora com a experiência E.

> Mitchell, T. M. (1997). Machine Learning. McGraw-Hill, New York.

#### Experiência (E)
Em aprendizagem de máquina um programa de computador **aprende sem ser explicitamente programado**. Ele aprende a partir de um **conjunto de dados que expressa toda experiência (E)** que desejamos ensina-lo. Esse conjunto de dados é chamado de **conjunto de treinamento** (ou treino).

* **Aprendizagem Supervisionada**: o conjunto de treinamento é composto por amostras de **entradas**/**saídas**.
* **Aprendizagem Não-Supervisionada**: conjunto de treinamento é composto por amostras de **entradas apenas**.
* **$(HTML("<s>Aprendizagem por Reforço</s>"))**

#### Tarefas (T)

* **Classificação**: Supervisionada qualitativa
* **Regressão**: Supervisionada quantitativa
* **Agrupamento**: Não-supervisionada

#### Desempenho (P)
Para medir o desempenho de um algoritmo de aprendizagem de máquina é preciso de uma medida de desempenho para mensurar a qualidade do processo de aprendizagem. Essa medida é conhecida como **função de custo** ou **função de erro**. Essa função é definida de acordo com o **tipo de problema** (aprendizagem supervisionada ou não-supervisionada). Essa função contém um conjunto de parâmetros a serem otimizados pelo algoritmo de aprendizagem de máquina.

De maneira geral, pode-se dizer que o **objetivo do algoritmo de aprendizagem de máquina é otimizar (aprender) o conjunto de parâmetros de tal forma que resultado da função seja o mínimo possível**. Isso significa que algoritmo tem uma **alta taxa de aprendizagem** e uma **baixa taxa de erro**.

* Dividir os dados em
   * **Treino**
   * **Teste**: aqui eu mensuro desempenho (P)
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
info_trees.is_pure_julia # 😎

# ╔═╡ 4a6c5b51-a0d0-42e6-955f-920465c93809
info_trees.input_scitype

# ╔═╡ a857f289-a8c0-471d-8317-679856a96cd9
md"""
## `ScientificTypes`

Além disso, `MLJ.jl` usa um sistema de tipos "científicos" com base em [`JuliaAI/ScientificTypes.jl`](https://github.com/JuliaAI/ScientificTypes.jl) para definir qual o tipo dos *inputs* `X` e `y`.

Os tipos científicops básicos escalar (unidimensional) são `Continuous`, `Multiclass{N}`, `OrderedFactor{N}` and `Count`.
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
X = DataFrame(x1=x1, x2=rand(4), x3=rand(4))

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
ŷ = predict(mach_evotree, X_penguins_cont[test, :])

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
Vamos "tunar" o `nrounds` e oa regularização L2 `λ`. Para isso criamos um objeto `range` com os valores plausíveis dos hiperparâmetros:
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
report(mach_tuning_tree).best_history_entry

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

# ╔═╡ fe42d84b-e76c-464f-8d7e-78f3b7edf63c
md"""
## Composição de Modelos com [`@pipeline`](https://alan-turing-institute.github.io/MLJ.jl/dev/composing_models/)

O legal do `MLJ.jl` é que eu consigo fazer tudo isso que fizemos até agora virar um modelo gigante composicional:
"""

# ╔═╡ fc456ae3-5094-4034-9740-5092f581ec2a
pipe = @pipeline(OneHotEncoder(),
				 ContinuousEncoder(),
				 EvoTree(),
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
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
CSV = "~0.8.5"
DataFrames = "~1.2.2"
EvoTrees = "~0.8.2"
MLJ = "~0.16.7"
Plots = "~1.20.0"
PlutoUI = "~0.7.9"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[BFloat16s]]
deps = ["LinearAlgebra", "Test"]
git-tree-sha1 = "4af69e205efc343068dc8722b8dfec1ade89254a"
uuid = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"
version = "0.1.0"

[[BSON]]
git-tree-sha1 = "92b8a8479128367aaab2620b8e73dff632f5ae69"
uuid = "fbb218c0-5317-5bc6-957e-2ee96dd4b1f0"
version = "0.3.3"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c3598e525718abcc440f69cc6d5f60dda0a1b61e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.6+5"

[[CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[CSV]]
deps = ["Dates", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode"]
git-tree-sha1 = "b83aa3f513be680454437a0eee21001607e5d983"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.8.5"

[[CUDA]]
deps = ["AbstractFFTs", "Adapt", "BFloat16s", "CEnum", "CompilerSupportLibraries_jll", "DataStructures", "ExprTools", "GPUArrays", "GPUCompiler", "LLVM", "LazyArtifacts", "Libdl", "LinearAlgebra", "Logging", "Printf", "Random", "Random123", "RandomNumbers", "Reexport", "Requires", "SparseArrays", "SpecialFunctions", "TimerOutputs"]
git-tree-sha1 = "5e696e37e51b01ae07bd9f700afe6cbd55250bce"
uuid = "052768ef-5323-5732-b1bb-66c8b64840ba"
version = "3.3.4"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "e2f47f6d8337369411569fd45ae5753ca10394c6"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.0+6"

[[CategoricalArrays]]
deps = ["DataAPI", "Future", "JSON", "Missings", "Printf", "RecipesBase", "Statistics", "StructTypes", "Unicode"]
git-tree-sha1 = "1562002780515d2573a4fb0c3715e4e57481075e"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.0"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "dfbf58e0e470c2fd70020ae2c34e2f17b9fd1e4c"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.2.0"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random", "StaticArrays"]
git-tree-sha1 = "ed268efe58512df8c7e224d2e170afd76dd6a417"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.13.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "344f143fa0ec67e47917848795ab19c6a455f32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.32.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "ee400abb2298bd13bfc3df1c412ed228061a2385"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.7.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d785f42445b63fc86caa08bb9a9351008be9b765"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.2"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "4437b64df1e0adccc3e5d1adbc3ac741095e4677"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.9"

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

[[Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "abe4ad222b26af3337262b8afb28fab8d215e9f8"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.3"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns"]
git-tree-sha1 = "3889f646423ce91dd1055a76317e9a1d3a23fff1"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.11"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "92d8f9f208637e8d2d28c664051a00569c01493d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.1.5+1"

[[EarlyStopping]]
deps = ["Dates", "Statistics"]
git-tree-sha1 = "9427bc7a6c186d892f71b1c36ee7619e440c9e06"
uuid = "792122b4-ca99-40de-a6bc-6742525f08b6"
version = "0.1.8"

[[EvoTrees]]
deps = ["BSON", "CUDA", "CategoricalArrays", "Distributions", "MLJModelInterface", "NetworkLayout", "Random", "RecipesBase", "StaticArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "bf01a80d361d8a4da8ec258ae18758bcf77e5162"
uuid = "f6006082-12f8-11e9-0c9c-0d5d367ab1e5"
version = "0.8.2"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[ExprTools]]
git-tree-sha1 = "b7e3d17636b348f005f11040025ae8c6f645fe92"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.6"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "LibVPX_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "3cc57ad0a213808473eafef4845a74766242e05f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.3.1+4"

[[FilePathsBase]]
deps = ["Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "0f5e8d0cb91a6386ba47bd1527b240bd5725fbae"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.10"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "8c8eac2af06ce35973c3eadb4ab3243076a408e7"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.1"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "35895cf184ceaab11fd778b4590144034a167a2f"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.1+14"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "cbd58c9deb1d304f5a245a0b7eb841a2560cfec6"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.1+5"

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
git-tree-sha1 = "dba1e8614e98949abfa60480b13653813d8f0157"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+0"

[[GPUArrays]]
deps = ["AbstractFFTs", "Adapt", "LinearAlgebra", "Printf", "Random", "Serialization", "Statistics"]
git-tree-sha1 = "ececbf05f8904c92814bdbd0aafd5540b0bf2e9a"
uuid = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
version = "7.0.1"

[[GPUCompiler]]
deps = ["DataStructures", "ExprTools", "InteractiveUtils", "LLVM", "Libdl", "Logging", "TimerOutputs", "UUIDs"]
git-tree-sha1 = "0da0f52fc521ff23b8291e7fda54c61907609f12"
uuid = "61eb1bfa-7361-4325-ad38-22787b887f55"
version = "0.12.6"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "182da592436e287758ded5be6e32c406de3a2e47"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.58.1"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "d59e8320c2747553788e4fc42231489cc602fa50"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.58.1+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "15ff9a14b9e1218958d3530cc288cf31465d9ae2"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.3.13"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "7bf67e9a481712b3dbe9cb3dac852dc4b1162e02"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "44e3b40da000eab4ccb1aecdc4801c040026aeb5"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.13"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InvertedIndices]]
deps = ["Test"]
git-tree-sha1 = "15732c475062348b0165684ffe28e85ea8396afc"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.0.0"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IterationControl]]
deps = ["EarlyStopping", "InteractiveUtils"]
git-tree-sha1 = "f61d5d4d0e433b3fab03ca5a1bfa2d7dcbb8094c"
uuid = "b3c1a2ee-3fec-4384-bf48-272ea71de57c"
version = "0.4.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JLSO]]
deps = ["BSON", "CodecZlib", "FilePathsBase", "Memento", "Pkg", "Serialization"]
git-tree-sha1 = "e00feb9d56e9e8518e0d60eef4d1040b282771e2"
uuid = "9da8a3cd-07a3-59c0-a743-3fdc52c30d11"
version = "2.6.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "81690084b6198a2e1da36fcfda16eeca9f9f24e4"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.1"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LLVM]]
deps = ["CEnum", "LLVMExtra_jll", "Libdl", "Printf", "Unicode"]
git-tree-sha1 = "733abcbdc67337bb6aaf873c6bebbe1e6440a5df"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "4.1.1"

[[LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b36c0677a0549c7d1dc8719899a4133abbfacf7d"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.6+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "c7f1c695e06c01b95a67f0cd1d34994f3e7db104"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.2.1"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a4b12a1bd2ebade87891ab7e36fdbce582301a92"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.6"

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

[[LibVPX_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "12ee7e23fa4d18361e7c2cde8f8337d4c3101bc7"
uuid = "dd192d2f-8180-539f-9fb4-cc70b1dcf69a"
version = "1.10.0+0"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "761a393aeccd6aa92ec3515e428c26bf99575b3b"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+0"

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
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["DocStringExtensions", "LinearAlgebra"]
git-tree-sha1 = "7bd5f6565d80b6bf753738d2bc40a5dfea072070"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.2.5"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[LossFunctions]]
deps = ["InteractiveUtils", "LearnBase", "Markdown", "RecipesBase", "StatsBase"]
git-tree-sha1 = "0f057f6ea90a84e73a8ef6eebb4dc7b5c330020f"
uuid = "30fc2ffe-d236-52d8-8643-a9d8f7c094a7"
version = "0.7.2"

[[MLJ]]
deps = ["CategoricalArrays", "ComputationalResources", "Distributed", "Distributions", "LinearAlgebra", "MLJBase", "MLJEnsembles", "MLJIteration", "MLJModels", "MLJOpenML", "MLJSerialization", "MLJTuning", "Pkg", "ProgressMeter", "Random", "ScientificTypes", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "7cbd651e39fd3f3aa37e8a4d8beaccfa8d13b1cd"
uuid = "add582a8-e3ab-11e8-2d5e-e98b27df1bc7"
version = "0.16.7"

[[MLJBase]]
deps = ["CategoricalArrays", "ComputationalResources", "Dates", "DelimitedFiles", "Distributed", "Distributions", "InteractiveUtils", "InvertedIndices", "LinearAlgebra", "LossFunctions", "MLJModelInterface", "Missings", "OrderedCollections", "Parameters", "PrettyTables", "ProgressMeter", "Random", "ScientificTypes", "StatisticalTraits", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "ad7fdd566e2639c1a189e0d1b2ef43085091c2c7"
uuid = "a7f614a8-145f-11e9-1d2a-a57a1082229d"
version = "0.18.15"

[[MLJEnsembles]]
deps = ["CategoricalArrays", "ComputationalResources", "Distributed", "Distributions", "MLJBase", "MLJModelInterface", "ProgressMeter", "Random", "ScientificTypesBase", "StatsBase"]
git-tree-sha1 = "b9ce7bbc4bba927d52c26a3446ac2913777072c8"
uuid = "50ed68f4-41fd-4504-931a-ed422449fee0"
version = "0.1.1"

[[MLJIteration]]
deps = ["IterationControl", "MLJBase", "Random"]
git-tree-sha1 = "f927564f7e295b3205f37186191c82720a3d93a5"
uuid = "614be32b-d00c-4edb-bd02-1eb411ab5e55"
version = "0.3.1"

[[MLJModelInterface]]
deps = ["Random", "ScientificTypesBase", "StatisticalTraits"]
git-tree-sha1 = "54e0aa2c7e79f6f30a7b2f3e096af88de9966b7c"
uuid = "e80e1ace-859a-464e-9ed9-23947d8ae3ea"
version = "1.1.2"

[[MLJModels]]
deps = ["CategoricalArrays", "Dates", "Distances", "Distributions", "InteractiveUtils", "LinearAlgebra", "MLJBase", "MLJModelInterface", "OrderedCollections", "Parameters", "Pkg", "REPL", "Random", "Requires", "ScientificTypes", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "a5dab276c8fe1ccd5c585ec1b876e143dbaf1f5c"
uuid = "d491faf4-2d78-11e9-2867-c94bc002c0b7"
version = "0.14.9"

[[MLJOpenML]]
deps = ["CSV", "HTTP", "JSON", "Markdown", "ScientificTypes"]
git-tree-sha1 = "a0d6e25ec042ab84505733a62a2b2894fbcf260c"
uuid = "cbea4545-8c96-4583-ad3a-44078d60d369"
version = "1.1.0"

[[MLJSerialization]]
deps = ["IterationControl", "JLSO", "MLJBase", "MLJModelInterface"]
git-tree-sha1 = "cd6285f95948fe1047b7d6fd346c172e247c1188"
uuid = "17bed46d-0ab5-4cd4-b792-a5c4b8547c6d"
version = "1.1.2"

[[MLJTuning]]
deps = ["ComputationalResources", "Distributed", "Distributions", "LatinHypercubeSampling", "MLJBase", "ProgressMeter", "Random", "RecipesBase"]
git-tree-sha1 = "1deadc54bf1577a46978d80fe2506d62fa8bf18f"
uuid = "03970b2e-30c4-11ea-3135-d1576263f10f"
version = "0.6.10"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "0fb723cd8c45858c22169b2e42269e53271a6df7"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.7"

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
deps = ["Dates", "Distributed", "JSON", "Serialization", "Sockets", "Syslogs", "Test", "TimeZones", "UUIDs"]
git-tree-sha1 = "19650888f97362a2ae6c84f0f5f6cda84c30ac38"
uuid = "f28f55f0-a522-5efc-85c2-fe41dfb9b2d9"
version = "1.2.0"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "4ea90bd5d3985ae1f9a908bd4500ae88921c5ce7"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.0"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[Mocking]]
deps = ["ExprTools"]
git-tree-sha1 = "748f6e1e4de814b101911e64cc12d83a6af66782"
uuid = "78c3b35d-d492-501b-9361-3d52fe80e533"
version = "0.7.2"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NetworkLayout]]
deps = ["GeometryBasics", "LinearAlgebra", "Random", "Requires", "SparseArrays"]
git-tree-sha1 = "76bbbe01d2e582213e656688e63707d94aaadd15"
uuid = "46757867-2c16-5918-afeb-47bfcb05e46a"
version = "0.4.0"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

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
git-tree-sha1 = "4dd403333bcf0909341cfe57ec115152f937d7d8"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.1"

[[Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "2276ac65f1e236e0a6ea70baff3f62ad4c625345"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.2"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "bfd7d8c7fd87f04543810d9cbd3995972236ba1b"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.2"

[[PersistenceDiagramsBase]]
deps = ["Compat", "Tables"]
git-tree-sha1 = "ec6eecbfae1c740621b5d903a69ec10e30f3f4bc"
uuid = "b1ad91c1-539c-4ace-90bd-ea06abc420fa"
version = "0.1.1"

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
git-tree-sha1 = "501c20a63a34ac1d015d5304da0e645f42d91c9f"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.11"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "e39bea10478c6aff5495ab522517fae5134b40e3"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.20.0"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "cde4ce9d6f33219465b55162811d8de8139c0414"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.2.1"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "0d1245a357cc61c8cd61934c07447aa569ff22e6"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.1.0"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "afadeba63d90ff223a6a48d2009434ecee2ec9e8"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.1"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "12fbe86da16df6679be7521dfb39fbc861e1dc7b"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.1"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Random123]]
deps = ["Libdl", "Random", "RandomNumbers"]
git-tree-sha1 = "0e8b146557ad1c6deb1367655e052276690e71a3"
uuid = "74087812-796a-5b5d-8853-05524746bad3"
version = "1.4.2"

[[RandomNumbers]]
deps = ["Random", "Requires"]
git-tree-sha1 = "a752043df7488ca8bcbe05fa82c831b5e2c67211"
uuid = "e6cf234a-135c-5ec9-84dd-332b85af5143"
version = "1.5.2"

[[RecipesBase]]
git-tree-sha1 = "b3fb709f3c97bfc6e948be68beeecb55a0b340ae"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.1"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "2a7a2469ed5d94a98dea0e85c46fa653d76be0cd"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.3.4"

[[Reexport]]
git-tree-sha1 = "5f6c21241f0f655da3952fd60aa18477cf96c220"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.1.0"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

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
deps = ["CategoricalArrays", "ColorTypes", "Dates", "PersistenceDiagramsBase", "PrettyTables", "ScientificTypesBase", "StatisticalTraits", "Tables"]
git-tree-sha1 = "345e33061ad7c49c6e860e42a04c62ecbea3eabf"
uuid = "321657f4-b219-11e9-178b-2701a2544e81"
version = "2.0.0"

[[ScientificTypesBase]]
git-tree-sha1 = "3f7ddb0cf0c3a4cff06d9df6f01135fa5442c99b"
uuid = "30f210dd-8aff-4c5f-94ba-8e64358c1161"
version = "1.0.0"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "35927c2c11da0a86bcd482464b93dadd09ce420f"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.5"

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
deps = ["ChainRulesCore", "LogExpFunctions", "OpenSpecFun_jll"]
git-tree-sha1 = "508822dca004bf62e210609148511ad03ce8f1d8"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.6.0"

[[StableRNGs]]
deps = ["Random", "Test"]
git-tree-sha1 = "3be7d49667040add7ee151fefaf1f8c04c8c8276"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "885838778bb6f0136f8317757d7803e0d81201e4"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.9"

[[StatisticalTraits]]
deps = ["ScientificTypesBase"]
git-tree-sha1 = "93f7326079b73910e5a81f8848e7a633f99a2946"
uuid = "64bff920-2084-43da-a3e6-9bb72801c0c9"
version = "2.0.1"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "fed1ec1e65749c4d96fc20dd13bea72b55457e62"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.9"

[[StatsFuns]]
deps = ["LogExpFunctions", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "30cd8c360c54081f806b1ee14d2eecbef3c04c49"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.8"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "000e168f5cc9aded17b6999a560b7c11dda69095"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.0"

[[StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "e36adc471280e8b346ea24c5c87ba0571204be7a"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.7.2"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

[[Syslogs]]
deps = ["Printf", "Sockets"]
git-tree-sha1 = "46badfcc7c6e74535cc7d833a91f4ac4f805f86d"
uuid = "cea106d9-e007-5e6c-ad93-58fe2094e9c4"
version = "0.3.0"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "d0c690d37c73aeb5ca063056283fde5585a41710"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.5.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TimeZones]]
deps = ["Dates", "Future", "LazyArtifacts", "Mocking", "Pkg", "Printf", "RecipesBase", "Serialization", "Unicode"]
git-tree-sha1 = "81753f400872e5074768c9a77d4c44e70d409ef0"
uuid = "f269a46b-ccf7-5d73-abea-4c690281aa53"
version = "1.5.6"

[[TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "209a8326c4f955e2442c07b56029e88bb48299c7"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.12"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "7c53c35547de1c5b9d46a4797cf6d8253807108c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.5"

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

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll"]
git-tree-sha1 = "2839f1c1296940218e35df0bbb220f2a79686670"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.18.0+4"

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
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "acc685bcf777b2202a904cdcb49ad34c2fa1880c"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.14.0+4"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7a5780a0d9c6864184b3a2eeeb833a0c871f00ab"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "0.1.6+4"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d713c1ce4deac133e3334ee12f4adff07f81778f"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2020.7.14+2"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "487da2f8f2f0c8ee0e83f39d13037d6bbf0a45ab"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.0.0+3"

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
# ╟─fe42d84b-e76c-464f-8d7e-78f3b7edf63c
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
