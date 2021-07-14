### A Pluto.jl notebook ###
# v0.15.1

using Markdown
using InteractiveUtils

# ╔═╡ 27f62732-c909-11eb-27ee-e373dce148d9
begin
	using BenchmarkTools
	using LinearAlgebra
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

# ╔═╡ e4dbc9c7-cc0d-4305-ac6a-c562b233d965
Resource("https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg", :width => 120, :display => "inline")

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
a = randn(42_000)

# ╔═╡ 584973af-9d1c-4c79-ad0b-f4c8f8b39ee3
@benchmark summed($a)

# ╔═╡ bdbe2067-2101-4f36-a64d-442afc9c20dc
function sumsimd(a)
	result = zero(eltype(a))
	@simd for x in a
    result += x
  end
  return result
end

# ╔═╡ 6be5724f-78ed-49e4-8ac5-07caea58a4ee
@benchmark sumsimd($a) # 🚀

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

# ╔═╡ d4c8819f-31fe-4e2e-b10d-cc0278cd29d5


# ╔═╡ d4bea1f2-e30d-4fff-bdad-644b80f4e704
f(x)

# ╔═╡ c7e13998-1b4b-4363-b89a-a1f2c8f92a1a
f(y)

# ╔═╡ ee77185f-1abf-425a-aec0-1f84f54bcb41
abstract type Pet end

# ╔═╡ 461bd896-6d65-4b76-8934-2e38cfd86231
struct Dog <: Pet name::String end

# ╔═╡ 06009452-af10-4ed6-aa52-60297536efd9
struct Cat <: Pet name::String end

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

# ╔═╡ d90ce98c-6538-4a6d-9b45-e3f5c8ae2bb3
md"""
### Alguns Projetos Interessantes:

1. NASA usa Julia em super computador para analisar o ["maior conjunto de Planetas do tamanho da Terra já encontrados"](https://exoplanets.nasa.gov/news/1669/seven-rocky-trappist-1-planets-may-be-made-of-similar-stuff/) e conseguiu impressionantes **acelerações 1,000x** em catalogar 188 milhões de objetos astronômicos em 15 minutos!


2. [A Climate Modeling Alliance (CliMa)](https://clima.caltech.edu/) está usando majoritariamente Julia para **modelar clima na GPU e CPU**. Lançado em 2018 em colaboração com pesquisadores da Caltech, do Laboratório de Propulsão a Jato da NASA e da Escola de Pós-Graduação Naval, o CLIMA está utilizando o progresso recente da ciência computacional para desenvolver um modelo de sistema terrestre que pode prever secas, ondas de calor e chuvas com precisão sem precedentes.


3. [A Administração Federal de Aviação dos EUA (FAA) está desenvolvendo um **Sistema de prevenção de colisão aerotransportada (ACAS-X)** usando Julia] (https://youtu.be/19zm1Fn0S9M).Soluções anteriores usavam Matlab para desenvolver os algoritmos e C ++ para uma implementação rápida. Agora, a FAA está usando uma linguagem para fazer tudo isso: Julia.


4. [**Aceleração de 175x** para modelos de farmacologia da Pfizer usando GPUs em Julia] (https://juliacomputing.com/case-studies/pfizer/). Foi apresentado como um [pôster](https://chrisrackauckas.com/assets/Posters/ACoP11_Poster_Abstracts_2020.pdf) na 11ª Conferência Americana de Farmacometria (ACoP11) e [ganhou um prêmio de qualidade](https: //web.archive .org / web / 20210121164011 / https: //www.go-acop.org/abstract-awards).


5. [O Subsistema de Controle de Atitude e Órbita (AOCS) do satélite brasileiro Amazônia-1 é **escrito 100% em Julia**](https://discourse.julialang.org/t/julia-and-the-satellite -amazonia-1/57541) por [Ronan Arraes Jardim Chagas](https://ronanarraes.com/)


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

@benchmark combine(groupby(df, :x), :y => median, :z => mean)
```

##### Python `pandas`:
```python
import pandas as pd
import numpy as np

n = 10000

df = pd.DataFrame({'x': np.random.choice(['A', 'B', 'C', 'D'], n, replace=True),
                   'y': np.random.randn(n),
                   'z': np.random.rand(n)})

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

# ╔═╡ 81ae472d-7195-4525-87ae-1429972b8816
md"""
### Exemplo: One-Hot Vector

Um one-hot vector é um **vetor de inteiros em que todos os elementos são zero (0) exceto para um único elemento que é um (1)**.

