### A Pluto.jl notebook ###
# v0.19.0

using Markdown
using InteractiveUtils

# ╔═╡ 27f62732-c909-11eb-27ee-e373dce148d9
begin
	using Pkg
	using PlutoUI
	
	using BenchmarkTools
	using LoopVectorization
	using Plots
	using StaticArrays
	using ThreadsX
	
	# CUDA
	using CUDA
	
	using Random: seed!, shuffle
	using Statistics: mean
	
	# Random Seed
	seed!(123);
	# Para printar as cores do Terminal
	using ANSIColoredPrinters
end

# ╔═╡ a5949305-ac91-42b8-a601-a90fa5ff0add
using VectorizationBase, IfElse

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
@benchmark $positivo.($x)

# ╔═╡ 87f3d1aa-9803-4b97-a05e-fb5cd6610048
@benchmark $positivo_stable.($x)

# ╔═╡ c5b42cd9-ff11-4118-93de-809eba145bce
md"""
!!! tip "💡 Tipos Abstratos "
    Veja que eu dou preferência a anotar **tipos abstratos** do que tipos concretos.

	Aqui qualquer `Float64`, `Float32`, ... funcionaria pois o tipo anotado é `AbstractFloat`. O mesmo para `Int128`, `Int64`, ... com o tipo `Integer`.
"""

# ╔═╡ 3ae994ee-35d4-4f6f-964e-82022690f573
md"""
#### Tipos Paramétricos

São introduzidos com as chaves `{}` e usando a palavra-chave `where`.

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
    for i ∈ x
        s += i
    end
    return s
end

# ╔═╡ b99fe12f-f2fb-4900-9e08-09ecded57a87
@benchmark $sum_global()

# ╔═╡ df453cda-acc3-4b26-ae95-a22e6cda2564
function sum_arg(x)
   s = 0.0
   for i ∈ x
	   s += i
   end
   return s
end

# ╔═╡ a6997d0f-a95d-452a-8c0a-f75a744a8e0b
@benchmark $sum_arg($x)

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
    for i ∈ const_x
        s += i
    end
    return s
end

# ╔═╡ 962cbdff-8503-4b4e-ac3a-35247fd947b7
@benchmark $sum_const_global()

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
@benchmark $difference_matrix($tuple_points) seconds=1

# ╔═╡ 056fdaf1-03e8-4565-b2dc-8f9ea5621812
@benchmark $difference_matrix($vector_points) seconds=1

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
@benchmark $mean_point.([$ImmutablePoint(rand(), rand()) for _ ∈ 1:500_000]) seconds=1

# ╔═╡ f6cfd1f1-be06-412e-9aba-9766bb98a91e
@benchmark $mean_point.([$MutablePoint(rand(), rand()) for _ ∈ 1:500_000]) seconds=1

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
#### Instanciamento
"""

# ╔═╡ 9e623a78-d3b9-4b56-b5ab-a36f50cd6d48
function f_immutable()
	for i ∈ 1:1_000
    	x = MyImmutable([rand(Int), rand(Int)])
	end
	return nothing
end

# ╔═╡ e596d60c-0ced-44a4-86bf-f0e5bb2d9c6d
@benchmark $f_immutable()

# ╔═╡ 25686e19-6866-442b-86c2-4c987449307c
function f_mutable()
	for i ∈ 1:1_000
    	x = MyMutable([rand(Int), rand(Int)])
	end
	return nothing
end

# ╔═╡ 9a20d3a6-977d-44d5-aae2-6b1a418b5eff
@benchmark $f_mutable()

# ╔═╡ a57da9ac-4e5d-43ec-ab4a-589455ccdf68
function f_sarray()
	for i ∈ 1:1_000
		x = MySArray(SVector(rand(Int), rand(Int)))
	end
	return nothing
end

# ╔═╡ 5eecb645-7ac2-4ad3-b7ef-ba0d94c832db
@benchmark $f_sarray()

# ╔═╡ d6b1a624-a141-4950-815c-135f1e1b59ce
md"""
#### Operações
"""

# ╔═╡ 33948e3f-ce17-41ca-a68d-e3ef6e29f5ca
function mean_meu_tipo(m::MeuTipo)
	return mean(m.x) 
end

# ╔═╡ 589278e9-aef3-4a1f-8ff8-a593ec15546c
@benchmark $mean_meu_tipo($MyImmutable([rand(Int), rand(Int)]))

# ╔═╡ 9121f511-c1c4-4abb-bc4b-dab79ca83207
@benchmark $mean_meu_tipo($MyMutable([rand(Int), rand(Int)]))

# ╔═╡ 25cf90b9-7e35-48bd-ab69-887c77ec164e
@benchmark $mean_meu_tipo($MySArray(SVector(rand(Int), rand(Int))))

