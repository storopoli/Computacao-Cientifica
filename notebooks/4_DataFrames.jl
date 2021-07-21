### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 27f62732-c909-11eb-27ee-e373dce148d9
begin
	using Pkg
	using PlutoUI
	
	using BenchmarkTools
	using Chain
	using CSV
	using CategoricalArrays
	using DataFrames
	using HTTP
	using XLSX
	using Statistics: mean, std, cor
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
# Dados Tabulares com [`DataFrames.jl`](https://github.com/JuliaData/DataFrames.jl)
"""

# ╔═╡ a20561ca-2f63-4ff4-8cff-5f93da0e940c
Resource("https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg", :width => 120, :display => "inline")

# ╔═╡ 98ddb212-89ff-4376-8103-fb6c9518d0f7
md"""
!!! info "💁 Dados Tabulares"
    Vamos gastar **muito tempo** com Dados Tabulares. É uma coisa **muito importante**.
"""

# ╔═╡ f8557972-abb6-4fc1-9007-8d6fb91ca184
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/data-everywhere.png?raw=true", :width => 600)

# ╔═╡ b22870c8-fc29-451d-afcf-4e07823291fc
md"""
## Dados Tabulares

Quase tudo que mexemos que envolvem dados fazemos por meio de dados tabulares.

Onde:

