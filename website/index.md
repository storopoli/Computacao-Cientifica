# Computação Científica com Julia

[![CC BY-SA
4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by-sa/4.0/)

\blurb{Bem-vindo à Disciplina de **Computação Científica com [Julia](https://julialang.org/)** do Mestrado e Doutorado em Informática e Gestão do Conhecimento (PPGI) da [UNINOVE](https://uninove.br)}

## Julia

[**Julia**](https://www.julialang.org) é uma linguagem rápida de tipagem dinâmica que compila just-in-time (JIT) em código nativo binário usando LLVM. Ela ["roda como C mas escreve como Python"](https://www.nature.com/articles/d41586-019-02310-3), isto quer dizer que é *extremamente* rápida, de fácil prototipagem e leitura/escrita de código. Além disso, ela é multi-paradigma combinando as características de programação imperativa, funcional, e orientada a objetos.

**Pré-requisito(s):** lógica de programação e simples conceitos teóricos sobre álgebra linear, dados tabulares, grafos e redes, otimização matemática, machine learning, estatística Bayesiana e redes neurais.

### Sobre Julia:

* [**Documentação de Julia**](https://docs.julialang.org): A documentação de [Julia](https://www.julialang.org) é um recurso muito amigável e bem escrito que explica o design básico e a funcionalidade da linguagem.
* [**Thinking Julia**](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html) (Lauwens e Downey, 2019): livro introdutório para iniciantes que explica os principais conceitos e funcionalidades por trás da linguagem [Julia](https://www.julialang.org) . Disponível gratuitamente online.
* **Julia High Performance** (Sengupta e Edelman, 2019): livro de dois dos criadores da linguagem [Julia](https://www.julialang.org) ([Avik Sengupta](https://www.linkedin.com/in/aviks) e [Alan Edelman](http://www-math.mit.edu/~edelman/)), aborda como tornar [Julia](https://www.julialang.org) ainda mais rápida com alguns princípios e truques computacionais.
* [**A programming language to heal the planet together**](https://youtu.be/qGW0GT1rCvs): Julia (TEDx Talks, 2020): um vídeo no YouTube do [Alan Edelman](http://www-math.mit.edu/~edelman/) sobre as lacunas que [Julia](https://www.julialang.org) pretende preencher no mundo da computação científica.
* [**The Unreasonable Effectiveness of Multiple Dispatch**](https://youtu.be/kc9HwsxE1OY). (The Julia Programming Language, 2019): um vídeo no YouTube de um dos criadores da linguagem [Julia](https://www.julialang.org), [Stefan Karpinski](https://karpinski.org/), sobre um dos principais diferenciais da linguagem, [**Despacho Múltiplo**](https://en.wikipedia.org/wiki/Multiple_dispatch) (*Multiple Dispatch*).
* **Notebooks [Pluto](https://plutojl.org/)**: o conteúdo da disciplina é todo feito com Notebooks [Pluto](https://plutojl.org/) que são ambientes reativos e dinâmicos de fácil demonstração e exploração de código [Julia](https://www.julialang.org) .

## Objetivos da Disciplina:

Ao completar essa disciplina, alunos estarão aptos à:

1. programar algoritmos em [Julia](https://julialang.org/)
2. fazer benchmark correto de código [Julia](https://julialang.org/) com [`BenchmarkTools.jl`](https://juliaci.github.io/BenchmarkTools.jl/dev/)
3. utilizar estrutura de dados de [Julia](https://julialang.org/)
4. executar operações e decomposições de álgebra linear com [`LinearAlgebra.jl`](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/)
5. manipular dados tabulares com [`DataFrames.jl`](https://dataframes.juliadata.org/stable/)
6. plotar dados com [`Plots.jl`](http://docs.juliaplots.org/latest/) e [`StatsPlots.jl`](https://github.com/JuliaPlots/StatsPlots.jl)
7. criar, manipular e analisar grafos e redes com [1LightGraphs.jl`](https://juliagraphs.org/LightGraphs.jl/latest/)
8. especificar, modelar e otimizar matematicamente problemas complexos com [`JuMP.jl`](https://jump.dev/)
9. treinar algoritmos demachine learning com [`MLJ.jl`](https://alan-turing-institute.github.io/MLJ.jl/dev/)
10. especificar modelos probabilísticos Bayesianos e executar amostradores *Markov Chain Monte Carlo* (MCMC) com [`Turing.jl`](https://turing.ml)
11. criar e treinar redes neurais usando [`Flux.jl`](https://fluxml.ai/)

## Tópicos

1. [**Introdução à Julia**](/1_Julia/) (Bezanson et al., 2017; Perkel, 2019)
2. [**Como fazer benchmarks de código Julia com `BenchmarkTools.jl`**](/2_BenchmarkTools/) (Chen & Revels, 2016)
3. [**Estruturas de Dados (`Array` e `Dict`) de Julia**](/3_Data_Structures/)
4. [**Operações de Álgebra Linear com `LinearAlgebra.jl`**](/4_LinearAlgebra/)
5. [***Input* e *Output* e Manipulação de Dados Tabulares com `DataFrames.jl`**](/5_DataFrames_IO/) (White et al., 2020)
6. [**Agregações (*groupby*), Sumarizações e *joins* de Dados Tabulares com `DataFrames.jl`**](/6_DataFrames_Ops/) (White et al., 2020)
7. [**Visualização de Dados com `Plots.jl` e `StatsPlots.jl`**](/7_Plots/) (Breloff et al., 2021)
8. [**Grafos e Análise Redes com `LightGraphs.jl`**](/8_LightGraphs/) (Bromberger & Contributors, 2017)
9. [**Modelagem e Otimizações Matemáticas com `JuMP.jl`**](/9_JuMP/) (Dunning et al., 2017)
10. [***Machine Learning* com `MLJ.jl`**](/10_MLJ/) (Blaom et al., 2020)
11. [**Modelos Probabilísticos Bayesianos com `Turing.jl`**](/11_Turing/) (Ge et al., 2018; Xu et al., 2020; Storopoli, 2021)
12. [**Redes Neurais com `Flux.jl`**](/12_Flux/) (Innes et al., 2018; Innes, 2018)


## Autor

Jose Storopoli, PhD - [*Lattes* CV](http://lattes.cnpq.br/2281909649311607) - [ORCID](https://orcid.org/0000-0002-0559-5176) - <https://storopoli.io>

## Como usar esse conteúdo?

Este conteúdo possui *licença livre para uso* (CC BY-SA). Você é mais do que bem-vindo para contribuir com [issues](https://www.github.com/storopoli/Computacao-Cientifica/issues) e [pull requests](https://github.com/storopoli/Computacao-Cientifica/pulls).