# ╔═╡ ece06047-04ba-47f9-856a-88417a16b17a
md"""
## Desativar Checagem de Índices -- [`@inbounds`](https://docs.julialang.org/en/v1/devdocs/boundscheck/)

A maioria das linguagens modernas, por questões de segurança, garantem que não haverá acesso fora dos elementos de uma array.

Porém, em algumas situações que *performance* é crítica, você pode remover essa checagem de acesso.

Para fazer isso em Julia é só usar o macro [`@inbounds`](https://docs.julialang.org/en/v1/devdocs/boundscheck/):
"""

# ╔═╡ 58b775ec-0dd1-4f9b-8c31-7abf6f3d8113
md"""
!!! danger "⚠️ Cuidado com @inbounds"
    Remover o *bound check* de Julia é **perigoso**. Se certifique que você não está fazendo um loop inseguro antes de usar `@inbounds`
"""

# ╔═╡ ab63d553-6aec-4aae-b523-81a03288969b
array_x = rand(10_000)

# ╔═╡ 6862c7d2-76c8-40a1-a0cf-59e9141cf14e
array_y = rand(10_000)

# ╔═╡ 4d8acefd-8cca-4657-8a54-f2ba4bfee6e4
function inner(x, y)
    s = zero(eltype(x))
    for i ∈ eachindex(x)
        s += x[i]*y[i]
    end
    return s
end

# ╔═╡ 5885d029-907f-41ef-8684-8e325bb0e314
@benchmark $inner($array_x, $array_y) seconds=1

# ╔═╡ e1efd4d6-c7fb-46b7-ac70-aec0a4adf655
function inner_inbounds(x, y)
    s = zero(eltype(x))
    for i ∈ eachindex(x)
        @inbounds s += x[i]*y[i]
    end
    return s
end

# ╔═╡ c9124896-6ca8-4d58-8b82-40b34df42bac
@benchmark $inner_inbounds($array_x, $array_y) seconds=1

# ╔═╡ cb42709d-e4e6-4cc5-8d96-da1bfc4edab9
md"""
## Suporte [SIMD](https://en.wikipedia.org/wiki/SIMD) -- [`@simd`](https://docs.julialang.org/en/v1/base/base/#Base.SimdLoop.@simd)

Uma outra coisa importante é, se o seu processador permitir (a não ser que você esteja num computador com mais de 10 anos, SIMD vai funcionar), ativar suporte à [_**S**ingle **I**nstruction, **M**ultiple **D**ata_ (SIMD)](https://en.wikipedia.org/wiki/SIMD).

Geralmente você anota um `for`-loop com o macro `@simd`:
"""

# ╔═╡ 2934a4f0-1db1-4c79-8c1d-0bd5939ff056
function inner_simd(x, y)
    s = zero(eltype(x))
    @simd for i ∈ eachindex(x)
        @inbounds s += x[i] * y[i]
    end
    return s
end

# ╔═╡ 70de5e97-6c90-4074-a702-a57ccfc3702f
@benchmark $inner_simd($array_x, $array_y) seconds=1

# ╔═╡ a26137db-3484-4a99-b842-413a8adb15d5
md"""
!!! danger "⚠️ Operações Paralelas"
    Operações SIMD seguem o mesmo critério de operações paralelas. Isto quer dizer que elas tem que possui as propriedades necessárias para paralelismo: **Associatividade** e **Comutatividade**.

	Veja mais na próxima seção.
"""

# ╔═╡ e6d16ced-35ab-4bbb-9238-78774c96dac7
md"""
# Operações Paralelas
"""

# ╔═╡ acce145b-a978-4233-a8ce-3f13e15ab7e3
md"""
!!! info "💁 Paralelismo"
    Além de todas as coisas que falamos sobre *performance*, uma maneira muito fácil de ganhar mais *performance* é executar **operações em paralelo**.
"""

# ╔═╡ 6f783041-8edc-4c28-be47-689804682f2e
md"""
Toda operação paralela tem que ter duas propriedades:

* **Associatividade**


* **Comutatividade**
"""

# ╔═╡ 9f982b7c-0848-445d-a054-f8b602f4e507
md"""
## Associatividade

Uma operação `+` é **associativa** se: 

$$(a+b)+c = a+(b+c)$$
"""

# ╔═╡ 1a3b95d1-37f0-48a2-a7b9-46e927df8da1
md"""
!!! tip "💡"
    Geralmente **associatividade** é o maior desafio para paralelizar operações.
"""

# ╔═╡ 067cd150-7666-4b12-bab7-8539a1a5528a
md"""
### Exemplo de Associatividade

Adição de elementos de um vetor:
"""

# ╔═╡ b719a018-a8f7-45af-8e2a-b0859c860898
md"""
$(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/assoc_reduce_1.png?raw=true", :width => 320, :align => "left"))
$(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/assoc_reduce_2.png?raw=true", :width => 320, :align => "right"))
"""

