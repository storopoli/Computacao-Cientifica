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
# *Machine Learning* com `MLJ.jl`
"""

# ╔═╡ 92b94192-3647-49b7-baba-6d5d81d7ea19
Resource("https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg", :width => 120, :display => "inline")

# ╔═╡ 68e825fd-3c99-4bce-8377-1153949fdf77
md"""
!!! danger "⚠️ Disciplina Ferramental"
	**Esta disciplina é uma disciplina ferramental!**

	Portanto, se você não sabe o que é aprendizagem de máquina, pegue um livro-texto e estude ou pergunte pro seu orientador.

	**Sugestão de fontes**:

	Bishop, C. M. (2006). Pattern Recognition and Machine Learning. Springer. [(linka)](https://www.microsoft.com/en-us/research/uploads/prod/2006/01/Bishop-Pattern-Recognition-and-Machine-Learning-2006.pdf)

	Duda, R. O., Hart, P. E., & Stork, D. G. (2012). Pattern Classification. John Wiley & Sons. [(link)](https://www.amazon.com/Pattern-Classification-Pt-1-Richard-Duda/dp/0471056693)

	Mitchell, T. M. (1997). Machine Learning. McGraw Hill. [(link)](https://www.cs.cmu.edu/~tom/mlbook.html)

	Murphy, K. P. (2012). Machine Learning: A Probabilistic Perspective (Illustrated edition). The MIT Press. [(link)](https://www.amazon.com/Machine-Learning-Probabilistic-Perspective-Computation/dp/0262018020)

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

# ╔═╡ 7b455b83-b223-4b95-bd82-e7a5380633f4
md"""
# Licença

Este conteúdo possui licença [Creative Commons Attribution-ShareAlike 4.0 Internacional](http://creativecommons.org/licenses/by-sa/4.0/).

[![CC BY-SA 4.0](https://licensebuttons.net/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)
"""

# ╔═╡ Cell order:
# ╟─cbc48ca5-f1a4-4e13-9323-2fd2c43d8612
# ╟─7bb67403-d2ac-4dc9-b2f1-fdea7a795329
# ╟─92b94192-3647-49b7-baba-6d5d81d7ea19
# ╠═27f62732-c909-11eb-27ee-e373dce148d9
# ╟─68e825fd-3c99-4bce-8377-1153949fdf77
# ╟─d548bc1a-2e20-4b7f-971b-1b07faaa4c13
# ╟─228e9bf1-cfd8-4285-8b68-43762e1ae8c7
# ╟─23974dfc-7412-4983-9dcc-16e7a3e7dcc4
# ╟─7b455b83-b223-4b95-bd82-e7a5380633f4
