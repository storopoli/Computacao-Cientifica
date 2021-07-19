### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 27f62732-c909-11eb-27ee-e373dce148d9
begin
	using Pkg
	using PlutoUI
	
	using BenchmarkTools
	using StaticArrays
	using Statistics: mean
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

# ╔═╡ b232987d-bcc3-492d-850f-2a62768f3942
md"""
## *Performance*
"""

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
### Instabilidade de Tipo

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
#### [`@code_warntype`](https://docs.julialang.org/en/v1/manual/performance-tips/#man-code-warntype)

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

# ╔═╡ ae350740-f49b-437f-aad5-da4b71bf8f57
x = rand(1_000)

# ╔═╡ a9f4b7a2-dcf8-4dba-a7c0-133310802a26
@benchmark positivo.($x)

# ╔═╡ 87f3d1aa-9803-4b97-a05e-fb5cd6610048
@benchmark positivo_stable.($x)

# ╔═╡ c5b42cd9-ff11-4118-93de-809eba145bce
md"""
!!! tip "💡 Tipos Abstratos "
    Veja que eu dou preferência a anotar **tipos abstratos** do que tipos concretos.

	Aqui qualquer `Float64`, `Float32`, ... funcionaria pois o tipo anotado é `AbstractFloat`. O mesmo para `Int128`, `Int64`, ... com o tipo `Integer`.
"""

# ╔═╡ 3ae994ee-35d4-4f6f-964e-82022690f573
md"""
#### Tipos Paramétricos

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
		return 0::T
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
## Variáveis Globais vs Locais

Qual o problema aqui? Com variáveis globais o compilador LLVM tem dificuldades em otimizar o código Assembly.

Veja um exemplo com aquele `x` lá de cima:
"""

# ╔═╡ 2fd61b27-b252-42d7-a367-4ade2871a2f2
function sum_global()
    s = 0.0
    for i in x
        s += i
    end
    return s
end

# ╔═╡ b99fe12f-f2fb-4900-9e08-09ecded57a87
@benchmark sum_global()

# ╔═╡ df453cda-acc3-4b26-ae95-a22e6cda2564
function sum_arg(x)
   s = 0.0
   for i in x
	   s += i
   end
   return s
end

# ╔═╡ a6997d0f-a95d-452a-8c0a-f75a744a8e0b
@benchmark sum_arg($x)

# ╔═╡ d6cf53d0-3317-4cc2-8423-317636d1f173
md"""
> ≈ 70x de perda de *performance*
"""

# ╔═╡ a2656e94-58d5-4c48-90ff-d1e3909174db
md"""
### Se você tiver que usar variáveis globais use `const`
"""

# ╔═╡ beb9bf90-e578-4cb4-b8c4-08f7825e0a66
const const_x = rand(1_000)

# ╔═╡ 43eba429-f3c0-4a05-b240-a381552bd381
function sum_const_global()
	s = 0.0
    for i in const_x
        s += i
    end
    return s
end

# ╔═╡ 962cbdff-8503-4b4e-ac3a-35247fd947b7
@benchmark sum_const_global()

# ╔═╡ e2b1f4c4-abf6-4729-a93c-66fa2c8aa407
md"""
!!! danger "⚠️ Nunca use variáveis globais"
    Mas quando precisar faça elas imutáveis com `const`.
"""

# ╔═╡ d38c963d-c101-4399-8a3f-22b70c5a9f52
md"""
## Fazer tudo imutável

Mesma ideia. Tudo que é mutável faz com que o compilador LLVM não saiba o que vem pela frente e não consiga otimizar.
"""

# ╔═╡ 1882404a-ed82-4e7c-a0b2-2dde255a9788
md"""
### Tuplas vs Arrays

Tuplas são **imutáveis** e Arrays podem ser modificadas após a instanciação.

Veja um exemplo com pontos 2-D:
"""