# ╔═╡ 1521fdf3-c3d4-4b2c-bdf8-c1acfd2b4450
vetor_int = collect(0:6)

# ╔═╡ a90c0bdd-ccdf-48f0-ba70-ba706137f470
reduce(+, vetor_int)

# ╔═╡ 7bafa3b0-e7c2-43b1-8571-914a1717e23f
[reduce(+, shuffle(vetor_int)) for _ ∈ 1:10]

# ╔═╡ 5e0bff13-57eb-4e4e-b663-c34f38de3185
md"""
### Exemplo de Não-Associatividade

Subtração de elementos de um vetor:
"""

# ╔═╡ 0ff457a7-04ef-47cf-a8b5-4ff9f0d19a95
md"""
$(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/assoc_reduce_3.png?raw=true", :width => 320, :align => "left"))
$(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/assoc_reduce_4.png?raw=true", :width => 320, :align => "right"))
"""

# ╔═╡ 590be92c-7ec0-47c1-80a4-4009180d104a
vetor_int_2 = [2^n for n ∈ 6:-1:0]

# ╔═╡ 4aa405a8-e701-4880-9a3f-b81afc49788a
reduce(-, vetor_int_2)

# ╔═╡ deaac6a9-2905-4b6e-9ebd-c3f9b5d1109a
[reduce(-, shuffle(vetor_int_2)) for _ ∈ 1:10]

# ╔═╡ be10a80d-ad4b-4401-a605-5f47c061c33e
md"""
## Comutatividade

Uma operação `+` é **comutativa** se: 

$$a+b = b+a$$
"""

# ╔═╡ 4dc5ac85-6de5-444a-b255-4abaeea4f26b
md"""
!!! tip "💡"
    Poucas operações não possuem **comutatividade**, portanto não é o maior desafio para paralelizar operações.
"""

# ╔═╡ 4c2c1718-c547-4505-9c77-344aad359046
md"""
### Exemplo de Não-Comutatividade

Multiplicação de Matrizes:

$$A = \begin{bmatrix} 2 & 1 \\ 0 & 3 \\ 4 & 0 \end{bmatrix} \quad \text{e} \quad B = \begin{bmatrix} -1 & 1 \\ 0 & 3 \end{bmatrix}$$

$$A \cdot B = \begin{bmatrix} 2 & 5 \\ 0 & 9 \\ -4 & 4 \end{bmatrix}$$

Mas $B \cdot A$ não é possível pois as dimensões não são compatíveis:

$$2 \times 2 \cdot 3 \times 2$$
"""

# ╔═╡ 91b41524-b814-47d6-85d7-2f15ccb9ed71
matrizes = [rand(1:10, 2,2) for _ ∈ 1:4]

# ╔═╡ f280a4b5-1d08-4d15-9312-82e8c347ee5f
reduce(*, matrizes)

# ╔═╡ 01dacc96-95c9-464a-9520-3a83fc1803f6
[reduce(*, shuffle(matrizes)) for _ ∈ 1:3]

# ╔═╡ a08ba58d-9a0e-4a6e-a4f2-0711b4d6e688
md"""
## [Conjectura de Collatz](https://pt.wikipedia.org/wiki/Conjectura_de_Collatz)

Para exemplificar diversas maneiras de fazer paralelismo em Julia eu vou usar a [Conjectura de Collatz](https://pt.wikipedia.org/wiki/Conjectura_de_Collatz) como exemplo.

> Exemplo adaptado de [Julia Folds -- Data Parallelism: Quick Introduction](https://juliafolds.github.io/data-parallelism/tutorials/quick-introduction/)
"""

# ╔═╡ 35cc4511-29e5-4adc-80b6-5c6a0853fb49
md"""
!!! info "💁 Conjectura de Collatz"
	A **conjectura de Collatz** é uma conjectura matemática que recebeu este nome em referência ao matemático alemão **Lothar Collatz**, que foi o primeiro a propô-la, em 1937.
"""

# ╔═╡ 47130e80-5ce1-4e9f-a79f-7700af3d98cb
md"""
### Enunciado do problema

Considere a seguinte operação em um número inteiro positivo arbitrário qual que:

* Se o número é par, divida-o por 2;
* Se é ímpar, multiplique-o por 3 e some 1


Em notação aritmética, a função $C$ é definida tal que:

$$C(x)= \begin{cases}
3x + 1 &\text{se } x\equiv 1 \pmod 2 \\
\frac{x}{2} &\text{se } x \equiv 0 \pmod 2
\end{cases}$$

A conjectura apresenta uma regra dizendo que, qualquer número natural inteiro, quando aplicado a esta regra, eventualmente sempre chegará a 4, que se converte em 2 e termina em 1.
"""

