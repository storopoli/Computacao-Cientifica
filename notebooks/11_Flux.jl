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
	seed!(123)
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
    Os vídeos do [3blue1brown](https://www.youtube.com/c/3blue1brown) são excelentes. Inclusive ele tem uma **playlist sobre redes neurais**.
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
| $(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/sigmoid.png?raw=true", :width => 100)) | $(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/tanh.png?raw=true", :width => 100)) | $(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/relu.png?raw=true", :width => 100)) | !$(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/leaky-relu.png?raw=true", :width => 100)) |
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
	x0 = Node(0.0)
	y0 = Node(0.0)
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

$$\frac{1}{n} \sum^n_{i=1}  - \Big( y_i \log (\widehat{p}) + (1+y_i) \log (1 - \widehat{p}) \Big)$$

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
    As Redes Neurais Convolucionais têm a capacidade de **extrair automaticamente características dos padrões a serem aprendidos** (por meio das camadas de convolução), tarefa que necessariamente tem que ser implementada separadamente quando se emprega uma Rede Neural padrão ("vanilla", _**M**_ulti**l**ayer **P**erceptron_ -- MLP) ou um outro classificador convencional (por exemplo, _**S**upport **V**ector **M**achine_ -- SVM)
"""

# ╔═╡ fddc4e3b-1083-48df-b88b-881db060a754
md"""
# [`Flux.jl`](https://fluxml.ai/)