# ╔═╡ 714c2992-16f9-47f6-9c45-44fb2310a8d8
rand_tuple_point()  = (rand(), rand())

# ╔═╡ 1ff11963-4ca4-4154-8df4-5724c2760599
rand_vector_point() = [rand(), rand()]

# ╔═╡ 11436681-78ba-4697-81d1-4b76e57074e0
tuple_points  = [rand_tuple_point()  for _ ∈ 1:500]

# ╔═╡ e194d2f0-8ec9-41a2-addd-4b20124c14fd
vector_points = [rand_vector_point() for _ ∈ 1:500]

# ╔═╡ 463f85c5-62b6-42b8-81a1-df16d7ca1632
function difference_matrix(points)
	return [p1 .- p2 for p1 in points, p2 ∈ points]
end

# ╔═╡ eaea8739-a1f9-41e0-b196-86a7eee92a30
@benchmark difference_matrix($tuple_points) seconds=1

# ╔═╡ 056fdaf1-03e8-4565-b2dc-8f9ea5621812
@benchmark difference_matrix($vector_points) seconds=1

# ╔═╡ 3c5ad253-4964-48b2-871b-1daae0601848
md"""
### `struct` vs `mutable struct`

Mesma ideia.

* 👍 Imutável
* 👎 Mutável
"""

# ╔═╡ 633afbb7-8cf3-42d6-985c-edc5e52a8c93
abstract type Point end

# ╔═╡ b076bc83-a944-4a2e-86cd-352ee9ac686c
struct ImmutablePoint <: Point
   x::Float64
   y::Float64
end

# ╔═╡ 40817c95-b202-4730-8cf8-0ee12c8f132a
mutable struct MutablePoint <: Point
   x::Float64
   y::Float64
end

# ╔═╡ ce92ab2d-4362-44a5-b14a-d0d2e85f0e40
function mean_point(p::Point)
	return mean([p.x, p.y]) 
end

# ╔═╡ bf934236-4b43-423c-9e1e-55fad85d62ad
@benchmark mean_point.([ImmutablePoint(rand(), rand()) for _ ∈ 1:500_000]) seconds=1

# ╔═╡ f6cfd1f1-be06-412e-9aba-9766bb98a91e
@benchmark mean_point.([MutablePoint(rand(), rand()) for _ ∈ 1:500_000]) seconds=1

# ╔═╡ 3b7c1b4d-aa15-4aba-8f0a-bebf0cc7422e
md"""
### [`StaticArrays.jl`](https://juliaarrays.github.io/StaticArrays.jl/latest/)

**Arrays estáticas em Julia**.

Uso simples:

* `StaticArray{Size, T, Dims} <: AbstractArray{T, Dims}`
* `SVector{N, T}`: alias para `StaticArray{N, T, 1}`
* `SMatrix{M, N, T}`: alias para `StaticArray{(M, N), T, 2}`

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

# ╔═╡ 6326afa7-a9fd-4c6d-8c84-bd70e162ab7e
md"""
!!! tip "💡 Quando usar StaticArrays?"
    Geralmente como regra-geral, se você tiver uma `Array` **até 100 elementos** é interessante usar uma `StaticArray`.