# ╔═╡ bf0de194-4c09-404d-9ed6-ec99b4d51e8d
HTML("
<style>.embed-container { position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; } .embed-container iframe, .embed-container object, .embed-container embed { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }</style><div class='embed-container'><iframe src='https://www.youtube.com/embed/094y1Z2wpJg' frameborder='0' allowfullscreen></iframe></div>
	")

# ╔═╡ 847640e6-0f1d-4ffe-9336-44b6d5106e97
md"""
!!! tip "💡"
    Essa conjectura ainda não está provada. Aliás [Paul Erdős](https://en.wikipedia.org/wiki/Paul_Erd%C5%91s) estava disposto a pagar U\$ 500 para quem provasse.
"""

# ╔═╡ 25317cc9-14c7-4641-b417-b965ed05b3d0
collatz(x) = ifelse(iseven(x), x ÷ 2, 3x + 1)

# ╔═╡ 9dd37346-1931-4905-9beb-ca14cbe43f46
md"""
Uma coisa interessante é o padrão do tamanho da sequência aplicada para cada número inteiro.

Esse padrão da sequência também é conhecido como **Números de Granizo** ou **Números Maravilhosos**.
"""

# ╔═╡ a7be2174-a7dd-4259-aab9-64cdcc749fb0
function collatz_sequencia(x)
	n = zero(x)
    while true
        x == 1 && return n
        n += 1
        x = collatz(x)
    end
	return n
end

# ╔═╡ 239cf005-ae62-43ed-98ec-31d456236421
scatter(
    map(collatz_sequencia, 1:10_000),
    xlabel = "Valor Inicial",
    ylabel = "Tamanho da Sequência",
    label = "",
    markercolor = 1,
    markerstrokecolor = 1,
    markersize = 3,
    dpi=300
)

# ╔═╡ 70220e30-721f-427c-b117-2b46db35980b
md"""
!!! tip "💡"
	Até 2020, a conjectura já foi checada por um computador para todos os números iniciais até $2^{68} \approx 2.95\times 10^{20}$.
"""

# ╔═╡ 70074377-5575-4cdf-ac05-1f4d3d52851f
md"""
### Benchmark Padrão com `map`
"""

# ╔═╡ 31afe4a9-25fb-4ae6-83df-6891b9985435
@benchmark map($collatz_sequencia, 1:100_000)

# ╔═╡ 7bd9b091-abb0-487d-9f47-7856e7f3f5fb
md"""
### [`ThreadsX.jl`](https://github.com/tkf/ThreadsX.jl)

Possui várias funções totalmente paralelizadas:

```julia
julia> using ThreadsX

julia> ThreadsX.
MergeSort       any             findfirst       map!            reduce
QuickSort       collect         findlast        mapreduce       sort
Set             count           foreach         maximum         sort!
StableQuickSort extrema         issorted        minimum         sum
all             findall         map             prod            unique
```
"""

# ╔═╡ 26ae4dfc-698e-4dfd-9503-2e66435a63d3
@benchmark ThreadsX.map($collatz_sequencia, 1:100_000)

# ╔═╡ 7424ee08-938a-4b38-96b5-43f7613ccd3a
md"""
### [`LoopVectorization`](https://github.com/JuliaSIMD/LoopVectorization.jl)

Paralelização de operações com SIMD. O uso principal são os macros `@turbo` e `@tturbo`.

Possui umas funções vetorizadas prontas:

* `vmap` e `vmap!`: `map` e `map!` vetorizado em SIMD
* `vmapnt` e `vmapntt`: igual ao `vmap` mas usa armazenagem **n**ão-**t**emporal para evitar a poluição do cache. Se você não vai ler os valores logo de cara provavlmente dê algum desempenho.
* `vfilter` e `vfilter!`: `filter` e `filter!` vetorizado em SIMD
* `vmapreduce` e `vmapreduce!`: `mapreduce` e `mapreduce!` vetorizado em SIMD
"""

# ╔═╡ bb2197bf-7fc0-400e-be1b-238e196c721d
md"""
!!! info "💁 LoopVectorization na Conjectura de Collatz"
    Essa [foi difícil de conseguir fazer funcionar](https://discourse.julialang.org/t/loopvectorization-jl-vmap-gives-an-error-vectorizationbase-vec-4-int64/65056/).
"""

# ╔═╡ edb1cf30-a22f-4a87-bfe7-426b1fc7c72c
collatz_SIMD(x) =
    IfElse.ifelse(VectorizationBase.iseven(x), x ÷ 2, 3x + 1)

# ╔═╡ 8bbfb595-c965-4ec0-bc67-4d8e74f6380b
function collatz_sequencia_SIMD(x)
    n = zero(x)
    m = x ≠ 0
    while  VectorizationBase.vany(VectorizationBase.collapse_or(m))
        n += m
        x = collatz_SIMD(x)
        m &= x ≠ 1
    end
    return n
end

# ╔═╡ 68f42bb3-fa97-45ac-aa65-d5e0c48c36e8
@benchmark vmap($collatz_sequencia_SIMD, 1:100_000)

# ╔═╡ d999c31e-f327-4733-a68d-09c373abeb1b
@benchmark vmapntt($collatz_sequencia_SIMD, 1:100_000)

# ╔═╡ a97692dd-5a85-4660-8993-a79e5f39f351
md"""
## Outras opções de Paralelismo

* [`FLoops.jl`](https://github.com/JuliaFolds/FLoops.jl): possui o macro `@floop` e `@reduce` para coisas mais customizadas e complexas. Permite paralelizar na GPU com [`FoldsCUDA.jl`](https://github.com/JuliaFolds/FoldsCUDA.jl).


* [`Dagger.jl`](https://github.com/JuliaParallel/Dagger.jl): operações paralelas em um _**D**irected **A**cyclic **G**raph_ (DAG) ao estilo do `Dask` de Python.


* [`Tullio.jl`](https://github.com/mcabbott/Tullio.jl): paralelização para operações matriciais -- Álgebra Linear.


* [`OnlineStats.jl`](https://github.com/joshday/OnlineStats.jl): Algoritmos de "passada única" (*single-pass*) para Estatísticas e Visualizações de Dados.


* [`VectorizedStatistics`](https://github.com/JuliaSIMD/VectorizedStatistics.jl): Funções de Estatística Descritiva (`mean`, `std`, ...) baseadas em `LoopVectorization.jl` com SIMD.
"""

# ╔═╡ 5dd037c1-63ef-49f1-a34e-e5bc1dda4775
md"""
# BONUS: Operações Paralelas na GPU com `CUDA`
"""

# ╔═╡ b289cb48-c695-40c1-85a0-8d2285c1e3db
# GeForce RTX 3070Ti - 111 μs
#@benchmark map($collatz_sequencia, CuArray(1:100_000))

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

# ╔═╡ a198c969-a0d9-49f9-b83f-96593fbd374e
@code_warntype_ sum_global()

# ╔═╡ 99b3ee9d-47eb-425e-9d78-1bcf09d6881d
@code_warntype_ sum_arg(x)

# ╔═╡ f6e22ed5-6943-4cc2-895f-5f75db23b9bf
@code_warntype_ sum_const_global()

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
CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
IfElse = "615f187c-cbe4-4ef1-ba3b-2fcf58d6d173"
InteractiveUtils = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
LoopVectorization = "bdcacae8-1622-11e9-2a5c-532679323890"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
ThreadsX = "ac1d9e8a-700a-412c-b207-f0111f4b6c0d"
VectorizationBase = "3d5dd08c-fd9d-11e8-17fa-ed2836048c2f"

[compat]
ANSIColoredPrinters = "~0.0.1"
BenchmarkTools = "~1.3.1"
CUDA = "~3.8.5"
IfElse = "~0.1.1"
LoopVectorization = "~0.12.104"
Plots = "~1.27.4"
PlutoUI = "~0.7.38"
StaticArrays = "~1.4.3"
ThreadsX = "~0.1.10"
VectorizationBase = "~0.21.26"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

manifest_format = "2.0"

[[deps.ANSIColoredPrinters]]
git-tree-sha1 = "574baf8110975760d391c710b6341da1afa48d8c"
uuid = "a4c015fc-c6ff-483c-b24f-f7ea428134e9"
version = "0.0.1"

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

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "af92965fb30777147966f58acb05da51c5616b5f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.3"

[[deps.ArgCheck]]
git-tree-sha1 = "a3a402a35a2f7e0b87828ccabbd5ebfbebe356b4"
uuid = "dce04be8-c92d-5529-be00-80e4d2c0e197"
version = "2.3.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.ArrayInterface]]
deps = ["Compat", "IfElse", "LinearAlgebra", "Requires", "SparseArrays", "Static"]
git-tree-sha1 = "8d4a07999261b4461daae67b2d1e12ae1a097741"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "5.0.6"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.BFloat16s]]
deps = ["LinearAlgebra", "Printf", "Random", "Test"]
git-tree-sha1 = "a598ecb0d717092b5539dbbe890c98bac842b072"
uuid = "ab4f0b2a-ad5b-11e8-123f-65d77653426b"
version = "0.2.0"

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

