### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 27f62732-c909-11eb-27ee-e373dce148d9
begin
	import Pkg
	Pkg.activate(mktempdir())
	Pkg.add([
			"PlutoUI"
			])
	using PlutoUI
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
# Modelagem e Otimizações Matemáticas com `JuMP.jl`
"""

# ╔═╡ e8626037-f700-4d7d-96be-4f6851e9c963
Resource("https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg", :width => 120, :display => "inline")

# ╔═╡ 9eccb57e-eb78-47f0-bc76-14d598e21df2
md"""
!!! danger "⚠️ Disciplina Ferramental"
	**Esta disciplina é uma disciplina ferramental!**

	Portanto, se você não sabe o que é otimização matemática, pegue um livro-texto e estude ou pergunte pro seu orientador.

	**Sugestão de fontes**:

	Boyd, Stephen P.; Vandenberghe, Lieven (2004). Convex Optimization. Cambridge: Cambridge University Press. [(link)](https://web.stanford.edu/~boyd/cvxbook/)

	 Kochenderfer, Mykel J; Wheeler, Tim A. (2019). Algorithms for Optimization. The MIT Press. [(link)](https://algorithmsbook.com/optimization/)

	Kwon, Changhyun (2019) Julia Programming for Operations Research. [(link)](https://www.chkwon.net/julia/)
"""

# ╔═╡ 5a590d88-85bf-4d74-bc84-d488507ae947
md"""
# Otimização Matemática

Em matemática, o termo **otimização** refere-se ao **estudo de problemas em que se busca minimizar ou maximizar uma função através da escolha sistemática dos valores de variáveis reais ou inteiras dentro de um conjunto viável**.

Um problema de otimização (no caso um problema de achar o mínimo) pode ser representado da seguinte maneira:

* *Dado*: uma função $f: A \to  R$ de um conjunto $A$ para os números reais $\mathbb{R}$
* *Encontre*: um elemento $x_0 \in A$ tal que $f(x0) \leq f(x)$ para todos $x \in A$

Na otimização contínua, $A$ é algum subconjunto do espaço euclidiano $\mathbb{R}^n$, freqüentemente especificado por um conjunto de restrições, igualdades ou desigualdades que os membros de $A$ devem satisfazer.

Na otimização combinatória, $A$ é algum subconjunto de um espaço discreto, como cadeias binárias, permutações ou conjuntos de inteiros.

O uso de software de otimização requer que a função $f$ seja definida em uma linguagem de programação adequada (Julia, óbvio) e conectada em tempo de compilação ou execução ao software de otimização. O software de otimização entregará valores de entrada em $A$, o módulo de software realizando $f$ entregará o valor calculado $f(x)$ e, em alguns casos, informações adicionais sobre a função como derivadas e gradientes.
"""

# ╔═╡ ba9d3285-7f38-46aa-ab87-7e207478c396
Resource("https://jump.dev/JuMP.jl/dev/assets/logo-with-text-background.svg")

# ╔═╡ 9ac79fb4-feaf-4a41-bb78-993ccf63a782
md"""
# [`JuMP.jl`](https://github.com/jump-dev/JuMP.jl)

**[`JuMP.jl`](https://github.com/jump-dev/JuMP.jl) é uma linguagem de modelagem e pacotes de suporte para otimização matemática em Julia**.

O JuMP torna mais fácil formular e resolver programação linear, programação semidefinida, programação inteira, otimização convexa, otimização não-linear restrita e classes relacionadas de problemas de otimização. Você pode usá-lo para d[irecionar ônibus escolares](https://www.the74million.org/article/building-a-smarter-and-cheaper-school-bus-system-how-a-boston-mit-partnership-led-to-new-routes-that-are-20-more-efficient-use-400-fewer-buses-save-5-million/), [programar trens](https://www.sciencedirect.com/science/article/pii/S0191261516304830), [planejar a expansão da rede elétrica](https://juliacomputing.com/case-studies/psr/) ou até mesmo [otimizar a produção de leite](https://juliacomputing.com/case-studies/moo/).
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

# ╔═╡ 49566ded-c381-4478-b8c5-3dfec256d45a
md"""
# Licença

Este conteúdo possui licença [Creative Commons Attribution-ShareAlike 4.0 Internacional](http://creativecommons.org/licenses/by-sa/4.0/).

[![CC BY-SA 4.0](https://licensebuttons.net/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)
"""

# ╔═╡ Cell order:
# ╟─cbc48ca5-f1a4-4e13-9323-2fd2c43d8612
# ╟─7bb67403-d2ac-4dc9-b2f1-fdea7a795329
# ╟─e8626037-f700-4d7d-96be-4f6851e9c963
# ╠═27f62732-c909-11eb-27ee-e373dce148d9
# ╟─9eccb57e-eb78-47f0-bc76-14d598e21df2
# ╟─5a590d88-85bf-4d74-bc84-d488507ae947
# ╟─ba9d3285-7f38-46aa-ab87-7e207478c396
# ╠═9ac79fb4-feaf-4a41-bb78-993ccf63a782
# ╟─d548bc1a-2e20-4b7f-971b-1b07faaa4c13
# ╟─228e9bf1-cfd8-4285-8b68-43762e1ae8c7
# ╟─23974dfc-7412-4983-9dcc-16e7a3e7dcc4
# ╟─49566ded-c381-4478-b8c5-3dfec256d45a