"""

# ╔═╡ e94db3ee-f765-4657-8656-4746bc9404b5
md"""
Comparação:
"""

# ╔═╡ 5badcbbb-1810-4781-9ce5-ec183aa7e267
abstract type MeuTipo end

# ╔═╡ dfbce314-06e2-448a-8a35-7671a1083f05
struct MyImmutable <: MeuTipo
	x::Vector{Int}
end

# ╔═╡ b4fad535-b940-4126-8923-4110fe70c834
mutable struct MyMutable <: MeuTipo
	x::Vector{Int}
end

# ╔═╡ c98e3d08-76e0-4661-9335-b8b846cb6945
struct MySArray <: MeuTipo
	x::SVector{2, Int}
end

# ╔═╡ b23883cb-0bd3-48f3-94cd-507a831027ca
md"""
#### Instaciamento
"""

# ╔═╡ 9e623a78-d3b9-4b56-b5ab-a36f50cd6d48
function f_immutable()
	for i in 1:1000
    	x = MyImmutable([rand(Int), rand(Int)])
	end
	return nothing
end

# ╔═╡ e596d60c-0ced-44a4-86bf-f0e5bb2d9c6d
@benchmark f_immutable()

# ╔═╡ 25686e19-6866-442b-86c2-4c987449307c
function f_mutable()
	for i in 1:1000
    	x = MyMutable([rand(Int), rand(Int)])
	end
	return nothing
end

# ╔═╡ 9a20d3a6-977d-44d5-aae2-6b1a418b5eff
@benchmark f_mutable()

# ╔═╡ a57da9ac-4e5d-43ec-ab4a-589455ccdf68
function f_sarray()
	for i in 1:1000
		x = MySArray(SVector(rand(Int), rand(Int)))
	end
	return nothing
end

# ╔═╡ 5eecb645-7ac2-4ad3-b7ef-ba0d94c832db
@benchmark f_sarray()

# ╔═╡ d6b1a624-a141-4950-815c-135f1e1b59ce
md"""
#### Operações
"""

# ╔═╡ 33948e3f-ce17-41ca-a68d-e3ef6e29f5ca
function mean_meu_tipo(m::MeuTipo)
	return mean(m.x) 
end

# ╔═╡ 589278e9-aef3-4a1f-8ff8-a593ec15546c
@benchmark mean_meu_tipo(MyImmutable([rand(Int), rand(Int)]))

# ╔═╡ 9121f511-c1c4-4abb-bc4b-dab79ca83207
@benchmark mean_meu_tipo(MyMutable([rand(Int), rand(Int)]))

# ╔═╡ 25cf90b9-7e35-48bd-ab69-887c77ec164e
@benchmark mean_meu_tipo(MySArray(SVector(rand(Int), rand(Int))))

# ╔═╡ ece06047-04ba-47f9-856a-88417a16b17a
md"""
## Desativar Checagem de Índices -- [`@inbounds`](https://docs.julialang.org/en/v1/devdocs/boundscheck/)

A maioria das linagugens mode
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