[[deps.BitTwiddlingConvenienceFunctions]]
deps = ["Static"]
git-tree-sha1 = "28bbdbf0354959db89358d1d79d421ff31ef0b5e"
uuid = "62783981-4cbd-42fc-bca8-16325de8dc4b"
version = "0.1.3"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "215a9aa4a1f23fbd05b92769fdd62559488d70e9"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.1"

[[deps.CPUSummary]]
deps = ["IfElse", "Static"]
git-tree-sha1 = "48e01b22ef077b07541309652f697595f8decf25"
uuid = "2a0fbf3d-bb9c-48f3-b0a9-814d99fd7ab9"
version = "0.1.18"

[[deps.CUDA]]
deps = ["AbstractFFTs", "Adapt", "BFloat16s", "CEnum", "CompilerSupportLibraries_jll", "ExprTools", "GPUArrays", "GPUCompiler", "LLVM", "LazyArtifacts", "Libdl", "LinearAlgebra", "Logging", "Printf", "Random", "Random123", "RandomNumbers", "Reexport", "Requires", "SparseArrays", "SpecialFunctions", "TimerOutputs"]
git-tree-sha1 = "a28686d7c83026069cc2505016269cca77506ed3"
uuid = "052768ef-5323-5732-b1bb-66c8b64840ba"
version = "3.8.5"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

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

