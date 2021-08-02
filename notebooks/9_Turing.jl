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

# ╔═╡ Cell order:
# ╟─cbc48ca5-f1a4-4e13-9323-2fd2c43d8612
# ╟─7bb67403-d2ac-4dc9-b2f1-fdea7a795329
# ╟─bdece96a-53f6-41b9-a16a-fabdf24524e0
# ╠═27f62732-c909-11eb-27ee-e373dce148d9
# ╟─c9c8b8c4-c97d-41c7-9eaa-b7a367851c50
# ╟─d548bc1a-2e20-4b7f-971b-1b07faaa4c13
# ╟─228e9bf1-cfd8-4285-8b68-43762e1ae8c7
# ╟─23974dfc-7412-4983-9dcc-16e7a3e7dcc4
# ╟─11184212-a2ed-47f5-b123-62fa70636fb7
