### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 27f62732-c909-11eb-27ee-e373dce148d9
begin
	using Pkg
	using PlutoUI
	
	# Para printar as cores do Terminal
	using ANSIColoredPrinters
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
# *Performance* e Operações Paralelas
"""

# ╔═╡ 365e3617-b3e8-4128-956b-56ba047814ec
Resource("https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg", :width => 120, :display => "inline")

# ╔═╡ c6e7e56c-39c5-4330-83c4-5120e8bf5c99
md"""
Checklist básico para *performance*:

1. **arrumar instabilidade de tipo**
2. **usar variáveis locais ao invés de globais**
3. **deixar tudo imutável se possível**
4. **desativar checagem de índice em operações com `Array`**
5. **ativar suporte SIMD em todos os loops `for`**
"""

# ╔═╡ dd475167-987c-462e-b296-67e61e2ccf64
md"""
## Instabilidade de Tipo

!!! info "💁"
	O tipo de saída de uma função é **imprevisível** a partir dos tipos de entradas. Em particular, isso significa que o tipo de saída **pode variar** dependendo dos valores das entradas.
"""

# ╔═╡ 17f404d1-12a3-4368-b7f2-b14968fcae86
function positivo(x)
	if x > 0
		return x
	else
		return 0
	end
end

# ╔═╡ bc28935f-368f-42fe-8bb0-0d5c0f83a9fc
md"""
!!! danger "⚠️"
	Essa função possui instabilidade de tipo.

	`x` é o quê?
"""

# ╔═╡ d4bf050e-bad2-4df9-95c9-926a940a1be6
md"""
### [`@code_warntype`](https://docs.julialang.org/en/v1/manual/performance-tips/#man-code-warntype)