[[deps.CloseOpenIntervals]]
deps = ["ArrayInterface", "Static"]
git-tree-sha1 = "f576084239e6bdf801007c80e27e2cc2cd963fe0"
uuid = "fb6a15b2-703c-40df-9091-08a04967cfa9"
version = "0.1.6"

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

[[deps.CompositionsBase]]
git-tree-sha1 = "455419f7e328a1a2493cabc6428d79e951349769"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.1"

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

[[deps.DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

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

[[deps.DefineSingletons]]
git-tree-sha1 = "0fba8b706d0178b4dc7fd44a96a92382c9065c2c"
uuid = "244e2a9f-e319-4986-a169-4d1fe445cd52"
version = "0.1.2"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

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

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

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
git-tree-sha1 = "1bd6fc0c344fc0cbee1f42f8d2e7ec8253dda2d2"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "0.10.25"

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

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "51d2dfe8e590fbd74e7a842cf6d13d8a2f45dc01"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.6+0"

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

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "RelocatableFolders", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "af237c08bda486b74318c8070adb96efa6952530"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.64.2"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "cd6efcf9dc746b06709df14e462f0a3fe0786b1e"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.64.2+0"

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

[[deps.HostCPUFeatures]]
deps = ["BitTwiddlingConvenienceFunctions", "IfElse", "Libdl", "Static"]
git-tree-sha1 = "18be5268cf415b5e27f34980ed25a7d34261aa83"
uuid = "3e5b6fbb-0976-4d2c-9146-d79de83f2fb0"
version = "0.1.7"

[[deps.Hwloc]]
deps = ["Hwloc_jll"]
git-tree-sha1 = "92d99146066c5c6888d5a3abc871e6a214388b91"
uuid = "0e44f5e4-bd66-52a0-8798-143a42290a1d"
version = "2.0.0"

[[deps.Hwloc_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "303d70c961317c4c20fafaf5dbe0e6d610c38542"
uuid = "e33a78d0-f292-5ffc-b300-72abe9b543c8"
version = "2.7.1+0"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "91b5dcf362c5add98049e6c29ee756910b03051d"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.3"

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
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5558ad3c8972d602451efe9d81c78ec14ef4f5ef"
uuid = "dad2f222-ce93-54a1-a47d-0025e8a3acab"
version = "0.0.14+2"

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
git-tree-sha1 = "6f14549f7760d84b2db7a9b10b88cd3cc3025730"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.14"

[[deps.LayoutPointers]]
deps = ["ArrayInterface", "LinearAlgebra", "ManualMemory", "SIMDTypes", "Static"]
git-tree-sha1 = "b651f573812d6c36c22c944dd66ef3ab2283dfa1"
uuid = "10f19ff3-798f-405d-979b-55457f8fc047"
version = "0.1.6"

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

[[deps.LoopVectorization]]
deps = ["ArrayInterface", "CPUSummary", "ChainRulesCore", "CloseOpenIntervals", "DocStringExtensions", "ForwardDiff", "HostCPUFeatures", "IfElse", "LayoutPointers", "LinearAlgebra", "OffsetArrays", "PolyesterWeave", "SIMDDualNumbers", "SLEEFPirates", "SpecialFunctions", "Static", "ThreadingUtilities", "UnPack", "VectorizationBase"]
git-tree-sha1 = "0ad02fdd8009e42eb52fcef08a4130465e055ebc"
uuid = "bdcacae8-1622-11e9-2a5c-532679323890"
version = "0.12.104"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.ManualMemory]]
git-tree-sha1 = "bcaef4fc7a0cfe2cba636d84cda54b5e4e4ca3cd"
uuid = "d125e4d3-2237-4719-b19c-fa641b8a4667"
version = "0.1.8"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

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

[[deps.NaNMath]]
git-tree-sha1 = "b086b7ea07f8e38cf122f5016af580881ac914fe"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.7"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

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

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "621f4f3b4977325b9128d5fae7a8b4829a0c2222"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.2.4"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "bb16469fd5224100e422f0b027d26c5a25de1200"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.2.0"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "edec0846433f1c1941032385588fd57380b62b59"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.27.4"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "670e559e5c8e191ded66fa9ea89c97f10376bb4c"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.38"

[[deps.PolyesterWeave]]
deps = ["BitTwiddlingConvenienceFunctions", "CPUSummary", "IfElse", "Static", "ThreadingUtilities"]
git-tree-sha1 = "7e597df97e46ffb1c8adbaddfa56908a7a20194b"
uuid = "1d0040c9-8b98-4ee7-8388-3f51789ca0ad"
version = "0.1.5"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "d3538e7f8a790dc8903519090857ef8e1283eecd"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.5"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

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

[[deps.RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "dc1e451e15d90347a7decc4221842a022b011714"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.5.2"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Referenceables]]
deps = ["Adapt"]
git-tree-sha1 = "e681d3bfa49cd46c3c161505caddf20f0e62aaa9"
uuid = "42d2dcc6-99eb-4e98-b66c-637b7d73030e"
version = "0.1.2"

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

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.SIMDDualNumbers]]
deps = ["ForwardDiff", "IfElse", "SLEEFPirates", "VectorizationBase"]
git-tree-sha1 = "62c2da6eb66de8bb88081d20528647140d4daa0e"
uuid = "3cdde19b-5bb0-4aaf-8931-af3e248e098b"
version = "0.1.0"

[[deps.SIMDTypes]]
git-tree-sha1 = "330289636fb8107c5f32088d2741e9fd7a061a5c"
uuid = "94e857df-77ce-4151-89e5-788b33177be4"
version = "0.1.0"

[[deps.SLEEFPirates]]
deps = ["IfElse", "Static", "VectorizationBase"]
git-tree-sha1 = "d4c366b135fc2e1af7a000473e08edc5afd94819"
uuid = "476501e8-09a2-5ece-8869-fb82de89a1fa"
version = "0.6.31"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

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
git-tree-sha1 = "5ba658aeecaaf96923dce0da9e703bd1fe7666f9"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.4"

[[deps.SplittablesBase]]
deps = ["Setfield", "Test"]
git-tree-sha1 = "39c9f91521de844bad65049efd4f9223e7ed43f9"
uuid = "171d559e-b47b-412a-8079-5efa626c420e"
version = "0.1.14"

[[deps.Static]]
deps = ["IfElse"]
git-tree-sha1 = "87e9954dfa33fd145694e42337bdd3d5b07021a6"
uuid = "aedffcd0-7271-4cad-89d0-dc628f76c6d3"
version = "0.6.0"

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

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "57617b34fa34f91d536eb265df67c2d4519b8b98"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.5"

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

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.ThreadingUtilities]]
deps = ["ManualMemory"]
git-tree-sha1 = "f8629df51cab659d70d2e5618a430b4d3f37f2c3"
uuid = "8290d209-cae3-49c0-8002-c8c24d57dab5"
version = "0.5.0"

