# Ciência de Dados e Computação Científica com Julia

~~~
<img src="https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg" style="width: 180px; height: auto;">
~~~

\blurb{Bem-vindo à Disciplina de **Ciência de Dados e Computação Científica com [Julia](https://julialang.org/)** do Mestrado e Doutorado em Informática e Gestão do Conhecimento (PPGI) da [UNINOVE](https://uninove.br)}

~~~
<style>.embed-container { position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; } .embed-container iframe, .embed-container object, .embed-container embed { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }</style><div class='embed-container'><iframe src='https://www.youtube.com/embed/videoseries?list=PLpTXaEnTpmwPE4amQWlikU8Zt6mwmgyny' frameborder='0' allowfullscreen></iframe></div>
~~~

Esta disciplina foi inspirada na disciplina do MIT "Computational Thinking, a live online Julia/Pluto textbook, <https://computationalthinking.mit.edu>".

## Julia

[**Julia**](https://www.julialang.org) é uma linguagem rápida de tipagem dinâmica que compila just-in-time (JIT) em código nativo binário usando LLVM. Ela ["roda como C mas escreve como Python"](https://www.nature.com/articles/d41586-019-02310-3), isto quer dizer que é *extremamente* rápida, de fácil prototipagem e leitura/escrita de código. Além disso, ela é multi-paradigma combinando as características de programação imperativa, funcional, e orientada a objetos.

**Pré-requisito(s):** lógica de programação e simples conceitos teóricos sobre  dados tabulares, grafos e redes, otimização matemática, machine learning, estatística Bayesiana e redes neurais.

### Sobre Julia:

* [**Documentação de Julia**](https://docs.julialang.org): A documentação de [Julia](https://www.julialang.org) é um recurso muito amigável e bem escrito que explica o design básico e a funcionalidade da linguagem.
* [**Thinking Julia**](https://benlauwens.github.io/ThinkJulia.jl/latest/book.html) (Lauwens e Downey, 2019): livro introdutório para iniciantes que explica os principais conceitos e funcionalidades por trás da linguagem [Julia](https://www.julialang.org) . Disponível gratuitamente online.
* **Julia High Performance** (Sengupta e Edelman, 2019): livro de dois dos criadores da linguagem [Julia](https://www.julialang.org) ([Avik Sengupta](https://www.linkedin.com/in/aviks) e [Alan Edelman](http://www-math.mit.edu/~edelman/)), aborda como tornar [Julia](https://www.julialang.org) ainda mais rápida com alguns princípios e truques computacionais.
* [**A programming language to heal the planet together**](https://youtu.be/qGW0GT1rCvs): Julia (TEDx Talks, 2020): um vídeo no YouTube do [Alan Edelman](http://www-math.mit.edu/~edelman/) sobre as lacunas que [Julia](https://www.julialang.org) pretende preencher no mundo da computação científica.
* [**The Unreasonable Effectiveness of Multiple Dispatch**](https://youtu.be/kc9HwsxE1OY). (The Julia Programming Language, 2019): um vídeo no YouTube de um dos criadores da linguagem [Julia](https://www.julialang.org), [Stefan Karpinski](https://karpinski.org/), sobre um dos principais diferenciais da linguagem, [**Despacho Múltiplo**](https://en.wikipedia.org/wiki/Multiple_dispatch) (*Multiple Dispatch*).
* **Notebooks [Pluto](https://plutojl.org/)**: o conteúdo da disciplina é todo feito com Notebooks [Pluto](https://plutojl.org/) que são ambientes reativos e dinâmicos de fácil demonstração e exploração de código [Julia](https://www.julialang.org).
* [**Julia Programming for Nervous Beginners**](https://juliaacademy.com/p/julia-programming-for-nervous-beginners) (Laurie, 2021): um curso de 4 semanas da [JuliaAcademy](https://juliaacademy.com/) que ensina desde o zero de computação até o básico da linguagem [Julia](https://www.julialang.org).
* [**Julia Data Science**](https://juliadatascience.io) (Storopoli, Huijzer & Alonso, 2021): livro opensource e gratuito sobre `Julia`. Possui tradução para Português e Chinês.
* **Numerical Methods for Scientific Computing** (Novak, 2022): livro gratuito com muitas aplicações em métodos numéricos e computação científica. Código todo em `Julia`.
* [**Statistics with Julia**](https://statisticswithjulia.org/) (Nazarathy & Klok, 2021): livro de estatística e machine learning com Julia.

## Objetivos da Disciplina:

Ao completar essa disciplina, alunos estarão aptos à:

1. programar em [Julia](https://julialang.org/)
2. programar algoritmos em [Julia](https://julialang.org/)
3. fazer *benchmark* correto de código [Julia](https://julialang.org/) com [`BenchmarkTools.jl`](https://juliaci.github.io/BenchmarkTools.jl/dev/)
4. utilizar estrutura de dados de [Julia](https://julialang.org/)
5. executar operações em paralelo na CPU usando [`Threads.jl`](https://docs.julialang.org/en/v1/base/multi-threading/), [`ThreadsX.jl`](https://tkf.github.io/ThreadsX.jl/dev/) e `SIMD` com [`LoopVectorization.jl`](https://juliasimd.github.io/LoopVectorization.jl/stable/)
6. manipular dados tabulares com [`DataFrames.jl`](https://dataframes.juliadata.org/stable/)
7. plotar dados com [`Plots.jl`](http://docs.juliaplots.org/latest/), [`StatsPlots.jl`](https://github.com/JuliaPlots/StatsPlots.jl) e [`AlgebraOfGraphics.jl`](http://juliaplots.org/AlgebraOfGraphics.jl/stable/)
8. criar, manipular e analisar grafos e redes com [`Graphs.jl`](https://juliagraphs.org/Graphs.jl/dev/)
9.  especificar, modelar e otimizar matematicamente problemas complexos com [`JuMP.jl`](https://jump.dev/)
10. treinar algoritmos de machine learning com [`MLJ.jl`](https://alan-turing-institute.github.io/MLJ.jl/dev/)
11. especificar modelos probabilísticos Bayesianos e executar amostradores *Markov Chain Monte Carlo* (MCMC) com [`Turing.jl`](https://turing.ml)
12. criar e treinar redes neurais usando [`Flux.jl`](https://fluxml.ai/)

## Tópicos

1. [**Linguagem Julia e Estrutura de Dados Nativas**](/01_Julia/) (Bezanson et al., 2017; Perkel, 2019)
2. [**Algoritmos e *Benchmarks* com `BenchmarkTools.jl`**](/02_BenchmarkTools/) (Chen & Revels, 2016)
3. [**_Performance_ e Operações Paralelas**](/03_Parallel/)
4. [**Dados Tabulares com `DataFrames.jl`**](/04_DataFrames/) (White et al., 2020; Storopoli, Huijzer & Alonso, 2021)
5. [**Séries Temporais `DataFrames.jl`**](/05_TimeSeries/)(White et al., 2020; Storopoli Storopoli, Huijzer & Alonso, 2021)
6. [**Visualização de Dados com `Plots.jl`, `StatsPlots.jl` e `AlgebraOfGraphics.jl`**](/06_Plots/) (Breloff et al., 2021; Storopoli, Huijzer & Alonso, 2021)
7. [**Grafos e Análise Redes com `Graphs.jl`**](/07_Graphs/) (Bromberger & Contributors, 2017)
8.  [**Modelagem e Otimizações Matemáticas com `JuMP.jl`**](/08_JuMP/) (Dunning et al., 2017)
9.  [**Modelos Probabilísticos Bayesianos com `Turing.jl`**](/09_Turing/) (Ge et al., 2018; Xu et al., 2020; Storopoli, 2021)
10. [**_Machine Learning_ com `MLJ.jl`**](/10_MLJ/) (Blaom et al., 2020)
11. [**_Deep Learning_ com `Flux.jl`**](/11_Flux/) (Innes et al., 2018; Innes, 2018)


## Autor

Jose Storopoli, PhD - [*Lattes* CV](http://lattes.cnpq.br/2281909649311607) - [ORCID](https://orcid.org/0000-0002-0559-5176) - <https://storopoli.io>

## Como usar esse conteúdo?

Este conteúdo possui *licença livre para uso* (CC BY-SA). Você é mais do que bem-vindo para contribuir com [issues](https://www.github.com/storopoli/Computacao-Cientifica/issues) e [pull requests](https://github.com/storopoli/Computacao-Cientifica/pulls).

Para citar este conteúdo, use:

```plaintext
Storopoli (2021). Ciência de Dados e Computação Científica com Julia. https://storopoli.github.io/Computacao-Cientifica.
```

Ou em formato BibTeX para $\LaTeX$:

```plaintext
@misc{storopoli2021programacaojulia,
  author = {Storopoli, Jose},
  title = {Ciência de Dados e Computação Científica com Julia},
  url = {https://storopoli.github.io/Computacao-Cientifica},
  year = {2021}
}
```

~~~
<img src="https://licensebuttons.net/l/by-sa/4.0/88x31.png" style="width: 180px; height: auto;">
~~~