Aí que entra a macro [`@code_warntype`](https://docs.julialang.org/en/v1/manual/performance-tips/#man-code-warntype) que avalia a função com o argumento e printa um *Abstract Syntax Tree* (AST).

Tudo que tiver vermelho é problema...
"""

# ╔═╡ 0e1a1a33-1384-472c-b163-c47d76276afb
md"""
!!! tip "💡 Arrumar Instabilidade de Tipo"
    O mais fácil e simples é simplemente **anotar os tipos** de entrada ou de saída da sua função.
"""

# ╔═╡ 630b1d02-2994-4959-8c73-9831e574e0be
function positivo_stable(x::AbstractFloat)
	if x > 0
		return x
	else
		return 0.0
	end
end

# ╔═╡ 4281974f-9374-4e30-aacc-f200fafde1a6
function positivo_stable(x::Integer)
	if x > 0
		return x
	else
		return 0
	end
end

# ╔═╡ c5b42cd9-ff11-4118-93de-809eba145bce
md"""
!!! tip "💡 Tipos Abstratos "
    Veja que eu dou preferência a anotar **tipos abstratos** do que tipos concretos.

	Aqui qualquer `Float64`, `Float32`, ... funcionaria pois o tipo anotado é `AbstractFloat`. O mesmo para `Int128`, `Int64`, ... com o tipo `Integer`.
"""

# ╔═╡ 3ae994ee-35d4-4f6f-964e-82022690f573
md"""
### Tipos Paramétricos

São introduzidos com as chaves `{}` e usando a palavra-chave `where`

Por exemplo qualquer subtipo concreto de `Real`:
"""

# ╔═╡ d93c4592-bd6d-49ce-b8e0-8d6a02928477
subtypes(Real)

# ╔═╡ c17a5fbe-6d4e-4ef6-99c5-667d059df6f6
function positivo_stable2(x::T) where T <: Real
	if x > 0
		return x
	else
		return 0.0
	end
end

# ╔═╡ c33fec23-79f1-41b7-97be-6bc9a66b12bc
md"""
Funciona também com `Array`s:

* `AbstractArray{T, N}`
* `AbstractMatrix{T}` atalho para `AbstractArray{T, 2}`
* `AbstractVector{T}` atalho para `AbstractArray{T, 1}`
"""

# ╔═╡ ec1929fe-a686-4662-92e4-681cb6264f39
function meus_zeros(x::AbstractVector{T}) where T <: Real
	return zeros(eltype(x), size(x))
end

# ╔═╡ cb172b0a-ceaf-4c82-ab19-b7824dd12cc4
meus_zeros([1, 0, 3])

# ╔═╡ 8bf79817-1e93-4c24-b228-2de2a255bcf2
md"""
# Variáveis Globais vs Locais
"""

# ╔═╡ d38c963d-c101-4399-8a3f-22b70c5a9f52
md"""
# Fazer tudo imutável
"""

# ╔═╡ 1882404a-ed82-4e7c-a0b2-2dde255a9788
md"""
## Tuplas vs Arrays
"""

# ╔═╡ 3c5ad253-4964-48b2-871b-1daae0601848
md"""
## `struct` vs `mutable struct`
"""

# ╔═╡ 3b7c1b4d-aa15-4aba-8f0a-bebf0cc7422e
md"""
## [`StaticArrays.jl`](https://juliaarrays.github.io/StaticArrays.jl/latest/)


[Benchmarks](https://github.com/JuliaArrays/StaticArrays.jl#speed) para matrizes `Float64` 3×3:

| **operação**                | *speedup* |
|:----------------------------|----------:|
| multiplicação               | 5.9x      |
| adição                      | 33.1x     |
| determinante                | 112.9x    |
| inverso                     | 67.8x     |
| decomposição em autovetores | 25.0x     |
| decomposição Cholesky       | 8.8x      |
| decomposição LU             | 6.1x      |
| decomposição QR             | 65.0x     |
"""

# ╔═╡ ece06047-04ba-47f9-856a-88417a16b17a
md"""
## Desativar Checagem de indices -- [`@inbounds`](https://docs.julialang.org/en/v1/devdocs/boundscheck/)
"""

# ╔═╡ cb42709d-e4e6-4cc5-8d96-da1bfc4edab9
md"""
## Suporte [SIMD](https://en.wikipedia.org/wiki/SIMD) -- [`@simd`](https://docs.julialang.org/en/v1/base/base/#Base.SimdLoop.@simd) 
"""

# ╔═╡ e6d16ced-35ab-4bbb-9238-78774c96dac7
md"""
# Operações Paralelas
"""

# ╔═╡ 0e544e1b-fd02-4f5b-b1f0-448a8a1c6ebd
md"""
# Printar as Cores no Terminal

> Código e Hack originais do [Chris Foster](https://github.com/c42f) nesse [issue do `fonsp/PlutoUI.jl`](https://github.com/fonsp/PlutoUI.jl/issues/88):
"""

# ╔═╡ 94384649-efb7-4d44-9506-aa747fd85cbe
# Hacky style setup for ANSIColoredPrinters. css taken from ANSIColoredPrinters example.
# Not sure why we need to modify the font size...
HTML("""
<style>
html .content pre {
    font-family: "JuliaMono", "Roboto Mono", "SFMono-Regular", "Menlo", "Consolas",
        "Liberation Mono", "DejaVu Sans Mono", monospace;
}
html pre.documenter-example-output {
    line-height: 125%;
	font-size: 60%
}
html span.sgr1 {
    font-weight: bolder;
}
html span.sgr2 {
    font-weight: lighter;
}
html span.sgr3 {
    font-style: italic;
}
html span.sgr4 {
    text-decoration: underline;
}
html span.sgr7 {
    color: #fff;
    background-color: #222;
}
html.theme--documenter-dark span.sgr7 {
    color: #1f2424;
    background-color: #fff;
}
html span.sgr8,
html span.sgr8 span,
html span span.sgr8 {
    color: transparent;
}
html span.sgr9 {
    text-decoration: line-through;
}
html span.sgr30 {
    color: #111;
}
html span.sgr31 {
    color: #944;
}
html span.sgr32 {
    color: #073;
}
html span.sgr33 {
    color: #870;
}
html span.sgr34 {
    color: #15a;
}
html span.sgr35 {
    color: #94a;
}
html span.sgr36 {
    color: #08a;
}
html span.sgr37 {
    color: #ddd;
}
html span.sgr40 {
    background-color: #111;
}
html span.sgr41 {
    background-color: #944;
}
html span.sgr42 {
    background-color: #073;
}
html span.sgr43 {
    background-color: #870;
}
html span.sgr44 {
    background-color: #15a;
}
html span.sgr45 {
    background-color: #94a;
}
html span.sgr46 {
    background-color: #08a;
}
html span.sgr47 {
    background-color: #ddd;
}
html span.sgr90 {
    color: #888;
}
html span.sgr91 {
    color: #d57;
}
html span.sgr92 {
    color: #2a5;
}
html span.sgr93 {
    color: #d94;
}
html span.sgr94 {
    color: #08d;
}
html span.sgr95 {
    color: #b8d;
}
html span.sgr96 {
    color: #0bc;
}
html span.sgr97 {
    color: #eee;
}
html span.sgr100 {
    background-color: #888;
}
html span.sgr101 {
    background-color: #d57;
}
html span.sgr102 {
    background-color: #2a5;
}
html span.sgr103 {
    background-color: #d94;
}
html span.sgr104 {
    background-color: #08d;
}
html span.sgr105 {
    background-color: #b8d;
}
html span.sgr106 {
    background-color: #0bc;
}
html span.sgr107 {
    background-color: #eee;
}
</style>""")

# ╔═╡ 40264fb5-4dd5-4e1d-be77-ebac1427e1ee
function color_print(f)
	io = IOBuffer()
	f(IOContext(io, :color=>true))
	html_str = sprint(io2->show(io2, MIME"text/html"(),
					  HTMLPrinter(io, root_class="documenter-example-output")))
	HTML("$html_str")
end

# ╔═╡ c0b42347-65e5-42dd-9cbe-a8fd7b3917bb
macro code_warntype_(args...)
	code = macroexpand(@__MODULE__, :(@code_warntype $(args...)))
	@assert code.head == :call
	insert!(code.args, 2, :io)
	esc(quote # non-hygenic :(
		color_print() do io
		    $code
		end
	end)
end

# ╔═╡ 822227ba-515c-42e2-a8ac-356bedb32872
@code_warntype_ positivo(-3.4) #obs usando um hack

# ╔═╡ 042b82f4-5f7f-494e-ad34-2969e59d8996
@code_warntype_ positivo_stable(-3.4) #obs usando um hack

# ╔═╡ 954566c5-3653-4efc-a49b-c4d92c5f402d
@code_warntype_ positivo_stable(-3) #obs usando um hack

# ╔═╡ a372ccf0-07fb-4fd7-b813-ede5d12507ea
@code_warntype_ positivo_stable2(-3.4) #obs usando um hack

# ╔═╡ cd74a7da-824c-48ce-9d6c-af2337f3c57e
@code_warntype_ meus_zeros([1, 0, 3])

# ╔═╡ f829087b-b3e7-490d-a57c-640504a8d5fc
macro code_llvm_(args...)
	code = macroexpand(@__MODULE__, :(@code_llvm $(args...)))
	@assert code.head == :call
	insert!(code.args, 2, :io)
	esc(quote # non-hygenic :(
		color_print() do io
		    $code
		end
	end)
end

# ╔═╡ 0eeb7e93-0235-4a23-828a-c3b32027bdf9
macro code_native_(args...)
	code = macroexpand(@__MODULE__, :(@code_native $(args...)))
	@assert code.head == :call
	insert!(code.args, 2, :io)
	esc(quote # non-hygenic :(
		color_print() do io
		    $code
		end
	end)
end

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

# ╔═╡ f0745f95-d3c5-4255-8bd5-5ced7a2d9fdb
md"""
# Licença

Este conteúdo possui licença [Creative Commons Attribution-ShareAlike 4.0 Internacional](http://creativecommons.org/licenses/by-sa/4.0/).

[![CC BY-SA 4.0](https://licensebuttons.net/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ANSIColoredPrinters = "a4c015fc-c6ff-483c-b24f-f7ea428134e9"
InteractiveUtils = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
ANSIColoredPrinters = "~0.0.1"
PlutoUI = "~0.7.9"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ANSIColoredPrinters]]
git-tree-sha1 = "574baf8110975760d391c710b6341da1afa48d8c"
uuid = "a4c015fc-c6ff-483c-b24f-f7ea428134e9"
version = "0.0.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "81690084b6198a2e1da36fcfda16eeca9f9f24e4"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.1"

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

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "c8abc88faa3f7a3950832ac5d6e690881590d6dc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "1.1.0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["Base64", "Dates", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "44e225d5837e2a2345e69a1d1e01ac2443ff9fcb"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.9"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "5f6c21241f0f655da3952fd60aa18477cf96c220"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.1.0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[Suppressor]]
git-tree-sha1 = "a819d77f31f83e5792a76081eee1ea6342ab8787"
uuid = "fd094767-a336-5f1f-9728-57cf17d0bbfb"
version = "0.2.0"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─cbc48ca5-f1a4-4e13-9323-2fd2c43d8612
# ╟─7bb67403-d2ac-4dc9-b2f1-fdea7a795329
# ╟─365e3617-b3e8-4128-956b-56ba047814ec
# ╠═27f62732-c909-11eb-27ee-e373dce148d9
# ╟─c6e7e56c-39c5-4330-83c4-5120e8bf5c99
# ╟─dd475167-987c-462e-b296-67e61e2ccf64
# ╠═17f404d1-12a3-4368-b7f2-b14968fcae86
# ╟─bc28935f-368f-42fe-8bb0-0d5c0f83a9fc
# ╟─d4bf050e-bad2-4df9-95c9-926a940a1be6
# ╠═822227ba-515c-42e2-a8ac-356bedb32872
# ╟─0e1a1a33-1384-472c-b163-c47d76276afb
# ╠═630b1d02-2994-4959-8c73-9831e574e0be
# ╠═4281974f-9374-4e30-aacc-f200fafde1a6
# ╠═042b82f4-5f7f-494e-ad34-2969e59d8996
# ╠═954566c5-3653-4efc-a49b-c4d92c5f402d
# ╟─c5b42cd9-ff11-4118-93de-809eba145bce
# ╟─3ae994ee-35d4-4f6f-964e-82022690f573
# ╠═d93c4592-bd6d-49ce-b8e0-8d6a02928477
# ╠═c17a5fbe-6d4e-4ef6-99c5-667d059df6f6
# ╠═a372ccf0-07fb-4fd7-b813-ede5d12507ea
# ╟─c33fec23-79f1-41b7-97be-6bc9a66b12bc
# ╠═ec1929fe-a686-4662-92e4-681cb6264f39
# ╠═cb172b0a-ceaf-4c82-ab19-b7824dd12cc4
# ╠═cd74a7da-824c-48ce-9d6c-af2337f3c57e
# ╠═8bf79817-1e93-4c24-b228-2de2a255bcf2
# ╠═d38c963d-c101-4399-8a3f-22b70c5a9f52
# ╠═1882404a-ed82-4e7c-a0b2-2dde255a9788
# ╠═3c5ad253-4964-48b2-871b-1daae0601848
# ╠═3b7c1b4d-aa15-4aba-8f0a-bebf0cc7422e
# ╠═ece06047-04ba-47f9-856a-88417a16b17a
# ╠═cb42709d-e4e6-4cc5-8d96-da1bfc4edab9
# ╠═e6d16ced-35ab-4bbb-9238-78774c96dac7
# ╟─0e544e1b-fd02-4f5b-b1f0-448a8a1c6ebd
# ╠═94384649-efb7-4d44-9506-aa747fd85cbe
# ╠═40264fb5-4dd5-4e1d-be77-ebac1427e1ee
# ╠═c0b42347-65e5-42dd-9cbe-a8fd7b3917bb
# ╠═f829087b-b3e7-490d-a57c-640504a8d5fc
# ╠═0eeb7e93-0235-4a23-828a-c3b32027bdf9
# ╟─d548bc1a-2e20-4b7f-971b-1b07faaa4c13
# ╟─228e9bf1-cfd8-4285-8b68-43762e1ae8c7
# ╟─23974dfc-7412-4983-9dcc-16e7a3e7dcc4
# ╟─f0745f95-d3c5-4255-8bd5-5ced7a2d9fdb
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