* Cada **coluna** é uma variável
* Cada **linha** é uma observação
* Cada **célula** é uma mensuração única
"""

# ╔═╡ 0bdad8c0-837c-4814-a8d9-e73bec34399e
md"""
$(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/tidydata_1.jpg?raw=true"))

> Figura com licença creative commons de [`@allisonhorst`](https://github.com/allisonhorst/stats-illustrations)
"""

# ╔═╡ f5f02b1c-0734-4e00-8b78-fab0ef6ab6c2
md"""
## Dados Tabulares em Julia

Não tem muito o que pensar...
"""

# ╔═╡ 750df153-fb1c-4b65-bc17-6d408000e422
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/dataframes.jpg?raw=true", :width => 600)

# ╔═╡ e4f7f01e-76bb-4f26-b231-0a01d817fc33
md"""
```julia
using DataFrames
```

Um exemplo para mostrar algumas coisas adiante:
"""

# ╔═╡ 7a47a8d3-0408-4e8a-bcd9-ffaf696eae81
df_1 = DataFrame(x_1=rand(5), x_2=rand(5), x_3=rand(5), y_a=rand(5), y_b=rand(5))

# ╔═╡ 4f8b256e-9069-4d23-bf9e-a95867ffe3da
typeof(df_1)

# ╔═╡ a6b81169-b0cf-49e6-a700-d3618d7aeae9
md"""
## Informações sobre um `DataFrame`

- `size(df)`: tupla das dimensões (similar ao `df.shape` de Python)
- `nrow(df)` e `ncol(df)`: número de linhas e número de colunas
- `first(df, 5)` e `last(df, 5)`: 5 primeiras ou últimas linhas com o *header*
- `describe(df)`: similar ao `df.describe()` de Pandas
- `names(df)`: vetor de colunas como `String`s
- `propertynames(df)`: vetor de colunas como `Symbol`s
- `hasproperty(df, :x1)`: retorna um `Bool` se a coluna `x1` ∈ `df`
- `columnindex(df, :x2)`: returna o `index` da coluna `x2` ∈ `df`
- `colwise(sum, df)`: operações *column-wise*
- `df2 = copy(df)`: copia um DataFrame
"""

# ╔═╡ 50af3d7c-535d-42fc-8fc5-d124210055e5
size(df_1)

# ╔═╡ 06a37ad8-2ff7-4999-9008-98aa96b73420
first(df_1, 3)

# ╔═╡ 5da74073-e6cd-4ce9-a994-797be0e59ff8
ncol(df_1)

# ╔═╡ 843ac012-f8f1-4655-84e2-ffb151b99bea
names(df_1)

# ╔═╡ c4efdf84-8700-4ed9-b40a-965d9188ffbc
md"""
### Estatísticas Descritivas com o `describe`
"""

# ╔═╡ de547f28-1eb5-4438-b088-adbeae032f55
md"""
!!! tip "💡 describe(df)"
    Por padrão `describe(df)` é `describe(df, :mean, :min, :median, :max, :nmissing, :eltype)`. 
"""

# ╔═╡ 877c0807-b9a9-406c-ac5d-dd7478a197c6
describe(df_1)

# ╔═╡ 7f223d58-4bd1-4b3d-9c14-9d84d0b8e7dd
md"""
Mas você pode escolher o que você quiser:

- `:mean`: média
- `:std`: desvio padrão
- `:min`: mínimo
- `:q25`: quartil 25
- `:median`: mediana
- `:q75`: quartil 75
- `:max`: máximo
- `:nunique`: número de valores únicos
- `:nmissing`: número de valores faltantes
- `:first`: primeiro valor
- `:last`: último valor
- `:eltype`: tipo de elemento (e.g. `Float64`, `Int64`, `String`)
"""

# ╔═╡ d73508d0-649c-46c5-be35-fc0ae7990ee3
describe(df_1, :mean, :median, :std)

# ╔═╡ 77d83116-8d87-4313-aaaf-e57d0322c3fe
md"""
Ou até inventar a sua função de sumarização:
"""

# ╔═╡ 39a3b34d-2cb5-4033-a243-c13af0a49b2c
describe(df_1, sum => :sum)

# ╔═╡ 8d4c63fe-2c4c-40d4-b079-7a4fd2b55142
md"""
Por padrão `describe` age em todas as colunas do dataset. Mas você pode definir um subconjunto de colunas com o argumento `cols`:
"""

# ╔═╡ ae553b32-49a0-4c45-950b-bb4400e069ae
describe(df_1, :mean; cols=[:x_1, :x_2])

# ╔═╡ 8959d49d-b019-442d-adb6-99c1450ec108
md"""
## *Input*/*Output* (IO)

1. [`CSV.jl`](https://github.com/JuliaData/CSV.jl): para ler qualquer arquivo delimitado -- `.csv`, `.tsv` etc.
2. [`XLSX.jl`](https://github.com/felipenoris/XLSX.jl): para ler arquivos Excel `.xslx` e `.xls`.
3. [`JSONTables.jl`](https://github.com/JuliaData/JSONTables.jl): para ler arquivos JSON `.json`.
4. [`Arrow.jl`](https://github.com/JuliaData/Arrow.jl): formato Apache Arrow para Big Data.
"""

# ╔═╡ 4722d7bc-789f-4c4b-966f-483fd276a243
md"""
### Dataset `palmerpenguins`

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

# ╔═╡ 99c0cc2a-b538-4b42-8a6e-ddf4d93c5baa
md"""
$(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/palmerpenguins_1.png?raw=true", :width => 338))
$(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/palmerpenguins_2.png?raw=true", :width => 338))
"""

# ╔═╡ 68e791a3-cfff-4115-8cbe-b7cc40b67bc4
md"""
!!! tip "💡 Opções CSV.jl"
    `CSV.jl` tolera qualquer maluquice que vier pela frente de arquivo delimitado. Veja a documentação para a função [`CSV.File`](https://csv.juliadata.org/dev/#CSV.File).
"""

# ╔═╡ dd760bda-855b-41a0-bc59-be46943c5705
md"""
### `CSV.File` vs `CSV.read`

`CSV.File` materializa um arquivo `.csv` como um `DataFrame` **copiando as colunas** da função `CSV.File`:

```julia
df = CSV.File(file) |> DataFrame
```

`CSV.read` **evita fazer cópias das colunas** do arquivo `.csv` parseado

```julia
df = CSV.read(file, DataFrame)
```
"""

# ╔═╡ 04b9e718-44a5-4e4d-9d4a-10b72a140e3c
@benchmark CSV.File("../data/penguins.csv") |> DataFrame

# ╔═╡ 6c7e84cd-0747-4291-ace4-e1b0fa079c97
@benchmark CSV.read("../data/penguins.csv", DataFrame)

# ╔═╡ f6d41644-3d13-4d4a-b8b8-c3fc9abec689
penguins = CSV.read("../data/penguins.csv", DataFrame)

# ╔═╡ 0f3c04f6-210a-4fac-ac73-af5ecb4c5370
md"""
* Adelie – 146 observações.
* Chinstrap – 68 observações.
* Gentoo – 119 observações.
"""

# ╔═╡ edeabce5-2296-4eb5-9410-cdb9b6187e7e
md"""
## Dataset StarWars

87 personagens e 14 variáveis:

- `name`: nome do personagem
- `height`: altura em cm
- `mass`: peso em kg
- `hair_color`, `skin_color` ,`eye_color`: cor de cabelo, pele e olhos
- `birth_year`: ano de nascimento em BBY (BBY = Before Battle of Yavin)
- `sex`: o sexo biológico do personagem, `male`, `female`, `hermaphroditic`, ou `none` (no caso de Droids)
- `gender`: a identidade de gênero do personagem determinada pela sua personalidade ou pela maneira que foram programados (no caso de Droids)oids).
- `homeworld`: nome do mundo de origem
- `species`: nome da espécie
- `films`: lista de filmes que o personagem apareceu
- `vehicles`: lista de veículos que o personagem pilotou
- `starships`: lista de naves que o personagem pilotou

> Dataset obtido por licença creative commons do StarWars API `https://swapi.dev/`
"""

# ╔═╡ c390de55-1f7c-4278-9d99-fd75c94f5e9d
md"""
!!! tip "💡 Julia"
    Provavelmente Julia faz o percurso de Kessel em bem menos que 12 parsecs.
"""

# ╔═╡ 9197ec1a-eb2b-4dea-bb96-5ff16a9c423f
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/12-parsecs.gif?raw=true", :width => 800)

# ╔═╡ fafdd689-6c1f-4036-aeb8-47c75cc73e9f
starwars = @chain begin
	HTTP.get("https://github.com/tidyverse/dplyr/blob/master/data-raw/starwars.csv?raw=true").body
	CSV.read(DataFrame)
end

# ╔═╡ ab034249-de4e-418d-a54e-ab1ad49bea1b
nrow(starwars)

# ╔═╡ d548bc1a-2e20-4b7f-971b-1b07faaa4c13
md"""
## Ambiente
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

# ╔═╡ 93ae2b3a-67fb-46d2-b082-6dc47c1b8f7a
md"""
# Licença

Este conteúdo possui licença [Creative Commons Attribution-ShareAlike 4.0 Internacional](http://creativecommons.org/licenses/by-sa/4.0/).

[![CC BY-SA 4.0](https://licensebuttons.net/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
CategoricalArrays = "324d7699-5711-5eae-9e2f-1d82baa6b597"
Chain = "8be319e6-bccf-4806-a6f7-6fae938471bc"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
InteractiveUtils = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
XLSX = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"

[compat]
BenchmarkTools = "~1.1.1"
CSV = "~0.8.5"
CategoricalArrays = "~0.10.0"
Chain = "~0.4.7"
DataFrames = "~1.2.1"
HTTP = "~0.9.12"
PlutoUI = "~0.7.9"
XLSX = "~0.7.6"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Statistics", "UUIDs"]
git-tree-sha1 = "c31ebabde28d102b602bada60ce8922c266d205b"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.1.1"

[[CSV]]
deps = ["Dates", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode"]
git-tree-sha1 = "b83aa3f513be680454437a0eee21001607e5d983"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.8.5"

[[CategoricalArrays]]
deps = ["DataAPI", "Future", "JSON", "Missings", "Printf", "RecipesBase", "Statistics", "StructTypes", "Unicode"]
git-tree-sha1 = "1562002780515d2573a4fb0c3715e4e57481075e"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.0"

[[Chain]]
git-tree-sha1 = "c72673739e02d65990e5e068264df5afaa0b3273"
uuid = "8be319e6-bccf-4806-a6f7-6fae938471bc"
version = "0.4.7"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dc7dedc2c2aa9faf59a55c622760a25cbefbe941"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.31.0"

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
git-tree-sha1 = "a19645616f37a2c2c3077a44bc0d3e73e13441d7"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.1"

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

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EzXML]]
deps = ["Printf", "XML2_jll"]
git-tree-sha1 = "0fa3b52a04a4e210aeb1626def9c90df3ae65268"
uuid = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
version = "1.1.0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "c6a1fff2fd4b1da29d3dccaffb1e1001244d844e"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.12"

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

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "81690084b6198a2e1da36fcfda16eeca9f9f24e4"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.1"

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

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

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

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "4ea90bd5d3985ae1f9a908bd4500ae88921c5ce7"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.0"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "c8abc88faa3f7a3950832ac5d6e690881590d6dc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

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

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RecipesBase]]
git-tree-sha1 = "b3fb709f3c97bfc6e948be68beeecb55a0b340ae"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.1"

[[Reexport]]
git-tree-sha1 = "5f6c21241f0f655da3952fd60aa18477cf96c220"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.1.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "944ced306c76ae4a5db96fc85ec21f501f06b302"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.4"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

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

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "e36adc471280e8b346ea24c5c87ba0571204be7a"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.7.2"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

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
git-tree-sha1 = "8ed4a3ea724dac32670b062be3ef1c1de6773ae8"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.4.4"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[XLSX]]
deps = ["Dates", "EzXML", "Printf", "Tables", "ZipFile"]
git-tree-sha1 = "7744a996cdd07b05f58392eb1318bca0c4cc1dc7"
uuid = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"
version = "0.7.6"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[ZipFile]]
deps = ["Libdl", "Printf", "Zlib_jll"]
git-tree-sha1 = "c3a5637e27e914a7a445b8d0ad063d701931e9f7"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.9.3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─cbc48ca5-f1a4-4e13-9323-2fd2c43d8612
# ╟─7bb67403-d2ac-4dc9-b2f1-fdea7a795329
# ╟─a20561ca-2f63-4ff4-8cff-5f93da0e940c
# ╠═27f62732-c909-11eb-27ee-e373dce148d9
# ╟─98ddb212-89ff-4376-8103-fb6c9518d0f7
# ╟─f8557972-abb6-4fc1-9007-8d6fb91ca184
# ╟─b22870c8-fc29-451d-afcf-4e07823291fc
# ╟─0bdad8c0-837c-4814-a8d9-e73bec34399e
# ╟─f5f02b1c-0734-4e00-8b78-fab0ef6ab6c2
# ╟─750df153-fb1c-4b65-bc17-6d408000e422
# ╟─e4f7f01e-76bb-4f26-b231-0a01d817fc33
# ╠═7a47a8d3-0408-4e8a-bcd9-ffaf696eae81
# ╠═4f8b256e-9069-4d23-bf9e-a95867ffe3da
# ╟─a6b81169-b0cf-49e6-a700-d3618d7aeae9
# ╠═50af3d7c-535d-42fc-8fc5-d124210055e5
# ╠═06a37ad8-2ff7-4999-9008-98aa96b73420
# ╠═5da74073-e6cd-4ce9-a994-797be0e59ff8
# ╠═843ac012-f8f1-4655-84e2-ffb151b99bea
# ╟─c4efdf84-8700-4ed9-b40a-965d9188ffbc
# ╟─de547f28-1eb5-4438-b088-adbeae032f55
# ╠═877c0807-b9a9-406c-ac5d-dd7478a197c6
# ╟─7f223d58-4bd1-4b3d-9c14-9d84d0b8e7dd
# ╠═d73508d0-649c-46c5-be35-fc0ae7990ee3
# ╟─77d83116-8d87-4313-aaaf-e57d0322c3fe
# ╠═39a3b34d-2cb5-4033-a243-c13af0a49b2c
# ╟─8d4c63fe-2c4c-40d4-b079-7a4fd2b55142
# ╠═ae553b32-49a0-4c45-950b-bb4400e069ae
# ╠═8959d49d-b019-442d-adb6-99c1450ec108
# ╟─4722d7bc-789f-4c4b-966f-483fd276a243
# ╟─99c0cc2a-b538-4b42-8a6e-ddf4d93c5baa
# ╟─68e791a3-cfff-4115-8cbe-b7cc40b67bc4
# ╟─dd760bda-855b-41a0-bc59-be46943c5705
# ╠═04b9e718-44a5-4e4d-9d4a-10b72a140e3c
# ╠═6c7e84cd-0747-4291-ace4-e1b0fa079c97
# ╠═f6d41644-3d13-4d4a-b8b8-c3fc9abec689
# ╟─0f3c04f6-210a-4fac-ac73-af5ecb4c5370
# ╟─edeabce5-2296-4eb5-9410-cdb9b6187e7e
# ╟─c390de55-1f7c-4278-9d99-fd75c94f5e9d
# ╟─9197ec1a-eb2b-4dea-bb96-5ff16a9c423f
# ╠═fafdd689-6c1f-4036-aeb8-47c75cc73e9f
# ╠═ab034249-de4e-418d-a54e-ab1ad49bea1b
# ╟─d548bc1a-2e20-4b7f-971b-1b07faaa4c13
# ╟─228e9bf1-cfd8-4285-8b68-43762e1ae8c7
# ╟─23974dfc-7412-4983-9dcc-16e7a3e7dcc4
# ╟─93ae2b3a-67fb-46d2-b082-6dc47c1b8f7a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
