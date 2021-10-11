### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 27f62732-c909-11eb-27ee-e373dce148d9
begin
	using Pkg
	Pkg.activate(mktempdir())
	Pkg.add([
			"PlutoUI",
			"CSV",
			"DataFrames",
			"DataWrangler",
			"Forecast",
			"Plots",
			"RollingFunctions",
			"ShiftedArrays",
			"HTTP"
			])
	Pkg.add(url="https://github.com/pierrenodet/AutoARIMA.jl")
	
	using PlutoUI
	
	using AutoARIMA
	using Dates
	using DataFrames
	using DataWrangler
	using Forecast
	using Plots
	using RollingFunctions
	using ShiftedArrays
	
	using Statistics: mean
	using ShiftedArrays: lag, lead

	# evitar conflitos
	import HTTP # stack de DataFrames
	using DataFrames: transform
	using Base: isnothing
	using AutoARIMA: forecast
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
# Séries Temporais `DataFrames.jl`
"""

# ╔═╡ ff1ec432-ce73-4d04-8dcf-dea133894b67
Resource("https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg", :width => 120, :display => "inline")

# ╔═╡ b09513de-7df4-4fd5-95c4-d38965d6a666
md"""
!!! danger "⚠️ Disciplina Ferramental"
    **Esta disciplina é uma disciplina ferramental!**

	Portanto, se você não sabe o que é uma rede ou um grafo, pegue um livro-texto e estude ou pergunte pro seu orientador.
"""

# ╔═╡ 59b60d4a-04bf-425e-a443-1361af55a428
md"""
# O que são Séries Temporais?

Uma **série temporal** é uma coleção de observações feitas **sequencialmente** ao longo do tempo.
"""

# ╔═╡ 9eb79017-d135-44e9-a2ea-712829418a6d
md"""
 $N$ = $(@bind N_1 Slider(25:25:300, default=25, show_value=true))
"""

# ╔═╡ 38581a7b-2da4-49fb-b5e0-32db22cb3616
plot(Plots.fakedata(N_1), label=:none, lw=3, marker=:circle, xlab="\$N\$")

# ╔═╡ 23e24ad3-296b-4316-bb1b-617262b93a9b
md"""
!!! info "💁 Por quê Series Temporais são tão Especiais?"
    Dada a ordenação temporal dos dados, as observações não possuem o pressuposto de independência, portanto há uma **dependência temporal** que precisamos lidar.
"""

# ╔═╡ aa89ebab-573c-4819-b1c6-ffce3fff5a18
md"""
## Componentes de Séries Temporais

Geralmente uma série temporal tem alguns componentes:

$$y_t = S_t + T_t + R_t$$

Onde:

*  $y_t$ é a observação no tempo $t$.
*  $T_t$ é o componente de **têndencia** no tempo $t$.
*  $S_t$ é o componente **sazonal** no tempo $t$.
*  $R_t$ é o componente **residual** no tempo $t$.

Além disso classificamos como:

* **Estacionária**: também chamada de *convergente*, flutua em torno de uma mesma média ao longo do tempo.
* **Não-Estacionária**: também chamada de *divergente*, evoluem ao longo do tempo.

"""

# ╔═╡ f8ab9748-2002-4e48-82d2-60518e06f5cd
md"""
 $N$ = $(@bind N_2 Slider(50:50:600, default=300, show_value=true))
