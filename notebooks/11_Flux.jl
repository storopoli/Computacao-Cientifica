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
	
	using Flux
	using CUDA
	CUDA.allowscalar(false) # melhora desempenho de CUDA
	using MLDatasets
	
	# Visualizações
	using ForwardDiff
	using CairoMakie
	using WGLMakie
	using JSServe
	
	# Seed
	using Random:seed!
	seed!(123);
end

# ╔═╡ 6094b975-d610-4c4a-9318-858c443370ee
using Flux: onehot, onehotbatch

# ╔═╡ 1de34946-f040-4908-bf74-57d402c2b8c2
using Flux.Data: DataLoader

# ╔═╡ 42806fb7-1f4b-4a1f-b595-f5be174ec179
using Flux.Losses: logitcrossentropy

# ╔═╡ c47cb021-19f0-46d0-b2af-1f9f70e2d6e1
using Flux: throttle

# ╔═╡ af07c7c9-dd40-4fd3-86bc-de1a3fdef750
using Flux: @epochs

# ╔═╡ 76b33449-cf47-48b3-ad1e-bc3a9af25b8e
using Statistics: mean

# ╔═╡ d106f13c-cf0c-420c-85e9-21c7ee4cfc73
using Flux: onecold

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
# Deep Learning com `Flux.jl`
"""

# ╔═╡ 3cf20976-2d7c-4436-bcb1-00c4f3db8985
Resource("https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg", :width => 120, :display => "inline")

# ╔═╡ b50112c8-d571-4b48-9acc-19c5a349edce
JSServe.Page(exportable=true)

# ╔═╡ 919df339-43d3-40a6-97a2-4ef77e3a562b
md"""
!!! danger "⚠️ Disciplina Ferramental"
	**Esta disciplina é uma disciplina ferramental!**

	Portanto, se você não sabe o que é uma rede neural, pegue um livro-texto e estude ou pergunte pro seu orientador.

	**Sugestão de fonte**:
	
	Goodfellow, I., Bengio, Y., & Courville, A. (2016). Deep Learning. MIT Press. [(link)](https://www.deeplearningbook.org/)

"""

# ╔═╡ a4eda727-2d82-4100-bc74-bec00a4120e0
md"""
!!! tip "💡 3blue1brown Neural Networks"
    Os vídeos do [3blue1brown](https://www.youtube.com/c/3blue1brown) são excelentes. 
	Inclusive ele tem uma **playlist sobre redes neurais**.
"""

# ╔═╡ 2bbe47e5-2742-493c-9829-f66a026fa840
HTML("
<style>.embed-container { position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; } .embed-container iframe, .embed-container object, .embed-container embed { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }</style><div class='embed-container'><iframe src='https://www.youtube.com/embed/aircAruvnKk' frameborder='0' allowfullscreen></iframe></div>
")

# ╔═╡ 926b21c0-04d6-4d25-be7b-10d421fe92b8
md"""
# O que é uma rede neural?

Redes neurais artificiais (RNAs) são modelos computacionais inspirados pelo sistema nervoso central (em particular o cérebro) que são capazes de realizar o aprendizado de máquina bem como o reconhecimento de padrões.

Redes neurais artificiais geralmente são apresentadas como **sistemas de "neurônios interconectados, que podem computar valores de entradas"**, simulando o comportamento de redes neurais biológicas
"""

# ╔═╡ 61fd08c4-17dd-4f48-bb44-b90395ed8146
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/redes_neurais.jpeg?raw=true")

# ╔═╡ cf5581e9-1c68-4798-af3c-dd480a2ec290
md"""
# Como a rede neural aprende?

Em cada neurônio há uma função de ativação (*activation function*) que processa uma combinação linear entre inputs e pesos sinápticos, gerando assim um sinal de saída.

A informação flui da *input layer* para as *hidden layers* e por fim para a *output layer*. Nesse fluxo os inputs de dados da *input layer* são alimentados para os neurônios das *hidden layers* que por fim alimentam o neurônio final da *output layer*.

A primeira passada de informação (propagação) pela rede é geralmente feita com parâmetros aleatórios para as funções de ativação dos neurônios.

Ao realizar a propagação, chamada de *feed forward*, temos sinais de saídas nos neurônios da output layer. 

No fim da propagação, a função custo (uma métrica de erro) é calculada e o modelo então ajusta os parâmetros dos neurônios na direção de um menor custo (por meio do gradiente - derivada multivariada).

Assim uma nova propagação é gerada e a numa nova função custo e calculada. Assim como é realizado a atualização dos parâmetros dos neurônios.

O nome desse algoritmo é **Retro-propagação** (*Backpropagation*). E cada vez que ele é executado denomina-se como época (*epoch*). E quandos as épocas estabelecidas se encerram, a rede neural encerra o seu treinamento/aprendizagem.
"""

# ╔═╡ 2674b100-0da8-4503-b868-2e9429b3e099
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/backpropagation.gif?raw=true")

# ╔═╡ 62e019b3-9190-4dcf-8bf3-115367585619
md"""
# Funções de Ativação (_Activation Functions_)

| **Sigmoid**                                                  | **Tanh**                                                     | **ReLU**                                                     | **Leaky ReLU**                                               |
| ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| $g(z)=\frac{1}{1+e^{-z}}$                                    | $g(z)=\frac{e^{z}-e^{-z}}{e^{z}+e^{-z}}$                     | $g(z)=\max (0, z)$                                           | $\begin{array}{c}{g(z)=\max (\epsilon z, z)} \\ {\text { com } \epsilon \ll 1}\end{array}$ |
| $(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/sigmoid.png?raw=true", :width => 100)) | $(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/tanh.png?raw=true", :width => 100)) | $(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/relu.png?raw=true", :width => 100)) | $(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/leaky-relu.png?raw=true", :width => 100)) |
"""

# ╔═╡ acb6dd37-b6eb-4226-88a2-6bece14c9eaf
md"""
# Gradiente Descendente (_Gradient Descent_)

