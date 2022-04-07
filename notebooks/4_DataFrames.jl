### A Pluto.jl notebook ###
# v0.19.0

using Markdown
using InteractiveUtils

# ╔═╡ 27f62732-c909-11eb-27ee-e373dce148d9
begin
	using Pkg
	using PlutoUI
	
	using BenchmarkTools
	using CSV
	using CategoricalArrays
	using DataFrames
	using XLSX
	using Statistics: mean, std, cor
	using Downloads: download
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

# ╔═╡ 0553799f-c084-4f24-85c4-6da4c26cf524
md"""
## Datasets Utilizados

* `palmerpenguins`
* `starwars`
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

# ╔═╡ edeabce5-2296-4eb5-9410-cdb9b6187e7e
md"""
### Dataset `starwars`

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

# ╔═╡ f5f02b1c-0734-4e00-8b78-fab0ef6ab6c2
md"""
# Dados Tabulares em Julia

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
# Informações sobre um `DataFrame`

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

# ╔═╡ a885fe89-1d10-4fe1-b3fc-486c2abf80d5
md"""
!!! tip "💡 Conversão de DataFrame em Matrix"
    Se você precisar converter um `DataFrame` com colunas do **mesmo tipo** para uma matriz, você pode usar o construtor `Matrix` passando um `DataFrame`.
"""

# ╔═╡ bf4b1f85-028b-4e0b-8336-63d3cfea28d3
Matrix(df_1)

# ╔═╡ c4efdf84-8700-4ed9-b40a-965d9188ffbc
md"""
## Estatísticas Descritivas com o `describe`
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
describe(df_1, :mean, :std; cols=[:x_1, :x_2])

# ╔═╡ 8959d49d-b019-442d-adb6-99c1450ec108
md"""
# *Input*/*Output* (IO)

1. [`CSV.jl`](https://github.com/JuliaData/CSV.jl): para ler qualquer arquivo delimitado -- `.csv`, `.tsv` etc.
2. [`XLSX.jl`](https://github.com/felipenoris/XLSX.jl): para ler arquivos Excel `.xslx` e `.xls`.
3. [`JSONTables.jl`](https://github.com/JuliaData/JSONTables.jl): para ler arquivos JSON `.json`.
4. [`Arrow.jl`](https://github.com/JuliaData/Arrow.jl): formato Apache Arrow para Big Data (que não cabe na RAM).
5. [`JuliaDB.jl`](https://juliadb.org/): leitura e manipulação de Big Data (que não cabe na RAM).
6. **Banco de Dados**: Julia também trabalha bem com banco de dados. Veja [juliadatabases.org](https://juliadatabases.org/)
"""

# ╔═╡ bd0fdeff-13c8-445e-86fc-bd619bd37645
md"""
## `CSV.jl`
"""

# ╔═╡ 811b2abe-a7ff-4985-a4a2-2b03301dc099
md"""
Óbvio que você já deve estar cansado disso, mas [Julia é mais rápida que R ou Python em leitura de CSVs](https://juliacomputing.com/blog/2020/06/fast-csv/):
"""

# ╔═╡ 07e01ad7-2f1c-45fd-88aa-a7e5e528fd52
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/fast_csv_heterogeneous.png?raw=true")

# ╔═╡ ba30be06-4c47-4e13-a263-2d3b77e78802
md"""
> Este dataset possui 10 mil linhas e 200 colunas. As colunas contêm `String`, `Float`, `DateTime` e `missing`. O Pandas leva cerca de 400 milissegundos para carregar este dataset. Sem multithreading, `CSV.jl` é 2 vezes mais rápido que R e cerca de 10 vezes mais rápido com 10 threads.

> Fonte: [Julia Computing em 2020](https://juliacomputing.com/blog/2020/06/fast-csv/).
"""

# ╔═╡ 68e791a3-cfff-4115-8cbe-b7cc40b67bc4
md"""
!!! tip "💡 Opções CSV.jl"
    `CSV.jl` tolera qualquer maluquice que vier pela frente de arquivo delimitado. Veja a documentação para a função [`CSV.File`](https://csv.juliadata.org/dev/#CSV.File).
"""

# ╔═╡ 75984809-48aa-4c14-a193-23695831c1b7
md"""
Tem várias maneiras de ler `.csv`s:

- Vanilla: `CSV.File(file) |> DataFrame` ou `CSV.read(file, DataFrame)`
- Brasileiro/Europeu: `CSV.read(file, DataFrame; delim=";", decimal=",")`
- Lendo da internet:
  ```julia
  using Downloads
  url = "..."
  CSV.read(Downloads.download(url), DataFrame)
  ```
- Lendo uma porrada de CSV de um diretório:
  ```julia
  files = filter(endswith(".csv"), readdir())
  CSV.read(files, DataFrame)
  ```
- Lendo arquivos comprimidos:
   - Gzip:
     ```julia
     CSV.read("file.csv.gz", DataFrame; buffer_in_memory=true)
     ```
   - Zip:
     ```julia
     using ZipFile
     z = ZipFile.Reader("file.zip")
     # identificar o arquivo correto no zip
     arquivo_csv_zip = filter(x->x.name == "a.csv", z.files)[1]
     CSV.read(aquivo_csv_zip, DataFrame)
     close(z)
     ```
- Lendo CSV em pedaços (*chunks*): `CSV.Chunks(source; tasks::Integer=Threads.nthreads(), kwargs...)`
- Lendo CSV de uma `String`:
  ```julia
  minha_string = "..."
  CSV.read(IOBuffer(minha_string), DataFrame)
  ```
"""