"""

# ╔═╡ 5d701b31-c830-4097-95ef-0e257ea36cb0
md"""
!!! info "💁 Visualizações de Séries Temporais"
    Há alguns pacotes mais especializados sobre como visualizar séries temporais. Em especial veja o [`TimeSeries.jl`](https://github.com/JuliaStats/TimeSeries.jl) e o [`Forecast.jl`](https://github.com/viraltux/Forecast.jl).
"""

# ╔═╡ edc92911-9627-45d3-a340-4292ce4cfc3e
md"""
# Exemplo com o Dataset de Viagens Áreas

Neste exemplo, preveremos os totais mensais em milhares de passageiros de companhias aéreas internacionais com dados de 1949 a 1960.

Ele está presente no pacote [`Forecast.jl`](https://github.com/viraltux/Forecast.jl):

```julia
using Forecast

ap = air()
```

Tem apenas duas colunas: `Date`e `Passengers` (em milhares)
"""

# ╔═╡ c958db84-9cb5-4398-b37a-15e8eb0b19f5
ap = air()

# ╔═╡ 733645f3-70d2-4e75-9688-7170dd3e3d3b
plot(ap.Date, ap.Passengers; marker=:circle, ms=3, lw=3, label=false)

# ╔═╡ 1a579b82-7552-4bba-bcaa-8eb507d34db4
md"""
!!! tip "💡 Tipos Date e DateTime"
    Dê uma olhada mais atenta na coluna `Date` do dataset `ap`. Ela é um tipo que não vimos antes: `Date`.
"""

# ╔═╡ e78c9151-baa3-4ec3-95bc-36843a42305c
describe(ap)

# ╔═╡ d67b34ed-4fd8-4f4b-9e9b-027dcef8e05f
md"""
# Módulo `Dates`

Julia possui o módulo [`Dates`](https://docs.julialang.org/en/v1/stdlib/Dates) na biblioteca padrão. Ou seja, já vem instalado em toda instalação de Julia e basta dar um:

```julia
using Dates
```
"""

# ╔═╡ d702c956-5765-433a-833a-fef06dacad8e
md"""
!!! info "💁 Como lidar com Datas e Tempo em Julia?"
    O `pandas` do Python usam seu próprio tipo `DateTime` para lidar com datas. O mesmo com o pacote `lubridate` do R `tidyverse`, que também define seu próprio tipo `datetime` para lidar com datas. Julia não precisa de nada disso, ela tem todas as coisas de **datas já embutidas em sua biblioteca padrão, em um módulo chamado `Dates`**.
"""

# ╔═╡ 8131495e-f21a-4473-bf7d-beb84c145636
md"""
O módulo da biblioteca padrão de datas tem dois tipos para trabalhar com datas:

* `Data`: representando o tempo em **dias**.
* `DateTime`: representando o tempo na precisão de **milissegundos**.

Podemos construir `Date` e `DateTime` com o construtor padrão, especificando um número inteiro para representar ano, mês, dia, horas e assim por diante:
"""

# ╔═╡ 0e22fdf9-7106-4e03-b73e-df63e4612a8f
Date(1987) # ano

# ╔═╡ baa42a2f-ac93-49ac-9af3-b794466f1b8f
Date(1987, 9) # mês

# ╔═╡ c085d76a-7d2e-48ea-820a-9baa303138b6
Date(1987, 9, 13) # dia

# ╔═╡ 3b05adc5-8a00-4807-9418-071326f10e18
DateTime(1987, 9, 13, 21) # hora

# ╔═╡ fef9271b-6956-4e5b-bc43-93501a05c2c1
DateTime(1987, 9, 13, 21, 21) # minuto

# ╔═╡ 0f1481ac-a337-4ff1-bc2d-f810dc90fcfb
md"""
> Para os curiosos, 13/09/1987 21:21 é a hora oficial de nascimento do professor da disciplina: José Storopoli.
"""

# ╔═╡ 15a25125-675a-4250-bfb5-56b982e63880
md"""
Também podemos passar tipos de `Period` para o construtor padrão. **Os tipos de `Period` são a representação equivalente humana do tempo para o computador**. As datas de Julia têm os seguintes subtipos abstratos de `Period`:
"""

# ╔═╡ cb6a5372-b6b2-48c7-ad48-30023cceac80
subtypes(Period)

# ╔═╡ a5e761fa-b3dd-46d9-95e0-ea72dd3d4dfc
md"""
Que se dividem nos seguintes tipos concretos, eles são bastante autoexplicativos:
"""

# ╔═╡ ab016abb-10ed-41cf-94a5-070440e96940
subtypes(DatePeriod)

# ╔═╡ 550f7cec-138d-40af-886c-878b8a17b974
subtypes(TimePeriod)

# ╔═╡ f0f81619-b99e-4329-9d7e-5d4831712937
md"""
Assim, poderíamos, alternativamente, construir a hora oficial de nascimento do professor como:
"""

# ╔═╡ 08eb4bd9-b812-40ee-b941-8c9ccde84771
DateTime(Year(1987), Month(9), Day(13), Hour(21), Minute(21))

# ╔═╡ b3621dc3-c897-4673-a15b-f79e993d0018
md"""
## Parseando Datas

Na maioria das vezes, não construiremos instâncias de `Date` ou `DateTime` do zero. Na verdade, provavelmente iremos **parsear strings como tipos `Date` ou `DateTime`**.

Os construtores `Date` e `DateTime` podem ser alimentados com uma string e uma string de formato. Por exemplo, a string `"19870913"` que representa 1º de janeiro pode ser analisada com:
"""

# ╔═╡ eb05091f-a13b-453a-b1bc-6a86b3e2a044
Date("19870913", "yyyymmdd")

# ╔═╡ facc2961-abb3-4452-862e-fb5917a37ef8
md"""
!!! tip "💡 DateFormat"
    Você pode encontrar mais informações sobre como especificar formatos diferentes como strings na [documentação de Julia `Dates`](https://docs.julialang.org/en/v1/stdlib/Dates/#Dates.DateFormat). Não se preocupe se você tiver que revisitá-lo o tempo todo, eu mesmo tenhop que fazer isso o tempo todo ao trabalhar com datas e *timestamps* de data/hora.
"""

# ╔═╡ 7733271e-5010-485e-b861-6b4382fbbd5e
md"""
Observe que o segundo argumento é uma representação de string do formato. Temos os primeiros quatro dígitos representando o ano `y`, seguidos por dois dígitos para o mês `m`, finalmente, dois dígitos para o dia `d`.

Também funciona para *timestamps* de data/hora com `DateTime`:
"""

# ╔═╡ 44c0f847-5084-4b88-9398-e14765d96dcf
DateTime("1987-09-13T21:21:00", "yyyy-mm-ddTHH:MM:SS")

# ╔═╡ 17dd18e2-1b0d-4f80-8634-cdb468ddf8db
md"""
!!! tip "💡 Desempenho de DateFormat"
    De acordo com a [documentação de Julia `Dates`](https://docs.julialang.org/en/v1/stdlib/Dates/#Constructors), usar o método `Date(date_string, format_string)` é adequado se for chamado **apenas algumas vezes**.

	Se houver muitas strings de data formatadas de forma semelhante para analisar, no entanto, é **muito mais eficiente** criar primeiro um tipo `DateFormat` e depois passá-lo em vez de uma string de formato bruto. Portanto, nosso exemplo anterior seria:

	```julia
	format = DateFormat("yyyymmdd")
	Date("19870913", format)
	```

	Como alternativa, **sem perda de desempenho**, você pode usar o prefixo literal de string `dateformat"..."`:

	```julia
	Date("19870913", dateformat"yyyymmdd")
	```
"""

# ╔═╡ 8e3b0051-24a1-43a0-b58f-de0086cb4d78
md"""
## Extraindo Informações de Datas

É fácil **extrair as informações desejadas dos objetos `Date` e `DateTime`**.

Primeiro, vamos criar uma instância de uma data muito especial:
"""

# ╔═╡ d7d4c668-5026-4702-b3d2-184d727197d0
my_birthday = Date("1987-09-13")

# ╔═╡ cb1fb301-21b2-456b-927f-9e2f2de4e159
md"""
Podemos extrair o que quisermos de `my_birthday`:
"""

# ╔═╡ 5055226f-477a-4fb9-b72c-aada4d954abb
year(my_birthday)

# ╔═╡ 41abfd3c-72c8-40ca-8e64-57bbcdd173af
month(my_birthday)

# ╔═╡ 7c2fe723-88be-4582-aab0-e24fa76fb897
day(my_birthday)

# ╔═╡ 487d0a02-907b-4454-b143-1b18bddd950c
md"""
O módulo `Dates` de Julia também tem **funções compostas que retornam uma tupla de valores**:
"""

# ╔═╡ 250bfa4d-0e2a-408b-9a8e-a4553c7ce4dc
yearmonth(my_birthday)

# ╔═╡ cbd76bd2-8741-4306-a30a-64c4d42c24a5
monthday(my_birthday)

# ╔═╡ 3ea5d363-d626-4999-95eb-a83a54e39343
yearmonthday(my_birthday)

# ╔═╡ 854fb72f-4cbd-4e5c-9068-51cd78b3c946
md"""
Também podemos ver o dia da semana e outras coisas úteis:
"""

# ╔═╡ 4b1bb682-249d-47f2-bcf7-917b402cc4bd
dayofweek(my_birthday)

# ╔═╡ 1a77baaf-ae62-49ef-8807-2f7b48f01974
dayname(my_birthday)

# ╔═╡ 1dfe096a-a614-4b12-b85e-33fc4edab1f5
dayofweekofmonth(my_birthday) # segundo domingo

# ╔═╡ 27d182d9-d6ed-4978-b250-34c814a87ba1
md"""
> Sim eu nasci no segundo domingo de Setembro.
"""

# ╔═╡ 66a8222a-6d38-464f-8466-59ef86f863ea
md"""
!!! tip "💡 Dias da Semana"
    Aqui está uma dica útil para recuperar apenas os dias da semana de oobjetos `Date`s. Basta usar um filtro em `dayofweek(sua_data) <= 5`.

	Para dias úteis você pode usar o pacote [`BusinessDays.jl`](`BusinessDays.jl`).
"""

# ╔═╡ a1ab378f-880a-4305-ae18-7bdbe28bef2a
md"""
## Operações com Datas

Podemos realizar **operações** em objetos de `Date`s.

Por exemplo, podemos adicionar dias a uma instância de `Date` ou `DateTime`. Observe que as datas de Julia realizarão automaticamente os ajustes necessários para anos bissextos, de meses com 30 ou 31 dias (isso é conhecido como aritmética *calendrical*)
"""

# ╔═╡ 8e369a6d-a489-4d5d-a3fe-8b3c40a37119
my_birthday + Day(90)

# ╔═╡ 750c5d4b-1167-4457-bc56-9917db2dee17
md"""
Podemos adicionar quantos quisermos:
"""

# ╔═╡ 0060e198-2eed-4fc2-83a7-d03d1d63a88b
my_birthday + Day(90) + Month(2) + Year(1)

# ╔═╡ 91c162d8-f325-455e-a5c8-84b5fc74eb4a
md"""
Para obter a **duração da data**, usamos apenas o operador de subtração `-`. Vamos ver quantos dias José tem:
"""

# ╔═╡ 88bff547-e22d-408c-a440-5eceae0319e7
today() - my_birthday

# ╔═╡ f07fa3b4-89fc-47f1-97d8-a708e72be343
md"""
A **duração padrão** dos tipos de `Date` é um objeto `Day`. Para `DateTime`, a **duração padrão** é um objeto `Millisecond`:
"""

# ╔═╡ 499b7a68-9e50-4662-9033-9a19b9434fd8
DateTime(today()) - DateTime(my_birthday)

# ╔═╡ 01108d2b-37e7-42f5-a2ff-5fca1167c891
md"""
## Intervalos de Datas

Uma coisa boa sobre o módulo `Dates` é que também podemos construir facilmente **intervalos de data e hora**.

Julia é inteligente o suficiente para não precisar definir todos os tipos de intervalo e operações que cobrimos na [Aula 1 - Linguagem Julia e Estrutura de Dados Nativas](https://storopoli.io/Computacao-Cientifica/1_Julia/). Julia apenas estende as funções e operações definidas para `UnitRange` para os tipos de `Date`.

> Isso é conhecido como despacho múltiplo e já abordamos na [Aula 1 - Linguagem Julia e Estrutura de Dados Nativas](https://storopoli.io/Computacao-Cientifica/1_Julia/).

Por exemplo, suponha que você deseja criar um intervalo de `Day`. Isso é feito facilmente com o operador dois pontos `:`
"""

# ╔═╡ 3346348c-2252-4472-805c-14594469fdbb
Date("2021-01-01"):Day(1):Date("2021-01-07")

# ╔═╡ 3b1d0c01-ed90-493a-8d38-81c92bd4b4f9
md"""
Não há nada de especial em usar o `Day(1)` como intervalo, podemos usar **qualquer tipo de `Period` como intervalo**. Por exemplo, usando 3 dias como intervalos:
"""

# ╔═╡ 387e3be7-2795-4a04-9b95-5b637286a544
Date("2021-01-01"):Day(3):Date("2021-01-07")

# ╔═╡ d840124d-c074-474c-b64c-19b5ec70a11b
md"""
Ou até meses:
"""

# ╔═╡ 63306f0b-46c5-43e2-8599-2e566e2e5cf4
Date("2021-01-01"):Month(1):Date("2021-03-01")

# ╔═╡ 9c04f616-4485-4b7c-ad85-06d6e0d20312
md"""
Observe que o **tipo deste intervalo é um `StepRange` com o tipo `Date` e tipo concretoo de `Period`** que usamos como intervalo dentro do operador dois pontos `:`
"""

# ╔═╡ a72d77cf-02f3-483b-a4e1-62ceb12008be
my_date_interval = Date("2021-01-01"):Month(1):Date("2021-03-01")

# ╔═╡ 8f721ddf-ba94-4d00-a009-8810f664a937
typeof(my_date_interval)

# ╔═╡ fe16de37-e8c3-4077-a888-95aefe0c2d80
md"""
Podemos converter isso em um vetor com a função `collect`:
"""

# ╔═╡ f378ce11-8e0b-49c3-89e4-20939b1f5f14
my_date_interval_vector = collect(my_date_interval)

# ╔═╡ 0bae3db9-9414-4b26-9f6f-bb503e0717ea
md"""
E ter todas as **funcionalidades de array disponíveis**, como, por exemplo, indexação:
"""

# ╔═╡ 20f6a1ce-93cd-43e3-8bac-6e9c6cf81d2a
my_date_interval_vector[end]

# ╔═╡ 0f4ec212-0022-4922-bf30-f0fe10f5e76e
md"""
Também podemos **vetorizar (*broadcast*) operações de data** para o nosso vetor de `Date`s:
"""

# ╔═╡ 8314024f-9418-4420-819b-9ac96b2e36c5
my_date_interval_vector .+ Day(10)

# ╔═╡ dac3e963-6470-41c0-8243-45d9561189f7
md"""
# O que Fazemos com Dados Temporais?

O mais importante é colocar eles em um `DataFrame` (veja [Aula 4 - Dados Tabulares com DataFrames.jl](https://storopoli.io/Computacao-Cientifica/4_DataFrames/)).

Depois disso tem várias coisas que podemos fazer....
"""

# ╔═╡ e0490ded-2eea-45e6-ad09-984f329839e9
md"""
## Usar as Funcionalidades do Módulo `Dates`

Podemos também usar as funcionalidades de `Dates` para manipular dados:
"""

# ╔═╡ 4ffbc763-16a4-4a63-90ea-ee8466423e75
transform!(ap,
	:Date => ByRow(dayofweek) => :DayWeek,
	:Date => ByRow(month) => :Month)

# ╔═╡ e4ea794a-4a6b-4a63-808b-fc93cabb7971
md"""
!!! danger "⚠️ Cuidado com Month vs month"
    Lembra `Month` é um construtor de um tipo `Month` e `month` é um extrator de meses de um objeto `Date` ou `DateTime`.

	A síntaxe CamelCase é para `struct`s `type`s e `module`s. O resto é snake_case.
"""

# ╔═╡ 4bca7094-79b1-438e-a4cd-1b0035e8218d
combine(groupby(ap, :DayWeek), :Passengers => mean)

# ╔═╡ 36674734-e58d-4984-88cc-bfad40a035d3
combine(groupby(ap, :Month), :Passengers => mean)

# ╔═╡ 878ad6c7-cfca-4af9-b999-32c83bc90d10
md"""
## Calcular valores com base em Valores Anteriores -- [`ShiftedArrays.jl`](https://github.com/JuliaArrays/ShiftedArrays.jl)

* `lag(v::AbstractArray, n = 1; default = missing)`
* `lead(v::AbstractArray, n = 1; default = missing)`
"""

# ╔═╡ 7c6e7292-c74f-4807-be07-44162a8cadd8
v = [1, 3, 5, 4]

# ╔═╡ de4425ad-866d-4654-b187-25b68bda5ca7
lag(v)

# ╔═╡ 3cbd6c11-ecce-401d-877b-a810118cdc7e
lead(v)

# ╔═╡ fc9793b6-d8ce-4ec0-a1ae-cd594cb25de8
md"""
Funciona também com intervalos:
"""

# ╔═╡ 93b4b297-e02f-418e-8569-8c9d1b290e0f
w = 1:2:9

# ╔═╡ df80ab42-4ea9-494f-9764-c0e841fb6949
lag(w, 2)

# ╔═╡ 71ba199b-b0e6-48c3-97ca-bd8277454f5d
lead(w, 2)

# ╔═╡ d3b4e17e-6432-45b6-b0bf-993b63bf1165
transform(ap, :Passengers => lag => :PassengerLag)

# ╔═╡ 89221be1-a1d8-43fe-9252-069a41b23703
transform(ap, :Passengers => (x -> lead(x, 2)) => :PassengerLead)

# ╔═╡ 2627e2e2-96de-4812-9542-ff7a28cbdc2f
md"""
## Calcular Estatísticas Móveis com base em Valores Anteriores -- [`RollingFunctions.jl`](https://github.com/JeffreySarnoff/RollingFunctions.jl)

Funções com dois prefixos:
* **`roll`**: retorna um vetor de tamanho `ndata - windowsize + 1`
* **`run`**: retorna um vetor de tamanho de `ndata`

Funções com vários sufixos:
* `min`, `max`, `mean`, `median`.
* `var`, `std`, `sem`, `mad`, `mad_normalized`.
* `skewness`, `kurtosis`, `variation`.
* `cor`, `cov`: correlação e covariância (sobre dois vetores de dados).
"""

# ╔═╡ 77b5a188-e6a6-4822-9c41-786b7904bc21
md"""
!!! tip "💡 Funções Customizadas"
    Além disso você pode usar suas **próprias funções criadas** para os dados com `rolling` e `running`:

	```julia
	rolling(function, data, windowsize)
	rolling(function, data1, data2, windowsize)
	```

	> OBS: também aceita dois vetores se for uma função complexa. Veja a documentação no [`README.md` do `RollingFunctions.jl`](https://github.com/JeffreySarnoff/RollingFunctions.jl#works-with-your-functions)
"""

# ╔═╡ e2c22ba6-faf2-41c1-b1f8-5119ae1dc14e
(length(v), length(w))

# ╔═╡ 1d77ec4b-d94a-487a-a910-fb6fc6aa6f6a
rollmean(v,1) # ndata - windowsize + 1

# ╔═╡ b253f241-a503-4932-951b-6cd890bbd70b
rollmean(v,2) # ndata - windowsize + 1

# ╔═╡ 87004299-9a20-4dca-aeaf-41d19bd772ed
rollmean(w,1) # ndata - windowsize + 1

# ╔═╡ 825bbd9c-f084-4a5e-b55c-376571b37e51
runmean(v, 1) # ndata

# ╔═╡ 3e448093-8265-4506-a450-c8fd21bb2931
runmean(v, 2) # ndata

# ╔═╡ a902af22-1e73-479a-8dec-3dca65961694
runmean(w, 1)

# ╔═╡ a8b4992d-4cd4-4338-80a9-887117847b79
md"""
## Decompor Séries Temporais

Como vocês viram **séries temporais** tem alguns componentes:

$$y_t = S_t + T_t + R_t$$

Onde:

*  $y_t$ é a observação no tempo $t$.
*  $T_t$ é o componente de **têndencia** no tempo $t$.
*  $S_t$ é o componente **sazonal** no tempo $t$.
*  $R_t$ é o componente **residual** no tempo $t$.


Tem várias maneiras de decompor uma série temporal:

* [**X-11**](https://otexts.com/fpp3/methods-used-by-official-statistics-agencies.html#x-11-method): originado no US Census Bureau e foi desenvolvido pela Statistics Canada. O método X-11 é um processo iterativo, usando médias móveis apropriadas para decompor uma série temporal.


* [**SEATS**](https://otexts.com/fpp3/methods-used-by-official-statistics-agencies.html#seats-method): **Se**asonal **E**xtraction in **A**RIMA **T**ime **S**eries. Procedimento foi desenvolvido no Banco da Espanha e agora é amplamente utilizado por agências governamentais em todo o mundo.


* [**STL**](): **S**easonal and **T**rend decomposition using **L**OESS. E LOESS é _**l**ocally **e**stimated **s**catterplot **s**moothing_ (basicamente uma interpolação polinomial)
"""

# ╔═╡ 6de89a61-a3d8-47f4-8c1d-0a5369da0bc5
begin
	n = 1000
	axb = LinRange(-1/2,pi+1/2,n)
	x = LinRange(0,pi,n)
	y = sin.(x) .+ rand(n)
	scatter(x, y; xlims=(-1/2,pi+1/2), ma=0.5, label="Dados", color=:grey)
	plot!(axb, loess(x,y,predict=axb); lw=4, la=0.7, label = "LOESS", color=:blue)
	plot!(x,sma(y,100,true); lw=4, la=0.7, label= "Média Movel 100", color=:orange)
	title!("LOESS")
	xlabel!("\$t\$")
end

# ╔═╡ 6d773bbf-579f-4035-b079-9a553e99e166
md"""
### STL -- **S**easonal and **T**rend decomposition using **L**OESS

STL tem várias **vantagens** sobre a decomposição clássica e os métodos SEATS e X-11:

* Ao contrário do SEATS e do X-11, o STL lida com **qualquer tipo de sazonalidade**, não apenas dados mensais e trimestrais.


* O componente **sazonal $S_t$ pode mudar ao longo do tempo** e a taxa de mudança pode ser **controlada pelo usuário**.


* A **suavidade do ciclo de tendência $T_t$ também pode ser controlada pelo usuário**.


* Pode ser robusto para *outliers* (ou seja, o usuário pode especificar uma decomposição robusta), de modo que **observações incomuns ocasionais não afetem as estimativas** do ciclo de tendência $T_t$ e componentes sazonais $S_t$. Eles irão, no entanto, afetar o componente residual $R_t$.

Decomposição STL está disponível no pacote [`Forecast.jl`](https://github.com/viraltux/Forecast.jl) com a função `stl`:
"""

# ╔═╡ 448a1eb3-0512-4e10-98c2-829e356ccea8
stl_ap = stl(ap.Passengers, 12; robust=true)

# ╔═╡ 213f02d5-679e-4d05-9f42-fa047663af50
typeof(stl_ap)

# ╔═╡ 2b674a78-f024-459b-b0c4-b4107730e7cd
plot(stl_ap)

# ╔═╡ 90351d6b-7117-4339-9c32-e5b80832b48c
md"""
#  Preparações de Dados Típicas em Séries Temporais

Além de colocar os dados em um `DataFrame`, muitas técnicas de séries temporais necessitam de um tratamento especial dos dados.
O pacote [`DataWrangler.jl`](https://github.com/viraltux/DataWrangler.jl) possui diversas funções com esse propósito:

* **Imputação de dados faltantes**
* **Normalização de dados** (por escore $z$, min-max, softmax ou sigmoid)
* **Deteção de _outliers_** (observações influentes)
"""

# ╔═╡ 8b9f03ac-e046-4279-8067-3381ae08871f
md"""
!!! info "💁 DataWranger.jl"
    O Pacote [`DataWrangler.jl`](https://github.com/viraltux/DataWrangler.jl) foi criado e é mantido pelo [viraltux](https://github.com/viraltux) que também é o criador dos pacotes [`Forecast.jl`](https://github.com/viraltux/Forecast.jl) e [`ForecastPlots.jl`](https://github.com/viraltux/ForecastPlots.jl).
"""

# ╔═╡ 0d8b34df-da80-4be8-b891-1ecc1243b1e1
let
	n = 1000
	x = sort(rand(n))*2*pi;
	y = Array{Union{Missing,Float64}}(undef,n);
	y[:] = sin.(x).+randn(n)/10;
	mid = vcat(100:150,300:350,600:650,950:1000);
	
	y[mid] .= missing;
	scatter(x,y; label="dados")
	
	ipy = impute(x,y; method = "normal")
	scatter!(x[mid],ipy[mid]; label = "imputed 'normal'", color=:white)
	
	ipy = impute(x,y)
	scatter!(x[mid],ipy[mid]; label = "imputed 'loess'", color=:black, markersize = 2)
	title!("Imputação de Dados Faltantes com DataWrangler.jl")
end

# ╔═╡ 907379d8-932c-48d2-8582-d1b4d6d41df0
let
	n = 1000
	x = sort(rand(n))*2*pi;
	y = Array{Union{Missing,Float64}}(undef,n);
	y[:] = sin.(x).+randn(n)/10
	mid = vcat(100:150,300:350,600:650,950:1000);
	y[mid] .= y[mid] .+ 2*(randn(length(mid)).+1)
	
	outlist = outlie(x,y)
	scatter(outlist, y[outlist]; color="blue", label="outliers",ms=6)
	scatter!(y,color="lightblue", label="dados")
	title!("Identificação de Outliers com DataWrangler.jl")
end

# ╔═╡ c9583420-6b50-4afb-aa34-7b070fbd50d6
md"""
# Maneiras de Modelar Séries Temporais

- $(HTML("<s>Frequentista</s>")):
   * Livro [Forecastring 3a edição](https://otexts.com/fpp3/)
   * Livro [Analysis of Financial Time Series 3a edição](https://faculty.chicagobooth.edu/ruey-s-tsay/research/analysis-of-financial-time-series-3rd-edition)
   * Pacote [`AutoARIMA.jl`](https://github.com/pierrenodet/AutoARIMA.jl): Modelos ARIMA.
   * Pacote [`Forecast.jl`](https://github.com/viraltux/Forecast.jl): foco em predição e visualizações, apenas modelos AR, decomposição STL.
- **Bayesiana**:
   * Livro [Bayesian Data Analysis 3a edição](http://www.stat.columbia.edu/~gelman/book/)
   * Livro [Statistical Rethinking 2a edição](https://xcelab.net/rm/statistical-rethinking/)
   * Manual do [`Stan`, seção 2 de Modelos de Séries Temporais](https://mc-stan.org/docs/stan-users-guide/time-series-chapter.html): ARIMA, GARCH, HMM etc.
   * Versão Bayesiana em `Stan` dos modelos do Livro Analysis of Financial Time Series 3a edição: [`marcomarconi/AFTS_with_Stan`](https://github.com/marcomarconi/AFTS_with_Stan) e [blog](https://notimeforbayes.blogspot.com/)
   * Pacote [`Turing.jl`](https://github.com/TuringLang/Turing.jl): [meus tutoriais em inglês](https://storopoli.io/Bayesian-Julia) e vamos falar sobre ele na [Aula 9 - Modelos Probabilísticos Bayesianos com `Turing.jl`](https://storopoli.io/Computacao-Cientifica/9_Turing/)
"""

# ╔═╡ 3d98552e-014c-4939-8e93-3b3536cd0898
md"""
!!! info "💁 Séries Temporais em Julia"
    Veja essa [lista de vários pacotes](https://discourse.julialang.org/t/time-series-in-julia-working-list/62539).
"""

# ╔═╡ edc542c7-8f70-4fa3-abcf-c9162ced69a0
md"""
## _**A**uto**r**egressive_ -- AR

O próprio nome diz, ele **regride em sí próprio**, ou seja você usa os dados em um tempo anterior como coeficientes do modelo.

Por exemplo um modelo **AR(1)** é:

$$y_t = \alpha + \beta \cdot y_{t-1} + \epsilon$$

Onde:

*  $y_t$: observação $y$ no tempo $t$.
*  $y_{t-1}$: observação $y$ no tempo $t-1$.
*  $\alpha$: constante (*intercept*).
*  $\beta$: coeficiente (*slope*).
*  $\epsilon$: erro ou resíduo.

Por exemplo um modelo **AR(2)** é:

$$y_t = \alpha + \boldsymbol{\beta}_1 \cdot y_{t-1} + \boldsymbol{\beta}_2 \cdot y_{t-2} + \epsilon$$

Onde:

*  $y_t$: observação $y$ no tempo $t$.
*  $y_{t-1}$: observação $y$ no tempo $t-1$.
*  $y_{t-2}$: observação $y$ no tempo $t-2$.
*  $\alpha$: constante (*intercept*).
*  $\boldsymbol{\beta}$: vetor de coeficientes (*slopes*).
*  $\epsilon$: erro ou resíduo.

De modo geral os modelos **AR($p$)** são:

$$y_t = \alpha + \sum^p_{i=1} \boldsymbol{\beta}_i \cdot y_{t-i} + \epsilon$$
"""

# ╔═╡ 05f271d7-8d3f-4aeb-917e-079defcd67e7
md"""
!!! tip "💡 ARCH e GARCH"
    Os modelos econométricos e financeiros de séries temporais geralmente assumem heterocedasticidade: eles permitem que a escala dos termos de erro que definem a série varie ao longo do tempo. O modelo mais simples é o _**A**uto**r**egressive **C**onditional **H**eteroscedasticity_ (ARCH) com extensões para o _**G**eneralized **A**uto**r**egressive **C**onditional **H**eteroscedasticity_ (GARCH)
"""

# ╔═╡ 37c4966e-6a4d-4f9d-905b-a806cc8b3ba6
md"""
## _**M**oving **A**verage_ -- MA

Um modelo de média móvel usa erros anteriores como preditores para resultados futuros. Para um modelo **MA($q$)** de média móvel de ordem $q$:

$$y_t = \alpha + \sum^q_{i=1} \boldsymbol{\theta}_i \cdot \boldsymbol{\epsilon}_{t-i}$$

Onde:

*  $y_t$: observação $y$ no tempo $t$.
*  $\alpha$: constante (*intercept*).
*  $\boldsymbol{\theta}$: vetor de coeficientes (*slopes*) para o erro.
*  $\boldsymbol{\epsilon}$: vetor de erros ou resíduos.
"""

# ╔═╡ 43fc389e-3daf-4a2d-b1c1-45dc10b53b49
md"""
## _**A**uto**r**egressive **M**oving **A**verage_ -- ARMA

Juncão do **AR($p$)** com o **MA($q$)** em **ARMA($p,q$)**:

$$y_t = \alpha + \sum^p_{i=1} \boldsymbol{\beta}_i \cdot y_{t-i} + \sum^q_{i=1} \boldsymbol{\theta}_i \cdot \boldsymbol{\epsilon}_{t-i}$$

Onde:

*  $y_t$: observação $y$ no tempo $t$.
*  $y_{t-i}$: observação $y$ no tempo $t-i$.
*  $\alpha$: constante (*intercept*).
*  $\boldsymbol{\beta}$: vetor de coeficientes (*slopes*).
*  $\boldsymbol{\theta}$: vetor de coeficientes (*slopes*) para o erro.
*  $\boldsymbol{\epsilon}$: vetor de erros ou resíduos.
"""

# ╔═╡ d13d7df1-7970-4696-8159-a17ba2ab9b03
md"""
## _**A**uto**r**egressive **Integrated** **M**oving **A**verage_ -- ARIMA

É o **ARMA($p,q$)** com uma média movel **integrada**.

Por exemplo, um **ARIMA($p,1,q$)**:

$$y_{t} - y_{t-1} = \alpha + \sum^p_{i=1} \boldsymbol{\beta}_i \cdot \left( y_{t-i} - y_{t-i-1} \right) + \sum^q_{i=1} \boldsymbol{\theta}_i \cdot \boldsymbol{\epsilon}_{t-i}$$

Onde:

*  $y_{t} - y_{t-1}$: diferença entre observação $y$ no tempo $t$ e observação no tempo $t-i$.
*  $y_{t-i} - y_{t-i-1}$: diferença entre observação $y$ no tempo $t-i$ e observação no tempo $t-i-1$
*  $\alpha$: constante (*intercept*).
*  $\boldsymbol{\beta}$: vetor de coeficientes (*slopes*).
*  $\boldsymbol{\theta}$: vetor de coeficientes (*slopes*) para o erro.
*  $\boldsymbol{\epsilon}$: vetor de erros ou resíduos.

De maneira geral, os modelos **ARIMA($p,d,q$)** são:

$$\sum^d_{i=1} \left( y_{t_{i}} - y_{t_{i-1}} \right) = \alpha + \sum^p_{i=1} \sum^d_{i=1} \boldsymbol{\beta}_i \cdot \left( y_{t_{i-1}} - y_{t_{i-2}} \right) + \sum^q_{i=1} \boldsymbol{\theta}_i \cdot \boldsymbol{\epsilon}_{t-i}$$

Onde:

*  $y_{t_{i}} - y_{t_{i-1}}$: diferença entre observação $y$ no tempo $t_i$ e observação no tempo $t_{i-1}$.
*  $\alpha$: constante (*intercept*).
*  $\boldsymbol{\beta}$: vetor de coeficientes (*slopes*).
*  $\boldsymbol{\theta}$: vetor de coeficientes (*slopes*) para o erro.
*  $\boldsymbol{\epsilon}$: vetor de erros ou resíduos.

Ou uma notação alternativa:

$$\begin{equation}
  \begin{array}{c c c c}
    (1-\beta_1 y - \cdots - \beta_p y^p) & (1-y)^d y_{t} &= &\alpha + (1 + \theta_1 y + \cdots + \theta_q y^q)\epsilon_t\\
    {\uparrow} & {\uparrow} & &{\uparrow}\\
    \text{AR($p$)} & \text{$d$ diferenças} & & \text{MA($q$)}\\
  \end{array}
\end{equation}$$

### Tudo acaba em $(HTML("<s>pizza</s>")) ARIMA

Como vocês podem ver... todos que vimos até agora são casos especiais de algum **ARIMA($p,d,q$)**:

* **AR($p$)**: **ARIMA($p,0,0$)**
* **MA($q$)**: **ARIMA($0,0,q$)**
* **ARMA($p,q)$**: **ARIMA($p,0,q$)**
"""

# ╔═╡ 4f08d209-8956-4f7b-bfcb-51dbf52dc135
md"""
Modelos **ARIMA** estão disponíveis no pacote [`AutoARIMA.jl`](https://github.com/pierrenodet/AutoARIMA.jl) com as funções:

* `fit(Params, y)`: passa um dos construtores abaixo e um vetor $y$.
* `forecast(Model, y_new)`: passa o modelo retornado por `fit` e um vetor $y_{t+i}$

E os construtores:

* `ARParams(c::Bool, p)`: **AR($p$)**
* `MAParams(q)`: **MA($q$)**
* `ARMAParams(c::Bool, p, q)`: **ARMA($p,q$)**
* `ARIMAParams(c::Bool, p, d, q)`: **ARIMA($p,d,q$)**
"""

# ╔═╡ 08a5e81b-72ad-4ed3-8bac-fa6d050c58c5
ar1 = ARParams(true, [1])

# ╔═╡ 07a95924-d638-4b15-8b8a-b99af5254865
m_ar1 = fit(ar1, float.(ap.Passengers))

# ╔═╡ b8939ebd-81bb-4e73-a6f2-7e1fe6ee471a
ma2 = MAParams([1, 2])

# ╔═╡ f24dd12d-039c-470c-9d1c-5f84538c5e6a
m_ma2 = fit(ma2, float.(ap.Passengers))

# ╔═╡ aa46d085-8757-4453-a34f-4d8891bce366
ar2ma3 = ARMAParams(true, [1, 2], [1, 3]) # notem que estou sem o 2 no q

# ╔═╡ 7a8bc69d-f3c1-4dbb-a8e0-373ca39bb06a
m_ar2ma3 = fit(ar2ma3, float.(ap.Passengers))

# ╔═╡ d68b6f54-8883-4453-95f2-533c528955ac
ar2i3ma3 = ARIMAParams(true, [1, 2], 3, [1, 2, 3]) # d não é vetor

# ╔═╡ 7c8af0f8-9ef8-4ed2-8d35-82827567fb81
m_ar2i3ma3 = fit(ar2i3ma3, float.(ap.Passengers))

# ╔═╡ 894c5e01-b7da-4f98-9594-fb06ec5d6642
forecast(m_ar1, float.(ap.Passengers)) # próximo ponto

# ╔═╡ ffa8b715-8974-481a-98c5-b5f101b0dff6
md"""
# Funções de Geração de Dados Sintéticos
"""

# ╔═╡ 661a485e-5721-4acc-96a4-39674ec27c1e
function generate_fake_data(N::Int; seasonality=false, noise=false, stationary=true)
	values = collect(1:N) .* 0.4
	if seasonality
		repeats = Int(floor(N/50))
		values = collect(1:50) .* 0.25
		values[1:9] .^=2.105
		values[10:50] .= values[1:41] .^2
		values = repeat(values, repeats)
	end
	if noise
		values += (randn(N) .* 2.5)
	end
	if !stationary
		values += collect(1:N) .* 0.4
	end
	return values
end

# ╔═╡ 849d7757-f5ff-41fc-9330-a83e063316b6
plot([
		generate_fake_data(N_2),
		generate_fake_data(N_2; seasonality=true),
		generate_fake_data(N_2; seasonality=true, noise=true),
		generate_fake_data(N_2; seasonality=true, noise=true, stationary=false)
		];
	layout=4, label=:none,
	title = ["Tendência" "Sazonalidade" "Ruído" "Não-Estacionária"] 
)

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

# ╔═╡ 659b4a75-c348-4cfa-b76e-420a4e224730
md"""
# Licença

Este conteúdo possui licença [Creative Commons Attribution-ShareAlike 4.0 Internacional](http://creativecommons.org/licenses/by-sa/4.0/).

[![CC BY-SA 4.0](https://licensebuttons.net/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)
"""

# ╔═╡ Cell order:
# ╟─cbc48ca5-f1a4-4e13-9323-2fd2c43d8612
# ╟─7bb67403-d2ac-4dc9-b2f1-fdea7a795329
# ╟─ff1ec432-ce73-4d04-8dcf-dea133894b67
# ╠═27f62732-c909-11eb-27ee-e373dce148d9
# ╟─b09513de-7df4-4fd5-95c4-d38965d6a666
# ╟─59b60d4a-04bf-425e-a443-1361af55a428
# ╟─9eb79017-d135-44e9-a2ea-712829418a6d
# ╟─38581a7b-2da4-49fb-b5e0-32db22cb3616
# ╟─23e24ad3-296b-4316-bb1b-617262b93a9b
# ╟─aa89ebab-573c-4819-b1c6-ffce3fff5a18
# ╟─f8ab9748-2002-4e48-82d2-60518e06f5cd
# ╟─849d7757-f5ff-41fc-9330-a83e063316b6
# ╟─5d701b31-c830-4097-95ef-0e257ea36cb0
# ╟─edc92911-9627-45d3-a340-4292ce4cfc3e
# ╠═c958db84-9cb5-4398-b37a-15e8eb0b19f5
# ╟─733645f3-70d2-4e75-9688-7170dd3e3d3b
# ╟─1a579b82-7552-4bba-bcaa-8eb507d34db4
# ╠═e78c9151-baa3-4ec3-95bc-36843a42305c
# ╟─d67b34ed-4fd8-4f4b-9e9b-027dcef8e05f
# ╟─d702c956-5765-433a-833a-fef06dacad8e
# ╟─8131495e-f21a-4473-bf7d-beb84c145636
# ╠═0e22fdf9-7106-4e03-b73e-df63e4612a8f
# ╠═baa42a2f-ac93-49ac-9af3-b794466f1b8f
# ╠═c085d76a-7d2e-48ea-820a-9baa303138b6
# ╠═3b05adc5-8a00-4807-9418-071326f10e18
# ╠═fef9271b-6956-4e5b-bc43-93501a05c2c1
# ╟─0f1481ac-a337-4ff1-bc2d-f810dc90fcfb
# ╟─15a25125-675a-4250-bfb5-56b982e63880
# ╠═cb6a5372-b6b2-48c7-ad48-30023cceac80
# ╟─a5e761fa-b3dd-46d9-95e0-ea72dd3d4dfc
# ╠═ab016abb-10ed-41cf-94a5-070440e96940
# ╠═550f7cec-138d-40af-886c-878b8a17b974
# ╟─f0f81619-b99e-4329-9d7e-5d4831712937
# ╠═08eb4bd9-b812-40ee-b941-8c9ccde84771
# ╟─b3621dc3-c897-4673-a15b-f79e993d0018
# ╠═eb05091f-a13b-453a-b1bc-6a86b3e2a044
# ╟─facc2961-abb3-4452-862e-fb5917a37ef8
# ╟─7733271e-5010-485e-b861-6b4382fbbd5e
# ╠═44c0f847-5084-4b88-9398-e14765d96dcf
# ╟─17dd18e2-1b0d-4f80-8634-cdb468ddf8db
# ╟─8e3b0051-24a1-43a0-b58f-de0086cb4d78
# ╠═d7d4c668-5026-4702-b3d2-184d727197d0
# ╟─cb1fb301-21b2-456b-927f-9e2f2de4e159
# ╠═5055226f-477a-4fb9-b72c-aada4d954abb
# ╠═41abfd3c-72c8-40ca-8e64-57bbcdd173af
# ╠═7c2fe723-88be-4582-aab0-e24fa76fb897
# ╟─487d0a02-907b-4454-b143-1b18bddd950c
# ╠═250bfa4d-0e2a-408b-9a8e-a4553c7ce4dc
# ╠═cbd76bd2-8741-4306-a30a-64c4d42c24a5
# ╠═3ea5d363-d626-4999-95eb-a83a54e39343
# ╟─854fb72f-4cbd-4e5c-9068-51cd78b3c946
# ╠═4b1bb682-249d-47f2-bcf7-917b402cc4bd
# ╠═1a77baaf-ae62-49ef-8807-2f7b48f01974
# ╠═1dfe096a-a614-4b12-b85e-33fc4edab1f5
# ╟─27d182d9-d6ed-4978-b250-34c814a87ba1
# ╟─66a8222a-6d38-464f-8466-59ef86f863ea
# ╟─a1ab378f-880a-4305-ae18-7bdbe28bef2a
# ╠═8e369a6d-a489-4d5d-a3fe-8b3c40a37119
# ╟─750c5d4b-1167-4457-bc56-9917db2dee17
# ╠═0060e198-2eed-4fc2-83a7-d03d1d63a88b
# ╟─91c162d8-f325-455e-a5c8-84b5fc74eb4a
# ╠═88bff547-e22d-408c-a440-5eceae0319e7
# ╟─f07fa3b4-89fc-47f1-97d8-a708e72be343
# ╠═499b7a68-9e50-4662-9033-9a19b9434fd8
# ╟─01108d2b-37e7-42f5-a2ff-5fca1167c891
# ╠═3346348c-2252-4472-805c-14594469fdbb
# ╟─3b1d0c01-ed90-493a-8d38-81c92bd4b4f9
# ╠═387e3be7-2795-4a04-9b95-5b637286a544
# ╟─d840124d-c074-474c-b64c-19b5ec70a11b
# ╠═63306f0b-46c5-43e2-8599-2e566e2e5cf4
# ╟─9c04f616-4485-4b7c-ad85-06d6e0d20312
# ╠═a72d77cf-02f3-483b-a4e1-62ceb12008be
# ╠═8f721ddf-ba94-4d00-a009-8810f664a937
# ╟─fe16de37-e8c3-4077-a888-95aefe0c2d80
# ╠═f378ce11-8e0b-49c3-89e4-20939b1f5f14
# ╟─0bae3db9-9414-4b26-9f6f-bb503e0717ea
# ╠═20f6a1ce-93cd-43e3-8bac-6e9c6cf81d2a
# ╟─0f4ec212-0022-4922-bf30-f0fe10f5e76e
# ╠═8314024f-9418-4420-819b-9ac96b2e36c5
# ╟─dac3e963-6470-41c0-8243-45d9561189f7
# ╟─e0490ded-2eea-45e6-ad09-984f329839e9
# ╠═4ffbc763-16a4-4a63-90ea-ee8466423e75
# ╟─e4ea794a-4a6b-4a63-808b-fc93cabb7971
# ╠═4bca7094-79b1-438e-a4cd-1b0035e8218d
# ╠═36674734-e58d-4984-88cc-bfad40a035d3
# ╟─878ad6c7-cfca-4af9-b999-32c83bc90d10
# ╠═7c6e7292-c74f-4807-be07-44162a8cadd8
# ╠═de4425ad-866d-4654-b187-25b68bda5ca7
# ╠═3cbd6c11-ecce-401d-877b-a810118cdc7e
# ╟─fc9793b6-d8ce-4ec0-a1ae-cd594cb25de8
# ╠═93b4b297-e02f-418e-8569-8c9d1b290e0f
# ╠═df80ab42-4ea9-494f-9764-c0e841fb6949
# ╠═71ba199b-b0e6-48c3-97ca-bd8277454f5d
# ╠═d3b4e17e-6432-45b6-b0bf-993b63bf1165
# ╠═89221be1-a1d8-43fe-9252-069a41b23703
# ╟─2627e2e2-96de-4812-9542-ff7a28cbdc2f
# ╟─77b5a188-e6a6-4822-9c41-786b7904bc21
# ╠═e2c22ba6-faf2-41c1-b1f8-5119ae1dc14e
# ╠═1d77ec4b-d94a-487a-a910-fb6fc6aa6f6a
# ╠═b253f241-a503-4932-951b-6cd890bbd70b
# ╠═87004299-9a20-4dca-aeaf-41d19bd772ed
# ╠═825bbd9c-f084-4a5e-b55c-376571b37e51
# ╠═3e448093-8265-4506-a450-c8fd21bb2931
# ╠═a902af22-1e73-479a-8dec-3dca65961694
# ╟─a8b4992d-4cd4-4338-80a9-887117847b79
# ╟─6de89a61-a3d8-47f4-8c1d-0a5369da0bc5
# ╟─6d773bbf-579f-4035-b079-9a553e99e166
# ╠═448a1eb3-0512-4e10-98c2-829e356ccea8
# ╠═213f02d5-679e-4d05-9f42-fa047663af50
# ╠═2b674a78-f024-459b-b0c4-b4107730e7cd
# ╟─90351d6b-7117-4339-9c32-e5b80832b48c
# ╟─8b9f03ac-e046-4279-8067-3381ae08871f
# ╟─0d8b34df-da80-4be8-b891-1ecc1243b1e1
# ╟─907379d8-932c-48d2-8582-d1b4d6d41df0
# ╟─c9583420-6b50-4afb-aa34-7b070fbd50d6
# ╟─3d98552e-014c-4939-8e93-3b3536cd0898
# ╟─edc542c7-8f70-4fa3-abcf-c9162ced69a0
# ╟─05f271d7-8d3f-4aeb-917e-079defcd67e7
# ╟─37c4966e-6a4d-4f9d-905b-a806cc8b3ba6
# ╟─43fc389e-3daf-4a2d-b1c1-45dc10b53b49
# ╟─d13d7df1-7970-4696-8159-a17ba2ab9b03
# ╟─4f08d209-8956-4f7b-bfcb-51dbf52dc135
# ╠═08a5e81b-72ad-4ed3-8bac-fa6d050c58c5
# ╠═07a95924-d638-4b15-8b8a-b99af5254865
# ╠═b8939ebd-81bb-4e73-a6f2-7e1fe6ee471a
# ╠═f24dd12d-039c-470c-9d1c-5f84538c5e6a
# ╠═aa46d085-8757-4453-a34f-4d8891bce366
# ╠═7a8bc69d-f3c1-4dbb-a8e0-373ca39bb06a
# ╠═d68b6f54-8883-4453-95f2-533c528955ac
# ╠═7c8af0f8-9ef8-4ed2-8d35-82827567fb81
# ╠═894c5e01-b7da-4f98-9594-fb06ec5d6642
# ╟─ffa8b715-8974-481a-98c5-b5f101b0dff6
# ╠═661a485e-5721-4acc-96a4-39674ec27c1e
# ╟─d548bc1a-2e20-4b7f-971b-1b07faaa4c13
# ╟─228e9bf1-cfd8-4285-8b68-43762e1ae8c7
# ╟─23974dfc-7412-4983-9dcc-16e7a3e7dcc4
# ╟─659b4a75-c348-4cfa-b76e-420a4e224730
