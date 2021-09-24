### A Pluto.jl notebook ###
# v0.16.1

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
	using BenchmarkPlots
	using BenchmarkTools
	using Cthulhu
	using LaTeXStrings
	using Plots
	using Profile
	using ProfileSVG
	using TimerOutputs
	using Random: seed!
	using StatsPlots
	
	using Pkg
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
# Algoritmos e *Benchmarks* com `BenchmarkTools.jl`
"""

# ╔═╡ a696704a-1347-47e0-9351-ced9d7f990c6
Resource("https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg", :width => 120, :display => "inline")

# ╔═╡ 0aaee5c9-d992-44b0-a4bf-57d6a78f6c95
md"""
!!! tip "💡 Algoritmos"
    Em matemática e ciência da computação, um algoritmo é uma **sequência finita de ações executáveis que visam obter uma solução para um determinado tipo de problema**.
"""

# ╔═╡ 339c28a4-d9f6-4f78-a01a-21de35fa3d3c
md"""
Agora que você já aprendeu o básico de Julia, vamos focar em:

1. **Como programar algoritmos?**


2. **Como fazer benchmark de algoritmos?**
"""

# ╔═╡ 66c95537-2f77-46df-b49d-9ab5b3dd176e
md"""
# Algoritmos de Ordenação

Eu poderia já entrar em coisas malucas como Markov chain Monte Carlo (MCMC), decomposição de matrizes etc. Mas o propósito não é esse... Vamos focar em algo simples.

!!! tip "💡 Algoritmos de Ordenação"
	**Algoritmos de ordenação são algoritmos de manipulação de dados, que coloca os elementos de uma dada sequência em uma certa ordem -- em outras palavras, efetua sua ordenação completa ou parcial**.