[`Flux.jl`](https://fluxml.ai/) é o stack 100% Julia para diferenciação automática (_**A**uto**D**iff_) e computação na GPU.

O ecosistema de `Flux.jl` é enorme. Vou listar alguns pacotes/repositórios interessantes:

* [`model-zoo`](https://github.com/FluxML/model-zoo): Zoológico de Modelos
* [`Optimizers.jl`](https://github.com/FluxML/Optimisers.jl): Algoritmos de Otimização e suporte para criação de novos algoritmos
* [`MLDatasets.jl`](https://github.com/JuliaML/MLDatasets.jl): Datasets famosos como MNIST, CIFAR10 etc.
* [`Transformers.jl`](https://github.com/chengchingwen/Transformers.jl): Transformers e NLP em `Flux.jl`
* [`Metalhead.jl`](https://github.com/FluxML/Metalhead.jl): Modelos de Visão Computacional
* [`Flux3D.jl`](https://github.com/FluxML/Flux3D.jl): Visão Computacional 3D.
* [`Augmentor.jl`](https://github.com/Evizero/Augmentor.jl): _Image Augmentation_.
* [`FastAI.jl`](https://github.com/FluxML/FastAI.jl): Melhores Práticas de Deep Learning inspirados em [`fastai`](https://github.com/fastai/fastai)
* [`GeometricFlux.jl`](https://github.com/FluxML/GeometricFlux.jl): Deep Learning Geométrico
* [`MLJFlux.jl`](https://github.com/FluxML/MLJFlux.jl): Interface de `Flux.jl` com `MLJ.jl`
* [`EasyML.jl`](https://github.com/OML-NPA/EasyML.jl): Criando redes neurais com `Flux.jl` de maneira fácil via GUI.
* [`Gym.jl`](https://github.com/FluxML/Gym.jl): Ambientes para Aprendizagem de Reforço
* [`AlphaZero.jl`](https://github.com/jonathan-laurent/AlphaZero.jl): Implementação do AlphaZero de Deep Mind em Julia.
* [`NeuralVerification.jl`](https://github.com/sisl/NeuralVerification.jl): Verificação de Redes Neurais contra ataques adversariais
* [`InvertibleNetworks.jl`](https://github.com/slimgroup/InvertibleNetworks.jl): Framework para inverter Redes Neurais (já que são aproximadores universais de funções)
* [`TensorBoardLogger.jl`](https://github.com/JuliaLogging/TensorBoardLogger.jl): API de [_TensorBoard_](https://www.tensorflow.org/tensorboard/) do [TensorFlow](https://www.tensorflow.org/) em Julia.
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

# ╔═╡ 07ea2397-da91-4fa4-b861-e5bf29a819bf
md"""
## Construção da Rede Neural -- [`Chain`](https://fluxml.ai/Flux.jl/stable/models/layers/)

Agora construímos nossa rede com o [`Chain`](https://fluxml.ai/Flux.jl/stable/models/layers/) colocando as diversas camadas uma na sequência da outra:
"""

# ╔═╡ 8bee7cbc-e9d5-4446-a831-209f665fc65e
imgsize = (28,28,1)

# ╔═╡ 64f89a8b-71c6-4ea5-86a9-3eb3876b4792
cnn_output_size = Int.(floor.([imgsize[1]÷8, imgsize[2]÷8, 32]))

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
	
	# Reshape o tensor 3D em 2D
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
η = 3e-3

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
       grads = Flux.gradient(parameters) do
           loss(d...)
       end

       # Atualiza os parâmetros baseado no otimizador `opt` escolhido
       Flux.Optimise.update!(opt, parameters, grads)
   end
   ```

2. Uma maneira mais fácil com o `Flux.train!`:

   ```julia
   train!(loss, params, data, opt; cb)
   ```

   Onde `loss` é a função custo, `params` são os parâmetros do modelo, `opt` é o otimizador escolhido e `cb` são as funções de _callback_.

Observe que, por padrão, `train!` apenas faz um único loop (uma única "época"). Uma maneira conveniente de executar várias épocas é fornecida por `Flux.@epochs`:
"""

# ╔═╡ 3f32ae9e-1749-44ad-88e3-47f7f704611e
with_terminal() do
	@epochs 2 println("hello")
end

# ╔═╡ 1a6c602e-386f-49e1-82a9-ee4665eac381
with_terminal() do
	@epochs epochs Flux.train!(loss, params(m), train_loader, opt; cb=throttled_cb)
end

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
# accuracy(x, y, model) = mean(onecold(device(model.(x))) .== onecold(device(y)))
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
CUDA = "~3.3.4"
CairoMakie = "~0.6.3"
Flux = "~0.12.6"
ForwardDiff = "~0.10.19"
JSServe = "~1.2.3"
MLDatasets = "~0.5.9"
PlutoUI = "~0.7.9"
WGLMakie = "~0.4.4"
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

[[Animations]]
deps = ["Colors"]
git-tree-sha1 = "e81c509d2c8e49592413bfb0bb3b08150056c79d"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[ArrayInterface]]
deps = ["IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "045ff5e1bc8c6fb1ecb28694abba0a0d55b5f4f5"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "3.1.17"

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

[[BFloat16s]]
deps = ["LinearAlgebra", "Test"]
git-tree-sha1 = "4af69e205efc343068dc8722b8dfec1ade89254a"
uuid = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"
version = "0.1.0"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BinDeps]]
deps = ["Libdl", "Pkg", "SHA", "URIParser", "Unicode"]
git-tree-sha1 = "1289b57e8cf019aede076edab0587eb9644175bd"
uuid = "9e28174c-4ba2-5203-b857-d8d62c4213ee"
version = "1.0.2"

[[BinaryProvider]]
deps = ["Libdl", "Logging", "SHA"]
git-tree-sha1 = "ecdec412a9abc8db54c0efc5548c64dfce072058"
uuid = "b99e7846-7c00-51b0-8f62-c81ae34c0232"
version = "0.5.10"

[[Blosc]]
deps = ["Blosc_jll"]
git-tree-sha1 = "84cf7d0f8fd46ca6f1b3e0305b4b4a37afe50fd6"
uuid = "a74b3585-a348-5f62-a45c-50e91977d574"
version = "0.7.0"

[[Blosc_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Lz4_jll", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "e747dac84f39c62aff6956651ec359686490134e"
uuid = "0b7ba130-8d10-5ba8-a3d6-c5182647fed9"
version = "1.21.0+0"

[[BufferedStreams]]
deps = ["Compat", "Test"]
git-tree-sha1 = "5d55b9486590fdda5905c275bb21ce1f0754020f"
uuid = "e1450e63-4bb3-523b-b2a4-4ffa8c0fd77d"
version = "1.0.0"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[CUDA]]
deps = ["AbstractFFTs", "Adapt", "BFloat16s", "CEnum", "CompilerSupportLibraries_jll", "DataStructures", "ExprTools", "GPUArrays", "GPUCompiler", "LLVM", "LazyArtifacts", "Libdl", "LinearAlgebra", "Logging", "Printf", "Random", "Random123", "RandomNumbers", "Reexport", "Requires", "SparseArrays", "SpecialFunctions", "TimerOutputs"]
git-tree-sha1 = "5e696e37e51b01ae07bd9f700afe6cbd55250bce"
uuid = "052768ef-5323-5732-b1bb-66c8b64840ba"
version = "3.3.4"

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
git-tree-sha1 = "f2202b55d816427cd385a9a4f3ffb226bee80f99"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+0"

[[ChainRules]]
deps = ["ChainRulesCore", "Compat", "LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "11567f2471013449c2fcf119f674c681484a130e"
uuid = "082447d4-558c-5d27-93f4-14fc19e9eca2"
version = "1.5.1"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "bdc0937269321858ab2a4f288486cb258b9a0af7"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.3.0"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

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
git-tree-sha1 = "32a2b8af383f11cbb65803883837a149d10dfe8a"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.10.12"

[[ColorVectorSpace]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "StatsBase"]
git-tree-sha1 = "4d17724e99f357bfd32afa0a9e2dda2af31a9aea"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.8.7"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[CommonSubexpressions]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "7b8a93dba8af7e3b42fecabf646260105ac373f7"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.0"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "344f143fa0ec67e47917848795ab19c6a455f32c"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.32.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Conda]]
deps = ["JSON", "VersionParsing"]
git-tree-sha1 = "299304989a5e6473d985212c28928899c74e9421"
uuid = "8f4d0f93-b110-5947-807f-2305c1781a2d"
version = "1.5.2"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[DataAPI]]
git-tree-sha1 = "ee400abb2298bd13bfc3df1c412ed228061a2385"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.7.0"

[[DataDeps]]
deps = ["BinaryProvider", "HTTP", "Libdl", "Reexport", "SHA", "p7zip_jll"]
git-tree-sha1 = "4f0e41ff461d42cfc62ff0de4f1cd44c6e6b3771"
uuid = "124859b0-ceae-595e-8997-d05f6a7a8dfe"
version = "0.7.7"

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

[[DiffResults]]
deps = ["StaticArrays"]
git-tree-sha1 = "c18e98cba888c6c25d1c3b048e4b3380ca956805"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.0.3"

[[DiffRules]]
deps = ["NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "85d2d9e2524da988bffaf2a381864e20d2dae08d"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.2.1"

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
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

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

[[Flux]]
deps = ["AbstractTrees", "Adapt", "ArrayInterface", "CUDA", "CodecZlib", "Colors", "DelimitedFiles", "Functors", "Juno", "LinearAlgebra", "MacroTools", "NNlib", "NNlibCUDA", "Pkg", "Printf", "Random", "Reexport", "SHA", "Statistics", "StatsBase", "Test", "ZipFile", "Zygote"]
git-tree-sha1 = "1286e5dd0b4c306108747356a7a5d39a11dc4080"
uuid = "587475ba-b771-5e3f-ad9e-33799f191a9c"
version = "0.12.6"

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
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "NaNMath", "Printf", "Random", "SpecialFunctions", "StaticArrays"]
git-tree-sha1 = "b5e930ac60b613ef3406da6d4f42c35d8dc51419"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.19"

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
git-tree-sha1 = "d51e69f0a2f8a3842bca4183b700cf3d9acce626"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.9.1"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[Functors]]
deps = ["MacroTools"]
git-tree-sha1 = "4cd9e70bf8fce05114598b663ad79dfe9ae432b3"
uuid = "d9f16b24-f501-4c13-a1f2-28368ffc5196"
version = "0.2.3"

[[GPUArrays]]
deps = ["AbstractFFTs", "Adapt", "LinearAlgebra", "Printf", "Random", "Serialization", "Statistics"]
git-tree-sha1 = "ececbf05f8904c92814bdbd0aafd5540b0bf2e9a"
uuid = "0c68f7d7-f131-5f86-a1c3-88cf8149b2d7"
version = "7.0.1"

[[GPUCompiler]]
deps = ["ExprTools", "InteractiveUtils", "LLVM", "Libdl", "Logging", "TimerOutputs", "UUIDs"]
git-tree-sha1 = "f26f15d9c353f7091065390ea826df9e03917e58"
uuid = "61eb1bfa-7361-4325-ad38-22787b887f55"
version = "0.12.8"

[[GZip]]
deps = ["Libdl"]
git-tree-sha1 = "039be665faf0b8ae36e089cd694233f5dee3f7d6"
uuid = "92fee26a-97fe-5a0c-ad85-20a5f3185b63"
version = "0.5.1"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "4136b8a5668341e58398bb472754bff4ba0456ff"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.3.12"

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

[[HDF5]]
deps = ["Blosc", "Compat", "HDF5_jll", "Libdl", "Mmap", "Random", "Requires"]
git-tree-sha1 = "83173193dc242ce4b037f0263a7cc45afb5a0b85"
uuid = "f67ccb44-e63f-5c2f-98bd-6dc0ccc4ba2f"
version = "0.15.6"

[[HDF5_jll]]
deps = ["Artifacts", "JLLWrappers", "LibCURL_jll", "Libdl", "OpenSSL_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "fd83fa0bde42e01952757f01149dd968c06c4dba"
uuid = "0234f1f7-429e-5d53-9886-15a909be8d59"
version = "1.12.0+1"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "MbedTLS", "Sockets"]
git-tree-sha1 = "c7ec02c4c6a039a98a15f955462cd7aea5df4508"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.8.19"

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

[[IRTools]]
deps = ["InteractiveUtils", "MacroTools", "Test"]
git-tree-sha1 = "95215cd0076a150ef46ff7928892bc341864c73c"
uuid = "7869d1d1-7146-5819-86e3-90919afe41df"
version = "0.4.3"

[[IfElse]]
git-tree-sha1 = "28e837ff3e7a6c3cdb252ce49fb412c8eb3caeef"
uuid = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
version = "0.1.0"

[[ImageCore]]
deps = ["AbstractFFTs", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "db645f20b59f060d8cfae696bc9538d13fd86416"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.8.22"

[[ImageIO]]
deps = ["FileIO", "Netpbm", "PNGFiles", "TiffImages", "UUIDs"]
git-tree-sha1 = "d067570b4d4870a942b19d9ceacaea4fb39b69a1"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.5.6"

[[ImageMagick]]
deps = ["FileIO", "ImageCore", "ImageMagick_jll", "InteractiveUtils", "Libdl", "Pkg", "Random"]
git-tree-sha1 = "5bc1cb62e0c5f1005868358db0692c994c3a13c6"
uuid = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
version = "1.2.1"

[[ImageMagick_jll]]
deps = ["JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "1c0a2295cca535fabaf2029062912591e9b61987"
uuid = "c73af94c-d91f-53ed-93a7-00f77d67a9d7"
version = "6.9.10-12+3"

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
deps = ["AxisAlgorithms", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "1e0e51692a3a77f1eeb51bf741bdd0439ed210e7"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.2"

[[IntervalSets]]
deps = ["Dates", "EllipsisNotation", "Statistics"]
git-tree-sha1 = "3cc368af3f110a767ac786560045dceddfc16758"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.5.3"

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

[[JSON3]]
deps = ["Dates", "Mmap", "Parsers", "StructTypes", "UUIDs"]
git-tree-sha1 = "b3e5984da3c6c95bcf6931760387ff2e64f508f3"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.9.1"

[[JSServe]]
deps = ["Base64", "CodecZlib", "Colors", "HTTP", "Hyperscript", "JSON3", "LinearAlgebra", "Markdown", "MsgPack", "Observables", "SHA", "Sockets", "Tables", "Test", "UUIDs", "WebSockets", "WidgetsBase"]
git-tree-sha1 = "91101a4b8ac8eefeed6ca8eb4f663fc660e4d9f9"
uuid = "824d6782-a2ef-11e9-3a09-e5662e0c26f9"
version = "1.2.3"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[Juno]]
deps = ["Base64", "Logging", "Media", "Profile"]
git-tree-sha1 = "07cb43290a840908a771552911a6274bc6c072c7"
uuid = "e5e0dc1b-0480-54bc-9374-aad01c23163d"
version = "0.8.4"

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

[[LLVM]]
deps = ["CEnum", "LLVMExtra_jll", "Libdl", "Printf", "Unicode"]
git-tree-sha1 = "d6041ad706cf458b2c9f3e501152488a26451e9c"
uuid = "929cbde3-209d-540e-8aea-75f648917ca0"
version = "4.2.0"

[[LLVMExtra_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "a9b1130c4728b0e462a1c28772954650039eb847"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.7+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "c7f1c695e06c01b95a67f0cd1d34994f3e7db104"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.2.1"

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

[[Lz4_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "5d494bc6e85c4c9b626ee0cab05daa4085486ab1"
uuid = "5ced341a-0733-55b8-9ab6-a4889d929147"
version = "1.9.3+0"

[[MAT]]
deps = ["BufferedStreams", "CodecZlib", "HDF5", "SparseArrays"]
git-tree-sha1 = "5c62992f3d46b8dce69bdd234279bb5a369db7d5"
uuid = "23992714-dd62-5051-b70f-ba57cb901cac"
version = "0.10.1"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "c253236b0ed414624b083e6b72bfe891fbd2c7af"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+1"

[[MLDatasets]]
deps = ["BinDeps", "ColorTypes", "DataDeps", "DelimitedFiles", "FixedPointNumbers", "GZip", "MAT", "PyCall", "Requires"]
git-tree-sha1 = "65cb0a663d65d0b782ba74bfc3982ba51eb85485"
uuid = "eb30cadb-4394-5ae3-aed4-317e484a6458"
version = "0.5.9"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "0fb723cd8c45858c22169b2e42269e53271a6df7"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.7"

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

[[Media]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "75a54abd10709c01f1b86b84ec225d26e840ed58"
uuid = "e89f7d12-3494-54d1-8411-f7d8b9ae1f27"
version = "0.5.0"

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

[[MsgPack]]
deps = ["Serialization"]
git-tree-sha1 = "a8cbf066b54d793b9a48c5daa5d586cf2b5bd43d"
uuid = "99f44e22-a591-53d1-9472-aa23ef4bd671"
version = "1.1.0"

[[NNlib]]
deps = ["Adapt", "ChainRulesCore", "Compat", "LinearAlgebra", "Pkg", "Requires", "Statistics"]
git-tree-sha1 = "16520143f067928bb69eee59ac8bca06be1e43b8"
uuid = "872c559c-99b0-510c-b3b7-b6c96a88d5cd"
version = "0.7.27"

[[NNlibCUDA]]
deps = ["CUDA", "LinearAlgebra", "NNlib", "Random", "Statistics"]
git-tree-sha1 = "a7de026dc0ff9f47551a16ad9a710da66881b953"
uuid = "a00861dc-f156-4864-bf3c-e6376f28a68d"
version = "0.1.7"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[Netpbm]]
deps = ["ColorVectorSpace", "FileIO", "ImageCore"]
git-tree-sha1 = "09589171688f0039f13ebe0fdcc7288f50228b52"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.1"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Observables]]
git-tree-sha1 = "fe29afdef3d0c4a8286128d4e45cc50621b1e43d"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.4.0"

[[OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "5cc97a6f806ba1b36bac7078b866d4297ae8c463"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.4"

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
git-tree-sha1 = "9bc1871464b12ed19297fbc56c4fb4ba84988b0d"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.47.0+0"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "bfd7d8c7fd87f04543810d9cbd3995972236ba1b"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.2"

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

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "501c20a63a34ac1d015d5304da0e645f42d91c9f"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.11"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[PolygonOps]]
git-tree-sha1 = "c031d2332c9a8e1c90eca239385815dc271abb22"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.1"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "afadeba63d90ff223a6a48d2009434ecee2ec9e8"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.1"

[[PyCall]]
deps = ["Conda", "Dates", "Libdl", "LinearAlgebra", "MacroTools", "Serialization", "VersionParsing"]
git-tree-sha1 = "169bb8ea6b1b143c5cf57df6d34d022a7b60c6db"
uuid = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
version = "1.92.3"

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
git-tree-sha1 = "043da614cc7e95c703498a491e2c21f58a2b8111"
uuid = "e6cf234a-135c-5ec9-84dd-332b85af5143"
version = "1.5.3"

[[Ratios]]
git-tree-sha1 = "37d210f612d70f3f7d57d488cb3b6eff56ad4e41"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.0"

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

[[SIMD]]
git-tree-sha1 = "9ba33637b24341aba594a2783a502760aa0bff04"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.3.1"

[[ScanByte]]
deps = ["Libdl", "SIMD"]
git-tree-sha1 = "9cc2955f2a254b18be655a4ee70bc4031b2b189e"
uuid = "7b38b023-a4d7-4c5e-8d43-3f3097f304eb"
version = "0.3.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[ShaderAbstractions]]
deps = ["ColorTypes", "FixedPointNumbers", "GeometryBasics", "LinearAlgebra", "Observables", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "63c6b8796d28a1f942c29659e5519e2ef9ef4a59"
uuid = "65257c39-d410-5151-9873-9b3e5be5013e"
version = "0.2.7"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

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
git-tree-sha1 = "2740ea27b66a41f9d213561a04573da5d3823d4b"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.2.5"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3fedeffc02e47d6e3eb479150c8e5cd8f15a77a0"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.10"

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
deps = ["Adapt", "DataAPI", "Tables"]
git-tree-sha1 = "44b3afd37b17422a62aea25f04c1f7e09ce6b07f"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.5.1"

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

[[TiffImages]]
deps = ["ColorTypes", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "OffsetArrays", "OrderedCollections", "PkgVersion", "ProgressMeter"]
git-tree-sha1 = "03fb246ac6e6b7cb7abac3b3302447d55b43270e"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.4.1"

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

[[URIParser]]
deps = ["Unicode"]
git-tree-sha1 = "53a9f49546b8d2dd2e688d216421d050c9a31d0d"
uuid = "30578b45-9adc-5946-b283-645ec420af67"
version = "0.4.1"

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

[[VersionParsing]]
git-tree-sha1 = "80229be1f670524750d905f8fc8148e5a8c4537f"
uuid = "81def892-9a0e-5fdd-b105-ffc91e053289"
version = "1.2.0"

[[WGLMakie]]
deps = ["Colors", "FileIO", "FreeTypeAbstraction", "GeometryBasics", "Hyperscript", "ImageMagick", "JSServe", "LinearAlgebra", "Makie", "Observables", "ShaderAbstractions", "StaticArrays"]
git-tree-sha1 = "c12ec4aaa701032f10df9abc2499da37c08dca79"
uuid = "276b4fcb-3e11-5398-bf8b-a0c2d153d008"
version = "0.4.4"

[[WebSockets]]
deps = ["Base64", "Dates", "HTTP", "Logging", "Sockets"]
git-tree-sha1 = "f91a602e25fe6b89afc93cf02a4ae18ee9384ce3"
uuid = "104b5d7c-a370-577a-8038-80a2059c5097"
version = "1.5.9"

[[WidgetsBase]]
deps = ["Observables"]
git-tree-sha1 = "c1ef6e02bc457c3b23aafc765b94c3dcd25f174d"
uuid = "eead4739-05f7-45a1-878c-cee36b57321c"
version = "0.1.3"

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

[[Zygote]]
deps = ["AbstractFFTs", "ChainRules", "ChainRulesCore", "DiffRules", "Distributed", "FillArrays", "ForwardDiff", "IRTools", "InteractiveUtils", "LinearAlgebra", "MacroTools", "NaNMath", "Random", "Requires", "SpecialFunctions", "Statistics", "ZygoteRules"]
git-tree-sha1 = "f01bac579bb397ab138aed7e9e3f80ef76d055f7"
uuid = "e88e6eb3-aa80-5325-afca-941959d7151f"
version = "0.6.19"

[[ZygoteRules]]
deps = ["MacroTools"]
git-tree-sha1 = "9e7a1e8ca60b742e508a315c17eef5211e7fbfd7"
uuid = "700de1a5-db45-46bc-99cf-38207098b444"
version = "0.2.1"

[[isoband_jll]]
deps = ["Libdl", "Pkg"]
git-tree-sha1 = "a1ac99674715995a536bbce674b068ec1b7d893d"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.2+0"

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
