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

# ╔═╡ a0f907f5-1d81-451e-b34b-8d622e5e47a2
Resource("https://julialang.org/assets/benchmarks/benchmarks.svg")

# ╔═╡ 98ead09d-8ca9-41a4-95cf-fc07bd34db16
sizeof(1) # 8 bytes

# ╔═╡ 107f0d48-cd18-4456-8b5e-4971b5fbe2e8
typeof(UInt(1) + 1)

# ╔═╡ fc833387-ae84-4220-9086-ee5dedb11d9d
abstract type Things end # We'll come back to this line

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
### Velocidade 🏎
"""

# ╔═╡ 3712de35-d34e-4f6f-9041-cac2efb2730a
md"""
!!! tip "💡 Como Julia Funciona"
	Julia funciona assim: ela pega o **código em Julia e expõe em linguagem de montagem (*Assembly*) para o compilador LLVM** fazer o que sabe melhor: otimizar o código como quiser.
"""

# ╔═╡ d90ce98c-6538-4a6d-9b45-e3f5c8ae2bb3
md"""
#### Alguns Projetos Interessantes:

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
#### Um exemplo prático com dados tabulares

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
##### Resultados:

* **Julia: 0.368ms** 🚀

* Python: 1.57ms 🙈

* R: 2.52ms #vairubinho 🐌

"""

# ╔═╡ 3c911397-cb1d-4929-b0e8-4aff516331b5
md"""
### Facilidade de Codificação

!!! tip "💡 Unicode"
    Veja o suporte à unicode e $\LaTeX$.

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

# ╔═╡ b6acb557-1a04-4021-a103-4be3a066be38
md"""
#### Python my a**! (Deep Learning)

$(Resource("https://storopoli.io/Bayesian-Julia/pages/images/ML_code_breakdown.svg"))
"""

# ╔═╡ a3ba253e-fbda-471e-ab82-c2ddeaf3ddf9
md"""
#### Pequeno Interlúdio para falar mal de Python
"""

# ╔═╡ a6a7bccf-4012-450c-ac02-9fdef68f0c9e
md"""
##### Int64 são 8 bytes né? #sqn
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
##### `UInt` + `UInt` = `UInt`?
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
### Despacho Múltiplo

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

#### Tentativa em Python

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
#### Agora em Julia
"""

# ╔═╡ b4938cbd-27bc-4999-919a-a32e503dadb0
md"""
#### Tentativa em C++

```c++
#include <iostream>
#include <string>

using std::string;
using std::cout;

class Pet {
    public:
        string name;
};

string meets(Pet a, Pet b) { return "FALLBACK"; } // If we use `return meets(a, b)` doesn't work

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
#### Agora em Julia
"""

# ╔═╡ 81ae472d-7195-4525-87ae-1429972b8816
md"""
#### Exemplo: One-Hot Vector

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

# ╔═╡ d548bc1a-2e20-4b7f-971b-1b07faaa4c13
md"""
## Ambiente
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
## Licença

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
# ╟─3712de35-d34e-4f6f-9041-cac2efb2730a
# ╟─d90ce98c-6538-4a6d-9b45-e3f5c8ae2bb3
# ╟─9104cac0-b5a8-4a54-a636-6475c0d3489f
# ╟─cf994c69-7adb-4461-8273-165574072582
# ╟─a0f907f5-1d81-451e-b34b-8d622e5e47a2
# ╟─3c911397-cb1d-4929-b0e8-4aff516331b5
# ╟─b6acb557-1a04-4021-a103-4be3a066be38
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
# ╟─d548bc1a-2e20-4b7f-971b-1b07faaa4c13
# ╟─228e9bf1-cfd8-4285-8b68-43762e1ae8c7
# ╠═23974dfc-7412-4983-9dcc-16e7a3e7dcc4
# ╟─8aa46a2a-e675-41c6-830e-0e16818c24c3
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
