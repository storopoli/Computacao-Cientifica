### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 27f62732-c909-11eb-27ee-e373dce148d9
begin
	using Pkg
	using PlutoUI
	
	using AlgebraOfGraphics
	using CairoMakie
	using Colors
	using ColorSchemes
	using CSV
	using CategoricalArrays
	using DataFrames
	using LaTeXStrings
	using StatsPlots
	using Plots
	using Statistics: mean, std, cor

	# evitar conflitos com stack de DataFrames
	import HTTP
	
	# evitar conflitos
	using CairoMakie: boxplot, barplot!, density!, lines!, rangebars! , scatter!, surface!, xlims!
	using AlgebraOfGraphics: density, histogram, Surface
	
	
	# Seed
	using Random: seed!
	seed!(123)
end

# ╔═╡ ed513f16-1ff5-4ad8-a2cb-4294f15a0ff2
let
	using Dates

	x = today() - Year(1) : Day(1) : today()
	y = cumsum(randn(length(x)))
	z = cumsum(randn(length(x)))
	df = (; x, y, z)
	labels = ["series 1", "series 2", "series 3", "series 4", "series 5"]
	plt = data(df) *
		mapping(:x, [:y, :z] .=> "value", color=dims(1) => renamer(labels) => "series ") *
		visual(Lines)
	draw(plt)
end

# ╔═╡ fee7043e-efdb-45d0-8e2f-9554eb525a12
let
	# Download, extract, and load shapefile
	using Shapefile, ZipFile
	using Downloads: download
	t = mktempdir() do dir
		url = "https://data.bas.ac.uk/download/7be3ab29-7caa-46b8-a355-2e3233796e86"
		r = ZipFile.Reader(seekstart(download(url, IOBuffer())))
		for f in r.files
			open(joinpath(dir, f.name), write = true) do io
				write(io, read(f, String));
			end
		end
		Shapefile.Table(joinpath(dir, "add_coastline_medium_res_polygon_v7_4.shp"))
	end

	# Draw map
	plt = geodata(t) * mapping(:geometry, color = :surface) * visual(Poly)
	draw(plt; axis=(aspect=1,))
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
# Visualização de Dados com `Plots.jl`, `StatsPlots.jl` e `AlgebraOfGraphics.jl`
"""

# ╔═╡ a1044598-e24a-4399-983e-3a906e9fae51
Resource("https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg", :width => 120, :display => "inline")

# ╔═╡ 71876e1a-dd30-44e4-943f-af4582b74f6d
md"""
!!! danger "⚠️ Conflitos de Pacote"
    Notem que eu carreguei `Plots.jl`, `StatsPlots.jl`, `AlgebraOfGraphics.jl` e `CairoMakie.jl` então eu vou ter que resolver muitos **conflitos** com:

	```julia
	Pacote.função()
	```

	Provavelmente você não tenha que fazer isso no dia-a-dia.
"""

# ╔═╡ 038653f4-7d94-4aed-92ef-c1258db95146
md"""
## JuliaPlots