# ╔═╡ 456acc71-3199-481c-b37c-0041ddb18a11
md"""
!!! tip "💡 Escrevendo CSV"
    Só usar o `CSV.write`:

	`CSV.write(file, table; kwargs...) => file`

    `df |> CSV.write(file; kwargs...) => file`
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

# ╔═╡ 0224e6af-4b4b-45d8-b7a2-3a8152638b6a
md"""
Para arquivos pequenos a diferença não é impactante. Mas para arquivos grandes eu recomendo `CSV.read`. Aliás eu só uso essa função.
"""

# ╔═╡ b4ed9851-3c64-4d10-8160-5d2e90681e72
penguins_file = joinpath(pwd(), "..", "data", "penguins.csv")

# ╔═╡ 04b9e718-44a5-4e4d-9d4a-10b72a140e3c
@benchmark CSV.File($penguins_file) |> DataFrame

# ╔═╡ 6c7e84cd-0747-4291-ace4-e1b0fa079c97
@benchmark CSV.read($penguins_file, DataFrame)

# ╔═╡ f6d41644-3d13-4d4a-b8b8-c3fc9abec689
penguins = CSV.read(penguins_file, DataFrame; missingstring="NA")

# ╔═╡ fafdd689-6c1f-4036-aeb8-47c75cc73e9f
begin
	url = "https://github.com/tidyverse/dplyr/blob/main/data-raw/starwars.csv?raw=true"
	starwars = CSV.read(download(url), DataFrame; missingstring="NA")
end

# ╔═╡ ca69e258-32eb-479f-ab67-8d6969dc77ce
md"""
## XLSX.jl
"""

# ╔═╡ 0f601a7e-8b3c-4807-82cd-38cd448395b9
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/CSV_Excel_meme.png?raw=true")

# ╔═╡ d13b4e84-94d0-4b2e-af5f-0fb0b387465c
md"""
!!! danger "⚠️ O problema do Excel"
    **Excel altera os dados de maneira silenciosa**.

	Por exemplo, [pesquisadores tiveram que mudar o nome de 27 Genes](https://www.theverge.com/2020/8/6/21355674/human-genes-rename-microsoft-excel-misreading-dates) pois o Excel pensava que eram datas (e.g `MARCH1` não é 1 de Março mas sim [Membrane Associated Ring-CH-Type Finger 1](https://www.genenames.org/data/gene-symbol-report/#!/hgnc_id/HGNC:26077). Mais de [1/5 dos estudos publicados com dados genéticos tem erros do Excel](https://genomebiology.biomedcentral.com/articles/10.1186/s13059-016-1044-7).

	Além disso, **Excel "falha silenciosamente"**.

	Por exemplo, [um erro silencioso de Excel no pipeline de dados do COVID-19 no Reino Unido fez com que fosse subreportado mais de 15mil casos de COVID-19](https://www.engadget.com/microsoft-excel-england-covid-19-delay-114634846.html). Alguém muito inteligente usou o formato `.xls` que aguenta somente ≈65k linhas e depois disso ele para de escrever e não avisa o erro.

	>Veja mais histórias de horror do Excel no [European Spreadsheet Risk Interest Group](http://eusprig.org/horror-stories.htm).
"""

# ╔═╡ 7ba9ae9e-e141-4566-9db4-87b91aeed57b
md"""
Eu uso muito pouco Excel (aliás tenho asco de coisas pagas... 🤮). Só conheço duas funções de leitura e uma de escrita:

* `XLSX.readxlsx(file.xlsx)`: lê todo o arquivo XLSX e retorna uma espécie de índice de abas (_tabs_) e células. Ele funciona com um dicionário dá pra fazer uma indexação `xf["minha_aba"]`.


* `XLSX.readtable(file.xlsx, sheet)`: lê uma aba especifica do arquivo XLSX. Aceita como `sheet` uma `String` com o nome da aba ou um `Integer` começando em 1 com o índice da aba.
   * Essa função retorna uma tupla `(data, column_labels)` então é necessário colocar o operador *splat* `...` dentro do construtor `DataFrame`
   * Cuidado com o argumento `infer_eltypes`. Por padrão ele é `false` e vai te dar um `DataFrame` com um monte de colunas `Any`. Use `infer_eltypes = true`)


* `XLSX.writetable(file.xlsx, data, columnames)`: escreve um arquivo XLSX. Se atente que aqui precisa dos dados e do nome das colunas separados. `XLSX.writetable("df.xlsx", collect(eachcol(df)), names(df))`
"""

# ╔═╡ 4b03488e-634e-4c48-a84e-649d3dbf9c14
md"""
!!! tip "💡 Operações Avançadas com XLSX.jl"
    Veja esse [tutorial na documentação de `XLSX.jl`](https://felipenoris.github.io/XLSX.jl/dev/tutorial/). Tem várias maneiras de ler arquivos Excel: intervalo de células, arquivos grandes etc...
"""

# ╔═╡ d65393aa-9ece-44be-b1e6-1e73e4644d73
penguins_xlsx_file = joinpath(pwd(), "..", "data", "penguins.xlsx")

# ╔═╡ 9c003007-ec85-4e6d-81a0-6778224a2ea1
XLSX.readxlsx(penguins_xlsx_file)

# ╔═╡ 968878aa-7396-412c-9b6c-39f1cc199b1e
DataFrame(XLSX.readtable(penguins_xlsx_file, 1)...)

# ╔═╡ b331fa61-c49a-4e56-bcac-4a977d247637
md"""
# Funções de `DataFrames.jl`

São [muitas](https://dataframes.juliadata.org/dev/lib/functions/):

- `eachrow` e `eachcol`: iterador de linhas e colunas (dão suporte para funções `findnext`, `findprev`, `findfirst`, `findlast` e `findall`)
- `select` e `select!`: seleção e filtragem de colunas
- `filter`, `filter!`, `subset` e `subset!`: seleção e filtragem de linhas
- `sort` e `sort!`: ordenação de linhas
- `unique` e `unique!`: valores únicos de colunas
- `rename` e `rename!`: renomeamento de colunas
- `transform` e `transform!`: transformação/criação de colunas
- `insertcols!`: inserção de colunas
- `completecases`, `dropmissing`, `dropmissing!`, `allowmissing`, `allowmissing!`, `disallowmissing`, `disallowmissing!`, `coalesce`: valores faltantes
- `hcat`, `vcat`, `append!` e `push!`: concatenação de dados
- `combine`: sumarizações de colunas (muito usado com *joins*)
- `groupby`: agrupar dados por colunas
- `antijoin`, `crossjoin`, `innerjoin`, `leftjoin`, `outerjoin`, `rightjoin` e `semijoin`: *joins* de `DataFrame`s
- `stack`, `unstack` e `flatten`: redimensionamento de `DataFrame`s (formato *wide* ⇆ *long* e *nest* ⇆ *unnest*)
"""

# ╔═╡ 47325d97-c116-48c5-8c5a-b2525082a4ee
md"""
!!! tip "💡 Funções com !"
    Quase todas as funções de `DataFrames.jl` tem uma versão `funcao!` que faz a alteração *inplace* e retorna `nothing`. São funções convenientes e rápidas pois não geram alocações novas.
"""

# ╔═╡ 844deb5f-76ef-4857-b218-c6b3ff3e3646
md"""
# Indexação de `DataFrame`

Basicamente funciona assim, muito similar com as `Array`s:

```julia
df[row, col]
```

Onde:

* `row`:
   * uma única linha:
      * `Integer`: `df[1, col]`
      * `begin` e `end` também funcionam `df[end, col]`
   * várias linhas:
      * `UnitRange`: um intervalo `df[1:10, col]`
      * `Vector{Integer}`: `df[[1,2], col]`
      * `Vector{Bool}`: os índices que são `true`, `df[[false, true, true], col]`
   * todas as linhas:
      * `:`: todas as linhas (com cópia)
      * `!`: todas as linhas (sem cópia)
* `col`:
   * uma única coluna:
      * `Symbol`: `df[:, :col]`
      * `String`: `df[:, "col"]`
      * `Integer`: `df[:, 1]`
      * `begin` e `end` também funcionam `df[:, end]`
      * `df.col` também funciona e é igual a `df[!, :col]`
   * várias colunas:
      * `Vector{Symbol}`: `df[:, [:col1, :col2]]`
      * `Vector{String}`: `df[:, ["col1", "col2"]]`
      * `UnitRange`: um intervalo `df[:, 1:10]`
      * `Vector{Integer}`: várias colunas `df[:, [1,2]]`
      * `Vector{Bool}`: os índices que são `true`, `df[:, [false, true, true]]`
      * RegEx: `df[:, r"^col"]`
      * `Not`: uma negação bem flexível `df[:, Not(:col)]` ou `df[:, Not(1:5)]`
      * `Between`: um intervalo bem flexível `df[:, Between(:col1, :col5)]` ou `df[:, Between("col", 5)]`
      * `Cols`: seleção flexível de colunas `df[:, Cols(:col, "col", 5)]`
   * todas as colunas:
      * `:`
      * `All`: `df[:, All()]`
"""

# ╔═╡ 7eb0f340-7bb9-4942-a150-cbe0a9b89118
md"""
!!! tip "💡 Diferença entre df[!, :col] e df[:, :col]"
    `df[!, :col]`: substitui a coluna `:col` no `df` com um novo vetor passado no lado direito da expressão **sem copiar**.
	
	`df[:, :col]`: atualiza a coluna `:col` no `df` com um novo vetor passado no lado direito da expressão **fazendo uma cópia**.

	**O mais rápido é `df[!, :col]`**. `df[:, :col]` mantém a mesma coluna então faz checagem de tipo, não deixa você colocar uma coluna de tipos que não podem ser convertidos para o tipo original da coluna.

	> Note que `df[!, :col]` é o mesmo que `df.col`.
"""

# ╔═╡ ba120760-53a5-4b2b-929c-bcb939819334
md"""
## Linhas
"""

# ╔═╡ dc37999a-338b-4248-8bd8-07999fa09d1d
penguins[begin, :]

# ╔═╡ a51b287a-15e6-40f1-9eb2-bfd389af5731
penguins[1:10, :]

# ╔═╡ 689ff378-e97e-4632-9cac-9411ccfee789
penguins[[1,2], :]

# ╔═╡ 309e08fd-b84e-4c60-ac03-9574e5ff74bc
penguins[vcat(false, true, true, repeat([false], nrow(penguins)-3)), :]

# ╔═╡ 06e4452f-3ef7-41b6-a07d-20c5f3ce76ef
md"""
## Colunas
"""

# ╔═╡ f96c94ed-1235-4651-959e-e474fb6793a5
penguins.species

# ╔═╡ bc851d7c-8b9f-4a57-973a-d1a5076f2b9a
penguins[:, :species]

# ╔═╡ 6d6db43e-fb6d-4494-bf7e-d9bd2cc95e3d
penguins[:, end]

# ╔═╡ 69fc9893-5715-40b5-b192-3682828fb22e
penguins[:, 4]

# ╔═╡ a7282b59-3cbc-44d6-a91d-00ab6694cba0
penguins[:, 1:4]

# ╔═╡ 977b194a-302e-4965-93c4-226b8ca91440
penguins[:, r"mm$"] 

# ╔═╡ a170e72c-ae85-4a41-9447-08c5643ca994
penguins[:, Not(:species)]

# ╔═╡ 8f7cdd2d-2d3c-4c5e-a76a-79e4cdef5a68
penguins[:, Not(1:5)]

# ╔═╡ 3cc6096a-a559-489c-b70d-f7ee9c03a711
penguins[:, Cols(:species, "bill_length_mm", 5)]

# ╔═╡ 45c10fc6-b51c-43f0-8733-66114f31606c
md"""
!!! tip "💡 Designação"
    Qualquer indexação acima se você parear com um operador `=` de designação (`.=` vetorizado), você **altera os valores do `DataFrame`**. 

	```julia
	df[row, col] = ...    # um valor
	df[:, col] .= ...     # múltiplas linhas na mesma coluna
	df[row, :] .= ...     # múltiplas colunas na mesma linha
	```
"""

# ╔═╡ 543d473a-44a5-42b7-b820-7a3b5bd1d84e
md"""
# Semânticas de DataFrames.jl
"""

# ╔═╡ 3c75695c-6160-4385-a329-c52fe43ab283
md"""
!!! tip "💡 Semânticas de DataFrames.jl"
    Para muitas coisas `DataFrames.jl` usa a [semântica de `Pair`s](https://bkamins.github.io/julialang/2020/12/24/minilanguage.html):

	```julia
	:col => transformação => :nova_col
	```
"""

# ╔═╡ ebc8d4af-7257-4a74-bccd-8693c6fc26be
typeof(:age => mean => :mean_age)

# ╔═╡ 18a5f498-4d4d-4a47-ab5a-3b62df1c2d0b
md"""
# Selecionar Colunas de `DataFrame`

* `select`: retorna um `DataFrame`
* `select!`: retorna `nothing` e altera o `DataFrame` *inplace*

```julia
select(df, ...)
```

`select` e `select!` funcionam com todos os seletores de `col` que falamos acima:

* `select(df, :col1, :col2)`
* `select(df, [:col1, :col2])`
* `select(df, Not(:col1))`
* `select(df, Between(:col1, :col5))`
* `select(df, r"^col")`
"""

# ╔═╡ 2bc2529d-8931-4300-8a64-97b349c37e2d
select(penguins, r"^bill")

# ╔═╡ 9ca94b93-d587-4f43-abeb-23d4125fdb47
md"""
## Renomear Colunas de `DataFrame`

Renomeação de colunas pode ser feito de duas maneiras:

1. **apenas renomeando**: passando um pair em `rename`
   ```julia
   rename(df, :col => :nova_col)
   ```

> Funciona com todos os seletores de `col`.
"""

# ╔═╡ 66c9b74d-ec9b-4d21-9b7f-87cb9756c29f
rename(penguins, :species => :especies, :island => :ilha)

# ╔═╡ 11be77ad-91f4-4d1d-a16f-5fd72941b9d5
md"""
2. **selecionando e renomeando**: passando um `Pair` em um `select`
   ```julia
   select(df, :col => :nova_col)
   ```
"""

# ╔═╡ c2d12ce6-0dcc-4ccf-8ea2-7365a7ff60d3
select(penguins, :species => :especies)

# ╔═╡ 03b63951-8e92-448c-8e1a-cc3857cc3e8d
md"""
## Inserir novas colunas com `insertcols!`

Podemos também inserir novas colunas com `insertcols!` (essa função não tem versão sem `!`):

```julia
insertcols!(df, :nova_col=...)
```

> Funciona com todos os seletores de `col`.

Por padrão se não especificarmos o índice que queremos inserir a coluna automaticamente ela é inserida no final do `DataFrame`.
Caso queira inserir em um índice específico é só indicar a posição após o argumento `df`:

```julia
insertcols!(df, 3, :nova_col=...)      # insere no índice 3
insertcols!(df, :col2, :nova_col=...)  # insere no índice da :col2
insertcols!(df, "col2", :nova_col=...) # insere no índice da :col2
```
"""

# ╔═╡ 6c629f13-1d3f-47a4-a0fa-a05a601a6274
md"""
## Reordenar Colunas

Suponha que você queria reordenar colunas de um dataset.

Você consegue fazer isso com o `select` (ou `select!`) e o seletores de `col`:
"""

# ╔═╡ 83d1b730-18b4-4835-8c39-f9dd86d7722e
starwars |> names # antes

# ╔═╡ cc691c4f-80a1-4a61-ab70-8b611913ade5
select(starwars, Between(1,:name), Between(:sex, :homeworld), :) |> names #depois

# ╔═╡ 8c73a569-2d31-413c-9464-3bda8d811fc0
md"""
# Ordenar Linhas de `DataFrame`

* sort: retorna um DataFrame
* sort!: retorna nothing e altera o `DataFrame` *inplace*

> Funciona com todos os seletores de `col`.

Por padrão é ordem crescente (`rev=false`) e ordena todas as colunas começando com a primeira coluna:
```julia
sort(df, cols; rev=false)
```
"""

# ╔═╡ e4134fcf-9117-4561-ae38-5628f6d660ca
sort(penguins, :bill_length_mm)

# ╔═╡ ec537d76-c7c3-4108-b92e-505ccc5d2e57
sort(penguins, [:species, :bill_length_mm]; rev=true)

# ╔═╡ 664b3514-dfbd-4b4e-8ede-5b6ada310eab
sort(penguins, Not(:species); rev=true)

# ╔═╡ c960e354-3f67-44ff-b5ca-5898bbbae67d
md"""
# Filtrar Linhas de `DataFrame`

* `filter`: retorna um DataFrame
* `filter!`: retorna nothing e altera o `DataFrame` *inplace*

```julia
filter(fun, df)
```

* `subset`: retorna um DataFrame
* `subset!`: retorna nothing e altera o `DataFrame` *inplace*

```julia
subset(df, :col => fun)
```

> Funciona com todos os seletores de `col`.
"""

# ╔═╡ cc50b948-f35f-4509-b39e-287acbd9ad74
md"""
!!! tip "💡 filter vs subset"
    `filter` é um **despacho múltiplo da função `Base.filter`**. Portanto, segue a mesma convenção de `Base.filter`: primeiro vem a função e depois a coleção, no caso `DataFrame`.

	`subset` é uma **função de `DataFrames.jl`** portanto a API é **consistente** com as outras funções: `função(df, ...)`.

	`filter` é **MUITO mais rápido**, mas `subset` é mais conveniente para **múltiplas condições de filtragem** e lida melhor com **dados faltantes**.
"""

# ╔═╡ 8ffbf3c6-f92f-46f7-bf45-410102dfe474
filter(:species => ==("Adelie"), penguins)

# ╔═╡ 83d5f454-592a-4425-812d-323eebb257fa
filter(row -> row.species == "Adelie" && row.island ≠ "Torgensen", penguins)

# ╔═╡ fe546a4f-ab05-49cc-8123-e7e713417d0e
filter([:species, :island] => (sp, is) -> sp == "Adelie" && is ≠ "Torgensen", penguins)

# ╔═╡ 511bbea9-e5f8-4082-89ae-0bde99a0b552
md"""
!!! danger "⚠️ filter não lida muito bem com missing"
    Tem que usar o `!ismissing`.
"""

# ╔═╡ 3b709446-6daf-4fd7-8b62-8ed64ac8cfa9
filter(row -> row.bill_length_mm > 40, penguins)

# ╔═╡ e1849ea8-6cb7-4001-9ae5-508793ee7f0f
filter(row -> !ismissing(row.bill_length_mm > 40), penguins)

# ╔═╡ c571d48e-627e-414c-8b42-9243b1e952da
md"""
!!! tip "💡 Missing: subset para a salvação"
    `filter` com `!ismissing` fica beeeeeeem verboso. Aí que entra o `subset` com `skipmissing=true`.
"""

# ╔═╡ 8bd9020d-bd31-4ce4-a3aa-b831d453ab17
subset(penguins, :bill_length_mm => ByRow(>(40)); skipmissing=true)

# ╔═╡ 8a922b3f-a38f-47f9-8dc0-cffd829a4e3c
md"""
!!! tip "💡 ByRow"
    Um *wrapper* (função de conveniência) para vetorizar (*brodcast*) a operação para toda as observações da coluna.

	`ByRow(fun)` ≡ `x -> fun.(x)`

	Mas o `ByRow` é [**mais rápido** que a função anônima vetorizada](https://discourse.julialang.org/t/performance-of-dataframes-subset-and-byrow/60577).
"""

# ╔═╡ a2e0a0b4-bda6-480b-908f-5c1ff72a2490
@benchmark subset($penguins, :bill_length_mm => ByRow(>(40)); skipmissing=true)

# ╔═╡ 2bfb7633-2325-49ac-9d0f-eb4baf32f853
@benchmark subset($penguins, :bill_length_mm => x -> x .> 40; skipmissing=true)

# ╔═╡ 1360ab11-5a21-4068-89b1-48b763318398
md"""
!!! tip "💡 Benchmarks filter vs subset"
    `filter` é **mais rápido**, mas ele fica beeeem verboso rápido...
"""

# ╔═╡ 9eb436a0-d858-4999-b785-217c9b8d82c0
@benchmark filter(:species => ==("Adelie"), $penguins)

# ╔═╡ d33bef35-3591-472d-b31f-305308318a8d
@benchmark filter(row -> row.species == "Adelie", $penguins)

# ╔═╡ 714b5152-6258-4ce2-b54c-410ebac24275
@benchmark subset($penguins, :species => ByRow(==("Adelie")))

# ╔═╡ dcca805f-2778-4c41-8995-a90f14e44552
@benchmark subset($penguins, :species => x -> x .== "Adelie")

# ╔═╡ e8829151-00b9-4cdc-8023-e0b1b53f2f5d
md"""
!!! tip "💡 Benchmarks filter vs subset"
    `filter` é realmente **MUITO mais rápido**.
"""

# ╔═╡ 6e98e03f-5a0c-44a9-a379-4e7a61dc4bbd
@benchmark filter([:species, :island] => (sp, is) -> sp == "Adelie" && is ≠ "Torgensen", $penguins)

# ╔═╡ a4fde68a-ce63-4859-a679-ad2c69722e77
@benchmark subset($penguins,  [:species, :island] => ByRow((sp, is) -> sp ==("Adelie") && is ≠("Torgensen")))

# ╔═╡ 5d18d2c3-b2e4-4b67-bbf2-fbed41ba4f88
@benchmark subset($penguins, :species => ByRow(==("Adelie")), :island => ByRow(≠("Torgensen")))

# ╔═╡ 8a853221-931b-4e81-be90-27c1f92f3d35
md"""
# Transformações de `DataFrame`

* `transform`: retorna um DataFrame
* `transform!`: retorna nothing e altera o `DataFrame` *inplace*

> Funciona com todos os seletores de `col`.
"""

# ╔═╡ 11c7082d-36a8-4653-81cb-8fd95bf2c5ad
transform(penguins, names(penguins, r"mm$") .=> ByRow(x -> x/10))

# ╔═╡ 70cb0f17-46ef-4771-a8e0-208aabb84d21
cols_mm = names(penguins, r"mm$")

# ╔═╡ 9197d244-889f-4fef-a6d4-495e03b44a5a
cols_cm = replace.(cols_mm, "mm" => "cm")

# ╔═╡ 3842cd95-2b12-4e10-b12f-3c41bb24702c
transform(penguins, cols_mm .=> ByRow(x -> x/10) .=> cols_cm)

# ╔═╡ d3bd0723-002f-4e43-8e9f-fb40e60770c9
md"""
!!! tip "💡 O mundo não é feito de funções anônonimas"
    Você pode usar também funções existentes ou criadas por você.
"""

# ╔═╡ 0e8f6918-393f-4756-8722-3bf3bf094522
function mm_to_cm(x)
	return x / 10
end

# ╔═╡ a489eea5-fbe1-499c-9a77-5d9da26815e9
transform(penguins, cols_mm .=> ByRow(mm_to_cm) .=> cols_cm)

# ╔═╡ 695a3cbc-6664-4ab9-a059-ef0ed454be16
md"""
!!! tip "💡 Sem renomear colunas"
	`transform` e `tranform!` também aceitam um argumento `renamecols` que por padrão é `true`.

	Se você passar `renamecols=false` as colunas não são renomeadas para `col_function`
"""

# ╔═╡ 131d0f27-1b89-4c59-a7fb-3928217e971c
transform(penguins, cols_mm .=> ByRow(mm_to_cm); renamecols=false)

# ╔═╡ 7ca7168c-fa55-4808-be9c-e33b5df21708
md"""
!!! tip "💡 ifelse"
    Uma função interessante de se ter no bolso é a `ifelse`.
"""

# ╔═╡ a952354f-84b0-4050-a78f-002a953b0c48
select(penguins, :body_mass_g => ByRow(
		x -> ifelse(coalesce(x, 0) > mean(
				skipmissing(penguins.body_mass_g)),
			"pesado", "leve"))
	=> :peso)

# ╔═╡ 7f96c3c1-a93e-401d-9993-2c857f4002f5
md"""
!!! danger "⚠️ coalesce"
    Aqui eu fiz todos os `missing` de `:body_mass_g` virarem `0`.

	Veja a próxima seção sobre **Dados Ausentes**.
"""

# ╔═╡ 4818c8d6-d421-46ed-a31d-cade0ed1e5a8
md"""
## Exemplo mais Complexo com `starwars`
"""

# ╔═╡ a1bf0253-24d7-46e0-bc24-1ef2b80d793f
names(starwars)

# ╔═╡ e1abe2d3-6296-447a-a53a-d669f554ac8f
transform(
	dropmissing(select(starwars, Between(:name, :mass), :gender, :species)),
	[:height, :mass, :species] =>
                          ByRow((height, mass, species) ->
                                height > 200 || mass > 200 ? "large" :
                                species == "Droid" ? "robot" :
                                "other") =>
                          :type)

# ╔═╡ 857136e8-c2fc-4473-86ed-f351b2af17c6
md"""
# Sumarizações de Dados

As vezes você quer fazer coisas mais complexas que um `describe(df)` conseguiria fazer.

Nessas horas que entra o `combine`. Essa função retorna um dataframe apenas com as colunas especificadas e com as linhas determinadas pela transformação.

```julia
combine(df, ...)
```
"""

# ╔═╡ 7f05e0b8-2fd8-4bf6-a17a-83ed728d920f
md"""
!!! tip "💡 combine e groupby"
    `combine` é bastante utilizado com `groupby`. Isto vai ser coberto na seção de **Agrupamentos de `DataFrame`**.
"""

# ╔═╡ 7c81da5c-bc38-4f02-b613-fa783fde5e34
combine(penguins, nrow, :body_mass_g => mean ∘ skipmissing => :mean_body_mass)

# ╔═╡ f3ed3917-e855-4b14-b76f-e2d09c74e958
md"""
!!! info "💁 Composição de funções com ∘"
    Matematicamente o símbolo ∘ é o simbolo de composição de funções:
	
	$$f \circ g(x) = f(g(x))$$

	Então no nosso caso:
	```julia
	mean ∘ skipmissing == mean(skipmissing())
	```
"""

# ╔═╡ f155e53e-58e0-4535-bc9c-6c1dd6989d76
md"""
Ou fazer coisas mais complicadas:
"""

# ╔═╡ 130b1d66-e806-4a90-a2fe-f75fd7f4c2c5
combine(
	dropmissing(select(penguins, :body_mass_g, names(penguins, r"mm$"))), 
		[:body_mass_g, :bill_length_mm] => cor,
	    [:body_mass_g, :bill_depth_mm] => cor,
	    [:body_mass_g, :flipper_length_mm] => cor)

# ╔═╡ 7d67c6c6-15df-4b42-9ba7-cab2ae02cfb1
md"""
# Lidando com Dados Ausentes de `DataFrame`

Temos algumas funções para lidar com `missing`:

1. No **`DataFrame`**:
   * `dropmissing`: retorna um `DataFrame`
   * `dropmissing!`: retorna `nothing` e altera o `DataFrame` *inplace*
2. Na **`Array`**:
   * `skipmissing`: remove os valores `missing`, e.g. `sum(skipmissing(x))`
3. No **elemento escalar**:
   * `coalesce`: substitui o valor `missing` por algo especificado, e.g. `colaesce.(x, 0)`
"""

# ╔═╡ e629ce11-b734-4f30-b178-7241e335c45a
md"""
## `dropmissing` no `DataFrame`

```julia
dropmissing(df, cols)
```

> `cols` pode ser qualquer um dos seletores de `col`.

Se você **não especificar nenhum argumento como `cols` qualquer linha com qualquer `missing` é removida**. Ou seja, **limpeza total de `missing`s**: 
"""

# ╔═╡ f88fbf73-6737-409c-8ee3-98cb1fc51c75
dropmissing(penguins)

# ╔═╡ 21cfdb23-2b15-4279-84b9-cbcda9d49afe
dropmissing(penguins, r"mm$") # veja que temos `sex` vários missings

# ╔═╡ b315f5eb-104d-4f22-aa2f-04ac41335bcb
coalesce(missing, "falante")

# ╔═╡ 9f47e9ce-7a25-4673-af63-41ef2fe05e58
select(penguins, :sex => ByRow(x -> coalesce(x, "faltante")))

# ╔═╡ d7c3676e-0875-4755-83e7-b15fdcfdd9de
md"""
# Dados Categóricos com [`CategoricalArrays.jl`](https://github.com/JuliaData/CategoricalArrays.jl)

Tudo de manipulação de dados categóricos está em [`CategoricalArrays.jl`](https://github.com/JuliaData/CategoricalArrays.jl).

Qualquer `Array` pode ser convertida para `CategoricalArray`:

```julia
using CategoricalArrays

v = ["Group A", "Group A", "Group A", "Group B", "Group B", "Group B"]
cv = categorical(v)
```

> Por padrão `categorical` criará **valores como `UInt32` em ordem alfabética**.
"""

# ╔═╡ bc0a87b3-2412-470d-b67c-959108c75ef6
# CategoricalVector{String, UInt32}
cv = categorical(penguins.species)

# ╔═╡ bdbc9453-14a6-4cdd-8db6-39b925415be7
typeof(cv)

# ╔═╡ 8122592c-1f6d-4a79-a146-f0a4c729ab1b
md"""
!!! tip "💡 CategoricalArrays em Big Data"
	Se você estiver mexendo com Big Data pode usar o `compress=true` para comprimir para o menor tipo possível de `UInt` que pode ser usado para representar os diferentes valores categóricos da `Array`.
"""

# ╔═╡ 4821561e-2e16-48e7-a025-7c4674ab6689
# CategoricalVector{String, UInt8}
cv_compress = categorical(penguins.species; compress=true)

# ╔═╡ 8ffbc0cb-0857-4cd6-8830-2dc0fec46969
md"""
!!! tip "💡 Base.summarysize"
    Essa função de `Base` computa o tamanho da memória, em bytes, usada pelos todos objetos únicos acessíveis do argumento. Ela levanta **toda a capivara** de `Arrays`. 
"""

# ╔═╡ 508064ff-f281-45e4-9d91-7b4ae45f266f
Base.summarysize(cv)

# ╔═╡ b925755c-7b03-48ab-9215-68efa1b20ef3
Base.summarysize(cv_compress)

# ╔═╡ 877a20dc-6a08-468f-baf2-126fd250e074
md"""
## Categorias Ordenadas

O padrão de `categorical` é criar variáveis categóricas **não-ordenadas**.

Ou seja não conseguimos comparar uma categoria com outra:
"""

# ╔═╡ 38c3fda1-8248-4e57-ab18-db10907290e9
cv[begin] > cv[end] # Adelie > Chinstrap

# ╔═╡ 52c87379-cf27-43eb-91e3-0b696cb72f76
md"""
Apenas é possível comparações de igualdade com `==` ou `≠`:
"""

# ╔═╡ c2a5b5d6-26e1-4782-94e7-524d653a23a5
cv[begin] == cv[end] # Adelie == Chinstrap

# ╔═╡ 7d4e7237-6a9c-46c2-839a-916de5c4bb16
cv[begin] ≠ cv[end] # Adelie ≠ Chinstrap

# ╔═╡ 1c8e5c89-9fe5-4bc0-8e54-632597f0e9a3
md"""
Para isso precisamos do argumento `ordered=true`:
"""

# ╔═╡ 84d6af7c-c32a-4142-ab4e-90f712fd966a
cv_ordered = categorical(penguins.species; ordered=true)

# ╔═╡ 11fbe1ef-4902-4d7a-87cc-c608156f845f
typeof(cv_ordered)

# ╔═╡ 3fc3ca84-e1b9-4f02-96d9-984a43fae1f5
cv_ordered[begin] == cv_ordered[end] # Adelie == Chinstrap

# ╔═╡ 700f80f5-1916-424c-b56e-3632b7868b6a
cv_ordered[begin] > cv_ordered[end] # Adelie > Chinstrap

# ╔═╡ 74cf8979-b2d2-43af-89cd-0eaf73941fd6
md"""
Por padrão a ordenação é alfabética.

Mas raramente isso funciona...

Para trocar usamos o argumento `levels` e passamos a ordem de grandeza das categorias:
"""

# ╔═╡ cacb0ff8-34a3-4699-b9d8-c69effb4f6c0
# digamos que Chinstrap < Adelie < Gentoo
cv_ordered_custom = categorical(
	penguins.species;
	ordered=true,
	levels=["Chinstrap", "Adelie", "Gentoo"]
)

# ╔═╡ 4b766752-dcee-460a-a719-60f82850c16a
cv_ordered_custom[begin] > cv_ordered_custom[end] # Adelie > Chinstrap

# ╔═╡ c2dcd926-b27d-45d4-b10f-2a94223a6142
md"""
## Funções de [`CategoricalArrays.jl`](https://github.com/JuliaData/CategoricalArrays.jl)

- `categorical(A)` - constrói uma `CategoricalArray` com valores da `Array` `A`.
- `levels(A)` - retorna um vetor de valores únicos da `CategoricalArray` `A`.
- `levels!(A)` - define um vetor de valores como os rótulos da `CategoricalArray` `A` *inplace*.
- `levelcode(x)` - retorna o código do valor categórico `x` (para `Array`s, use `levelcode.(A)`).
- `compress(A)` - retorna uma cópia da `CategoricalArray` `A` usando o menor tipo de referência possível (igual a `categorical` com `compress=true`).
- `cut(x)` - corta uma `Array` numérica em intervalos e retorna uma `CategoricalArray` ordenada.
- `decompress(A)` - retorna uma cópia da `CategoricalArray` `A` usando o tipo de referência padrão (`UInt32`).
- `isordered(A)` - testa se as entradas em `A` podem ser comparadas usando `<`, `>` e operadores semelhantes.
- `ordered!(A, Bool)` - faz com que  as entradas em `A` podem ser comparadas usando `<`, `>` e operadores semelhantes.
- `recode(A [, default], pairs...)` - retorna uma cópia da `CategoricalArray` `A` após substituir um ou mais valores.
- `recode!(A [, default], pairs ...)` - substitua um ou mais valores na `CategoricalArray` `A` *inplace*
"""

# ╔═╡ bdc36c0b-99aa-4052-9cde-ea7635e366c6
isordered(cv_ordered)

# ╔═╡ 7b8b2876-073f-4469-83e3-f754db8e3123
collect(1:10)

# ╔═╡ 73a20699-6054-45db-b5d9-8fbba8287fa1
cut(1:5, 2)

# ╔═╡ 10903659-de58-4ad3-9b66-4bd4cf848f6c
cut(1:5, 2; labels=["Pequeno", "Grande"])

# ╔═╡ 09527938-62b3-471c-aa4e-bd527399a180
levels(cv)

# ╔═╡ 48459911-bfea-4a1c-a808-bf2eeb262352
levels!(cv_ordered, ["Chinstrap", "Adelie", "Gentoo"])

# ╔═╡ 4d588708-5ea9-46c0-98d1-d4b00c64cfbf
levels(cv_ordered)

# ╔═╡ 65cbf902-a6f9-46f1-bc5c-9852b37fdf1c
recode(cv, "Adelie" => "A", "Gentoo" => "G", "Chinstrap" => "C")

# ╔═╡ 14161886-664b-496d-9548-574fda7d7745
md"""
!!! tip "💡 Pegando Valores Numéricos de CategoricalArrays"
    As vezes precisamos dos valores numéricos para Matrizes e Modelos.

	Uma maneira é o `levelcode.(x)` e a outra é um [`for` loop com um `ifelse`](https://discourse.julialang.org/t/dummy-encoding-one-hot-encoding-from-pooleddataarray/4167/10):

	```julia
	for c in unique(df.col)
    	df[!, Symbol(c)] = ifelse.(df.col .== c, 1, 0)
	end
	```

	Outra opção é usar os [*contrast coding systems* de `StatsModels.jl`](https://juliastats.org/StatsModels.jl/latest/contrasts/#Contrast-coding-systems).
"""

# ╔═╡ fbe8762f-6ba7-45a5-8249-8a9edf0771ec
v = levelcode.(cv)

# ╔═╡ 6a528de5-cc31-45c8-bbfd-de2155211a5b
typeof(v)

# ╔═╡ fe1d94fe-f79a-437b-9d02-af61b46905a3
for c in unique(penguins.species)
    penguins[!, Symbol(c)] = ifelse.(penguins.species .== c, 1, 0)
end

# ╔═╡ 9f87b096-1879-46c6-9cb8-995e965a52e6
for c in unique(penguins.species)
    penguins[!, Symbol("species_$(c)")] = ifelse.(penguins.species .== c, 1, 0)
end

# ╔═╡ 6e22e6a9-b540-4ab1-ac8e-ecc00a6ed6e6
select(penguins, r"^species", [:Adelie, :Gentoo, :Chinstrap])

# ╔═╡ 971c9aa8-e5d4-41c3-9147-8bb95edb6dd7
md"""
# Agrupamento de `DataFrame`

`DataFrames.jl` dá suporte à operações de agrupamento (*Split/Apply/Combine*) com a função `groupby`.
"""

# ╔═╡ d0831039-639b-4e9f-8ca5-af64ac5f57ce
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/split_apply_combine.png?raw=true")

# ╔═╡ d7efcd51-c6e2-44f6-adad-bdfc8bed969a
md"""
!!! info "💁 GroupedDataFrame"
    Todo objeto retornado pelo `groupby` e um tipo `GroupedDataFrame`.
"""

# ╔═╡ 6df41c9e-2510-48b5-b79d-a6deca1ed1cb
md"""
Uma coisa importante do `groupby` é que ele pode ser seguido por algumas outras funções:

- `combine`: **não impõe restrições à quantidade de linhas retornadas**, a ordem das linhas é especificada pela ordem dos grupos em `GroupedDataFrame`. Normalmente é usado para **calcular estatísticas descritivas por grupo**.


- `select`: retorna um `GroupedDataFrame` com a **quantidade e ordem das linhas exatamente igual ao `DataFrame` de origem**, incluindo **apenas novas colunas calculadas**.


- `transform`: retorna um `GroupedDataFrame` com a **quantidade e ordem das linhas exatamente igual ao `DataFrame` de origem**, incluindo **todas as colunas da origem e as novas colunas calculadas**.
"""

# ╔═╡ b03af91d-789a-4441-95ce-9ac2f036c5c1
penguins_valid = dropmissing(penguins);

# ╔═╡ d27425e3-87f2-4dd6-947d-402f71551ec5
penguins_gdf = groupby(penguins_valid, :species)

# ╔═╡ 6370f7a5-892e-47fa-95cc-da786769b4e9
typeof(penguins_gdf)

# ╔═╡ 819aa9b5-dd3b-492d-bd2b-7e1750c77b00
keys(penguins_gdf)

# ╔═╡ c4272242-e948-4706-97d4-98f59434c36d
md"""
## `combine` em `GroupedDataFrame`
"""

# ╔═╡ 25e4ca67-b98e-4b0e-a319-082ca3cd4ef2
combine(penguins_gdf, nrow)

# ╔═╡ c297b585-a86f-41f7-8a0b-3b4264cd0ffd
combine(penguins_gdf,
	nrow => :n,
	:species => (x -> length(x) / nrow(penguins_valid)) => :perc)

# ╔═╡ 2ffc4229-f6a0-48c6-9eee-163bc9f1b19d
combine(penguins_gdf, :bill_length_mm => mean => :media_bico_comp)

# ╔═╡ 2369f081-371a-4a72-a031-c5760c12a1e9
combine(penguins_gdf, nrow, names(penguins_valid, r"mm$") .=> mean)

# ╔═╡ fddd9bc0-1b46-44c9-a18c-55ad9ccc4742
combine(penguins_gdf, :body_mass_g => (x -> [extrema(x)]) => [:min, :max])

# ╔═╡ b1bc56d0-36b0-49b0-807a-2fb2b88a8898
md"""
## `select` em `GroupedDataFrame`

> Obs: também pode ser usado o `select!`
"""

# ╔═╡ 80419314-5080-4eff-9e08-239d181a81b3
select(penguins_gdf, [:flipper_length_mm, :body_mass_g] => cor)

# ╔═╡ bc3fbc31-0ea5-4b57-86a8-96ef4678ffa2
md"""
## `transform` em `GroupedDataFrame`

> Obs: também pode ser usado o `transform!`
"""

# ╔═╡ 2ee52796-79c1-4c67-aa78-9e6e64fe8c32
transform(penguins_gdf, :species => ByRow(x -> "Pinguim $x"))

# ╔═╡ 4d4df9c8-fd91-4d74-a2e8-9eada35a1092
md"""
## Múltiplos Grupos

O `groupby` aceita todos os seletores de `col`:
"""

# ╔═╡ ea369275-302a-4ee0-a15e-a595f17fc4a9
penguins_gdf2 = groupby(penguins_valid, [:species, :island, :sex])

# ╔═╡ be05ff11-7688-4729-a25a-dd1c64819ab1
md"""
!!! tip "💡 Aplicar uma função em todas as colunas válidas (não-agrupantes)"
    Use a função `valuecols`.
"""

# ╔═╡ 0754fa8e-7e08-400c-8b55-c6366447b16a
combine(penguins_gdf2, valuecols(penguins_gdf2) .=> mean)

# ╔═╡ b3215fac-4eec-498b-8c05-7f9bb7fce952
md"""
## Opções Avançadas de Agrupamento

A função `groupby` tem alguns argumentos de *keyword* (todas `Bool` e com `false` como padrão):

* `sort`: ordenação do `GroupedDataFrame` resultante pelas colunas de agrupamento. 
* `skipmissing`: se vai remover grupos com valores `missing` por inteiro caso tenha algum valor faltante em uma das colunas de agrupamento.

As funções `combine`, `select` e `transform` possuem 3 argumentos de *keyword* quando aplicadas em um `GroupedDataFrame` (todos `Bool` e com `true` como padrão):


* `keepkeys`: se as colunas de agrupamento devem ser retornadas no `GroupedDataFrame`.
* `ungroup`: se o objeto retornado é um `DataFrame` ou um `GroupedDataFrame`.
* `renamecols`: se as colunas nos `cols => function` devem ter nomes automaticamente gerados pelas funções ou não.
"""

# ╔═╡ 7a2f9c21-71ff-4271-8166-3393a0e2dc57
md"""
## Desempenho de Agrupamento

Suponha que você queira o pinguim mais pesado de cada espécie.

Tem pelo menos 3 maneiras de fazer isso. E algumas implicações de desempenho:
"""

# ╔═╡ fa9947ea-1053-4857-92af-843d603bb1a7
combine(penguins_gdf) do sdf
	sdf[argmax(sdf.body_mass_g), :]
end

# ╔═╡ f2bda2c2-deab-4e07-834d-fa6760c9f73d
combine(groupby(penguins_valid, :species)) do sdf
	first(sort(sdf, :body_mass_g; rev=true))
end

# ╔═╡ 17180dad-8e9c-499e-aa92-4066dc70b117
combine(groupby(sort(penguins_valid, :body_mass_g; rev=true), :species), first)

# ╔═╡ fd507ef7-b210-46fc-8a7e-427450f7326f
@benchmark combine(groupby(penguins_valid, :species)) do sdf
	sdf[argmax(sdf.body_mass_g), :]
end

# ╔═╡ c881af06-1401-4c47-a38d-ae61212a936b
@benchmark combine(groupby(penguins_valid, :species)) do sdf
	first(sort(sdf, :body_mass_g; rev=true))
end

# ╔═╡ 62e51c8d-4de6-4834-92a5-b594bf31f073
@benchmark combine(groupby(sort(penguins_valid, :body_mass_g; rev=true), :species), first)

# ╔═╡ 05fa98bc-10fb-4f8a-91e8-9cdf3f68d9bd
md"""
!!! info "💁 SubDataFrame"
    `sdf` é um acrônimo para `SubDataFrame` que é o que ocorre embaixo do capô do `GroupedDataFrame`.

	`SubDataFrame` são *views*, isto quer dizer que eles dão acesso direto ao `DataFrame`/`GroupedDataFrame` pai, e portanto qualquer alteração em um `sdf` impacta o `df`/`gdf` correspondente.
"""

# ╔═╡ bdf30fe2-59d9-4d61-81a7-84f61a769c74
combine(penguins_gdf) do sdf
	typeof(sdf)
end

# ╔═╡ 6113bca4-9f27-4453-827c-56bd0667d9d6
md"""
# *Joins* de `DataFrame`

É possível fazer *joins* com `DataFrames`. Note que o tipo de retorno é sempre um novo `DataFrame`.

* `innerjoin`: contém linhas para valores da chave que existem em **todos** os `DataFrame`s.
* `leftjoin`: contém linhas para valores da chave que existem no **primeiro** `DataFrame` (à esquerda), independentemente de esse valor existir ou não no segundo `DataFrame` (à direita).
* `rightjoin`: contém linhas para os valores da chave que existem no **segundo** `DataFrame` (à direita), independentemente de esse valor existir ou não no primeiro `DataFrame` (à esquerda).
* `outerjoin`: contém linhas para valores da chave que existem em **qualquer um** dos `DataFrame`s.
* `semijoin`: similar ao `innerjoin`, mas restrita às colunas do primeiro `DataFrame` (à esquerda).
* `antijoin`: contém linhas para valores da chave que existem no **primeiro** `DataFrame` (à esquerda), **mas não no segundo** `DataFrame` (à direita) argumento. 
* `crossjoin`: **produto cartesiano de linhas de todos** os `DataFrame`s.
"""

# ╔═╡ 3696de64-fdc8-49b3-a45c-47482739d45e
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/joins.png?raw=true")

# ╔═╡ ebfeee0e-f776-47a3-b168-f2092377e2b5
md"""
!!! tip "💡 leftjoin!"
	DataFrames.jl (versão 1.3 em diante) suporta in-loco `leftjoin` com a função `leftjoin!`:  *left join* sem alocações 😎.
	Essa função atualiza o `DataFrame` esquerdo com as colunas unidas do `DataFrame` direito.
	Há uma ressalva de que cada linha da tabela esquerda deve corresponder a no máximo uma linha da tabela direita.
"""

# ╔═╡ 3a2d45f0-5f1b-40ed-b720-0d2aa7f5b9ca
people = DataFrame(ID = [20, 40], Name = ["Joãozinho", "Mariazinha"])

# ╔═╡ db434628-4961-405d-8d69-4f2e45976577
jobs = DataFrame(ID = [20, 40], Job = ["Advogado(a)", "Médico(a)"])

# ╔═╡ 6bcdb3b1-b0be-4d23-8862-75957e2cb036
md"""
!!! tip "💡 Chave de Join"
    O argumento mais importante do *join* é a chave `on`.
"""

# ╔═╡ 6b4a89f3-1f8d-4eb3-8ef0-c6464b9d15f1
innerjoin(people, jobs; on=:ID)

# ╔═╡ d0782f40-3def-481f-be7b-881a1dc9824e
leftjoin(people, jobs; on=:ID)

# ╔═╡ 67edfd75-3623-4e75-988d-08c0b958a9f5
rightjoin(people, jobs; on=:ID)

# ╔═╡ dd038402-c18a-4b44-a635-b749f63b13c7
outerjoin(people, jobs; on=:ID)

# ╔═╡ 7963b6de-998f-4add-bd94-cc7babe12816
semijoin(people, jobs; on=:ID)

# ╔═╡ e20f890c-b49b-4cbe-bd3a-4440f7f0174b
antijoin(people, jobs; on=:ID)

# ╔═╡ 8004bf73-bc80-4919-9790-e68c13cc69a7
md"""
!!! danger "⚠️ crossjoin"
    `crossjoin` **não** tem o argumento `on`. Mas se atente ao argumento `makeunique`.
"""

# ╔═╡ 83c5c631-95e5-4353-962c-94c572b1a692
crossjoin(people, jobs; makeunique=true)

# ╔═╡ a0a53ae6-3f6a-44fa-9486-638eb805c46d
md"""
## Chaves com Nomes Diferentes

Às vezes nossas tabelas tem chaves diferentes. `DataFrames.jl` usa a síntaxe de `Pair`:

```julia
left => right
```
"""

# ╔═╡ 50b882c1-3c0a-47c3-bea4-c0894b9be0f1
jobs_new = DataFrame(IDNew = [20, 40], Job = ["Advogado(a)", "Médico(a)"])

# ╔═╡ 83b0d0a8-11e8-4cbf-bde6-55164dd860ee
innerjoin(people, jobs_new; on=:ID => :IDNew)

# ╔═╡ 5cc5494d-43a7-44f3-994b-b9cd89b793c4
md"""
## Múltiplas Chaves

Para múltiplas chaves usamos um vetor de `Symbol` ou um vetor de `Pair` `left => right`:
"""

# ╔═╡ 1c4898a3-2a0e-41ec-8306-61343cd6be3a
cidades = DataFrame(
	City = ["Amsterdam", "London", "London", "New York", "New York"],
	Job = ["Advogado(a)", "Advogado(a)", "Advogado(a)", "Médico(a)", "Médico(a)"],
	Category = [1, 2, 3, 4, 5])

# ╔═╡ 1495fdc5-ebdd-4f41-8144-b9a987c064ee
locais = DataFrame(
	Location = ["Amsterdam", "London", "London", "New York", "New York"],
	Work = ["Advogado(a)", "Advogado(a)", "Advogado(a)", "Médico(a)", "Médico(a)"],
	Name = ["a", "b", "c", "d", "e"]
)

# ╔═╡ fbafda61-e057-457f-8d4a-227b03703cff
innerjoin(cidades, locais; on=[:City => :Location, :Job => :Work])

# ╔═╡ 5ac9f0b7-94d9-4836-9d7e-a91869ea0cf2
md"""
!!! danger "⚠️  Joins com missing"
    Para *joins* com valores `missing`, veja o argumento `matchmissing` das funções de *join*.

	Por padrão ele é `matchmissing=:error`.
"""

# ╔═╡ 26d3ecfa-6240-4dfc-9f73-14005d7c3191
md"""
# Redimensionamento de `DataFrame`

As vezes queremos converter `DataFrames` entre formato longo ou largo:

* `stack`: largo → longo.
* `unstack`: longo → largo.

A sintaxe é bem simples:

```julia
stack(df, cols)
unstack(df, cols)
```

> Funciona com todos os seletores de `col`.
"""

# ╔═╡ ba926e8e-0060-410d-bbd5-f99e19f0b98f
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/wide_vs_long.png?raw=true")

# ╔═╡ 99d1d4a7-5e0f-4747-bb13-7c555db23ab4
md"""
!!! tip "💡 variable e value"
    Por padrão `stack` define os nomes das colunas de variáveis como `:variable` e valores como `:value`. Mas você pode escolher o nome que quiser.
"""

# ╔═╡ 265d4dbb-5b20-4014-b469-74d85fd5ab15
long_penguins = stack(penguins_valid, Not([:species, :sex, :island]))

# ╔═╡ 270a65f2-20a6-4db2-a3de-2484b0ddad72
unstack(long_penguins,
	[:species, :sex, :island], :variable, :value;
	allowduplicates=true)

# ╔═╡ c4a91d4c-9afc-4551-b7ea-31ba1abf5e69
md"""
## Expansão de valores aninhados

Às vezes (em especial com aqueles malditos JSON) temos dados aninhados.

Aí que entra a função `flatten`.

Lorem ipsum, yada yada, a sintaxe é a mesma:

```julia
flatten(df, cols)
```

> Funciona com todos os seletores de `col`.
"""

# ╔═╡ 2b502c61-6ea4-4f7c-90f7-b0663f27dc6f
df_maldito = DataFrame(
	a=[1, 2],
	b=[[1, 2], [3, 4]],
	c=[[5, 6], [7, 8]]
)

# ╔═╡ 2427725c-515c-4820-845c-abd90c6db0cc
flatten(df_maldito, :b)

# ╔═╡ 769368ee-d378-43fa-ad48-20453f5c0913
flatten(df_maldito, [:b, :c])

# ╔═╡ 445ee8bc-75d8-4683-afd0-05582630a1ea
flatten(df_maldito, Not(:a))

# ╔═╡ 09402d9a-8586-4257-bd04-5c315508114a
md"""
!!! tip "💡 Tuplas"
    `flatten` também funciona com tuplas.
"""

# ╔═╡ 6eaf37ad-2f27-40b5-8af6-20f335b9fa40
df_maldito2 = DataFrame(
	a=[1, 2],
	b=[(1, 2), (3, 4)],
	c=[(5, 6), (7, 8)]
)

# ╔═╡ 2ad063bc-2176-49cc-9cf6-0fb09e3969f5
flatten(df_maldito2, Not(:a))

# ╔═╡ c2bc45aa-4dc0-4a94-9137-697c23db53f9
md"""
## Expansão para Colunas Diferentes

Se você não tem o intuito de duplicar valores como linhas (exemplo do `flatten`), você pode usar um [`transform` com o `AsTable`](https://discourse.julialang.org/t/expanding-named-tuples/62435/10) que converte as colunas em `NamedTuple`s:
"""

# ╔═╡ 3b1dda1b-bdfc-4dd6-930e-413edd3fdf8c
df_maldito_3 = DataFrame(
	a=[(1, 2, 3),
	   (4, 5, 6)])

# ╔═╡ 2ee241ae-31b7-4198-b5b6-2e4dc31e574b
transform(df_maldito_3, :a => ByRow(identity) => AsTable)

# ╔═╡ 40141f62-874b-4bc5-b6a3-233597edc9c4
transform(df_maldito_3, :a => AsTable ∘ ByRow(identity))

# ╔═╡ c6c5f26b-edd6-4ae4-afbe-450483c8d38d
md"""
!!! tip "💡 Por que x1, x2, ...?"
    Note que o construtor padrão de `DataFrame` gera automaticamente colunas `x1`, `x2`, ... e é isso que está acontecendo debaixo do capô do `ByRow(identity) => AsTable`.
"""

# ╔═╡ d0b43734-ec7f-4508-9b9e-8b6f4f602b07
select(
	transform(df_maldito_3, :a => ByRow(identity) => AsTable),
	Not(:a)
)

# ╔═╡ 1da692bb-fbc7-4cde-96c8-861d8305e78c
select(
	transform(df_maldito_3, :a => ByRow(identity) => AsTable),
	[:x1, :x2, :x3] .=> [:col1, :col2, :col3]
)

# ╔═╡ 2efad240-8517-4477-8055-b01423178383
md"""
!!! tip "💡 Nomes Informativos"
    Você pode também substituir `identity` por qualquer função que retorna uma `NamedTuple`.
"""

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
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
InteractiveUtils = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
XLSX = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"

[compat]
BenchmarkTools = "~1.3.1"
CSV = "~0.10.4"
CategoricalArrays = "~0.10.5"
DataFrames = "~1.3.2"
PlutoUI = "~0.7.12"
XLSX = "~0.7.9"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.2"
manifest_format = "2.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "4c10eee4af024676200bc7752e536f858c6b8f93"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.1"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "873fb188a4b9d76549b81465b1f75c82aaf59238"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.4"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "109664d3a6f2202b1225478335ea8fea3cd8706b"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.5"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "96b0bc6c52df76506efc8a441c6cf1adcb1babc4"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.42.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

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

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.EzXML]]
deps = ["Printf", "XML2_jll"]
git-tree-sha1 = "0fa3b52a04a4e210aeb1626def9c90df3ae65268"
uuid = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
version = "1.1.0"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "129b104185df66e408edd6625d480b7f9e9823a0"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.18"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

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

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "61feba885fac3a407465726d0c330b3055df897f"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

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

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

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

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "621f4f3b4977325b9128d5fae7a8b4829a0c2222"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.4"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "670e559e5c8e191ded66fa9ea89c97f10376bb4c"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.38"

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

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "6a2f7d70512d205ca8c7ee31bfa9f142fe74310c"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.12"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

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

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

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

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

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

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.XLSX]]
deps = ["Dates", "EzXML", "Printf", "Tables", "ZipFile"]
git-tree-sha1 = "2af4b3e329b51f1a41acb346e64156f904860a74"
uuid = "fdbf4ff8-1666-58a4-91e7-1b58723a45e0"
version = "0.7.9"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[deps.ZipFile]]
deps = ["Libdl", "Printf", "Zlib_jll"]
git-tree-sha1 = "3593e69e469d2111389a9bd06bac1f3d730ac6de"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.9.4"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
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
# ╟─0553799f-c084-4f24-85c4-6da4c26cf524
# ╟─4722d7bc-789f-4c4b-966f-483fd276a243
# ╟─99c0cc2a-b538-4b42-8a6e-ddf4d93c5baa
# ╟─edeabce5-2296-4eb5-9410-cdb9b6187e7e
# ╟─c390de55-1f7c-4278-9d99-fd75c94f5e9d
# ╟─9197ec1a-eb2b-4dea-bb96-5ff16a9c423f
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
# ╟─a885fe89-1d10-4fe1-b3fc-486c2abf80d5
# ╠═bf4b1f85-028b-4e0b-8336-63d3cfea28d3
# ╟─c4efdf84-8700-4ed9-b40a-965d9188ffbc
# ╟─de547f28-1eb5-4438-b088-adbeae032f55
# ╠═877c0807-b9a9-406c-ac5d-dd7478a197c6
# ╟─7f223d58-4bd1-4b3d-9c14-9d84d0b8e7dd
# ╠═d73508d0-649c-46c5-be35-fc0ae7990ee3
# ╟─77d83116-8d87-4313-aaaf-e57d0322c3fe
# ╠═39a3b34d-2cb5-4033-a243-c13af0a49b2c
# ╟─8d4c63fe-2c4c-40d4-b079-7a4fd2b55142
# ╠═ae553b32-49a0-4c45-950b-bb4400e069ae
# ╟─8959d49d-b019-442d-adb6-99c1450ec108
# ╟─bd0fdeff-13c8-445e-86fc-bd619bd37645
# ╟─811b2abe-a7ff-4985-a4a2-2b03301dc099
# ╟─07e01ad7-2f1c-45fd-88aa-a7e5e528fd52
# ╟─ba30be06-4c47-4e13-a263-2d3b77e78802
# ╟─68e791a3-cfff-4115-8cbe-b7cc40b67bc4
# ╟─75984809-48aa-4c14-a193-23695831c1b7
# ╟─456acc71-3199-481c-b37c-0041ddb18a11
# ╟─dd760bda-855b-41a0-bc59-be46943c5705
# ╟─0224e6af-4b4b-45d8-b7a2-3a8152638b6a
# ╠═b4ed9851-3c64-4d10-8160-5d2e90681e72
# ╠═04b9e718-44a5-4e4d-9d4a-10b72a140e3c
# ╠═6c7e84cd-0747-4291-ace4-e1b0fa079c97
# ╠═f6d41644-3d13-4d4a-b8b8-c3fc9abec689
# ╠═fafdd689-6c1f-4036-aeb8-47c75cc73e9f
# ╟─ca69e258-32eb-479f-ab67-8d6969dc77ce
# ╟─0f601a7e-8b3c-4807-82cd-38cd448395b9
# ╟─d13b4e84-94d0-4b2e-af5f-0fb0b387465c
# ╟─7ba9ae9e-e141-4566-9db4-87b91aeed57b
# ╟─4b03488e-634e-4c48-a84e-649d3dbf9c14
# ╠═d65393aa-9ece-44be-b1e6-1e73e4644d73
# ╠═9c003007-ec85-4e6d-81a0-6778224a2ea1
# ╠═968878aa-7396-412c-9b6c-39f1cc199b1e
# ╟─b331fa61-c49a-4e56-bcac-4a977d247637
# ╟─47325d97-c116-48c5-8c5a-b2525082a4ee
# ╟─844deb5f-76ef-4857-b218-c6b3ff3e3646
# ╟─7eb0f340-7bb9-4942-a150-cbe0a9b89118
# ╟─ba120760-53a5-4b2b-929c-bcb939819334
# ╠═dc37999a-338b-4248-8bd8-07999fa09d1d
# ╠═a51b287a-15e6-40f1-9eb2-bfd389af5731
# ╠═689ff378-e97e-4632-9cac-9411ccfee789
# ╠═309e08fd-b84e-4c60-ac03-9574e5ff74bc
# ╟─06e4452f-3ef7-41b6-a07d-20c5f3ce76ef
# ╠═f96c94ed-1235-4651-959e-e474fb6793a5
# ╠═bc851d7c-8b9f-4a57-973a-d1a5076f2b9a
# ╠═6d6db43e-fb6d-4494-bf7e-d9bd2cc95e3d
# ╠═69fc9893-5715-40b5-b192-3682828fb22e
# ╠═a7282b59-3cbc-44d6-a91d-00ab6694cba0
# ╠═977b194a-302e-4965-93c4-226b8ca91440
# ╠═a170e72c-ae85-4a41-9447-08c5643ca994
# ╠═8f7cdd2d-2d3c-4c5e-a76a-79e4cdef5a68
# ╠═3cc6096a-a559-489c-b70d-f7ee9c03a711
# ╟─45c10fc6-b51c-43f0-8733-66114f31606c
# ╟─543d473a-44a5-42b7-b820-7a3b5bd1d84e
# ╟─3c75695c-6160-4385-a329-c52fe43ab283
# ╠═ebc8d4af-7257-4a74-bccd-8693c6fc26be
# ╟─18a5f498-4d4d-4a47-ab5a-3b62df1c2d0b
# ╠═2bc2529d-8931-4300-8a64-97b349c37e2d
# ╟─9ca94b93-d587-4f43-abeb-23d4125fdb47
# ╠═66c9b74d-ec9b-4d21-9b7f-87cb9756c29f
# ╟─11be77ad-91f4-4d1d-a16f-5fd72941b9d5
# ╠═c2d12ce6-0dcc-4ccf-8ea2-7365a7ff60d3
# ╟─03b63951-8e92-448c-8e1a-cc3857cc3e8d
# ╟─6c629f13-1d3f-47a4-a0fa-a05a601a6274
# ╠═83d1b730-18b4-4835-8c39-f9dd86d7722e
# ╠═cc691c4f-80a1-4a61-ab70-8b611913ade5
# ╟─8c73a569-2d31-413c-9464-3bda8d811fc0
# ╠═e4134fcf-9117-4561-ae38-5628f6d660ca
# ╠═ec537d76-c7c3-4108-b92e-505ccc5d2e57
# ╠═664b3514-dfbd-4b4e-8ede-5b6ada310eab
# ╟─c960e354-3f67-44ff-b5ca-5898bbbae67d
# ╟─cc50b948-f35f-4509-b39e-287acbd9ad74
# ╠═8ffbf3c6-f92f-46f7-bf45-410102dfe474
# ╠═83d5f454-592a-4425-812d-323eebb257fa
# ╠═fe546a4f-ab05-49cc-8123-e7e713417d0e
# ╟─511bbea9-e5f8-4082-89ae-0bde99a0b552
# ╠═3b709446-6daf-4fd7-8b62-8ed64ac8cfa9
# ╠═e1849ea8-6cb7-4001-9ae5-508793ee7f0f
# ╟─c571d48e-627e-414c-8b42-9243b1e952da
# ╠═8bd9020d-bd31-4ce4-a3aa-b831d453ab17
# ╟─8a922b3f-a38f-47f9-8dc0-cffd829a4e3c
# ╠═a2e0a0b4-bda6-480b-908f-5c1ff72a2490
# ╠═2bfb7633-2325-49ac-9d0f-eb4baf32f853
# ╟─1360ab11-5a21-4068-89b1-48b763318398
# ╠═9eb436a0-d858-4999-b785-217c9b8d82c0
# ╠═d33bef35-3591-472d-b31f-305308318a8d
# ╠═714b5152-6258-4ce2-b54c-410ebac24275
# ╠═dcca805f-2778-4c41-8995-a90f14e44552
# ╟─e8829151-00b9-4cdc-8023-e0b1b53f2f5d
# ╠═6e98e03f-5a0c-44a9-a379-4e7a61dc4bbd
# ╠═a4fde68a-ce63-4859-a679-ad2c69722e77
# ╠═5d18d2c3-b2e4-4b67-bbf2-fbed41ba4f88
# ╟─8a853221-931b-4e81-be90-27c1f92f3d35
# ╠═11c7082d-36a8-4653-81cb-8fd95bf2c5ad
# ╠═70cb0f17-46ef-4771-a8e0-208aabb84d21
# ╠═9197d244-889f-4fef-a6d4-495e03b44a5a
# ╠═3842cd95-2b12-4e10-b12f-3c41bb24702c
# ╟─d3bd0723-002f-4e43-8e9f-fb40e60770c9
# ╠═0e8f6918-393f-4756-8722-3bf3bf094522
# ╠═a489eea5-fbe1-499c-9a77-5d9da26815e9
# ╟─695a3cbc-6664-4ab9-a059-ef0ed454be16
# ╠═131d0f27-1b89-4c59-a7fb-3928217e971c
# ╟─7ca7168c-fa55-4808-be9c-e33b5df21708
# ╠═a952354f-84b0-4050-a78f-002a953b0c48
# ╟─7f96c3c1-a93e-401d-9993-2c857f4002f5
# ╟─4818c8d6-d421-46ed-a31d-cade0ed1e5a8
# ╠═a1bf0253-24d7-46e0-bc24-1ef2b80d793f
# ╠═e1abe2d3-6296-447a-a53a-d669f554ac8f
# ╟─857136e8-c2fc-4473-86ed-f351b2af17c6
# ╟─7f05e0b8-2fd8-4bf6-a17a-83ed728d920f
# ╠═7c81da5c-bc38-4f02-b613-fa783fde5e34
# ╟─f3ed3917-e855-4b14-b76f-e2d09c74e958
# ╟─f155e53e-58e0-4535-bc9c-6c1dd6989d76
# ╠═130b1d66-e806-4a90-a2fe-f75fd7f4c2c5
# ╟─7d67c6c6-15df-4b42-9ba7-cab2ae02cfb1
# ╟─e629ce11-b734-4f30-b178-7241e335c45a
# ╠═f88fbf73-6737-409c-8ee3-98cb1fc51c75
# ╠═21cfdb23-2b15-4279-84b9-cbcda9d49afe
# ╠═b315f5eb-104d-4f22-aa2f-04ac41335bcb
# ╠═9f47e9ce-7a25-4673-af63-41ef2fe05e58
# ╟─d7c3676e-0875-4755-83e7-b15fdcfdd9de
# ╠═bc0a87b3-2412-470d-b67c-959108c75ef6
# ╠═bdbc9453-14a6-4cdd-8db6-39b925415be7
# ╟─8122592c-1f6d-4a79-a146-f0a4c729ab1b
# ╠═4821561e-2e16-48e7-a025-7c4674ab6689
# ╟─8ffbc0cb-0857-4cd6-8830-2dc0fec46969
# ╠═508064ff-f281-45e4-9d91-7b4ae45f266f
# ╠═b925755c-7b03-48ab-9215-68efa1b20ef3
# ╟─877a20dc-6a08-468f-baf2-126fd250e074
# ╠═38c3fda1-8248-4e57-ab18-db10907290e9
# ╟─52c87379-cf27-43eb-91e3-0b696cb72f76
# ╠═c2a5b5d6-26e1-4782-94e7-524d653a23a5
# ╠═7d4e7237-6a9c-46c2-839a-916de5c4bb16
# ╟─1c8e5c89-9fe5-4bc0-8e54-632597f0e9a3
# ╠═84d6af7c-c32a-4142-ab4e-90f712fd966a
# ╠═11fbe1ef-4902-4d7a-87cc-c608156f845f
# ╠═3fc3ca84-e1b9-4f02-96d9-984a43fae1f5
# ╠═700f80f5-1916-424c-b56e-3632b7868b6a
# ╟─74cf8979-b2d2-43af-89cd-0eaf73941fd6
# ╠═cacb0ff8-34a3-4699-b9d8-c69effb4f6c0
# ╠═4b766752-dcee-460a-a719-60f82850c16a
# ╟─c2dcd926-b27d-45d4-b10f-2a94223a6142
# ╠═bdc36c0b-99aa-4052-9cde-ea7635e366c6
# ╠═7b8b2876-073f-4469-83e3-f754db8e3123
# ╠═73a20699-6054-45db-b5d9-8fbba8287fa1
# ╠═10903659-de58-4ad3-9b66-4bd4cf848f6c
# ╠═09527938-62b3-471c-aa4e-bd527399a180
# ╠═48459911-bfea-4a1c-a808-bf2eeb262352
# ╠═4d588708-5ea9-46c0-98d1-d4b00c64cfbf
# ╠═65cbf902-a6f9-46f1-bc5c-9852b37fdf1c
# ╟─14161886-664b-496d-9548-574fda7d7745
# ╠═fbe8762f-6ba7-45a5-8249-8a9edf0771ec
# ╠═6a528de5-cc31-45c8-bbfd-de2155211a5b
# ╠═fe1d94fe-f79a-437b-9d02-af61b46905a3
# ╠═9f87b096-1879-46c6-9cb8-995e965a52e6
# ╠═6e22e6a9-b540-4ab1-ac8e-ecc00a6ed6e6
# ╟─971c9aa8-e5d4-41c3-9147-8bb95edb6dd7
# ╟─d0831039-639b-4e9f-8ca5-af64ac5f57ce
# ╟─d7efcd51-c6e2-44f6-adad-bdfc8bed969a
# ╟─6df41c9e-2510-48b5-b79d-a6deca1ed1cb
# ╠═b03af91d-789a-4441-95ce-9ac2f036c5c1
# ╠═d27425e3-87f2-4dd6-947d-402f71551ec5
# ╠═6370f7a5-892e-47fa-95cc-da786769b4e9
# ╠═819aa9b5-dd3b-492d-bd2b-7e1750c77b00
# ╟─c4272242-e948-4706-97d4-98f59434c36d
# ╠═25e4ca67-b98e-4b0e-a319-082ca3cd4ef2
# ╠═c297b585-a86f-41f7-8a0b-3b4264cd0ffd
# ╠═2ffc4229-f6a0-48c6-9eee-163bc9f1b19d
# ╠═2369f081-371a-4a72-a031-c5760c12a1e9
# ╠═fddd9bc0-1b46-44c9-a18c-55ad9ccc4742
# ╟─b1bc56d0-36b0-49b0-807a-2fb2b88a8898
# ╠═80419314-5080-4eff-9e08-239d181a81b3
# ╟─bc3fbc31-0ea5-4b57-86a8-96ef4678ffa2
# ╠═2ee52796-79c1-4c67-aa78-9e6e64fe8c32
# ╟─4d4df9c8-fd91-4d74-a2e8-9eada35a1092
# ╠═ea369275-302a-4ee0-a15e-a595f17fc4a9
# ╟─be05ff11-7688-4729-a25a-dd1c64819ab1
# ╠═0754fa8e-7e08-400c-8b55-c6366447b16a
# ╟─b3215fac-4eec-498b-8c05-7f9bb7fce952
# ╟─7a2f9c21-71ff-4271-8166-3393a0e2dc57
# ╠═fa9947ea-1053-4857-92af-843d603bb1a7
# ╠═f2bda2c2-deab-4e07-834d-fa6760c9f73d
# ╠═17180dad-8e9c-499e-aa92-4066dc70b117
# ╠═fd507ef7-b210-46fc-8a7e-427450f7326f
# ╠═c881af06-1401-4c47-a38d-ae61212a936b
# ╠═62e51c8d-4de6-4834-92a5-b594bf31f073
# ╟─05fa98bc-10fb-4f8a-91e8-9cdf3f68d9bd
# ╠═bdf30fe2-59d9-4d61-81a7-84f61a769c74
# ╟─6113bca4-9f27-4453-827c-56bd0667d9d6
# ╟─3696de64-fdc8-49b3-a45c-47482739d45e
# ╟─ebfeee0e-f776-47a3-b168-f2092377e2b5
# ╠═3a2d45f0-5f1b-40ed-b720-0d2aa7f5b9ca
# ╠═db434628-4961-405d-8d69-4f2e45976577
# ╟─6bcdb3b1-b0be-4d23-8862-75957e2cb036
# ╠═6b4a89f3-1f8d-4eb3-8ef0-c6464b9d15f1
# ╠═d0782f40-3def-481f-be7b-881a1dc9824e
# ╠═67edfd75-3623-4e75-988d-08c0b958a9f5
# ╠═dd038402-c18a-4b44-a635-b749f63b13c7
# ╠═7963b6de-998f-4add-bd94-cc7babe12816
# ╠═e20f890c-b49b-4cbe-bd3a-4440f7f0174b
# ╟─8004bf73-bc80-4919-9790-e68c13cc69a7
# ╠═83c5c631-95e5-4353-962c-94c572b1a692
# ╟─a0a53ae6-3f6a-44fa-9486-638eb805c46d
# ╠═50b882c1-3c0a-47c3-bea4-c0894b9be0f1
# ╠═83b0d0a8-11e8-4cbf-bde6-55164dd860ee
# ╟─5cc5494d-43a7-44f3-994b-b9cd89b793c4
# ╠═1c4898a3-2a0e-41ec-8306-61343cd6be3a
# ╠═1495fdc5-ebdd-4f41-8144-b9a987c064ee
# ╠═fbafda61-e057-457f-8d4a-227b03703cff
# ╟─5ac9f0b7-94d9-4836-9d7e-a91869ea0cf2
# ╟─26d3ecfa-6240-4dfc-9f73-14005d7c3191
# ╟─ba926e8e-0060-410d-bbd5-f99e19f0b98f
# ╟─99d1d4a7-5e0f-4747-bb13-7c555db23ab4
# ╠═265d4dbb-5b20-4014-b469-74d85fd5ab15
# ╠═270a65f2-20a6-4db2-a3de-2484b0ddad72
# ╟─c4a91d4c-9afc-4551-b7ea-31ba1abf5e69
# ╠═2b502c61-6ea4-4f7c-90f7-b0663f27dc6f
# ╠═2427725c-515c-4820-845c-abd90c6db0cc
# ╠═769368ee-d378-43fa-ad48-20453f5c0913
# ╠═445ee8bc-75d8-4683-afd0-05582630a1ea
# ╟─09402d9a-8586-4257-bd04-5c315508114a
# ╠═6eaf37ad-2f27-40b5-8af6-20f335b9fa40
# ╠═2ad063bc-2176-49cc-9cf6-0fb09e3969f5
# ╟─c2bc45aa-4dc0-4a94-9137-697c23db53f9
# ╠═3b1dda1b-bdfc-4dd6-930e-413edd3fdf8c
# ╠═2ee241ae-31b7-4198-b5b6-2e4dc31e574b
# ╠═40141f62-874b-4bc5-b6a3-233597edc9c4
# ╟─c6c5f26b-edd6-4ae4-afbe-450483c8d38d
# ╠═d0b43734-ec7f-4508-9b9e-8b6f4f602b07
# ╠═1da692bb-fbc7-4cde-96c8-861d8305e78c
# ╟─2efad240-8517-4477-8055-b01423178383
# ╟─d548bc1a-2e20-4b7f-971b-1b07faaa4c13
# ╟─228e9bf1-cfd8-4285-8b68-43762e1ae8c7
# ╟─23974dfc-7412-4983-9dcc-16e7a3e7dcc4
# ╟─93ae2b3a-67fb-46d2-b082-6dc47c1b8f7a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