"""

# ╔═╡ 1edba463-9d82-413a-b870-97b719e94a10
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/sorting_meme.jpg?raw=true")

# ╔═╡ f4560756-8e6b-4161-a8e2-c94935686034
md"""
> Figura com licença creative commons de `yourbasic.org`
"""

# ╔═╡ d2b7f7cf-a5c7-419b-a2d2-6ccd5c54da7f
md"""
!!! danger "⚠️ Arrays"
    Há diversas estruturas otimizadas para o que você quiser, mas como bom cientista de computação (e seguindo o que o [Bjarne Stroustrup](https://youtu.be/YQs6IC-vgmo) fala de `std::vector`), eu vou fazer tudo em `Array`... (veja esse [link](http://andybohn.com/almostalwaysvector/) também)
"""

# ╔═╡ c2b12078-4039-4b3e-992a-7c2148aeef8b
md"""
## Insertion Sort
"""

# ╔═╡ fadcb3cc-7a45-439f-be60-4d9137b07eab
Resource("https://cdn.emre.me/sorting/insertion_sort.gif", :width => 400)

# ╔═╡ c31dbb4d-13e3-4e05-ad91-74e327f58b0d
md"""
> Figura com licença creative commons de `emre.me/algorithms/sorting-algorithms/`
"""

# ╔═╡ 218b4f0d-51eb-4510-b528-7ec936ae8edd
function insertion_sort!(X)
	for i ∈ 1:length(X)
        cᵥ = X[i]
        j = i - 1
        while j ≥ 1 && X[j] > cᵥ
            X[j+1] = X[j]
            j -= 1
        end
        X[j+1] = cᵥ
    end
end

# ╔═╡ c6056836-9ce6-4e1e-ada2-cc07e1268e54
md"""
## Bubble Sort
"""

# ╔═╡ eb456857-f736-47af-b450-9c13833cb488
Resource("https://cdn.emre.me/sorting/bubble_sort.gif", :width => 400)

# ╔═╡ b68d6f0f-fe43-461c-9285-910c8cd14db8
md"""
> Figura com licença creative commons de `emre.me/algorithms/sorting-algorithms/`
"""

# ╔═╡ 5b443be3-ccbb-4dd5-8ad0-4141b33f4b76
function bubble_sort!(X)
    for i in 1:length(X), j in 1:length(X)-i
        if X[j] > X[j+1]
            (X[j+1], X[j]) = (X[j], X[j+1])
        end
    end
end

# ╔═╡ 3e2731a8-ac55-479d-a9a0-9b0dd7e7420d
md"""
## Merge Sort
"""

# ╔═╡ ee17d11a-955e-4884-930f-6bf61d1bfde0
Resource("https://cdn.emre.me/sorting/merge_sort.gif", :width => 400)

# ╔═╡ bef3ecdc-3867-44ed-adb9-cc45c778e67d
md"""
> Figura com licença creative commons de `emre.me/algorithms/sorting-algorithms/`
"""

# ╔═╡ 2c26b54d-ad41-45e0-a946-60d3c80ec368
function merge(L, R)
    nₗ, nᵣ, i, j = length(L), length(R), 1, 1
    combined = []
    for k in 1:(nₗ + nᵣ)
        l = i ≤ nₗ ? L[i] : Inf
        r = j ≤ nᵣ ? R[j] : Inf
        push!(combined, l < r ? l : r)
        l < r ? i+=1 : j+=1
    end
    return combined
end

# ╔═╡ f6d96868-9614-4301-8b27-397e1c37d0b0
function merge_sort(X)
    n = length(X)
    if n ≤ 1
        return X
    end
    L = merge_sort(X[1:n÷2])
    R = merge_sort(X[n÷2+1:end])
    return merge(L, R)
end

# ╔═╡ 7a020487-c60e-49bd-b4aa-2fb6c371bc1d
md"""
!!! info "💁 BeautifulAlgorithms.jl"
    A maioria dos algoritmos eu peguei desse repositório GitHub [`mossr/BeautifulAlgorithms.jl`](https://github.com/mossr/BeautifulAlgorithms.jl).
"""

# ╔═╡ 3515d81e-1910-474a-aebd-cffbbde66b37
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/complexities-sort-algo.png?raw=true")

# ╔═╡ 165b078c-492e-48af-8b07-7e354e807802
md"""
> Figura com licença creative commons de `weibeld.net`
"""

# ╔═╡ 3716b8c1-77e0-4582-b9d9-32262b2599a7
md"""
# Benchmarks em Julia
"""

# ╔═╡ 854f4f41-345f-47f6-80d5-ea5e77f057ef
const rng = seed!(123) # reproducibilidade

# ╔═╡ e79acabe-bd68-42cd-9b46-76b83ccdaaf6
md"""
Primeiro vamos nos perguntar, por que não usar o `@time` que já está incluso na linguagem Julia?
"""

# ╔═╡ 35d57769-ad58-4c25-94af-987d6444dbf1
X = rand(3, 3)

# ╔═╡ 91ab287d-ef5b-4393-a99d-bd52d7f0528e
with_terminal() do
	@time inv(X) # primeira vez
end

# ╔═╡ 0be60c17-5b9a-40d7-b366-0cef5139815c
with_terminal() do
	@time inv(X) # segunda vez
end

# ╔═╡ 07f57c1a-8927-4c02-8853-de1eddfb4054
Resource("https://llvm.org/img/LLVMWyvernSmall.png", :width => 300)

# ╔═╡ ab63e097-2b40-4d98-9e2a-b5b8103c4877
md"""
> **LLVM** -- Você acha que um compilador com esse logo vai ser enganado facilmente?
"""

# ╔═╡ 7108159a-e33e-473d-85a1-a2785e72fda7
md"""
## [`BenchmarkTools.jl`](https://github.com/JuliaCI/BenchmarkTools.jl)
"""

# ╔═╡ b5d98492-efae-46b8-ac79-3a854f113c2d
md"""
!!! info "💁 Paper sobre o BenchmarkTools"
    Chen, J., & Revels, J. (2016). Robust benchmarking in noisy environments. ArXiv:1608.04295 [Cs]. <http://arxiv.org/abs/1608.04295>
"""

# ╔═╡ 1d1550ca-61aa-4143-a039-025eb8c56efe
md"""
Um pacote bem fácil de usar. Basicamente ele roda inúmeras vezes uma operação e faz a cronometragem do tempo de execucação, compilação, memória alocada, GC etc.

Ele tem dois macros:

1. `@benchmark`: retorna a **capivara toda do benchmark** com um histograma printado no terminal.

2. `@btime`: retorna uma coisa bem **sumarizada e simples** para benchmarks rápidos.
"""

# ╔═╡ 677f3b32-6196-46a2-9189-0d93cf5729d8
md"""
!!! danger "⚠️ Use Referências"
    Em todos esses benchmarks sempre é bom você usar a **referência de tipos instanciados** como argumentos do benchmark.

	Isso é para evitar que o compilador LLVM otimize com base em computações já realizadas durante mensurações prévias.

	Para passar uma referência use o operador `$`.
"""

# ╔═╡ 7ed1f94e-ce96-4ef9-8372-4579a22f561f
# LLVM vai JIT compile da segunda vez em diante e otimizar
@benchmark sin.(X)

# ╔═╡ 26e99f87-0f14-45fc-a55d-d6f4818dc181
# LLVM não consegue inferir o X então nos temos JIT mas não há otimização
@benchmark sin.($X)

# ╔═╡ ad238529-9718-45a0-8b20-25df03182b25
md"""
### `BenchmarkTools.Trial`

Relembrando o `@simd` que deu o *Fatality* no `NumPy` na aula passada:
"""

# ╔═╡ 5744bb5f-4f0a-444c-8a9c-08540323542e
function sumsimd(a)
	result = zero(eltype(a))
	@simd for x in a
    result += x
  end
  return result
end

# ╔═╡ b3219ad5-b945-4d43-ad13-13bff76b0ef0
vec_a = randn(42_000)

# ╔═╡ cd71c1e7-050c-4ad0-b485-1b36cbd6b1a0
bench_obj = @benchmark sumsimd($vec_a) seconds=1 

# ╔═╡ 22e4bdf1-2637-42db-b71a-aff516ca0711
typeof(bench_obj)

# ╔═╡ b28e53b7-f049-4315-83e5-d08fb69ef377
first.(split.(string.(methodswith(BenchmarkTools.Trial)), "("))

# ╔═╡ e129526d-b413-48ea-98d3-08e2c960f89c
summary(bench_obj)

# ╔═╡ b254962c-f7d8-4f49-b6cf-585f6e825975
time(bench_obj)

# ╔═╡ 5e461561-9c19-480b-bbd9-13fc4b4d5343
allocs(bench_obj)

# ╔═╡ dff1efb1-5db1-43dd-ac2e-451375bc1c1b
gctime(bench_obj)

# ╔═╡ bae6a808-119d-471a-a39d-34d1fea28b0e
with_terminal() do
	dump(bench_obj)
end

# ╔═╡ 0aeaf17a-6fcf-4da0-9185-67142cfdb272
md"""
### Plotando `BenchmarkTools.Trial`

A documentação de [`BenchmarkTools.jl`](https://juliaci.github.io/BenchmarkTools.jl/dev/manual/#Visualizing-benchmark-results) menciona que podemos plotar tipos `Trial` com o pacote [`BenchmarkPlots.jl`](https://github.com/JuliaAstroSim/BenchmarkPlots.jl).

```julia
using BenchmarkPlots
using StatsPlots
```
"""

# ╔═╡ 47677be0-f211-400e-a522-78d0a6364954
plot(bench_obj)

# ╔═╡ ba3a91b1-bf53-4e22-9dbc-8e5029df9c26
md"""
### Benchmarks -- Algoritmos de Ordenação

Escolha seu `k` em $10^k$

$(@bind k Slider(1:4; show_value=true))

"""

# ╔═╡ 6bb03874-89b3-4925-94aa-7befc4f58cee
md"""
 $k$ = $k

 $n$ = $(10^k)
"""

# ╔═╡ c3967255-7b74-4999-a764-df56759803b4
A = rand(rng, 10^k)

# ╔═╡ bc051646-3f99-4052-a97a-747e4c60b000
@benchmark insertion_sort!($A) seconds=1

# ╔═╡ 876c8fef-e98e-482e-9f2a-98124cc83f77
@benchmark bubble_sort!($A) seconds=1

# ╔═╡ b08ee953-bd89-4805-9fda-d1c5f0133323
@benchmark merge_sort($A) seconds=1

# ╔═╡ f0715632-54b1-4e5f-9290-a770e36c99ba
begin
	# 38.7s
	xs_insertion = Float64[]
	ys_insertion = Float64[]
	xs_bubble = Float64[]
	ys_bubble = Float64[]
	xs_merge = Float64[]
	ys_merge = Float64[]
	
	rands = [rand(10^k) for k in 1:5] # 5x3 = 15s ±
	
	for i ∈ 1:length(rands)
		# Insertion Sort
		t_insertion = @benchmark insertion_sort!($(rands[i])) seconds=0.5
		push!(xs_insertion, i)
		# convert from nano seconds to seconds
		push!(ys_insertion, minimum(t_insertion).time / 10^9)
		
		# Bubble Sort
		t_bubble = @benchmark bubble_sort!($(rands[i])) seconds=0.5
		push!(xs_bubble, i)
		# convert from nano seconds to seconds
		push!(ys_bubble, minimum(t_bubble).time / 10^9)
		
		# Insertion Sort
		t_merge = @benchmark merge_sort($(rands[i])) seconds=0.5
		push!(xs_merge, i)
		# convert from nano seconds to seconds
		push!(ys_merge, minimum(t_merge).time / 10^9)
	end
	
	plot(xs_insertion, ys_insertion, label="Insertion Sort",
		leg=:topleft,
		yscale=:log10,
		xformatter= x -> L"10^ %$(Int(x))",
		xaxis="Tamanho da Array", yaxis="Tempo em Segundos")
	plot!(xs_bubble, ys_bubble, label="Bubble Sort")
	plot!(xs_merge, ys_merge, label="Merge Sort")
end

# ╔═╡ 2409fff2-8ddd-4619-86de-6267d01c3cda
md"""
# Inspecionando Funções com [`TimerOutputs.jl`](https://github.com/KristofferC/TimerOutputs.jl)

O uso é bem simples: só enfiar o macro `@timeit` dentro da função nas partes que você quer que seja cronometrada.

Ele traz a capivara toda também com **tempo** e **alocações**.

Primeiro vamos criar um tipo `TimerOuput` para armazenar as informações. Fazemos ele imutável com `const`:
"""

# ╔═╡ e0314a6b-5c98-47db-94bb-5c849986c3e6
const to = TimerOutput()

# ╔═╡ 6df83adb-42f6-4ba8-a10d-80526d1ffa70
md"""
Temos que mudar ligeramente a função:
"""

# ╔═╡ c6820844-3f25-4520-b43e-a735f477a77d
function merge_sort_to(X)
    @timeit to "length" n = length(X)
    
	@timeit to "if" begin
		if n ≤ 1
        	return X
		end
    end
    
	@timeit to "L merge_sort" L = merge_sort(X[1:n÷2])
    @timeit to "R merge_sort" R = merge_sort(X[n÷2+1:end])
    
	return merge(L, R)
end

# ╔═╡ 91066a2e-2ad4-4fbe-8687-2f219c91f53f
md"""
Agora executamos a função:
"""

# ╔═╡ 1f812f43-2d87-435e-a1ec-7bf6ad7456b3
merge_sort_to(vec_a)

# ╔═╡ 48c52370-f03c-4946-8f6c-7f016abee7b1
md"""
E chamamos de novo o tipo `TimerOuput`
"""

# ╔═╡ 49909905-3e36-4dc9-9b27-f044e2f927aa
to

# ╔═╡ a123ae5e-8850-4a92-b83d-f148652d061f
md"""
## Criando Diferentes níveis aninhados

Dá também para criarmos diferentes níveis aninhados:
"""

# ╔═╡ 33f7d334-e6df-448c-ae2e-7aa7f277005f
const to_nested = TimerOutput()

# ╔═╡ f5b5cb38-bbb7-42d6-93e0-1ccc1cb354b7
function merge_sort_to_nested(X)
    @timeit to_nested "length" n = length(X)
    
	@timeit to_nested "if" begin
		if n ≤ 1
        	return X
		end
    end
    @timeit to_nested "Merges" begin
		@timeit to_nested "L merge_sort" L = merge_sort(X[1:n÷2])
    	@timeit to_nested "R merge_sort" R = merge_sort(X[n÷2+1:end])
	end
    
	return merge(L, R)
end

# ╔═╡ a41de564-299b-4ea5-a1df-8b2e3c7f5d2a
merge_sort_to_nested(vec_a)

# ╔═╡ b22807f6-3449-4b5b-902f-e6699e9f7292
to_nested

# ╔═╡ 3bc698c5-2cc5-4940-9aca-d37053fb7cbd
md"""
!!! danger "⚠️ Alocações"
    Dá para ver que o problema do `merge_sort` é que ele contem diversas alocações. Uma boa ideia seria evitar essas alocações com um função com efeitos colaterais `merge_sort!`.
"""

# ╔═╡ b561e80e-a013-4b2f-81e8-d4a7676e1619
md"""
# Inspecionando Funções com [`Cthulhu.jl`](https://github.com/JuliaDebug/Cthulhu.jl)
"""

# ╔═╡ 47f5dea4-ca33-4ee4-ab69-6bef181dee22
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/cthulhu_logo.gif?raw=true", :width => 300)

# ╔═╡ 0b936e23-64d7-41e7-8eb9-b9b5c7b76011
md"""
O uso também é bem simples: basta anotar o código com o macro `@descend` para descer às "trevas" da representação mais baixo-nível possível da sua função:
"""

# ╔═╡ 39a43e8a-fe93-4afc-84ae-348390656d6b
md"""
```julia
@descend merge_sort(A)
```
"""

# ╔═╡ a046ac85-196c-41e4-8e19-8b1dba373255
md"""
```plaintext
                        v  %163  = invoke merge_sort(::Vector{Float64})
      From worker 2:	│ ─ %-1  = invoke merge_sort(::Vector{Float64})::Union{Vector{Any}, Vector{Float64}}
      From worker 2:	CodeInfo(
      From worker 2:	     @ /home/storopoli/Documents/Julia/Computacao-Cientifica/notebooks/2_BenchmarkTools.jl#==#f6d96868-9614-4301-8b27-397e1c37d0b0:2 within `merge_sort'
      From worker 2:	    ┌ @ array.jl:197 within `length'
      From worker 2:	1 ──│ %1   = Base.arraylen(X)::Int64
      From worker 2:	│   └
      From worker 2:	│    @ /home/storopoli/Documents/Julia/Computacao-Cientifica/notebooks/2_BenchmarkTools.jl#==#f6d96868-9614-4301-8b27-397e1c37d0b0:3 within `merge_sort'
      From worker 2:	│   ┌ @ int.jl:442 within `<='
      From worker 2:	│   │ %2   = Base.sle_int(%1, 1)::Bool
      From worker 2:	│   └
      From worker 2:	└───        goto #3 if not %2

```
"""

# ╔═╡ c81ada97-6dab-42e7-acf0-39a786e014c6
md"""
# Profile de Código Julia

A biblioteca padrão de Julia já tem um módulo para dar profile, chamado [`Profile`](https://docs.julialang.org/en/v1/manual/profile/) 🙄

```julia
using Profile
```

Para usar é o anotar sua função com o macro `@profile`
"""

# ╔═╡ e8b762a6-e8d8-4ada-b7e2-35c05c67efc4
@profile merge_sort(vec_a)

# ╔═╡ 642aacf6-ad3f-4c21-8fc0-494471d76b05
with_terminal() do
	Profile.print()
end

# ╔═╡ ddf83a10-b264-46e0-a34f-e7d3d9064b20
md"""
## Bibliotecas de Visualização de Profile

1. [`ProfileSVG.jl`](https://github.com/timholy/ProfileSVG.jl): Esse pacote é o pai do `@profview`. Gosto bastante. Em especial para Notebooks Pluto.

2. [VS Code Julia `@profview`](https://www.julia-vscode.org/docs/stable/release-notes/v0_17/#Profile-viewing-support-1): se estou no VS Code eu provavelmente usarei essa função nativa da extensão de Julia. Dá suporte para *flamegraph*.

3. [`FlameGraphs.jl`](https://github.com/timholy/FlameGraphs.jl)

4. [`ProfileView`](https://github.com/timholy/ProfileView.jl)

5. [`ProfileVega.jl`](https://github.com/davidanthoff/ProfileVega.jl)

6. [`StatProfilerHTML.jl`](https://github.com/tkluck/StatProfilerHTML.jl)

7. [`PProf.jl`](https://github.com/JuliaPerf/PProf.jl): wrapper do [`google/pprof`](https://github.com/google/pprof).
"""

# ╔═╡ 7a15fb68-d0d0-48ba-9072-45df4df4c94a
md"""
## `ProfileSVG.jl`

```julia
using Profile
using ProfileSVG
```
"""

# ╔═╡ be52ee6e-88e7-479a-9102-4d3f2632d3f5
@profview merge_sort(vec_a)

# ╔═╡ 7cf5acc3-65e2-4967-9857-7c48f27582ad
@profview insertion_sort!(vec_a)

# ╔═╡ cb0ee76f-b4f8-4dfa-b2e9-61c07502cb20
md"""
!!! tip "💡 Salvando o output do ProfileSVG"
	Use a função `ProfileSVG.save`, exemplo:
	```julia
	ProfileSVG.save(joinpath("imagens", "prof.svg"))
	```
"""

# ╔═╡ 8ef7cb22-67a0-4638-9656-d290149f7aa5
md"""
# Mais Informações sobre Inspeção de Código Julia

Veja esse Workshop da JuliaCon 2021 ([Código GitHub](https://github.com/aviatesk/juliacon2021-workshop-pkgdev))
"""

# ╔═╡ b052618d-90d9-480d-bf75-dc833f4cccd8
HTML("<style>.embed-container { position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; } .embed-container iframe, .embed-container object, .embed-container embed { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }</style><div class='embed-container'><iframe src='https://www.youtube.com/embed/wXRMwJdEjX4' frameborder='0' allowfullscreen></iframe></div>")

# ╔═╡ 5264685e-ddac-4a91-b550-b3769f832444
md"""
# Mais Informações sobre Ordenação em Julia

[`SortingAlgorithms.jl`](https://github.com/JuliaCollections/SortingAlgorithms.jl) possui implementações de HeapSort, TimSort e RadixSort.

[`SortingLab.jl`](https://github.com/xiaodaigh/SortingLab.jl) possui implementações de `sort` e `sortperm` mais rápidas que o `Base.sort` e `Base.sortperm`.
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

# ╔═╡ d8a50be6-165f-4277-a3d3-a96ef5fa8b24
md"""
# Licença

Este conteúdo possui licença [Creative Commons Attribution-ShareAlike 4.0 Internacional](http://creativecommons.org/licenses/by-sa/4.0/).

[![CC BY-SA 4.0](https://licensebuttons.net/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkPlots = "ab8c0f59-4072-4e0d-8f91-a91e1495eb26"
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
Cthulhu = "f68482b8-f384-11e8-15f7-abe071a5a75f"
InteractiveUtils = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Profile = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"
ProfileSVG = "132c30aa-f267-4189-9183-c8a63c7e05e6"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
StatsPlots = "f3b207a7-027a-5e70-b257-86293d7955fd"
TimerOutputs = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"

[compat]
BenchmarkPlots = "~0.1.0"
BenchmarkTools = "~1.2.0"
Cthulhu = "~1.6.1"
LaTeXStrings = "~1.2.1"
Plots = "~1.22.2"
PlutoUI = "~0.7.10"
ProfileSVG = "~0.2.1"
StatsPlots = "~0.14.27"
TimerOutputs = "~0.5.13"
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

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "a4d07a1c313392a77042855df46c5f534076fab9"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.0"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BenchmarkPlots]]
deps = ["BenchmarkTools", "RecipesBase"]
git-tree-sha1 = "1cf60c704455accbfab5d55da8f5d3475a37f20e"
uuid = "ab8c0f59-4072-4e0d-8f91-a91e1495eb26"
version = "0.1.0"

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "61adeb0823084487000600ef8b1c00cc2474cd47"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.2.0"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f2202b55d816427cd385a9a4f3ffb226bee80f99"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+0"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "bd4afa1fdeec0c8b89dad3c6e92bc6e3b0fec9ce"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.6.0"

[[Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "75479b7df4167267d75294d14b58244695beb2ac"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.14.2"

[[CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "9aa8a5ebb6b5bf469a7e0e2b5202cf6f8c291104"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.0.6"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "9995eb3977fbf67b86d0a0a0508e83017ded03f2"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.14.0"

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

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "1a90210acd935f222ea19657f143004d2c2a1117"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.38.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[Cthulhu]]
deps = ["CodeTracking", "FoldingTrees", "InteractiveUtils", "REPL", "UUIDs", "Unicode"]
git-tree-sha1 = "5e65dfced9daeae7fee72deab634f8a635442b8a"
uuid = "f68482b8-f384-11e8-15f7-abe071a5a75f"
version = "1.6.1"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

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

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distances]]
deps = ["LinearAlgebra", "Statistics", "StatsAPI"]
git-tree-sha1 = "9f46deb4d4ee4494ffb5a40a27a2aced67bdd838"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.4"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns"]
git-tree-sha1 = "f4efaa4b5157e0cdb8283ae0b5428bc9208436ed"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.16"

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
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

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
git-tree-sha1 = "463cb335fa22c4ebacfd1faba5fde14edb80d96c"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.5"

[[FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "3c041d2ac0a52a12a27af2782b34900d9c3ee68c"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.11.1"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "7f6ad1a7f4621b4ab8e554133dade99ebc6e7221"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.5"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[FlameGraphs]]
deps = ["AbstractTrees", "Colors", "FileIO", "FixedPointNumbers", "IndirectArrays", "LeftChildRightSiblingTrees", "Profile"]
git-tree-sha1 = "99c43a8765095efa6ef76233d44a89e68073bd10"
uuid = "08572546-2f56-4bcf-ba4e-bab62c3a3f89"
version = "0.2.5"

[[FoldingTrees]]
deps = ["AbstractTrees", "REPL"]
git-tree-sha1 = "e0c730b2d920d29edf8c381695e16c0a28055466"
uuid = "1eca21be-9b9b-4ed8-839a-6d8ae26b1781"
version = "1.0.1"

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

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "dba1e8614e98949abfa60480b13653813d8f0157"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+0"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "c2178cfbc0a5a552e16d097fae508f2024de61a3"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.59.0"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "ef49a187604f865f4708c90e3f431890724e9012"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.59.0+0"

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
git-tree-sha1 = "60ed5f1643927479f845b0135bb369b031b541fa"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.14"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "8a954fed8ac097d5be04921d595f741115c1b2ad"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+0"

[[HypertextLiteral]]
git-tree-sha1 = "72053798e1be56026b81d4e2682dbe58922e5ec9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.0"

[[IndirectArrays]]
git-tree-sha1 = "c2a145a145dc03a7620af1444e0264ef907bd44f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "0.5.1"

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
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "61aa005707ea2cebf47c8d780da8dc9bc4e0c512"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.4"

[[IrrationalConstants]]
git-tree-sha1 = "f76424439413893a832026ca355fe273e93bce94"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.0"

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
git-tree-sha1 = "c7f1c695e06c01b95a67f0cd1d34994f3e7db104"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.2.1"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a4b12a1bd2ebade87891ab7e36fdbce582301a92"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.6"

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
deps = ["ChainRulesCore", "DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "34dc30f868e368f8a17b728a1238f3fcda43931a"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.3"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "5455aef09b40e5020e1520f551fa3135040d4ed0"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2021.1.1+2"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "5a5bc6bf062f0f95e62d0fe0a2d99699fed82dd9"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.8"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

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

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

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
git-tree-sha1 = "c0e9e582987d36d5a61e650e6e543b9e44d9914b"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.7"

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
git-tree-sha1 = "4dd403333bcf0909341cfe57ec115152f937d7d8"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.1"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "9d8c00ef7a8d110787ff6f170579846f776133a9"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.4"

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
git-tree-sha1 = "2537ed3c0ed5e03896927187f5f2ee6a4ab342db"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.14"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "457b13497a3ea4deb33d273a6a5ea15c25c0ebd9"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.22.2"

[[PlutoUI]]
deps = ["Base64", "Dates", "HypertextLiteral", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "26b4d16873562469a0a1e6ae41d90dec9e51286d"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.10"

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

[[ProfileSVG]]
deps = ["Colors", "FlameGraphs", "Profile", "UUIDs"]
git-tree-sha1 = "e4df82a5dadc26736f106f8d7fc97c42cc6c91ae"
uuid = "132c30aa-f267-4189-9183-c8a63c7e05e6"
version = "0.2.1"

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

[[Ratios]]
deps = ["Requires"]
git-tree-sha1 = "01d341f502250e81f6fec0afe662aa861392a3aa"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.2"

[[RecipesBase]]
git-tree-sha1 = "44a75aa7a527910ee3d1751d1f0e4148698add9e"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.2"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

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

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "54f37736d8934a12a200edea2f9206b03bdf3159"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.7"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

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
deps = ["ChainRulesCore", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "ad42c30a6204c74d264692e633133dcea0e8b14e"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.6.2"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3240808c6d463ac46f1c1cd7638375cd22abbccb"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.12"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "8cbbc098554648c84f79a463c9ff0fd277144b6c"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.10"

[[StatsFuns]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "46d7ccc7104860c38b11966dd1f72ff042f382e4"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.10"

[[StatsPlots]]
deps = ["Clustering", "DataStructures", "DataValues", "Distributions", "Interpolations", "KernelDensity", "LinearAlgebra", "MultivariateStats", "Observables", "Plots", "RecipesBase", "RecipesPipeline", "Reexport", "StatsBase", "TableOperations", "Tables", "Widgets"]
git-tree-sha1 = "233bc83194181b07b052b4ee24515564b893faf6"
uuid = "f3b207a7-027a-5e70-b257-86293d7955fd"
version = "0.14.27"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

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

[[TableOperations]]
deps = ["SentinelArrays", "Tables", "Test"]
git-tree-sha1 = "019acfd5a4a6c5f0f38de69f2ff7ed527f1881da"
uuid = "ab02a1b2-a7df-11e8-156e-fb1833f50b87"
version = "1.1.0"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "1162ce4a6c4b7e31e0e6b14486a6986951c73be9"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.5.2"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "7cb456f358e8f9d102a8b25e8dfedf58fa5689bc"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.13"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

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

[[Widgets]]
deps = ["Colors", "Dates", "Observables", "OrderedCollections"]
git-tree-sha1 = "80661f59d28714632132c73779f8becc19a113f2"
uuid = "cc8bc4a8-27d6-5769-a93b-9d913e69aa62"
version = "0.6.4"

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
# ╟─a696704a-1347-47e0-9351-ced9d7f990c6
# ╠═27f62732-c909-11eb-27ee-e373dce148d9
# ╟─0aaee5c9-d992-44b0-a4bf-57d6a78f6c95
# ╟─339c28a4-d9f6-4f78-a01a-21de35fa3d3c
# ╟─66c95537-2f77-46df-b49d-9ab5b3dd176e
# ╟─1edba463-9d82-413a-b870-97b719e94a10
# ╟─f4560756-8e6b-4161-a8e2-c94935686034
# ╟─d2b7f7cf-a5c7-419b-a2d2-6ccd5c54da7f
# ╟─c2b12078-4039-4b3e-992a-7c2148aeef8b
# ╟─fadcb3cc-7a45-439f-be60-4d9137b07eab
# ╟─c31dbb4d-13e3-4e05-ad91-74e327f58b0d
# ╠═218b4f0d-51eb-4510-b528-7ec936ae8edd
# ╟─c6056836-9ce6-4e1e-ada2-cc07e1268e54
# ╟─eb456857-f736-47af-b450-9c13833cb488
# ╟─b68d6f0f-fe43-461c-9285-910c8cd14db8
# ╠═5b443be3-ccbb-4dd5-8ad0-4141b33f4b76
# ╟─3e2731a8-ac55-479d-a9a0-9b0dd7e7420d
# ╟─ee17d11a-955e-4884-930f-6bf61d1bfde0
# ╟─bef3ecdc-3867-44ed-adb9-cc45c778e67d
# ╠═f6d96868-9614-4301-8b27-397e1c37d0b0
# ╠═2c26b54d-ad41-45e0-a946-60d3c80ec368
# ╟─7a020487-c60e-49bd-b4aa-2fb6c371bc1d
# ╟─3515d81e-1910-474a-aebd-cffbbde66b37
# ╟─165b078c-492e-48af-8b07-7e354e807802
# ╟─3716b8c1-77e0-4582-b9d9-32262b2599a7
# ╠═854f4f41-345f-47f6-80d5-ea5e77f057ef
# ╟─e79acabe-bd68-42cd-9b46-76b83ccdaaf6
# ╠═35d57769-ad58-4c25-94af-987d6444dbf1
# ╠═91ab287d-ef5b-4393-a99d-bd52d7f0528e
# ╠═0be60c17-5b9a-40d7-b366-0cef5139815c
# ╟─07f57c1a-8927-4c02-8853-de1eddfb4054
# ╟─ab63e097-2b40-4d98-9e2a-b5b8103c4877
# ╟─7108159a-e33e-473d-85a1-a2785e72fda7
# ╟─b5d98492-efae-46b8-ac79-3a854f113c2d
# ╟─1d1550ca-61aa-4143-a039-025eb8c56efe
# ╟─677f3b32-6196-46a2-9189-0d93cf5729d8
# ╠═7ed1f94e-ce96-4ef9-8372-4579a22f561f
# ╠═26e99f87-0f14-45fc-a55d-d6f4818dc181
# ╟─ad238529-9718-45a0-8b20-25df03182b25
# ╠═5744bb5f-4f0a-444c-8a9c-08540323542e
# ╠═b3219ad5-b945-4d43-ad13-13bff76b0ef0
# ╠═cd71c1e7-050c-4ad0-b485-1b36cbd6b1a0
# ╠═22e4bdf1-2637-42db-b71a-aff516ca0711
# ╠═b28e53b7-f049-4315-83e5-d08fb69ef377
# ╠═e129526d-b413-48ea-98d3-08e2c960f89c
# ╠═b254962c-f7d8-4f49-b6cf-585f6e825975
# ╠═5e461561-9c19-480b-bbd9-13fc4b4d5343
# ╠═dff1efb1-5db1-43dd-ac2e-451375bc1c1b
# ╠═bae6a808-119d-471a-a39d-34d1fea28b0e
# ╟─0aeaf17a-6fcf-4da0-9185-67142cfdb272
# ╠═47677be0-f211-400e-a522-78d0a6364954
# ╟─ba3a91b1-bf53-4e22-9dbc-8e5029df9c26
# ╟─6bb03874-89b3-4925-94aa-7befc4f58cee
# ╠═c3967255-7b74-4999-a764-df56759803b4
# ╠═bc051646-3f99-4052-a97a-747e4c60b000
# ╠═876c8fef-e98e-482e-9f2a-98124cc83f77
# ╠═b08ee953-bd89-4805-9fda-d1c5f0133323
# ╟─f0715632-54b1-4e5f-9290-a770e36c99ba
# ╟─2409fff2-8ddd-4619-86de-6267d01c3cda
# ╠═e0314a6b-5c98-47db-94bb-5c849986c3e6
# ╟─6df83adb-42f6-4ba8-a10d-80526d1ffa70
# ╠═c6820844-3f25-4520-b43e-a735f477a77d
# ╟─91066a2e-2ad4-4fbe-8687-2f219c91f53f
# ╠═1f812f43-2d87-435e-a1ec-7bf6ad7456b3
# ╟─48c52370-f03c-4946-8f6c-7f016abee7b1
# ╠═49909905-3e36-4dc9-9b27-f044e2f927aa
# ╟─a123ae5e-8850-4a92-b83d-f148652d061f
# ╠═33f7d334-e6df-448c-ae2e-7aa7f277005f
# ╠═f5b5cb38-bbb7-42d6-93e0-1ccc1cb354b7
# ╠═a41de564-299b-4ea5-a1df-8b2e3c7f5d2a
# ╠═b22807f6-3449-4b5b-902f-e6699e9f7292
# ╟─3bc698c5-2cc5-4940-9aca-d37053fb7cbd
# ╟─b561e80e-a013-4b2f-81e8-d4a7676e1619
# ╟─47f5dea4-ca33-4ee4-ab69-6bef181dee22
# ╟─0b936e23-64d7-41e7-8eb9-b9b5c7b76011
# ╟─39a43e8a-fe93-4afc-84ae-348390656d6b
# ╟─a046ac85-196c-41e4-8e19-8b1dba373255
# ╟─c81ada97-6dab-42e7-acf0-39a786e014c6
# ╠═e8b762a6-e8d8-4ada-b7e2-35c05c67efc4
# ╠═642aacf6-ad3f-4c21-8fc0-494471d76b05
# ╟─ddf83a10-b264-46e0-a34f-e7d3d9064b20
# ╟─7a15fb68-d0d0-48ba-9072-45df4df4c94a
# ╠═be52ee6e-88e7-479a-9102-4d3f2632d3f5
# ╠═7cf5acc3-65e2-4967-9857-7c48f27582ad
# ╟─cb0ee76f-b4f8-4dfa-b2e9-61c07502cb20
# ╟─8ef7cb22-67a0-4638-9656-d290149f7aa5
# ╟─b052618d-90d9-480d-bf75-dc833f4cccd8
# ╟─5264685e-ddac-4a91-b550-b3769f832444
# ╟─d548bc1a-2e20-4b7f-971b-1b07faaa4c13
# ╟─228e9bf1-cfd8-4285-8b68-43762e1ae8c7
# ╟─23974dfc-7412-4983-9dcc-16e7a3e7dcc4
# ╟─d8a50be6-165f-4277-a3d3-a96ef5fa8b24
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