No **aprendizado de máquina**, a codificação one-hot é um método frequentemente usado para lidar com **dados categóricos**. Como muitos modelos de aprendizado de máquina precisam que suas variáveis de entrada sejam numéricas, as variáveis categóricas precisam ser transformadas na parte de **pré-processamento de dados**.

Como representaríamos vetores one-hot em Julia?

**Simples**: criamos um novo tipo `OneHotVector` em Julia usando a palavra-chave `struct` e definimos dois campos `len` e `ind`, que representam o comprimento (*length*) do `OneHotVector` e cujo índice (*index*) é a entrada 1 (ou seja, qual índice é "quente"). Em seguida, definimos novos métodos para as funções do módulo `Base` de Julia `size()` e `getindex()` para nosso recém-definido `OneHotVector`.

> Exemplo altamente inspirado em um [post de Vasily Pisarev](https://habr.com/ru/post/468609/)
"""

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

# ╔═╡ 5b87ddf1-4f76-46ed-a954-e2b814dcc7a8
with_terminal() do
	@code_warntype quadratic(42.0, 42.0, 42.0)
end

# ╔═╡ ce5e7964-9b19-4968-89e6-6deb429fa554
with_terminal() do 
	@code_llvm quadratic(42.0, 42.0, 42.0)
end

# ╔═╡ efc03594-5c0f-4841-b6d1-22cb3cdeca4b
with_terminal() do 
	@code_llvm quadratic(42, 42, 42)
end

# ╔═╡ f530d914-e940-4be2-9d00-688faa6a13a1
with_terminal() do
	@code_native quadratic(42, 42.0, 42.0)
end

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

# ╔═╡ 21a2f28e-dfa9-4ab3-822c-447e6262d387
@benchmark inner_sum($A, $onehot)

# ╔═╡ 62dd87d5-8a13-47eb-9a90-a10556e99b08
@benchmark inner_sum($A, $onehot)

# ╔═╡ 39ddde6a-9030-430c-ae39-1033720fd43a
md"""
# Sintaxe da Linguagem Julia

CamelCase são `type`s, `struct`s, `module`s e `package`s

snake_case é o resto: funções, métodos ou variáveis instanciadas
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
    name::String
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
   * `!=` ou `≠`: diferente (\neq TAB)


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
"""

# ╔═╡ a6c58949-56b3-4a4a-a496-099c6e6ab35e


# ╔═╡ 925dc80e-c594-457a-b2c9-288673ece8bc
md"""
## Condicionais `if`-`else`-`elseif`
"""

# ╔═╡ a38739cb-1838-4957-80c6-ff8469358e05
md"""
## `for`-Loops
"""

# ╔═╡ 624afde0-6e92-4be0-b944-ac9adaf72ece
md"""
## `while`-Loops
"""

# ╔═╡ af3299d2-3802-4cb5-8175-8ad26a7451aa
md"""
# Estrutura de Dados Nativas
"""

# ╔═╡ bd654c6b-31eb-440f-b56d-8baa6e3be45c
md"""
## Broadcast de Operadores e Funções
"""

# ╔═╡ fb925ccb-7e31-435b-91f5-84cf0467ae2d
md"""
## `String`
"""

# ╔═╡ db838095-2cc8-47ed-951e-1017d62c73dc
md"""
## `Tuple`
"""

# ╔═╡ cb3c0d7a-5d56-4970-af6b-4e98af1961bc
md"""
## `NamedTuple`
"""

# ╔═╡ 51326bad-c0f3-4d0d-89a5-29ba3bf2834d
md"""
## `UnitRange`
"""

# ╔═╡ 4fe2bba3-b244-4c25-965c-fd39c8495014
md"""
## `Array`
"""

# ╔═╡ e20176c6-3a39-4ca0-8be7-379dcca98bd2
md"""
## `Pair`
"""

# ╔═╡ 95168671-e9b0-4f43-8782-bd083511fdf6
md"""
## `Dict`
"""

# ╔═╡ 6233afd4-78c3-4750-b3b9-96af0bc861df
md"""
## `Symbol`
"""

# ╔═╡ 367e7fb2-445d-467c-9a46-78e34f0a95d7
md"""
# Sistema de Arquivos
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

# ╔═╡ 8aa46a2a-e675-41c6-830e-0e16818c24c3
md"""
# Licença

Este conteúdo possui licença [Creative Commons Attribution-ShareAlike 4.0 Internacional](http://creativecommons.org/licenses/by-sa/4.0/).

[![CC BY-SA 4.0](https://licensebuttons.net/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
InteractiveUtils = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
Pkg = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
BenchmarkTools = "~1.1.0"
PlutoUI = "~0.7.9"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Statistics", "UUIDs"]
git-tree-sha1 = "ffabdf5297c9038973a0a3724132aa269f38c448"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.1.0"

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
# ╟─165e0a37-dd2c-4dae-8cc6-b80615af6e30
# ╟─89dbf386-2216-400e-ab36-05599e1fb4c7
# ╟─575a6998-032b-40fb-9942-6ec39b1b69d7
# ╟─6c5d8d8f-b08f-4550-bc1b-9f19a6152bd4
# ╟─3e2441b6-1545-4f34-a418-f61b2dbf61e9
# ╟─0659cb16-eea6-4ef7-90e7-27a50deee15f
# ╟─6f1bec92-7703-4911-8ff5-668618185bf4
# ╟─3712de35-d34e-4f6f-9041-cac2efb2730a
# ╠═43f8ee8b-7d74-4ef3-88fe-41c44f0a0eee
# ╠═5b87ddf1-4f76-46ed-a954-e2b814dcc7a8
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
# ╠═d4c8819f-31fe-4e2e-b10d-cc0278cd29d5
# ╠═d4bea1f2-e30d-4fff-bdad-644b80f4e704
# ╠═c7e13998-1b4b-4363-b89a-a1f2c8f92a1a
# ╟─b4938cbd-27bc-4999-919a-a32e503dadb0
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
# ╟─81ae472d-7195-4525-87ae-1429972b8816
# ╠═8faf0fee-cad5-440f-bc2d-0fdb848ce42d
# ╠═cb276e1e-1b81-4705-b28b-b7b3e08332bc
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
# ╠═21a2f28e-dfa9-4ab3-822c-447e6262d387
# ╟─41801f25-e95a-49bc-9454-0328f13684b6
# ╠═8c7d2d8a-c547-45c1-bcf5-636584cdb3da
# ╟─f6042d46-94bf-45ad-aa23-f5e256c67571
# ╠═fa434fbe-0999-4c45-8ae2-87f5652c1b52
# ╠═62dd87d5-8a13-47eb-9a90-a10556e99b08
# ╠═39ddde6a-9030-430c-ae39-1033720fd43a
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
# ╠═e752e5bf-9a8a-4fd1-8e4b-f39b3fad6410
# ╠═e9e34c57-36f2-4f10-b16f-8ba34c38c957
# ╠═9bbb809a-27c5-47db-a5a0-ae836318868d
# ╠═6d0a36ab-0cd4-4502-973f-85f90aa0fc03
# ╠═dc13a6c0-3b40-43a9-9627-babfb0899e7f
# ╟─3a3f2e64-941a-4abe-bc6b-d4fb9a53a1f5
# ╠═a9134413-8ac2-4d70-ad87-5ce35bc74bda
# ╠═0329e55d-2845-4ba0-a10d-f91103559d60
# ╟─53ddf7fc-9886-4f64-973d-f62b9563943b
# ╠═6f2c5ff8-1015-4e57-87cb-1f79c2c0aed6
# ╟─7fac9fb9-1d6d-49c3-854a-e02a05473f1c
# ╠═d48cbefb-8993-4807-b370-c815048c613b
# ╠═d39fe930-1547-491d-a17b-570d44fde35d
# ╠═a6c58949-56b3-4a4a-a496-099c6e6ab35e
# ╠═925dc80e-c594-457a-b2c9-288673ece8bc
# ╠═a38739cb-1838-4957-80c6-ff8469358e05
# ╠═624afde0-6e92-4be0-b944-ac9adaf72ece
# ╠═af3299d2-3802-4cb5-8175-8ad26a7451aa
# ╠═bd654c6b-31eb-440f-b56d-8baa6e3be45c
# ╠═fb925ccb-7e31-435b-91f5-84cf0467ae2d
# ╠═db838095-2cc8-47ed-951e-1017d62c73dc
# ╠═cb3c0d7a-5d56-4970-af6b-4e98af1961bc
# ╠═51326bad-c0f3-4d0d-89a5-29ba3bf2834d
# ╠═4fe2bba3-b244-4c25-965c-fd39c8495014
# ╠═e20176c6-3a39-4ca0-8be7-379dcca98bd2
# ╠═95168671-e9b0-4f43-8782-bd083511fdf6
# ╠═6233afd4-78c3-4750-b3b9-96af0bc861df
# ╠═367e7fb2-445d-467c-9a46-78e34f0a95d7
# ╟─d548bc1a-2e20-4b7f-971b-1b07faaa4c13
# ╟─228e9bf1-cfd8-4285-8b68-43762e1ae8c7
# ╟─23974dfc-7412-4983-9dcc-16e7a3e7dcc4
# ╟─8aa46a2a-e675-41c6-830e-0e16818c24c3
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
