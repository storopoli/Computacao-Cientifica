### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 27f62732-c909-11eb-27ee-e373dce148d9
begin
	using Pkg
	using PlutoUI
	
	# Turing
	using Turing
	using MCMCChains
	using LazyArrays
	using LinearAlgebra

	# Visualizações
	using Plots
	using StatsPlots
	using LaTeXStrings

	# Dados
	using CSV
	using DataFrames
	
	# Benchmarks
	using BenchmarkTools
	
	# Estatística
	using Distributions
	using Statistics: mean, std

	# evitar conflitos com stack de DataFrames
	import HTTP
	
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
# Modelos Probabilísticos Bayesianos com `Turing.jl`
"""

# ╔═╡ bdece96a-53f6-41b9-a16a-fabdf24524e0
Resource("https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg", :width => 120, :display => "inline")

# ╔═╡ c9c8b8c4-c97d-41c7-9eaa-b7a367851c50
md"""
!!! danger "⚠️ Disciplina Ferramental"
	**Esta disciplina é uma disciplina ferramental!**

	Portanto, se você não sabe o que é estatística Bayesiana, pegue um livro-texto e estude ou pergunte pro seu orientador.

	**Sugestão de fontes**: 

	Gelman, A., Carlin, J. B., Stern, H. S., Dunson, D. B., Vehtari, A., & Rubin, D. B. (2013). Bayesian Data Analysis. Chapman and Hall/CRC. [(link)](http://www.stat.columbia.edu/~gelman/book/)
	
	Gelman, A., Hill, J., & Vehtari, A. (2020). Regression and other stories. Cambridge University Press. [(link)](https://avehtari.github.io/ROS-Examples/)

	McElreath, R. (2020). Statistical rethinking: A Bayesian course with examples in R and Stan. CRC press. [(link)](https://xcelab.net/rm/statistical-rethinking/)

	Jaynes, E. T. (2003). Probability theory: The logic of science. Cambridge university press. [(link)](https://www.amazon.com/Probability-Theory-Science-T-Jaynes/dp/0521592712)
"""

# ╔═╡ cd619fe5-ce2a-4631-af7c-047bb990915a
md"""
[$(Resource("https://github.com/storopoli/Turing-Workshop/blob/master/images/BDA_book.jpg?raw=true", :width => 100.5*1.25))](https://www.routledge.com/Bayesian-Data-Analysis/Gelman-Carlin-Stern-Dunson-Vehtari-Rubin/p/book/9781439840955)
[$(Resource("https://github.com/storopoli/Turing-Workshop/blob/master/images/SR_book.jpg?raw=true", :width => 104*1.25))](https://www.routledge.com/Statistical-Rethinking-A-Bayesian-Course-with-Examples-in-R-and-STAN/McElreath/p/book/9780367139919)
[$(Resource("https://github.com/storopoli/Turing-Workshop/blob/master/images/ROS_book.jpg?raw=true", :width => 118*1.25))](https://www.cambridge.org/fi/academic/subjects/statistics-probability/statistical-theory-and-methods/regression-and-other-stories)
[$(Resource("https://github.com/storopoli/Turing-Workshop/blob/master/images/Bayes_book.jpg?raw=true", :width => 102*1.25))](https://www.amazon.com/Theory-That-Would-Not-Die/dp/0300188226/)
[$(Resource("https://github.com/storopoli/Turing-Workshop/blob/master/images/bernoullis_fallacy_book.jpeg?raw=true", :width => 102*1.25))](https://www.amazon.com/Bernoullis-Fallacy-Statistical-Illogic-Science/dp/0231199945)
"""

# ╔═╡ 44cb1b2b-6ea3-4fd6-a543-c5164121b658
HTML(
"<style>.embed-container { position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; } .embed-container iframe, .embed-container object, .embed-container embed { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }</style><div class='embed-container'><iframe src='https://www.youtube.com/embed/RMNwsdb5VU4' frameborder='0' allowfullscreen></iframe></div>"
)

# ╔═╡ 5a0ed069-6f99-47ac-bfe5-831ab396d470
md"""
!!! tip "💡 Tutorias de Turing"
    Não deixe de ver os tutoriais de **Estatística Bayesiana com `Turing.jl` e Julia** que eu fiz: <https://storopoli.github.io/Bayesian-Julia>
"""

# ╔═╡ 4ea61753-a2ff-442e-ac91-55060fd52db9
Resource("https://github.com/storopoli/Bayesian-Julia/blob/master/images/bayes-meme.jpg?raw=true",  :width => 250, :display=>"center")

# ╔═╡ 4dc10c3b-fbe8-4050-b32c-c056223e1131
md"""
# O que é Estatística Bayesiana?

A **estatística Bayesiana é uma abordagem de análise de dados baseada no teorema de Bayes, onde o conhecimento disponível sobre os parâmetros em um modelo estatístico é atualizado com as informações dos dados observados** (Gelman et. al, 2013).

O conhecimento prévio é expresso como uma distribuição *a priori* (*prior distribution*) e combinado com os dados observados na forma de uma função de verossimilhança ( *likelihood function*) para determinar a distribuição *a posteriori* (*posterior distribution*). A *posteriori* também pode ser usada para fazer previsões sobre eventos futuros.

> Gelman, A., Carlin, J. B., Stern, H. S., Dunson, D. B., Vehtari, A., & Rubin, D. B. (2013). *Bayesian Data Analysis*. Chapman and Hall/CRC.

$$\underbrace{P(\theta \mid y)}_{\textit{Posteriori}} = \frac{\overbrace{P(y \mid  \theta)}^{\text{Verossimilhança}} \cdot \overbrace{P(\theta)}^{\textit{Priori}}}{\underbrace{P(y)}_{\text{Costante Normalizadora}}}$$

> Sem $p$-values! Ninguém sabe o que eles são... Não é $P(H_0 \mid y)$
"""

# ╔═╡ b093fd81-4011-4594-8b9a-c496a0afe116
md"""
# O que é o tal do $p$-valor?

**Primeiramente a definição estatística**:

>  $p$-valor é a probabilidade de obter resultados no mínimo tão extremos quanto os que foram observados, dado que a hipótese nula $H_0$ é verdadeira.
Se você escrever essa definição em qualquer prova, livro ou artigo científico, você estará 100% preciso e correto na definição do que é um $p$-valor. Agora, a compreensão dessa definição é algo complicado. Para isso, vamos quebrar essa definição em algumas partes para melhor compreensão:

* **"probabilidade de obter resultados..."**: vejam que $p$-valores são uma característica dos seus dados e não da sua teoria ou hipótese.

* **"...no mínimo tão extremos quanto os que foram observados..."**: "no minimo tão" implica em definir um limiar para a caracterização de algum achado relevante, que é comumente chamado de $\alpha$. Geralmente estipulamos alpha em 5% ($\alpha = 0.05$) e qualquer coisa mais extrema que alpha (ou seja menor que 5%) caracterizamos como **significante**.

* **"...dado que a hipótese nula é verdadeira."**: todo teste estatístico que possui um $p$-valor possui uma Hipótese Nula (geralmente escrita como $H_0$). Hipótese nula, sempre tem a ver com algum **efeito nulo**. Por exemplo, a hipótese nula do teste Shapiro-Wilk e Komolgorov-Smirnov é "os dados são distribuídos conforme uma distribuição Normal" e a do teste de Levene é "as variâncias dos dados são iguais". Sempre que ver um $p$-valor, se pergunte: "Qual a hipótese nula que este teste presupõe correta?".


Para entender o $p$-valor qualquer teste estatístico  primeiro descubra qual é a hipótese nula por trás daquele teste. A definição do $p$-valor não mudará. Em todo teste ela é sempre a mesma. O que muda com o teste é a hipótese nula. Cada teste possui sua $H_0$. Por exemplo, alguns testes estatísticos comuns ($\text{D}$ = dados):

* Teste t: $P(D \mid \text{a diferença entre os grupos é zero})$

* ANOVA: $P(D \mid \text{não há diferença entre os grupos})$

* Regressão: $P(D \mid \text{coeficiente é nulo})$

* Shapiro-Wilk: $P(D \mid \text{amostra é oriunda de uma população distribuída como uma normal})$


 $p$-valor é a probabilidade dos dados que você obteve dado que a hipótese nula é verdadeira. Para os que gostam do formalismo matemático: $p = P(D \mid H_0)$. Em português, essa expressão significa "a probabilidade de $D$ condicionado à $H_0$". Antes de avançarmos para alguns exemplos e tentativas de formalizar uma intuição sobre os $p$-valores, é importante ressaltar que $p$-valores dizem algo à respeito dos **dados** e não de **hipóteses**. Para o $p$-valor, **a hipótese nula é verdadeira, e estamos apenas avaliando se os dados se conformam à essa hipótese nula ou não**. Se vocês saírem desse tutorial munidos com essa intuição, o mundo será agraciado com pesquisadores mais preparados para qualificar e interpretar evidências ($p < 0.05$).

**Exemplo intuitivo**:

> Imagine que você tem uma moeda que suspeita ser enviesada para uma probabilidade maior de dar cara. (Sua hipótese nula é então que a moeda é justa.) Você joga a moeda 100 vezes e obtém mais cara do que coroa. O $p$-valor  não dirá se a moeda é justa, mas dirá a probabilidade de você obter pelo menos tantas caras quanto se a moeda fosse justa. É isso - nada mais.


"""

# ╔═╡ 55e159e6-9712-4bab-beb0-e6d3f5f78671
md"""
## Intervalo de Confiança vs Intervalos de Credibilidade
"""

# ╔═╡ 07b757d2-a99d-4a32-9262-4098eeac1bed
md"""
Por exemplo, veja a figura abaixo, que mostra uma distribuição `Log-Normal` com média 0 e desvio padrão 2. O ponto verde mostra a estimativa de máxima verossimilhança (MLE) do valor de $\theta$ que é simplesmente o modo de distribuição. E na área sombreada temos o intervalo de credibilidade de 50% do valor de $\theta$, que é o intervalo entre o percentil 25% e o percentil 75% da densidade de probabilidade de $\theta$. Neste exemplo, MLE leva a valores estimados que não são consistentes com a densidade de probabilidade real do valor de $\theta$.
"""

# ╔═╡ 0d7a483e-4a5e-4319-8e8d-ea983d9c00a4
let
	d = LogNormal(0, 2)
	range_d = 0:0.001:4
	q25 = quantile(d, 0.25)
	q75 = quantile(d, 0.75)
	plot((range_d, pdf.(d, range_d)),
		 leg=false,
		 xlims=(-0.2, 4.2),
		 lw=3,
		 xlabel=L"\theta",
		 ylabel="Densidade")
	scatter!((mode(d), pdf(d, mode(d))), mc=:green, ms=5)
	plot!(range(q25, stop=q75, length=100),
		  x -> pdf(d, x),
		  lc=false, fc=:blues,
		  fill=true, fa=0.5)
end

# ╔═╡ 307586b2-1773-47d8-a489-22ee37251532
md"""
Agora, um exemplo de uma distribuição multimodal (o que não é muito incomum). A figura abaixo mostra uma distribuição bimodal com duas modas 2 e 10. O ponto verde mostra a estimativa de máxima verossimilhança (MLE) do valor de $\theta$ que é o modo de distribuição. Veja que mesmo com 2 modas, o padrão de máxima verossimilhança é a moda mais alta. E na área sombreada temos o intervalo de credibilidade de 50% do valor de $\theta$, que é o intervalo entre o percentil 25% e o percentil 75% da densidade de probabilidade de $\theta$. Neste exemplo, a estimativa por probabilidade máxima novamente nos leva a valores estimados que não são consistentes com a densidade de probabilidade real do valor de $\theta$.
"""

# ╔═╡ 006dcf9c-e474-485c-a34d-e4c3eada6e85
let
	d1 = Normal(10, 1)
	d2 = Normal(2, 1)
	mix_d = [0.4, 0.6]
	d = MixtureModel([d1, d2], mix_d)
	range_d = -2:0.01:14
	sim_d = rand(d, 10_000)
	q25 = quantile(sim_d, 0.25)
	q75 = quantile(sim_d, 0.75)
	plot((range_d, pdf.(d, range_d)),
		 leg=false,
		 xlims=(-2, 14),
		 xticks=[0, 5, 10],
		 lw=3,
		 xlabel=L"\theta",
		 ylabel="Densidade")
	scatter!((mode(d2), pdf(d, mode(d2))), mc=:green, ms=5)
	plot!(range(q25, stop=q75, length=100),
		  x -> pdf(d, x),
		  lc=false, fc=:blues,
		  fill=true, fa=0.5)
end

# ╔═╡ cafa53f2-f979-488a-a07c-062d0916fc56
md"""
# Estatística Bayesiana vs Frequentista

|                   | **Estatística Bayesiana**                         | **Estatística Frequentista**                                        |
|-------------------|---------------------------------------------------|---------------------------------------------------------------------|
| **Dados**         | Fixos -- Não Aleatórios                           | Incertos -- Aleatórios                                              |
| **Parâmetros**    | Incertos -- Aleatórios                            | Fixos -- Não Aleatórios                                             |
| **Inferência**    | Incerteza sobre o valor do parâmetro              | Incerteza sobre um processo de amostragem de uma população infinita |
| **Probabilidade** | Subjetiva                                         | Objetiva (mas com diversos pressupostos dos modelos)                |
| **Incerteza**     | Intervalo de Credibilidade -- $P(\theta \mid y)$  | Intervalo de Confiança -- $P(y \mid \theta)$                        |
"""

# ╔═╡ 350a7204-fb21-45e3-8fb9-64bedc7402f6
md"""
# Vantagens da Estatística Bayesiana

Por fim, eu sumarizo as principais **vantagens da estatística Bayesiana**:

* Abordagem Natural para expressar incerteza

* Habilidade de incorporar informações prévia

* Maior flexibilidade do modelo

* Distribuição posterior completa dos parâmetros

   * Intervalos de Confiança vs Intervalos de Credibilidade

* Propagação natural da incerteza

E eu acredito que preciso também mostrar a principal **desvantagem**:

* Velocidade lenta de estimativa do modelo (30 segundos ao invés de 3 segundos na abordagem frequentista)
"""

# ╔═╡ c44b18bd-9015-4e0c-820a-7e92536a02c3
md"""
# `Turing.jl`

[**`Turing.jl`** (Ge, Xu & Ghahramani, 2018)](http://turing.ml/) é um ecossistema de pacotes Julia para **inferência Bayesiana** usando [**programação probabilística**](https://en.wikipedia.org/wiki/Probabilistic_programming). Os modelos especificados usando `Turing.jl` são fáceis de ler e escrever - os modelos funcionam da maneira que você os escreve. Como tudo em Julia, `Turing.jl` é **rápido** [(Tarek, Xu, Trapp, Ge & Ghahramani, 2020)](https://arxiv.org/abs/2002.02702).

> Ge, H., Xu, K., & Ghahramani, Z. (2018). Turing: A Language for Flexible Probabilistic Inference. International Conference on Artificial Intelligence and Statistics, 1682–1690. http://proceedings.mlr.press/v84/ge18b.html
>
> Tarek, M., Xu, K., Trapp, M., Ge, H., & Ghahramani, Z. (2020). DynamicPPL: Stan-like Speed for Dynamic Probabilistic Models. ArXiv:2002.02702 [Cs, Stat]. http://arxiv.org/abs/2002.02702

Antes de mergulharmos em como especificar modelos em `Turing,jl`. Vamos discutir o **ecossistema** de `Turing.jl`.
Temos vários pacotes Julia na organização GitHub de Turing [TuringLang](https://github.com/TuringLang), mas vou me concentrar em 7 deles:

* [`Turing.jl`](https://github.com/TuringLang/Turing.jl): pacote principal que usamos para **fazer interface com todo o ecossistema de `Turing.jl`** de pacotes e a espinha dorsal do PPL `Turing.jl`.


* [`MCMCChains.jl`](https://github.com/TuringLang/MCMCChains.jl): é uma interface para **resumir simulações MCMC** e tem várias funções utilitárias para **diagnósticos** e **visualizações**.


* [`DynamicPPL.jl`](https://github.com/TuringLang/DynamicPPL.jl): que especifica uma linguagem específica de domínio (_**D**omain **S**pecific **L**anguage_ -- DSL) e backend para `Turing.jl` (que é um PPL), modular e escrito em Julia.


* [`AdvancedHMC.jl`](https://github.com/TuringLang/AdvancedHMC.jl): implementação modular e eficiente de algoritmos HMC avançados. O algoritmo HMC de última geração é o **N**o-**U**-**T**urn **S**ampling (NUTS) (Hoffman & Gelman, 2011)


* [`DistributionsAD.jl`](https://github.com/TuringLang/DistributionsAD.jl): define as funções necessárias para habilitar a diferenciação automática (_**A**utomatic **D**ifferentation_ -- AutoDiff -- AD) da função `logpdf` de [` Distributions.jl`](https://github.com/JuliaStats/Distributions.jl) usando os pacotes [`Tracker.jl`](https://github.com/FluxML/Tracker.jl), [`Zygote.jl`](https://github.com/FluxML/Zygote.jl), [` ForwardDiff.jl`](https://github.com/JuliaDiff/ForwardDiff.jl) e [`ReverseDiff.jl`](https://github.com/JuliaDiff/ReverseDiff.jl). O principal objetivo do `DistributionsAD.jl` é tornar a saída do` logpdf` diferenciável com respeito a todos os parâmetros contínuos de uma distribuição.


* [`Bijectors.jl`](https://github.com/TuringLang/Bijectors.jl): implementa um conjunto de funções para transformar variáveis aleatórias restritas (por exemplo, simplexes, intervalos) para o espaço euclidiano. Observe que `Bijectors.jl` ainda é um trabalho em andamento e, no futuro, teremos uma implementação melhor para mais restrições, por exemplo, vetores ordenados positivos de variáveis aleatórias.

* [`TuringGLM.jl`](https://github.com/TuringLang/TuringGLM.jl): ainda em desenvolvimento. Implementa a síntaxe de formula amigável e familiar aos(às) estatísticos(as) e pessoas oriundas da linguagem R.

> Hoffman, M. D., & Gelman, A. (2011). The No-U-Turn Sampler: Adaptively Setting Path Lengths in Hamiltonian Monte Carlo. Journal of Machine Learning Research, 15(1), 1593–1623.
"""

# ╔═╡ 20e897da-f24e-4b66-a585-14775a47bf70
md"""
## Como especificar um modelo? `@model`

**Especificamos o modelo dentro de uma macro `@model`** onde podemos atribuir variáveis de duas maneiras:

1. usando `~`: o que significa que uma variável segue alguma distribuição de probabilidade (`Normal`, `Binomial` etc.) e seu valor é aleatório nessa distribuição.

2. usando `=`: o que significa que uma variável não segue uma distribuição de probabilidade e seu valor é determinístico (como a atribuição normal `=` em linguagens de programação)

`Turing.jl` executará inferência automática em todas as variáveis que você especificar usando `~`.

Assim como você escreveria na forma matemática:

$$\begin{aligned}
p &\sim \text{Beta}(1,1) \\
\text{coin flip} &\sim \text{Bernoulli}(p)
\end{aligned}$$

> **Exemplo**: Moeda tendenciosa com $p = 0.7$.
"""

# ╔═╡ fabcb7f5-fd4f-4da9-b736-f46102f1d96a
coin_flips = rand(Bernoulli(0.7), 100);

# ╔═╡ 3e0788d1-8d14-4012-9a71-c24abb41ac4b
@model function coin(coin_flips)
	p ~ Beta(1, 1)
	for i in 1:length(coin_flips)
		coin_flips[i] ~ Bernoulli(p)
	end
end;

# ╔═╡ 1b3ede8a-4764-40c6-891e-d257583583bd
begin
	chain_coin = sample(coin(coin_flips), MH(), 2_000);
	summarystats(chain_coin)
end

# ╔═╡ 981317c1-6423-446c-a96a-3cd6bc6a88f0
quantile(chain_coin)

# ╔═╡ 53cfa785-f81e-4bc4-8773-723b9626cb19
md"""
## Como especificar um amostrador Monte Carlo de Correntes Markov (MCMC)? `NUTS`, `HMC`, `MH` etc.

Temos [vários exemplos] (https://turing.ml/dev/docs/using-turing/sampler-viz) disponíveis:

* `MH()`: **M**etropolis-**H**astings
* `PG()`: **P**article **G**ibbs
* `SMC()`: **S**equential **M**onte **C**arlo
* `HMC()`: **H**amiltonian **M**onte **C**arlo
* `HMCDA()`: **H**amiltonian **M**onte **C**arlo with Nesterov's **D**ual **A**veraging
* `NUTS()`: **N**o-**U**-**T**urn **S**ampling

Apenas enfie seu `amostrador` desejado na função `sample(modelo, amostrador, N; kwargs)`.

Brinque se quiser. Escolha o seu `amostrador`:
"""

# ╔═╡ 885d11ab-303c-420d-b4e3-be753a4845b7
@bind chosen_sampler Radio([
		"MH()",
		"PG(Nₚ) - Number of Particles",
		"SMC()",
		"HMC(ϵ, L) - leaprog step size(ϵ) e number of leaprogs steps (L)",
		"HMCDA(Nₐ, δ, λ) - Number of samples to use for adaptation (Nₐ), target acceptance ratio (δ), e target leapfrog length(λ)",
		"NUTS(Nₐ, δ) - Number of samples to use for adaptation (Nₐ) e target acceptance ratio (δ)"], default = "MH()")

# ╔═╡ d622f58d-1f3b-4d22-a7f3-80bb1df920f5
begin
	your_sampler = nothing
	if chosen_sampler == "MH()"
		your_sampler = MH()
	elseif chosen_sampler == "PG(Nₚ) - Number of Particles"
		your_sampler = PG(2)
	elseif chosen_sampler == "SMC()"
		your_sampler = SMC()
	elseif chosen_sampler == "HMC(ϵ, L) - leaprog step size(ϵ) e number of leaprogs steps (L)"
		your_sampler = HMC(0.05, 10)
	elseif chosen_sampler == "HMCDA(Nₐ, δ, λ) - Number of samples to use for adaptation (Nₐ), target acceptance ratio (δ), e target leapfrog length(λ)"
		your_sampler = HMCDA(10, 0.65, 0.3)
	elseif chosen_sampler == "NUTS(Nₐ, δ) - Number of samples to use for adaptation (Nₐ) e target acceptance ratio (δ)"
		your_sampler = NUTS(0.65)
	end
end

# ╔═╡ 08ff26a5-b28c-4c69-b574-92baddceb0d6
begin
	chain_coin_2 = sample(coin(coin_flips), your_sampler, 100); # Here is your sampler
	summarystats(chain_coin_2)
end

# ╔═╡ 38386c8a-31af-4989-b0ee-c28ce735f9b0
md"""
## MOAH CHAINS!! `MCMCThreads` e `MCMCDistributed`

Existem alguns métodos do `sample` de `Turing.jl` que aceita:

* **`MCMCThreads()`**: usa paralelização com [`Threads.jl`](https://docs.julialang.org/en/v1/manual/multi-threading/#man-multithreading)


* **`MCMCDistributed()`**: usa paralelização multiprocessos com [`Distributed.jl`](https://docs.julialang.org/en/v1/manual/distributed-computing/) por meio  do [MPI -- _**M**essage **P**assing **I**nterface_](https://en.wikipedia.org/wiki/Message_Passing_Interface)
> Se você estiver usando `MCMCDistributed()` não se esqueça da macro `@where` e do` addprocs () `stuff

Basta usar `sample(modelo, amostrador, MCMCThreads(), N, correntes)`

Vamos revisitar nosso exemplo de moeda tendenciosa:
"""

# ╔═╡ 45237b0d-a71d-4b8a-863b-bd0fac87a6bc
begin
	chain_coin_parallel = sample(coin(coin_flips), MH(), MCMCThreads(), 2_000, 2);
	summarystats(chain_coin_parallel)
end

# ╔═╡ f4219f9d-5cb2-4dd4-89e8-469fb0e6ea76
quantile(chain_coin_parallel)

# ╔═╡ 14b838bf-3d86-423d-90d9-f50fb01e4b6e
md"""
## Como Inspecionar Correntes Markov e Visualizações com `MCMCChains.jl`

Podemos inspecionar e plotar as correntes Markov de nosso modelo e seus parâmetros subjacentes com [**`MCMCChains.jl`**](https://turinglang.github.io/MCMCChains.jl/stable/):

1. **Inspecionando Correntes**
    * **Estatísticas Descritivas**: basta fazer `summarystats(chain)`
    * **Quantis** (mediana, etc.): basta fazer `quantile(chain)`
    * E se eu só quiser um **subconjunto** de parâmetros?: basta fazer `group(chain, :parameter)` ou indexar com `chain[:, 1:6, :]` ou `chain[[:parameters,...]]`
    * **Diagnósticos**: basta fazer um `summarize(chain, sections=[:internals])`
"""

# ╔═╡ d6d0c8f3-9ffb-4d79-8a23-518e798d1b8e
typeof(chain_coin)

# ╔═╡ 671d83f2-f5d9-4931-be18-f6a4f514433f
summarystats(chain_coin_parallel)

# ╔═╡ 06292181-9405-4a5f-b30e-29c50ff09251
quantile(chain_coin_parallel)

# ╔═╡ 197ff761-422b-4f20-85aa-248ef748051b
quantile(group(chain_coin_parallel, :p))

# ╔═╡ 5201b2c3-9cec-47ee-981a-8af923c06943
summarystats(chain_coin_parallel[:, 1:1, :])

# ╔═╡ 0b51d75d-0acf-44eb-871e-91f02425e237
summarize(chain_coin, sections=[:internals])

# ╔═╡ fc2c6b64-c63a-4afe-9319-e07b79485fee
md"""
2. **Visualizando Correntes Markov**: Agora temos várias opções. A receita padrão `plot()` renderizará um `traceplot()` lado-a-lado com uma `mixeddensity()`.

    Primeiro, temos que escolher ou visualizar **parâmetros** (`:parameter`) ou **correntes Makov** (`:chain`) com o argumento *keyword* `colordim`.
"""

# ╔═╡ 1c434eef-157c-4d10-8454-8caa87138686
plot(chain_coin_parallel; dpi=300)

# ╔═╡ 59b771c7-8c6c-4cf3-8f12-bb5fc2d11e9b
plot(chain_coin_parallel; colordim=:chain, dpi=300)

# ╔═╡ bab2207c-0571-49c0-b9dc-912a26e4c9ea
plot(chain_coin_parallel; colordim=:parameter, dpi=300)

# ╔═╡ 0f4873ae-2a04-4030-bbc6-94e29bab0265
md"""
Segundo, temos diversas visualizações para escolher :
* `traceplot()`: usado para inspecionar **convergência** de correntes de Markov
* `meanplot()`: médias móvel do parâmetro por interação
* `density()`: **densidade** da distribuição do parâmetro
* `histogram()`: **histograma** da distribuição do parâmetro
* `mixeddensity()`: **densidade mista** da distribuição do parâmetro
* `autcorplot()`: **autocorrelatação**
"""

# ╔═╡ f17442ec-1138-4c4a-ac11-abe825b6a110
plot(
	traceplot(chain_coin_parallel; title="traceplot"),
	meanplot(chain_coin_parallel; title="meanplot"),
	density(chain_coin_parallel; title="density"),
	histogram(chain_coin_parallel; title="histogram"),
	mixeddensity(chain_coin_parallel; title="mixeddensity"),
	autocorplot(chain_coin_parallel; title="autocorplot"),
	dpi=300, size=(840, 600)
)

# ╔═╡ 5ca48428-3504-4073-bfce-562599b649ad
md"""
Também existe a opção de **construir seu próprio gráfico** com `plot()` e o argumento *keyword* `seriestype`:
"""

# ╔═╡ 6a974f6a-d6fc-4031-b657-14d13001e0ee
plot(chain_coin_parallel; seriestype=(:meanplot, :autocorplot), dpi=300)

# ╔═╡ d4091772-5a5b-435d-8f53-3bf259dc99cd
md"""
## Como evitar `for`-loops dentro `@model` (`LazyArrays` e `filldist`)
"""

# ╔═╡ b08f36be-9fa4-4e18-9378-e29eb8f54d2f
md"""
**Regressão Logística**

$$\begin{aligned}
\boldsymbol{y} &\sim \text{Bernoulli}\left( p\right) \\
p &= \text{Logística}(\alpha +  \mathbf{X} \boldsymbol{\beta}) \\
\alpha &\sim \text{Normal}(\mu_\alpha, \sigma_\alpha) \\
\boldsymbol{\beta} &\sim \text{Normal}(\mu_{\boldsymbol{\beta}}, \sigma_{\boldsymbol{\beta}})
\end{aligned}$$

Sendo que:

*  $\boldsymbol{y}$ -- variável dependente binária
*  $p$ -- probabilidade de $\boldsymbol{y}$ tomar o valor de 1 - sucesso de um experimento Bernoulli independente
*  $\text{Logística}$ -- função logística
*  $\alpha$ -- constante (também chamada de *intercept*)
*  $\boldsymbol{\beta}$ -- vetor de coeficientes
*  $\mathbf{X}$ -- matriz de dados
"""

# ╔═╡ 91fd4de2-30c8-44fd-8c64-4ee78bd3140f
md"""
Primeiro o modelo ingênuo *com* `for`-loops:
"""

# ╔═╡ efee4868-b96b-4bcf-9e1e-de93535a4dad
@model function logreg(X,  y; predictors=size(X, 2))
	# priors
	α ~ Normal(0, 2.5) # não é alpha, é α
	β = Vector{Float64}(undef, predictors)
	for i in 1:predictors
		β[i] ~ Normal()
	end
	
	# likelihood
	for i in 1:length(y)
		y[i] ~ BernoulliLogit(α +  X[i, :] ⋅ β) #\cdot TAB (dot product)
	end
end;

# ╔═╡ f319c97c-c1d8-4bb7-8703-34393b8659ed
md"""
* `BernoulliLogit()` de `Turing.jl` é uma distribuição Bernoulli já parameterizada em valores logit que converte o log da chance (_logodds_) para probabilidade.
"""

# ╔═╡ e2157ddf-3fbc-49d0-9fb9-3b2d644187d8
md"""
Agora o modelo *sem* `for`-loops:
"""

# ╔═╡ 506c9851-eaa9-44de-981d-62614904eb74
@model function logreg_vectorized(X,  y; predictors=size(X, 2))
	# priors
	α ~ Normal(0, 2.5)
	β ~ filldist(Normal(), predictors)
	# customization
	# β ~ arraydist([Normal(0, 2), Normal(-1, 3), ...])
	
	# likelihood
	# y .~ BernoulliLogit.(α .+ X * β)
	y ~ arraydist(LazyArray(@~ BernoulliLogit.(α .+ X * β)))
end;

# ╔═╡ afaa1e80-c216-4057-9e4a-0d73722363aa
md"""
* **`arraydist()`** de `Turing.jl` aceita uma `Array` de distribuições retornando uma nova distribuição das distribuições individuais.

* **`LazyArray()`** é o constructor de `LazyArrays.jl` que retorna um objeto de avaliação tardia (_lazy evaluation_) de uma operação qualquer produzindo um mapeamento de `Array` para `Array`. or último, mas não menos importante, o macro `@~` cria a vetorização (_broadcast_) e é um atalho para o familiar operador ponto de vetorização `.` de Julia. Essa é uma maneira eficiente de avisar `Turing.jl` que o nosso vetor `y` é distribuído com avaliação tardia (_lazy evaluation_) como uma `BernoulliLogit` vetorizada (_broadcast_) para `α` adicionado ao produto entre a matriz de dados `X` e o vetor de coeficientes `β`.
"""

# ╔═╡ 09fb0c81-6bee-448e-8938-937fdec06028
md"""

Para exemplo, usaremos um *dataset* chamado **`wells`** (Gelman & Hill, 2007). É uma survey com 3.200 residentes de uma pequena área de Bangladesh na qual os lençóis freáticos estão contaminados por arsênico. Respondentes com altos níveis de arsênico nos seus poços foram encorajados para trocar a sua fonte de água para uma níveis seguros de arsênico.

Possui as seguintes variáveis:

-   `switch`: dependente indicando se o respondente trocou ou não de poço
-   `arsenic`: nível de arsênico do poço do respondente
-   `dist`: distância em metros da casa do respondente até o poço seguro mais próximo
-   `association`: *dummy* se os membros da casa do respondente fazem parte de alguma organização da comunidade
-   `educ`: quantidade de anos de educação que o chefe da família respondente possui

> Gelman, A., & Hill, J. (2007). Data analysis using regression and multilevel/hierarchical models. Cambridge university press.
"""

# ╔═╡ 84850cbd-0e11-4ed4-af64-61a9d2b18b83
begin
	# Regressão Logística
	url = "https://github.com/storopoli/Turing-Workshop/blob/master/data/wells.csv?raw=true"
	wells = CSV.read(HTTP.get(url).body, DataFrame)
	X_wells = Matrix(select(wells, Not(:switch)))
	y_wells = wells[:, :switch];
end

# ╔═╡ 09abc780-18e7-4a9d-986d-25e52a615e32
md"""
**Por quê se preocupar com `for`-loops nos modelos?**

1. Bem, você terá bons ganhos de desempenho:
"""

# ╔═╡ ddd9acdc-6ea6-4bbe-bf49-ce42aaaf4470
@benchmark sample($logreg($X_wells, $y_wells), NUTS(), 100)

# ╔═╡ a10a99fd-56ca-4808-9921-302498bbf3ba
@benchmark sample($logreg_vectorized($X_wells, $y_wells), NUTS(), 100)

# ╔═╡ e93b9152-e826-4ab1-bfdb-b3b41aacc0d5
md"""
2. Alguns [backends de AutoDiff só funcionam sem `for`-loops dentro do`@model`](https://turing.ml/dev/docs/using-turing/performancetips#special-care-for-codetrackercode-and-codezygotecode):
   * [`Tracker.jl`](https://github.com/FluxML/Tracker.jl)
   * [`Zygote.jl`](https://github.com/FluxML/Zygote.jl)
"""

# ╔═╡ 68729b68-d91f-491f-afd7-86d0740b94a7
md"""
### Qual *backend* de *AutoDiff* (AD) usar?

Temos principalmente dois [tipos de AutoDiff](https://en.wikipedia.org/wiki/Automatic_differentiation) (ambos usam a regra da cadeia (_chain rule_) de cáculo $\mathbb{R}^N \to \mathbb{R}^M$)

* **Forward Autodiff**: A variável **independente** é fixada e diferenciação é feita de uma maneira sequencial para *frente*. Preferido quando $N < M$
   * [`ForwardDiff.jl`](https://github.com/JuliaDiff/ForwardDiff.jl): *backend* padrão de `Turing.jl` atualmente (versão 0.21.x), `:forwarddiff`

* **Reverse Autodiff**: A variável **dependente** é fixada e diferenciação é feita de uma maneira sequencial para *trás*. Preferido quando $N > M$
   * [`Tracker.jl`](https://github.com/FluxML/Tracker.jl): `:tracker`
   * [`Zygote.jl`](https://github.com/FluxML/Zygote.jl): `:zygote`
   * [`ReverseDiff.jl`](https://github.com/JuliaDiff/ReverseDiff.jl): `:reversediff`

Veja esse video se você quer aprender mais sobre Diferenciação Automática (_Automatic Differentiation_):
"""

# ╔═╡ 5a9ccc92-123c-4f37-83ed-2fd34465610b
HTML("
<style>.embed-container { position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; } .embed-container iframe, .embed-container object, .embed-container embed { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }</style><div class='embed-container'><iframe src='https://www.youtube.com/embed/wG_nF1awSSY' frameborder='0' allowfullscreen></iframe></div>
")

# ╔═╡ e9a00a1f-8477-4615-86bd-bb637c7e1829
md"""
Para alterar o *backend* de autodiff de `Turing.jl` apenas execute:

```julia
Turing.setadbackend(:zygote)
```

ou :

```julia
Turing.setadbackend(:tracker)
```

Note que você precisa importar o pacote do *backend*:
```julia
using Zygote
```
"""

# ╔═╡ 83a06879-4220-4df3-b19a-ddc5c1ed2a26
md"""
## Modelos Hierárquicos

Modelos **hierárquicos** Bayesianos (também chamados de modelos **multiníveis**) são modelos probabilísticos descritos em **níveis múltiplos** (forma hierárquica) que estimam os parâmetros da distribuição _posteriori_ usando a abordagem Bayesiana.

Os submodelos se combinam para formar o modelo hierárquico, e o **teorema de Bayes é usado para integrá-los aos dados observados** e contabilizar toda a **incerteza** que está presente.

A **modelagem hierárquica** é usada quando as informações estão disponíveis em vários **níveis diferentes de unidades de observação**. A forma hierárquica de análise e organização auxilia no entendimento de **problemas multiparâmetros** e também desempenha um papel importante no desenvolvimento de **estratégias computacionais**.
"""

# ╔═╡ baad490e-227a-41e2-bbb3-4d39f215d250
md"""
!!! tip "💡 I have many names..."
    Modelos multiníveis também são conhecidos por vários nomes:
	
	* Modelos Hierárquicos (_Hierarchical Models_)
	* Modelos de Efeitos Aleatórios (_Random Effects Models_)
	* Modelos de Efeitos Mistos (_Mixed Effects Models_)
	* Modelos de Dados em Painel (_Cross-Sectional Models_)
	* Modelos de Dados Aninhados (_Nested Data Models_)

	> Para uma listagem completa veja [aqui](https://statmodeling.stat.columbia.edu/2019/09/18/all-the-names-for-hierarchical-and-multilevel-modeling/).
"""

# ╔═╡ 6d1c4f5d-2476-46b6-aaa7-774a525a0332
md"""
Mesmo que as observações informem diretamente apenas um único conjunto de parâmetros, o modelo hierárquico acopla os parâmetros individuais e fornece uma porta dos fundos para que as observações informem todos os contextos.

Por exemplo, as observações do $k$-ésimo contexto, $y_k$ , informam diretamente os parâmetros que quantificam o comportamento desse contexto, $\theta_k$ . Esses parâmetros, entretanto, informam diretamente os parâmetros populacionais $\phi$ que então informam todos os outros contextos por meio do modelo hierárquico. Da mesma
forma, as observações que informam diretamente os outros contextos informam indiretamente os parâmetros populacionais que então retroalimentam o $k$-ésimo contexto.
"""

# ╔═╡ 43ff1948-9f8f-4bb7-82ad-24eac7e3bdad
Resource("https://github.com/storopoli/Turing-Workshop/blob/master/images/multilevel_models.png?raw=true", :width => 1_000)

# ╔═╡ 464fe066-229a-42b6-9e95-da44a4064461
md"""
> figura adaptada de [Michael Betancourt (CC-BY-SA-4.0)](https://betanalpha.github.io/assets/case_studies/hierarchical_modeling.html)
"""

# ╔═╡ be5073f2-0062-425d-8621-2101e37a3ce9
md"""
### *Hiperpriori*

Como as _prioris_ dos parâmetros são amostradas de outra _priori_ do hiperparâmetro (parâmetro de nível superior), que são chamados de _hiperprioris_. Isso faz com que as estimativas de um grupo ajudem o modelo a estimar melhor os outros grupos, fornecendo **estimativas robustas e estáveis**.

Chamamos os parâmetros globais de **efeitos de população** (ou efeitos em nível de população, também chamados de **efeitos fixos**) e os parâmetros de cada grupo como **efeitos de grupo** (ou efeitos em nível de grupo, também chamados de **efeitos aleatórios**) É por isso que os modelos multiníveis também são conhecidos como **modelos mistos**, nos quais temos efeitos _fixos_ e efeitos _aleatórios_.
"""

# ╔═╡ 32bd6721-b5cc-4694-b709-ac3e26baf04c
md"""
### Três Abordagens de Modelos Multiníveis

Modelos multiníveis geralmente se enquadram em três abordagens:

* _**Random-intercept model**_: modelo no qual cada grupo recebe uma constante (_intercept_) diferente além da constante global e coeficientes globais.


* _**Random-slope model**_: modelo no qual cada grupo recebe um coeficiente (_slope_) diferente para cada variável independente além da constante global.


* _**Random-intercept-slope model**_: modelo no qual cada grupo recebe tanto uma constante (_intercept_) quanto um coeficiente (_slope_) diferente para cada variável independente além da constante global.
"""

# ╔═╡ 302b03e2-102b-4193-b5c7-43f816e4b20b
md"""
#### _Random-Intercept_

A primeira abordagem é o _**random-intercept model**_ no qual especificamos uma constante (_intercept_) para cada grupo, além da constante global. Essas constantes à nível de grupo são amostradas de uma _hiperpriori_.

Para ilustrar um modelo multinível, vou usar um exemplo de regressão linear com uma função de verossimilhança Gaussiana/normal.
Matematicamente um modelo Bayesiano de regressão linear _random-intercept_ é:

$$\begin{aligned}
\mathbf{y} &\sim \text{Normal}\left( \alpha + \alpha_j + \mathbf{X} \cdot \boldsymbol{\beta}, \sigma \right) \\
\alpha &\sim \text{Normal}(\mu_\alpha, \sigma_\alpha) \\
\alpha_j &\sim \text{Normal}(0, \tau) \\
\boldsymbol{\beta} &\sim \text{Normal}(\mu_{\boldsymbol{\beta}}, \sigma_{\boldsymbol{\beta}}) \\
\tau &\sim \text{Cauchy}^+(0, \psi_{\alpha})\\
\sigma &\sim \text{Exponencial}(\lambda_\sigma)
\end{aligned}$$
"""

# ╔═╡ ba7fdd3f-79c8-4759-8055-c577270ec0ae
@model function varying_intercept(X, idx, y; n_gr=length(unique(idx)), predictors=size(X, 2))
    # prioris
    α ~ Normal(mean(y), 2.5 * std(y))       # constante popularional
    β ~ filldist(Normal(0, 2), predictors)  # coeficientes popularionais
    σ ~ Exponential(1 / std(y))             # erro residual
    
	# priori para variância das constantes de grupo
    # geralmente requer uma especificação cuidadosa
    τ ~ truncated(Cauchy(0, 2); lower=0)     # desvio-padrão das constantes de grupo
    αⱼ ~ filldist(Normal(0, τ), n_gr)       # constantes de grupo
    
	# verossimilhança
    ŷ = α .+ X * β .+ αⱼ[idx]
    y ~ MvNormal(ŷ, σ)
end;

# ╔═╡ a982ae5f-7f33-4ae3-9981-99b74c0cd36a
md"""
#### _Random-Slope_

A segunda abordage é o  _**random-slope model**_ no qual especificamos um coeficiente (_slope_) diferente para cada grupo, além da constante global. Esses coeficientes à nível de grupo são amostrados de uma _hiperpriori_.

Para ilustrar um modelo multinível, vou usar um exemplo de regressão linear com uma função de verossimilhança Gaussiana/normal.
Matematicamente um modelo Bayesiano de regressão linear _random-slope_ é:

$$\begin{aligned}
\mathbf{y} &\sim \text{Normal}\left( \alpha + \mathbf{X} \cdot \boldsymbol{\beta}_j \cdot \boldsymbol{\tau}, \sigma \right) \\
\alpha &\sim \text{Normal}(\mu_\alpha, \sigma_\alpha) \\
\boldsymbol{\beta}_j &\sim \text{Normal}(0, 1) \\
\boldsymbol{\tau} &\sim \text{Cauchy}^+(0, \psi_{\boldsymbol{\beta}})\\
\sigma &\sim \text{Exponencial}(\lambda_\sigma)
\end{aligned}$$
"""

# ╔═╡ 3dc9f615-cae7-4f2a-83a5-86bd395e2c7b
@model function varying_slope(X, idx, y; n_gr=length(unique(idx)), predictors=size(X, 2))
    # prioris
    α ~ Normal(mean(y), 2.5 * std(y))                   # constante popularional
    σ ~ Exponential(1 / std(y))                         # erro residual
    
	# priori para variância dos coeficientes de grupo
    # geralmente requer uma especificação cuidadosa
    τ ~ filldist(truncated(Cauchy(0, 2); lower=0), n_gr) # desvio-padrão dos coeficientes de grupo
    βⱼ ~ filldist(Normal(), predictors, n_gr)       # coeficientes de grupo
    
	# verossimilhança
    ŷ = α .+ X * βⱼ * τ
    y ~ MvNormal(ŷ, σ)
end;

# ╔═╡ a6b1d276-9519-47f8-8d2f-88a952102e46
md"""
#### _Random-Intercept-Slope_

A terceira abordage é o _**random-intercept-slope model**_ no qual especificamos uma constante (_intercept_) e um coeficiente (_slope_) diferente para cada grupo, além da constante global.
Essas constantes e coeficientes à nível de grupo são amostrados de uma _hiperpriori_.

Para ilustrar um modelo multinível, vou usar um exemplo de regressão linear com uma função de verossimilhança Gaussiana/normal.
Matematicamente um modelo Bayesiano de regressão linear _random-intercept-slope_ é:

$$\begin{aligned}
\mathbf{y} &\sim \text{Normal}\left( \alpha + \alpha_j + \mathbf{X} \cdot \boldsymbol{\beta}_j \cdot \boldsymbol{\tau}_{\boldsymbol{\beta}}, \sigma \right) \\
\alpha &\sim \text{Normal}(\mu_\alpha, \sigma_\alpha) \\
\alpha_j &\sim \text{Normal}(0, \tau_{\alpha}) \\
\boldsymbol{\beta}_j &\sim \text{Normal}(0, 1) \\
\tau_{\alpha} &\sim \text{Cauchy}^+(0, \psi_{\alpha})\\
\boldsymbol{\tau}_{\boldsymbol{\beta}} &\sim \text{Cauchy}^+(0, \psi_{\boldsymbol{\beta}})\\
\sigma &\sim \text{Exponencial}(\lambda_\sigma)
\end{aligned}$$
"""

# ╔═╡ 0ab59e2d-a84d-43cc-8517-92b505988cd7
@model function varying_intercept_slope(X, idx, y; n_gr=length(unique(idx)), predictors=size(X, 2))
    # priors
    α ~ Normal(mean(y), 2.5 * std(y))                    # constante popularional
    σ ~ Exponential(1 / std(y))                          # erro residual
    
	# priori para variância das constantes e coeficientes de grupo
    # geralmente requer uma especificação cuidadosa
    τₐ ~ truncated(Cauchy(0, 2); lower=0)                 # desvio-padrão das constantes de grupo
    τᵦ ~ filldist(truncated(Cauchy(0, 2); lower=0), n_gr) # desvio-padrão dos coeficientes de grupo
    αⱼ ~ filldist(Normal(0, τₐ), n_gr)                   # constantes de grupo
    βⱼ ~ filldist(Normal(), predictors, n_gr)        # coeficientes de grupo
    
	# verossimilhança
    ŷ = α .+ αⱼ[idx] .+ X * βⱼ * τᵦ
    y ~ MvNormal(ŷ, σ)
end;

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

# ╔═╡ 11184212-a2ed-47f5-b123-62fa70636fb7
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
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
InteractiveUtils = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
LazyArrays = "5078a376-72f3-5289-bfd5-ec5146d43c02"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
MCMCChains = "c7f686f2-ff18-58e9-bc7b-31028e88f75d"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
StatsPlots = "f3b207a7-027a-5e70-b257-86293d7955fd"
Turing = "fce5fe82-541a-59a6-adf8-730c64b5f9a0"

[compat]
BenchmarkTools = "~1.3.1"
CSV = "~0.10.4"
DataFrames = "~1.3.2"
Distributions = "~0.25.53"
HTTP = "~0.9.17"
LaTeXStrings = "~1.3.0"
LazyArrays = "~0.22.10"
MCMCChains = "~5.1.0"
Plots = "~1.27.4"
PlutoUI = "~0.7.38"
StatsPlots = "~0.14.33"
Turing = "~0.21.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "6f1d9bc1c08f9f4a8fa92e3ea3cb50153a1b40d4"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.1.0"

[[deps.AbstractMCMC]]
deps = ["BangBang", "ConsoleProgressMonitor", "Distributed", "Logging", "LoggingExtras", "ProgressLogging", "Random", "StatsBase", "TerminalLoggers", "Transducers"]
git-tree-sha1 = "5c26c7759412ffcaf0dd6e3172e55d783dd7610b"
uuid = "80f14c24-f653-4e6a-9b94-39d6b0f70001"
version = "4.1.3"

[[deps.AbstractPPL]]
deps = ["AbstractMCMC", "DensityInterface", "Setfield", "SparseArrays"]
git-tree-sha1 = "6320752437e9fbf49639a410017d862ad64415a5"
uuid = "7a57a42e-76ec-4ea3-a279-07e840d6d9cf"
version = "0.5.2"

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

[[deps.AdvancedHMC]]
deps = ["AbstractMCMC", "ArgCheck", "DocStringExtensions", "InplaceOps", "LinearAlgebra", "ProgressMeter", "Random", "Requires", "Setfield", "Statistics", "StatsBase", "StatsFuns", "UnPack"]
git-tree-sha1 = "345effa84030f273ee86fcdd706d8484ce9a1a3c"
uuid = "0bf59076-c3b1-5ca4-86bd-e02cd72cde3d"
version = "0.3.5"

[[deps.AdvancedMH]]
deps = ["AbstractMCMC", "Distributions", "Random", "Requires"]
git-tree-sha1 = "5d9e09a242d4cf222080398468244389c3428ed1"
uuid = "5b7e9947-ddc0-4b3f-9b55-0d8042f74170"
version = "0.6.7"

[[deps.AdvancedPS]]
deps = ["AbstractMCMC", "Distributions", "Libtask", "Random", "StatsFuns"]
git-tree-sha1 = "9ff1247be1e2aa2e740e84e8c18652bd9d55df22"
uuid = "576499cb-2369-40b2-a588-c64705576edc"
version = "0.3.8"

[[deps.AdvancedVI]]
deps = ["Bijectors", "Distributions", "DistributionsAD", "DocStringExtensions", "ForwardDiff", "LinearAlgebra", "ProgressMeter", "Random", "Requires", "StatsBase", "StatsFuns", "Tracker"]
git-tree-sha1 = "e743af305716a527cdb3a67b31a33a7c3832c41f"
uuid = "b5ca4192-6429-45e5-a2d9-87aec30a685c"
version = "0.1.5"

[[deps.ArgCheck]]
git-tree-sha1 = "a3a402a35a2f7e0b87828ccabbd5ebfbebe356b4"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.3.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Arpack]]
deps = ["Arpack_jll", "Libdl", "LinearAlgebra", "Logging"]
git-tree-sha1 = "91ca22c4b8437da89b030f08d71db55a379ce958"
uuid = "7d9fca2a-8960-54d3-9f78-7d1dccf2cb97"
version = "0.5.3"

[[deps.Arpack_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "OpenBLAS_jll", "Pkg"]
git-tree-sha1 = "5ba6c757e8feccf03a1554dfaf3e26b3cfc7fd5e"
uuid = "68821587-b530-5797-8361-c406ea357684"
version = "3.5.1+1"

[[deps.ArrayInterface]]
deps = ["ArrayInterfaceCore", "Compat", "IfElse", "LinearAlgebra", "Static"]
git-tree-sha1 = "d956c0606a3bc1112a1f99a8b2309b79558d9921"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "6.0.17"

[[deps.ArrayInterfaceCore]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "5e732808bcf7bbf730e810a9eaafc52705b38bb5"
uuid = "30b0a656-2188-435a-8636-2ec0e6a096e2"
version = "0.1.13"

[[deps.ArrayInterfaceStaticArrays]]
deps = ["Adapt", "ArrayInterface", "LinearAlgebra", "Static", "StaticArrays"]
git-tree-sha1 = "d7dc30474e73173a990eca86af76cae8790fa9f2"
uuid = "b0d46f97-bff5-4637-a19a-dd75974142cd"
version = "0.1.2"

[[deps.ArrayLayouts]]
deps = ["FillArrays", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "26c659b14c4dc109b6b9c3398e4455eebc523814"
uuid = "4c555306-a7a7-4459-81d9-ec55ddd5c99a"
version = "0.8.8"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "1dd4d9f5beebac0c03446918741b1a03dc5e5788"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.6"

[[deps.BangBang]]
deps = ["Compat", "ConstructionBase", "Future", "InitialValues", "LinearAlgebra", "Requires", "Setfield", "Tables", "ZygoteRules"]
git-tree-sha1 = "b15a6bc52594f5e4a3b825858d1089618871bf9d"
uuid = "198e06fe-97b7-11e9-32a5-e1d131e6ad66"
version = "0.3.36"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Baselet]]
git-tree-sha1 = "aebf55e6d7795e02ca500a689d326ac979aaf89e"
uuid = "9718e550-a3fa-408a-8086-8db961cd8217"
version = "0.1.1"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "4c10eee4af024676200bc7752e536f858c6b8f93"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.1"

[[deps.Bijectors]]
deps = ["ArgCheck", "ChainRulesCore", "ChangesOfVariables", "Compat", "Distributions", "Functors", "InverseFunctions", "IrrationalConstants", "LinearAlgebra", "LogExpFunctions", "MappedArrays", "Random", "Reexport", "Requires", "Roots", "SparseArrays", "Statistics"]
git-tree-sha1 = "51c842b5a07ad64acdd6cac9e52a304b2d6605b6"
uuid = "76274a88-744f-5084-9051-94815aaf08c4"
version = "0.10.2"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "873fb188a4b9d76549b81465b1f75c82aaf59238"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.4"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[deps.ChainRules]]
deps = ["ChainRulesCore", "Compat", "IrrationalConstants", "LinearAlgebra", "Random", "RealDot", "SparseArrays", "Statistics"]
git-tree-sha1 = "97fd0a3b7703948a847265156a41079730805c77"
uuid = "082447d4-558c-5d27-93f4-14fc19e9eca2"
version = "1.36.0"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "9489214b993cd42d17f44c36e359bf6a7c919abf"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.0"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "1e315e3f4b0b7ce40feded39c73049692126cf53"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.3"

[[deps.Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "75479b7df4167267d75294d14b58244695beb2ac"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.14.2"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "1fd869cc3875b57347f7027521f561cf46d1fcd8"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.19.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.CommonSolve]]
git-tree-sha1 = "332a332c97c7071600984b3c31d9067e1a4e6e25"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.1"

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "9be8be1d8a6f44b96482c8af52238ea7987da3e3"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.45.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.CompositionsBase]]
git-tree-sha1 = "455419f7e328a1a2493cabc6428d79e951349769"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.1"

[[deps.ConsoleProgressMonitor]]
deps = ["Logging", "ProgressMeter"]
git-tree-sha1 = "3ab7b2136722890b9af903859afcf457fa3059e8"
uuid = "88cd18e8-d9cc-4ea6-8889-5259c0d15c8b"
version = "0.1.2"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f74e9d5388b8620b4cee35d4c5a618dd4dc547f4"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.3.0"

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
git-tree-sha1 = "fb5f5316dd3fd4c5e7c30a24d50643b73e37cd40"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.10.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "daa21eb85147f72e41f6352a57fccea377e310a9"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.4"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.DataValues]]
deps = ["DataValueInterfaces", "Dates"]
git-tree-sha1 = "d88a19299eba280a6d062e135a43f00323ae70bf"
uuid = "e7dc6d0d-1eca-5fa6-8ad6-5aecde8b7ea5"
version = "0.4.13"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DefineSingletons]]
git-tree-sha1 = "0fba8b706d0178b4dc7fd44a96a92382c9065c2c"
uuid = "244e2a9f-e319-4986-a169-4d1fe445cd52"
version = "0.1.2"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.DiffResults]]
deps = ["StaticArrays"]
git-tree-sha1 = "c18e98cba888c6c25d1c3b048e4b3380ca956805"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.0.3"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "28d605d9a0ac17118fe2c5e9ce0fbb76c3ceb120"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.11.0"

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
git-tree-sha1 = "0ec161f87bf4ab164ff96dfacf4be8ffff2375fd"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.62"

[[deps.DistributionsAD]]
deps = ["Adapt", "ChainRules", "ChainRulesCore", "Compat", "DiffRules", "Distributions", "FillArrays", "LinearAlgebra", "NaNMath", "PDMats", "Random", "Requires", "SpecialFunctions", "StaticArrays", "StatsBase", "StatsFuns", "ZygoteRules"]
git-tree-sha1 = "ec811a2688b3504ce5b315fe7bc86464480d5964"
uuid = "ced4e74d-a319-5a8a-b0ac-84af2272839c"
version = "0.6.41"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.DynamicPPL]]
deps = ["AbstractMCMC", "AbstractPPL", "BangBang", "Bijectors", "ChainRulesCore", "Distributions", "LinearAlgebra", "MacroTools", "Random", "Setfield", "Test", "ZygoteRules"]
git-tree-sha1 = "c6f574d855670c2906af3f4053e6db10224e5dda"
uuid = "366bfd00-2699-11ea-058f-f148b4cae6d8"
version = "0.19.3"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[deps.EllipticalSliceSampling]]
deps = ["AbstractMCMC", "ArrayInterfaceCore", "Distributions", "Random", "Statistics"]
git-tree-sha1 = "4cda4527e990c0cc201286e0a0bfbbce00abcfc2"
uuid = "cad2338a-1db2-11e9-3401-43bc07c9ede2"
version = "1.0.0"

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
git-tree-sha1 = "90630efff0894f8142308e334473eba54c433549"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.5.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "129b104185df66e408edd6625d480b7f9e9823a0"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.18"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

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

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "2f18915445b248731ec5db4e4a17e451020bf21e"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.30"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.FunctionWrappers]]
git-tree-sha1 = "241552bc2209f0fa068b6415b1942cc0aa486bcc"
uuid = "069b7b12-0de2-55c6-9aab-29f3d0a68a2e"
version = "1.1.2"

[[deps.Functors]]
git-tree-sha1 = "223fffa49ca0ff9ce4f875be001ffe173b2b7de4"
uuid = "d9f16b24-f501-4c13-a1f2-28368ffc5196"
version = "0.2.8"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "51d2dfe8e590fbd74e7a842cf6d13d8a2f45dc01"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.6+0"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "4078d3557ab15dd9fe6a0cf6f65e3d4937e98427"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.0"

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "RelocatableFolders", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "c98aea696662d09e215ef7cda5296024a9646c75"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.64.4"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "3a233eeeb2ca45842fe100e0413936834215abf5"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.64.4+0"

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

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InitialValues]]
git-tree-sha1 = "4da0f88e9a39111c2fa3add390ab15f3a44f3ca3"
uuid = "22cec73e-a1b8-11e9-2c92-598750a2cf9c"
version = "0.3.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "61feba885fac3a407465726d0c330b3055df897f"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.2"

[[deps.InplaceOps]]
deps = ["LinearAlgebra", "Test"]
git-tree-sha1 = "50b41d59e7164ab6fda65e71049fee9d890731ff"
uuid = "505f98c9-085e-5b2c-8e89-488be7bf1f34"
version = "0.3.0"

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
git-tree-sha1 = "b7bc05649af456efc75d178846f47006c2c4c3c7"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.6"

[[deps.IntervalSets]]
deps = ["Dates", "Random", "Statistics"]
git-tree-sha1 = "57af5939800bce15980bddd2426912c4f83012d8"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.1"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "b3364212fb5d870f724876ffcd34dd8ec6d98918"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.7"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
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

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LRUCache]]
git-tree-sha1 = "d64a0aff6691612ab9fb0117b0995270871c5dfc"
uuid = "8ac3fa9e-de4c-5943-b1dc-09c6b5f20637"
version = "1.3.0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "46a39b9c58749eefb5f2dc1178cb8fab5332b1ab"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.15"

[[deps.LazyArrays]]
deps = ["ArrayLayouts", "FillArrays", "LinearAlgebra", "MacroTools", "MatrixFactorizations", "SparseArrays", "StaticArrays"]
git-tree-sha1 = "d9a962fac652cc6b0224622b18199f0ed46d316a"
uuid = "5078a376-72f3-5289-bfd5-ec5146d43c02"
version = "0.22.11"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LeftChildRightSiblingTrees]]
deps = ["AbstractTrees"]
git-tree-sha1 = "b864cb409e8e445688bc478ef87c0afe4f6d1f8d"
uuid = "1d6d02ad-be62-4b6b-8a6d-2f90e265016e"
version = "0.1.3"

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

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

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

[[deps.Libtask]]
deps = ["FunctionWrappers", "LRUCache", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "dfa6c5f2d5a8918dd97c7f1a9ea0de68c2365426"
uuid = "6f1fad26-d15e-5dc8-ae53-837a1d7b8c9f"
version = "0.7.5"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "09e4b894ce6a976c354a69041a04748180d43637"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.15"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "5d4d2d9904227b8bd66386c1138cf4d5ffa826bf"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "0.4.9"

[[deps.MCMCChains]]
deps = ["AbstractMCMC", "AxisArrays", "Compat", "Dates", "Distributions", "Formatting", "IteratorInterfaceExtensions", "KernelDensity", "LinearAlgebra", "MCMCDiagnosticTools", "MLJModelInterface", "NaturalSort", "OrderedCollections", "PrettyTables", "Random", "RecipesBase", "Serialization", "Statistics", "StatsBase", "StatsFuns", "TableTraits", "Tables"]
git-tree-sha1 = "1711536fb68ea406d6c821210d8629820823e836"
uuid = "c7f686f2-ff18-58e9-bc7b-31028e88f75d"
version = "5.1.2"

[[deps.MCMCDiagnosticTools]]
deps = ["AbstractFFTs", "DataAPI", "Distributions", "LinearAlgebra", "MLJModelInterface", "Random", "SpecialFunctions", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "058d08594e91ba1d98dcc3669f9421a76824aa95"
uuid = "be115224-59cd-429b-ad48-344e309966f0"
version = "0.1.3"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "e595b205efd49508358f7dc670a940c790204629"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.0.0+0"

[[deps.MLJModelInterface]]
deps = ["Random", "ScientificTypesBase", "StatisticalTraits"]
git-tree-sha1 = "b8073fe6973dcfad5fec803dabc1d3a7f6c4ebc8"
uuid = "e80e1ace-859a-464e-9ed9-23947d8ae3ea"
version = "1.4.3"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MatrixFactorizations]]
deps = ["ArrayLayouts", "LinearAlgebra", "Printf", "Random"]
git-tree-sha1 = "2212d36f97e01347adb1460a6914e20f2feee853"
uuid = "a3b82374-2e81-5b9e-98ce-41277c0e4c87"
version = "0.9.1"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[deps.MicroCollections]]
deps = ["BangBang", "InitialValues", "Setfield"]
git-tree-sha1 = "6bb7786e4f24d44b4e29df03c69add1b63d88f01"
uuid = "128add7d-3638-4c79-886c-908ea0c25c34"
version = "0.1.2"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.MultivariateStats]]
deps = ["Arpack", "LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI", "StatsBase"]
git-tree-sha1 = "7008a3412d823e29d370ddc77411d593bd8a3d03"
uuid = "6f286f6a-111f-5878-ab1e-185364afe411"
version = "0.9.1"

[[deps.NNlib]]
deps = ["Adapt", "ChainRulesCore", "LinearAlgebra", "Pkg", "Requires", "Statistics"]
git-tree-sha1 = "1a80840bcdb73de345230328d49767ab115be6f2"
uuid = "872c559c-99b0-510c-b3b7-b6c96a88d5cd"
version = "0.8.8"

[[deps.NaNMath]]
git-tree-sha1 = "737a5957f387b17e74d4ad2f440eb330b39a62c5"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.0"

[[deps.NamedArrays]]
deps = ["Combinatorics", "DataStructures", "DelimitedFiles", "InvertedIndices", "LinearAlgebra", "Random", "Requires", "SparseArrays", "Statistics"]
git-tree-sha1 = "2fd5787125d1a93fbe30961bd841707b8a80d75b"
uuid = "86f7a689-2022-50b4-a561-43c23ac3c673"
version = "0.9.6"

[[deps.NaturalSort]]
git-tree-sha1 = "eda490d06b9f7c00752ee81cfa451efe55521e21"
uuid = "c020b1a1-e9b0-503a-9c33-f039bfc54a85"
version = "1.0.0"

[[deps.NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "0e353ed734b1747fc20cd4cba0edd9ac027eff6a"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "ec2e30596282d722f018ae784b7f44f3b88065e4"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.6"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

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
git-tree-sha1 = "7f4869861f8dac4990d6808b66b57e5a425cfd99"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.13"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "0044b23da09b5608b4ecacb4e5e6c6332f833a7e"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.3.2"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "8162b2f8547bc23876edd0c5181b27702ae58dce"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.0.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "bb16469fd5224100e422f0b027d26c5a25de1200"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.2.0"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "6f2dd1cf7a4bbf4f305a0d8750e351cb46dfbe80"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.27.6"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "8d1f54886b9037091edf146b517989fc4a09efec"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.39"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

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

[[deps.ProgressLogging]]
deps = ["Logging", "SHA", "UUIDs"]
git-tree-sha1 = "80d919dee55b9c50e8d9e2da5eeafff3fe58b539"
uuid = "33c8b6b6-d38a-422a-b730-caa89a2f386c"
version = "0.1.4"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "d7a7aef8f8f2d537104f170139553b14dfe39fe9"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.2"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "c6c0f690d0cc7caddb74cef7aa847b824a16b256"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+1"

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

[[deps.RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "dc84268fe0e3335a62e315a3a7cf2afa7178a734"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.3"

[[deps.RealDot]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9f0a1b71baaf7650f4fa8a1d168c7fb6ee41f0c9"
uuid = "c1ae055f-0cd5-4b69-90a6-9a35b1a98df9"
version = "0.1.0"

[[deps.RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "dc1e451e15d90347a7decc4221842a022b011714"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.5.2"

[[deps.RecursiveArrayTools]]
deps = ["Adapt", "ArrayInterfaceCore", "ArrayInterfaceStaticArrays", "ChainRulesCore", "DocStringExtensions", "FillArrays", "GPUArraysCore", "LinearAlgebra", "RecipesBase", "StaticArrays", "Statistics", "ZygoteRules"]
git-tree-sha1 = "de1d261ff688a68f296185085aaecf99bc039d80"
uuid = "731186ca-8d62-57ce-b412-fbd966d074cd"
version = "2.30.0"

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

[[deps.Roots]]
deps = ["CommonSolve", "Printf", "Setfield"]
git-tree-sha1 = "30e3981751855e2340e9b524ab58c1ec85c36f33"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "2.0.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.SciMLBase]]
deps = ["ArrayInterfaceCore", "CommonSolve", "ConstructionBase", "Distributed", "DocStringExtensions", "IteratorInterfaceExtensions", "LinearAlgebra", "Logging", "Markdown", "RecipesBase", "RecursiveArrayTools", "StaticArrays", "Statistics", "Tables", "TreeViews"]
git-tree-sha1 = "e74049cca1ff273cc62697dd3739f7d43e029d93"
uuid = "0bca4576-84f4-4d90-8ffe-ffa030f20462"
version = "1.41.4"

[[deps.ScientificTypesBase]]
git-tree-sha1 = "a8e18eb383b5ecf1b5e6fc237eb39255044fd92b"
uuid = "30f210dd-8aff-4c5f-94ba-8e64358c1161"
version = "3.0.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "db8481cf5d6278a121184809e9eb1628943c7704"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.13"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "Requires"]
git-tree-sha1 = "38d88503f695eb0301479bc9b0d4320b378bafe5"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "0.8.2"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

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
git-tree-sha1 = "a9e798cae4867e3a41cae2dd9eb60c047f1212db"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.6"

[[deps.SplittablesBase]]
deps = ["Setfield", "Test"]
git-tree-sha1 = "39c9f91521de844bad65049efd4f9223e7ed43f9"
uuid = "171d559e-b47b-412a-8079-5efa626c420e"
version = "0.1.14"

[[deps.Static]]
deps = ["IfElse"]
git-tree-sha1 = "5d2c08cef80c7a3a8ba9ca023031a85c263012c5"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.6.6"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "2bbd9f2e40afd197a1379aef05e0d85dba649951"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.4.7"

[[deps.StatisticalTraits]]
deps = ["ScientificTypesBase"]
git-tree-sha1 = "271a7fea12d319f23d55b785c51f6876aadb9ac0"
uuid = "64bff920-2084-43da-a3e6-9bb72801c0c9"
version = "3.0.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "8d7530a38dbd2c397be7ddd01a424e4f411dcc41"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.2.2"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "642f08bf9ff9e39ccc7b710b2eb9a24971b52b1a"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.17"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "5950925ff997ed6fb3e985dcce8eb1ba42a0bbe7"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.18"

[[deps.StatsPlots]]
deps = ["AbstractFFTs", "Clustering", "DataStructures", "DataValues", "Distributions", "Interpolations", "KernelDensity", "LinearAlgebra", "MultivariateStats", "Observables", "Plots", "RecipesBase", "RecipesPipeline", "Reexport", "StatsBase", "TableOperations", "Tables", "Widgets"]
git-tree-sha1 = "4d9c69d65f1b270ad092de0abe13e859b8c55cad"
uuid = "f3b207a7-027a-5e70-b257-86293d7955fd"
version = "0.14.33"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "9abba8f8fb8458e9adf07c8a2377a070674a24f1"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.8"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableOperations]]
deps = ["SentinelArrays", "Tables", "Test"]
git-tree-sha1 = "e383c87cf2a1dc41fa30c093b2a19877c83e1bc1"
uuid = "ab02a1b2-a7df-11e8-156e-fb1833f50b87"
version = "1.2.0"

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

[[deps.TerminalLoggers]]
deps = ["LeftChildRightSiblingTrees", "Logging", "Markdown", "Printf", "ProgressLogging", "UUIDs"]
git-tree-sha1 = "62846a48a6cd70e63aa29944b8c4ef704360d72f"
uuid = "5d786b92-1e48-4d6f-9151-6b4477ca9bed"
version = "0.1.5"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tracker]]
deps = ["Adapt", "DiffRules", "ForwardDiff", "LinearAlgebra", "LogExpFunctions", "MacroTools", "NNlib", "NaNMath", "Printf", "Random", "Requires", "SpecialFunctions", "Statistics"]
git-tree-sha1 = "0874c1b5de1b5529b776cfeca3ec0acfada97b1b"
uuid = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"
version = "0.2.20"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[deps.Transducers]]
deps = ["Adapt", "ArgCheck", "BangBang", "Baselet", "CompositionsBase", "DefineSingletons", "Distributed", "InitialValues", "Logging", "Markdown", "MicroCollections", "Requires", "Setfield", "SplittablesBase", "Tables"]
git-tree-sha1 = "c76399a3bbe6f5a88faa33c8f8a65aa631d95013"
uuid = "28d57a85-8fef-5791-bfe6-a80928e7c999"
version = "0.4.73"

[[deps.TreeViews]]
deps = ["Test"]
git-tree-sha1 = "8d0d7a3fe2f30d6a7f833a5f19f7c7a5b396eae6"
uuid = "a2a6695c-b41b-5b7d-aed9-dbfdeacea5d7"
version = "0.3.0"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.Turing]]
deps = ["AbstractMCMC", "AdvancedHMC", "AdvancedMH", "AdvancedPS", "AdvancedVI", "BangBang", "Bijectors", "DataStructures", "DiffResults", "Distributions", "DistributionsAD", "DocStringExtensions", "DynamicPPL", "EllipticalSliceSampling", "ForwardDiff", "Libtask", "LinearAlgebra", "MCMCChains", "NamedArrays", "Printf", "Random", "Reexport", "Requires", "SciMLBase", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Tracker", "ZygoteRules"]
git-tree-sha1 = "cba513b222ff87fb55fdccc1a76d26acbc607b0f"
uuid = "fce5fe82-541a-59a6-adf8-730c64b5f9a0"
version = "0.21.6"

[[deps.URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "34db80951901073501137bdbc3d5a8e7bbd06670"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.1.2"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.Widgets]]
deps = ["Colors", "Dates", "Observables", "OrderedCollections"]
git-tree-sha1 = "fcdae142c1cfc7d89de2d11e08721d0f2f86c98a"
uuid = "cc8bc4a8-27d6-5769-a93b-9d913e69aa62"
version = "0.6.6"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

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

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

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

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

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

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.ZygoteRules]]
deps = ["MacroTools"]
git-tree-sha1 = "8c1a8e4dfacb1fd631745552c8db35d0deb09ea0"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.2"

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

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─cbc48ca5-f1a4-4e13-9323-2fd2c43d8612
# ╟─7bb67403-d2ac-4dc9-b2f1-fdea7a795329
# ╟─bdece96a-53f6-41b9-a16a-fabdf24524e0
# ╠═27f62732-c909-11eb-27ee-e373dce148d9
# ╟─c9c8b8c4-c97d-41c7-9eaa-b7a367851c50
# ╟─cd619fe5-ce2a-4631-af7c-047bb990915a
# ╟─44cb1b2b-6ea3-4fd6-a543-c5164121b658
# ╟─5a0ed069-6f99-47ac-bfe5-831ab396d470
# ╟─4ea61753-a2ff-442e-ac91-55060fd52db9
# ╟─4dc10c3b-fbe8-4050-b32c-c056223e1131
# ╟─b093fd81-4011-4594-8b9a-c496a0afe116
# ╟─55e159e6-9712-4bab-beb0-e6d3f5f78671
# ╟─07b757d2-a99d-4a32-9262-4098eeac1bed
# ╠═0d7a483e-4a5e-4319-8e8d-ea983d9c00a4
# ╟─307586b2-1773-47d8-a489-22ee37251532
# ╠═006dcf9c-e474-485c-a34d-e4c3eada6e85
# ╟─cafa53f2-f979-488a-a07c-062d0916fc56
# ╟─350a7204-fb21-45e3-8fb9-64bedc7402f6
# ╟─c44b18bd-9015-4e0c-820a-7e92536a02c3
# ╟─20e897da-f24e-4b66-a585-14775a47bf70
# ╠═fabcb7f5-fd4f-4da9-b736-f46102f1d96a
# ╠═3e0788d1-8d14-4012-9a71-c24abb41ac4b
# ╠═1b3ede8a-4764-40c6-891e-d257583583bd
# ╠═981317c1-6423-446c-a96a-3cd6bc6a88f0
# ╟─53cfa785-f81e-4bc4-8773-723b9626cb19
# ╟─885d11ab-303c-420d-b4e3-be753a4845b7
# ╟─d622f58d-1f3b-4d22-a7f3-80bb1df920f5
# ╠═08ff26a5-b28c-4c69-b574-92baddceb0d6
# ╟─38386c8a-31af-4989-b0ee-c28ce735f9b0
# ╠═45237b0d-a71d-4b8a-863b-bd0fac87a6bc
# ╠═f4219f9d-5cb2-4dd4-89e8-469fb0e6ea76
# ╟─14b838bf-3d86-423d-90d9-f50fb01e4b6e
# ╠═d6d0c8f3-9ffb-4d79-8a23-518e798d1b8e
# ╠═671d83f2-f5d9-4931-be18-f6a4f514433f
# ╠═06292181-9405-4a5f-b30e-29c50ff09251
# ╠═197ff761-422b-4f20-85aa-248ef748051b
# ╠═5201b2c3-9cec-47ee-981a-8af923c06943
# ╠═0b51d75d-0acf-44eb-871e-91f02425e237
# ╟─fc2c6b64-c63a-4afe-9319-e07b79485fee
# ╠═1c434eef-157c-4d10-8454-8caa87138686
# ╠═59b771c7-8c6c-4cf3-8f12-bb5fc2d11e9b
# ╠═bab2207c-0571-49c0-b9dc-912a26e4c9ea
# ╟─0f4873ae-2a04-4030-bbc6-94e29bab0265
# ╠═f17442ec-1138-4c4a-ac11-abe825b6a110
# ╟─5ca48428-3504-4073-bfce-562599b649ad
# ╠═6a974f6a-d6fc-4031-b657-14d13001e0ee
# ╟─d4091772-5a5b-435d-8f53-3bf259dc99cd
# ╟─b08f36be-9fa4-4e18-9378-e29eb8f54d2f
# ╟─91fd4de2-30c8-44fd-8c64-4ee78bd3140f
# ╠═efee4868-b96b-4bcf-9e1e-de93535a4dad
# ╟─f319c97c-c1d8-4bb7-8703-34393b8659ed
# ╟─e2157ddf-3fbc-49d0-9fb9-3b2d644187d8
# ╠═506c9851-eaa9-44de-981d-62614904eb74
# ╟─afaa1e80-c216-4057-9e4a-0d73722363aa
# ╟─09fb0c81-6bee-448e-8938-937fdec06028
# ╠═84850cbd-0e11-4ed4-af64-61a9d2b18b83
# ╟─09abc780-18e7-4a9d-986d-25e52a615e32
# ╠═ddd9acdc-6ea6-4bbe-bf49-ce42aaaf4470
# ╠═a10a99fd-56ca-4808-9921-302498bbf3ba
# ╟─e93b9152-e826-4ab1-bfdb-b3b41aacc0d5
# ╟─68729b68-d91f-491f-afd7-86d0740b94a7
# ╟─5a9ccc92-123c-4f37-83ed-2fd34465610b
# ╟─e9a00a1f-8477-4615-86bd-bb637c7e1829
# ╟─83a06879-4220-4df3-b19a-ddc5c1ed2a26
# ╟─baad490e-227a-41e2-bbb3-4d39f215d250
# ╟─6d1c4f5d-2476-46b6-aaa7-774a525a0332
# ╟─43ff1948-9f8f-4bb7-82ad-24eac7e3bdad
# ╟─464fe066-229a-42b6-9e95-da44a4064461
# ╟─be5073f2-0062-425d-8621-2101e37a3ce9
# ╟─32bd6721-b5cc-4694-b709-ac3e26baf04c
# ╟─302b03e2-102b-4193-b5c7-43f816e4b20b
# ╠═ba7fdd3f-79c8-4759-8055-c577270ec0ae
# ╟─a982ae5f-7f33-4ae3-9981-99b74c0cd36a
# ╠═3dc9f615-cae7-4f2a-83a5-86bd395e2c7b
# ╟─a6b1d276-9519-47f8-8d2f-88a952102e46
# ╠═0ab59e2d-a84d-43cc-8517-92b505988cd7
# ╟─d548bc1a-2e20-4b7f-971b-1b07faaa4c13
# ╟─228e9bf1-cfd8-4285-8b68-43762e1ae8c7
# ╟─23974dfc-7412-4983-9dcc-16e7a3e7dcc4
# ╟─11184212-a2ed-47f5-b123-62fa70636fb7
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