[[deps.ThreadsX]]
deps = ["ArgCheck", "BangBang", "ConstructionBase", "InitialValues", "MicroCollections", "Referenceables", "Setfield", "SplittablesBase", "Transducers"]
git-tree-sha1 = "d223de97c948636a4f34d1f84d92fd7602dc555b"
uuid = "ac1d9e8a-700a-412c-b207-f0111f4b6c0d"
version = "0.1.10"

[[deps.TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "d60b0c96a16aaa42138d5d38ad386df672cb8bd8"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.16"

[[deps.Transducers]]
deps = ["Adapt", "ArgCheck", "BangBang", "Baselet", "CompositionsBase", "DefineSingletons", "Distributed", "InitialValues", "Logging", "Markdown", "MicroCollections", "Requires", "Setfield", "SplittablesBase", "Tables"]
git-tree-sha1 = "c76399a3bbe6f5a88faa33c8f8a65aa631d95013"
uuid = "28d57a85-8fef-5791-bfe6-a80928e7c999"
version = "0.4.73"

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

[[deps.VectorizationBase]]
deps = ["ArrayInterface", "CPUSummary", "HostCPUFeatures", "Hwloc", "IfElse", "LayoutPointers", "Libdl", "LinearAlgebra", "SIMDTypes", "Static"]
git-tree-sha1 = "a48484def839a98571683a8b5b942fc910329480"
uuid = "3d5dd08c-fd9d-11e8-17fa-ed2836048c2f"
version = "0.21.26"

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
# ╠═a198c969-a0d9-49f9-b83f-96593fbd374e
# ╠═99b3ee9d-47eb-425e-9d78-1bcf09d6881d
# ╟─a2656e94-58d5-4c48-90ff-d1e3909174db
# ╠═beb9bf90-e578-4cb4-b8c4-08f7825e0a66
# ╠═43eba429-f3c0-4a05-b240-a381552bd381
# ╠═962cbdff-8503-4b4e-ac3a-35247fd947b7
# ╠═f6e22ed5-6943-4cc2-895f-5f75db23b9bf
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
# ╟─ece06047-04ba-47f9-856a-88417a16b17a
# ╟─58b775ec-0dd1-4f9b-8c31-7abf6f3d8113
# ╠═ab63d553-6aec-4aae-b523-81a03288969b
# ╠═6862c7d2-76c8-40a1-a0cf-59e9141cf14e
# ╠═4d8acefd-8cca-4657-8a54-f2ba4bfee6e4
# ╠═5885d029-907f-41ef-8684-8e325bb0e314
# ╠═e1efd4d6-c7fb-46b7-ac70-aec0a4adf655
# ╠═c9124896-6ca8-4d58-8b82-40b34df42bac
# ╟─cb42709d-e4e6-4cc5-8d96-da1bfc4edab9
# ╠═2934a4f0-1db1-4c79-8c1d-0bd5939ff056
# ╠═70de5e97-6c90-4074-a702-a57ccfc3702f
# ╟─a26137db-3484-4a99-b842-413a8adb15d5
# ╟─e6d16ced-35ab-4bbb-9238-78774c96dac7
# ╟─acce145b-a978-4233-a8ce-3f13e15ab7e3
# ╟─6f783041-8edc-4c28-be47-689804682f2e
# ╟─9f982b7c-0848-445d-a054-f8b602f4e507
# ╟─1a3b95d1-37f0-48a2-a7b9-46e927df8da1
# ╟─067cd150-7666-4b12-bab7-8539a1a5528a
# ╟─b719a018-a8f7-45af-8e2a-b0859c860898
# ╠═1521fdf3-c3d4-4b2c-bdf8-c1acfd2b4450
# ╠═a90c0bdd-ccdf-48f0-ba70-ba706137f470
# ╠═7bafa3b0-e7c2-43b1-8571-914a1717e23f
# ╟─5e0bff13-57eb-4e4e-b663-c34f38de3185
# ╟─0ff457a7-04ef-47cf-a8b5-4ff9f0d19a95
# ╠═590be92c-7ec0-47c1-80a4-4009180d104a
# ╠═4aa405a8-e701-4880-9a3f-b81afc49788a
# ╠═deaac6a9-2905-4b6e-9ebd-c3f9b5d1109a
# ╟─be10a80d-ad4b-4401-a605-5f47c061c33e
# ╟─4dc5ac85-6de5-444a-b255-4abaeea4f26b
# ╟─4c2c1718-c547-4505-9c77-344aad359046
# ╠═91b41524-b814-47d6-85d7-2f15ccb9ed71
# ╠═f280a4b5-1d08-4d15-9312-82e8c347ee5f
# ╠═01dacc96-95c9-464a-9520-3a83fc1803f6
# ╟─a08ba58d-9a0e-4a6e-a4f2-0711b4d6e688
# ╟─35cc4511-29e5-4adc-80b6-5c6a0853fb49
# ╟─47130e80-5ce1-4e9f-a79f-7700af3d98cb
# ╟─bf0de194-4c09-404d-9ed6-ec99b4d51e8d
# ╟─847640e6-0f1d-4ffe-9336-44b6d5106e97
# ╠═25317cc9-14c7-4641-b417-b965ed05b3d0
# ╟─9dd37346-1931-4905-9beb-ca14cbe43f46
# ╠═a7be2174-a7dd-4259-aab9-64cdcc749fb0
# ╟─239cf005-ae62-43ed-98ec-31d456236421
# ╟─70220e30-721f-427c-b117-2b46db35980b
# ╟─70074377-5575-4cdf-ac05-1f4d3d52851f
# ╠═31afe4a9-25fb-4ae6-83df-6891b9985435
# ╟─7bd9b091-abb0-487d-9f47-7856e7f3f5fb
# ╠═26ae4dfc-698e-4dfd-9503-2e66435a63d3
# ╟─7424ee08-938a-4b38-96b5-43f7613ccd3a
# ╟─bb2197bf-7fc0-400e-be1b-238e196c721d
# ╠═a5949305-ac91-42b8-a601-a90fa5ff0add
# ╠═edb1cf30-a22f-4a87-bfe7-426b1fc7c72c
# ╠═8bbfb595-c965-4ec0-bc67-4d8e74f6380b
# ╠═68f42bb3-fa97-45ac-aa65-d5e0c48c36e8
# ╠═d999c31e-f327-4733-a68d-09c373abeb1b
# ╟─a97692dd-5a85-4660-8993-a79e5f39f351
# ╟─5dd037c1-63ef-49f1-a34e-e5bc1dda4775
# ╠═b289cb48-c695-40c1-85a0-8d2285c1e3db
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
