### A Pluto.jl notebook ###
# v0.17.1

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
    Não deixe de ver os tutoriais de **Estatística Bayesiana com `Turing.jl` e Julia** que eu fiz: <https://storopoli.io/Bayesian-Julia>
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

* Shapiro-Wilk: $P(D \mid \text{amostra é normal})$


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
"""

# ╔═╡ d6d0c8f3-9ffb-4d79-8a23-518e798d1b8e
typeof(chain_coin)

# ╔═╡ 671d83f2-f5d9-4931-be18-f6a4f514433f
summarystats(chain_coin_parallel) # 0.99 < rhat < 1.01

# ╔═╡ 06292181-9405-4a5f-b30e-29c50ff09251
quantile(chain_coin_parallel)

# ╔═╡ 197ff761-422b-4f20-85aa-248ef748051b
quantile(group(chain_coin_parallel, :p))

# ╔═╡ 5201b2c3-9cec-47ee-981a-8af923c06943
summarystats(chain_coin_parallel[:, 1:1, :])

# ╔═╡ fc2c6b64-c63a-4afe-9319-e07b79485fee
md"""
2. **Visualizando Correntes Markov**: Agora temos várias opções. A receita padrão `plot()` renderizará um `traceplot()` lado-a-lado com uma `mixeddensity()`.

    Primeiro, temos que escolher ou visualizar **parâmetros** (`:parameter`) ou **correntes Makov** (`:chain`) com o argumento *keyword* `colordim`.
"""

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
	traceplot(chain_coin_parallel, title="traceplot"),
	meanplot(chain_coin_parallel, title="meanplot"),
	density(chain_coin_parallel, title="density"),
	histogram(chain_coin_parallel, title="histogram"),
	mixeddensity(chain_coin_parallel, title="mixeddensity"),
	autocorplot(chain_coin_parallel, title="autocorplot"),
	dpi=300, size=(840, 600)
)

# ╔═╡ 5ca48428-3504-4073-bfce-562599b649ad
md"""
Também existe a opção de **construir seu próprio gráfico** com `plot()` e o argumento *keyword* `seriestype`:
"""

# ╔═╡ 6a974f6a-d6fc-4031-b657-14d13001e0ee
plot(chain_coin_parallel, seriestype=(:meanplot, :autocorplot), dpi=300)

# ╔═╡ d4091772-5a5b-435d-8f53-3bf259dc99cd
md"""
## Como evitar `for`-loops dentro `@model` (`LazyArrays` e `filldist`)
"""

# ╔═╡ b08f36be-9fa4-4e18-9378-e29eb8f54d2f
md"""
**Regressão Logística**

$$\begin{aligned}
\boldsymbol{y} &\sim \text{Bernoulli}\left( p\right) \\
p &\sim \text{Logística}(\alpha +  \mathbf{X} \boldsymbol{\beta}) \\
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
@benchmark sample($logreg($X_wells, $y_wells), MH(), 100)

