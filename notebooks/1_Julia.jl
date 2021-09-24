### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# ╔═╡ 27f62732-c909-11eb-27ee-e373dce148d9
begin
	using BenchmarkTools
	using LinearAlgebra
	
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

# ╔═╡ e4dbc9c7-cc0d-4305-ac6a-c562b233d965
Resource("https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg", :width => 120, :display => "inline")

# ╔═╡ ebc2a29a-2ad9-457f-8b9c-344fbc955a15
HTML("<style>.embed-container { position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; } .embed-container iframe, .embed-container object, .embed-container embed { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }</style><div class='embed-container'><iframe src='https://www.youtube.com/embed/qGW0GT1rCvs' frameborder='0' allowfullscreen></iframe></div>")

# ╔═╡ 6f1bec92-7703-4911-8ff5-668618185bf4
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/llvm_julia_meme.jpg?raw=true", :width => 400)

# ╔═╡ 32b4273d-06d9-4450-97d0-23740cf7bd88
function summed(a)
	result = 0
  	for x in a
    	result += x
  	end
  return result
end

# ╔═╡ 673ec92c-e813-424a-b4d9-4ff36bb887d2
vec_a = randn(42_000)

# ╔═╡ 584973af-9d1c-4c79-ad0b-f4c8f8b39ee3
@benchmark summed($vec_a)

# ╔═╡ bdbe2067-2101-4f36-a64d-442afc9c20dc
function sumsimd(a)
	result = zero(eltype(a))
	@simd for x in a
    	result += x
  	end
  return result
end

# ╔═╡ 6be5724f-78ed-49e4-8ac5-07caea58a4ee
@benchmark sumsimd($vec_a) # 🚀

# ╔═╡ 959e2288-ee21-4541-9ce0-537716190733
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/toasty.jpg?raw=true")

# ╔═╡ a0f907f5-1d81-451e-b34b-8d622e5e47a2
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/benchmarks.svg?raw=true")

# ╔═╡ de862c54-cd85-493e-9140-4682c8c25d9a
√2

# ╔═╡ 3e20679b-04d5-48c0-b788-958fcfcd97c3
π

# ╔═╡ 1768f19a-4158-4597-9110-450f81a67986
ℯ

# ╔═╡ 98ead09d-8ca9-41a4-95cf-fc07bd34db16
sizeof(1) # 8 bytes

# ╔═╡ 107f0d48-cd18-4456-8b5e-4971b5fbe2e8
typeof(UInt(1) + 1)

# ╔═╡ fc833387-ae84-4220-9086-ee5dedb11d9d
abstract type Things end

# ╔═╡ 3b64cd4e-f9cf-4a57-b971-58ea76b748c9
struct Foo <: Things end

# ╔═╡ 468b1950-195d-43f5-8d1c-105abe84d439
struct Bar <: Things end

# ╔═╡ e783aa1f-e96b-4abd-9daa-ac668b0f79cd
f(::Things) = "Just a Thing"

# ╔═╡ 61a5142f-5a69-4913-96e9-5582259fbd7a
f(x::Foo) = "Just Foo"

# ╔═╡ 5a52e20b-ff55-462b-ab87-03f4f38138c0
f(x::Bar) = "Just Bar"

# ╔═╡ ff24f4a0-bd0e-4dc7-b8bf-504b5ac05096
x = Foo()

# ╔═╡ 87bed413-6237-4c16-9459-41f4b868e1be
y = Bar()

# ╔═╡ d4bea1f2-e30d-4fff-bdad-644b80f4e704
f(x)

# ╔═╡ c7e13998-1b4b-4363-b89a-a1f2c8f92a1a
f(y)

# ╔═╡ 7412d8ce-dc0c-42be-800d-fe222c48a1f9
HTML("<style>.embed-container { position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; } .embed-container iframe, .embed-container object, .embed-container embed { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }</style><div class='embed-container'><iframe src='https://www.youtube.com/embed/kc9HwsxE1OY' frameborder='0' allowfullscreen></iframe></div>")

# ╔═╡ ee77185f-1abf-425a-aec0-1f84f54bcb41
abstract type Pet end

# ╔═╡ 461bd896-6d65-4b76-8934-2e38cfd86231
struct Dog <: Pet
	name::String
end

# ╔═╡ 06009452-af10-4ed6-aa52-60297536efd9
struct Cat <: Pet
	name::String
end

# ╔═╡ ef284b80-4fbe-4af4-9ab1-145f5d3be67d
meets(a::Dog, b::Dog) = "sniffs"

# ╔═╡ 3762fb2b-e263-4451-968b-9b7b03cf1db1
meets(a::Dog, b::Cat) = "chases"

# ╔═╡ d50a833f-590f-4b0f-87cd-b2e9c3eacb0e
meets(a::Cat, b::Dog) = "hisses"

# ╔═╡ 0aa44c17-70dc-42f5-a7f0-8eddbe0dc0b8
meets(a::Cat, b::Cat) = "slinks"

# ╔═╡ 1d939b3d-43ad-40b5-8001-4465579b7a15
function encounter(a::Pet, b::Pet)
	verb = meets(a, b)
	return "$(a.name) meets $(b.name) and $verb"
end

# ╔═╡ b3942ceb-31f4-4dfd-818e-c50e81262853
fido = Dog("Fido")

# ╔═╡ ef621d5e-f69b-44b1-a8c7-fe4b3fc64232
rex = Dog("Rex")

# ╔═╡ 90ab5ecf-7a4a-406e-9cec-bd83195b88d7
whiskers = Cat("Whiskers")

# ╔═╡ 0c119847-6137-49aa-aac9-247ee630dcdd
spots = Cat("Spots")

# ╔═╡ a1f56329-5883-42ec-a747-52ba24800eb6
encounter(fido, rex)

# ╔═╡ fd342dc5-f775-4597-bad8-da131f127ab2
encounter(rex, whiskers)

# ╔═╡ 83bbae2f-1510-4d46-b88a-bb966ec8fe89
encounter(spots, fido)

# ╔═╡ 5c433041-9de3-4245-bbb1-393b9a26101d
encounter(whiskers, spots)

# ╔═╡ 8faf0fee-cad5-440f-bc2d-0fdb848ce42d
struct OneHotVector <: AbstractVector{Int}
	len::Int
	ind::Int
end

# ╔═╡ cb276e1e-1b81-4705-b28b-b7b3e08332bc
begin
	import Base: size, getindex
	
	size(v::OneHotVector) = (v.len,)
	getindex(v::OneHotVector, i::Integer) = Int(i == v.ind)
end

# ╔═╡ 7bb67403-d2ac-4dc9-b2f1-fdea7a795329
md"""
# Linguagem Julia e Estrutura de Dados Nativas
"""

# ╔═╡ 92216109-f448-495d-8114-d7e4c6e2b5f0
md"""
## Por quê Julia?

1. O mais importante, **velocidade** 🏎
2. Linguagem dinâmica de **fácil** codificação e prototipagem 👩🏼‍💻
3. **Despacho múltiplo** ⚡️
"""

# ╔═╡ c0212d94-246c-4129-b2c7-65a3b107d951
md"""
A combinação dos motivos acima gera ainda:

* 1 + 2 = eliminação do **problema das duas linguagens** 😱
* 2 + 3 = **facilidade de compartilhar** tipos definido pelo usuário e código em pacotes modulares 🎁

Além disso temos:
* suporte à caracteretes unicode: 😎 e $\LaTeX$
"""

# ╔═╡ 165e0a37-dd2c-4dae-8cc6-b80615af6e30
md"""
!!! info "💁 Open Source"
    Óbvio mas preciso dizer que Julia é gratuita e de código aberto.
	
	#ChupaMatlab
"""

# ╔═╡ d5c8264f-defe-4e4c-b072-093c580a19af
md"""
!!! tip "💡 O Estado de Julia (Julho/2021)"
    - 6.008 [pacotes](https://juliahub.com/ui/Packages)
	- 9,003 perguntas no [StackOverflow](https://stackoverflow.com/questions/tagged/julia)
	- 34.4K Estrelas GitHub [`JuliaLang/julia`](https://github.com/JuliaLang/julia)
"""

# ╔═╡ 89dbf386-2216-400e-ab36-05599e1fb4c7
md"""
## Como eu uso Júlia?

Instale acessando [julialang.org](https://julialang.org).
"""

# ╔═╡ 575a6998-032b-40fb-9942-6ec39b1b69d7
md"""
```julia
$ julia

               _
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.6.1 (2021-04-23)
 _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org/ release
|__/                   |


julia>
```
"""

# ╔═╡ 6c5d8d8f-b08f-4550-bc1b-9f19a6152bd4
md"""
$(Resource("https://raw.githubusercontent.com/fonsp/Pluto.jl/master/frontend/img/logo.svg", :width => 200))

$(HTML("<br>"))

$(Resource("https://raw.githubusercontent.com/fonsp/Pluto.jl/580ab811f13d565cc81ebfa70ed36c84b125f55d/demo/plutodemo.gif", :width => 400))
"""

# ╔═╡ 3e2441b6-1545-4f34-a418-f61b2dbf61e9
md"""
$(Resource("https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Visual_Studio_Code_1.35_icon.svg/1200px-Visual_Studio_Code_1.35_icon.svg.png", :width => 50))

$(HTML("<br>"))

$(Resource("https://www.julia-vscode.org/img/newscreen1.png", :width => 500))


"""

# ╔═╡ 0659cb16-eea6-4ef7-90e7-27a50deee15f
md"""
## Velocidade 🏎
"""

# ╔═╡ 3712de35-d34e-4f6f-9041-cac2efb2730a
md"""
!!! tip "💡 Como Julia Funciona"
	Julia funciona assim: ela pega o **código em Julia e expõe em linguagem de montagem (*Assembly*) para o compilador LLVM** fazer o que sabe melhor: otimizar o código como quiser.
"""

# ╔═╡ 9b8cac39-97ed-465c-bacb-1841c6926280
md"""
### Loops são rápidos!
"""

# ╔═╡ d9b7c5bc-2f99-4721-8910-41497e307689
md"""
#### Enquanto isso em Python


```python
def summed(a):
  result = 0
  for x in a:
    result += x
  return result

import random
a = [ random.random() for _ in range(42000) ]

%timeit summed(a)
```

> 909 µs ± 18.4 µs per loop (mean ± std. dev. of 7 runs, 1000 loops each)
"""

# ╔═╡ ec8aa40e-a6d4-46db-8d76-99e53f876fdd
md"""
#### Ou em `NumPy`

```python
import numpy as np

a = np.random.randn(42000)
n = 1000

%timeit a.sum()
```

> 12.5 µs ± 885 ns per loop (mean ± std. dev. of 7 runs, 100000 loops each)
"""

# ╔═╡ c9be26cf-08d1-4927-b2da-a3cf4d1023ee
md"""
E se colocarmos paralelismo [SIMD](https://en.wikipedia.org/wiki/SIMD) pois as operações no loop são associativas:
"""

# ╔═╡ d79ec91b-353f-4986-90a6-be613b20bff7
md"""
> OBS resposta original no meu computador é 12.5 μs (Python) vs 2.83 μs (Julia)
"""

# ╔═╡ d90ce98c-6538-4a6d-9b45-e3f5c8ae2bb3
md"""
### Alguns Projetos Interessantes:

1. NASA usa Julia em super computador para analisar o ["maior conjunto de Planetas do tamanho da Terra já encontrados"](https://exoplanets.nasa.gov/news/1669/seven-rocky-trappist-1-planets-may-be-made-of-similar-stuff/) e conseguiu impressionantes **acelerações 1,000x** em catalogar 188 milhões de objetos astronômicos em 15 minutos!


2. [A Climate Modeling Alliance (CliMa)](https://clima.caltech.edu/) está usando majoritariamente Julia para **modelar clima na GPU e CPU**. Lançado em 2018 em colaboração com pesquisadores da Caltech, do Laboratório de Propulsão a Jato da NASA e da Escola de Pós-Graduação Naval, o CLIMA está utilizando o progresso recente da ciência computacional para desenvolver um modelo de sistema terrestre que pode prever secas, ondas de calor e chuvas com precisão sem precedentes.


3. [A Administração Federal de Aviação dos EUA (FAA) está desenvolvendo um **Sistema de prevenção de colisão aerotransportada (ACAS-X)** usando Julia] (https://youtu.be/19zm1Fn0S9M). Soluções anteriores usavam Matlab para desenvolver os algoritmos e C ++ para uma implementação rápida. Agora, a FAA está usando uma linguagem para fazer tudo isso: Julia.


4. [**Aceleração de 175x** para modelos de farmacologia da Pfizer usando GPUs em Julia] (https://juliacomputing.com/case-studies/pfizer/). Foi apresentado como um [pôster](https://chrisrackauckas.com/assets/Posters/ACoP11_Poster_Abstracts_2020.pdf) na 11ª Conferência Americana de Farmacometria (ACoP11) e [ganhou um prêmio de qualidade](https: //web.archive .org / web / 20210121164011 / https: //www.go-acop.org/abstract-awards).


5. [O simulador do Subsistema de Controle de Atitude e Órbita (AOCS) do satélite brasileiro Amazonia-1 é **escrito 100% em Julia**](https://discourse.julialang.org/t/julia-and-the-satellite -amazonia-1/57541) por [Ronan Arraes Jardim Chagas](https://ronanarraes.com/). Além disso, Julia é usada para inúmeras atividades relacionadas com a Análise de Missão do mesmo satélite.


6. [O Banco Nacional de Desenvolvimento do Brasil (BNDES) abandonou uma solução paga e optou pela modelagem Julia de código aberto e ganhou uma **aceleração 10x**.](https://youtu.be/NY0HcGqHj3g)



Se isso não for suficiente, há mais estudos de caso no [site da Julia Computing] (https://juliacomputing.com/case-studies/).
"""

# ╔═╡ 9104cac0-b5a8-4a54-a636-6475c0d3489f
md"""
### Um exemplo prático com dados tabulares

##### Julia `DataFrames.jl`:
```julia
using DataFrames, BenchmarkTools


n = 10_000

df = DataFrame(
    x=rand(["A", "B", "C", "D"], n),
    y=rand(n),
    z=randn(n),
)

@benchmark combine(groupby($df, :x), :y => median, :z => mean)
```

##### Python `pandas`:
```python
import pandas as pd
import numpy as np

n = 10000

df = pd.DataFrame({'x': np.random.choice(['A', 'B', 'C', 'D'], n, replace=True),
                   'y': np.random.rand(n),
                   'z': np.random.randn(n)})

%timeit df.groupby('x').agg({'y': 'median', 'z': 'mean'})
```

##### R `dplyr`:
```R
library(dplyr)

n <- 10e3
df <- tibble(
    x = sample(c("A", "B", "C", "D"), n, replace = TRUE),
    y = runif(n),
    z = rnorm(n)
)

bench::mark(
    df %>%
        group_by(x) %>%
        summarize(
            median(y),
            mean(z)
        )
)
```
"""

# ╔═╡ cf994c69-7adb-4461-8273-165574072582
md"""
#### Resultados:

* **Julia: 0.368ms** 🚀

* Python: 1.57ms 🙈

* R: 2.52ms #vairubinho 🐌

"""

# ╔═╡ 3c911397-cb1d-4929-b0e8-4aff516331b5
md"""
## Facilidade de Codificação

!!! tip "💡 Unicode"
    Veja o suporte à unicode e $\LaTeX$.
"""

# ╔═╡ 7659200b-163c-4127-be46-93ed949fb8ae
md"""
```julia
using Statistics, LinearAlgebra

function gradient_descent(𝒟train, φ, ∇loss; η=0.1, T=100)
    𝐰 = zeros(length(φ(𝒟train[1][1])))
    for t in 1:T
        𝐰 = 𝐰 .- η*mean(∇loss(x, y, 𝐰, φ) for (x,y) ∈ 𝒟train)
    end
    return 𝐰
end
```

```julia
using LinearAlgebra

dist_manhattan(𝐯, 𝐯′) = norm(𝐯 - 𝐯′, 1)
dist_euclidean(𝐯, 𝐯′) = norm(𝐯 - 𝐯′, 2)
dist_supremum(𝐯, 𝐯′)  = norm(𝐯 - 𝐯′, Inf)
```

```julia
using Distributions

function metropolis(S, ρ; μ_x=0.0, μ_y=0.0, σ_x=1.0, σ_y=1.0)
    binormal = MvNormal([μ_x; μ_y], [σ_x ρ; ρ σ_y]);
    draws = Matrix{Float64}(undef, S, 2);
    x = rand(Normal(μ_x, σ_x))
	y = rand(Normal(μ_x, σ_x))
    accepted = 0
    for s in 1:S
        xₚ = rand(Normal(μ_x, σ_x))
        yₚ = rand(Normal(μ_x, σ_x))
        r = exp(logpdf(binormal, [xₚ, yₚ]) - logpdf(binormal, [x, y]))

        if r > rand(Uniform())
            x = xₚ
            y = yₚ
            accepted += 1;
        end
        @inbounds draws[s, :] = [x y]
    end
    println("Acceptance rate is $(accepted / S)")
    return draws
end
```
"""

# ╔═╡ 36603633-5af5-4cdf-b6c9-9d87c23492e2
md"""

$(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/language_comparisons.svg?raw=true"))
"""

# ╔═╡ ac147d47-71eb-482a-a52d-ab3b6bf33db3
md"""
Outra coisa a observar que acho bastante surpreendente é que os pacotes de Julia são todos escritos em Julia. Isso não acontece em outras linguagens de computação científica. Por exemplo, todo o ecossistema `{tidyverse}` de pacotes R é baseado em C++. `NumPy` e `SciPy` são uma mistura de FORTRAN e C. `Scikit-Learn` também é codificado em C.
"""