# ╔═╡ 4a052112-9a45-4f63-aedf-eecd1bee403d
@code_warntype_ positivo_stable2(-3) #obs usando um hack

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
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
InteractiveUtils = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[compat]
ANSIColoredPrinters = "~0.0.1"
BenchmarkTools = "~1.1.1"
PlutoUI = "~0.7.9"
StaticArrays = "~1.2.7"
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

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Statistics", "UUIDs"]
git-tree-sha1 = "c31ebabde28d102b602bada60ce8922c266d205b"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.1.1"

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

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

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

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "1b9a0f17ee0adde9e538227de093467348992397"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.7"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

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
# ╟─b232987d-bcc3-492d-850f-2a62768f3942
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
# ╠═ae350740-f49b-437f-aad5-da4b71bf8f57
# ╠═a9f4b7a2-dcf8-4dba-a7c0-133310802a26
# ╠═87f3d1aa-9803-4b97-a05e-fb5cd6610048
# ╟─c5b42cd9-ff11-4118-93de-809eba145bce
# ╟─3ae994ee-35d4-4f6f-964e-82022690f573
# ╠═d93c4592-bd6d-49ce-b8e0-8d6a02928477
# ╠═c17a5fbe-6d4e-4ef6-99c5-667d059df6f6
# ╠═a372ccf0-07fb-4fd7-b813-ede5d12507ea
# ╠═4a052112-9a45-4f63-aedf-eecd1bee403d
# ╟─c33fec23-79f1-41b7-97be-6bc9a66b12bc
# ╠═ec1929fe-a686-4662-92e4-681cb6264f39
# ╠═cb172b0a-ceaf-4c82-ab19-b7824dd12cc4
# ╠═cd74a7da-824c-48ce-9d6c-af2337f3c57e
# ╟─8bf79817-1e93-4c24-b228-2de2a255bcf2
# ╠═2fd61b27-b252-42d7-a367-4ade2871a2f2
# ╠═b99fe12f-f2fb-4900-9e08-09ecded57a87
# ╠═df453cda-acc3-4b26-ae95-a22e6cda2564
# ╠═a6997d0f-a95d-452a-8c0a-f75a744a8e0b
# ╟─d6cf53d0-3317-4cc2-8423-317636d1f173
# ╟─a2656e94-58d5-4c48-90ff-d1e3909174db
# ╠═beb9bf90-e578-4cb4-b8c4-08f7825e0a66
# ╠═43eba429-f3c0-4a05-b240-a381552bd381
# ╠═962cbdff-8503-4b4e-ac3a-35247fd947b7
# ╟─e2b1f4c4-abf6-4729-a93c-66fa2c8aa407
# ╟─d38c963d-c101-4399-8a3f-22b70c5a9f52
# ╟─1882404a-ed82-4e7c-a0b2-2dde255a9788
# ╠═714c2992-16f9-47f6-9c45-44fb2310a8d8
# ╠═1ff11963-4ca4-4154-8df4-5724c2760599
# ╠═11436681-78ba-4697-81d1-4b76e57074e0
# ╠═e194d2f0-8ec9-41a2-addd-4b20124c14fd
# ╠═463f85c5-62b6-42b8-81a1-df16d7ca1632
# ╠═eaea8739-a1f9-41e0-b196-86a7eee92a30
# ╠═056fdaf1-03e8-4565-b2dc-8f9ea5621812
# ╟─3c5ad253-4964-48b2-871b-1daae0601848
# ╠═633afbb7-8cf3-42d6-985c-edc5e52a8c93
# ╠═b076bc83-a944-4a2e-86cd-352ee9ac686c
# ╠═40817c95-b202-4730-8cf8-0ee12c8f132a
# ╠═ce92ab2d-4362-44a5-b14a-d0d2e85f0e40
# ╠═bf934236-4b43-423c-9e1e-55fad85d62ad
# ╠═f6cfd1f1-be06-412e-9aba-9766bb98a91e
# ╟─3b7c1b4d-aa15-4aba-8f0a-bebf0cc7422e
# ╟─6326afa7-a9fd-4c6d-8c84-bd70e162ab7e
# ╟─e94db3ee-f765-4657-8656-4746bc9404b5
# ╠═5badcbbb-1810-4781-9ce5-ec183aa7e267
# ╠═dfbce314-06e2-448a-8a35-7671a1083f05
# ╠═b4fad535-b940-4126-8923-4110fe70c834
# ╠═c98e3d08-76e0-4661-9335-b8b846cb6945
# ╟─b23883cb-0bd3-48f3-94cd-507a831027ca
# ╠═9e623a78-d3b9-4b56-b5ab-a36f50cd6d48
# ╠═e596d60c-0ced-44a4-86bf-f0e5bb2d9c6d
# ╠═25686e19-6866-442b-86c2-4c987449307c
# ╠═9a20d3a6-977d-44d5-aae2-6b1a418b5eff
# ╠═a57da9ac-4e5d-43ec-ab4a-589455ccdf68
# ╠═5eecb645-7ac2-4ad3-b7ef-ba0d94c832db
# ╟─d6b1a624-a141-4950-815c-135f1e1b59ce
# ╠═33948e3f-ce17-41ca-a68d-e3ef6e29f5ca
# ╠═589278e9-aef3-4a1f-8ff8-a593ec15546c
# ╠═9121f511-c1c4-4abb-bc4b-dab79ca83207
# ╠═25cf90b9-7e35-48bd-ab69-887c77ec164e
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
