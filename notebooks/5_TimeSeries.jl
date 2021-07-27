### A Pluto.jl notebook ###
# v0.15.1

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
			"Plots",
			"RollingFunctions",
			"ShiftedArrays",
			"TimeSeries",
			"TSAnalysis",
			"HTTP"
			])
	Pkg.add(url="https://github.com/viraltux/Forecast.jl")
	
	using PlutoUI
	
	using CSV
	using DataFrames
	using Forecast
	using Plots
	using RollingFunctions
	using ShiftedArrays
	using TimeSeries
	using TSAnalysis
	
	# evitar conflitos com stack de DataFrames
	import HTTP
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

# ╔═╡ dac3e963-6470-41c0-8243-45d9561189f7
md"""
# O que Fazemos com Dados Temporais?
"""

# ╔═╡ 878ad6c7-cfca-4af9-b999-32c83bc90d10
md"""
## Calcular valores com base em Valores Anteriores -- [`ShiftedArrays.jl`](https://github.com/JuliaArrays/ShiftedArrays.jl)

* `lag`
* `lead`
"""

# ╔═╡ 2627e2e2-96de-4812-9542-ff7a28cbdc2f
md"""
## Calcular Estatísticas Móveis com base em Valores Anteriores -- [`RollingFunctions.jl`](https://github.com/JeffreySarnoff/RollingFunctions.jl)

Funções com dois prefixos:
* **`roll`**:
* **`run`**:

Funções com vários sufixos:
* `min`, `max`, `mean`, `median`
* `var`, `std`, `sem`, `mad`, `mad_normalized`
* `skewness`, `kurtosis`, `variation`
* `cor`, `cov`: correlação e covariância (sobre dois vetores de dados) 
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

# ╔═╡ 1d77ec4b-d94a-487a-a910-fb6fc6aa6f6a
md"""
# Exemplo com um Dataset Legal
"""

# ╔═╡ c9583420-6b50-4afb-aa34-7b070fbd50d6
md"""
# Maneiras de Modelar Séries Temporais

- $(HTML("<s>Frequentista</s>")):
   * Livro [Forecastring 3a edição](https://otexts.com/fpp3/)
   * Livro [Analysis of Financial Time Series 3a edição](https://faculty.chicagobooth.edu/ruey-s-tsay/research/analysis-of-financial-time-series-3rd-edition)
   * Pacote [`TSAnalysis.jl`](https://github.com/fipelle/TSAnalysis.jl): ARIMA, filtros Kalman etc...
   * Pacote[`Forecast.jl`](https://github.com/viraltux/Forecast.jl): foco em predição e visualizações, apenas modelos AR
- **Bayesiana**:
   * Livro [Bayesian Data Analysis 3a edição](http://www.stat.columbia.edu/~gelman/book/)
   * Livro [Statistical Rethinking 2a edição](https://xcelab.net/rm/statistical-rethinking/)
   * Manual do [`Stan`, seção 2 de Modelos de Séries Temporais](https://mc-stan.org/docs/stan-users-guide/time-series-chapter.html): ARIMA, GARCH, HMM etc.
   * Versão Bayesiana em `Stan` dos modelos do Livro Analysis of Financial Time Series 3a edição: [`marcomarconi/AFTS_with_Stan`](https://github.com/marcomarconi/AFTS_with_Stan) e [blog](https://notimeforbayes.blogspot.com/)
   * Pacote [`Turing.jl`](https://github.com/TuringLang/Turing.jl): [meus tutoriais em inglês](https://storopoli.io/Bayesian-Julia) e vamos falar sobre ele na [Aula 9 - Modelos Probabilísticos Bayesianos com `Turing.jl`](https://storopoli.io/Computacao-Cientifica/9_Turing/)
"""

# ╔═╡ edc542c7-8f70-4fa3-abcf-c9162ced69a0
md"""
## _**A**uto**r**egressive_ -- AR
"""

# ╔═╡ 37c4966e-6a4d-4f9d-905b-a806cc8b3ba6
md"""
## _**M**oving **A**verage_ -- MA
"""

# ╔═╡ 43fc389e-3daf-4a2d-b1c1-45dc10b53b49
md"""
## _**A**uto**r**egressive **M**oving **A**verage_ -- ARMA
"""

# ╔═╡ d13d7df1-7970-4696-8159-a17ba2ab9b03
md"""
## _**A**uto**r**egressive **Integrated** **M**oving **A**verage_ -- ARIMA
"""

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
# ╟─59b60d4a-04bf-425e-a443-1361af55a428
# ╟─9eb79017-d135-44e9-a2ea-712829418a6d
# ╟─38581a7b-2da4-49fb-b5e0-32db22cb3616
# ╟─23e24ad3-296b-4316-bb1b-617262b93a9b
# ╟─aa89ebab-573c-4819-b1c6-ffce3fff5a18
# ╟─f8ab9748-2002-4e48-82d2-60518e06f5cd
# ╟─849d7757-f5ff-41fc-9330-a83e063316b6
# ╟─5d701b31-c830-4097-95ef-0e257ea36cb0
# ╠═dac3e963-6470-41c0-8243-45d9561189f7
# ╠═878ad6c7-cfca-4af9-b999-32c83bc90d10
# ╠═2627e2e2-96de-4812-9542-ff7a28cbdc2f
# ╟─77b5a188-e6a6-4822-9c41-786b7904bc21
# ╠═1d77ec4b-d94a-487a-a910-fb6fc6aa6f6a
# ╠═c9583420-6b50-4afb-aa34-7b070fbd50d6
# ╠═edc542c7-8f70-4fa3-abcf-c9162ced69a0
# ╠═37c4966e-6a4d-4f9d-905b-a806cc8b3ba6
# ╠═43fc389e-3daf-4a2d-b1c1-45dc10b53b49
# ╠═d13d7df1-7970-4696-8159-a17ba2ab9b03
# ╟─ffa8b715-8974-481a-98c5-b5f101b0dff6
# ╠═661a485e-5721-4acc-96a4-39674ec27c1e
# ╟─d548bc1a-2e20-4b7f-971b-1b07faaa4c13
# ╟─228e9bf1-cfd8-4285-8b68-43762e1ae8c7
# ╟─23974dfc-7412-4983-9dcc-16e7a3e7dcc4
# ╟─659b4a75-c348-4cfa-b76e-420a4e224730