O [método do **gradiente descendente**](https://pt.wikipedia.org/wiki/M%C3%A9todo_do_gradiente) é um **método numérico usado em otimização**. Para encontrar um mínimo (local) de uma função usa-se um esquema **iterativo**, onde em cada passo se toma a **direção (negativa) do gradiente**, que corresponde à direção de declive máximo.

Um algoritmo em pseudo-código: $\arg \min$

1. Define-se o vector inicial $\mathbf{x}_0$ e a taxa de aprendizagem $\eta$.
2. Para cada $i \in 1, \ldots, n$:
$$\mathbf{x}_{i+1} = \mathbf{x}_{i} - \eta \nabla F(\mathbf{x}_n)$$
"""

# ╔═╡ b45ceedd-31b6-4871-b2bf-351114d3a24c
let
	WGLMakie.activate!()
	function descend(
    Δ::Real,
    x0::Real,
    y0::Real;
    numsteps = 10
    )::Array{Float64, 2}

    coords = zeros(numsteps, 2)

    coords[1, 1] = x0

    coords[1, 2] = y0

    for i ∈ 2:numsteps

        coords[i, :] = coords[i-1, :] + Δ*∇f(coords[i-1, :])

        end

    coords
    end

	f(x::Real, y::Real)  = 2/(x^2 - 4*x + y^2 + 5) + 3/(x^2 - 4*y + y^2 + 6)

	f(x::Array{T, 1} where T <: Real)  = f(x[1], x[2])

	∇f(x::Real, y::Real) = ForwardDiff.gradient(f, [x, y])
	∇f(x::Array{<:AbstractFloat, 1}) = ForwardDiff.gradient(f, x)

	fig = Figure(resolution=(800, 800))

	# 2-D
	ax1 = Axis(fig[1, 1])
	# 3-D
	ax2 = Axis3(fig[2, 1])

	# different plots you can see of f and ∇f
	xa = LinRange(-5, 5, 500)
	ya = LinRange(-5, 5, 500)
	za = .-[f(x, y) for x ∈ xa, y ∈ ya]
	# ∇za = [∇f(x, y) for x ∈ xa, y ∈ ya]

	plotobj2d = contour3d!(ax1, xa, ya, za; shading=false, linewidth=3, levels=20)
	plotobj3d = surface!(ax2, xa, ya, za; shading=false)
	# fsurf = surface!(ax1, xa, ya, za; shading = false)
	# ∇fsurf = surface!(ax1, xa, ya, ∇za; shading = false)
	# fcont = contour!(ax1, xa, ya, za; levels = 20, linewidth = 3)
	# ∇fcont = contour!(ax1, xa, ya, ∇za; levels = 20, linewidth = 3)
	# fheat = heatmap!(ax1, xa, ya, za)
	# ∇fheat = heatmap!(ax1, xa, ya, ∇za)
	# fcont3 = contour3d!(ax1, xa, ya, za; levels = 20, linewidth = 3)
	# ∇fcont3 = contour3d!(ax1, xa, ya, ∇za; levels = 20, linewidth = 3)

	slider_η = labelslider!(
		fig,
		"η",
		0.01:0.001:2.0;
		width = 350,
		tellwidth=false)

	# slider_iter = labelslider!(
	#     fig,
	#     "Iterações",
	#     10:10:100)

	fig[3, 1]= slider_η.layout
	# fig[4, 1]= slider_iter.layout
	x0 = Observable(0.0)
	y0 = Observable(0.0)
	coords = @lift(descend($(slider_η.slider.value), $x0, $y0))
	xs = lift(x -> x[:, 1], coords)
	ys = lift(x -> x[:, 2], coords)
	zs = lift((x, y) -> .-f.(x, y), xs, ys) # for three dimensional plots
	scatterlines!(ax1, xs, ys, zs, color = :red, linewidth = 5)
	scatterlines!(ax2, xs, ys, zs, color = :red, linewidth = 5)
	hidedecorations!(ax1)
	hidedecorations!(ax2)
	hidespines!(ax1)
	hidespines!(ax2)
	
	fig
end

# ╔═╡ 65ddfed1-2ae1-4df8-9948-a2d98d7c8a28
md"""
!!! tip "💡"
    Se a imagem interativa acima estiver quebrada provavelmente você vai ter que rodar esse notebook no seu computador ou no `binder`.

	Mas pelo menos te dou um *free sample* estático abaixo.
"""

# ╔═╡ d6250574-fa76-4e7e-b3de-cb74b851162e
let
	CairoMakie.activate!()
	function descend(
    Δ::Real,
    x0::Real,
    y0::Real;
    numsteps = 10
    )::Array{Float64, 2}

    coords = zeros(numsteps, 2)

    coords[1, 1] = x0

    coords[1, 2] = y0

    for i ∈ 2:numsteps

        coords[i, :] = coords[i-1, :] + Δ*∇f(coords[i-1, :])

        end

    coords
    end

	f(x::Real, y::Real)  = 2/(x^2 - 4*x + y^2 + 5) + 3/(x^2 - 4*y + y^2 + 6)

	f(x::Array{T, 1} where T <: Real)  = f(x[1], x[2])

	∇f(x::Real, y::Real) = ForwardDiff.gradient(f, [x, y])
	∇f(x::Array{<:AbstractFloat, 1}) = ForwardDiff.gradient(f, x)

	fig = Figure(resolution=(800, 800))

	# 2-D
	ax1 = Axis(fig[1, 1])
	# 3-D
	ax2 = Axis3(fig[2, 1])

	# different plots you can see of f and ∇f
	xa = LinRange(-5, 5, 500)
	ya = LinRange(-5, 5, 500)
	za = .-[f(x, y) for x ∈ xa, y ∈ ya]
	# ∇za = [∇f(x, y) for x ∈ xa, y ∈ ya]

	plotobj2d = contour3d!(ax1, xa, ya, za; shading=false, linewidth=3, levels=20)
	plotobj3d = surface!(ax2, xa, ya, za; shading=false)
	# fsurf = surface!(ax1, xa, ya, za; shading = false)
	# ∇fsurf = surface!(ax1, xa, ya, ∇za; shading = false)
	# fcont = contour!(ax1, xa, ya, za; levels = 20, linewidth = 3)
	# ∇fcont = contour!(ax1, xa, ya, ∇za; levels = 20, linewidth = 3)
	# fheat = heatmap!(ax1, xa, ya, za)
	# ∇fheat = heatmap!(ax1, xa, ya, ∇za)
	# fcont3 = contour3d!(ax1, xa, ya, za; levels = 20, linewidth = 3)
	# ∇fcont3 = contour3d!(ax1, xa, ya, ∇za; levels = 20, linewidth = 3)

	
	x0 = 0.0
	y0 = 0.0
	coords = descend(0.6, x0, y0)
	xs = coords[:, 1]
	ys = coords[:, 2]
	zs = .-f.(xs, ys) # for three dimensional plots
	scatterlines!(ax1, xs, ys, zs, color = :red, linewidth = 5)
	scatterlines!(ax2, xs, ys, zs, color = :red, linewidth = 5)
	hidedecorations!(ax1)
	hidedecorations!(ax2)
	hidespines!(ax1)
	hidespines!(ax2)
	
	fig
end

# ╔═╡ 461d0516-6e5e-40f6-b54c-68c16e6371ab
md"""
# Algoritmos de Otimização (_Optimization_)

A seguir alguns **algoritmos de otimização**, junto com as referências e o seu tipo em `Flux.jl`:

* **SGD**: _**S**tochastic **G**radient **D**escent_ -- `Descent`


* **SGD com Momento**: SGD com Momento usando a derivada (ou gradiente) do ponto atual --- `Momentum`


* **SGD com Momento Nesterov**: SGD com Momento mas  usa a derivada (ou o gradiente) parcial do ponto seguinte (Nesterov, 1983) -- `Nesterov`


* **RMSprop**: SGD com taxa de aprendizagem adaptativa  (Hinton, Srivastava & Swersky, 2012) -- `RMSProp`


* **AdaGrad**: SGD com taxa de aprendizagem adaptativa (Duchi, Hazan, & Yoram, 2011) --  `AdaGrad`


* **Adam**: SGD com taxa de aprendizagem adaptativa e momento (Kingma, Diederick & Jimmy, 2014) --- `ADAM`

> Duchi, John, Elad Hazan, and Yoram Singer. "Adaptive subgradient methods for online learning and stochastic optimization." Journal of machine learning research 12.7 (2011).
> 
> Hinton, Geoffrey, Nitish Srivastava, and Kevin Swersky. “Neural Networks for Machine Learning Lecture 6a Overview of Mini--Batch Gradient Descent,” 2012.
>
> Kingma, Diederik P., and Jimmy Ba. “Adam: A Method for Stochastic Optimization,” December 22, 2014. https://arxiv.org/abs/1412.6980.
>
> Nesterov, Y. A method of solving a convex programming problem with convergence rate O(1/sqr(k)). _Soviet Mathematics Doklady_, 27:372–376, 1983.
"""

# ╔═╡ 25b44378-069d-48e6-8ef8-74642e50d201
md"""
!!! tip "💡 Algoritmos de Otimização"
    Note que  temos uma PORRADA de algoritmos propostos pela literatura.

	Veja a seção [_Optimization_ do paperswithcode.com](https://paperswithcode.com/methods/category/optimization) para uma listagem bem mais completa.
"""

# ╔═╡ 11ad6e43-e9d4-4812-b2a7-af2c57414a25
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/comparacao_otimizadores.gif?raw=true")

# ╔═╡ 98d633ea-151e-4806-b879-36d258ea95f8
md"""
# Funções Custo (_Cost Functions_)

As funções custos se dividem em dois tipos:

1. Funções Custo de **Classificação**
2. Funções Custo de **Regressão**
"""

# ╔═╡ 5949000c-bb03-4799-8af7-9c056771c3c4
md"""
## Funções Custo -- Regressão

* _**M**ean **A**bsolute **E**rror_:

$$\frac{1}{n} \sum^n_{i=1} | y_i - \widehat{y}_i |$$


* _**M**ean **S**quared **E**rror_:

$$\frac{1}{n} \sum^n_{i=1} (y_i - \widehat{y}_i)^2$$
"""

# ╔═╡ 8ed693b9-e24f-4d1e-83ac-b154969b264c
md"""
##  Funções Custo -- Classificação

Na verdade só tem uma bem usada que é **entropia cruzada (_Cross Entropy_)**.

Veja o caso da **entropia cruzada binária**:

$$\begin{cases}
-\log (\widehat{p}) & \text{ se } y=1 \\
-\log (1 - \widehat{p}) & \text{ se } y=0
\end{cases}$$

Onde $\widehat{p}$ é a probabilidade de $y$ ser rótulo binário positivo ($1$). Para todo dataset ficaria:

$$\frac{1}{n} \sum^n_{i=1}  - \Big( y_i \log (\widehat{p}) + (1-y_i) \log (1 - \widehat{p}) \Big)$$

Faz sentido porque:

*  $- \log(\widehat{p})$ se torna grande quando $\widehat{p}$ se aproxima de 0 -- Erro vai ser grande quando o modelo prevê $\widehat{p} \approx 0$ mas $y = 1$
*  $- \log(1 - \widehat{p})$ se torna grande quando $1- \widehat{p}$ se aproxima de 0 - Erro vai ser grande quando o modelo prevê $\widehat{p} \approx 1$ mas $y = 0$
"""

# ╔═╡ 4a118fbe-74e4-402b-af0d-71f1538cf912
let
	f = Figure(resolution = (900, 600))
	xs = 0.001..0.999
	ax1 = f[1, 1] = Axis(f, title="Se y=1", xlabel="p̂", ylabel="Erro")
	line1 = lines!(f[1, 1], xs, x -> -log(x); color=:blue)
	ax2, line2 = lines(f[1, 2], xs, x -> -log(1-x);
		color=:blue,
		axis=(;title="Se y=0", xlabel="p̂"))
	linkaxes!(ax1, ax2)
	f
end

# ╔═╡ 81620941-c4a0-4560-a77f-deb4b5c78fe1
md"""
# Tamanho de Batch (_Batch Size_)

**Tamanho do Batch de dados que passa por vez pela rede neural antes da atualização dos parâmetros pelo _backpropagation_**. Tamanhos grandes resultam em instabilidade no treinamento. Geralmente usam-se potências de $2$ $(2,4,8,16,\dots, 2^n)$.

Em Abril de 2018, Yann LeCun, um dos principais pesquisadores sobre redes neurais e ganhador do "nobel" da computação (Prêmio Turing) [twittou](https://twitter.com/ylecun/status/989610208497360896) em resposta à Masters & Luschi (2018) que mostrava diversos contextos de *batch size*:

>"Friends don't let friends use mini-batches larger than 32"

Então 32 é um valor empiricamente verificado que dá estabilidade ao treinamento.

> Dominic Masters and Carlo Luschi. "Revisiting small batch training for deep neural networks." _arXiv preprint arXiv:1804.07612_ (2018).
"""

# ╔═╡ f90b73ba-913e-4bec-874a-95cf82636760
md"""
# _Dropout_

_Dropout_ (Srivastava et al. 2014) é uma **medida de regularização na qual evita-se overfitting proposta por Hinton em 2012**. *Dropout* é um algoritmo que especifica que a cada iteração de época do treino os neurônios possuem uma probabilidade de serem removidos (não utilizados) para a aprendizagem.

Geralmente a probabilidade ideal fica em torno de 20% ($0.2$).

> Srivastava, Nitish, Geoffrey Hinton, Alex Krizhevsky, Ilya Sutskever, and Ruslan Salakhutdinov. “Dropout: A Simple Way to Prevent Neural Networks from Overfitting.” _Journal of Machine Learning Research 15_, no. 56 (2014): 1929–58.
"""

# ╔═╡ 27de55a7-ea5a-42b9-b8f7-312b33e3c21a
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/dropout.gif?raw=true")

# ╔═╡ 4136a014-91d1-4e61-8719-08068cf08626
md"""
# Convoluções

Em matemática **[convolução](https://pt.wikipedia.org/wiki/Convolu%C3%A7%C3%A3o) é um operador linear** que, a partir de **duas funções dadas**, **resulta numa terceira que mede a soma do produto dessas funções ao longo da região** subentendida pela superposição delas em função do deslocamento existente entre elas.

A notação para a convolução de $f$ e $g$ é $f*g$. Ela é definida como a integral do produto de uma das funções por uma cópia deslocada e invertida da outra; a função resultante $h$ depende do valor do deslocamento. Se $x$ for a variável independente e $u$, o deslocamento, a fórmula pode ser escrita como:

$$(f * g) (x) = h(x) = \int_{-\infty}^{\infty} f(u) \cdot g(x-u) du$$

Existe ainda uma definição de **convolução para funções de domínio discreto**, dada por

$$(f * g) (k) = h(k)= \sum_{j=0}^{k} f(j) \cdot g(k-j)$$
"""

# ╔═╡ 00aac365-a747-456d-b999-a90e250396a6
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/convolution.gif?raw=true")

# ╔═╡ 5fc43fe1-2807-4457-accf-2afbaee77282
md"""
## Convoluções em Redes Neurais

As redes neurais convolucionais se distinguem de outras redes neurais por seu desempenho superior com dados de imagem, voz ou áudio. Elas têm três tipos principais de camadas, que são:

* Camada Convolucional
* Camada de _Pooling_
* Camada Totalmente Conectada (_**f**ully **c**onnected_ -- FC)
"""

# ╔═╡ 160cf645-d716-43aa-8b7c-0a764c4af623
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/deeplearning_convolutions.gif?raw=true")

# ╔═╡ be9b6acb-670d-4d14-abd7-c80c2695f56f
md"""
!!! tip "💡 Por que Redes Neurais Convolucionais?"
    As Redes Neurais Convolucionais têm a capacidade de **extrair automaticamente características dos padrões a serem aprendidos** (por meio das camadas de convolução), tarefa que necessariamente tem que ser implementada separadamente quando se emprega uma Rede Neural padrão ("vanilla", _**M**ulti**l**ayer **P**erceptron_ -- MLP) ou um outro classificador convencional (por exemplo, _**S**upport **V**ector **M**achine_ -- SVM)
"""

# ╔═╡ fddc4e3b-1083-48df-b88b-881db060a754
md"""
# [`Flux.jl`](https://fluxml.ai/)

[`Flux.jl`](https://fluxml.ai/) é o stack 100% Julia para diferenciação automática (_**A**uto**D**iff_) e computação na GPU.

O ecosistema de `Flux.jl` é enorme. Vou listar alguns pacotes/repositórios interessantes:

* [`model-zoo`](https://github.com/FluxML/model-zoo): Zoológico de modelos
* [`Optimizers.jl`](https://github.com/FluxML/Optimisers.jl): Algoritmos de otimização e suporte para criação de novos algoritmos
* [`Metrics.jl`](https://github.com/AdarshKumar712/Metrics.jl): Métricas diversas para machine learning e deep learning
* [`MLDatasets.jl`](https://github.com/JuliaML/MLDatasets.jl): Datasets famosos como MNIST, CIFAR10 etc.
* [`Transformers.jl`](https://github.com/chengchingwen/Transformers.jl): Transformers e NLP em `Flux.jl`
* [`HuggingFaceApi.jl`](https://github.com/chengchingwen/HuggingFaceApi.jl): API do HuggingFace para Julia
* [`Metalhead.jl`](https://github.com/FluxML/Metalhead.jl): Modelos de Visão Computacional
* [`Flux3D.jl`](https://github.com/FluxML/Flux3D.jl): Visão computacional 3D.
* [`Augmentor.jl`](https://github.com/Evizero/Augmentor.jl): _Image Augmentation_.
* [`FastAI.jl`](https://github.com/FluxML/FastAI.jl): Melhores práticas de deep learning inspirados em [`fastai`](https://github.com/fastai/fastai)
* [`GeometricFlux.jl`](https://github.com/FluxML/GeometricFlux.jl): Deep learning geométrico
* [`MLJFlux.jl`](https://github.com/FluxML/MLJFlux.jl): Interface de `Flux.jl` com `MLJ.jl`
* [`GraphNeuralNetworks.jl`](https://github.com/CarloLucibello/GraphNeuralNetworks.jl): Arquiteturas e camadas de redes neurais em grafos usando `Flux.jl`
* [`GraphMLDatasets.jl`](https://github.com/yuehhua/GraphMLDatasets.jl): Datasets famosos de machine learning em grafos
* [`EasyML.jl`](https://github.com/OML-NPA/EasyML.jl): Criando redes neurais com `Flux.jl` de maneira fácil via GUI
* [`Gym.jl`](https://github.com/FluxML/Gym.jl): Ambientes para aprendizagem de reforço
* [`AlphaZero.jl`](https://github.com/jonathan-laurent/AlphaZero.jl): Implementação do AlphaZero de Deep Mind em Julia.
* [`NeuralVerification.jl`](https://github.com/sisl/NeuralVerification.jl): Verificação de redes neurais contra ataques adversariais
* [`InvertibleNetworks.jl`](https://github.com/slimgroup/InvertibleNetworks.jl): Framework para inverter redes neurais (já que são aproximadores universais de funções)
* [`TensorBoardLogger.jl`](https://github.com/JuliaLogging/TensorBoardLogger.jl): API de [_TensorBoard_](https://www.tensorflow.org/tensorboard/) do [TensorFlow](https://www.tensorflow.org/) em Julia
* [`DaggerFlux.jl`](https://github.com/DhairyaLGandhi/DaggerFlux.jl): Integração de [`Dagger.jl`](https://github.com/JuliaParallel/Dagger.jl) e `Flux.jl` para computação distribuída em diversos cores, processos, dispositivos, GPUs etc.
"""

# ╔═╡ 332e8a34-d774-4c5b-acd0-51e2aaf9b095
md"""
!!! tip "💡 Redes Neurais Bayesianas"
    Caso você queira combinar Redes Neurais de `Flux.jl` com Modelos Probabilísticos Bayesianso de [`Turing.jl`](https://github.com/TuringLang/Turing.jl) por **despacho múltiplo** você fica com uma [**Rede Neural Bayesiana**](https://turing.ml/dev/tutorials/03-bayesian-neural-network/).
"""

# ╔═╡ 9b9f74e3-03e7-45d5-96b1-8bbd5fbf8de0
md"""
!!! tip "💡 Equações Diferenciais com Redes Neurais"
    Caso você queira combinar Redes Neurais de `Flux.jl` com Equações Diferenciais de [`DifferentialEquations.jl`](https://github.com/SciML/DifferentialEquations.jl) por **despacho múltiplo** você fica com uma **Equação Diferencial Neural** de [`DiffEqFlux`](https://github.com/SciML/DiffEqFlux.jl).
"""

# ╔═╡ e211a39e-d281-4a08-91c7-9f7df3e37f11
md"""
## Como treinar uma Rede Neural com [`Flux.jl`](https://fluxml.ai/Flux.jl/stable/training/training/)

Para treinar uma rede neural em `Flux.jl` precisamos de [4 coisas](https://fluxml.ai/Flux.jl/stable/training/training/):

* Uma **função custo**
* Os **parâmetros** "treináveis" do modelo
* **Dados**
* Um **algoritmo de otimização**
"""

# ╔═╡ 4e89f0d1-cac5-4a34-806c-0a435053114d
md"""
# Exemplo com o [MNIST](https://en.wikipedia.org/wiki/MNIST_database)

O dataset **MNIST** (_**M**odified **N**ational **I**nstitute of **S**tandards and **T**echnology_) é um clássico de Deep Learning. São imagens preto e branco de dígitos de 0 a 9 de formato 28x28 pixels ($(28*28) pixels)

Contém 60.000 imagens de treino e 10.000 de teste e é um padrão de benchmark de modelos (acho que "foi", não é tão usado assim mais)
"""

# ╔═╡ 995b6561-dbf7-4869-b6ee-8305b54e10b6
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/MNIST.png?raw=true")

# ╔═╡ 6665fcce-309a-45c6-85bf-e03a1b6181df
md"""
Vamos usar o **MNIST** disponível pelo [`MLDatasets`](https://github.com/JuliaML/MLDatasets.jl).
"""

# ╔═╡ 5a2b677e-92e5-4776-92d1-e952cdf4ce53
# aceitar os termos de uso
ENV["DATADEPS_ALWAYS_ACCEPT"] = "true"

# ╔═╡ 3663ba78-83ca-48e8-9bf8-5fa92a45f9f9
# 60k imagens de 28x28
xtrain, ytrain = MLDatasets.MNIST.traindata(Float32); Print(size(xtrain))

# ╔═╡ 5b20f458-4179-4b8c-8a6f-77e0face805d
# 10k imagens de 28x28
xtest, ytest = MLDatasets.MNIST.testdata(Float32); Print(size(xtest))

# ╔═╡ cd51acd5-2883-4949-a43a-3b7a501496e7
md"""
Adicionar um canal 3D nas imagens:
"""

# ╔═╡ f8f37cf2-822a-4db1-a5b7-b6656e7e1a27
x_train = reshape(xtrain, 28, 28, 1, :)

# ╔═╡ ec4204d2-18a8-4957-9e77-bbad9adac83e
x_test = reshape(xtest, 28, 28, 1, :)

# ╔═╡ 42b3ab58-0458-482d-8210-ef0f01071d84
md"""
## Exemplo de uma imagem do MNIST

Digite um número de 1 a 60.000: $(@bind img NumberField(1:60_000, default=1))
"""

# ╔═╡ 6423c01b-7b06-442f-85fd-8da243c08c1b
label = MLDatasets.MNIST.trainlabels(img)

# ╔═╡ b3efc4aa-c615-4c3f-8737-5ff08ffdbd7a
MLDatasets.MNIST.convert2image(xtrain[:, : , img])

# ╔═╡ 73132729-5ee4-4864-9323-07e253b1ec32
md"""
## [_One-Hot Encoding_](https://fluxml.ai/Flux.jl/stable/data/onehot/)

E também temos uns truques de manipulação de dados com `Flux.jl`. Aqui vamos usar o `onehotbatch` ao invés do `onehot`. Veja a diferença:
"""

# ╔═╡ f5529156-03a6-4de9-9293-52b6ef095a4d
# Cria um Vector
onehot(:b, [:a, :b, :c])

# ╔═╡ 4c14c0e3-cd2e-4ad8-80c4-c08d5a5ded98
# Cria uma Array
onehotbatch([:b, :a, :b], [:a, :b, :c])

# ╔═╡ 2a02f832-0f97-4279-8667-abc01ba6d844
y_train, y_test = onehotbatch(ytrain, 0:9), onehotbatch(ytest, 0:9)

# ╔═╡ 1eeda370-f0f8-4dda-ab24-18916e194558
md"""
## [`DataLoader`](https://fluxml.ai/Flux.jl/stable/data/dataloader/)

A primeira coisa que fazemos após tratar os dados é criar um [`DataLoader`](https://fluxml.ai/Flux.jl/stable/data/dataloader/) para ser o nosso gestor de ingestão de dados à rede neural por minibatches:
"""

# ╔═╡ 4507ff8d-ad41-420f-b6a6-2304cca97d3e
train_loader = DataLoader((x_train, y_train);
	batchsize=2^5, shuffle=true)

# ╔═╡ bec1f040-6c87-4cfe-84d9-8d5f91b1ade8
md"""
Vejam que temos alguns fields dentro do `DataLoader`:
"""

# ╔═╡ d350a90b-59c8-4d15-b912-52a88558eb63
typeof(train_loader)

# ╔═╡ 0ad3c6ea-f549-48ca-a019-29b0ef95d328
train_loader.batchsize

# ╔═╡ 3bcc2660-70f1-4e94-be73-07ff88d7caad
train_loader.nobs

# ╔═╡ f1f4558d-c8e8-4a27-ac81-1651bed83c8b
train_loader.shuffle

# ╔═╡ 07ea2397-da91-4fa4-b861-e5bf29a819bf
md"""
## Construção da Rede Neural -- [`Chain`](https://fluxml.ai/Flux.jl/stable/models/layers/)

Agora construímos nossa rede com o [`Chain`](https://fluxml.ai/Flux.jl/stable/models/layers/) colocando as diversas camadas uma na sequência da outra:
"""

# ╔═╡ 8bee7cbc-e9d5-4446-a831-209f665fc65e
imgsize = (28, 28, 1)

# ╔═╡ 64f89a8b-71c6-4ea5-86a9-3eb3876b4792
cnn_output_size = Int.(floor.((imgsize[1]÷8, imgsize[2]÷8, 32)))

# ╔═╡ 418a2706-bdcd-453a-abdd-57fdc47acdb7
nclasses = 10

# ╔═╡ c1be3e97-ee86-4afa-a849-446a5a82a771
m = Chain(
	# Primeira convolução numa imagem 28x28
	Conv((3, 3), imgsize[3]=>16, pad=(1, 1), relu),
	MaxPool((2, 2)),
	
	# Segunda convolução numa imagem 14x14
	Conv((3, 3), 16=>32, pad=(1, 1), relu),
	MaxPool((2, 2)),
	
	# Terceira convolução numa imagem 7x7
	Conv((3, 3), 32=>32, pad=(1, 1), relu),
	MaxPool((2, 2)),
	
	# Reshape o tensor 3D em 1-D
	flatten,
	Dense(prod(cnn_output_size), nclasses)
  )

# ╔═╡ bbf8852f-034c-4b57-ad98-6bf9dec3eb24
md"""
**Camada 1 -- Convolução**

`Conv((3, 3), imgsize[3]=>16, pad=(1, 1), relu)`

`(3,3)` é o tamanho do filtro de convolução (3x3) que vai deslizar sobre a imagem.
`1=>16` é o tamanho de input para o tamanho de output. Quer dizer que uma imagem 28x28x1 vai virar 28x28x16 com 16 novos canais. `pad=(1, 1)` quer dizer que não vai alterar o formato da imagem e continua 28x28. E `relu` é a função de ativação.

**Camada 2 -- _Pooling_**

`MaxPool((2, 2))`

Camadas de convolução geralmente são seguidas por uma camada de _pooling_. No nosso caso o parâmetro `(2, 2)` é o tamanho da janela que desliza sobre a imagem e reduzir ela para metade do tamanho enquanto retendo a informação necessária para a aprendizagem da rede neural. Então nossa imagem sai de 28x28x16 para 14x14x16

**Camada 3 -- Convolução**

`Conv((3, 3), 16=>32, pad=(1, 1), relu)` 

Mais uma convolução com `relu` mas agora os canais vão de 16 para 32. Então a imagem vai de 14x14x16 para 14x14x32.

**Camada 4 -- _Pooling_**

`MaxPool((2, 2))`

Mais uma `MaxPool` com parâmetro `(2, 2)` de janela. Então nossa imagem sai de 14x14x32 para 7x7x32.

**Camada 5 e 6 -- Convolução e _Pooling_**

`Conv((3, 3), 32=>32, pad=(1, 1), relu)`

`MaxPool((2, 2))`

Mais uma convolução `relu` sem alteração de canais com `MaxPool(2, 2)`. Então nossa imagem vai de 7x7x32 para 3x3x32 (arrendando 3.5 para 3).

**Camada 7 -- Achatamento 1D da imagem**

`flatten`

Essa camada achata toda a imagem com um `flatten` em uma única dimensão 1D. Então nossa imagem sai de 3x3x32 para 3⋅3⋅32 = $(3 * 3 * 32) em uma única dimensão.

**Camada 8 -- Densa Totalmente Conectada (_fully connected_ -- FC)**

`Dense(prod(cnn_output_size), nclasses)`

Aqui o `prod` faz o produto de 3x3x32 e especifica o tamanho do inputa da camada densa FC. E o output é o numero de classes `nclasses` que é 10 dígitos possíveis.

> OBS: Não precisamos de uma `softmax` no final pq a nossa `loss` é uma [`logitcrossentropy`](https://fluxml.ai/Flux.jl/stable/models/losses/#Flux.Losses.logitcrossentropy) que já faz o $\log$ do softmax mas com estabilidade numérica.
"""

# ╔═╡ 2bafe287-56ff-4025-ae77-1f69cbb56885
md"""
!!! tip "💡 Flux.Dropout(p)"
    Apesar de não aplicarmos uma camada de _dropout_ ela existe no `Flux.jl` como [`Dropout(p)`](https://fluxml.ai/Flux.jl/stable/models/layers/#Flux.Dropout) onde `p` é a probabilidade de _dropout).
"""

# ╔═╡ 1dca58b6-1174-4eb9-a490-6ee058959f52
md"""
## Função Custo com [`Flux.Losses`](https://fluxml.ai/Flux.jl/stable/models/losses/)

`Flux.jl` tem uma [porrada de função custo](https://fluxml.ai/Flux.jl/stable/models/losses/), mas vamos escolher a [`logitcrossentropy`](https://fluxml.ai/Flux.jl/stable/models/losses/#Flux.Losses.logitcrossentropy) por estabilidade númerica do $\log$ e que substitui a necessidade de uma camada de saída com função de ativação _softmax_:
"""

# ╔═╡ 21a9ad33-89ce-4b08-ba48-b008b5d45bfb
loss(x, y) = logitcrossentropy(m(x), y)

# ╔═╡ 8d2870f5-54ba-4c80-90d9-31d941f6da35
md"""
## Algoritmos de Otimização com [`Flux.Optimise`](https://fluxml.ai/Flux.jl/stable/training/optimisers/)

`Flux.jl` tem uma [porrada de algoritmos de otimização](https://fluxml.ai/Flux.jl/stable/training/optimisers/), mas vamos escolher o [`ADAM`](https://fluxml.ai/Flux.jl/stable/training/optimisers/#Flux.Optimise.ADAM):
"""

# ╔═╡ dfe6dd25-6230-4055-8e82-93983aceea27
η = 3e-3 #\eta <TAB>

# ╔═╡ 8ef0c203-5c4a-410b-9f83-74e219779924
opt = ADAM(η)

# ╔═╡ db785415-4bd4-42f4-a2ea-e2dd7c16385a
md"""
## _Callbacks_ de [`Flux.jl`](https://fluxml.ai/Flux.jl/stable/training/training/#Callbacks)

Flux.jl tem vários [_callbacks_](https://fluxml.ai/Flux.jl/stable/training/training/#Callbacks) que são executados a cada batch no treinamento da rede neural.

Você pode diminuir a velocidade do _callback_ usando `Flux.throttle(f, timeout)` que evita que `f` seja chamado mais de uma vez a cada segundo de `timeout`.
"""

# ╔═╡ 7586f269-657c-4ce2-801a-b8b3f431d5bb
# x_test não test_loader
# e sobrecarregando CPU ao invés de GPU
evalcb() = @show loss_test = logitcrossentropy(cpu(m)(x_test), y_test) 

# ╔═╡ 0a4b1f61-be45-477a-9832-56041fca62e6
throttled_cb = throttle(evalcb, 5)

# ╔═╡ d2d4b093-1c13-4361-b102-6cc931287504
md"""
## GPU ou CPU

Agora vem a parte que jogamos tudo para um `device`, seja CPU ou GPU:
"""

# ╔═╡ cad780f3-428c-4774-a068-e2490481d4d7
temos_CUDA = CUDA.has_cuda_gpu()

# ╔═╡ 33a349a8-a1e8-4683-a186-aa7093f426d2
if temos_CUDA
	device = gpu
	@show "Treinando na GPU 🚀"
else
	device = cpu
	@show "Treinando na CPU 🐌"
end

# ╔═╡ cd024b53-b0fe-4bcb-8b56-b448da2d9bf4
m |> device; train_loader |> device;

# ╔═╡ e0d61ba3-b4bc-4c64-bb4b-cd518ad931a9
if temos_CUDA
	epochs = 10
else
	epochs = 2
end

# ╔═╡ 1854e6a4-57f5-40ca-8477-27ff5f38ab1a
md"""
## Treinando Redes Neurais em [`Flux.jl`](https://fluxml.ai/Flux.jl/stable/training/training/)

Com **função custo**, **modelo**, **dados** e **algoritmo de otimização** definidos, podemos treinar de **duas maneiras**:

1. Uma coisa mais manual com um `for`-loop:

   ```julia
   for d in data

       # Calcula os gradientes dos parâmetros com respeito à função custo `loss`
       grads = Flux.gradient(params(m)) do
           loss(d...)
       end

       # Atualiza os parâmetros baseado no otimizador `opt` escolhido
       Flux.Optimise.update!(opt, params(m), grads)
   end
   ```

2. Uma maneira mais fácil com o `Flux.train!`:

   ```julia
   train!(loss, params(m), data, opt; cb)
   ```

   Onde `loss` é a função custo, `params` são os parâmetros do modelo `m`, `opt` é o otimizador escolhido e `cb` são as funções de _callback_.

Observe que, por padrão, `train!` apenas faz um único loop (uma única "época"). Uma maneira conveniente de executar várias épocas é fornecida por `Flux.@epochs`:
"""

# ╔═╡ 3f32ae9e-1749-44ad-88e3-47f7f704611e
@epochs 2 println("hello")

# ╔═╡ 1a6c602e-386f-49e1-82a9-ee4665eac381
@epochs epochs Flux.train!(loss, params(m), train_loader, opt; cb=throttled_cb)

# ╔═╡ eb992f7e-513b-452a-81cb-d5b3b6cafe35
md"""
## Avaliação da Rede Neural

Óbvio que faremos no **dataset de teste**, pois são dados não observados pelo modelo e estamos interessados na **generalização da aprendizagem**.

Note que agora estamos usando `onecold` ao invés de `onehot` faz o inverso da operação de `onehot`: traz o índice que é "quente" como um inteiro:
"""

# ╔═╡ ec722cd7-26c9-48bf-811d-e8ac888c9102
onecold([false, true, false])

# ╔═╡ 2b901334-0c7c-4484-9681-6949b614eb39
md"""
A função `accuracy` compara a predição `onehot` do modelo para um dado `x` convertida para `onecold` e compara com o rótulo real `y` convertido para `onecold`:
"""

# ╔═╡ 373b0fd2-3d4a-4ec4-b4cd-69b50951877c
accuracy(x, y, model) = mean(onecold(model(x)) .== onecold(y))

# ╔═╡ 395154d6-3d5e-4253-aade-dac59fb71758
accuracy(x_test, y_test, m)

# ╔═╡ e9679cf3-32d1-41c7-906a-e0ff66e52747
md"""
!!! info "💁 Flux.jl"
    Se você gostou de redes neurais não deixe de ver a documentação de [`Flux.jl`](http://fluxml.ai)
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

# ╔═╡ e57c5a8b-5d37-49aa-bc20-2805798f4958
md"""
# Licença

Este conteúdo possui licença [Creative Commons Attribution-ShareAlike 4.0 Internacional](http://creativecommons.org/licenses/by-sa/4.0/).

[![CC BY-SA 4.0](https://licensebuttons.net/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
Flux = "587475ba-b771-5e3f-ad9e-33799f191a9c"
ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
InteractiveUtils = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
JSServe = "824d6782-a2ef-11e9-3a09-e5662e0c26f9"
MLDatasets = "eb30cadb-4394-5ae3-aed4-317e484a6458"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
WGLMakie = "276b4fcb-3e11-5398-bf8b-a0c2d153d008"

[compat]
CUDA = "~3.8.5"
CairoMakie = "~0.7.5"
Flux = "~0.12.9"
ForwardDiff = "~0.10.25"
JSServe = "~1.2.5"
MLDatasets = "~0.5.16"
PlutoUI = "~0.7.38"
WGLMakie = "~0.5.5"
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

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e81c509d2c8e49592413bfb0bb3b08150056c79d"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.ArrayInterface]]
deps = ["Compat", "IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "d49f55ff9c7ee06930b0f65b1df2bfa811418475"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "4.0.4"

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

[[deps.BFloat16s]]
deps = ["LinearAlgebra", "Printf", "Random", "Test"]
git-tree-sha1 = "a598ecb0d717092b5539dbbe890c98bac842b072"
uuid = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"
version = "0.2.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BinDeps]]
deps = ["Libdl", "Pkg", "SHA", "URIParser", "Unicode"]
git-tree-sha1 = "1289b57e8cf019aede076edab0587eb9644175bd"
uuid = "9e28174c-4ba2-5203-b857-d8d62c4213ee"
version = "1.0.2"

[[deps.BinaryProvider]]
deps = ["Libdl", "Logging", "SHA"]
git-tree-sha1 = "ecdec412a9abc8db54c0efc5548c64dfce072058"
uuid = "b99e7846-7c00-51b0-8f62-c81ae34c0232"
version = "0.5.10"

[[deps.BufferedStreams]]
deps = ["Compat", "Test"]
git-tree-sha1 = "5d55b9486590fdda5905c275bb21ce1f0754020f"
uuid = "e1450e63-4bb3-523b-b2a4-4ffa8c0fd77d"
version = "1.0.0"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "873fb188a4b9d76549b81465b1f75c82aaf59238"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.4"

[[deps.CUDA]]
deps = ["AbstractFFTs", "Adapt", "BFloat16s", "CEnum", "CompilerSupportLibraries_jll", "ExprTools", "GPUArrays", "GPUCompiler", "LLVM", "LazyArtifacts", "Libdl", "LinearAlgebra", "Logging", "Printf", "Random", "Random123", "RandomNumbers", "Reexport", "Requires", "SparseArrays", "SpecialFunctions", "TimerOutputs"]
git-tree-sha1 = "a28686d7c83026069cc2505016269cca77506ed3"
uuid = "052768ef-5323-5732-b1bb-66c8b64840ba"
version = "3.8.5"

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

[[deps.ChainRules]]
deps = ["ChainRulesCore", "Compat", "IrrationalConstants", "LinearAlgebra", "Random", "RealDot", "SparseArrays", "Statistics"]
git-tree-sha1 = "8b887daa6af5daf705081061e36386190204ac87"
uuid = "082447d4-558c-5d27-93f4-14fc19e9eca2"
version = "1.28.1"

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

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

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

[[deps.CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

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

[[deps.DataDeps]]
deps = ["BinaryProvider", "HTTP", "Libdl", "Reexport", "SHA", "p7zip_jll"]
git-tree-sha1 = "4f0e41ff461d42cfc62ff0de4f1cd44c6e6b3771"
uuid = "124859b0-ceae-595e-8997-d05f6a7a8dfe"
version = "0.7.7"

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

[[deps.DiffResults]]
deps = ["StaticArrays"]
git-tree-sha1 = "c18e98cba888c6c25d1c3b048e4b3380ca956805"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.0.3"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "dd933c4ef7b4c270aacd4eb88fa64c147492acf0"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.10.0"

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
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
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

[[deps.ExprTools]]
git-tree-sha1 = "56559bbef6ca5ea0c0818fa5c90320398a6fbf8d"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.8"

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

[[deps.Flux]]
deps = ["AbstractTrees", "Adapt", "ArrayInterface", "CUDA", "CodecZlib", "Colors", "DelimitedFiles", "Functors", "Juno", "LinearAlgebra", "MacroTools", "NNlib", "NNlibCUDA", "Pkg", "Printf", "Random", "Reexport", "SHA", "SparseArrays", "Statistics", "StatsBase", "Test", "ZipFile", "Zygote"]
git-tree-sha1 = "983271b47332fd3d9488d6f2d724570290971794"
uuid = "587475ba-b771-5e3f-ad9e-33799f191a9c"
version = "0.12.9"

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
git-tree-sha1 = "1bd6fc0c344fc0cbee1f42f8d2e7ec8253dda2d2"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.25"

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

[[deps.Functors]]
git-tree-sha1 = "223fffa49ca0ff9ce4f875be001ffe173b2b7de4"
uuid = "d9f16b24-f501-4c13-a1f2-28368ffc5196"
version = "0.2.8"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GPUArrays]]
deps = ["Adapt", "LLVM", "LinearAlgebra", "Printf", "Random", "Serialization", "Statistics"]
git-tree-sha1 = "9010083c218098a3695653773695a9949e7e8f0d"
uuid = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
version = "8.3.1"

[[deps.GPUCompiler]]
deps = ["ExprTools", "InteractiveUtils", "LLVM", "Libdl", "Logging", "TimerOutputs", "UUIDs"]
git-tree-sha1 = "647a54f196b5ffb7c3bc2fec5c9a57fa273354cc"
uuid = "61eb1bfa-7361-4325-ad38-22787b887f55"
version = "0.13.14"

[[deps.GZip]]
deps = ["Libdl"]
git-tree-sha1 = "039be665faf0b8ae36e089cd694233f5dee3f7d6"
uuid = "92fee26a-97fe-5a0c-ad85-20a5f3185b63"
version = "0.5.1"

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

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "78e2c69783c9753a91cdae88a8d432be85a2ab5e"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[deps.Glob]]
git-tree-sha1 = "4df9f7e06108728ebf00a0a11edee4b29a482bb2"
uuid = "c27321d9-0574-5035-807b-f59d2c89b15c"
version = "1.3.0"

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

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "169c3dc5acae08835a573a8a3e25c62f689f8b5c"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.6.5"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HDF5]]
deps = ["Compat", "HDF5_jll", "Libdl", "Mmap", "Random", "Requires"]
git-tree-sha1 = "1ffca8635410d35aed33facc7840fee647e18b55"
uuid = "f67ccb44-e63f-5c2f-98bd-6dc0ccc4ba2f"
version = "0.16.5"

[[deps.HDF5_jll]]
deps = ["Artifacts", "JLLWrappers", "LibCURL_jll", "Libdl", "OpenSSL_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "bab67c0d1c4662d2c4be8c6007751b0b6111de5c"
uuid = "0234f1f7-429e-5d53-9886-15a909be8d59"
version = "1.12.1+0"

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

[[deps.IRTools]]
deps = ["InteractiveUtils", "MacroTools", "Test"]
git-tree-sha1 = "7f43342f8d5fd30ead0ba1b49ab1a3af3b787d24"
uuid = "7869d1d1-7146-5819-86e3-90919afe41df"
version = "0.4.5"

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

[[deps.ImageMagick]]
deps = ["FileIO", "ImageCore", "ImageMagick_jll", "InteractiveUtils", "Libdl", "Pkg", "Random"]
git-tree-sha1 = "5bc1cb62e0c5f1005868358db0692c994c3a13c6"
uuid = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
version = "1.2.1"

[[deps.ImageMagick_jll]]
deps = ["Artifacts", "Ghostscript_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f025b79883f361fa1bd80ad132773161d231fd9f"
uuid = "c73af94c-d91f-53ed-93a7-00f77d67a9d7"
version = "6.9.12+2"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "87f7662e03a649cffa2e05bf19c303e168732d3e"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.2+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "f5fc07d4e706b84f72d54eedcc1c13d92fb0871c"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.2"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "61feba885fac3a407465726d0c330b3055df897f"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.1.2"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InternedStrings]]
deps = ["Random", "Test"]
git-tree-sha1 = "eb05b5625bc5d821b8075a77e4c421933e20c76b"
uuid = "7d512f48-7fb1-5a58-b986-67e6dc259f01"
version = "0.7.0"

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

[[deps.JLD2]]
deps = ["FileIO", "MacroTools", "Mmap", "OrderedCollections", "Pkg", "Printf", "Reexport", "TranscodingStreams", "UUIDs"]
git-tree-sha1 = "81b9477b49402b47fbe7f7ae0b252077f53e4a08"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.22"

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

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "StructTypes", "UUIDs"]
git-tree-sha1 = "8c1f668b24d999fb47baf80436194fdccec65ad2"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.9.4"

[[deps.JSServe]]
deps = ["Base64", "CodecZlib", "Colors", "HTTP", "Hyperscript", "JSON3", "LinearAlgebra", "Markdown", "MsgPack", "Observables", "RelocatableFolders", "SHA", "Sockets", "Tables", "Test", "UUIDs", "WebSockets", "WidgetsBase"]
git-tree-sha1 = "e8c3434c3e880e15760821a9eac00deb35ab6ea9"
uuid = "824d6782-a2ef-11e9-3a09-e5662e0c26f9"
version = "1.2.5"

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

[[deps.Juno]]
deps = ["Base64", "Logging", "Media", "Profile"]
git-tree-sha1 = "07cb43290a840908a771552911a6274bc6c072c7"
uuid = "e5e0dc1b-0480-54bc-9374-aad01c23163d"
version = "0.8.4"

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

[[deps.LLVM]]
deps = ["CEnum", "LLVMExtra_jll", "Libdl", "Printf", "Unicode"]
git-tree-sha1 = "c9b86064be5ae0f63e50816a5a90b08c474507ae"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "4.9.1"

[[deps.LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg", "TOML"]
git-tree-sha1 = "43817483288cdceb8d3258756040a3e63578bb1b"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.14+3"

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

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "c9551dd26e31ab17b86cbd00c2ede019c08758eb"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+1"

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
git-tree-sha1 = "58f25e56b706f95125dcb796f39e1fb01d913a71"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.10"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MAT]]
deps = ["BufferedStreams", "CodecZlib", "HDF5", "SparseArrays"]
git-tree-sha1 = "971be550166fe3f604d28715302b58a3f7293160"
uuid = "23992714-dd62-5051-b70f-ba57cb901cac"
version = "0.10.3"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "e595b205efd49508358f7dc670a940c790204629"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.0.0+0"

[[deps.MLDatasets]]
deps = ["BinDeps", "CSV", "ColorTypes", "DataDeps", "DataFrames", "DelimitedFiles", "FileIO", "FixedPointNumbers", "GZip", "Glob", "HDF5", "JLD2", "JSON3", "MAT", "MLUtils", "Pickle", "Requires", "SparseArrays", "Tables"]
git-tree-sha1 = "862c3a31a5a6dfc68e78e2e1634dac1d3b0f654e"
uuid = "eb30cadb-4394-5ae3-aed4-317e484a6458"
version = "0.5.16"

[[deps.MLUtils]]
deps = ["ChainRulesCore", "DelimitedFiles", "Random", "ShowCases", "Statistics", "StatsBase"]
git-tree-sha1 = "c92a10a2492dffac0e152a19d5ffd99a5030349a"
uuid = "f1d291b0-491e-4a28-83b9-f70985020b54"
version = "0.2.1"

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

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Media]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "75a54abd10709c01f1b86b84ec225d26e840ed58"
uuid = "e89f7d12-3494-54d1-8411-f7d8b9ae1f27"
version = "0.5.0"

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

[[deps.MsgPack]]
deps = ["Serialization"]
git-tree-sha1 = "a8cbf066b54d793b9a48c5daa5d586cf2b5bd43d"
uuid = "99f44e22-a591-53d1-9472-aa23ef4bd671"
version = "1.1.0"

[[deps.NNlib]]
deps = ["Adapt", "ChainRulesCore", "Compat", "LinearAlgebra", "Pkg", "Requires", "Statistics"]
git-tree-sha1 = "a59a614b8b4ea6dc1dcec8c6514e251f13ccbe10"
uuid = "872c559c-99b0-510c-b3b7-b6c96a88d5cd"
version = "0.8.4"

[[deps.NNlibCUDA]]
deps = ["CUDA", "LinearAlgebra", "NNlib", "Random", "Statistics"]
git-tree-sha1 = "0d18b4c80a92a00d3d96e8f9677511a7422a946e"
uuid = "a00861dc-f156-4864-bf3c-e6376f28a68d"
version = "0.2.2"

[[deps.NaNMath]]
git-tree-sha1 = "b086b7ea07f8e38cf122f5016af580881ac914fe"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.7"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore"]
git-tree-sha1 = "18efc06f6ec36a8b801b23f076e3c6ac7c3bf153"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.2"

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

[[deps.Pickle]]
deps = ["DataStructures", "InternedStrings", "Serialization", "SparseArrays", "Strided", "StringEncodings", "ZipFile"]
git-tree-sha1 = "de8165bc4d1c448824cefa98cd5cd281dc01d9b2"
uuid = "fbb45041-c46e-462f-888f-7c521cafbc2c"
version = "0.3.0"

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

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

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

[[deps.Random123]]
deps = ["Random", "RandomNumbers"]
git-tree-sha1 = "afeacaecf4ed1649555a19cb2cad3c141bbc9474"
uuid = "74087812-796a-5b5d-8853-05524746bad3"
version = "1.5.0"

[[deps.RandomNumbers]]
deps = ["Random", "Requires"]
git-tree-sha1 = "043da614cc7e95c703498a491e2c21f58a2b8111"
uuid = "e6cf234a-135c-5ec9-84dd-332b85af5143"
version = "1.5.3"

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

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "6a2f7d70512d205ca8c7ee31bfa9f142fe74310c"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.12"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.ShaderAbstractions]]
deps = ["ColorTypes", "FixedPointNumbers", "GeometryBasics", "LinearAlgebra", "Observables", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "0d97c895406b552bed78f3a1fe9925248e908ae2"
uuid = "65257c39-d410-5151-9873-9b3e5be5013e"
version = "0.2.8"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.ShowCases]]
git-tree-sha1 = "7f534ad62ab2bd48591bdeac81994ea8c445e4a5"
uuid = "605ecd9f-84a6-4c9e-81e2-4798472b76a3"
version = "0.1.0"

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
git-tree-sha1 = "65068e4b4d10f3c31aaae2e6cb92b6c6cedca610"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.5.6"

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

[[deps.Strided]]
deps = ["LinearAlgebra", "TupleTools"]
git-tree-sha1 = "4d581938087ca90eab9bd4bb6d270edaefd70dcd"
uuid = "5e0ebb24-38b0-5f93-81fe-25c709ecae67"
version = "1.1.2"

[[deps.StringEncodings]]
deps = ["Libiconv_jll"]
git-tree-sha1 = "50ccd5ddb00d19392577902f0079267a72c5ab04"
uuid = "69024149-9ee7-55f6-a4c4-859efe599b68"
version = "0.3.5"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "57617b34fa34f91d536eb265df67c2d4519b8b98"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.5"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "d24a825a95a6d98c385001212dc9020d609f2d4f"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.8.1"

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

[[deps.TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "d60b0c96a16aaa42138d5d38ad386df672cb8bd8"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.16"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[deps.TupleTools]]
git-tree-sha1 = "3c712976c47707ff893cf6ba4354aa14db1d8938"
uuid = "9d95972d-f1c8-5527-a6e0-b4b365fa01f6"
version = "1.3.0"

[[deps.URIParser]]
deps = ["Unicode"]
git-tree-sha1 = "53a9f49546b8d2dd2e688d216421d050c9a31d0d"
uuid = "30578b45-9adc-5946-b283-645ec420af67"
version = "0.4.1"

[[deps.URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

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

[[deps.WGLMakie]]
deps = ["Colors", "FileIO", "FreeTypeAbstraction", "GeometryBasics", "Hyperscript", "ImageMagick", "JSServe", "LinearAlgebra", "Makie", "Observables", "RelocatableFolders", "ShaderAbstractions", "StaticArrays"]
git-tree-sha1 = "caaaecca3dff47c774fb0cbac9d4899fad3d8f18"
uuid = "276b4fcb-3e11-5398-bf8b-a0c2d153d008"
version = "0.5.5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WebSockets]]
deps = ["Base64", "Dates", "HTTP", "Logging", "Sockets"]
git-tree-sha1 = "f91a602e25fe6b89afc93cf02a4ae18ee9384ce3"
uuid = "104b5d7c-a370-577a-8038-80a2059c5097"
version = "1.5.9"

[[deps.WidgetsBase]]
deps = ["Observables"]
git-tree-sha1 = "c1ef6e02bc457c3b23aafc765b94c3dcd25f174d"
uuid = "eead4739-05f7-45a1-878c-cee36b57321c"
version = "0.1.3"

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

[[deps.ZipFile]]
deps = ["Libdl", "Printf", "Zlib_jll"]
git-tree-sha1 = "3593e69e469d2111389a9bd06bac1f3d730ac6de"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.9.4"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.Zygote]]
deps = ["AbstractFFTs", "ChainRules", "ChainRulesCore", "DiffRules", "Distributed", "FillArrays", "ForwardDiff", "IRTools", "InteractiveUtils", "LinearAlgebra", "MacroTools", "NaNMath", "Random", "Requires", "SparseArrays", "SpecialFunctions", "Statistics", "ZygoteRules"]
git-tree-sha1 = "52adc0a505b6421a8668f13dcdb0c4cb498bd72c"
uuid = "e88e6eb3-aa80-5325-afca-941959d7151f"
version = "0.6.37"

[[deps.ZygoteRules]]
deps = ["MacroTools"]
git-tree-sha1 = "8c1a8e4dfacb1fd631745552c8db35d0deb09ea0"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.2"

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
# ╟─3cf20976-2d7c-4436-bcb1-00c4f3db8985
# ╠═27f62732-c909-11eb-27ee-e373dce148d9
# ╠═b50112c8-d571-4b48-9acc-19c5a349edce
# ╟─919df339-43d3-40a6-97a2-4ef77e3a562b
# ╟─a4eda727-2d82-4100-bc74-bec00a4120e0
# ╟─2bbe47e5-2742-493c-9829-f66a026fa840
# ╟─926b21c0-04d6-4d25-be7b-10d421fe92b8
# ╟─61fd08c4-17dd-4f48-bb44-b90395ed8146
# ╟─cf5581e9-1c68-4798-af3c-dd480a2ec290
# ╟─2674b100-0da8-4503-b868-2e9429b3e099
# ╟─62e019b3-9190-4dcf-8bf3-115367585619
# ╟─acb6dd37-b6eb-4226-88a2-6bece14c9eaf
# ╟─b45ceedd-31b6-4871-b2bf-351114d3a24c
# ╟─65ddfed1-2ae1-4df8-9948-a2d98d7c8a28
# ╟─d6250574-fa76-4e7e-b3de-cb74b851162e
# ╟─461d0516-6e5e-40f6-b54c-68c16e6371ab
# ╟─25b44378-069d-48e6-8ef8-74642e50d201
# ╟─11ad6e43-e9d4-4812-b2a7-af2c57414a25
# ╟─98d633ea-151e-4806-b879-36d258ea95f8
# ╟─5949000c-bb03-4799-8af7-9c056771c3c4
# ╟─8ed693b9-e24f-4d1e-83ac-b154969b264c
# ╟─4a118fbe-74e4-402b-af0d-71f1538cf912
# ╟─81620941-c4a0-4560-a77f-deb4b5c78fe1
# ╟─f90b73ba-913e-4bec-874a-95cf82636760
# ╟─27de55a7-ea5a-42b9-b8f7-312b33e3c21a
# ╟─4136a014-91d1-4e61-8719-08068cf08626
# ╟─00aac365-a747-456d-b999-a90e250396a6
# ╟─5fc43fe1-2807-4457-accf-2afbaee77282
# ╟─160cf645-d716-43aa-8b7c-0a764c4af623
# ╟─be9b6acb-670d-4d14-abd7-c80c2695f56f
# ╟─fddc4e3b-1083-48df-b88b-881db060a754
# ╟─332e8a34-d774-4c5b-acd0-51e2aaf9b095
# ╟─9b9f74e3-03e7-45d5-96b1-8bbd5fbf8de0
# ╟─e211a39e-d281-4a08-91c7-9f7df3e37f11
# ╟─4e89f0d1-cac5-4a34-806c-0a435053114d
# ╟─995b6561-dbf7-4869-b6ee-8305b54e10b6
# ╟─6665fcce-309a-45c6-85bf-e03a1b6181df
# ╠═5a2b677e-92e5-4776-92d1-e952cdf4ce53
# ╠═3663ba78-83ca-48e8-9bf8-5fa92a45f9f9
# ╠═5b20f458-4179-4b8c-8a6f-77e0face805d
# ╟─cd51acd5-2883-4949-a43a-3b7a501496e7
# ╠═f8f37cf2-822a-4db1-a5b7-b6656e7e1a27
# ╠═ec4204d2-18a8-4957-9e77-bbad9adac83e
# ╟─42b3ab58-0458-482d-8210-ef0f01071d84
# ╠═6423c01b-7b06-442f-85fd-8da243c08c1b
# ╠═b3efc4aa-c615-4c3f-8737-5ff08ffdbd7a
# ╟─73132729-5ee4-4864-9323-07e253b1ec32
# ╠═6094b975-d610-4c4a-9318-858c443370ee
# ╠═f5529156-03a6-4de9-9293-52b6ef095a4d
# ╠═4c14c0e3-cd2e-4ad8-80c4-c08d5a5ded98
# ╠═2a02f832-0f97-4279-8667-abc01ba6d844
# ╟─1eeda370-f0f8-4dda-ab24-18916e194558
# ╠═1de34946-f040-4908-bf74-57d402c2b8c2
# ╠═4507ff8d-ad41-420f-b6a6-2304cca97d3e
# ╟─bec1f040-6c87-4cfe-84d9-8d5f91b1ade8
# ╠═d350a90b-59c8-4d15-b912-52a88558eb63
# ╠═0ad3c6ea-f549-48ca-a019-29b0ef95d328
# ╠═3bcc2660-70f1-4e94-be73-07ff88d7caad
# ╠═f1f4558d-c8e8-4a27-ac81-1651bed83c8b
# ╟─07ea2397-da91-4fa4-b861-e5bf29a819bf
# ╠═8bee7cbc-e9d5-4446-a831-209f665fc65e
# ╠═64f89a8b-71c6-4ea5-86a9-3eb3876b4792
# ╠═418a2706-bdcd-453a-abdd-57fdc47acdb7
# ╠═c1be3e97-ee86-4afa-a849-446a5a82a771
# ╟─bbf8852f-034c-4b57-ad98-6bf9dec3eb24
# ╟─2bafe287-56ff-4025-ae77-1f69cbb56885
# ╟─1dca58b6-1174-4eb9-a490-6ee058959f52
# ╠═42806fb7-1f4b-4a1f-b595-f5be174ec179
# ╠═21a9ad33-89ce-4b08-ba48-b008b5d45bfb
# ╟─8d2870f5-54ba-4c80-90d9-31d941f6da35
# ╠═dfe6dd25-6230-4055-8e82-93983aceea27
# ╠═8ef0c203-5c4a-410b-9f83-74e219779924
# ╟─db785415-4bd4-42f4-a2ea-e2dd7c16385a
# ╠═c47cb021-19f0-46d0-b2af-1f9f70e2d6e1
# ╠═7586f269-657c-4ce2-801a-b8b3f431d5bb
# ╠═0a4b1f61-be45-477a-9832-56041fca62e6
# ╟─d2d4b093-1c13-4361-b102-6cc931287504
# ╠═cad780f3-428c-4774-a068-e2490481d4d7
# ╠═33a349a8-a1e8-4683-a186-aa7093f426d2
# ╠═cd024b53-b0fe-4bcb-8b56-b448da2d9bf4
# ╠═e0d61ba3-b4bc-4c64-bb4b-cd518ad931a9
# ╟─1854e6a4-57f5-40ca-8477-27ff5f38ab1a
# ╠═af07c7c9-dd40-4fd3-86bc-de1a3fdef750
# ╠═3f32ae9e-1749-44ad-88e3-47f7f704611e
# ╠═1a6c602e-386f-49e1-82a9-ee4665eac381
# ╟─eb992f7e-513b-452a-81cb-d5b3b6cafe35
# ╠═76b33449-cf47-48b3-ad1e-bc3a9af25b8e
# ╠═d106f13c-cf0c-420c-85e9-21c7ee4cfc73
# ╠═ec722cd7-26c9-48bf-811d-e8ac888c9102
# ╟─2b901334-0c7c-4484-9681-6949b614eb39
# ╠═373b0fd2-3d4a-4ec4-b4cd-69b50951877c
# ╠═395154d6-3d5e-4253-aade-dac59fb71758
# ╟─e9679cf3-32d1-41c7-906a-e0ff66e52747
# ╟─d548bc1a-2e20-4b7f-971b-1b07faaa4c13
# ╟─228e9bf1-cfd8-4285-8b68-43762e1ae8c7
# ╟─23974dfc-7412-4983-9dcc-16e7a3e7dcc4
# ╟─e57c5a8b-5d37-49aa-bc20-2805798f4958
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