# ╔═╡ a10a99fd-56ca-4808-9921-302498bbf3ba
@benchmark sample($logreg_vectorized($X_wells, $y_wells), MH(), 100)

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
   * [`ForwardDiff.jl`](https://github.com/JuliaDiff/ForwardDiff.jl): *backend* padrão de `Turing.jl` atualmente (versão 0.19.x), `:forwarddiff`

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
    τ ~ truncated(Cauchy(0, 2), 0, Inf)     # desvio-padrão das constantes de grupo
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
    τ ~ filldist(truncated(Cauchy(0, 2), 0, Inf), n_gr) # desvio-padrão dos coeficientes de grupo
    βⱼ ~ filldist(Normal(0, 1), predictors, n_gr)       # coeficientes de grupo
    
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
    τₐ ~ truncated(Cauchy(0, 2), 0, Inf)                 # desvio-padrão das constantes de grupo
    τᵦ ~ filldist(truncated(Cauchy(0, 2), 0, Inf), n_gr) # desvio-padrão dos coeficientes de grupo
    αⱼ ~ filldist(Normal(0, τₐ), n_gr)                   # constantes de grupo
    βⱼ ~ filldist(Normal(0, 1), predictors, n_gr)        # coeficientes de grupo
    
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
BenchmarkTools = "~1.2.0"
CSV = "~0.9.10"
DataFrames = "~1.2.2"
Distributions = "~0.25.28"
HTTP = "~0.9.16"
LaTeXStrings = "~1.3.0"
LazyArrays = "~0.22.4"
MCMCChains = "~5.0.1"
Plots = "~1.23.6"
PlutoUI = "~0.7.19"
StatsPlots = "~0.14.28"
Turing = "~0.19.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "485ee0867925449198280d4af84bdb46a2a404d0"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.0.1"

[[AbstractMCMC]]
deps = ["BangBang", "ConsoleProgressMonitor", "Distributed", "Logging", "LoggingExtras", "ProgressLogging", "Random", "StatsBase", "TerminalLoggers", "Transducers"]
git-tree-sha1 = "db0a7ff3fbd987055c43b4e12d2fa30aaae8749c"
uuid = "80f14c24-f653-4e6a-9b94-39d6b0f70001"
version = "3.2.1"

[[AbstractPPL]]
deps = ["AbstractMCMC"]
git-tree-sha1 = "15f34cc635546ac072d03fc2cc10083adb4df680"
uuid = "7a57a42e-76ec-4ea3-a279-07e840d6d9cf"
version = "0.2.0"

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "0bc60e3006ad95b4bb7497698dd7c6d649b9bc06"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.1"

[[AbstractTrees]]
git-tree-sha1 = "03e0550477d86222521d254b741d470ba17ea0b5"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.3.4"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[AdvancedHMC]]
deps = ["AbstractMCMC", "ArgCheck", "DocStringExtensions", "InplaceOps", "LinearAlgebra", "ProgressMeter", "Random", "Requires", "Setfield", "Statistics", "StatsBase", "StatsFuns", "UnPack"]
git-tree-sha1 = "0a655e9a59ee1c8bafc3af18e96d90f980b08600"
uuid = "0bf59076-c3b1-5ca4-86bd-e02cd72cde3d"
version = "0.3.2"

[[AdvancedMH]]
deps = ["AbstractMCMC", "Distributions", "Random", "Requires"]
git-tree-sha1 = "8ad8bfddf8bb627d689ecb91599c349cbf15e971"
uuid = "5b7e9947-ddc0-4b3f-9b55-0d8042f74170"
version = "0.6.6"

[[AdvancedPS]]
deps = ["AbstractMCMC", "Distributions", "Libtask", "Random", "StatsFuns"]
git-tree-sha1 = "06da6c283cf17cf0f97ed2c07c29b6333ee83dc9"
uuid = "576499cb-2369-40b2-a588-c64705576edc"
version = "0.2.4"

[[AdvancedVI]]
deps = ["Bijectors", "Distributions", "DistributionsAD", "DocStringExtensions", "ForwardDiff", "LinearAlgebra", "ProgressMeter", "Random", "Requires", "StatsBase", "StatsFuns", "Tracker"]
git-tree-sha1 = "130d6b17a3a9d420d9a6b37412cae03ffd6a64ff"
uuid = "b5ca4192-6429-45e5-a2d9-87aec30a685c"
version = "0.1.3"

[[ArgCheck]]
git-tree-sha1 = "dedbbb2ddb876f899585c4ec4433265e3017215a"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.1.0"

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
deps = ["Compat", "IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "e527b258413e0c6d4f66ade574744c94edef81f8"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.40"

[[ArrayLayouts]]
deps = ["FillArrays", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "7a92ea1dd16472d18ca1ffcbb7b3cc67d7e78a3f"
uuid = "4c555306-a7a7-4459-81d9-ec55ddd5c99a"
version = "0.7.7"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "d127d5e4d86c7680b20c35d40b503c74b9a39b5e"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.4"

[[BangBang]]
deps = ["Compat", "ConstructionBase", "Future", "InitialValues", "LinearAlgebra", "Requires", "Setfield", "Tables", "ZygoteRules"]
git-tree-sha1 = "0ad226aa72d8671f20d0316e03028f0ba1624307"
uuid = "198e06fe-97b7-11e9-32a5-e1d131e6ad66"
version = "0.3.32"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Baselet]]
git-tree-sha1 = "aebf55e6d7795e02ca500a689d326ac979aaf89e"
uuid = "9718e550-a3fa-408a-8086-8db961cd8217"
version = "0.1.1"

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "61adeb0823084487000600ef8b1c00cc2474cd47"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.2.0"

[[Bijectors]]
deps = ["ArgCheck", "ChainRulesCore", "Compat", "Distributions", "Functors", "IrrationalConstants", "LinearAlgebra", "LogExpFunctions", "MappedArrays", "Random", "Reexport", "Requires", "Roots", "SparseArrays", "Statistics"]
git-tree-sha1 = "369af32fcb9be65d496dc43ad0bb713705d4e859"
uuid = "76274a88-744f-5084-9051-94815aaf08c4"
version = "0.9.11"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "74147e877531d7c172f70b492995bc2b5ca3a843"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.9.10"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f2202b55d816427cd385a9a4f3ffb226bee80f99"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+0"

[[ChainRules]]
deps = ["ChainRulesCore", "Compat", "LinearAlgebra", "Random", "RealDot", "Statistics"]
git-tree-sha1 = "035ef8a5382a614b2d8e3091b6fdbb1c2b050e11"
uuid = "082447d4-558c-5d27-93f4-14fc19e9eca2"
version = "1.12.1"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "f885e7e7c124f8c92650d61b9477b9ac2ee607dd"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.1"

[[ChangesOfVariables]]
deps = ["LinearAlgebra", "Test"]
git-tree-sha1 = "9a1d594397670492219635b35a3d830b04730d62"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.1"

[[Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "75479b7df4167267d75294d14b58244695beb2ac"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.14.2"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

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

[[Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[CommonSolve]]
git-tree-sha1 = "68a0743f578349ada8bc911a5cbd5a2ef6ed6d1f"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.0"

[[CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dce3e3fea680869eaa0b774b2e8343e9ff442313"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.40.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[CompositionsBase]]
git-tree-sha1 = "455419f7e328a1a2493cabc6428d79e951349769"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.1"

[[ConsoleProgressMonitor]]
deps = ["Logging", "ProgressMeter"]
git-tree-sha1 = "3ab7b2136722890b9af903859afcf457fa3059e8"
uuid = "88cd18e8-d9cc-4ea6-8889-5259c0d15c8b"
version = "0.1.2"

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
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d785f42445b63fc86caa08bb9a9351008be9b765"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.2"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

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

[[DefineSingletons]]
git-tree-sha1 = "77b4ca280084423b728662fe040e5ff8819347c5"
uuid = "244e2a9f-e319-4986-a169-4d1fe445cd52"
version = "0.1.1"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "794daf62dce7df839b8ed446fc59c68db4b5182f"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.3.3"

[[DiffResults]]
deps = ["StaticArrays"]
git-tree-sha1 = "c18e98cba888c6c25d1c3b048e4b3380ca956805"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.0.3"

[[DiffRules]]
deps = ["LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "3287dacf67c3652d3fed09f4c12c187ae4dbb89a"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.4.0"

[[Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "837c83e5574582e07662bbbba733964ff7c26b9d"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.6"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "cab6fd4d6a0fca4d7f1dcdc2a130884e6ae242c9"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.28"

[[DistributionsAD]]
deps = ["Adapt", "ChainRules", "ChainRulesCore", "Compat", "DiffRules", "Distributions", "FillArrays", "LinearAlgebra", "NaNMath", "PDMats", "Random", "Requires", "SpecialFunctions", "StaticArrays", "StatsBase", "StatsFuns", "ZygoteRules"]
git-tree-sha1 = "ab3a797864e7d138c03ac7485430f514e3c8245b"
uuid = "ced4e74d-a319-5a8a-b0ac-84af2272839c"
version = "0.6.32"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[DynamicPPL]]
deps = ["AbstractMCMC", "AbstractPPL", "BangBang", "Bijectors", "ChainRulesCore", "Distributions", "MacroTools", "Random", "ZygoteRules"]
git-tree-sha1 = "532397f64ad49472fb60e328369ecd5dedeff02f"
uuid = "366bfd00-2699-11ea-058f-f148b4cae6d8"
version = "0.15.1"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[EllipsisNotation]]
deps = ["ArrayInterface"]
git-tree-sha1 = "9aad812fb7c4c038da7cab5a069f502e6e3ae030"
uuid = "da5c29d0-fa7d-589e-88eb-ea29b0a81949"
version = "1.1.1"

[[EllipticalSliceSampling]]
deps = ["AbstractMCMC", "ArrayInterface", "Distributions", "Random", "Statistics"]
git-tree-sha1 = "254182080498cce7ae4bc863d23bf27c632688f7"
uuid = "cad2338a-1db2-11e9-3401-43bc07c9ede2"
version = "0.4.4"

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
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "463cb335fa22c4ebacfd1faba5fde14edb80d96c"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.5"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[FilePathsBase]]
deps = ["Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "5440c1d26aa29ca9ea848559216e5ee5f16a8627"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.14"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "8756f9935b7ccc9064c6eef0bff0ad643df733a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.7"

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

[[ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "6406b5112809c08b1baa5703ad274e1dded0652f"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.23"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[Functors]]
git-tree-sha1 = "e4768c3b7f597d5a352afa09874d16e3c3f6ead2"
uuid = "d9f16b24-f501-4c13-a1f2-28368ffc5196"
version = "0.2.7"

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "0c603255764a1fa0b61752d2bec14cfbd18f7fe8"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+1"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "30f2b340c2fff8410d89bfcdc9c0a6dd661ac5f7"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.62.1"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "fd75fa3a2080109a2c0ec9864a6e14c60cca3866"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.62.0+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

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
git-tree-sha1 = "14eece7a3308b4d8be910e265c724a6ba51a9798"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.16"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "8a954fed8ac097d5be04921d595f741115c1b2ad"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+0"

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

[[IfElse]]
git-tree-sha1 = "debdd00ffef04665ccbb3e150747a77560e8fad1"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.1"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InitialValues]]
git-tree-sha1 = "7f6a4508b4a6f46db5ccd9799a3fc71ef5cad6e6"
uuid = "22cec73e-a1b8-11e9-2c92-598750a2cf9c"
version = "0.2.11"

[[InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "19cb49649f8c41de7fea32d089d37de917b553da"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.0.1"

[[InplaceOps]]
deps = ["LinearAlgebra", "Test"]
git-tree-sha1 = "50b41d59e7164ab6fda65e71049fee9d890731ff"
uuid = "505f98c9-085e-5b2c-8e89-488be7bf1f34"
version = "0.3.0"

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
git-tree-sha1 = "61aa005707ea2cebf47c8d780da8dc9bc4e0c512"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.4"

[[IntervalSets]]
deps = ["Dates", "EllipsisNotation", "Statistics"]
git-tree-sha1 = "3cc368af3f110a767ac786560045dceddfc16758"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.5.3"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
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
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

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
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a8f4f279b6fa3c3c4f1adadd78a621b13a506bce"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.9"

[[LazyArrays]]
deps = ["ArrayLayouts", "FillArrays", "LinearAlgebra", "MacroTools", "MatrixFactorizations", "SparseArrays", "StaticArrays"]
git-tree-sha1 = "6dfb5dc9426e0cb7e237a71aa78c6b8c3e78a7fc"
uuid = "5078a376-72f3-5289-bfd5-ec5146d43c02"
version = "0.22.4"

[[LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[LeftChildRightSiblingTrees]]
deps = ["AbstractTrees"]
git-tree-sha1 = "71be1eb5ad19cb4f61fa8c73395c0338fd092ae0"
uuid = "1d6d02ad-be62-4b6b-8a6d-2f90e265016e"
version = "0.1.2"

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

[[Libtask]]
deps = ["Libtask_jll", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "90c6ed7f9ac449cddacd80d5c1fca59c97d203e7"
uuid = "6f1fad26-d15e-5dc8-ae53-837a1d7b8c9f"
version = "0.5.3"

[[Libtask_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "901fc8752bbc527a6006a951716d661baa9d54e9"
uuid = "3ae2931a-708c-5973-9c38-ccf7496fb450"
version = "0.4.3+0"

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
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "be9eef9f9d78cecb6f262f3c10da151a6c5ab827"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.5"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "dfeda1c1130990428720de0024d4516b1902ce98"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "0.4.7"

[[MCMCChains]]
deps = ["AbstractMCMC", "AxisArrays", "Compat", "Dates", "Distributions", "Formatting", "IteratorInterfaceExtensions", "KernelDensity", "LinearAlgebra", "MCMCDiagnosticTools", "MLJModelInterface", "NaturalSort", "OrderedCollections", "PrettyTables", "Random", "RecipesBase", "Serialization", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "TableTraits", "Tables"]
git-tree-sha1 = "04c3fd6da28ebd305120ffb05f0a3b8f9baced0a"
uuid = "c7f686f2-ff18-58e9-bc7b-31028e88f75d"
version = "5.0.1"

[[MCMCDiagnosticTools]]
deps = ["AbstractFFTs", "DataAPI", "Distributions", "LinearAlgebra", "MLJModelInterface", "Random", "SpecialFunctions", "Statistics", "StatsBase", "Tables"]
git-tree-sha1 = "f3f0c23f0ebe11db62ff1e81412919cf7739053d"
uuid = "be115224-59cd-429b-ad48-344e309966f0"
version = "0.1.1"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5455aef09b40e5020e1520f551fa3135040d4ed0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+2"

[[MLJModelInterface]]
deps = ["Random", "ScientificTypesBase", "StatisticalTraits"]
git-tree-sha1 = "0174e9d180b0cae1f8fe7976350ad52f0e70e0d8"
uuid = "e80e1ace-859a-464e-9ed9-23947d8ae3ea"
version = "1.3.3"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MatrixFactorizations]]
deps = ["ArrayLayouts", "LinearAlgebra", "Printf", "Random"]
git-tree-sha1 = "1a0358d0283b84c3ccf9537843e3583c3b896c59"
uuid = "a3b82374-2e81-5b9e-98ce-41277c0e4c87"
version = "0.8.5"

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

[[MicroCollections]]
deps = ["BangBang", "Setfield"]
git-tree-sha1 = "4f65bdbbe93475f6ff9ea6969b21532f88d359be"
uuid = "128add7d-3638-4c79-886c-908ea0c25c34"
version = "0.1.1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[MultivariateStats]]
deps = ["Arpack", "LinearAlgebra", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "8d958ff1854b166003238fe191ec34b9d592860a"
uuid = "6f286f6a-111f-5878-ab1e-185364afe411"
version = "0.8.0"

[[NNlib]]
deps = ["Adapt", "ChainRulesCore", "Compat", "LinearAlgebra", "Pkg", "Requires", "Statistics"]
git-tree-sha1 = "2eb305b13eaed91d7da14269bf17ce6664bfee3d"
uuid = "872c559c-99b0-510c-b3b7-b6c96a88d5cd"
version = "0.7.31"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NamedArrays]]
deps = ["Combinatorics", "DataStructures", "DelimitedFiles", "InvertedIndices", "LinearAlgebra", "Random", "Requires", "SparseArrays", "Statistics"]
git-tree-sha1 = "2fd5787125d1a93fbe30961bd841707b8a80d75b"
uuid = "86f7a689-2022-50b4-a561-43c23ac3c673"
version = "0.9.6"

[[NaturalSort]]
git-tree-sha1 = "eda490d06b9f7c00752ee81cfa451efe55521e21"
uuid = "c020b1a1-e9b0-503a-9c33-f039bfc54a85"
version = "1.0.0"

[[NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "16baacfdc8758bc374882566c9187e785e85c2f0"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.9"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "043017e0bdeff61cfbb7afeb558ab29536bbb5ed"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.8"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

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
git-tree-sha1 = "c8b8775b2f242c80ea85c83714c64ecfa3c53355"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.3"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "ae4bbcadb2906ccc085cf52ac286dc1377dceccc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.2"

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
git-tree-sha1 = "b084324b4af5a438cd63619fd006614b3b20b87b"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.15"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun"]
git-tree-sha1 = "0d185e8c33401084cab546a756b387b15f76720c"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.23.6"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "e071adf21e165ea0d904b595544a8e514c8bb42c"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.19"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a193d6ad9c45ada72c14b731a318bedd3c2f00cf"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.3.0"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "d940010be611ee9d67064fe559edbb305f8cc0eb"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.2.3"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[ProgressLogging]]
deps = ["Logging", "SHA", "UUIDs"]
git-tree-sha1 = "80d919dee55b9c50e8d9e2da5eeafff3fe58b539"
uuid = "33c8b6b6-d38a-422a-b730-caa89a2f386c"
version = "0.1.4"

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
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[Ratios]]
deps = ["Requires"]
git-tree-sha1 = "01d341f502250e81f6fec0afe662aa861392a3aa"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.2"

[[RealDot]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9f0a1b71baaf7650f4fa8a1d168c7fb6ee41f0c9"
uuid = "c1ae055f-0cd5-4b69-90a6-9a35b1a98df9"
version = "0.1.0"

[[RecipesBase]]
git-tree-sha1 = "44a75aa7a527910ee3d1751d1f0e4148698add9e"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.2"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[RecursiveArrayTools]]
deps = ["ArrayInterface", "ChainRulesCore", "DocStringExtensions", "FillArrays", "LinearAlgebra", "RecipesBase", "Requires", "StaticArrays", "Statistics", "ZygoteRules"]
git-tree-sha1 = "c944fa4adbb47be43376359811c0a14757bdc8a8"
uuid = "731186ca-8d62-57ce-b412-fbd966d074cd"
version = "2.20.0"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

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

[[Roots]]
deps = ["CommonSolve", "Printf", "Setfield"]
git-tree-sha1 = "4c40dc61b51054bdb93536400420d73fdca6865e"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "1.3.7"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[SciMLBase]]
deps = ["ArrayInterface", "CommonSolve", "ConstructionBase", "Distributed", "DocStringExtensions", "IteratorInterfaceExtensions", "LinearAlgebra", "Logging", "RecipesBase", "RecursiveArrayTools", "StaticArrays", "Statistics", "Tables", "TreeViews"]
git-tree-sha1 = "ad2c7f08e332cc3bb05d33026b71fa0ef66c009a"
uuid = "0bca4576-84f4-4d90-8ffe-ffa030f20462"
version = "1.19.4"

[[ScientificTypesBase]]
git-tree-sha1 = "185e373beaf6b381c1e7151ce2c2a722351d6637"
uuid = "30f210dd-8aff-4c5f-94ba-8e64358c1161"
version = "2.3.0"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "f45b34656397a1f6e729901dc9ef679610bd12b5"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.8"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "Requires"]
git-tree-sha1 = "def0718ddbabeb5476e51e5a43609bee889f285d"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "0.8.0"

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
git-tree-sha1 = "f0bccf98e16759818ffc5d97ac3ebf87eb950150"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.8.1"

[[SplittablesBase]]
deps = ["Setfield", "Test"]
git-tree-sha1 = "39c9f91521de844bad65049efd4f9223e7ed43f9"
uuid = "171d559e-b47b-412a-8079-5efa626c420e"
version = "0.1.14"

[[Static]]
deps = ["IfElse"]
git-tree-sha1 = "e7bc80dc93f50857a5d1e3c8121495852f407e6a"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.4.0"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[StatisticalTraits]]
deps = ["ScientificTypesBase"]
git-tree-sha1 = "730732cae4d3135e2f2182bd47f8d8b795ea4439"
uuid = "64bff920-2084-43da-a3e6-9bb72801c0c9"
version = "2.1.0"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "eb35dcc66558b2dda84079b9a1be17557d32091a"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.12"

[[StatsFuns]]
deps = ["ChainRulesCore", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "385ab64e64e79f0cd7cfcf897169b91ebbb2d6c8"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.13"

[[StatsPlots]]
deps = ["Clustering", "DataStructures", "DataValues", "Distributions", "Interpolations", "KernelDensity", "LinearAlgebra", "MultivariateStats", "Observables", "Plots", "RecipesBase", "RecipesPipeline", "Reexport", "StatsBase", "TableOperations", "Tables", "Widgets"]
git-tree-sha1 = "eb007bb78d8a46ab98cd14188e3cec139a4476cf"
uuid = "f3b207a7-027a-5e70-b257-86293d7955fd"
version = "0.14.28"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableOperations]]
deps = ["SentinelArrays", "Tables", "Test"]
git-tree-sha1 = "e383c87cf2a1dc41fa30c093b2a19877c83e1bc1"
uuid = "ab02a1b2-a7df-11e8-156e-fb1833f50b87"
version = "1.2.0"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[TerminalLoggers]]
deps = ["LeftChildRightSiblingTrees", "Logging", "Markdown", "Printf", "ProgressLogging", "UUIDs"]
git-tree-sha1 = "62846a48a6cd70e63aa29944b8c4ef704360d72f"
uuid = "5d786b92-1e48-4d6f-9151-6b4477ca9bed"
version = "0.1.5"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[Tracker]]
deps = ["Adapt", "DiffRules", "ForwardDiff", "LinearAlgebra", "MacroTools", "NNlib", "NaNMath", "Printf", "Random", "Requires", "SpecialFunctions", "Statistics"]
git-tree-sha1 = "bf4adf36062afc921f251af4db58f06235504eff"
uuid = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"
version = "0.2.16"

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[Transducers]]
deps = ["Adapt", "ArgCheck", "BangBang", "Baselet", "CompositionsBase", "DefineSingletons", "Distributed", "InitialValues", "Logging", "Markdown", "MicroCollections", "Requires", "Setfield", "SplittablesBase", "Tables"]
git-tree-sha1 = "bccb153150744d476a6a8d4facf5299325d5a442"
uuid = "28d57a85-8fef-5791-bfe6-a80928e7c999"
version = "0.4.67"

[[TreeViews]]
deps = ["Test"]
git-tree-sha1 = "8d0d7a3fe2f30d6a7f833a5f19f7c7a5b396eae6"
uuid = "a2a6695c-b41b-5b7d-aed9-dbfdeacea5d7"
version = "0.3.0"

[[Turing]]
deps = ["AbstractMCMC", "AdvancedHMC", "AdvancedMH", "AdvancedPS", "AdvancedVI", "BangBang", "Bijectors", "DataStructures", "Distributions", "DistributionsAD", "DocStringExtensions", "DynamicPPL", "EllipticalSliceSampling", "ForwardDiff", "Libtask", "LinearAlgebra", "MCMCChains", "NamedArrays", "Printf", "Random", "Reexport", "Requires", "SciMLBase", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Tracker", "ZygoteRules"]
git-tree-sha1 = "c40eac01a46b8efc8af9481982a618d6e54b506d"
uuid = "fce5fe82-541a-59a6-adf8-730c64b5f9a0"
version = "0.19.0"

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
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "c69f9da3ff2f4f02e811c3323c22e5dfcb584cfa"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.1"

[[Widgets]]
deps = ["Colors", "Dates", "Observables", "OrderedCollections"]
git-tree-sha1 = "80661f59d28714632132c73779f8becc19a113f2"
uuid = "cc8bc4a8-27d6-5769-a93b-9d913e69aa62"
version = "0.6.4"

[[WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

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

[[ZygoteRules]]
deps = ["MacroTools"]
git-tree-sha1 = "8c1a8e4dfacb1fd631745552c8db35d0deb09ea0"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.2"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

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
# ╟─fc2c6b64-c63a-4afe-9319-e07b79485fee
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