Aqui vamos falar dos pacotes de [`JuliaPlots`](https://github.com/JuliaPlots):

* [`Plots.jl`](https://github.com/JuliaPlots/Plots.jl): biblioteca original e mais utilizada de plotagem. Muito poderosa e simples de usar.


* [`StatsPlots.jl`](https://github.com/JuliaPlots/StatsPlots.jl): interface de `Plots.jl` com `DataFrame`s.


* [`Makie.jl`](https://github.com/JuliaPlots/Makie.jl): nova biblioteca que possui maiores custoomizações e mais poderosa que `Plots.jl`.


* [`AlgebraOfGraphics`](https://github.com/JuliaPlots/AlgebraOfGraphics.jl): interface de `Makie.jl` com `DataFrame`s, mas muito mais poderosa pois usa o [Grammar of Graphics](https://www.amazon.com/Grammar-Graphics-Statistics-Computing/dp/0387245448) (estilo `ggplot2`).
"""

# ╔═╡ c98b5ef9-8cce-448e-8a8d-1cd1e94fb5cd
md"""
!!! tip "💡 O quê usar?"
    Uma dica pessoal.

	`Plots.jl` para coisas **corriqueiras** de dia-a-dia.

	`AlgebraOfGraphics.jl` para coisas envolvendo **ciência de dados**, dados tabulares ou **estatística**.

	`Makie.jl` para **publicações** e coisas sérias ($\LaTeX$).
"""

# ╔═╡ 1d743482-02ae-4723-a35e-c23fcc79e2f5
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

# ╔═╡ 5718597f-051e-42e8-ba85-d5ef5898f0f3
md"""
$(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/palmerpenguins_1.png?raw=true", :width => 338))
$(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/palmerpenguins_2.png?raw=true", :width => 338))
"""

# ╔═╡ 7ee550f4-39f8-4678-a101-eb506ea3ebc1
penguins_file = joinpath(pwd(), "..", "data", "penguins.csv")

# ╔═╡ d0f51a90-f6b0-402d-bfd7-891abc065a48
penguins = CSV.read(penguins_file, DataFrame; missingstring="NA")

# ╔═╡ ac54b4e0-33f5-426e-820e-3e9f002c2e91
dropmissing!(penguins) # 11 missings

# ╔═╡ 43c658ee-f378-450a-9d7c-97b603b56e62
md"""
# [`Plots.jl`](https://github.com/JuliaPlots/Plots.jl)

$(Resource("https://github.com/JuliaPlots/PlotDocs.jl/blob/master/docs/src/assets/axis_logo.svg?raw=true", :width => 250))

A primeira que vamos cobrir é [`Plots.jl`](https://github.com/JuliaPlots/Plots.jl).

```julia
using Plots
```

`Plots.jl` possui **duas** funções principais:

* **`plot`**: retorna um `plotobj`.
* **`plot!`**: altera um `plotobj` *inplace*.
"""

# ╔═╡ b447e5e9-6647-46cd-b793-bf2ec2025a12
p1 = Plots.plot(1:10)

# ╔═╡ 670086e1-fcb5-4fd6-9685-7dbbfc50080e
Plots.plot!(p1, 2:5)

# ╔═╡ 0f79aeb6-b31f-4f9c-9e0c-2718fe650619
md"""
!!! tip "💡 O que está acontecendo aqui?"
    Simples, o intervalo `1:10` é convertido para uma `Array` e `Plots.jl` entende que isso é uma série a ser plotada no eixo vertical (eixo-`y`) e então ele cria implicitamente uma série para o eixo horizontal (eixo-`x`) começando em `1` e com o mesmo tamanho de `1:10`. Logo, eixo-`y` `1:10` e eixo-`x` `1:10`.

	No segundo exemplo acontece o mesmo, mas com `2:5` no eixo-`y` e `1:4` no eixo-`x`.
"""

# ╔═╡ b0953f8a-0393-4352-83d2-cd40c06d90a9
md"""
## `seriestype`

As duas funções `plots` e `plots!` tem um argumento *keyword* chamado **`seriestype`** que define o **tipo de gráfico que você quer plotar**. Por padrão é `:line`.

Mas temos outros (muitos outros):
"""

# ╔═╡ 8df33c6f-654d-4fe9-882f-cc7a17044ac4
DataFrame(
	series=Plots.all_seriestypes()
)

# ╔═╡ 3adba103-7866-46e2-b26f-12476d9147cc
Plots.plot(1:10; seriestype=:scatter)

# ╔═╡ 399f99e1-e4f7-4c9b-ba0c-c120cab5e4e9
md"""
Na verdade `Plots.jl` exporta todos esses como funções:
"""

# ╔═╡ a85cd5f2-cc1d-42e2-993a-7914a539c81e
p2 = Plots.scatter(1:10)

# ╔═╡ 71895560-48fc-4005-8898-b27d140ea468
md"""
E há versões com `!`:
"""

# ╔═╡ 368290eb-3968-4a9e-9d52-8790cf1b46a4
Plots.scatter!(p2, 2:5)

# ╔═╡ 288748f6-5245-4aae-a6ac-920158f1d9f6
md"""
!!! info "💁 Seriestype como Funções"
    Para todas as seriestype há uma função `seriestype` que retorna um `plotobj` e uma função `seriestype!` que altera um `plotobj` *inplace*.
"""

# ╔═╡ 03ace772-d78e-4cc4-8e16-b650f16f7e9d
md"""
## Input Data

Que tipos de dados podem ser fornecidos ao `Plots.jl`?

Para `Plots.jl` inputs são argumentos posicionais e não argumento *keyword*:

* **`plot(y)`**: trata `y` como input para o eixo-`y` e replica um `UnitRange` de `1:length(y)` como eixo-`x`.


* **`plot(x, y)`**: plot 2-D "vanilla".


* **`plot(x, y, z)`**: plot 3-D.

A maneira mais fácil é usar `Vector`s (`Array`s 1-D):
"""

# ╔═╡ 21f2fd59-f74d-4fd4-a645-24066643d4cc
Plots.scatter([1, 2, 3], [4, 5, 6])

# ╔═╡ 36783771-3729-4fd3-893d-2ca7cab1777f
md"""
### Colunas são séries

Se você passar uma matriz (`m` x `n`) `Plots.jl` criará `n` séries com `m` observações.
"""

# ╔═╡ 0378f4c1-1d4b-4255-a545-22e44d73426e
Plots.plot(rand(10, 4))

# ╔═╡ f5c64355-fae0-4dcd-846a-bc51221cde35
md"""
## Salvar gráficos de `Plots.jl`

Isto é a função `Plots.savefig`:

```julia
savefig("myplot.png")    # salva o CURRENT_PLOT como um .png
savefig(p, "myplot.pdf") # salva o plot de p como um gráfico vetorizado .pdf
```
"""

# ╔═╡ 069fc1e2-d273-41f2-bae0-c9610b5b46fa
md"""
## *Backends*

* **`GR`**: O que é o padrão e o que eu estou usando. Função `gr()`.


* **`PGFPlotsX`**: converte em $\LaTeX$ com o [`pgfplots`](https://ctan.org/pkg/pgfplots). Útil para publicação. Função `pgfplotsx()`.


* **`Plotly`**: muito bom para interatividade, usa a biblioteca JavaScript [`PlotlyJS`](https://plotly.com/javascript/) no navegador. Função `plotlyjs()`.

Todos os *backends* dão suporte à `png` and `pdf`, alguns também dão suporte à `svg`, `ps`, `eps`, `html` e `tex`.
"""

# ╔═╡ e3444c25-5e2d-4525-abe3-0b24a6b4f56d
md"""
!!! danger "⚠️ PGFPlotsX vs PGFPlots"
    Cuidado `PGFPlots.jl` está sendo **deprecado** e **substituído** por `PGFPlotsX.jl`.
"""

# ╔═╡ 57217a63-f17e-4dc7-b3fd-d2628a74f1bd
md"""
## Atributos

Atributos são **maneiras de customizar os seus gráficos**.

São muitos eu nunca sei qual usar e eu sempre consulto a [documentação](http://docs.juliaplots.org/latest/attributes/) ou uso a função **`plotattr`** passando:

* **`:Plots`**: para atributos que se aplicam ao **plot todo**, e.g. `dpi`, `size`.


* **`:Series`**: para atributos que se aplicam à **séries**, e.g. `linecolor`, `markersize`.


* **`:Subplot`**: para atributos que se aplicam à **subplots**.


* **`:Axis`**: para atributos que se aplicam aos **eixos `x`, `y` e `z`**, e.g. `xticks`, `scales`.
"""

# ╔═╡ 59a00010-ec1d-4c75-8645-3b7cae615bf9
with_terminal() do
	plotattr(:Plot)
end

# ╔═╡ e379b2e7-724e-46e2-b7e7-995e181bf816
with_terminal() do
	plotattr(:Series)
end

# ╔═╡ a8b97406-54f0-4f5a-b3c9-fc465f6a6b38
with_terminal() do
	plotattr(:Subplot)
end

# ╔═╡ a0dabd50-5a90-4cc0-a20f-e4566a464123
with_terminal() do
	plotattr(:Axis)
end

# ╔═╡ 329b9f58-1889-4b4a-8a53-c564648a4d48
Plots.plot(
	rand(10, 4);
	lw=3,
	label=["1" "dois" "drei" "four"],
	legend=:outerbottomright,
	xticks=1:10,
	yticks=0.1:0.1:1.0,
	yformatter=(x -> string(x) * "cm"),
	xrotation=45,
	dpi=300
)

# ╔═╡ 5cf609a9-320c-44a7-995a-096c16862e4f
md"""
## Cores e Palhetas
"""

# ╔═╡ 2d6a655e-6f2b-4521-b5de-7aa7dcc06d63
md"""
!!! tip "💡 Fundamentals of Data Visualization"
    Um livro que eu recomendo muito (em especial quando falando de cores e palhetas de cores é o livro [Fundamentals of Data Visualization do Claus Wilke](https://clauswilke.com/dataviz). Em especial veja o capítulo 4 e 19.

$(Resource("https://clauswilke.com/dataviz/cover.png", :width => 300, :align => "center"))
"""

# ╔═╡ d5cfb8bc-bf52-4f2b-9f5b-c1ca35586e0e
md"""
Tem [várias maneiras de incorporar ou editar cores](http://docs.juliaplots.org/latest/generated/colorschemes/), mas eu geralmente uso o **argumento `palette`**:
"""

# ╔═╡ a3267a72-8322-474e-af11-e3cfd3b9727e
Plots.plot(
	rand(10, 4);
	lw=3,
	palette=:default
)

# ╔═╡ 2ab30ceb-31a3-4b90-a6df-816e1c2e60ef
md"""
### Palhetas Interessantes

* **qualitativa**: coisas discretas. Eu gosto muito das palhetas do [ColorBrewer](https://colorbrewer2.org/). Em especial o `:Set1`: `:Set1_3` até `:Set1_9`.


* **sequencial**: coisas contínuas. `:blues`, `:reds`, `:greens` e `:heat`


* **divergente**: coisas contínuas. `:cividis` (excelente para acessibilidade), `:inferno`, `:magma` e `:viridis`. (todos do `matplotlib`)
"""

# ╔═╡ e57518d7-6a3e-4756-89be-86694ac1a1f0
Plots.plot(
	rand(10, 4);
	lw=3,
	palette=:Set1_4
)

# ╔═╡ 96c2e80b-60af-41c6-a2f3-1e03a0e17735
function f(x, y)
    r = sqrt(x^2 + y^2)
    return cos(r) / (1 + r)
end

# ╔═╡ 7ae76e18-5afb-423f-9578-8a11a9e32438
x_pallete = range(0, 2π, length = 30)

# ╔═╡ 56ef1845-1a41-4b4e-8b18-1732f11b864a
Plots.heatmap(x_pallete, x_pallete, f;
	c=:inferno
)

# ╔═╡ 046c5fee-c1bb-4002-aa91-da98584b8358
Plots.heatmap(x_pallete, x_pallete, f;
	c=:cividis
)

# ╔═╡ 42c8f6a7-30d1-44e4-9bb7-4d301c6c9d2d
Plots.heatmap(x_pallete, x_pallete, f;
	c=:blues
)

# ╔═╡ fccf95bd-62be-4709-b569-d1bccd8e45ff
md"""
### Construção de Palhetas
"""

# ╔═╡ aa407b6a-6ee4-4d1b-be4b-1b8411abc1a8
md"""
!!! tip "💡 cgrad"
    Você pode converter qualquer palheta em **gradiente** (contínua) com a função **`grad`**. Até misturar as cores em um gradiente único.
"""

# ╔═╡ 8b562691-03f6-4d0b-9b5d-bb583a8896d9
Plots.cgrad([:orange, :blue])

# ╔═╡ 1a2222d8-9734-4de5-97ed-4d0288299bc7
Plots.cgrad(:thermal, rev = true)

# ╔═╡ da380258-0f0f-41ce-bb15-ae205ddb3056
Plots.cgrad(:Set1_9) # cuidado com coisas qualitativas, não fica muito bom...

# ╔═╡ 7fc6ca38-bf40-491d-80f0-c1052fec667e
md"""
### Cores do Logo de Julia

É claro que não faltou nossa queridinha. 

Está no pacote [`Colors.jl`](https://github.com/JuliaGraphics/Colors.jl):

```julia
using Colors
```
"""

# ╔═╡ b1867d6b-b425-46b0-be95-3e58c7dad4aa
logocolors = Colors.JULIA_LOGO_COLORS

# ╔═╡ d22e1a79-aa3f-4101-a02f-379104d21e21
Plots.scatter(
	[1, 1.5, 2], [1, 2.5, 1];
	ms=60,
	c=[logocolors.red, logocolors.green, logocolors.purple],
	xlims=(0, 3), ylims=(0, 3.5),
	xaxis=false, yaxis=false,
	yticks=false, xticks=false,
	grid=false,
	title="Ta Dáaaaa",
	label=false
)

# ╔═╡ f83aa994-3d5d-4f6a-b88f-f68989693760
md"""
## Layout

É possível controlar o **layout e o posicionamento dos subgráficos _subplots_**.

Para layouts simples é só passar um `Integer` no argumento `layout`:
"""

# ╔═╡ ef3da092-0e34-4d20-b098-3f3197cec0f1
Plots.plot(
	rand(100, 4);
	layout=4
)

# ╔═╡ 516ae969-dbc6-4180-98fa-4f01b96548c7
begin
	x = 1:10; y = rand(10, 4);
	
	p_1 = Plots.plot(x, y)
	p_2 = Plots.scatter(x, y)
	p_3 = Plots.plot(x, y; xlabel="Esse aqui tem label", lw=3, title="Subtítulo")
	p_4 = Plots.histogram(x, y; alpha=0.5)
	
	Plots.plot(p_1, p_2, p_3, p_4; layout=4, legend=false)
end

# ╔═╡ 818dc824-84cb-4cdb-883e-5e4692232fb1
md"""
Para layouts simples um pouco mais customizados em *grid*, passe uma `Tuple` de `Integer` especificando o tamanho o grid:
"""

# ╔═╡ 66922260-8411-4868-ad50-3e399477a1ac
Plots.plot(
	rand(100, 4);
	layout=(4, 1)  # 4x1 Grid
)

# ╔═╡ ef7f506e-dd0c-4708-90a5-5768477475ea
md"""
Para layouts complexos, voce pode customizar com o construtor `grid(...)`:
"""

# ╔═╡ 5adf46ff-b94d-4d8a-9264-585b6e2425d0
Plots.plot(
	rand(100, 4);
	layout=grid(4, 1, heights=[0.1 ,0.4, 0.4, 0.1])
)

# ╔═╡ dd4ee3ad-5da2-4e4a-883a-87dde75ea06c
md"""
Você consegue adicionar títulos e rótulos facilmente com `title` e `label`:
"""

# ╔═╡ 00fdd825-b00e-4205-85ca-fb9a434ccc8f
Plots.plot(
	rand(100, 4);
	layout=4,
	title=["1" "2" "3" "4"],
	label=["a" "b" "c" "d"]
)

# ╔═╡ 12ba0fd1-47b4-4dd8-ade2-a4da178f101d
md"""
### Layouts Avançados com `@layout`

O macro `@layout` é a maneira mais fácil de definir layouts complexos, usando a construção de `Array` multidimensional de Julia como base para uma sintaxe de layout personalizado.

O dimensionamento preciso pode ser obtido com colchetes `{}`, caso contrário, o espaço livre é dividido **igualmente** entre as áreas de plotagem em subplotagens.

Exemplo:
"""

# ╔═╡ 32f7c8d4-b8a8-48ca-9afb-e10aa8e93775
l = @layout [
    a{0.3w} [grid(3,3)   # 1 linha
             b{0.2h}  ]  # 2 colunas
]

# ╔═╡ 13e090db-9913-438e-ae7c-45b484845b7a
Plots.plot(
    rand(10, 11);
    layout=l,
	legend=false,
	seriestype=[:bar :scatter :line],
    title=["($i)" for j in 1:1, i in 1:11],
	titleloc=:right,
	titlefont=font(8),
	tickfont=font(6)
)

# ╔═╡ 2b1c1ff7-6b8b-47dd-aa1f-bdbc039180fb
md"""
## Temas
"""

# ╔═╡ 2ec69707-58df-4ac4-8277-8c51defab57e
md"""
!!! tip "💡 Temas"
    Temos vários temas com o [`PlotThemes.jl`](http://docs.juliaplots.org/latest/generated/plotthemes/).

	Eu tenho uma quedinha por temas dark.
"""

# ╔═╡ 3f92bf5f-8b45-471c-b53c-cad06f490afe
Plots.showtheme(:dark)

# ╔═╡ 2daed1c2-1c82-4651-9c45-827f188efceb
md"""
!!! info "💁 Animações"
    É possível fazer animações muito fácil em Julia com `Plots.jl`. Mas não vou cobrir aqui. Veja a [documentação](http://docs.juliaplots.org/latest/animations/).
"""

# ╔═╡ dc9b9dae-5cbf-4de7-ae5f-5e9d905ce361
md"""
!!! info "💁 PlotsGallery.jl"
    Não deixe de ver os gráficos da [`PlotsGallery.jl`](https://goropikari.github.io/PlotsGallery.jl/)
"""

# ╔═╡ 61f56d4d-053e-4f37-b8a7-9434dd27ba4b
md"""
# [`LaTeXStrings.jl`](https://github.com/stevengj/LaTeXStrings.jl)

Um pacote simples que ajuda em passar strings com $\LaTeX$ para a linguagem Julia.

```julia
using LaTeXStrings
```

Ele tem um construtor de `String` com o literal `L"..."`:
"""

# ╔═╡ 0d0d6f5c-523f-46b1-90d1-b7435a754a46
L"\alpha^2"

# ╔═╡ 304c23b4-eb12-4fa0-8fb3-7e26e7c70f30
begin
	fib = zeros(12);
	for i = 1:12
	    fib[i] = (((1+sqrt(5))/2)^i - ((1-sqrt(5))/2)^i)/sqrt(5);
	end
	
	Plots.plot(fib;
	    marker=:circle,
		label=false,
		grid=false,
		title="Fibbonaci",
	    xlabel=L"n", ylabel=L"F_n",
	    annotation=(6, 100, L"F_n = \frac{1}{\sqrt{5}} \left[\left( \frac{1+\sqrt{5}}{2} \right)^n - \left( \frac{1-\sqrt{5}}{2} \right)^n \right]"))
end

# ╔═╡ 0468bac2-5415-4416-bd92-899b1e9caa94
md"""
# [`StatsPlots.jl`](https://github.com/JuliaPlots/StatsPlots.jl)

A interface de `Plots.jl` com `DataFrames.jl`.

Possui suporte à **simbolos `:col1`** e também **`seriestype`s** específicos de **ciência de dados** e **estatística**.
"""

# ╔═╡ dfca1da3-acbd-48da-8489-2b9961e4bebf
md"""
!!! info "💁 Distributions.jl e StatsPlots.jl"
    Além disso, `StatsPlots.jl` também é usado para gerar gráficos de tipos `Distribution`s do pacote `Distributions.jl` mas eu não vou cobri aqui.
"""

# ╔═╡ 9b2e62a0-660b-4193-97dc-0e815a7380f5
md"""
!!! tip "💡 Atributos de StatsPlots.jl"
    Note que `StatsPlots.jl` dá suporte à todos os atributos de `Plots.jl`.
"""

# ╔═╡ afff32c5-15cf-49ce-828f-1cc8142ad86f
md"""
## `@df`

O **macro `@df`** permite com que qualquer `seriestype` de `StatsPlots.jl` e `Plots.jl` possa ter como **input de dados** um **`Symbol`**, e.g. `:col1`, de um **`DataFrame`**.

```julia
@df d x
```

Ele converte qualquer símbolo na expressão `x` com a respective coluna de `d` se ela existir.
"""

# ╔═╡ 7f9e7230-e587-4507-be47-7a40877d1318
df = DataFrame(
	x=1:10,
	y=[i^2 for i ∈ 1:10]
)

# ╔═╡ 76690388-c600-449f-b5cd-d4caf0693e2b
@df df Plots.plot(:x, :y)

# ╔═╡ 8452c91f-43a4-4122-bd6b-7b695aba7912
md"""
## `seriestype`

Além disso `StatsPlots.jl` tem **novos `seriestype`s**:

- `histogram`, `histogram2d` e `ea_histogram`
- `groupedhist` e `groupedbar`
- `boxplot`
- `dotplot`
- `violin`
- `marginalhist`, `marginalkde` e `marginalscatter`
- `corrplot` e `cornerplot`
"""

# ╔═╡ 8a2c8c45-0a52-4aca-a507-8ac200850993
md"""
### Histogramas e Densidades
"""

# ╔═╡ 13055c7f-3b93-48da-9c6f-29ebce464457
@df penguins StatsPlots.density(
	:body_mass_g;
	group=:species,
	lw=3
)

# ╔═╡ 18720936-1e25-4250-abfd-12cc102b48ca
@df penguins StatsPlots.density(
	:body_mass_g;
	group=(:species, :island),
	lw=3
)

# ╔═╡ 7a5335e9-b1e1-4180-9087-0c383db345ef
md"""
### Histogramas Marginais etc.
"""

# ╔═╡ 351068e8-54c4-4ce9-bba8-1cfdabd13f4d
@df penguins StatsPlots.marginalhist(
	:bill_length_mm, :bill_depth_mm
)

# ╔═╡ d6498efd-8bc8-42fc-bed2-ed2420681a98
@df penguins StatsPlots.marginalkde(
	:bill_length_mm, :bill_depth_mm
)

# ╔═╡ 4ed7ff92-c17b-4d93-bca7-7b84b126fb23
@df penguins StatsPlots.corrplot(
	cols([:bill_length_mm, :bill_depth_mm, :body_mass_g, :flipper_length_mm]);
	size=(800,600)
)

# ╔═╡ 3aa2401c-27ea-4f34-b99c-2adfa47cd703
@df penguins StatsPlots.corrplot(
	cols([:bill_length_mm, :bill_depth_mm, :body_mass_g, :flipper_length_mm]);
	group=:island,
	size=(800,600)
)

# ╔═╡ ea2fd5c6-d5c0-4369-9514-76e7a2017767
@df penguins StatsPlots.cornerplot(
	cols([:bill_length_mm, :bill_depth_mm, :body_mass_g, :flipper_length_mm]);
	size=(800,600)
)

# ╔═╡ 5fa48e2b-cf94-40ca-8b42-6e08e8f99c1e
md"""
### Boxplot, Dotplot e Violin
"""

# ╔═╡ 71c747e8-79d4-4a87-b13c-4799d84ab864
begin
	@df penguins StatsPlots.violin(
		:species, :body_mass_g;
		linewidth=0, legend=false)
	
	@df penguins StatsPlots.boxplot!(
		:species, :body_mass_g;
		fillalpha=0.75, linewidth=2)
	
	@df penguins StatsPlots.dotplot!(
		:species, :body_mass_g;
		marker=(:black, stroke(0)))
end

# ╔═╡ 006be106-fb0f-4955-a4b4-9e27f0b7b50c
md"""
### Gráficos de Barras e Histogramas Agrupados
"""

# ╔═╡ e3524563-6a48-4a22-9316-9b4c60ec755a
@df combine(
	groupby(penguins, :species),
	:body_mass_g => mean;
	renamecols=false) StatsPlots.groupedbar(
	:body_mass_g;
	group=:species
)

# ╔═╡ 39c75ff3-3661-4cb2-82f6-8aec128da417
@df combine(
	groupby(penguins, :species),
	:body_mass_g => mean;
	renamecols=false) StatsPlots.groupedbar(
	:body_mass_g;
	group=:species,
	bar_position=:stack,
	legend=:outerbottomright,
	yformatter=(x -> string(Int(x / 1_000)) * "K"),
	palette=:Set1_3
)

# ╔═╡ 11c69906-66e0-4dfa-bb75-e8e93faf71d7
md"""
!!! danger "⚠️ Verboso"
    Notem esse `groupedbar` acima como é verboso. Vamos rever isso em `AlgebraOfGraphics.jl`.
"""

# ╔═╡ 46bcee65-c7d4-4052-860e-f62f6fb37223
@df penguins StatsPlots.groupedhist(
	:body_mass_g;
	group=:species,
)

# ╔═╡ 6c8757bf-35e8-40d6-a508-949acb7b1b6a
@df penguins StatsPlots.groupedhist(
	:body_mass_g;
	group=:species,
	bar_position=:stack,
	xformatter=(x -> string(Int(x / 1_000)) * " kg"),
	palette=:Set1_3
)

# ╔═╡ 04ec3000-42c0-497f-bf4f-83214ebe1850
names(penguins)

# ╔═╡ 5841530d-e62b-4c14-ba53-b5fc223d4d7b
collect(1_000:1_000:7_000)

# ╔═╡ f4a96990-a738-42e9-8f44-c20ea86d4734
md"""
# [`AlgebraOfGraphics.jl`](https://github.com/JuliaPlots/AlgebraOfGraphics.jl)

$(Resource("https://github.com/JuliaPlots/AlgebraOfGraphics.jl/blob/master/docs/src/assets/logo.svg?raw=true", :width => 300))

Esse é meu **pacote favorito** de visualização 😍.

Ele possui como **_backend_ [`Makie.jl`](https://github.com/JuliaPlots/Makie.jl)** que é muito mais **poderoso** que `Plots.jl` e ainda possui uma **DSL** (_**D**omain **S**pecific **L**anguage_) muito **simples** e **poderosa** baseada em [Grammar of Graphics](https://www.amazon.com/Grammar-Graphics-Statistics-Computing/dp/0387245448) (estilo `ggplot2`):

* **dados** (_data_)
* **camadas** (_layers_)
* **mapeamentos** (_mappings_)
* **transformações** (_transformations_)

Além disso você pode combinar tudo isso aí com:
* **`+`**: adição
* **`*`**: multiplicação
"""

# ╔═╡ c142f0e2-348b-4364-abfc-4feab9064975
md"""
!!! tip "💡 AlgebraOfGraphics.jl"
    Tudo o que você consegue fazer com `AlgebraOfGraphics.jl` você consegue fazer com [`Makie.jl`](https://github.com/JuliaPlots/Makie.jl), so que de maneira muito mais cômoda e menos verbosa por conta da facilidade da sintaxe.
"""

# ╔═╡ 2a817b8a-0fa7-4a7b-9ece-fa95f8954e4f
md"""
## *Backends*

* [`Makie.jl`](https://github.com/JuliaPlots/Makie.jl) - Define todos os objetos. Teoricamente não é um *backend*.


* [`CairoMakie`](https://github.com/JuliaPlots/Makie.jl/tree/master/CairoMakie) - *backend* baseado em [Cairo](https://www.cairographics.org/) para gráficos vetoriais não-interativos (para publicação).


* [`GLMakie`](https://github.com/JuliaPlots/Makie.jl/tree/master/GLMakie) - *backend* de gráficos na GPU interativo.


* [`WGLMakie`](https://github.com/JuliaPlots/Makie.jl/tree/master/WGLMakie) - *backend* baseado em [WebGL](https://www.khronos.org/webgl/) de gráficos interativos que roda nos browsers.

Para usar `AlgebraOfGraphics.jl` importe-o com algum *backend*:

```julia
using AlgebraOfGraphics
using CairoMakie
```
"""

# ╔═╡ 430e4e03-2730-49d2-b68c-622774dc0d00
md"""
!!! info "💁 Makie.jl"
    Note que os *backends* de `AlgebraOfGraphics.jl` são do [`Makie.jl`](https://github.com/JuliaPlots/Makie.jl). Eu não vou cobrir `Makie.jl` nesse conteúdo. 

	Mas eu recomendo fortemente ler a [documentação de `Makie.jl`](http://makie.juliaplots.org/dev/).
"""

# ╔═╡ a7483a4b-07d1-42be-abdf-5718c0a48ea5
Resource("https://github.com/JuliaPlots/Makie.jl/blob/master/assets/makie_logo_canvas.svg?raw=true", :width => 300)

# ╔═╡ a3085cb1-e1d6-4f91-926c-6c58725a4917
md"""
## Dados com `data`

Primeiro você especifica os dados com `data`:
"""

# ╔═╡ 82bfc210-a024-44ac-8382-63ee3e87294a
data(penguins)

# ╔═╡ 570dcbbf-ac8a-41c0-a831-41e596da3aae
md"""
!!! info "💁 Tables.jl"
    `AlgebraOfGraphics.data` aceita qualquer interface de dados que dê suporte ao [formato `Tables.jl`](https://github.com/JuliaData/Tables.jl/blob/main/INTEGRATIONS.md).

	Isso quer dizer: `DataFrames.jl`, `Arrow.jl`, `JSON`, `MCMCChains.jl` e muitos outros...
"""

# ╔═╡ 50d7a8b0-0623-424e-8b67-d74b1dfbf5b4
md"""
## Mapeamentos com `mapping`

1. primeira posição é **`x`**
2. segunda posição é **`y`**
3. terceira posição é **`z`**
4. **`color`**
5. **`marker`** para tipo de marcador (círculo, triângulo etc)
6. **`dodge`** lado-a-lado
7. **`stack`** empilhado um em cima do outro 
8. **`group`**
9. **`col`** facetagem por coluna
10. **`row`** facetagem por linha
11. **`layout`** facetagem por automática
"""

# ╔═╡ 26e12d97-5be4-4f26-b257-bf1a61564042
md"""
!!! info "💁 AlgebraOfGraphics.draw"
    As funções **`AlgebraOfGraphics.draw`** e **`AlgebraOfGraphics.draw!`** pega suas camadas `Layers` e plota de acordo com o *backend*.
"""

# ╔═╡ 3a6accf0-f433-40fe-979c-cbf2c3111438
md"""
Por padrão é um diagrama de dispersão
"""

# ╔═╡ 9499c13c-8503-4cb4-ad90-787799b58c35
data(penguins) *
	mapping(
		:body_mass_g,       # x
		:flipper_length_mm  # y
) |> draw

# ╔═╡ 9385cda6-5de0-41ea-afd5-276ec2033536
data(penguins) *
	mapping(
		:body_mass_g,       # x
		:flipper_length_mm; # y
		color=:sex
) |> draw

# ╔═╡ 543c957f-b52f-4a5d-a842-2570719bdec1
data(penguins) *
	mapping(
		:body_mass_g,       # x
		:flipper_length_mm; # y
		color=:sex,
		marker=:species
) |> draw

# ╔═╡ b33cfa68-0b75-4f95-81f3-efb62603034d
data(penguins) *
	mapping(
		:body_mass_g,       # x
		:flipper_length_mm; # y
		color=:sex,
		marker=:species,
		layout=:island
) |> draw

# ╔═╡ e37ae35e-ee98-4cee-9869-b80a15e5c137
data(penguins) *
	mapping(
		:body_mass_g,       # x
		:flipper_length_mm; # y
		color=:sex,
		marker=:species,
		col=:island
) |> draw

# ╔═╡ 1932ae6a-7259-4dcb-ae24-3b83c197438a
md"""
### Operações em `mapping`

Também dá para executar operações dentro de mapping estilo `DataFrames.jl` com a [**semântica de `Pair`s**](https://bkamins.github.io/julialang/2020/12/24/minilanguage.html):

```julia
:col => transformação => :nova_col
```

Além disso tem as seguintes funções:

* **`renamer`**: renomeia uma variável categórica com um vetor de `Pair`s:
   
  ```julia
  renamer(["class 1" => "Class One", "class 2" => "Class Two"])
  ```

* **`sorter`**: reordena uma variável categórica com argumentos de `String`s:

  ```julia
  sorter("low", "medium", "high")
  ```

* **`nonnumeric`**: transforma uma variável numérica em categórica. Útil quando temos uma variável discreta rotulada com `Int`s.
"""

# ╔═╡ 207e64fd-d952-4559-a1bb-68e25aba60d6
data(penguins) *
	mapping(
		:body_mass_g => log => "massa corporal (log gramas)",
		:flipper_length_mm => (t -> t / 10) => "cumprimento da asa (cm)";
		color=:sex => renamer(["male" => "macho", "female" => "fêmea"]),
		marker=:species => sorter("Gentoo", "Adelie", "Chinstrap"),
		col=:year => nonnumeric
) |> draw

# ╔═╡ 1077ac49-9e26-49ff-9758-4d7e76743633
md"""
## Transformações Visuais

Todas do [`Makie.jl`](https://github.com/JuliaPlots/Makie.jl) e algumas extras:

1. [`Lines`](http://makie.juliaplots.org/dev/plotting_functions/lines.html)
2. [`Scatter`](http://makie.juliaplots.org/dev/plotting_functions/scatter.html)
3. [`BoxPlot`](http://makie.juliaplots.org/dev/makie_api.html#Makie.boxplot-Tuple)
4. [`BarPlot`](http://makie.juliaplots.org/dev/makie_api.html#Makie.barplot-Tuple)
5. [`Violin`](http://makie.juliaplots.org/dev/makie_api.html#Makie.violin-Tuple)
6. **`QQPlot`**
7. [`Heatmap`](http://makie.juliaplots.org/dev/plotting_functions/heatmap.html)
8. [`Wireframe`](http://makie.juliaplots.org/dev/makie_api.html#Makie.wireframe-Tuple)
9. [`Contour`](http://makie.juliaplots.org/dev/makie_api.html#Makie.contour-Tuple)
10. [`Arrows`](http://makie.juliaplots.org/dev/makie_api.html#Makie.arrows-Tuple)
11. [`Poly`](http://makie.juliaplots.org/dev/makie_api.html#Makie.poly-Tuple)
12. [`Band`](http://makie.juliaplots.org/dev/makie_api.html#Makie.band-Tuple)
13. [`Crossbar`](http://makie.juliaplots.org/dev/makie_api.html#Makie.crossbar-Tuple)
14. [`Density`](http://makie.juliaplots.org/dev/makie_api.html#Makie.density-Tuple)
15. [`Errorbars`](http://makie.juliaplots.org/dev/makie_api.html#Makie.errorbars!-Tuple)
16. [`Hist`](http://makie.juliaplots.org/dev/makie_api.html#Makie.hist-Tuple)
17. [`Mesh`](http://makie.juliaplots.org/dev/plotting_functions/mesh.html)
18. [`Surface`](http://makie.juliaplots.org/dev/plotting_functions/mesh.html)
19. [`Rangebars`](http://makie.juliaplots.org/dev/makie_api.html#Makie.rangebars-Tuple)
20. [`Pie`](http://makie.juliaplots.org/dev/makie_api.html#Makie.pie-Tuple)
21. [`Stem`](http://makie.juliaplots.org/dev/makie_api.html#Makie.stem-Tuple)
22. [`StreamPlot`](http://makie.juliaplots.org/dev/makie_api.html#Makie.streamplot-Tuple)

Especificamos com:

```julia
data(...) *
	mapping(...) *
	visual(SuaTransformaçãoVisual)
```
"""

# ╔═╡ 70c15c98-79b4-41d4-9b0f-2873bec855e2
# objeto Layer
mass_flipper = data(penguins) *
	mapping(:body_mass_g, :flipper_length_mm)

# ╔═╡ 0c5876db-764d-4ab4-b6c7-874592ac3157
# objeto Layers
scatter_lines = mass_flipper *
	(visual(Scatter) + visual(Lines))

# ╔═╡ 2a2a49a7-89ef-4db4-aee0-4c5955859b0b
draw(scatter_lines)

# ╔═╡ fded1e6e-2d18-4b65-be9e-9dd68ccfa2ae
data(penguins) *
	mapping(
		:species,
		:bill_depth_mm;
		color=:sex,
		side=:sex) *
	visual(Violin) |> draw

# ╔═╡ 4f6f0034-5dc4-40c0-acbd-b2b3743ad023
data(penguins) *
	mapping(
		:species,
		:bill_depth_mm;
		color=:sex,
		dodge=:sex) *
	visual(BoxPlot) |> draw

# ╔═╡ a52839f7-0fc3-416a-a5be-08816ceaeed0
md"""
## Transformações de Dados

1. [`histogram`](http://juliaplots.org/AlgebraOfGraphics.jl/dev/generated/datatransformations/#Histogram): computa um **histograma**.
2. [`density`](http://juliaplots.org/AlgebraOfGraphics.jl/dev/generated/datatransformations/#Density): computa uma **densidade**.
3. [`frequency`](http://juliaplots.org/AlgebraOfGraphics.jl/dev/generated/datatransformations/#Frequency): computa frequências (`nrow`).
4. [`expectation`](http://juliaplots.org/AlgebraOfGraphics.jl/dev/generated/datatransformations/#Expectation): computa uma **média por categoria**. Vem da esperança, termo matemático de probabilidade/estatística, do inglês *expectation*.
5. [`linear`](http://juliaplots.org/AlgebraOfGraphics.jl/dev/generated/datatransformations/#Linear): adiciona uma **linha (reta) de tendência**.
6. [`smoothing`](http://juliaplots.org/AlgebraOfGraphics.jl/dev/generated/datatransformations/#Smoothing): adiciona uma **curva de tendência**.

Especificamos com:

```julia
data(...) *
	mapping(...) *
	visual(...) *
	sua_transformação_de_dados()
```
"""

# ╔═╡ 2143fe13-c3f3-4a53-a92c-65e8d0263ce3
data(penguins) *
	mapping(:species) *
	frequency() |>draw

# ╔═╡ 341cc441-72be-4804-88b4-e6415b8da95c
data(penguins) *
	mapping(
		:species;
		color=:island,
		stack=:island) *
	frequency() |>draw

# ╔═╡ d1575065-a4bf-4cc3-82cf-7200b5a37498
data(penguins) *
	mapping(
		:species,
		:body_mass_g;
		color=:island,
		dodge=:island) *
	expectation() |>draw

# ╔═╡ 4acb99c5-8f9c-4568-8495-2522669b11ee
data(penguins) *
	mapping(
		:body_mass_g => float; # histogram não aceita `Int`s
		color=:species) *
	histogram() |> draw

# ╔═╡ 3b9f0db5-275f-47da-a7d8-528bcd9fc154
data(penguins) *
	mapping(
	:body_mass_g;
	color=:species) *
	density() |> draw

# ╔═╡ 3d75b6ac-4735-49fd-88ec-d6b0d8d85af0
data(penguins) *
	mapping(
	:body_mass_g,
	:flipper_length_mm;
	layout=:species) *
	visual(Contour) *
	density() |> draw

# ╔═╡ 41718826-5264-46e5-941a-a9db5d263751
data(penguins) *
	mapping(
		:bill_length_mm,
		:bill_depth_mm;
		col=:sex,
		color=:species) *
	(linear() +  # quero que o linear() replique para todos
				 # mapping herda o antigo mapping
		mapping()) |> draw

# ╔═╡ 720cd7de-a32a-436e-b4e3-f08af1c8b0e3
data(penguins) *
	mapping(
		:bill_length_mm,
		:bill_depth_mm;
		col=:sex,
		color=:species) *
	(smooth() +  # quero que o smooth() replique para todos
				 # mapping herda o antigo mapping
		mapping()) |> draw

# ╔═╡ 087e170a-7ae3-4f46-bda4-3b70e2732153
md"""
## Atributos de Transformações Visuais

Qualquer **atributo** de algum **`visual`** (e.g. `Scatter`, `BoxPlot`) podem ser listados com **`help_attributes`**:
"""

# ╔═╡ 0d97b638-e6a1-4d63-9c2d-52a7a8070d16
with_terminal() do
	help_attributes(boxplot)
end

# ╔═╡ 0f6fa18c-6797-4c84-b32e-7932b2f16b8c
md"""
!!! danger "⚠️ BoxPlot vs boxplot"
    Note que aqui estamos usando **`boxplot`** ao invés de **`BoxPlot`**.

	Isto é porque queremos acessar os atributos da **função** (snake_case) do *backend* (e.g. `CairoMakie` ao invés do **tipo** (CamelCase).
"""

# ╔═╡ 08882dce-6a3a-4a0d-8408-98ec2a122a8e
data(penguins) *
	mapping(
		:species,
		:bill_depth_mm;
		color=:sex,
		dodge=:sex) *
	visual(
		BoxPlot;
		markersize=15,
		show_notch=true,
		medianlinewidth=3,
		whiskerlinewidth=3,
		whiskerwidth=0.5
) |> draw

# ╔═╡ c20b59f9-3401-4c8f-9c95-a8f158b04384
md"""
Funciona também para **transformações de dados**:
"""

# ╔═╡ ec6015b9-decb-4750-948d-5e252fbae8fe
with_terminal() do
	help_attributes(lines)
end

# ╔═╡ 585d1b44-34cd-485b-bd1c-b9f8a0b183ea
data(penguins) *
	mapping(
		:bill_length_mm,
		:bill_depth_mm;
		col=:sex,
		color=:species) * 
	(linear() * visual(linewidth=3) +
		mapping()) |> draw

# ╔═╡ 7e21f990-8348-495a-9226-5a3bcc9ac373
md"""
## Argumentos `Figure` e `Axis`

**`draw`** e **`draw!`** também aceitam argumentos de `Figure` e `Axis` com os argumentos de *keyword* `figure` e `axis`.
"""

# ╔═╡ 0d0cc1a1-bce0-446a-ba20-cc278c06c04c
md"""
!!! danger "⚠️ NamedTuple"
    Note que `figure` e `axis` dentro de **`draw`** e **`draw!`** devem ser tuplas nomeadas `NamedTuple`.

	Então algo com uma única customização deve ser construido como:

	```julia
	figure=(atributo=valor,)  # tupla nomeada
	figure=(; atributo=valor) # tupla nomeada construção alternativa
	```
"""

# ╔═╡ d0344d4c-709e-4f82-8e47-f291d72bfa40
md"""
### Argumentos de `Figure`

Tem um [monte](http://makie.juliaplots.org/dev/figure.html), mas os mais importantes é **`resolution`**:
"""

# ╔═╡ 0bb9dc80-de08-41b3-98fb-6b1a6bc09b16
let
	fig = data(penguins) *
	mapping(
		:bill_length_mm,
		:bill_depth_mm;
		col=:sex,
		color=:species) * 
	(linear() * visual(linewidth=3) +
		mapping())
	draw(
		fig;
		figure=(;
			resolution=(800, 300),
			figure_padding=2,
			backgroundcolor=:pink,
			fontsize=12
			)
		)
end

# ╔═╡ cb8b4f7a-aad1-464b-9dfa-2d2d177ffff3
md"""
### Argumentos de `Axis`

També tem um [monte](http://makie.juliaplots.org/dev/makielayout/reference.html#Makie.MakieLayout.Axis), mas o mais importantes são:

* **`title`**: título do gráfico
* **`aspect`**: *aspect ratio*
* **`limits`**: limites do eixo-`x` e eixo-`y`
* **`xtickformat`** e **`ytickformat`**: formatação dós rótulos dos ticks do eixo `x` ou `y`. Note que a [documentação](http://makie.juliaplots.org/dev/makielayout/axis.html#Modifying-ticks) fala "_a function which takes a vector of numbers and outputs a vector of strings_". Então essa função precisa ser vetorizada (_broadcast_) com o `.`.
* **`xticklabelrotation`** e **`ticklabelrotation`**: rotação dos rótulos dos ticks eixo `x` ou `y` em radianos
"""

# ╔═╡ 8d60fd15-e0ed-4433-8fb7-92620ce1cfbd
let
	fig = data(penguins) *
	mapping(
		:bill_length_mm => "Cumprimento do Bico (cm)",
		:bill_depth_mm  => "Largura do Bico (cm)";
		col=:sex,
		color=:species) * 
	(linear() * visual(linewidth=3) +
		mapping())
	draw(
		fig;
		axis=(;
			title="Título",
			aspect=4/3,
			limits=(
				(30, 60), # eixo-x, pode ser `nothing` para somente eixo x
				(12, 23)  # eixo-y, pode ser `nothing` para somente eixo y
				),
			xtickformat=(x -> @. string(x / 10) * "\ncm"), # vetorizada com `@.`
			ytickformat=(x -> @. string(x / 10) * "cm"),   # vetorizada com `@.`
			yticklabelrotation=π/8
			)
		)
end

# ╔═╡ 743572d9-226c-40fe-bfbe-17d0631ccb87
md"""
## Cores de `AlgebraOfGraphics.jl`

Parafraseando a [documentação](http://juliaplots.org/AlgebraOfGraphics.jl/dev/philosophy/) sobre os padrões do `AlgebraOfGraphics.jl`:

> `AlgebraOfGraphics` visa fornecer configurações padrão sólidas e opinativas. Em particular, AoG usa uma [paleta conservadora e amigável para daltônicos](https://www.nature.com/articles/nmeth.1618?WT.ec_id=NMETH-201106) e um [mapa de cores perceptualmente uniforme e universalmente legível](https://www.nature.com/articles/s41467-020-19160-7). Ele segue as diretrizes da [IBM](https://www.ibm.com/design/language/typography/type-basics/#titles-and-subtitles) para diferenciar títulos e rótulos de rótulos de escala por meio do peso da fonte, enquanto usa o mesmo tipo de letra em um tamanho legível.

Caso você queira mudar as cores você pode de duas maneiras:

1. com um argumento **`colormap`** dentro de uma transformação visual **`visual`**:
"""

# ╔═╡ ce5d791e-64f0-449d-ba9d-2a33463386aa
data(penguins) *
	mapping(
	:body_mass_g,
	:flipper_length_mm;
	layout=:species) *
	visual(
		Contour,
		colormap=Reverse(:grays)
	) *
	density() |> draw

# ╔═╡ f8ca7907-9872-4f1d-8dac-0ca1f054ca62
md"""
2. dentro do argumento **`palettes`** de **`draw`** e **`draw!`** (OBS: `NamedTuple` e [`ColorSchemes.jl`](https://github.com/JuliaGraphics/ColorSchemes.jl)):
"""

# ╔═╡ 32ac588f-3aff-4942-884b-abe7ca3e46b9
let
	colors=[
		"Adelie" => ColorSchemes.Set1_3.colors[1],
		"Chistrap" => ColorSchemes.Set1_3.colors[2],
		"Gentoo" => ColorSchemes.Set1_3.colors[3]
		]
	fig = data(penguins) *
	mapping(
		:bill_length_mm,
		:bill_depth_mm;
		col=:sex,
		color=:species) * 
	(linear() * visual(linewidth=3) +
		mapping())
	draw(
		fig;
		palettes=(; color=ColorSchemes.Set1_3.colors)
		)
end

# ╔═╡ 6c5b8a1f-6524-458a-ad24-315bbd9b90e1
md"""
## Salvar gráficos de `AlgebraOfGraphics.jl`

Apenas use o `save`:

```julia
fg = draw(...)
save("figure.png", fg, px_per_unit = 3) # salva png alta resolução 300dpi
save("figure.svg", fg, pt_per_unit = 2) # salva svg alta resolução
```

### Formatos Suportados

- **`GLMakie`**: `.png`, `.jpeg`, e `.bmp`
- **`CairoMakie`**: `.svg`, `.pdf`, `.png`, e `.jpeg`
- **`WGLMakie`**: `.png`
"""

# ╔═╡ 87780a7b-dab0-4a1f-aaf4-b5c33a7bcb5f
md"""
## Temas de `AlgebraOfGraphics.jl`

`AlgebraOfGraphics.jl` tem o seu [próprio tema](http://juliaplots.org/AlgebraOfGraphics.jl/dev/philosophy/#Opinionated-defaults) e também dá suporte aos [temas pré-definidos de `Makie.jl`](http://makie.juliaplots.org/dev/predefined_themes.html).
"""

# ╔═╡ e36ce10e-5747-4ac8-933d-87082503738c
function demofigure()
    f = Figure()
    ax = Axis(f[1, 1],
        title = "measurements",
        xlabel = "time (s)",
        ylabel = "amplitude")

    labels = ["alpha", "beta", "gamma", "delta", "epsilon", "zeta"]
    for i in 1:6
        y = cumsum(randn(10)) .* (isodd(i) ? 1 : -1)
        lines!(y, label = labels[i])
        scatter!(y, label = labels[i])
    end

    Legend(f[1, 2], ax, "legend", merge = true)

    Axis3(f[1, 3],
        viewmode = :stretch,
        zlabeloffset = 40,
        title = "sinusoid")

    s = surface!(0:0.5:10, 0:0.5:10, (x, y) -> sqrt(x * y) + sin(1.5x))

    Colorbar(f[1, 4], s, label = "intensity")

    ax = Axis(f[2, 1:2],
        title = "different species",
        xlabel = "height (m)",
        ylabel = "density",)
    for i in 1:6
        y = randn(200) .+ 2i
        density!(y)
    end
    tightlimits!(ax, Bottom())
    xlims!(ax, -1, 15)

    Axis(f[2, 3:4],
        title = "stock performance",
        xticks = (1:6, labels),
        xlabel = "company",
        ylabel = "gain (\$)",
        xticklabelrotation = pi/6)
    for i in 1:6
        data = randn(1)
        barplot!([i], data)
        rangebars!([i], data .- 0.2, data .+ 0.2)
    end

    f
end;

# ╔═╡ dfc0d351-a589-4f25-a00c-973bdf03f158
md"""
### AlgebraOfGraphics
"""

# ╔═╡ 4c8cb50e-44b3-419c-a113-6eaaa4614bfd
let
	set_aog_theme!()
	demofigure()
end

# ╔═╡ d3f78785-cc9b-4028-be16-a2099ab419d3
md"""
### ggplot2
"""

# ╔═╡ 237f4595-fa70-498d-b548-9ce4b2d2da4b
with_theme(demofigure, theme_ggplot2())

# ╔═╡ 84abf831-6881-4116-af00-741889c33aae
md"""
### minimal
"""

# ╔═╡ bcac58ec-feca-46de-a291-d685907f52f0
with_theme(demofigure, theme_minimal())

# ╔═╡ 4a45ccba-c5b7-4bec-8ee1-aba72ffaf0ed
md"""
### black 😍
"""

# ╔═╡ 9ecc98d2-2b59-45dd-a383-9984cbcfed20
with_theme(demofigure, theme_black())

# ╔═╡ 8e6f6bec-b62a-485e-99f1-775e41c21c57
md"""
### light
"""

# ╔═╡ 7e4bcbcb-273e-4ef3-afc4-215dcd923ef8
with_theme(demofigure, theme_light())

# ╔═╡ 59548a54-beea-4d15-a49f-168bd2971965
md"""
### dark
"""

# ╔═╡ 4c4b0972-b6d4-4e7c-88cf-ff83c3162bd9
with_theme(demofigure, theme_dark())

# ╔═╡ e2927e8b-6268-46da-99b4-8f56da1241ea
md"""
# Galeria de Exemplos
"""

# ╔═╡ 7ef930ce-a8a7-4bf5-8e39-6a216d141ca4
md"""
!!! tip "💡 BeautifulMakie"
    Um dos coautores do livro [Julia Data Science](https://juliadatascience.io) é o [Lázaro Alonso](https://lazarusa.github.io/Webpage/index.html).

	Ele tem uma galeria de gráficos chamada [BeautifulMakie](https://lazarusa.github.io/BeautifulMakie/). As imagem abaixos são exemplos retirado de lá.
"""

# ╔═╡ ad112d99-2cd2-48de-8a85-2c7789600ef0
let
	ychi = filter(:species => x -> x == "Chinstrap", penguins)[!,:bill_depth_mm]
    yade = filter(:species => x -> x == "Adelie", penguins)[!,:bill_depth_mm]
    ygen = filter(:species => x -> x == "Gentoo", penguins)[!,:bill_depth_mm]
	penguin_bill = data(penguins) * mapping(:bill_length_mm  => "bill length mm",
        :bill_depth_mm  => "bill depth mm")

    layers = density() * visual(Contour) + linear() +
                visual(alpha = 0.5, markersize = 15)
    aesPoints = penguin_bill * layers * mapping(color = :species, marker = :species,)
    aesHist = data(penguins) * mapping(:bill_length_mm  => "bill length mm",
        color = :species, stack = :species) * histogram(;bins = 20)

    estilo = (color=["#FC7808", "#8C00EC", "#107A78"],
                marker=[:circle, :utriangle, :rect])
    # the actual plot with AoG and Makie
    fig = Figure(; resolution = (700, 700))
    axP = draw!(fig[2,1], aesPoints, palettes = estilo)
    axH = draw!(fig[1,1], aesHist, palettes = estilo)
    ax1 = Axis(axH[1,1])
    ax2 = Axis(axP[1,1])

    ax3 = Axis(fig[2,2],xgridstyle=:dash,ygridstyle=:dash,xtickalign=1, ytickalign=1)
    chin = density!(ax3, ychi, direction = :y, color =("#8C00EC", 0.25),
            strokewidth = 1, strokecolor = "#8C00EC")
    ade = density!(ax3, yade, direction = :y, color =("#FC7808", 0.25),
            strokewidth = 1, strokecolor = "#FC7808")
    gen = density!(ax3, ygen, direction = :y, color =("#107A78", 0.25),
            strokewidth = 1, strokecolor = "#107A78")
    leg = Legend(fig, [chin,ade,gen], ["Chinstrap", "Adelie", "Gentoo"],)
    fig[1,2] = leg
    limits!(ax2, 30, 60, 10, 25)
    CairoMakie.xlims!(ax1, 30,60)
    CairoMakie.ylims!(ax3, 10, 25)
    hidexdecorations!(ax1, ticks = false, grid = false)
    hideydecorations!(ax3, ticks = false, grid = false)
    hidespines!(ax3, :b,:r,:t)
    hidespines!(ax1, :l,:r,:t)
    colsize!(fig.layout, 1, Relative(3/4))
    rowsize!(fig.layout, 1, Relative(1/4))
    fig
end

# ╔═╡ 266b84f9-978b-47dd-9554-f3e7fabf2406
let
    ychi = filter(:species => x -> x == "Chinstrap", penguins)[!,:bill_depth_mm]
    yade = filter(:species => x -> x == "Adelie", penguins)[!,:bill_depth_mm]
    ygen = filter(:species => x -> x == "Gentoo", penguins)[!,:bill_depth_mm]

    penguin_bill = data(penguins) * mapping( :bill_length_mm  => "bill length mm",
        :bill_depth_mm  => "bill depth mm")

    layers = AlgebraOfGraphics.density() * visual(Contour) + linear() +
                visual(alpha = 0.5, markersize = 15)
    aesPoints = penguin_bill * layers * mapping(color = :species, marker = :species,)
    aesHist = data(penguins) * mapping(:bill_length_mm => "bill length mm",
        color = :species, stack = :species) * AlgebraOfGraphics.histogram(;bins = 20)

    estilo = (color=["#FC7808", "#8C00EC", "#107A78"],
                marker=[:circle, :utriangle, :rect])

    layer = AlgebraOfGraphics.density() * visual(Wireframe, linewidth=0.05)
    plt3d = penguin_bill * layer * mapping(color = :species)
    # the actual plot with AoG and Makie
    set_aog_theme!()
    fig = Figure(; resolution = (700, 700))
    aes3d = draw!(fig[2,1], plt3d; axis = (type = Axis3,), palettes = estilo)
    aesH = draw!(fig[1,1], aesHist, palettes = estilo)
    ax1 = Axis(aesH[1,1])
    ax2 = Axis(aes3d[1,1])

    ax3 = Axis(fig[2,2], ylabel = "bill depth mm")
    chin = density!(ax3, ychi, direction = :y, color =("#8C00EC", 0.25),
        strokewidth = 1, strokecolor = "#8C00EC")
    ade = density!(ax3, yade, direction = :y, color =("#FC7808", 0.25),
        strokewidth = 1, strokecolor = "#FC7808")
    gen = density!(ax3, ygen, direction = :y, color =("#107A78", 0.25),
        strokewidth = 1, strokecolor = "#107A78")
    leg = Legend(fig, [chin,ade,gen], ["Chinstrap", "Adelie", "Gentoo"],)
    fig[1,2] = leg
    colsize!(fig.layout, 1, Relative(3/4))
    rowsize!(fig.layout, 1, Relative(1/4))
    fig
end

# ╔═╡ ba45a8e0-ca7d-47eb-8782-1479a7dda6f2
md"""
## Séries Temporais
"""

# ╔═╡ a0d173fd-3307-422c-beb7-75f599c322a8
md"""
## Mapas
"""

# ╔═╡ fdf41c2b-8dfe-42eb-98bb-3b3a64f1cbdd
md"""
# Menções Honrosas

* [`GraphMakie.jl`](https://github.com/JuliaPlots/GraphMakie.jl): plotando grafos (aquele que de "redes" com vértices e arestas).
* [`WordCloud.jl`](https://github.com/guo-yong-zhi/WordCloud.jl): núvem de palavras.
"""

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

# ╔═╡ 33c80113-6505-41a6-95bd-e1f26847ed47
md"""
# Licença

Este conteúdo possui licença [Creative Commons Attribution-ShareAlike 4.0 Internacional](http://creativecommons.org/licenses/by-sa/4.0/).

[![CC BY-SA 4.0](https://licensebuttons.net/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
AlgebraOfGraphics = "cbdf2221-f076-402e-a563-3d30da359d67"
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
CategoricalArrays = "324d7699-5711-5eae-9e2f-1d82baa6b597"
ColorSchemes = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
Downloads = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
InteractiveUtils = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Shapefile = "8e980c4a-a4fe-5da2-b3a7-4b4b0353a2f4"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsPlots = "f3b207a7-027a-5e70-b257-86293d7955fd"
ZipFile = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"

[compat]
AlgebraOfGraphics = "~0.4.9"
CSV = "~0.8.5"
CairoMakie = "~0.6.3"
CategoricalArrays = "~0.10.0"
ColorSchemes = "~3.13.0"
Colors = "~0.12.8"
DataFrames = "~1.2.1"
HTTP = "~0.9.12"
LaTeXStrings = "~1.2.1"
Plots = "~1.19.4"
PlutoUI = "~0.7.9"
Shapefile = "~0.7.1"
StatsPlots = "~0.14.26"
ZipFile = "~0.9.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[AlgebraOfGraphics]]
deps = ["Colors", "DataAPI", "Dates", "FileIO", "GLM", "GeoInterface", "GeometryBasics", "GridLayoutBase", "KernelDensity", "Loess", "Makie", "PlotUtils", "PooledArrays", "RelocatableFolders", "StatsBase", "StructArrays", "Tables"]
git-tree-sha1 = "d8242f4f9160fbac4c5c6edac8d81227c5213263"
uuid = "cbdf2221-f076-402e-a563-3d30da359d67"
version = "0.4.9"

[[Animations]]
deps = ["Colors"]
git-tree-sha1 = "e81c509d2c8e49592413bfb0bb3b08150056c79d"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Arpack]]
deps = ["Arpack_jll", "Libdl", "LinearAlgebra"]
git-tree-sha1 = "2ff92b71ba1747c5fdd541f8fc87736d82f40ec9"
uuid = "7d9fca2a-8960-54d3-9f78-7d1dccf2cb97"
version = "0.4.0"

[[Arpack_jll]]
deps = ["Libdl", "OpenBLAS_jll", "Pkg"]
git-tree-sha1 = "e214a9b9bd1b4e1b4f15b22c0994862b66af7ff7"
uuid = "68821587-b530-5797-8361-c406ea357684"
version = "3.5.0+3"

[[ArrayInterface]]
deps = ["IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "655d9e28a75f88eea3fb81a12f62da9bade89fb5"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.19"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Automa]]
deps = ["Printf", "ScanByte", "TranscodingStreams"]
git-tree-sha1 = "d50976f217489ce799e366d9561d56a98a30d7fe"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "0.8.2"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "a4d07a1c313392a77042855df46c5f534076fab9"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.0"

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

[[Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "d0b3f8b4ad16cb0a2988c6788646a5e6a17b6b1b"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.0.5"

[[CairoMakie]]
deps = ["Base64", "Cairo", "Colors", "FFTW", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "SHA", "StaticArrays"]
git-tree-sha1 = "7d37b0bd71e7f3397004b925927dfa8dd263439c"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.6.3"

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
git-tree-sha1 = "f53ca8d41e4753c41cdafa6ec5f7ce914b34be54"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "0.10.13"

[[Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "75479b7df4167267d75294d14b58244695beb2ac"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.14.2"

[[ColorBrewer]]
deps = ["Colors", "JSON", "Test"]
git-tree-sha1 = "61c5334f33d91e570e1d0c3eb5465835242582c4"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.0"

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

[[ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "42a9b08d3f2f951c9b283ea427d96ed9f1f30343"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.5"

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

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DBFTables]]
deps = ["Printf", "Tables", "WeakRefStrings"]
git-tree-sha1 = "3887db9932c2f9f159d28bfbe34f25597048eb80"
uuid = "75c7ada1-017a-5fb6-b8c7-2125ff2d6c93"
version = "0.2.3"

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

[[DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "d88a19299eba280a6d062e135a43f00323ae70bf"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.13"

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

[[EllipsisNotation]]
deps = ["ArrayInterface"]
git-tree-sha1 = "8041575f021cba5a099a456b4163c9a08b566a02"
uuid = "da5c29d0-fa7d-589e-88eb-ea29b0a81949"
version = "1.1.0"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

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

[[FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "f985af3b9f4e278b1d24434cbb546d6092fca661"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.3"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3676abafff7e4ff07bbd2c42b3d8201f31653dcc"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.9+8"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "256d8e6188f3f1ebfa1a5d17e072a0efafa8c5bf"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.10.1"

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

[[FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "cabd77ab6a6fdff49bfd24af2ebe76e6e018a2b4"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.0.0"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "cbd58c9deb1d304f5a245a0b7eb841a2560cfec6"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.1+5"

[[FreeTypeAbstraction]]
deps = ["ColorVectorSpace", "Colors", "FreeType", "GeometryBasics", "StaticArrays"]
git-tree-sha1 = "d51e69f0a2f8a3842bca4183b700cf3d9acce626"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.9.1"

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

[[GLM]]
deps = ["Distributions", "LinearAlgebra", "Printf", "Reexport", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "StatsModels"]
git-tree-sha1 = "f564ce4af5e79bb88ff1f4488e64363487674278"
uuid = "38e38edf-8417-5370-95a0-9cbb8c7f171a"
version = "1.5.1"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "9f473cdf6e2eb360c576f9822e7c765dd9d26dbc"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.58.0"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "eaf96e05a880f3db5ded5a5a8a7817ecba3c7392"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.58.0+0"

[[GeoInterface]]
deps = ["RecipesBase"]
git-tree-sha1 = "38a649e6a52d1bea9844b382343630ac754c931c"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "0.5.5"

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

[[Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "2c1cf4df419938ece72de17f368a021ee162762e"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.0"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Match", "Observables"]
git-tree-sha1 = "d44945bdc7a462fa68bb847759294669352bd0a4"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.5.7"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "c6a1fff2fd4b1da29d3dccaffb1e1001244d844e"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.12"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "8a954fed8ac097d5be04921d595f741115c1b2ad"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+0"

[[IfElse]]
git-tree-sha1 = "28e837ff3e7a6c3cdb252ce49fb412c8eb3caeef"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.0"

[[ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "75f7fea2b3601b58f24ee83617b528e57160cbfd"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.1"

[[ImageIO]]
deps = ["FileIO", "Netpbm", "PNGFiles", "TiffImages", "UUIDs"]
git-tree-sha1 = "d067570b4d4870a942b19d9ceacaea4fb39b69a1"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.5.6"

[[IndirectArrays]]
git-tree-sha1 = "c2a145a145dc03a7620af1444e0264ef907bd44f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "0.5.1"

[[Inflate]]
git-tree-sha1 = "f5fc07d4e706b84f72d54eedcc1c13d92fb0871c"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.2"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "1470c80592cf1f0a35566ee5e93c5f8221ebc33a"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.3"

[[IntervalSets]]
deps = ["Dates", "EllipsisNotation", "Statistics"]
git-tree-sha1 = "3cc368af3f110a767ac786560045dceddfc16758"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.5.3"

[[InvertedIndices]]
deps = ["Test"]
git-tree-sha1 = "15732c475062348b0165684ffe28e85ea8396afc"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.0.0"

[[Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

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

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "591e8dc09ad18386189610acafb970032c519707"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.3"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

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

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

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

[[Loess]]
deps = ["Distances", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "b5254a86cf65944c68ed938e575f5c81d5dfe4cb"
uuid = "4345ca2d-374a-55d4-8d30-97f9976e7612"
version = "0.5.3"

[[LogExpFunctions]]
deps = ["DocStringExtensions", "LinearAlgebra"]
git-tree-sha1 = "7bd5f6565d80b6bf753738d2bc40a5dfea072070"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.2.5"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "c253236b0ed414624b083e6b72bfe891fbd2c7af"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+1"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "6a8a2a625ab0dea913aba95c11370589e0239ff0"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.6"

[[Makie]]
deps = ["Animations", "Artifacts", "Base64", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "Distributions", "DocStringExtensions", "FFMPEG", "FileIO", "FixedPointNumbers", "Formatting", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageIO", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MakieCore", "Markdown", "Match", "MathTeXEngine", "Observables", "Packing", "PlotUtils", "PolygonOps", "Printf", "Random", "Serialization", "Showoff", "SignedDistanceFields", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "UnicodeFun"]
git-tree-sha1 = "5761bfd21ad271efd7e134879e39a2289a032fc8"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.15.0"

[[MakieCore]]
deps = ["Observables"]
git-tree-sha1 = "7bcc8323fb37523a6a51ade2234eee27a11114c8"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.1.3"

[[MappedArrays]]
git-tree-sha1 = "18d3584eebc861e311a552cbb67723af8edff5de"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.0"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[Match]]
git-tree-sha1 = "5cf525d97caf86d29307150fcba763a64eaa9cbe"
uuid = "7eb4fadd-790c-5f42-8a69-bfa0b872bfbf"
version = "1.1.0"

[[MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "Test"]
git-tree-sha1 = "69b565c0ca7bf9dae18498b52431f854147ecbf3"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.1.2"

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

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "4ea90bd5d3985ae1f9a908bd4500ae88921c5ce7"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.0"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "b34e3bc3ca7c94914418637cb10cc4d1d80d877d"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.3"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[MultivariateStats]]
deps = ["Arpack", "LinearAlgebra", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "8d958ff1854b166003238fe191ec34b9d592860a"
uuid = "6f286f6a-111f-5878-ab1e-185364afe411"
version = "0.8.0"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "16baacfdc8758bc374882566c9187e785e85c2f0"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.9"

[[Netpbm]]
deps = ["FileIO", "ImageCore"]
git-tree-sha1 = "18efc06f6ec36a8b801b23f076e3c6ac7c3bf153"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.2"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "4f825c6da64aebaa22cc058ecfceed1ab9af1c7e"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.3"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

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

[[PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "520e28d4026d16dcf7b8c8140a3041f0e20a9ca8"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.7"

[[Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "f4049d379326c2c7aa875c702ad19346ecb2b004"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.4.1"

[[PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "0fa5e78929aebc3f6b56e1a88cf505bb00a354c4"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.8"

[[Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9a336dee51d20d1ed890c4a8dca636e86e2b76ca"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.42.4+10"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "94bf17e83a0e4b20c8d77f6af8ffe8cc3b386c0a"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.1"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "a7a7e1a88853564e551e4eba8650f8c38df79b37"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.1.1"

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
git-tree-sha1 = "1e72752052a3893d0f7103fbac728b60b934f5a5"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.19.4"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[PolygonOps]]
git-tree-sha1 = "c031d2332c9a8e1c90eca239385815dc271abb22"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.1"

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

[[Ratios]]
git-tree-sha1 = "37d210f612d70f3f7d57d488cb3b6eff56ad4e41"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.0"

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

[[RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "0529f4188bc8efee85a7e580aca1c7dff6b103f8"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.1.0"

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

[[SIMD]]
git-tree-sha1 = "9ba33637b24341aba594a2783a502760aa0bff04"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.3.1"

[[ScanByte]]
deps = ["Libdl", "SIMD"]
git-tree-sha1 = "9cc2955f2a254b18be655a4ee70bc4031b2b189e"
uuid = "7b38b023-a4d7-4c5e-8d43-3f3097f304eb"
version = "0.3.0"

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

[[Shapefile]]
deps = ["DBFTables", "GeoInterface", "RecipesBase", "Tables"]
git-tree-sha1 = "1f4070fed3e779b4f710583f8dacd87397cd13b1"
uuid = "8e980c4a-a4fe-5da2-b3a7-4b4b0353a2f4"
version = "0.7.1"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[ShiftedArrays]]
git-tree-sha1 = "22395afdcf37d6709a5a0766cc4a5ca52cb85ea0"
uuid = "1277b4bf-5013-50f5-be3d-901d8477a67a"
version = "1.0.0"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[SignedDistanceFields]]
deps = ["Random", "Statistics", "Test"]
git-tree-sha1 = "d263a08ec505853a5ff1c1ebde2070419e3f28e9"
uuid = "73760f76-fbc4-59ce-8f25-708e95d2df96"
version = "0.4.0"

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

[[StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "62701892d172a2fa41a1f829f66d2b0db94a9a63"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.3.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "885838778bb6f0136f8317757d7803e0d81201e4"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.9"

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

[[StatsModels]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Printf", "ShiftedArrays", "SparseArrays", "StatsBase", "StatsFuns", "Tables"]
git-tree-sha1 = "a209a68f72601f8aa0d3a7c4e50ba3f67e32e6f8"
uuid = "3eaba693-59b7-5ba5-a881-562e759f1c8d"
version = "0.6.24"

[[StatsPlots]]
deps = ["Clustering", "DataStructures", "DataValues", "Distributions", "Interpolations", "KernelDensity", "LinearAlgebra", "MultivariateStats", "Observables", "Plots", "RecipesBase", "RecipesPipeline", "Reexport", "StatsBase", "TableOperations", "Tables", "Widgets"]
git-tree-sha1 = "e7d1e79232310bd654c7cef46465c537562af4fe"
uuid = "f3b207a7-027a-5e70-b257-86293d7955fd"
version = "0.14.26"

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

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableOperations]]
deps = ["SentinelArrays", "Tables", "Test"]
git-tree-sha1 = "a7cf690d0ac3f5b53dd09b5d613540b230233647"
uuid = "ab02a1b2-a7df-11e8-156e-fb1833f50b87"
version = "1.0.0"

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

[[TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TiffImages]]
deps = ["ColorTypes", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "OffsetArrays", "OrderedCollections", "PkgVersion", "ProgressMeter"]
git-tree-sha1 = "03fb246ac6e6b7cb7abac3b3302447d55b43270e"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.4.1"

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

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

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

[[WeakRefStrings]]
deps = ["DataAPI", "Random", "Test"]
git-tree-sha1 = "28807f85197eaad3cbd2330386fac1dcb9e7e11d"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "0.6.2"

[[Widgets]]
deps = ["Colors", "Dates", "Observables", "OrderedCollections"]
git-tree-sha1 = "eae2fbbc34a79ffd57fb4c972b08ce50b8f6a00d"
uuid = "cc8bc4a8-27d6-5769-a93b-9d913e69aa62"
version = "0.6.3"

[[WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "59e2ad8fd1591ea019a5259bd012d7aee15f995c"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.3"

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

[[ZipFile]]
deps = ["Libdl", "Printf", "Zlib_jll"]
git-tree-sha1 = "c3a5637e27e914a7a445b8d0ad063d701931e9f7"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.9.3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[isoband_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "a1ac99674715995a536bbce674b068ec1b7d893d"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.2+0"

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
# ╟─a1044598-e24a-4399-983e-3a906e9fae51
# ╠═27f62732-c909-11eb-27ee-e373dce148d9
# ╟─71876e1a-dd30-44e4-943f-af4582b74f6d
# ╟─038653f4-7d94-4aed-92ef-c1258db95146
# ╟─c98b5ef9-8cce-448e-8a8d-1cd1e94fb5cd
# ╟─1d743482-02ae-4723-a35e-c23fcc79e2f5
# ╟─5718597f-051e-42e8-ba85-d5ef5898f0f3
# ╠═7ee550f4-39f8-4678-a101-eb506ea3ebc1
# ╠═d0f51a90-f6b0-402d-bfd7-891abc065a48
# ╠═ac54b4e0-33f5-426e-820e-3e9f002c2e91
# ╟─43c658ee-f378-450a-9d7c-97b603b56e62
# ╠═b447e5e9-6647-46cd-b793-bf2ec2025a12
# ╠═670086e1-fcb5-4fd6-9685-7dbbfc50080e
# ╟─0f79aeb6-b31f-4f9c-9e0c-2718fe650619
# ╟─b0953f8a-0393-4352-83d2-cd40c06d90a9
# ╠═8df33c6f-654d-4fe9-882f-cc7a17044ac4
# ╠═3adba103-7866-46e2-b26f-12476d9147cc
# ╟─399f99e1-e4f7-4c9b-ba0c-c120cab5e4e9
# ╠═a85cd5f2-cc1d-42e2-993a-7914a539c81e
# ╟─71895560-48fc-4005-8898-b27d140ea468
# ╠═368290eb-3968-4a9e-9d52-8790cf1b46a4
# ╟─288748f6-5245-4aae-a6ac-920158f1d9f6
# ╟─03ace772-d78e-4cc4-8e16-b650f16f7e9d
# ╠═21f2fd59-f74d-4fd4-a645-24066643d4cc
# ╟─36783771-3729-4fd3-893d-2ca7cab1777f
# ╠═0378f4c1-1d4b-4255-a545-22e44d73426e
# ╟─f5c64355-fae0-4dcd-846a-bc51221cde35
# ╟─069fc1e2-d273-41f2-bae0-c9610b5b46fa
# ╟─e3444c25-5e2d-4525-abe3-0b24a6b4f56d
# ╟─57217a63-f17e-4dc7-b3fd-d2628a74f1bd
# ╠═59a00010-ec1d-4c75-8645-3b7cae615bf9
# ╠═e379b2e7-724e-46e2-b7e7-995e181bf816
# ╠═a8b97406-54f0-4f5a-b3c9-fc465f6a6b38
# ╠═a0dabd50-5a90-4cc0-a20f-e4566a464123
# ╠═329b9f58-1889-4b4a-8a53-c564648a4d48
# ╟─5cf609a9-320c-44a7-995a-096c16862e4f
# ╟─2d6a655e-6f2b-4521-b5de-7aa7dcc06d63
# ╟─d5cfb8bc-bf52-4f2b-9f5b-c1ca35586e0e
# ╠═a3267a72-8322-474e-af11-e3cfd3b9727e
# ╟─2ab30ceb-31a3-4b90-a6df-816e1c2e60ef
# ╠═e57518d7-6a3e-4756-89be-86694ac1a1f0
# ╠═96c2e80b-60af-41c6-a2f3-1e03a0e17735
# ╠═7ae76e18-5afb-423f-9578-8a11a9e32438
# ╠═56ef1845-1a41-4b4e-8b18-1732f11b864a
# ╠═046c5fee-c1bb-4002-aa91-da98584b8358
# ╠═42c8f6a7-30d1-44e4-9bb7-4d301c6c9d2d
# ╟─fccf95bd-62be-4709-b569-d1bccd8e45ff
# ╟─aa407b6a-6ee4-4d1b-be4b-1b8411abc1a8
# ╠═8b562691-03f6-4d0b-9b5d-bb583a8896d9
# ╠═1a2222d8-9734-4de5-97ed-4d0288299bc7
# ╠═da380258-0f0f-41ce-bb15-ae205ddb3056
# ╟─7fc6ca38-bf40-491d-80f0-c1052fec667e
# ╠═b1867d6b-b425-46b0-be95-3e58c7dad4aa
# ╠═d22e1a79-aa3f-4101-a02f-379104d21e21
# ╟─f83aa994-3d5d-4f6a-b88f-f68989693760
# ╠═ef3da092-0e34-4d20-b098-3f3197cec0f1
# ╠═516ae969-dbc6-4180-98fa-4f01b96548c7
# ╟─818dc824-84cb-4cdb-883e-5e4692232fb1
# ╠═66922260-8411-4868-ad50-3e399477a1ac
# ╟─ef7f506e-dd0c-4708-90a5-5768477475ea
# ╠═5adf46ff-b94d-4d8a-9264-585b6e2425d0
# ╟─dd4ee3ad-5da2-4e4a-883a-87dde75ea06c
# ╠═00fdd825-b00e-4205-85ca-fb9a434ccc8f
# ╟─12ba0fd1-47b4-4dd8-ade2-a4da178f101d
# ╠═32f7c8d4-b8a8-48ca-9afb-e10aa8e93775
# ╠═13e090db-9913-438e-ae7c-45b484845b7a
# ╟─2b1c1ff7-6b8b-47dd-aa1f-bdbc039180fb
# ╟─2ec69707-58df-4ac4-8277-8c51defab57e
# ╠═3f92bf5f-8b45-471c-b53c-cad06f490afe
# ╟─2daed1c2-1c82-4651-9c45-827f188efceb
# ╟─dc9b9dae-5cbf-4de7-ae5f-5e9d905ce361
# ╟─61f56d4d-053e-4f37-b8a7-9434dd27ba4b
# ╠═0d0d6f5c-523f-46b1-90d1-b7435a754a46
# ╠═304c23b4-eb12-4fa0-8fb3-7e26e7c70f30
# ╟─0468bac2-5415-4416-bd92-899b1e9caa94
# ╟─dfca1da3-acbd-48da-8489-2b9961e4bebf
# ╟─9b2e62a0-660b-4193-97dc-0e815a7380f5
# ╟─afff32c5-15cf-49ce-828f-1cc8142ad86f
# ╠═7f9e7230-e587-4507-be47-7a40877d1318
# ╠═76690388-c600-449f-b5cd-d4caf0693e2b
# ╟─8452c91f-43a4-4122-bd6b-7b695aba7912
# ╟─8a2c8c45-0a52-4aca-a507-8ac200850993
# ╠═13055c7f-3b93-48da-9c6f-29ebce464457
# ╠═18720936-1e25-4250-abfd-12cc102b48ca
# ╟─7a5335e9-b1e1-4180-9087-0c383db345ef
# ╠═351068e8-54c4-4ce9-bba8-1cfdabd13f4d
# ╠═d6498efd-8bc8-42fc-bed2-ed2420681a98
# ╠═4ed7ff92-c17b-4d93-bca7-7b84b126fb23
# ╠═3aa2401c-27ea-4f34-b99c-2adfa47cd703
# ╠═ea2fd5c6-d5c0-4369-9514-76e7a2017767
# ╟─5fa48e2b-cf94-40ca-8b42-6e08e8f99c1e
# ╠═71c747e8-79d4-4a87-b13c-4799d84ab864
# ╟─006be106-fb0f-4955-a4b4-9e27f0b7b50c
# ╠═e3524563-6a48-4a22-9316-9b4c60ec755a
# ╠═39c75ff3-3661-4cb2-82f6-8aec128da417
# ╟─11c69906-66e0-4dfa-bb75-e8e93faf71d7
# ╠═46bcee65-c7d4-4052-860e-f62f6fb37223
# ╠═6c8757bf-35e8-40d6-a508-949acb7b1b6a
# ╠═04ec3000-42c0-497f-bf4f-83214ebe1850
# ╠═5841530d-e62b-4c14-ba53-b5fc223d4d7b
# ╟─f4a96990-a738-42e9-8f44-c20ea86d4734
# ╟─c142f0e2-348b-4364-abfc-4feab9064975
# ╟─2a817b8a-0fa7-4a7b-9ece-fa95f8954e4f
# ╟─430e4e03-2730-49d2-b68c-622774dc0d00
# ╟─a7483a4b-07d1-42be-abdf-5718c0a48ea5
# ╟─a3085cb1-e1d6-4f91-926c-6c58725a4917
# ╠═82bfc210-a024-44ac-8382-63ee3e87294a
# ╟─570dcbbf-ac8a-41c0-a831-41e596da3aae
# ╟─50d7a8b0-0623-424e-8b67-d74b1dfbf5b4
# ╟─26e12d97-5be4-4f26-b257-bf1a61564042
# ╟─3a6accf0-f433-40fe-979c-cbf2c3111438
# ╠═9499c13c-8503-4cb4-ad90-787799b58c35
# ╠═9385cda6-5de0-41ea-afd5-276ec2033536
# ╠═543c957f-b52f-4a5d-a842-2570719bdec1
# ╠═b33cfa68-0b75-4f95-81f3-efb62603034d
# ╠═e37ae35e-ee98-4cee-9869-b80a15e5c137
# ╟─1932ae6a-7259-4dcb-ae24-3b83c197438a
# ╠═207e64fd-d952-4559-a1bb-68e25aba60d6
# ╟─1077ac49-9e26-49ff-9758-4d7e76743633
# ╠═70c15c98-79b4-41d4-9b0f-2873bec855e2
# ╠═0c5876db-764d-4ab4-b6c7-874592ac3157
# ╠═2a2a49a7-89ef-4db4-aee0-4c5955859b0b
# ╠═fded1e6e-2d18-4b65-be9e-9dd68ccfa2ae
# ╠═4f6f0034-5dc4-40c0-acbd-b2b3743ad023
# ╟─a52839f7-0fc3-416a-a5be-08816ceaeed0
# ╠═2143fe13-c3f3-4a53-a92c-65e8d0263ce3
# ╠═341cc441-72be-4804-88b4-e6415b8da95c
# ╠═d1575065-a4bf-4cc3-82cf-7200b5a37498
# ╠═4acb99c5-8f9c-4568-8495-2522669b11ee
# ╠═3b9f0db5-275f-47da-a7d8-528bcd9fc154
# ╠═3d75b6ac-4735-49fd-88ec-d6b0d8d85af0
# ╠═41718826-5264-46e5-941a-a9db5d263751
# ╠═720cd7de-a32a-436e-b4e3-f08af1c8b0e3
# ╟─087e170a-7ae3-4f46-bda4-3b70e2732153
# ╠═0d97b638-e6a1-4d63-9c2d-52a7a8070d16
# ╟─0f6fa18c-6797-4c84-b32e-7932b2f16b8c
# ╠═08882dce-6a3a-4a0d-8408-98ec2a122a8e
# ╟─c20b59f9-3401-4c8f-9c95-a8f158b04384
# ╠═ec6015b9-decb-4750-948d-5e252fbae8fe
# ╠═585d1b44-34cd-485b-bd1c-b9f8a0b183ea
# ╟─7e21f990-8348-495a-9226-5a3bcc9ac373
# ╟─0d0cc1a1-bce0-446a-ba20-cc278c06c04c
# ╟─d0344d4c-709e-4f82-8e47-f291d72bfa40
# ╠═0bb9dc80-de08-41b3-98fb-6b1a6bc09b16
# ╟─cb8b4f7a-aad1-464b-9dfa-2d2d177ffff3
# ╠═8d60fd15-e0ed-4433-8fb7-92620ce1cfbd
# ╟─743572d9-226c-40fe-bfbe-17d0631ccb87
# ╠═ce5d791e-64f0-449d-ba9d-2a33463386aa
# ╟─f8ca7907-9872-4f1d-8dac-0ca1f054ca62
# ╠═32ac588f-3aff-4942-884b-abe7ca3e46b9
# ╟─6c5b8a1f-6524-458a-ad24-315bbd9b90e1
# ╟─87780a7b-dab0-4a1f-aaf4-b5c33a7bcb5f
# ╟─e36ce10e-5747-4ac8-933d-87082503738c
# ╟─dfc0d351-a589-4f25-a00c-973bdf03f158
# ╠═4c8cb50e-44b3-419c-a113-6eaaa4614bfd
# ╟─d3f78785-cc9b-4028-be16-a2099ab419d3
# ╠═237f4595-fa70-498d-b548-9ce4b2d2da4b
# ╟─84abf831-6881-4116-af00-741889c33aae
# ╠═bcac58ec-feca-46de-a291-d685907f52f0
# ╟─4a45ccba-c5b7-4bec-8ee1-aba72ffaf0ed
# ╠═9ecc98d2-2b59-45dd-a383-9984cbcfed20
# ╟─8e6f6bec-b62a-485e-99f1-775e41c21c57
# ╠═7e4bcbcb-273e-4ef3-afc4-215dcd923ef8
# ╟─59548a54-beea-4d15-a49f-168bd2971965
# ╠═4c4b0972-b6d4-4e7c-88cf-ff83c3162bd9
# ╟─e2927e8b-6268-46da-99b4-8f56da1241ea
# ╟─7ef930ce-a8a7-4bf5-8e39-6a216d141ca4
# ╠═ad112d99-2cd2-48de-8a85-2c7789600ef0
# ╠═266b84f9-978b-47dd-9554-f3e7fabf2406
# ╟─ba45a8e0-ca7d-47eb-8782-1479a7dda6f2
# ╠═ed513f16-1ff5-4ad8-a2cb-4294f15a0ff2
# ╟─a0d173fd-3307-422c-beb7-75f599c322a8
# ╠═fee7043e-efdb-45d0-8e2f-9554eb525a12
# ╟─fdf41c2b-8dfe-42eb-98bb-3b3a64f1cbdd
# ╟─d548bc1a-2e20-4b7f-971b-1b07faaa4c13
# ╟─228e9bf1-cfd8-4285-8b68-43762e1ae8c7
# ╟─23974dfc-7412-4983-9dcc-16e7a3e7dcc4
# ╟─33c80113-6505-41a6-95bd-e1f26847ed47
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