# ╔═╡ 1b79ac6f-7be3-4c5b-903e-be26e134be87
md"""
### Python my a**! (Arrays)

$(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/Array_code_breakdown.svg?raw=true"))
"""

# ╔═╡ b6acb557-1a04-4021-a103-4be3a066be38
md"""
### Python my a**! (Deep Learning)

$(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/ML_code_breakdown.svg?raw=true"))
"""

# ╔═╡ a2ba234a-ff84-498f-84df-778dc3c5c6c8
md"""
### Qual o propósito de Python?
$(Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/python_meme.jpg?raw=true", :width => 400))
"""

# ╔═╡ a3ba253e-fbda-471e-ab82-c2ddeaf3ddf9
md"""
### Pequeno Interlúdio para falar mal de Python
"""

# ╔═╡ a6a7bccf-4012-450c-ac02-9fdef68f0c9e
md"""
#### Int64 são 8 bytes né? #sqn
"""

# ╔═╡ e4e6e448-eac0-40ec-ac91-c79c3c4f040e
md"""
```python
from sys import getsizeof
getsizeof(1)

> 28
```
"""

# ╔═╡ e30005e0-540a-48ec-92ef-351c07c86912
md"""
#### `UInt` + `Int` Positivo = `UInt`?
"""

# ╔═╡ fcb0a3f9-ebdd-40e5-968c-2f3644dcc095
md"""
```python
import numpy as np
type(np.uint(1) + 1)

> numpy.float64
```
"""

# ╔═╡ 6a45dd9a-1117-4591-b284-80cac24bb541
md"""
## Despacho Múltiplo

!!! danger "⚠️ Conhecimento Técnico"
    Esse conteúdo parte do pressuposto que você saiba o que é programação orientada a objetos. Em especial, vamos expor código C++ e Python.
"""

# ╔═╡ 180e897c-ea27-44bb-9f93-1a1dd13aaf71
md"""
Acho que este é a verdadeira pérola da linguagem Julia: a capacidade de definir o **comportamento da função em muitas combinações de tipos de argumento por meio de [despacho múltiplo](https://en.wikipedia.org/wiki/Multiple_dispatch)**.

**Despacho múltiplo** é um recurso que permite que uma função ou método seja **despachado dinamicamente** com base no tipo de tempo de execução (dinâmico) ou, no caso mais geral, algum outro atributo de mais de um de seus argumentos.

Esta é uma generalização do **polimorfismo de despacho único**, em que uma função ou chamada de método é despachada dinamicamente com base no tipo derivado do objeto no qual o método foi chamado. O despacho múltiplo roteia o despacho dinâmico para a função ou método de implementação usando as características combinadas de um ou mais argumentos.
"""

# ╔═╡ e0057d14-f306-4eaa-9ac3-e83500c8be59
md"""

### Tentativa em Python

```python
>>> class Foo:
...     x = 1
...

>>> class Bar:
...     x = 1
...

>>> def f(a: Foo):
...     print("Just Foo")
...

>>> a = Foo()
>>> b = Bar()
>>> f(a)
Just Foo

>>> def f(b: Bar):
...     print("Just Bar")
...
>>> f(b)
"Just Bar"

>>> f(a)
"Just Bar"
```

> Exemplo adaptado de [Miguel Raz Guzmán Macedo](https://miguelraz.github.io/blog/dispatch/)
"""

# ╔═╡ 01949b8b-702f-4e82-9c48-3619b67133fa
md"""
### Agora em Julia ⚡
"""

# ╔═╡ b4938cbd-27bc-4999-919a-a32e503dadb0
md"""
### Tentativa em C++

```c++
#include <iostream>
#include <string>

using std::string;
using std::cout;

class Pet {
    public:
        string name;
};

string meets(Pet a, Pet b) { return "FALLBACK"; } // `return meets(a, b)` não funciona

void encounter(Pet a, Pet b) {
    string verb = meets(a, b);
    cout << a.name << " meets "
         << b. name << " and " << verb << '\n';
}

class Cat : public Pet {};
class Dog : public Pet {};

string meets(Dog a, Dog b) { return "sniffs"; }
string meets(Dog a, Cat b) { return "chases"; }
string meets(Cat a, Dog b) { return "hisses"; }
string meets(Cat a, Cat b) { return "slinks"; }

int main() {
    Dog fido;      fido.name     = "Fido";
    Dog rex;       rex.name      = "Rex";
    Cat whiskers;  whiskers.name = "Whiskers";
    Cat spots;     spots.name    = "Spots";

    encounter(fido, rex);
    encounter(rex, whiskers);
    encounter(spots, fido);
    encounter(whiskers, spots);

    return 0;
}
```

```bash
g++ main.cpp && ./a.out

Fido meets Rex and FALLBACK
Rex meets Whiskers and FALLBACK
Spots meets Fido and FALLBACK
```

> Exemplo adaptado de uma apresentação do [Stefan Karpinski na JuliaCon 2019](https://youtu.be/kc9HwsxE1OY)
"""

# ╔═╡ c2875c4e-e49e-42e6-ad88-bddc790550b9
md"""
### Agora em Julia ⚡
"""

# ╔═╡ 1d46cf0f-a322-4447-9192-133c6e4085b8
md"""
!!! info "💁 Exemplo com Pokemons"
    Tem um [exemplo de despacho múltiplo muito bem feito com Pokemons](https://www.moll.dev/projects/effective-multi-dispatch/). Vale a pena conferir.
"""

# ╔═╡ 81ae472d-7195-4525-87ae-1429972b8816
md"""
### Exemplo: One-Hot Vector

Um one-hot vector é um **vetor de inteiros em que todos os elementos são zero (0) exceto para um único elemento que é um (1)**.

No **aprendizado de máquina**, a codificação one-hot é um método frequentemente usado para lidar com **dados categóricos**. Como muitos modelos de aprendizado de máquina precisam que suas variáveis de entrada sejam numéricas, as variáveis categóricas precisam ser transformadas na parte de **pré-processamento de dados**.

Como representaríamos vetores one-hot em Julia?

**Simples**: criamos um novo tipo `OneHotVector` em Julia usando a palavra-chave `struct` e definimos dois campos `len` e `ind`, que representam o comprimento (*length*) do `OneHotVector` e cujo índice (*index*) é a entrada 1 (ou seja, qual índice é "quente"). Em seguida, definimos novos métodos para as funções do módulo `Base` de Julia `size()` e `getindex()` para nosso recém-definido `OneHotVector`.

> Exemplo altamente inspirado em um [post de Vasily Pisarev](https://habr.com/ru/post/468609/)
"""

# ╔═╡ 7d03d2be-d9bd-4992-bb60-a8eb266a956c
meu_hot = OneHotVector(3, 2)

# ╔═╡ 20c73247-0555-4962-bd01-152a68b3b782
meu_hot[2]

# ╔═╡ 2538921e-6b35-4f84-9e76-e246cd28ecd8
md"""
Como `OneHotVector` é uma estrutura derivada de `AbstractVector`, podemos usar todos os métodos já definidos para `AbstractVector` e ele simplesmente funciona imediatamente. Aqui, estamos construindo uma `Array` com uma compreensão de array:
"""

# ╔═╡ 7bbbebc8-8a2b-45de-aa25-aa1bec443f43
onehot = [OneHotVector(3, rand(1:3)) for _ in 1:4]

# ╔═╡ 8f815967-ec04-44b7-aeae-4ae48b1429c7
md"""
Agora defino uma nova função `inner_sum()` que é basicamente um produto escalar recursivo com um somatório. Aqui `A` - isso é algo parecido com uma matriz (embora eu não indiquei os tipos e você possa adivinhar algo apenas pelo nome) e `vs` é um vetor de alguns elementos parecidos com vetores. A função prossegue pegando o produto escalar da "matriz" com todos os elementos semelhantes a vetores de `vs` e retornando os valores acumulados. Tudo isso recebe uma definição genérica sem especificar nenhum tipo.

A programação genérica aqui consiste na própria chamada de função `inner()` em um *loop*.
"""

# ╔═╡ 92dac6c4-a85b-496c-b022-ef68b8e1e595
md"""
"Olha mãe, funciona!"
"""

# ╔═╡ d83443d7-ea65-48a7-bc88-2ed51762ac82
A = rand(3, 3)

# ╔═╡ 88ab49be-8770-4c04-874f-db964d89dc2c
vs = [rand(3) for _ in 1:4]

# ╔═╡ e7272270-5ecf-4c33-b550-3caf354247fb
md"""
Como `OneHotVector` é um subtipo de `AbstractVector`:
"""

# ╔═╡ 7376684a-75be-46c9-867c-34d6e625edae
supertype(OneHotVector)

# ╔═╡ 3d3f64f4-bf19-4684-9a29-8fee1dfbe9c9
md"""
Conseguimos usar `innersum` e vai funcionar que é uma beleza:
"""

# ╔═╡ 5aa224c5-a05a-438d-ba0a-fadce5f46592
md"""
Mas essa implementação é bem **lenta**:
"""

# ╔═╡ 41801f25-e95a-49bc-9454-0328f13684b6
md"""
Podemos otimizar muito este procedimento.

Veja que multiplicação de matrizes por vetores one-hot é simplesmente uma indexação de colunas:

$$\begin{bmatrix}
1 & 2 & 3\\
4 & 5 & 6 \\
7 & 8 & 9

\end{bmatrix}

\cdot

\begin{bmatrix}
0 \\ 1 \\ 0
\end{bmatrix}
=

\begin{bmatrix}
2 \\ 5 \\ 8
\end{bmatrix}$$

Agora vamos redefinir a multiplicação da matriz por `OneHotVector` com uma seleção de coluna simples. Fazemos isso definindo um novo método da função `*` (função multiplicadora) do módulo `Base` Julia:
"""

# ╔═╡ 8c7d2d8a-c547-45c1-bcf5-636584cdb3da
begin
	import Base:*
	
	*(A::AbstractMatrix, v::OneHotVector) = A[:, v.ind]
end

# ╔═╡ 43f8ee8b-7d74-4ef3-88fe-41c44f0a0eee
quadratic(a, sqr_term, b) = (-b + sqr_term) / 2a

# ╔═╡ 238e3cc9-6ea1-4f23-8a4a-0a58de6fd014
inner(v, A, w) = dot(v, A * w) # very general definition

# ╔═╡ f6042d46-94bf-45ad-aa23-f5e256c67571
md"""
Além disso, também criamos um novo método otimizado de `inner()` para lidar com `OneHotVector`:

$$\begin{bmatrix}
1 & 0 & 0
\end{bmatrix}

\cdot

\begin{bmatrix}
1 & 2 & 3\\
4 & 5 & 6 \\
7 & 8 & 9
\end{bmatrix}


=

\begin{bmatrix}
1 & 2 & 3
\end{bmatrix}$$

Logo:

$$\begin{bmatrix}
1 & 0 & 0
\end{bmatrix}

\cdot

\begin{bmatrix}
1 & 2 & 3\\
4 & 5 & 6 \\
7 & 8 & 9
\end{bmatrix}

\cdot

\begin{bmatrix}
0 \\ 1 \\ 0
\end{bmatrix}

=

2$$
"""

# ╔═╡ fa434fbe-0999-4c45-8ae2-87f5652c1b52
inner(v::OneHotVector, A, w::OneHotVector) = A[v.ind, w.ind]

# ╔═╡ ecdabab9-c2c4-4f89-bcef-a2ddc1e782d3
function inner_sum(A, vs)
	t = zero(eltype(A))
	for v in vs
		t += inner(v, A, v) # multiple dispatch!
	end
	return t
end

# ╔═╡ 6c559966-7d63-4b69-bcf7-0ae90835fa9c
inner_sum(A, vs)

# ╔═╡ 250cbe36-059b-4681-925f-fccf1d6095d2
inner_sum(A, onehot)

# ╔═╡ 39ddde6a-9030-430c-ae39-1033720fd43a
md"""
# Sintaxe da Linguagem Julia

!!! info "💁 Convenções de Sintaxe"
	**CamelCase** são `type`s, `struct`s, `module`s e `package`s

	**snake_case** é o resto: funções, métodos ou variáveis instanciadas
"""

# ╔═╡ 8e63e4f2-ef86-4a9d-ab21-4194965c32ba
md"""
## Variáveis

* Números Inteiros: `Int64`
* Números Reais: `Float64`
* Booleanas: `Bool`
* Strings: `String`
"""

# ╔═╡ 6dfc1289-63ce-418f-be4e-8e0d56b548a8
Resource("https://github.com/storopoli/Computacao-Cientifica/blob/master/images/julia_types.png?raw=true")

# ╔═╡ 335f192a-c6df-40a0-85ad-632df6effb7b
typeof(1)

# ╔═╡ 0a4c0174-2237-44a2-8b40-2660aeca5301
typeof(1.0)

# ╔═╡ ccf84f8a-34f2-4cae-879e-d9d4db0d6e79
typeof(true)

# ╔═╡ 40de7a64-f189-4ed6-87ac-f92d585a1d7c
typeof("Julia é melhor que Python")

# ╔═╡ 23aad319-3599-45c2-b4ce-4ae1a65a5efc
supertypes(Float64)

# ╔═╡ c897c959-16fe-4c69-89ac-13b1f7c68532
subtypes(Number)

# ╔═╡ 31388efd-ece4-4e8b-b912-0c7ef4504cee
subtypes(AbstractFloat)

# ╔═╡ b4abf678-9647-4b0d-91e2-f72824594eeb
md"""
### Operações Matemáticas

* `+`: Adição
* `-`: Subtração
* `*`: Multiplicação
* `/`: Divisão
* `÷`: Divisão Truncado para Inteiro
* `^`: Exponenciação
* `%`: Resto da Divisão
"""

# ╔═╡ dfb1f5d7-4b42-43d4-b485-a69aa501506f
1 + 2

# ╔═╡ 4f69ed81-c1bf-4ecc-b98b-28ecf5d23339
1 - 2

# ╔═╡ 6cf71676-068b-4ab8-995f-0018d160c670
1 * 3

# ╔═╡ dd55eea5-f90c-40bf-852a-804eef13ccc5
1 / 3

# ╔═╡ 1bbe7c18-9305-4dd0-9de0-93692860c30c
10 ÷ 3 # \div TAB

# ╔═╡ dba22aea-f08f-48a4-aa58-baedbc15a226
2^3

# ╔═╡ 9890d50b-84eb-448a-b6d8-63b9b630bd40
10 % 3

# ╔═╡ 1523aa7c-311a-40db-b8fe-e901618d8941
md"""
### Operações In-Place

* `+=`: Adição
* `-=`: Subtração
* `*=`: Multiplicação
* `/=`: Divisão
* `÷=`: Divisão Truncado para Inteiro
* `^=`: Exponenciação
* `%=`: Resto da Divisão
"""

# ╔═╡ b2814c7f-4d92-496b-8312-c3c96cd196dc
md"""
## Tipos Definidos pelo Usuário: `struct`

Em Julia, podemos definir tipo de dados estruturados com um `struct` (também conhecido como tipos compostos). Dentro de cada `struct`, há um **conjunto opcional de campos, _fields_**.

Eles diferem dos tipos primitivos (por exemplo, `Int` e `Float`) que são definidos por padrão já dentro do núcleo da linguagem Julia. Como a maioria dos `struct`s são **definidos pelo usuário**, eles são conhecidos como **tipos definidos pelo usuário**.
"""

# ╔═╡ 15168171-d7db-4a53-ba90-aa066786f007
struct Language
    name::String  # Se não definir o tipo ele via ser o ::Any
    title::String
    year_of_birth::Int64
    fast::Bool
end

# ╔═╡ bde7cb11-003d-4686-8864-9f07ba2dfc44
fieldnames(Language)

# ╔═╡ 44712c46-020a-4ab3-827c-2ca0aa1fdbe7
md"""
Por padrão temos o construtor do `struct` já definido por Julia
"""

# ╔═╡ c776f970-668f-491c-ae8b-d59f0125586c
julia = Language("Julia", "Rapidus", 2012, true)

# ╔═╡ be427637-8a55-45fb-87f3-a3740fccef82
python = Language("Python", "Letargicus", 1991, false)

# ╔═╡ 5b2a3041-b135-4f49-8939-d817a3c93931
md"""
Uma coisa a ser observada com relação aos `struct`s é que não podemos alterar seus valores uma vez que sejam instanciados. Podemos resolver isso com um `mutable struct`. 

Objetos **mutáveis** geralmente serão mais **lentos** e mais sujeitos a **erros**. **Sempre que possível, torne tudo _imutável_**.
"""

# ╔═╡ 307f8eb1-be1d-4ddd-be36-602fc18e3542
mutable struct MutableLanguage
    name::String
    title::String
    year_of_birth::Int64
    fast::Bool
end

# ╔═╡ bbb61634-0b8a-4c1d-bccb-f96aea7ad8ab
MutableLanguage("Julia", "Rapidus", 2012, true)

# ╔═╡ b41e4303-dcfa-4839-851f-4054b13e7a0d
julia_mutable = MutableLanguage("Julia", "Rapidus", 2012, true)

# ╔═╡ 5d83fd98-1d88-4d29-9fe2-3e506b147b85
md"""
Suponha que queremos mudar o título de `julia_mutable`. Agora podemos fazer isso, já que `julia_mutable` é um `mutable struct` instanciado:
"""

# ╔═╡ c22d7fbd-91a0-4c5c-89ad-88ad6c635f7f
julia_mutable.title = "Python Obliteratus"

# ╔═╡ fcf95c93-5896-430e-9c57-392acbd0452d
julia_mutable

# ╔═╡ f489f0e2-b49c-4a44-a088-e1414dc1f0f1
md"""
## Operadores Booleanos e Comparações Numéricas

* `!`: NOT
* `&&`: AND
* `||`: OR
"""

# ╔═╡ 878dd181-a981-4bc3-8c7a-bcfcbf1c599b
!true

# ╔═╡ aea8516b-2a8c-466a-bf60-c539666a327d
(false && true) || (!false)

# ╔═╡ 22d9a2df-2199-4233-aa54-e9909224984c
(6 isa Int64) && (6 isa Real)

# ╔═╡ 3d2da59d-df8b-42cb-9f3a-19e605f9c274
md"""
1. **Igualdade**:
   * `==`: igual
   * `!=` ou `≠`: diferente (\ne TAB)


2. **Menor**:
   * `<`: menor que
   * `<=` ou `≤`: menor ou igual a (\leq TAB)


3. **Maior**:
   * `>`: maior que
   * `>=` ou `≥`: maior ou igual a (\geq TAB)
"""

# ╔═╡ f7308afc-5477-4a51-ad9a-c7e1b421bf50
1 == 1

# ╔═╡ c5bf57a4-2a17-42a8-ab6c-e9793a75924b
1 >= 10

# ╔═╡ 5c7c3816-2b36-4397-9ce3-518f4766a523
md"""
Funciona também para tipos diferentes:
"""

# ╔═╡ 9dcf470b-dbdc-4903-8119-ab21412a2733
1 == 1.0

# ╔═╡ c696e5f1-17a4-4775-98a8-013e4ebd6a6d
md"""
Também dá para fazer um bem-bolado com operadores booleanos:
"""

# ╔═╡ f9575009-eecf-4f65-a149-b81ff9e25078
(1 != 10) || (3.14 <= 2.71)

# ╔═╡ af3f1666-441f-49aa-8275-f2b027adb840
md"""
Também funciona para tipos abstratos:
"""

# ╔═╡ 962d8216-adf9-4dc1-9b0d-68156a93d6fb
2.0 isa AbstractFloat

# ╔═╡ 00243765-bc99-4ac0-a29d-b2e4a25b8308
md"""
## Funções

Agora que já sabemos como definir variáveis e tipos personalizados como `struct`, vamos voltar nossa atenção para as funções.

Em Julia, uma função é um **objeto que mapeia os valores do argumento para um valor de retorno**. A sintaxe básica é mais ou menos assim:

```julia
function f_nome(arg1, arg2)
    computações = manipulações com arg1 e arg2
    return computações
end
```
"""

# ╔═╡ fc401271-a696-45d2-886d-25ff03d852aa
md"""
Também a sintaxe **compacta de designação** (*compact assignment form*):

```julia
f_nome(arg1, arg2) = manipulações com arg1 e arg2
```
"""

# ╔═╡ fd0059dc-316d-495a-8745-d1c6de3213ba
md"""
### Criando Novas Funções
"""

# ╔═╡ 6642f04b-997f-4bcb-842c-0229d1c2e0a6
function add_numbers(x, y)
    return x + y
end

# ╔═╡ 746c4392-f927-4737-9b4f-2d8e9e2dc1ef
add_numbers(17, 29)

# ╔═╡ 9f16d36a-4535-4878-9f54-e1b83ed966e9
md"""
Também funciona com `Float`s:
"""

# ╔═╡ 8736d279-d6a4-455a-8147-da54b6a8b7cb
add_numbers(3.14, 2.72)

# ╔═╡ a92afdd8-4caf-4b93-9ff0-a1c2a4d8e10f
md"""
Também podemos definir o comportamento personalizado especificando declarações de tipos.

Suponha que queremos uma função `round_number` que se comporte de maneira diferente se seu argumento for `Float64` ou `Int64`:
"""

# ╔═╡ 2c5764ff-eb58-4bbc-8516-a1b85e3d39d2
function round_number(x::Float64)
    return round(x)
end

# ╔═╡ 672dea18-7531-41fe-9664-1e54760b84cc
function round_number(x::Int64)
    return x
end

# ╔═╡ c1eae7f9-02d1-46a1-8d55-27e84d4270ab
md"""
Há um problema: o que acontece se quisermos arredondar um `Float32` de 32 bits? Ou um inteiro de 8 bits `Int8`?

Se você deseja que algo funcione em todos os tipos `Float` e `Int`, você pode usar um tipo abstrato como assinatura de tipo, como `AbstractFloat` ou `Integer`:
"""

# ╔═╡ 47b462f6-cf75-4ec2-b99c-9481e09a611a
function round_number(x::AbstractFloat)
    return round(x)
end

# ╔═╡ 5885a920-a492-4f43-855e-f609e52d44c8
methods(round_number)

# ╔═╡ e6f84787-a190-4758-871e-b5b22d95e528
x_32 = Float32(1.1)

# ╔═╡ 78d63c1b-1424-4a5d-a8a4-a3d463a8df4b
round_number(x_32)

# ╔═╡ 30ff79b3-c6e3-47cb-8e1a-60c785bfcaeb
md"""
Vamos voltar ao nosso `struct` de linguagem que definimos acima. Este é um exemplo de **despacho múltiplo**. Vamos estender a função `Base.show` que imprime a saída de tipos e `struct` instanciados.

Por padrão, uma estrutura tem uma saída básica, que você viu acima no caso de `python` e `julia`. Podemos definir a função `Base.show` para nosso tipo de linguagem, de modo que tenhamos uma boa impressão para nossas instâncias de linguagens de programação.

Queremos comunicar claramente os nomes, títulos e idades das linguagens de programação em anos de idade. A função `Base.show` aceita como argumentos um tipo de `IO` chamado `io` seguido pelo tipo que você deseja definir o comportamento personalizado:
"""

# ╔═╡ 8a101cdf-ef38-4be1-800e-91288e3a30c1
Base.show(io::IO, l::Language) = print(
    io, l.name, " ",
    2021 - l.year_of_birth, ", anos de idade, ",
    "tem os seguintes títulos: ", l.title
)

# ╔═╡ 6f08a8e7-55be-41fc-865e-3ef26ffd94a7
python

# ╔═╡ 8a2dbca6-36db-4c2d-bd6f-e07d3cd84a3d
julia

# ╔═╡ 8a02b02c-3bfd-405f-9163-b6b2b8880382
md"""
### Múltiplos Valores de Retorno

Uma função também pode retornar dois ou mais valores. Veja a nova função `add_multiply` abaixo:
"""

# ╔═╡ da1f1312-d3e4-42ae-aef6-eb14d3b0fee8
function add_multiply(x, y)
    addition = x + y
    multiplication = x * y
    return addition, multiplication
end

# ╔═╡ e752e5bf-9a8a-4fd1-8e4b-f39b3fad6410
md"""
Podemos fazer duas coisas:

1. desempacotar os valores de retorno
"""

# ╔═╡ e9e34c57-36f2-4f10-b16f-8ba34c38c957
return_1, return_2 = add_multiply(1, 2)

# ╔═╡ 9bbb809a-27c5-47db-a5a0-ae836318868d
md"""
2. definir uma única variável para os valores de retorno e acessar com indexação ou `first`, `last` etc...
"""

# ╔═╡ 6d0a36ab-0cd4-4502-973f-85f90aa0fc03
all_returns = add_multiply(1, 2)

# ╔═╡ dc13a6c0-3b40-43a9-9627-babfb0899e7f
last(all_returns)

# ╔═╡ 3a3f2e64-941a-4abe-bc6b-d4fb9a53a1f5
md"""
### Argumentos por Palavras-Chave (*Keywords*)

Algumas funções podem aceitar **argumentos de palavras-chave** em vez de argumentos posicionais.

Esses argumentos são como argumentos regulares, exceto que eles são **definidos após os argumentos da função regular e separados por um ponto e vírgula `;`**.

Outra diferença é que devemos fornecer um **valor padrão para cada argumento de palavra-chave**.

Por exemplo, vamos definir uma função de `logarithm` que, por padrão, usa base ℯ (2.718281828459045) como um argumento de palavra-chave. Observe que aqui estamos usando o tipo abstrato `Real` de modo que cobrimos todos os tipos derivados de `Integer` e `AbstractFloat`, sendo ambos subtipos de `Real`:
"""

# ╔═╡ a9134413-8ac2-4d70-ad87-5ce35bc74bda
(AbstractFloat <: Real) && (Integer <: Real)

# ╔═╡ 0329e55d-2845-4ba0-a10d-f91103559d60
function logarithm(x::Real; base::Real=2.7182818284590)
    return log(base, x)
end

# ╔═╡ 53ddf7fc-9886-4f64-973d-f62b9563943b
md"""
Funciona sem especificar o argumento `base`:
"""

# ╔═╡ 6f2c5ff8-1015-4e57-87cb-1f79c2c0aed6
logarithm(10)

# ╔═╡ 7fac9fb9-1d6d-49c3-854a-e02a05473f1c
md"""
E também com o argumento de palavra-chave `base` diferente de seu valor padrão:
"""

# ╔═╡ d48cbefb-8993-4807-b370-c815048c613b
logarithm(10; base=2)

# ╔═╡ d39fe930-1547-491d-a17b-570d44fde35d
md"""
### Funções Anônimas

Muitas vezes, não nos importamos com o nome da função e queremos fazer uma rapidamente. O que precisamos são **funções anônimas**.

A sintaxe é simples. Usamos o operador `->`. À esquerda de `->` definimos o nome do parâmetro. E à direita de `->` definimos quais operações queremos realizar no parâmetro que definimos à esquerda de `->`. Aqui está um exemplo, suponha que queremos desfazer a transformação de `logarithm` usando uma exponenciação:
"""

# ╔═╡ a6c58949-56b3-4a4a-a496-099c6e6ab35e
map(x -> 2.7182818284590^x, logarithm(2))

# ╔═╡ d859a384-61a9-4878-94c0-d6bb4c1317ae
md"""
Aqui, estamos usando a função `map` para mapear convenientemente a função anônima (primeiro argumento) para `logarithm(2)` (o segundo argumento).
"""

# ╔═╡ 925dc80e-c594-457a-b2c9-288673ece8bc
md"""
## Condicionais `if`-`else`-`elseif`

Na maioria das linguagens de programação, o usuário tem permissão para controlar o **fluxo de execução** do computador. Dependendo da situação, queremos que o computador faça uma coisa ou outra. Em Julia, podemos controlar o fluxo de execução com as palavras-chave `if`, `elseif` e `else`. São conhecidos como sintaxe condicionais.

A palavra-chave `if` solicita que Julia avalie uma expressão e, dependendo se verdadeira ou falsa, certas partes do código serão executadas. Podemos combinar várias condições `if` com a palavra-chave `elseif`, para um fluxo de controle complexo. 

Finalmente, podemos definir uma parte alternativa a ser executada se qualquer coisa dentro de `if` ou `elseif`s for avaliada como verdadeira. Este é o propósito da palavra-chave `else`. Finalmente, como todos os operadores de palavra-chave anteriores que vimos, devemos informar a Julia quando a instrução condicional for concluída com a palavra-chave `end`.

Aqui está um exemplo com todas as palavras-chave `if`-`elseif`-`else`:
"""

# ╔═╡ e98d6b23-d70d-48ca-8b0d-b90cefe2f526
a = 1

# ╔═╡ be3aa7ab-7140-430b-860c-6782179b3f21
b = 2

# ╔═╡ 35a02922-f6bf-479d-9bf4-269f7d952890
if a < b
    "a é menor que b"
elseif a > b
    "a é maior que b"
else
    "a é igual a b"
end

# ╔═╡ 145dc716-3de0-4749-8a45-dbcdb008bbe8
md"""
Dá até para enfiar sintaxe condicional numa função:
"""

# ╔═╡ f40d3038-47c9-4128-8262-1f1231da1df4
function comparar(a, b)
	if a < b
		return "a é menor que b"
	elseif a > b
		return "a é maior que b"
	else
		return "a é igual a b"
	end
end

# ╔═╡ cefa15f5-a1fb-4723-9693-dc68ff4e358c
comparar(3.14, 3.14)

# ╔═╡ a38739cb-1838-4957-80c6-ff8469358e05
md"""
## `for`-Loops

O loop `for` clássico em Julia segue uma sintaxe semelhante às instruções condicionais. Você começa com uma palavra-chave, neste caso, `for`. Em seguida, você especifica o que Julia deve fazer “loop”, ou seja, uma sequência. Além disso, como tudo mais, você deve terminar com a palavra-chave `end`.

Então, para fazer Julia imprimir todos os números de 1 a 10, você precisará do seguinte loop `for`:
"""

# ╔═╡ 57019909-33c3-4294-aa78-5e139f47f5d8
for i in 1:10
    println(i)
end

# ╔═╡ 624afde0-6e92-4be0-b944-ac9adaf72ece
md"""
## `while`-Loops

O loop `while` é uma mistura das instruções condicionais anteriores e dos loops `for`. Aqui, o loop é executado sempre que a condição for verdadeira. A sintaxe segue o mesmo estilo da anterior. Começamos com a palavra-chave while, seguida pela instrução to Avaliado como `true`. Como anteriormente, você deve terminar com a palavra-chave `end`.

Aqui está um exemplo:
"""

# ╔═╡ 2980b180-c052-4f65-b8e6-12f8bf663f2d
begin
	n = 0
	while n < 3
	    global n += 1
	end
end

# ╔═╡ 05b815e4-a936-473a-b38d-f580a5803f8d
n

# ╔═╡ 43286eb0-b7b3-4b2c-80f0-cdc2fa6289b0
md"""
Como você pode ver, temos que usar a palavra-chave `global`. Isso se deve ao **escopo variável**.

Variáveis definidas dentro de declarações condicionais, loops e funções existem apenas dentro dela. Isso é conhecido como **escopo da variável**. Aqui, tivemos que dizer a Julia que o `n` dentro do loop `while` está no escopo global com a palavra-chave `global`.
"""

# ╔═╡ af3299d2-3802-4cb5-8175-8ad26a7451aa
md"""
# Estrutura de Dados Nativas

Julia possui várias estruturas de dados nativas. Eles são **abstrações de dados que representam dados estruturados de alguma forma**. Abordaremos os **mais usados**. Eles contêm dados homogêneos ou heterogêneos. Uma vez que são coleções, eles podem ser "loopados" com os loops `for`.

Abordaremos `String`, `Tuple`, `NamedTuple`, `UnitRange`, `Array`, `Pair`, `Dict`, `Symbol`.
"""

# ╔═╡ 2581f42b-90d9-4c4f-a420-2c6f3a7de4a1
md"""
Quando você se depara com uma estrutura de dados em Julia, pode encontrar funções/métodos que a aceitam como um argumento com a função `methodswith`.

É uma coisa boa para se ter na sua mala de truques. Vamos ver o que podemos fazer com uma `String`, por exemplo:
"""

# ╔═╡ 176fa107-cf78-4700-8952-8807792bef90
last(methodswith(String), 20)

# ╔═╡ bd654c6b-31eb-440f-b56d-8baa6e3be45c
md"""
## Broadcast de Operadores e Funções

Antes de mergulharmos nas estruturas de dados, precisamos falar sobre *broadcasting* (também conhecida como vetorização) e o operador “ponto” `.`

Para operações matemáticas, como `*` (multiplicação) ou `+` (adição), podemos vetorizar usando o operador ponto `.`. Por exemplo, a adição vetorizada implicaria na alteração de `+` para `.+`:
"""

# ╔═╡ 8f6fc6c1-eb52-48e0-89a0-9be3f23a544f
[1, 2, 3] .+ 1

# ╔═╡ a6a9ab62-0c83-4258-a03a-d2decd24ad26
md"""
Também funciona com funções. Lembra da função `logarithm`:
"""

# ╔═╡ b33ca93a-1e3f-4b6f-9452-e15194b3b739
logarithm.([1, 2, 3])

# ╔═╡ cb2871f5-915a-4055-8404-59970243e991
md"""
## Funções com o bang `!`

Em Julia, a é praxe adicionar `!` a nomes de **funções que modificam seus argumentos**.

Esta é uma convenção que avisa ao usuário que a **função não é pura**, ou seja, tem *efeitos colaterais*. Uma função com efeitos colaterais é útil quando você deseja atualizar uma grande estrutura de dados ou contêiner de variável sem ter toda a sobrecarga da criação de uma nova instância.

A maioria dos `!` os argumentos das funções são estruturas de dados.

Por exemplo, podemos criar uma função que adiciona 1 ao seu argumento:
"""

# ╔═╡ ff7ee2c5-ba27-4164-97fa-427d01a24fdc
function add_one!(x)
    for i in 1:length(x)
        x[i] += 1
    end
    return nothing
end

# ╔═╡ 7979220f-0546-451c-a64b-290f91311995
my_data = [1, 2, 3]

# ╔═╡ 618df2a4-bcc8-462b-bc90-0a3ce4847946
add_one!(my_data)

# ╔═╡ 0aba2b94-dcd2-4ca6-9a44-cb7dd1258c4b
my_data

# ╔═╡ fb925ccb-7e31-435b-91f5-84cf0467ae2d
md"""
## `String`

**Strings** são representadas com delimitadores de aspas duplas:
"""

# ╔═╡ ab5f439a-6f74-468b-9910-fa28e763e8e0
typeof("Você deleterá o Python do seu computador")

# ╔═╡ 7a00294d-49db-40d3-adf8-7b8d82c4bbe9
md"""
Funciona também com uma string de múltiplas linhas:
"""

# ╔═╡ f81d9b63-47ed-4e83-9b33-13d1ff5e2ab8
typeof("
	Você deleterá o Python do seu computador,
	Assim como o R e o Matlab.
	Esse último pior ainda pois é pago.
	Julia é gratuita
	")

# ╔═╡ 6a8cf359-9bc7-4682-97eb-6d3ee9bcf270
md"""
Mas geralmente, nesse caso usamos aspas triplas:
"""

# ╔═╡ e8c933b6-92b5-4819-a5aa-360c5f11c7df
typeof("""
	Você deleterá o Python do seu computador,
	Assim como o R e o Matlab.
	Esse último pior ainda pois é pago.
	Julia é gratuita
	""")

# ╔═╡ b3b1b518-993c-423f-94a8-9a59514adc13
md"""
### Concatenação de Strings

Uma operação comum com strings é a concatenação de string. Suponha que você queira construir uma nova string que é a concatenação de duas ou mais strings. Isso é realizado em julia com o operador `*` (aqui é onde Julia se afasta de outras linguagens de programação de código aberto) ou com a função `join`:
"""

# ╔═╡ afc4a870-bc83-4529-980b-305677a238fb
goodbye = "You say goodbye"

# ╔═╡ c98ded1b-e107-4634-b07b-32fcf5da9b9c
hello = "And I say hello"

# ╔═╡ 73b7e842-8e51-40f5-bc7c-9f624f00f7c0
goodbye * hello

# ╔═╡ 1bf4dfca-7d70-428c-bfbf-2ff47cf3e6b1
md"""
Como você pode ver, está faltando um espaço entre `oi` e o `tchau`. Poderíamos concatenar uma string `" "` adicional com o `*`, mas isso seria complicado para mais de duas strings.

É quando usamos a função `join`. Apenas passamos como argumentos as strings dentro dos colchetes `[]` e o separador:
"""

# ╔═╡ ccd7d075-8f5f-48da-bc8a-182d50ec9163
join([goodbye, hello], ". ")

# ╔═╡ 5887f734-9e8c-4a5f-bac2-6251e18be96d
md"""
### Interpolação de Strings

Concatenação de strings podem se tornar complicadas. Podemos ser muito mais expressivos com a **interpolação de strings**.

Funciona assim: você especifica o que quer que seja incluído em sua string com o cifrão `$`. Aqui está o exemplo anterior, mas agora usando interpolação:
"""

# ╔═╡ 04be3f46-6d12-448f-a06e-309c674fa977
"$goodbye. $hello"

# ╔═╡ de3c52fc-d3e1-46f7-976b-069d842f43c2
"$(1 + 1 / 2 * π * ℯ)"

# ╔═╡ b38f87f3-aa0c-487a-ba0e-967b694c485a
md"""
Funciona também em funções. Vamos revisitar a funcão `comparar`:
"""

# ╔═╡ 273f1a87-b406-4bae-9499-76b7d691ada2
function comparar_interpolado(a, b)
	if a < b
		return "$a é menor que $b"
	elseif a > b
		return "$a é maior que $b"
	else
		return "$a é igual a $b"
	end
end

# ╔═╡ f7143396-d441-4b19-b1a2-8d4b5a51808a
comparar_interpolado(3.14, 3.14)

# ╔═╡ f6501a7f-d5db-4e35-87cf-0276a10f101d
md"""
### Manipulações de Strings

Existem várias funções para manipular strings em Julia. Vamos demonstrar as mais comuns. Além disso, observe que a maioria dessas funções aceita uma [Expressão regular (RegEx)](https://docs.julialang.org/en/v1/manual/strings/#Regular-Expressions) como argumentos. Não cobriremos RegEx nesta disciplina, mas você é incentivado a aprender sobre eles, especialmente se a maior parte de seu trabalho usa dados textuais.
"""

# ╔═╡ f9750fe5-314a-4c76-b54f-853d971bc32c
md"""
Primeiro vamos definir uma string para brincar de manipulações:
"""

# ╔═╡ 5623cf32-1701-4257-8499-339a97333a23
julia_string = "Julia é uma linguagem de programação opensource incrível"

# ╔═╡ 91e5c8a7-f5c4-4f6e-a731-690df4232f17
md"""
#### Procurar em uma String

`contains`, `startswith` e `endswith`: Um condicional (retorna `true` ou `false`) se o primeiro argumento for um:
"""

# ╔═╡ 867f15a5-190c-415f-b17d-27835fdd32b5
# substring
contains(julia_string, "Julia")

# ╔═╡ a08230c8-b75c-4950-8efe-1c45598b8601
# prefixo
startswith(julia_string, "Julia")

# ╔═╡ 8d3c614d-0f84-40cb-a705-ede6f3739e43
# sufixo
endswith(julia_string, "Julia")

# ╔═╡ 0cf87278-3d4f-4bd4-8ff7-25b9cf349cd4
md"""
!!! tip "💡 Um exemplo do Mundo Real"
    ```julia
	using CSV
	using DataFrames
	
	files = filter(endswith(".csv"), readdir())
	df = CSV.read(files, DataFrame)
	```
"""

# ╔═╡ 341febea-3452-4936-bee9-1b2b86855cce
md"""
#### Modificar uma String

`lowercase`, `uppercase`, `titlecase` e `lowercasefirst`:
"""

# ╔═╡ 7a2309eb-0532-4b1b-9ca2-973b7b19c1d7
lowercase(julia_string)

# ╔═╡ 85d5af38-41be-47bc-8a5d-522cd5b5a61b
uppercase(julia_string)

# ╔═╡ 8bffcb75-682b-424b-ab75-54de724802a3
titlecase(julia_string)

# ╔═╡ 0667dfb3-c29e-4737-89b4-54cdaf96f93c
lowercasefirst(uppercase(julia_string))

# ╔═╡ c5bd2e45-d5b5-4bbb-bbf4-53d0dd112ff6
md"""
#### Substituir algo em String

`replace`

!!! danger "⚠️ Sintaxe Nova: Pair"
    `replace` introduz uma nova sintaxe usando o tipo `Pair`, mais sobre ele já já...
"""

# ╔═╡ 69320491-5140-4b14-b51e-edca3eec22d2
replace(julia_string, "incrível" => "maravilhosa")

# ╔═╡ 0b6ee7a3-0a6b-4027-9a55-e0a4b13e4672
md"""
#### Dividir uma String

`split`
"""

# ╔═╡ b68b808c-e618-43bd-a9ad-c3551fb6bfbc
split(julia_string, " ")

# ╔═╡ 5d096db0-f757-4bfb-b8ff-a76da7759255
md"""
### Conversão de Strings

Freqüentemente, precisamos converter entre tipos em Julia. Podemos usar a função `string`:
"""

# ╔═╡ c05ff138-ea15-4230-84c1-ba25d44ed284
my_number = 123

# ╔═╡ 9917bd60-0d9a-4941-933e-cbddcdbd3ae5
typeof(string(my_number))

# ╔═╡ 7d9fe9ab-c11e-4bf0-884e-05bc6fff8976
md"""
Às vezes, queremos o oposto: converter uma string em um número. Julia tem uma função útil para isso: `parse`
"""

# ╔═╡ 45d55b1f-7a8d-4641-ba1f-cd4b979ddf16
typeof(parse(Int64, "123"))

# ╔═╡ 885ebfe1-d8e5-4b7f-8d4b-f3eec4360b6c
md"""
Às vezes, queremos nos precaver com essas conversões. É quando a função `tryparse` entra em ação.

Ela tem a mesma funcionalidade que `parse`, mas retorna um valor do tipo solicitado ou `nothing`. Isso torna o `tryparse` útil quando queremos evitar erros.

Claro, você precisaria lidar com todos esses valores `nothing` depois.
"""

# ╔═╡ 689c80e9-b403-4bd3-9402-1c413e6645db
tryparse(Int64, "Uma string nada numérica")

# ╔═╡ db838095-2cc8-47ed-951e-1017d62c73dc
md"""
## `Tuple`

Julia tem uma estrutura de dados chamada **tupla**. Elas são realmente especiais em Julia porque estão intimamente relacionados às funções. Como as funções são um recurso importante do Julia, todo usuário do Julia deve conhecer o básico das tuplas.

Uma tupla é um **contêiner de comprimento fixo que pode conter qualquer tipo de valor**. Uma tupla é um **objeto imutável**, o que significa que não pode ser modificada após a instanciação. Para construir uma tupla, você usa parênteses `()` para delimitar o início e o fim, junto com vírgulas `,` como delimitadores de valor:
"""

# ╔═╡ 969d0111-86b8-483b-8833-702ee8d7accb
my_tuple = (1, 3.14, "Julia")

# ╔═╡ 42f3a193-125b-4228-847c-7197ed6cfa04
md"""

Podemos acessar valores das tuplas por meio de indexação ou usando `first` e `last`.

!!! danger "⚠️ Sintaxe Nova: operador []"
    Indexação de tuplas introduz uma nova sintaxe usando o operador `[]`, mais sobre ele já já na seção de `Array`.
"""

# ╔═╡ 7fe68465-0cd0-44ea-9c6d-967d8d37848e
my_tuple[2]

# ╔═╡ 4ae2d830-75b4-4450-9246-4e36d8723709
last(my_tuple)

# ╔═╡ 2f8376a4-9d32-4a37-a42c-94fdefcd4a8b
md"""
A relação entre tuplas e funções é muito importante. Lembra das funções que retornam vários valores?

Vamos inspecionar o que nossa função add_multiply retorna:
"""

# ╔═╡ 9da51fda-8971-4624-bf3f-ebe1da2afb1f
return_multiple = add_multiply(1, 2)

# ╔═╡ 92b103ae-0342-4510-8df7-075f40ae15ee
typeof(return_multiple)

# ╔═╡ 6bcf22c2-6d06-47ea-9937-cfd40c86beaf
md"""
Então, agora você pode ver como eles estão relacionados. As **funções que retornam vários argumentos o fazem retornando uma `Tuple`** com os tipos dentro dos `{}` colchetes.

Mais uma coisa sobre tuplas. **Quando você quiser passar mais de uma variável para uma função anônima, adivinhe o que você precisa usar? Mais uma vez: tuplas!**
"""

# ╔═╡ f63c025d-fe0f-46b3-a756-14d0e4a2f0f7
map((x, y) -> x^y, 2, 3)

# ╔═╡ 25a70750-d4c9-4fe7-8137-0ad2bf1bd355
map((x, y, z) -> x^y + z, 2, 3, 1)

# ╔═╡ cb3c0d7a-5d56-4970-af6b-4e98af1961bc
md"""
## `NamedTuple`

Às vezes, você deseja nomear os valores em tuplas. É quando entram as **tuplas nomeadas**. Sua funcionalidade é praticamente a mesma das tuplas: elas são **imutáveis** e podem **conter qualquer tipo de valor**.

A construção da tupla nomeada é ligeiramente diferente das tuplas. Você tem os familiares parênteses `()` e vírgula `,` como separador de valor. Mas agora você deve **nomear os valores**:
"""

# ╔═╡ 17e5667e-9978-4eff-a405-6423abc3f8d6
my_namedtuple = (i=1, f=3.14, s="Julia")

# ╔═╡ 1018e8bd-2a5c-4679-aead-40036152db41
md"""
Podemos acessar os valores de uma tupla nomeada por meio da indexação como tuplas regulares ou, alternativamente, acessar por seus nomes com o `.`:
"""

# ╔═╡ e26c3913-12a1-4019-b333-3cd557d9d9c8
my_namedtuple.s

# ╔═╡ 3b5f0399-9721-4e92-9338-318a29ac95b8
md"""
Para terminar as tuplas nomeadas, há uma **sintaxe rápida** importante que você verá muito no código de Julia.

Freqüentemente, os usuários de Julia criam uma tupla nomeada usando os familiares parênteses `()` e vírgulas `,` mas sem nomear os valores. Para fazer isso, você **começa a construção da tupla nomeada especificando primeiro um ponto-e-vírgula `;` antes dos valores**. Isso é especialmente útil quando os valores que comporiam a tupla nomeada já estão definidos nas variáveis:
"""

# ╔═╡ f451e3c8-cb9d-4097-a796-066cdbc4331c
i = 1

# ╔═╡ 240a658f-b82f-4d86-9e84-bb7bd4e4fd68
fun = 3.14

# ╔═╡ 30ebfc7f-190d-4268-b961-0c27e8d09903
s = "Julia"

# ╔═╡ e88e62d1-4c6d-4822-a107-009b1c68d49c
my_quick_namedtuple = (; i, fun, s)

# ╔═╡ 51326bad-c0f3-4d0d-89a5-29ba3bf2834d
md"""
## `UnitRange`

Um intervalo em Julia representa um intervalo entre os limites de início e fim. A sintaxe é `start:stop`:
"""

# ╔═╡ 62b08f70-b799-45b3-a393-183e7a21d5a0
1:10

# ╔═╡ f26b334d-b6ef-4e6c-929a-d9cd13a4495a
md"""
Como você pode ver, nosso intervalo instanciado é do tipo `UnitRange{T}`, onde `T` é o tipo dentro de `UnitRange`:
"""

# ╔═╡ a86f0f47-e75c-4fbd-b540-03baf270273e
typeof(1:10)

# ╔═╡ 64a39d5d-10fa-42d5-920f-06fddfe1e975
md"""
E para coletarmos os valores:
"""

# ╔═╡ d2f43da2-86d9-40a2-9001-bad3be0bc226
[x for x in 1:10]

# ╔═╡ a9a9428e-36b1-4b6d-bd2d-92b63ab3d8b2
collect(1:10)

# ╔═╡ 731fb3bf-9a0d-41e0-98c8-2c198b64c5a0
md"""
Podemos construir intervalos também para outros tipos:
"""

# ╔═╡ a6d6f024-57e1-4602-8348-198b817f25b8
typeof(1.0:10.0)

# ╔═╡ 9a97abcf-5bc4-4bb6-9c9c-12085aaa75a9
md"""
Às vezes, queremos mudar o comportamento do tamanho do intervalo padrão. Podemos fazer isso adicionando um tamanho do intervalo na sintaxe de intervalo `start:step:stop`. Por exemplo, suponha que queremos um intervalo de Float64 de 0 a 1 com intevalos de tamanho 0.2:
"""

# ╔═╡ 6b676293-34d4-4182-bcb6-76eaef0cfa53
0.0:0.2:1.0 |> collect

# ╔═╡ 4fe2bba3-b244-4c25-965c-fd39c8495014
md"""
## `Array`

Arrays são **arranjos sistemáticos de objetos semelhantes, geralmente em linhas e colunas**. Na maioria das vezes, você desejaria **arrays de um único tipo para problemas de desempenho**, mas observe que eles também podem conter objetos de diferentes tipos. 

Elas são o “pão com manteiga” do cientista de dados e do cientista computacional, porque as arrays são o que constitui a maior parte dos fluxos de trabalho de **manipulação e visualização de dados**; além de serem a maior parte dos **algoritmos computacionais**.

**As arrays são uma estrutura de dados poderosa**. Eles são uma das principais características que tornam Julia extremamente rápida.
"""

# ╔═╡ a767ffa3-3163-4b82-866b-78b75c76e6ec
md"""
### Tipos de `Array`s

Vamos começar com tipos de arrays. Existem vários, mas vamos nos concentrar em dois dos mais usados em ciência de dados e computação científica:

* `Vector{T}`: array **unidimensional**. Apelido para `Array{T, 1}`.
* `Matrix{T}` array **bidimensional**. Apelido para `Array{T, 2}`

Observe aqui que `T` é o tipo do elemento da array. Assim, por exemplo, `Vector{Int64}` é um `Vector` em que todos os elementos são `Int64`s e `Matrix{AbstractFloat}` é uma `Matrix` em que todos os elementos são subtipos de `AbstractFloat`.

Na maioria das vezes, especialmente quando lidamos com dados tabulares, estamos usando matrizes uni ou bidimensionais. Ambos são tipos `Array` para Julia. Mas podemos usar os apelidos úteis `Vector` e `Matrix` para uma sintaxe clara e concisa.
"""

# ╔═╡ 0355cde9-fc02-4d69-9208-abc1a6df2fab
md"""
### Construção de `Array`s

Como construímos um `Array`?
"""

# ╔═╡ 1d17c89d-078b-43e8-9fc2-3b9c08845685
md"""
#### Constutor Padrão

A resposta mais simples é usar o **construtor padrão**. Ele aceita o tipo de elemento como o parâmetro de tipo dentro dos `{}` colchetes e dentro do construtor você passará o tipo de elemento seguido pelas dimensões desejadas.

É comum inicializar vetores e matrizes com elementos indefinidos usando o argumento `undef` para tipo (é muito mais rápida a construção com `undef`s.

Um vetor de 10 elementos `undef` de tipo `Float64` pode ser construído como:

"""

# ╔═╡ b77f331b-0d76-458c-9b84-3afde370b310
my_vector = Vector{Float64}(undef, 10)

# ╔═╡ 9b8414f9-cfe2-432e-b13f-f3c934c71e44
md"""
Para matrizes, como estamos lidando com objetos bidimensionais, precisamos passar dois argumentos de dimensões dentro do construtor: um para **linhas** e outro para **colunas**.

Por exemplo, uma matriz com 10 linhas, 2 colunas e elementos `undef` de tipo `Float64` pode ser instanciada como:
"""

# ╔═╡ 32236bbf-5fbb-471f-a240-edeb49e6fc71
my_matrix = Matrix{Float64}(undef, 10, 2)

# ╔═╡ f5643e26-2a20-49c8-b511-13bd51554f75
md"""
Também temos alguns apelidos de sintaxe para os elementos mais comuns na construção de arrays:
"""

# ╔═╡ 44c0a60c-2b22-47fa-8bea-435907ca1c94
my_vector_zeros = zeros(10)

# ╔═╡ 1b2f094d-83c9-4569-b466-574c3d99e103
my_matrix_zeros = zeros(Int64, 10, 2)

# ╔═╡ 9035cbbc-02ec-492e-af76-ec994930970e
my_vector_ones = ones(Int64, 10)

# ╔═╡ 185c1f43-23aa-497b-bfd1-63ccee901b94
my_matrix_ones = ones(10, 2)

# ╔═╡ 8aed3a9f-7efc-4915-91e4-865012515f92
md"""
Para outros elementos, podemos primeiro instanciar um array com elementos `undef` e usar a função `fill!` para preencher todos os elementos de uma array com o elemento desejado. Aqui está um exemplo com `3.14` ($\pi$):
"""

# ╔═╡ 7d01ec07-976a-4661-9d62-7f24d11097d6
my_matrix_π = Matrix{Float64}(undef, 2, 2)

# ╔═╡ 40f64809-262a-4706-ba3d-2659bbd224e9
fill!(my_matrix_π, π) #\pi TAB

# ╔═╡ 1fe5512b-1f64-4747-ae45-5e3b570e9e2e
md"""
#### Literais de Array

Também podemos criar arrays com **literais de array** (*array literals*). Por exemplo, uma matriz 2x2 de inteiros:
"""

# ╔═╡ 65baaf4e-bf4d-4ea8-82b8-1a2e5ad6b20a
[[1 2]
 [3 4]]

# ╔═╡ f0254bce-2cdd-45b3-80fb-debb608069dc
md"""
Literais de array também aceitam uma **especificação de tipo** antes dos colchetes `[]`. Portanto, se quisermos a mesma matriz 2x2 de antes, mas agora com `Float64`, podemos fazer isso:
"""

# ╔═╡ c5c33a46-21b8-4d9c-850d-28a2a06e3218
Float64[[1 2]
        [3 4]]

# ╔═╡ 8fdacc64-a2ee-4493-9eb6-a2f098570844
md"""
Também funciona para `Vector`:
"""

# ╔═╡ e34efd0b-3206-4494-ad82-4c461cdfab2c
Bool[0, 1, 0, 1]

# ╔═╡ 87158b9e-59f9-49ea-beca-d55ce31be213
md"""
Dá até para fazer um **bem-bolado** dos construtores com os literais de array:
"""

# ╔═╡ 6f74f6be-58c2-4ba4-a18e-abe2d4befaf5
[ones(Int, 2, 2) zeros(Int, 2, 2)]

# ╔═╡ 962817ec-26bb-441d-9215-29c2552c0488
[zeros(Int, 2, 2)
 ones(Int, 2, 2)]

# ╔═╡ d048a3bc-e058-4171-a4ba-a4f3362c283f
[ones(Int, 2, 2) [1; 2]
 [3 4]            5]

# ╔═╡ 7ba0b638-6a65-4422-874d-a11b17196e21
md"""
#### Compreensão de Array

Outra maneira poderosa de criar matrizes são as **compreensões de array** (*array comprehensions*). Esta forma de criar arrays é a minha forma preferida, evita loops, indexação e outras operações sujeitas a erros.

Você especifica o que deseja fazer entre os colchetes `[]`. Por exemplo, digamos que queremos criar um vetor de quadrados de 1 a 100:
"""

# ╔═╡ ef272daf-5bf8-4e0a-bb41-583d36898ed2
[x^2 for x in 1:10]

# ╔═╡ 7c750260-cf54-4425-846c-eb1fd8893ccd
md"""
Também há suporte para inputs múltiplos:
"""

# ╔═╡ fe514dd8-dcea-4f79-a7a5-9809be9b0d2d
[x*y for x in 1:10 for y in 1:2]

# ╔═╡ b0ec5129-4b6f-4085-9fdd-c7290e893d16
md"""
E condicionais:
"""

# ╔═╡ a9a0f1c1-edeb-4315-8f89-3e792318989c
[x^2 for x in 1:10 if isodd(x)]

# ╔═╡ a385cec5-7909-4a8b-8958-b88b0556ef59
[x^2 for x in 1:10 if iseven(x)]

# ╔═╡ bb535534-b195-4139-a5b9-4e469d783a9e
md"""
Assim como os literais de array, você pode especificar o tipo desejado antes dos colchetes `[]`:
"""

# ╔═╡ 604df609-4f1e-410e-86dc-4cd61841ec13
Float64[x^2 for x in 1:10 if isodd(x)]

# ╔═╡ 0ac9ebbc-6e8d-4a06-a5d5-a48092847f98
Complex[x^2 for x in 1:10 if iseven(x)]

# ╔═╡ 5a2a2f51-adf0-4ac7-911f-5ec961e9154a
md"""
#### Funções de Concatenação

Por fim, podemos criar arrays também com as **funcões de concatenação**:

1. `cat`: concatena em uma dimensão especifica `dims`
"""

# ╔═╡ 276d7f23-08f2-4b01-beed-07249b1aafaa
cat(ones(2), zeros(2); dims=1)

# ╔═╡ 2ebeeeda-3912-47e4-98e5-34a2e6537103
md"""
2. `vcat`: concatenação **v**ertical. Um atalho para `cat(...; dims=1)`
"""

# ╔═╡ 28de6463-7a25-4430-bc95-f8294d85c2df
vcat(ones(2), zeros(2))

# ╔═╡ 9ee13f25-c167-46fe-84e7-2790e0f9fb14
md"""
3. `hcat`: concatenação **h**orizontal. Um atalho para `cat(...; dims=2)`
"""

# ╔═╡ 8ece00af-463a-479f-b40a-3353af33ab69
hcat(ones(2), zeros(2))

# ╔═╡ 578583a4-7a6c-4154-9bd1-7b721d761b78
md"""
### Inspeção de `Array`s

Assim que tivermos as arrays, a próxima etapa lógica é inspecioná-las.

Existem várias funções úteis que permitem ao usuário ter uma visão interna de qualquer array.
"""

# ╔═╡ 54445272-7b73-46f9-823c-7a69a830a884
md"""
#### Tipo de Elemento de Array

É muito útil saber quais tipos de elementos estão dentro de um array. Podemos fazer isso com `eltype`:
"""

# ╔═╡ aaa37358-1a36-4f66-9ee5-e195f2a0f939
eltype(my_matrix_π)

# ╔═╡ 7f386c88-aee7-40f2-9e22-c8016be8ca4b
md"""
#### Dimensões de Array

Depois de conhecer seus tipos, geralmente estamos interessado nas dimensões da array. Julia tem várias funções para inspecionar as dimensões da matriz:

1. `length`: número total de elementos
"""

# ╔═╡ cdf1c8f5-9a41-4551-9fe7-92874010731b
length(my_matrix_π)

# ╔═╡ 18931049-b509-41b8-96f4-dd06e7734bcf
md"""
2. `ndims`: número de dimensões
"""

# ╔═╡ fe2035de-81d1-4cd9-b797-0d628e93c773
ndims(my_matrix_π)

# ╔═╡ ddbe514a-2c92-4e80-a256-d2515dc6890c
md"""
3. `size`: esta função é um pouco complicada. Por padrão, ela retornará uma tupla contendo as dimensões da matriz.
"""

# ╔═╡ 2940f804-2126-4a49-8267-fa76c27a6b83
size(my_matrix_π)

# ╔═╡ 1619a70c-ab34-44ec-96ca-495503b915e7
md"""
Você pode obter uma dimensão específica com um segundo argumento para `size`:
"""

# ╔═╡ 66deda8d-c35f-4f21-9950-1702d66b8cf5
size(my_matrix_π, 2) # columns

# ╔═╡ 5691fe91-3354-4671-bc52-08219d18ebbf
md"""
### Indexação e Fatiação de `Array`s

Às vezes, queremos inspecionar apenas certas partes de uma array. Isso é chamado de **indexação** (*indexing*) e **fatiação** (*slicing*).
"""

# ╔═╡ b39f073c-832f-4e31-8d6a-2377fe3a1375
md"""
#### Indexação de Arrays

Se você deseja uma observação particular de um vetor, ou uma linha ou coluna de uma matriz; você provavelmente precisará **indexar uma array**.
"""

# ╔═╡ b97ac4b5-2ce2-45f8-b85a-3e97945404de
my_example_vector = [1, 2, 3, 4, 5]

# ╔═╡ 6bcbe880-be3f-4eb0-95e6-87050e7fe2dc
my_example_matrix = [[1 2 3]
                     [4 5 6]
                     [7 8 9]]

# ╔═╡ 83d6ab60-b26d-4e5f-afe1-e6be8f1ed18e
md"""
Vamos ver primeiro um exemplo com vetores.

Suponha que você queira o segundo elemento de um vetor. Você acrescenta `[]` colchetes com o **índice** desejado dentro de:
"""

# ╔═╡ b82d098d-fce1-4d0d-a40c-9a7f15007d43
my_example_vector[2]

# ╔═╡ c1eeb631-f5cf-4cc4-b065-e1b5e372e03e
md"""
A mesma sintaxe segue com matrizes. Mas, como as matrizes são arrays bidimensionais, temos que especificar *tanto* linhas *quanto* colunas.

Vamos recuperar o elemento da segunda linha (primeira dimensão) e da primeira coluna (segunda dimensão):
"""

# ╔═╡ 4baecafb-bf57-44e8-9a95-c183607b6a4c
my_example_matrix[2, 1]

# ╔═╡ 14a7fb5a-9f60-4025-ba9c-0198ae89302b
md"""
##### `begin` e `end`

Julia também possui palavras-chave convencionais para o primeiro e o último elementos de uma array: `begin` e `end`.

Por exemplo, o penúltimo elemento de um vetor pode ser recuperado como:
"""

# ╔═╡ 5e3896f0-206f-4c56-aa9e-55590ba97c7b
my_example_vector[end-1]

# ╔═╡ d162ac4a-91aa-46b5-abf0-ad6bc45a2a12
md"""
Também funciona para matrizes. Vamos recuperar o elemento da última linha e da segunda coluna:
"""

# ╔═╡ 202cd904-3dce-485f-84ad-997d208c550a
my_example_matrix[end, begin+1]

# ╔═╡ 15fbc36f-5d9c-42f0-9f2a-873b400145d6
md"""
#### Fatiação de Arrays

Freqüentemente, não estamos interessados apenas em um elemento da array, mas em todo um subconjunto de elementos da array.

Podemos fazer isso **fatiando** uma array. Fatiação usa a mesma sintaxe de indexação, mas com os dois pontos adicionados `:` para denotar os limites que estamos fatiando a  array.

Por exemplo, suponha que queremos obter o 2º ao 4º elemento de um vetor:
"""

# ╔═╡ d92f7d73-00b7-4c8b-8c3d-7af50e713246
my_example_vector[2:4]

# ╔═╡ 4d7d7e8e-8b98-443b-9f5e-e028fa949dc6
md"""
Podemos fazer o mesmo com matrizes. Particularmente com matrizes, se quisermos selecionar todos os elementos em uma dimensão particular, podemos fazê-lo com apenas dois pontos `:`.

Por exemplo, todos os elementos na segunda linha:
"""

# ╔═╡ 4a0979ce-c7c5-49c7-87ef-4bb507d87602
my_example_matrix[2, :]

# ╔═╡ 8037cfe4-f4f7-45c1-9164-3be7fec76a0b
md"""
Também funciona com `begin` e `end`:
"""

# ╔═╡ 141de90c-1548-4d9f-ad1d-405fcb7edae7
my_example_matrix[begin+1:end, end]

# ╔═╡ ea54121c-b413-4bbc-93fc-3e671d75adf7
md"""
### Manipulações de `Array`s

Existem várias maneiras de manipular uma array.
"""

# ╔═╡ 673b3005-080e-487f-998d-60f7505aa878
md"""
#### Manipular Elementos de uma Array

A primeira seria manipular um **elemento singular** da array. Nós apenas indexamos a matriz pelo elemento desejado e procedemos com uma atribuição `=`:
"""

# ╔═╡ 715a2169-1c8f-4df0-ae67-1aedac9433ad
my_example_matrix[2, 2] = 42

# ╔═╡ 48423f21-5a47-49b7-b980-e0663f7a6aac
my_example_matrix

# ╔═╡ f644a7d2-a3a8-470f-b71a-e3c862599dd2
md"""
Ou você pode manipular um determinado **subconjunto de elementos** da array. Neste caso, precisamos fatiar a array e, em seguida, atribuir com `=`:
"""

# ╔═╡ e0ab2962-f8d7-4844-816d-e6c738d76f95
my_example_matrix[3, :] = [17, 16, 15]

# ╔═╡ 382cfa60-d3d2-46a4-a81b-9226bbcf5ef2
my_example_matrix

# ╔═╡ 73a88b71-9cab-4d14-8814-ef41a10b2e8f
md"""
#### Manipular a Forma de uma Array

A segunda maneira pela qual podemos manipular um array é **alterando sua forma**.

Suponha que você tenha um vetor de 6 elementos e queira torná-lo uma matriz 3x2. Você pode fazer isso com `reshape`, usando a array como primeiro argumento e uma tupla de dimensões como segundo argumento:
"""

# ╔═╡ 0ad9a3f2-38fd-411c-a6e5-25bfa46e3afb
six_vector = [1, 2, 3, 4, 5, 6]

# ╔═╡ 588c0476-c0f0-4072-8e89-ca587a81dcd3
tree_two_matrix = reshape(six_vector, (3, 2))

# ╔═╡ 86b71106-f7c2-4adc-a71d-89fbc99c807e
tree_two_matrix

# ╔═╡ 3225486d-44ad-45d3-9255-b4b241094eca
md"""
Você pode fazer o inverso, convertê-la de volta em um vetor, especificando uma tupla com apenas uma dimensão como segundo argumento:
"""

# ╔═╡ fbf72ca8-6101-4a4d-a6eb-4614151f9e83
reshape(tree_two_matrix, (6, ))

# ╔═╡ 925b76df-668e-40de-85eb-67e401654a4a
md"""
#### Aplicar uma Função numa Array

A terceira maneira de manipular um array é **aplicar uma função a cada elemento do array**. lembra do familiar operador “ponto” de vetorização `.`?
"""

# ╔═╡ 25610407-be23-4518-9b1f-48fd3d436a9d
logarithm.(my_example_matrix)

# ╔═╡ 8fafc604-cc8a-4368-b9b0-e943f9774d49
md"""
Também podemos vetorizar operadores:
"""

# ╔═╡ 29295128-f115-4bfa-89af-c4017d0b85bf
my_example_matrix .+ 100

# ╔═╡ 12a39248-4d59-4869-9487-8801e56e9f83
md"""
Adicionalmente podemos usar a função `map` para "mapear" uma função para todos os elementos de uma array:
"""

# ╔═╡ e765ecd3-3e79-48ab-9663-c7a8f8794bd0
map(logarithm, my_example_matrix)

# ╔═╡ 99e1e14b-33f1-47fb-aab8-a4e8100ffcae
md"""
`map` também aceita uma função anônima:
"""

# ╔═╡ bf6ab39a-3d93-4080-827b-1d76f2c00cd5
map(x -> x*3, my_example_matrix)

# ╔═╡ 82298f2d-f01f-49b4-93e2-bb93747d7251
md"""
E também funciona com fatiamento:
"""

# ╔═╡ 949cd9c9-a365-4b16-82bb-708ce2f1777d
map(x -> x + 100, my_example_matrix[:, 3])

# ╔═╡ 1b6a29c4-6643-443b-a0ea-5ca5489e21fc
md"""
##### `mapslices`

Finalmente, às vezes, e especialmente ao lidar com dados tabulares, queremos **aplicar uma função sobre todos os elementos em uma dimensão de array específica**.

Isso pode ser feito com a função `mapslices`. Semelhante ao map, o primeiro argumento é a função e o segundo argumento é a matriz. A única mudança é que precisamos especificar o argumento `dims` para sinalizar em qual dimensão queremos transformar os elementos.

Por exemplo, vamos usar `mapslice` com a função `sum` em ambas as linhas (`dims = 1`) e colunas (`dims = 2`):
"""

# ╔═╡ d7399528-1956-4048-9b8d-c37a96f065e0
my_example_matrix

# ╔═╡ 07a4816d-8f72-44ac-9cfc-bc2d9fcc7ceb
# colunas
mapslices(sum, my_example_matrix; dims=1)

# ╔═╡ ada5b74c-4fb4-40fa-9681-c9d28100e1c8
# linhas
mapslices(sum, my_example_matrix; dims=2)

# ╔═╡ 50f76d97-1830-487b-9cfc-f983b6d2e438
md"""
### Iteração de `Array`s

Uma operação comum é **iterar sobre um array com um loop `for`**. O **loop `for` em uma array retorna cada elemento**.

O exemplo mais simples é com um vetor.
"""

# ╔═╡ 0a572ce5-c512-4e32-bf1a-3bbbf1a923b8
simple_vector = [1, 2, 3]

# ╔═╡ d235ae94-1f90-4995-8e8b-6ad8b8c5156d
empty_vector = Int64[]

# ╔═╡ 78009959-931d-4450-89a3-b2a3b49eb4e3
for i in simple_vector
    push!(empty_vector, i + 1)
end

# ╔═╡ 4d0eca3e-b0b5-463a-8940-87f0a35a6a3c
empty_vector

# ╔═╡ 32252625-e515-47ec-935f-008df3e9d2a7
md"""
#### `eachindex`

Às vezes, você não quer fazer um loop sobre cada elemento, mas na verdade sobre cada índice de uma array. Podemos combinar a função `eachindex` com um loop `for` para iterar sobre cada índice de array.

Novamente, vamos mostrar um exemplo com um vetor:
"""

# ╔═╡ e2082eae-083d-4226-812b-dfc7ed0152f2
forty_two_vector = [42, 42, 42]

# ╔═╡ a80ddf46-0673-4196-94c8-04d06c469fb2
empty_vector_2 = Int64[]

# ╔═╡ b0ec5cf1-0ae1-4d33-918a-061065e2207b
for i in eachindex(forty_two_vector)
    push!(empty_vector_2, i)
end

# ╔═╡ ed3eeff6-75c8-4c24-9723-cbd002275fed
empty_vector_2

# ╔═╡ 218874db-d88b-4bc6-b8ad-53c574cd5b8f
md"""
Neste exemplo, o iterador `eachindex(forty_two_vector)` dentro do loop `for` retorna não os valores de `forty_two_vector`, mas seus índices: `[1, 2, 3]`.
"""

# ╔═╡ 63a2831a-f9dd-4a35-8dd4-680dee36994f
md"""
#### Julia é *column-major*

A iteração de matrizes envolve mais detalhes. O comportamento padrão para loop `for`  vai **primeiro sobre colunas e depois sobre linhas**. Ele percorrerá primeiro todos os elementos da coluna 1, da primeira à última linha, depois se moverá para a coluna 2 de maneira semelhante até cobrir todas as colunas.

Para aqueles que estão familiarizados com outras linguagens de programação, Julia, como a maioria das linguagens de programação científica, é "coluna principal" (*column-major*). Isso significa que as arrays são armazenadas de forma contígua usando uma orientação de coluna. Se a qualquer momento você estiver vendo problemas de desempenho e houver uma loop `for` com array envolvido, é provável que você não esta correspondendo à orientação de armazenamento *column-major* nativa de Julia.
"""

# ╔═╡ d3cfd585-8c47-49ba-ad3a-91d11dd11dcd
column_major = [[1 3]
                [2 4]]

# ╔═╡ 7ea0e64e-c153-4994-ba8c-c4cfee894866
row_major = [[1 2]
             [3 4]]

# ╔═╡ e779cfa4-d349-4e81-bd64-fe0a8f71a067
empty_vector_3 = Int64[]

# ╔═╡ 19c52194-9a1e-4af6-897e-154415bdd018
for i in column_major
    push!(empty_vector_3, i)
end

# ╔═╡ 36b4f380-6356-4fde-b64a-2b1f16c011f0
empty_vector_3

# ╔═╡ 53908a81-07be-4dbe-a617-b3bb1c107bc8
empty_vector_4 = Int64[]

# ╔═╡ 6305f6b3-2ad6-43ba-a1b4-1f730f620afa
for i in row_major
    push!(empty_vector_4, i)
end

# ╔═╡ 6e7fad82-a342-4fd8-a57c-10128c73906c
empty_vector_4

# ╔═╡ 79840669-8b94-453a-9d37-489ea82b2743
md"""
#### Julia pode ser *row-major* também

Existem algumas funções úteis para iterar em matrizes:

1. `eachcol`: itera sobre as colunas da array primeiro
"""

# ╔═╡ 5a00b308-49b6-47ce-a8c4-c1fcfe88249d
first(eachcol(column_major))

# ╔═╡ 26671096-3285-4e29-86aa-caa8b53c31f3
md"""
2. `eachrow`: itera sobre as linhas da array primeiro
"""

# ╔═╡ ef83fb23-d421-4df1-9344-3aa12af9e816
first(eachrow(column_major))

# ╔═╡ e20176c6-3a39-4ca0-8be7-379dcca98bd2
md"""
## `Pair`

**`Pair` é uma estrutura de dados que contém dois tipos**. A forma como construímos um `Pair` em Julia está usando a seguinte sintaxe:
"""

# ╔═╡ ab76fa37-4e00-41a5-bdfc-ae0c776a1cab
my_pair = Pair("Julia", 42)

# ╔═╡ b1f07781-de89-4d24-ae65-7e88f3e33bca
my_pair_2 = "Julia" => 42

# ╔═╡ 74fdac10-95f9-4f10-8436-9f188f8d9c2b
md"""
Os elementos são armazenados nos campos `first` e `second`.
"""

# ╔═╡ 49aa1ae1-bceb-4dd7-86db-cd2ec193e15c
my_pair.first

# ╔═╡ 531e5fe7-619d-423c-ad78-039ef439c319
my_pair.second

# ╔═╡ 7d71bd8b-887b-42b8-b26c-7b9914e46a23
md"""
!!! tip "💡 Uso dos Pairs"
	`Pair`s serão muito usados na manipulação e visualização de dados, uma vez que as funções principais de `DataFrames.jl` ([Aula 4](https://storopoli.io/Computacao-Cientifica/4_DataFrames/)) e `Plots.jl` ([Aula 6](https://storopoli.io/Computacao-Cientifica/6_Plots/)) usam `Pair` como tipo de argumentos em diversas funcões.
"""

# ╔═╡ 95168671-e9b0-4f43-8782-bd083511fdf6
md"""
## `Dict`

Se você entendeu o que é um `Pair`, então `Dict` não será um problema. **`Dict` em Julia é apenas uma “tabela hash” (*hash table*) com pares de `key` e `value`**.

`key`s e `value`s podem ser de qualquer tipo, mas geralmente você verá as `key`s como strings.
"""

# ╔═╡ b91bc734-0438-42d6-860e-ba6f97f42b5f
md"""
### Construindo `Dict`s

Existem duas maneiras de construir `Dict`s em Julia. A primeira é usar o **construtor padrão `Dict` e passar um vetor de tuplas compostas por `(key, value)`**:
"""

# ╔═╡ ac8e5cc4-571d-4cd9-93d5-cc9021ae34ac
my_dict = Dict([("one", 1), ("two", 2)])

# ╔═╡ 1a090de0-31ec-412e-90ca-9a554afe9bba
md"""
Eu *prefiro* a segunda forma de construir `Dict`s. Ele oferece uma sintaxe muito elegante e expressiva.

Você usa o mesmo **construtor padrão `Dict`**, mas agora você passa **`Pair`s de `key` e `value`**:
"""

# ╔═╡ 3d0e8678-a59d-4606-8e16-ff82f69eda81
my_dict_2 = Dict("one" => 1, "two" => 2)

# ╔═╡ fbc673e8-6110-48fb-8cad-fc1e70e0bceb
md"""
### Recuperando `value`s de `key`s

Você pode recuperar um `value` de uma `key` de um `Dict` indexando-o pela `key` correspondente:
"""

# ╔═╡ 0b3dadb0-ea10-4834-aec5-9064cf5a96b9
my_dict["one"]

# ╔═╡ dc3d9f48-5c28-47ef-bcb8-c2db0539ad91
md"""
### Criando novas `key`s

Da mesma forma, para adicionar uma nova `key`, você indexa o `Dict` pela `key` desejada e atribui um `value` com o operador de atribuição `=`:
"""

# ╔═╡ 5101ad1a-2575-4d2e-9831-2ff58d4ddecd
my_dict["three"] = 3

# ╔═╡ fdc662dc-1b03-4c30-8b05-1dce800a3a46
md"""
### Verificando `key`s

Se você quiser verificar se um `Dict` tem uma determinada `key`, você pode usar a função `haskey`:
"""

# ╔═╡ 718c0ec9-dedd-40aa-86ac-8b1800d07ba4
haskey(my_dict, "two")

# ╔═╡ b224e5cf-a03e-4593-83df-e7dd0b1245de
md"""
### Deletando `key`s

Para deletar uma  `key` você pode usar a funcão `delete!`:
"""

# ╔═╡ 735b88f2-a3d3-452b-83d4-2346eada4e14
delete!(my_dict, "three")

# ╔═╡ 6fa9db7e-b9d3-4bdf-acc7-b33595061d22
md"""
Ou para deletar uma `key` enquanto retorna o seu valor, você pode usar a funcão `pop!`:
"""

# ╔═╡ d5c4877f-f5d3-41bb-bf30-3d3629ac70b3
popped_value = pop!(my_dict, "two")

# ╔═╡ 88dbb4f6-ddc8-4e55-ab70-2d27e3d62d54
md"""
Agora nosso `my_dict` tem apenas uma `key`:
"""

# ╔═╡ 0e538383-0fcf-4b68-834b-ae0666730120
length(my_dict)

# ╔═╡ 1f3e2b53-7ffa-4f97-97f7-0421e15750c4
my_dict

# ╔═╡ f2049ce2-117e-4566-aafa-2e07f12c586a
md"""
!!! tip "💡 Construtor Dict com zip"
	Existe um construtor `Dict` útil. Suponha que você tenha dois vetores e queira construir um `Dict` com um deles como `key`s e o outro como `value`s. Você pode fazer isso com a função `zip`, que "cola" dois objetos como um zíper:
"""

# ╔═╡ 0c7559f0-5818-43d8-a907-9a5bf70f54a9
chaves = ["one", "two", "three"]

# ╔═╡ 134c476e-ee2a-49f9-a462-413155c20042
valores = [1, 2, 3]

# ╔═╡ 6570b24b-8d04-4d79-b78d-60810fde88ed
dic = Dict(zip(chaves, valores))

# ╔═╡ 6233afd4-78c3-4750-b3b9-96af0bc861df
md"""
## `Symbol`

Na verdade, `Symbol` não é uma estrutura de dados. É um tipo e se comporta muito como uma string. Em vez de colocar o texto entre aspas, um símbolo começa com dois pontos (`:`) e pode conter underlines:
"""

# ╔═╡ 4ac539fe-b5dd-4cfd-8bbf-e79043202bda
sym = :algum_texto

# ╔═╡ 286fb8ea-a9f6-42b1-9435-f7ab5b9d4ad6
md"""
Como os `Symbol`s e strings são muito semelhantes, podemos facilmente converter um `Symbol` em string e vice-versa:
"""

# ╔═╡ ce45627b-9b55-40cf-95e1-06469152b7ed
s1 = string(sym)

# ╔═╡ 10fb4d48-a550-4775-bcf7-cafb0430af1c
sym2 = Symbol(s1)

# ╔═╡ ede362d3-537f-45a0-b546-449aabeae3e1
md"""
!!! tip "💡 Uso dos Symbols"
	`Symbol`s serão muito usados na manipulação e visualização de dados, uma vez que as funções principais de `DataFrames.jl` ([Aula 4](https://storopoli.io/Computacao-Cientifica/4_DataFrames/)) e `Plots.jl` ([Aula 6](https://storopoli.io/Computacao-Cientifica/6_Plots/)) usam `Symbol` como tipo de argumentos em diversas funcões.
"""

# ╔═╡ 367e7fb2-445d-467c-9a46-78e34f0a95d7
md"""
# Sistema de Arquivos
"""

# ╔═╡ c4c5a7ae-eee2-4544-b011-52e819c0b1b7
md"""
!!! tip "💡 Linux"
    Delete o Windows e instale Linux. Mesmo que não queira ou possa abrir mão do windows, instale o Linux com o Windows.

	Veja mais aqui [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
"""

# ╔═╡ c1cdc5a7-5af5-42fa-9186-4a1d1e8d37a6
md"""
Em ciência de dados, a maioria dos projetos é realizada em um **esforço colaborativo**. Compartilhamos código, dados, tabelas, figuras e assim por diante.

Por trás de tudo, existe o **sistema de arquivos do sistema operacional (SO)**. Em um trabalho ideal, o código seria executado da mesma forma em sistemas operacionais diferentes. Mas não é isso o que realmente acontece. Uma instância disso é a diferença de caminhos do Windows, como `C:\\user\joazinho\`, e caminhos do Linux, como `/home/joazinho`.

É por isso que é importante discutir as **melhores práticas do sistema de arquivos**.
"""

# ╔═╡ b40bbeb2-5088-4af9-ae3f-57c44faaa25c
md"""
Julia possui recursos de sistema de arquivos nativos que pode **lidar com todas as demandas de sistemas operacionais diferentes**. Eles estão localizados no módulo `Filesystem` da biblioteca principal `Base` Julia. Isso significa que Julia fornece tudo que você precisa para fazer seu código funcionar perfeitamente em qualquer sistema operacional que você desejar.

Sempre que estiver lidando com arquivos como `.csv`, `.xlsx` ou outros scripts Julia `.jl`, certifique-se de que seu código seja compatível com todos os diferentes sistemas de arquivos do SO. Isso é facilmente realizado com as funções `joinpath` e `pwd`.

A função `pwd` é um acrônimo para _**p**rint **w**orking **d**irectory_ e retorna uma string contendo o diretório de trabalho atual. Uma coisa boa sobre o `pwd` é que ele é robusto para o sistema operacional, ou seja, ele retornará a string correta no Linux, MacOS, Windows ou qualquer outro sistema operacional.

Por exemplo, vamos ver quais são nosso diretório atual e registrá-lo em uma variável `root`:
"""

# ╔═╡ aa819682-34bf-436e-bfd2-c23bb12ae952
root = pwd()

# ╔═╡ 68e8f9b2-a545-481b-a47f-081fce300731
md"""
A próxima etapa seria incluir o caminho relativo do `root` ao arquivo desejado. Uma vez que diferentes sistemas operacionais têm maneiras diferentes de construir caminhos relativos com subpastas, alguns usam barra `/` enquanto outros podem usar barras invertidas `\`, não podemos simplesmente concatenar o caminho relativo do nosso arquivo com a string `root`. Para isso, temos a função `joinpath`, que unirá diferentes caminhos relativos e nomes de arquivos em sua implementação específica do sistema de arquivos do SO.

Suponha que você tenha um script chamado `my_script.jl` dentro do diretório raíz do seu `projeto`. Você pode ter uma representação robusta do caminho de arquivo para `my_script`.jl como:
"""

# ╔═╡ 41fef0c8-1668-4439-98c7-01fd7007152c
joinpath(root, "my_script.jl")

# ╔═╡ 1aa13f41-26bc-4583-93a2-2720eaed5203
md"""
`joinpath` também lida com subpastas. Vamos agora imaginar uma situação comum em que você tem uma pasta chamada `data/` no diretório raíz do seu projeto. Dentro dessa pasta, há um arquivo CSV chamado `my_data.csv`. Você pode ter a mesma representação robusta do caminho de arquivo para `my_data.csv` como:
"""

# ╔═╡ 76012ecf-be96-46e2-809e-3a76ed9649f8
joinpath(root, "data", "my_data.csv")

# ╔═╡ 6f73368a-6e88-465e-9fea-d7ce69376fd0
md"""
!!! danger "⚠️ Git"
    Além disso, **aprenda `git`**. Para ficar claro, três vezes:

	Aprenda `git`, aprenda `git` e aprenda `git`.

	**APRENDA `git`!**
"""

# ╔═╡ d5dee4ec-2b92-4106-aac5-1ea508a9b04e
md"""
# Printar as Cores no Terminal

> Código e Hack originais do [Chris Foster](https://github.com/c42f) nesse [issue do `fonsp/PlutoUI.jl`](https://github.com/fonsp/PlutoUI.jl/issues/88):
"""

# ╔═╡ 2ab4cdba-9ae3-4293-ad75-40aa1993b8d3
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

# ╔═╡ 821d9942-ad13-412a-9806-e3055d5cc0db
function color_print(f)
	io = IOBuffer()
	f(IOContext(io, :color=>true))
	html_str = sprint(io2->show(io2, MIME"text/html"(),
					  HTMLPrinter(io, root_class="documenter-example-output")))
	HTML("$html_str")
end

# ╔═╡ feef0409-838a-4d4c-af20-dffb231914da
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

# ╔═╡ a3f71dea-7454-4771-857d-8c3db3db1b08
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

# ╔═╡ ce5e7964-9b19-4968-89e6-6deb429fa554
@code_llvm_ quadratic(42.0, 42.0, 42.0)

# ╔═╡ efc03594-5c0f-4841-b6d1-22cb3cdeca4b
@code_llvm_ quadratic(42, 42, 42)

# ╔═╡ e79c52af-29e5-485b-ae8a-7c927ac0d917
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

# ╔═╡ f530d914-e940-4be2-9d00-688faa6a13a1
@code_native_ quadratic(42, 42.0, 42.0)

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

# ╔═╡ 8aa46a2a-e675-41c6-830e-0e16818c24c3
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
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
ANSIColoredPrinters = "~0.0.1"
BenchmarkTools = "~1.2.0"
PlutoUI = "~0.7.10"
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
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "61adeb0823084487000600ef8b1c00cc2474cd47"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.2.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[HypertextLiteral]]
git-tree-sha1 = "72053798e1be56026b81d4e2682dbe58922e5ec9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

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
git-tree-sha1 = "9d8c00ef7a8d110787ff6f170579846f776133a9"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.4"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlutoUI]]
deps = ["Base64", "Dates", "HypertextLiteral", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "Suppressor"]
git-tree-sha1 = "26b4d16873562469a0a1e6ae41d90dec9e51286d"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.10"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

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
# ╟─e4dbc9c7-cc0d-4305-ac6a-c562b233d965
# ╠═27f62732-c909-11eb-27ee-e373dce148d9
# ╟─92216109-f448-495d-8114-d7e4c6e2b5f0
# ╟─c0212d94-246c-4129-b2c7-65a3b107d951
# ╟─ebc2a29a-2ad9-457f-8b9c-344fbc955a15
# ╟─165e0a37-dd2c-4dae-8cc6-b80615af6e30
# ╟─d5c8264f-defe-4e4c-b072-093c580a19af
# ╟─89dbf386-2216-400e-ab36-05599e1fb4c7
# ╟─575a6998-032b-40fb-9942-6ec39b1b69d7
# ╟─6c5d8d8f-b08f-4550-bc1b-9f19a6152bd4
# ╟─3e2441b6-1545-4f34-a418-f61b2dbf61e9
# ╟─0659cb16-eea6-4ef7-90e7-27a50deee15f
# ╟─6f1bec92-7703-4911-8ff5-668618185bf4
# ╟─3712de35-d34e-4f6f-9041-cac2efb2730a
# ╠═43f8ee8b-7d74-4ef3-88fe-41c44f0a0eee
# ╠═ce5e7964-9b19-4968-89e6-6deb429fa554
# ╠═efc03594-5c0f-4841-b6d1-22cb3cdeca4b
# ╠═f530d914-e940-4be2-9d00-688faa6a13a1
# ╟─9b8cac39-97ed-465c-bacb-1841c6926280
# ╠═32b4273d-06d9-4450-97d0-23740cf7bd88
# ╠═673ec92c-e813-424a-b4d9-4ff36bb887d2
# ╠═584973af-9d1c-4c79-ad0b-f4c8f8b39ee3
# ╟─d9b7c5bc-2f99-4721-8910-41497e307689
# ╟─ec8aa40e-a6d4-46db-8d76-99e53f876fdd
# ╟─c9be26cf-08d1-4927-b2da-a3cf4d1023ee
# ╠═bdbe2067-2101-4f36-a64d-442afc9c20dc
# ╠═6be5724f-78ed-49e4-8ac5-07caea58a4ee
# ╟─d79ec91b-353f-4986-90a6-be613b20bff7
# ╟─959e2288-ee21-4541-9ce0-537716190733
# ╟─d90ce98c-6538-4a6d-9b45-e3f5c8ae2bb3
# ╟─9104cac0-b5a8-4a54-a636-6475c0d3489f
# ╟─cf994c69-7adb-4461-8273-165574072582
# ╟─a0f907f5-1d81-451e-b34b-8d622e5e47a2
# ╟─3c911397-cb1d-4929-b0e8-4aff516331b5
# ╠═de862c54-cd85-493e-9140-4682c8c25d9a
# ╠═3e20679b-04d5-48c0-b788-958fcfcd97c3
# ╠═1768f19a-4158-4597-9110-450f81a67986
# ╟─7659200b-163c-4127-be46-93ed949fb8ae
# ╟─36603633-5af5-4cdf-b6c9-9d87c23492e2
# ╟─ac147d47-71eb-482a-a52d-ab3b6bf33db3
# ╟─1b79ac6f-7be3-4c5b-903e-be26e134be87
# ╟─b6acb557-1a04-4021-a103-4be3a066be38
# ╟─a2ba234a-ff84-498f-84df-778dc3c5c6c8
# ╟─a3ba253e-fbda-471e-ab82-c2ddeaf3ddf9
# ╟─a6a7bccf-4012-450c-ac02-9fdef68f0c9e
# ╠═98ead09d-8ca9-41a4-95cf-fc07bd34db16
# ╟─e4e6e448-eac0-40ec-ac91-c79c3c4f040e
# ╟─e30005e0-540a-48ec-92ef-351c07c86912
# ╠═107f0d48-cd18-4456-8b5e-4971b5fbe2e8
# ╟─fcb0a3f9-ebdd-40e5-968c-2f3644dcc095
# ╟─6a45dd9a-1117-4591-b284-80cac24bb541
# ╟─180e897c-ea27-44bb-9f93-1a1dd13aaf71
# ╟─e0057d14-f306-4eaa-9ac3-e83500c8be59
# ╟─01949b8b-702f-4e82-9c48-3619b67133fa
# ╠═fc833387-ae84-4220-9086-ee5dedb11d9d
# ╠═3b64cd4e-f9cf-4a57-b971-58ea76b748c9
# ╠═468b1950-195d-43f5-8d1c-105abe84d439
# ╠═e783aa1f-e96b-4abd-9daa-ac668b0f79cd
# ╠═61a5142f-5a69-4913-96e9-5582259fbd7a
# ╠═5a52e20b-ff55-462b-ab87-03f4f38138c0
# ╠═ff24f4a0-bd0e-4dc7-b8bf-504b5ac05096
# ╠═87bed413-6237-4c16-9459-41f4b868e1be
# ╠═d4bea1f2-e30d-4fff-bdad-644b80f4e704
# ╠═c7e13998-1b4b-4363-b89a-a1f2c8f92a1a
# ╟─b4938cbd-27bc-4999-919a-a32e503dadb0
# ╟─7412d8ce-dc0c-42be-800d-fe222c48a1f9
# ╟─c2875c4e-e49e-42e6-ad88-bddc790550b9
# ╠═ee77185f-1abf-425a-aec0-1f84f54bcb41
# ╠═461bd896-6d65-4b76-8934-2e38cfd86231
# ╠═06009452-af10-4ed6-aa52-60297536efd9
# ╠═1d939b3d-43ad-40b5-8001-4465579b7a15
# ╠═ef284b80-4fbe-4af4-9ab1-145f5d3be67d
# ╠═3762fb2b-e263-4451-968b-9b7b03cf1db1
# ╠═d50a833f-590f-4b0f-87cd-b2e9c3eacb0e
# ╠═0aa44c17-70dc-42f5-a7f0-8eddbe0dc0b8
# ╠═b3942ceb-31f4-4dfd-818e-c50e81262853
# ╠═ef621d5e-f69b-44b1-a8c7-fe4b3fc64232
# ╠═90ab5ecf-7a4a-406e-9cec-bd83195b88d7
# ╠═0c119847-6137-49aa-aac9-247ee630dcdd
# ╠═a1f56329-5883-42ec-a747-52ba24800eb6
# ╠═fd342dc5-f775-4597-bad8-da131f127ab2
# ╠═83bbae2f-1510-4d46-b88a-bb966ec8fe89
# ╠═5c433041-9de3-4245-bbb1-393b9a26101d
# ╟─1d46cf0f-a322-4447-9192-133c6e4085b8
# ╟─81ae472d-7195-4525-87ae-1429972b8816
# ╠═8faf0fee-cad5-440f-bc2d-0fdb848ce42d
# ╠═cb276e1e-1b81-4705-b28b-b7b3e08332bc
# ╠═7d03d2be-d9bd-4992-bb60-a8eb266a956c
# ╠═20c73247-0555-4962-bd01-152a68b3b782
# ╟─2538921e-6b35-4f84-9e76-e246cd28ecd8
# ╠═7bbbebc8-8a2b-45de-aa25-aa1bec443f43
# ╟─8f815967-ec04-44b7-aeae-4ae48b1429c7
# ╠═ecdabab9-c2c4-4f89-bcef-a2ddc1e782d3
# ╠═238e3cc9-6ea1-4f23-8a4a-0a58de6fd014
# ╟─92dac6c4-a85b-496c-b022-ef68b8e1e595
# ╠═d83443d7-ea65-48a7-bc88-2ed51762ac82
# ╠═88ab49be-8770-4c04-874f-db964d89dc2c
# ╠═6c559966-7d63-4b69-bcf7-0ae90835fa9c
# ╟─e7272270-5ecf-4c33-b550-3caf354247fb
# ╠═7376684a-75be-46c9-867c-34d6e625edae
# ╟─3d3f64f4-bf19-4684-9a29-8fee1dfbe9c9
# ╠═250cbe36-059b-4681-925f-fccf1d6095d2
# ╟─5aa224c5-a05a-438d-ba0a-fadce5f46592
# ╟─41801f25-e95a-49bc-9454-0328f13684b6
# ╠═8c7d2d8a-c547-45c1-bcf5-636584cdb3da
# ╟─f6042d46-94bf-45ad-aa23-f5e256c67571
# ╠═fa434fbe-0999-4c45-8ae2-87f5652c1b52
# ╟─39ddde6a-9030-430c-ae39-1033720fd43a
# ╟─8e63e4f2-ef86-4a9d-ab21-4194965c32ba
# ╟─6dfc1289-63ce-418f-be4e-8e0d56b548a8
# ╠═335f192a-c6df-40a0-85ad-632df6effb7b
# ╠═0a4c0174-2237-44a2-8b40-2660aeca5301
# ╠═ccf84f8a-34f2-4cae-879e-d9d4db0d6e79
# ╠═40de7a64-f189-4ed6-87ac-f92d585a1d7c
# ╠═23aad319-3599-45c2-b4ce-4ae1a65a5efc
# ╠═c897c959-16fe-4c69-89ac-13b1f7c68532
# ╠═31388efd-ece4-4e8b-b912-0c7ef4504cee
# ╟─b4abf678-9647-4b0d-91e2-f72824594eeb
# ╠═dfb1f5d7-4b42-43d4-b485-a69aa501506f
# ╠═4f69ed81-c1bf-4ecc-b98b-28ecf5d23339
# ╠═6cf71676-068b-4ab8-995f-0018d160c670
# ╠═dd55eea5-f90c-40bf-852a-804eef13ccc5
# ╠═1bbe7c18-9305-4dd0-9de0-93692860c30c
# ╠═dba22aea-f08f-48a4-aa58-baedbc15a226
# ╠═9890d50b-84eb-448a-b6d8-63b9b630bd40
# ╟─1523aa7c-311a-40db-b8fe-e901618d8941
# ╟─b2814c7f-4d92-496b-8312-c3c96cd196dc
# ╠═15168171-d7db-4a53-ba90-aa066786f007
# ╠═bde7cb11-003d-4686-8864-9f07ba2dfc44
# ╟─44712c46-020a-4ab3-827c-2ca0aa1fdbe7
# ╠═c776f970-668f-491c-ae8b-d59f0125586c
# ╠═be427637-8a55-45fb-87f3-a3740fccef82
# ╟─5b2a3041-b135-4f49-8939-d817a3c93931
# ╠═307f8eb1-be1d-4ddd-be36-602fc18e3542
# ╠═bbb61634-0b8a-4c1d-bccb-f96aea7ad8ab
# ╠═b41e4303-dcfa-4839-851f-4054b13e7a0d
# ╟─5d83fd98-1d88-4d29-9fe2-3e506b147b85
# ╠═c22d7fbd-91a0-4c5c-89ad-88ad6c635f7f
# ╠═fcf95c93-5896-430e-9c57-392acbd0452d
# ╟─f489f0e2-b49c-4a44-a088-e1414dc1f0f1
# ╠═878dd181-a981-4bc3-8c7a-bcfcbf1c599b
# ╠═aea8516b-2a8c-466a-bf60-c539666a327d
# ╠═22d9a2df-2199-4233-aa54-e9909224984c
# ╟─3d2da59d-df8b-42cb-9f3a-19e605f9c274
# ╠═f7308afc-5477-4a51-ad9a-c7e1b421bf50
# ╠═c5bf57a4-2a17-42a8-ab6c-e9793a75924b
# ╟─5c7c3816-2b36-4397-9ce3-518f4766a523
# ╠═9dcf470b-dbdc-4903-8119-ab21412a2733
# ╟─c696e5f1-17a4-4775-98a8-013e4ebd6a6d
# ╠═f9575009-eecf-4f65-a149-b81ff9e25078
# ╟─af3f1666-441f-49aa-8275-f2b027adb840
# ╠═962d8216-adf9-4dc1-9b0d-68156a93d6fb
# ╟─00243765-bc99-4ac0-a29d-b2e4a25b8308
# ╟─fc401271-a696-45d2-886d-25ff03d852aa
# ╟─fd0059dc-316d-495a-8745-d1c6de3213ba
# ╠═6642f04b-997f-4bcb-842c-0229d1c2e0a6
# ╠═746c4392-f927-4737-9b4f-2d8e9e2dc1ef
# ╟─9f16d36a-4535-4878-9f54-e1b83ed966e9
# ╠═8736d279-d6a4-455a-8147-da54b6a8b7cb
# ╟─a92afdd8-4caf-4b93-9ff0-a1c2a4d8e10f
# ╠═2c5764ff-eb58-4bbc-8516-a1b85e3d39d2
# ╠═672dea18-7531-41fe-9664-1e54760b84cc
# ╠═5885a920-a492-4f43-855e-f609e52d44c8
# ╟─c1eae7f9-02d1-46a1-8d55-27e84d4270ab
# ╠═47b462f6-cf75-4ec2-b99c-9481e09a611a
# ╠═e6f84787-a190-4758-871e-b5b22d95e528
# ╠═78d63c1b-1424-4a5d-a8a4-a3d463a8df4b
# ╟─30ff79b3-c6e3-47cb-8e1a-60c785bfcaeb
# ╠═8a101cdf-ef38-4be1-800e-91288e3a30c1
# ╠═6f08a8e7-55be-41fc-865e-3ef26ffd94a7
# ╠═8a2dbca6-36db-4c2d-bd6f-e07d3cd84a3d
# ╟─8a02b02c-3bfd-405f-9163-b6b2b8880382
# ╠═da1f1312-d3e4-42ae-aef6-eb14d3b0fee8
# ╟─e752e5bf-9a8a-4fd1-8e4b-f39b3fad6410
# ╠═e9e34c57-36f2-4f10-b16f-8ba34c38c957
# ╟─9bbb809a-27c5-47db-a5a0-ae836318868d
# ╠═6d0a36ab-0cd4-4502-973f-85f90aa0fc03
# ╠═dc13a6c0-3b40-43a9-9627-babfb0899e7f
# ╟─3a3f2e64-941a-4abe-bc6b-d4fb9a53a1f5
# ╠═a9134413-8ac2-4d70-ad87-5ce35bc74bda
# ╠═0329e55d-2845-4ba0-a10d-f91103559d60
# ╟─53ddf7fc-9886-4f64-973d-f62b9563943b
# ╠═6f2c5ff8-1015-4e57-87cb-1f79c2c0aed6
# ╟─7fac9fb9-1d6d-49c3-854a-e02a05473f1c
# ╠═d48cbefb-8993-4807-b370-c815048c613b
# ╟─d39fe930-1547-491d-a17b-570d44fde35d
# ╠═a6c58949-56b3-4a4a-a496-099c6e6ab35e
# ╟─d859a384-61a9-4878-94c0-d6bb4c1317ae
# ╟─925dc80e-c594-457a-b2c9-288673ece8bc
# ╠═e98d6b23-d70d-48ca-8b0d-b90cefe2f526
# ╠═be3aa7ab-7140-430b-860c-6782179b3f21
# ╠═35a02922-f6bf-479d-9bf4-269f7d952890
# ╟─145dc716-3de0-4749-8a45-dbcdb008bbe8
# ╠═f40d3038-47c9-4128-8262-1f1231da1df4
# ╠═cefa15f5-a1fb-4723-9693-dc68ff4e358c
# ╟─a38739cb-1838-4957-80c6-ff8469358e05
# ╠═57019909-33c3-4294-aa78-5e139f47f5d8
# ╟─624afde0-6e92-4be0-b944-ac9adaf72ece
# ╠═2980b180-c052-4f65-b8e6-12f8bf663f2d
# ╠═05b815e4-a936-473a-b38d-f580a5803f8d
# ╟─43286eb0-b7b3-4b2c-80f0-cdc2fa6289b0
# ╟─af3299d2-3802-4cb5-8175-8ad26a7451aa
# ╟─2581f42b-90d9-4c4f-a420-2c6f3a7de4a1
# ╠═176fa107-cf78-4700-8952-8807792bef90
# ╟─bd654c6b-31eb-440f-b56d-8baa6e3be45c
# ╠═8f6fc6c1-eb52-48e0-89a0-9be3f23a544f
# ╟─a6a9ab62-0c83-4258-a03a-d2decd24ad26
# ╠═b33ca93a-1e3f-4b6f-9452-e15194b3b739
# ╟─cb2871f5-915a-4055-8404-59970243e991
# ╠═ff7ee2c5-ba27-4164-97fa-427d01a24fdc
# ╠═7979220f-0546-451c-a64b-290f91311995
# ╠═618df2a4-bcc8-462b-bc90-0a3ce4847946
# ╠═0aba2b94-dcd2-4ca6-9a44-cb7dd1258c4b
# ╟─fb925ccb-7e31-435b-91f5-84cf0467ae2d
# ╠═ab5f439a-6f74-468b-9910-fa28e763e8e0
# ╟─7a00294d-49db-40d3-adf8-7b8d82c4bbe9
# ╠═f81d9b63-47ed-4e83-9b33-13d1ff5e2ab8
# ╟─6a8cf359-9bc7-4682-97eb-6d3ee9bcf270
# ╠═e8c933b6-92b5-4819-a5aa-360c5f11c7df
# ╟─b3b1b518-993c-423f-94a8-9a59514adc13
# ╠═afc4a870-bc83-4529-980b-305677a238fb
# ╠═c98ded1b-e107-4634-b07b-32fcf5da9b9c
# ╠═73b7e842-8e51-40f5-bc7c-9f624f00f7c0
# ╟─1bf4dfca-7d70-428c-bfbf-2ff47cf3e6b1
# ╠═ccd7d075-8f5f-48da-bc8a-182d50ec9163
# ╟─5887f734-9e8c-4a5f-bac2-6251e18be96d
# ╠═04be3f46-6d12-448f-a06e-309c674fa977
# ╠═de3c52fc-d3e1-46f7-976b-069d842f43c2
# ╟─b38f87f3-aa0c-487a-ba0e-967b694c485a
# ╠═273f1a87-b406-4bae-9499-76b7d691ada2
# ╠═f7143396-d441-4b19-b1a2-8d4b5a51808a
# ╟─f6501a7f-d5db-4e35-87cf-0276a10f101d
# ╟─f9750fe5-314a-4c76-b54f-853d971bc32c
# ╠═5623cf32-1701-4257-8499-339a97333a23
# ╟─91e5c8a7-f5c4-4f6e-a731-690df4232f17
# ╠═867f15a5-190c-415f-b17d-27835fdd32b5
# ╠═a08230c8-b75c-4950-8efe-1c45598b8601
# ╠═8d3c614d-0f84-40cb-a705-ede6f3739e43
# ╟─0cf87278-3d4f-4bd4-8ff7-25b9cf349cd4
# ╟─341febea-3452-4936-bee9-1b2b86855cce
# ╠═7a2309eb-0532-4b1b-9ca2-973b7b19c1d7
# ╠═85d5af38-41be-47bc-8a5d-522cd5b5a61b
# ╠═8bffcb75-682b-424b-ab75-54de724802a3
# ╠═0667dfb3-c29e-4737-89b4-54cdaf96f93c
# ╟─c5bd2e45-d5b5-4bbb-bbf4-53d0dd112ff6
# ╠═69320491-5140-4b14-b51e-edca3eec22d2
# ╟─0b6ee7a3-0a6b-4027-9a55-e0a4b13e4672
# ╠═b68b808c-e618-43bd-a9ad-c3551fb6bfbc
# ╟─5d096db0-f757-4bfb-b8ff-a76da7759255
# ╠═c05ff138-ea15-4230-84c1-ba25d44ed284
# ╠═9917bd60-0d9a-4941-933e-cbddcdbd3ae5
# ╟─7d9fe9ab-c11e-4bf0-884e-05bc6fff8976
# ╠═45d55b1f-7a8d-4641-ba1f-cd4b979ddf16
# ╟─885ebfe1-d8e5-4b7f-8d4b-f3eec4360b6c
# ╠═689c80e9-b403-4bd3-9402-1c413e6645db
# ╟─db838095-2cc8-47ed-951e-1017d62c73dc
# ╠═969d0111-86b8-483b-8833-702ee8d7accb
# ╟─42f3a193-125b-4228-847c-7197ed6cfa04
# ╠═7fe68465-0cd0-44ea-9c6d-967d8d37848e
# ╠═4ae2d830-75b4-4450-9246-4e36d8723709
# ╟─2f8376a4-9d32-4a37-a42c-94fdefcd4a8b
# ╠═9da51fda-8971-4624-bf3f-ebe1da2afb1f
# ╠═92b103ae-0342-4510-8df7-075f40ae15ee
# ╟─6bcf22c2-6d06-47ea-9937-cfd40c86beaf
# ╠═f63c025d-fe0f-46b3-a756-14d0e4a2f0f7
# ╠═25a70750-d4c9-4fe7-8137-0ad2bf1bd355
# ╟─cb3c0d7a-5d56-4970-af6b-4e98af1961bc
# ╠═17e5667e-9978-4eff-a405-6423abc3f8d6
# ╟─1018e8bd-2a5c-4679-aead-40036152db41
# ╠═e26c3913-12a1-4019-b333-3cd557d9d9c8
# ╟─3b5f0399-9721-4e92-9338-318a29ac95b8
# ╠═f451e3c8-cb9d-4097-a796-066cdbc4331c
# ╠═240a658f-b82f-4d86-9e84-bb7bd4e4fd68
# ╠═30ebfc7f-190d-4268-b961-0c27e8d09903
# ╠═e88e62d1-4c6d-4822-a107-009b1c68d49c
# ╟─51326bad-c0f3-4d0d-89a5-29ba3bf2834d
# ╠═62b08f70-b799-45b3-a393-183e7a21d5a0
# ╟─f26b334d-b6ef-4e6c-929a-d9cd13a4495a
# ╠═a86f0f47-e75c-4fbd-b540-03baf270273e
# ╟─64a39d5d-10fa-42d5-920f-06fddfe1e975
# ╠═d2f43da2-86d9-40a2-9001-bad3be0bc226
# ╠═a9a9428e-36b1-4b6d-bd2d-92b63ab3d8b2
# ╟─731fb3bf-9a0d-41e0-98c8-2c198b64c5a0
# ╠═a6d6f024-57e1-4602-8348-198b817f25b8
# ╟─9a97abcf-5bc4-4bb6-9c9c-12085aaa75a9
# ╠═6b676293-34d4-4182-bcb6-76eaef0cfa53
# ╟─4fe2bba3-b244-4c25-965c-fd39c8495014
# ╟─a767ffa3-3163-4b82-866b-78b75c76e6ec
# ╟─0355cde9-fc02-4d69-9208-abc1a6df2fab
# ╟─1d17c89d-078b-43e8-9fc2-3b9c08845685
# ╠═b77f331b-0d76-458c-9b84-3afde370b310
# ╟─9b8414f9-cfe2-432e-b13f-f3c934c71e44
# ╠═32236bbf-5fbb-471f-a240-edeb49e6fc71
# ╟─f5643e26-2a20-49c8-b511-13bd51554f75
# ╠═44c0a60c-2b22-47fa-8bea-435907ca1c94
# ╠═1b2f094d-83c9-4569-b466-574c3d99e103
# ╠═9035cbbc-02ec-492e-af76-ec994930970e
# ╠═185c1f43-23aa-497b-bfd1-63ccee901b94
# ╟─8aed3a9f-7efc-4915-91e4-865012515f92
# ╠═7d01ec07-976a-4661-9d62-7f24d11097d6
# ╠═40f64809-262a-4706-ba3d-2659bbd224e9
# ╟─1fe5512b-1f64-4747-ae45-5e3b570e9e2e
# ╠═65baaf4e-bf4d-4ea8-82b8-1a2e5ad6b20a
# ╟─f0254bce-2cdd-45b3-80fb-debb608069dc
# ╠═c5c33a46-21b8-4d9c-850d-28a2a06e3218
# ╟─8fdacc64-a2ee-4493-9eb6-a2f098570844
# ╠═e34efd0b-3206-4494-ad82-4c461cdfab2c
# ╟─87158b9e-59f9-49ea-beca-d55ce31be213
# ╠═6f74f6be-58c2-4ba4-a18e-abe2d4befaf5
# ╠═962817ec-26bb-441d-9215-29c2552c0488
# ╠═d048a3bc-e058-4171-a4ba-a4f3362c283f
# ╟─7ba0b638-6a65-4422-874d-a11b17196e21
# ╠═ef272daf-5bf8-4e0a-bb41-583d36898ed2
# ╟─7c750260-cf54-4425-846c-eb1fd8893ccd
# ╠═fe514dd8-dcea-4f79-a7a5-9809be9b0d2d
# ╟─b0ec5129-4b6f-4085-9fdd-c7290e893d16
# ╠═a9a0f1c1-edeb-4315-8f89-3e792318989c
# ╠═a385cec5-7909-4a8b-8958-b88b0556ef59
# ╟─bb535534-b195-4139-a5b9-4e469d783a9e
# ╠═604df609-4f1e-410e-86dc-4cd61841ec13
# ╠═0ac9ebbc-6e8d-4a06-a5d5-a48092847f98
# ╟─5a2a2f51-adf0-4ac7-911f-5ec961e9154a
# ╠═276d7f23-08f2-4b01-beed-07249b1aafaa
# ╟─2ebeeeda-3912-47e4-98e5-34a2e6537103
# ╠═28de6463-7a25-4430-bc95-f8294d85c2df
# ╟─9ee13f25-c167-46fe-84e7-2790e0f9fb14
# ╠═8ece00af-463a-479f-b40a-3353af33ab69
# ╟─578583a4-7a6c-4154-9bd1-7b721d761b78
# ╟─54445272-7b73-46f9-823c-7a69a830a884
# ╠═aaa37358-1a36-4f66-9ee5-e195f2a0f939
# ╟─7f386c88-aee7-40f2-9e22-c8016be8ca4b
# ╠═cdf1c8f5-9a41-4551-9fe7-92874010731b
# ╟─18931049-b509-41b8-96f4-dd06e7734bcf
# ╠═fe2035de-81d1-4cd9-b797-0d628e93c773
# ╟─ddbe514a-2c92-4e80-a256-d2515dc6890c
# ╠═2940f804-2126-4a49-8267-fa76c27a6b83
# ╟─1619a70c-ab34-44ec-96ca-495503b915e7
# ╠═66deda8d-c35f-4f21-9950-1702d66b8cf5
# ╟─5691fe91-3354-4671-bc52-08219d18ebbf
# ╟─b39f073c-832f-4e31-8d6a-2377fe3a1375
# ╠═b97ac4b5-2ce2-45f8-b85a-3e97945404de
# ╠═6bcbe880-be3f-4eb0-95e6-87050e7fe2dc
# ╟─83d6ab60-b26d-4e5f-afe1-e6be8f1ed18e
# ╠═b82d098d-fce1-4d0d-a40c-9a7f15007d43
# ╟─c1eeb631-f5cf-4cc4-b065-e1b5e372e03e
# ╠═4baecafb-bf57-44e8-9a95-c183607b6a4c
# ╟─14a7fb5a-9f60-4025-ba9c-0198ae89302b
# ╠═5e3896f0-206f-4c56-aa9e-55590ba97c7b
# ╟─d162ac4a-91aa-46b5-abf0-ad6bc45a2a12
# ╠═202cd904-3dce-485f-84ad-997d208c550a
# ╟─15fbc36f-5d9c-42f0-9f2a-873b400145d6
# ╠═d92f7d73-00b7-4c8b-8c3d-7af50e713246
# ╟─4d7d7e8e-8b98-443b-9f5e-e028fa949dc6
# ╠═4a0979ce-c7c5-49c7-87ef-4bb507d87602
# ╟─8037cfe4-f4f7-45c1-9164-3be7fec76a0b
# ╠═141de90c-1548-4d9f-ad1d-405fcb7edae7
# ╟─ea54121c-b413-4bbc-93fc-3e671d75adf7
# ╟─673b3005-080e-487f-998d-60f7505aa878
# ╠═715a2169-1c8f-4df0-ae67-1aedac9433ad
# ╠═48423f21-5a47-49b7-b980-e0663f7a6aac
# ╟─f644a7d2-a3a8-470f-b71a-e3c862599dd2
# ╠═e0ab2962-f8d7-4844-816d-e6c738d76f95
# ╠═382cfa60-d3d2-46a4-a81b-9226bbcf5ef2
# ╟─73a88b71-9cab-4d14-8814-ef41a10b2e8f
# ╠═0ad9a3f2-38fd-411c-a6e5-25bfa46e3afb
# ╠═588c0476-c0f0-4072-8e89-ca587a81dcd3
# ╠═86b71106-f7c2-4adc-a71d-89fbc99c807e
# ╟─3225486d-44ad-45d3-9255-b4b241094eca
# ╠═fbf72ca8-6101-4a4d-a6eb-4614151f9e83
# ╟─925b76df-668e-40de-85eb-67e401654a4a
# ╠═25610407-be23-4518-9b1f-48fd3d436a9d
# ╟─8fafc604-cc8a-4368-b9b0-e943f9774d49
# ╠═29295128-f115-4bfa-89af-c4017d0b85bf
# ╟─12a39248-4d59-4869-9487-8801e56e9f83
# ╠═e765ecd3-3e79-48ab-9663-c7a8f8794bd0
# ╟─99e1e14b-33f1-47fb-aab8-a4e8100ffcae
# ╠═bf6ab39a-3d93-4080-827b-1d76f2c00cd5
# ╟─82298f2d-f01f-49b4-93e2-bb93747d7251
# ╠═949cd9c9-a365-4b16-82bb-708ce2f1777d
# ╟─1b6a29c4-6643-443b-a0ea-5ca5489e21fc
# ╠═d7399528-1956-4048-9b8d-c37a96f065e0
# ╠═07a4816d-8f72-44ac-9cfc-bc2d9fcc7ceb
# ╠═ada5b74c-4fb4-40fa-9681-c9d28100e1c8
# ╟─50f76d97-1830-487b-9cfc-f983b6d2e438
# ╠═0a572ce5-c512-4e32-bf1a-3bbbf1a923b8
# ╠═d235ae94-1f90-4995-8e8b-6ad8b8c5156d
# ╠═78009959-931d-4450-89a3-b2a3b49eb4e3
# ╠═4d0eca3e-b0b5-463a-8940-87f0a35a6a3c
# ╟─32252625-e515-47ec-935f-008df3e9d2a7
# ╠═e2082eae-083d-4226-812b-dfc7ed0152f2
# ╠═a80ddf46-0673-4196-94c8-04d06c469fb2
# ╠═b0ec5cf1-0ae1-4d33-918a-061065e2207b
# ╠═ed3eeff6-75c8-4c24-9723-cbd002275fed
# ╟─218874db-d88b-4bc6-b8ad-53c574cd5b8f
# ╟─63a2831a-f9dd-4a35-8dd4-680dee36994f
# ╠═d3cfd585-8c47-49ba-ad3a-91d11dd11dcd
# ╠═7ea0e64e-c153-4994-ba8c-c4cfee894866
# ╠═e779cfa4-d349-4e81-bd64-fe0a8f71a067
# ╠═19c52194-9a1e-4af6-897e-154415bdd018
# ╠═36b4f380-6356-4fde-b64a-2b1f16c011f0
# ╠═53908a81-07be-4dbe-a617-b3bb1c107bc8
# ╠═6305f6b3-2ad6-43ba-a1b4-1f730f620afa
# ╠═6e7fad82-a342-4fd8-a57c-10128c73906c
# ╟─79840669-8b94-453a-9d37-489ea82b2743
# ╠═5a00b308-49b6-47ce-a8c4-c1fcfe88249d
# ╟─26671096-3285-4e29-86aa-caa8b53c31f3
# ╠═ef83fb23-d421-4df1-9344-3aa12af9e816
# ╟─e20176c6-3a39-4ca0-8be7-379dcca98bd2
# ╠═ab76fa37-4e00-41a5-bdfc-ae0c776a1cab
# ╠═b1f07781-de89-4d24-ae65-7e88f3e33bca
# ╟─74fdac10-95f9-4f10-8436-9f188f8d9c2b
# ╠═49aa1ae1-bceb-4dd7-86db-cd2ec193e15c
# ╠═531e5fe7-619d-423c-ad78-039ef439c319
# ╟─7d71bd8b-887b-42b8-b26c-7b9914e46a23
# ╟─95168671-e9b0-4f43-8782-bd083511fdf6
# ╟─b91bc734-0438-42d6-860e-ba6f97f42b5f
# ╠═ac8e5cc4-571d-4cd9-93d5-cc9021ae34ac
# ╟─1a090de0-31ec-412e-90ca-9a554afe9bba
# ╠═3d0e8678-a59d-4606-8e16-ff82f69eda81
# ╟─fbc673e8-6110-48fb-8cad-fc1e70e0bceb
# ╠═0b3dadb0-ea10-4834-aec5-9064cf5a96b9
# ╟─dc3d9f48-5c28-47ef-bcb8-c2db0539ad91
# ╠═5101ad1a-2575-4d2e-9831-2ff58d4ddecd
# ╟─fdc662dc-1b03-4c30-8b05-1dce800a3a46
# ╠═718c0ec9-dedd-40aa-86ac-8b1800d07ba4
# ╟─b224e5cf-a03e-4593-83df-e7dd0b1245de
# ╠═735b88f2-a3d3-452b-83d4-2346eada4e14
# ╟─6fa9db7e-b9d3-4bdf-acc7-b33595061d22
# ╠═d5c4877f-f5d3-41bb-bf30-3d3629ac70b3
# ╟─88dbb4f6-ddc8-4e55-ab70-2d27e3d62d54
# ╠═0e538383-0fcf-4b68-834b-ae0666730120
# ╠═1f3e2b53-7ffa-4f97-97f7-0421e15750c4
# ╟─f2049ce2-117e-4566-aafa-2e07f12c586a
# ╠═0c7559f0-5818-43d8-a907-9a5bf70f54a9
# ╠═134c476e-ee2a-49f9-a462-413155c20042
# ╠═6570b24b-8d04-4d79-b78d-60810fde88ed
# ╟─6233afd4-78c3-4750-b3b9-96af0bc861df
# ╠═4ac539fe-b5dd-4cfd-8bbf-e79043202bda
# ╟─286fb8ea-a9f6-42b1-9435-f7ab5b9d4ad6
# ╠═ce45627b-9b55-40cf-95e1-06469152b7ed
# ╠═10fb4d48-a550-4775-bcf7-cafb0430af1c
# ╟─ede362d3-537f-45a0-b546-449aabeae3e1
# ╟─367e7fb2-445d-467c-9a46-78e34f0a95d7
# ╟─c4c5a7ae-eee2-4544-b011-52e819c0b1b7
# ╟─c1cdc5a7-5af5-42fa-9186-4a1d1e8d37a6
# ╟─b40bbeb2-5088-4af9-ae3f-57c44faaa25c
# ╠═aa819682-34bf-436e-bfd2-c23bb12ae952
# ╟─68e8f9b2-a545-481b-a47f-081fce300731
# ╠═41fef0c8-1668-4439-98c7-01fd7007152c
# ╟─1aa13f41-26bc-4583-93a2-2720eaed5203
# ╠═76012ecf-be96-46e2-809e-3a76ed9649f8
# ╟─6f73368a-6e88-465e-9fea-d7ce69376fd0
# ╟─d5dee4ec-2b92-4106-aac5-1ea508a9b04e
# ╠═2ab4cdba-9ae3-4293-ad75-40aa1993b8d3
# ╠═821d9942-ad13-412a-9806-e3055d5cc0db
# ╠═feef0409-838a-4d4c-af20-dffb231914da
# ╠═a3f71dea-7454-4771-857d-8c3db3db1b08
# ╠═e79c52af-29e5-485b-ae8a-7c927ac0d917
# ╟─d548bc1a-2e20-4b7f-971b-1b07faaa4c13
# ╟─228e9bf1-cfd8-4285-8b68-43762e1ae8c7
# ╟─23974dfc-7412-4983-9dcc-16e7a3e7dcc4
# ╟─8aa46a2a-e675-41c6-830e-0e16818c24c3
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
