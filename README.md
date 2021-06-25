Computação Científica com [Julia](https://julialang.org/)
================

[![CC BY-SA
4.0](https://img.shields.io/badge/License-CC%20BY--SA%204.0-lightgrey.svg)](http://creativecommons.org/licenses/by-sa/4.0/)

Bem-vindo à Disciplina de **Computação Científica com [Julia](https://julialang.org/)** do Mestrado e Doutorado em Informática e Gestão do Conhecimento (PPGI) da [UNINOVE](https://uninove.br)

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
7. criar, manipular e analisar grafos e redes com [`LightGraphs.jl`](https://juliagraphs.org/LightGraphs.jl/latest/)
8. especificar, modelar e otimizar matematicamente problemas complexos com [`JuMP.jl`](https://jump.dev/)
9. treinar algoritmos demachine learning com [`MLJ.jl`](https://alan-turing-institute.github.io/MLJ.jl/dev/)
10. especificar modelos probabilísticos Bayesianos e executar amostradores *Markov Chain Monte Carlo* (MCMC) com [`Turing.jl`](https://turing.ml)
11. criar e treinar redes neurais usando [`Flux.jl`](https://fluxml.ai/)

## Tópicos

1. [**Introdução à Julia**](https://storopoli.io/Computacao-Cientifica/1_Julia/) (Bezanson et al., 2017; Perkel, 2019)
2. [**Como fazer benchmarks de código Julia com `BenchmarkTools.jl`**](https://storopoli.io/Computacao-Cientifica/2_BenchmarkTools/) (Chen & Revels, 2016)
3. [**Estruturas de Dados (`Array` e `Dict`) de Julia**](https://storopoli.io/Computacao-Cientifica/3_Data_Structures/)
4. [**Operações de Álgebra Linear com `LinearAlgebra.jl`**](https://storopoli.io/Computacao-Cientifica/4_LinearAlgebra/)
5. [***Input* e *Output* e Manipulação de Dados Tabulares com `DataFrames.jl`**](https://storopoli.io/Computacao-Cientifica/5_DataFrames_IO/) (White et al., 2020)
6. [**Agregações (*groupby*), Sumarizações e *joins* de Dados Tabulares com `DataFrames.jl`**](https://storopoli.io/Computacao-Cientifica/6_DataFrames_Ops/) (White et al., 2020)
7. [**Visualização de Dados com `Plots.jl` e `StatsPlots.jl`**](https://storopoli.io/Computacao-Cientifica/7_Plots/) (Breloff et al., 2021)
8. [**Grafos e Análise Redes com `LightGraphs.jl`**](https://storopoli.io/Computacao-Cientifica/8_LightGraphs/) (Bromberger & Contributors, 2017)
9. [**Modelagem e Otimizações Matemáticas com `JuMP.jl`**](https://storopoli.io/Computacao-Cientifica/9_JuMP/) (Dunning et al., 2017)
10. [***Machine Learning* com `MLJ.jl`**](https://storopoli.io/Computacao-Cientifica/10_MLJ/) (Blaom et al., 2020)
11. [**Modelos Probabilísticos Bayesianos com `Turing.jl`**](https://storopoli.io/Computacao-Cientifica/11_Turing/) (Ge et al., 2018; Xu et al., 2020; Storopoli, 2021)
12. [**Redes Neurais com `Flux.jl`**](https://storopoli.io/Computacao-Cientifica/12_Flux/) (Innes et al., 2018; Innes, 2018)


## Autor

Jose Storopoli, PhD - [*Lattes* CV](http://lattes.cnpq.br/2281909649311607) - [ORCID](https://orcid.org/0000-0002-0559-5176) - <https://storopoli.io>

## Como usar esse conteúdo?

Este conteúdo possui *licença livre para uso* (CC BY-SA). Você é mais do que bem-vindo para contribuir com [issues](https://www.github.com/storopoli/Computacao-Cientifica/issues) e [pull requests](https://github.com/storopoli/Computacao-Cientifica/pulls).

Para configurar um ambiente local:

1. Baixe e instale [Julia](https://www.julialang.org/downloads/)
2.  Clone o repositório do GitHub:
    `git clone https://github.com/storopoli/Computacao-Cientifica.git`
3.  Acesse o diretório: `Computacao-Cientifica`
4.  Abra os Notebooks Pluto no terminal de Julia:
    ```julia
    using Pkg
    Pkg.add("Pluto")
    using Pluto
    Pluto.run()
    ```

## Como citar esse conteúdo

Para citar o conteúdo use:

    Storopoli (2021). Computação Científica com Julia. https://storopoli.io/Computacao-Cientifica.

Or in BibTeX format (LaTeX):

    @misc{storopoli2021computacaocientificajulia,
      author = {Storopoli, Jose},
      title = {Computação Científica com Julia},
      url = {https://storopoli.io/Computacao-Cientifica},
      year = {2021}
    }

## Referências

* Besard, T., Churavy, V., Edelman, A. & Sutter, B. D. (2019). Rapid Software Prototypingfor Heterogeneous and Distributed Platforms.Advances in Engineering Software,132,29–46. https://doi.org/10.1016/j.advengsoft.2019.02.002

* Besard, T., Foket, C. & De Sutter, B. (2019). Effective Extensible Programming: UnleashingJulia on GPUs.IEEE Transactions on Parallel and Distributed Systems,30(4), 827–841. https://doi.org/10.1109/TPDS.2018.287206

* Bezanson, J., Edelman, A., Karpinski, S. & Shah, V. B. (2017). Julia: A Fresh Approach to Numerical Computing. *SIAM review, 59*(1), 65–98.

* Blaom, A. D., Kiraly, F., Lienart, T., Simillides, Y., Arenas, D. & Vollmer, S. J. (2020). MLJ: A Julia Package for Composable Machine Learning. *Journal of Open Source Software, 5*(55), 2704. https://doi.org/10.21105/joss.02704

* Breloff, T., Schwabeneder, D., Borregaard, M. K., Christ, S., Heinen, J., Yuval, Palugniok, A.,Simon, Vertechi, P., Zhanibek, Chamberlin, T., ma-laforge, Rackauckas, C., Schulz,O., Pfitzner, S., Arakaki, T., Yahyaabadi, A., Devine, J., Pech, S., ... Watson, S. S.(2021). JuliaPlots/Plots.Jl: V1.13.2. https://doi.org/10.5281/zenodo.4725318

* Bromberger, S. & Contributors, O. (2017). Juliagraphs/Lightgraphs.Jl: An Optimized Graphs Package for the Julia Programming Language. https://doi.org/10.5281/ZENODO.889971

* Chen, J. & Revels, J. (2016). Robust Benchmarking in Noisy Environments. *arXiv:1608.04295[cs]*.

* Dunning, I., Huchette, J. & Lubin, M. (2017). JuMP: A Modeling Language for Mathematical Optimization. *SIAM Review, 59*(2), 295–320. https://doi.org/10.1137/15M1020575

* Gao, K., Mei, G., Piccialli, F., Cuomo, S., Tu, J. & Huo, Z. (2020). Julia Language in Machine Learning: Algorithms, Applications, and Open Issues. *Computer Science Review, 37*,100254. https://doi.org/10.1016/j.cosrev.2020.100254

* Ge, H., Xu, K. & Ghahramani, Z. (2018). Turing: A Language for Flexible Probabilistic Inference. *International Conference on Artificial Intelligence and Statistics*, 1682–1690.

* Innes, M., Saba, E., Fischer, K., Gandhi, D., Rudilosso, M. C., Joy, N. M., Karmali, T.,Pal, A. & Shah, V. (2018). Fashionable Modelling with Flux. *CoRR,abs/1811.01457*. https://arxiv.org/abs/1811.01457

* Laurie, H. (2021). Julia Programming for Nervous Beginners. https://juliaacademy.com/p/julia-programming-for-nervous-beginner

* Innes, M. (2018). Flux: Elegant Machine Learning with Julia. *Journal of Open Source Software*. https://doi.org/10.21105/joss.00602

* Lauwens, B. & Downey, A. B. (2019). *Think Julia: How to Think Like a Computer Scientist* (1st edition). O’Reilly Media.

* Perkel, J. M. (2019). Julia: Come for the Syntax, Stay for the Speed. *Nature, 572(7767)*, 141–142. https://doi.org/10.1038/d41586-019-02310-3

* Sengupta, A. & Edelman, A. (2019). *Julia High Performance: Optimizations, Distributed Computing, Multithreading, and GPU Programming with Julia 1.0 and beyond*, 2nd Edition. Packt Publishing.

* Storopoli, J. (2021). Bayesian Statistics with Julia and Turing. https://storopoli.io/Bayesian-Julia

* Storopoli, J. & Huijzer, R. (2021).Julia Data Science. https://juliadatascience.io

* TEDx Talks. (2020). A Programming Language to Heal the Planet Together: Julia | AlanEdelman | TEDxMIT.

* The Julia Programming Language. (2019). JuliaCon 2019 | The Unreasonable Effectivenessof Multiple Dispatch | Stefan Karpinski.

* White, J. M., Kamiński, B., powerdistribution, Milan Bouchet-Valat, Garborg, S., Quinn,J., Kornblith, S., cjprybol, Stukalov, A., Bates, D., Short, T., DuBois, C., Harris,H., Squire, K., Arslan, A., pdeffebach, Anthoff, D., Kleinschmidt, D., Noack, A.,... White, L. (2020). JuliaData/DataFrames.Jl: V0.22.1. https://doi.org/10.5281/zenodo.4282946

* Xu, K., Ge, H., Tebbutt, W., Tarek, M., Trapp, M. & Ghahramani, Z. (2020). AdvancedHMC.Jl: A Robust, Modular and Efficient Implementation of Advanced HMC Algorithms. *Symposium on Advances in Approximate Bayesian Inference*, 1–10.

## Licença

Este obra está licenciado com uma Licença [Creative Commons Atribuição-CompartilhaIgual 4.0 Internacional](http://creativecommons.org/licenses/by-sa/4.0/).

[![CC BY-SA 4.0](https://licensebuttons.net/l/by-sa/4.0/88x31.png)](http://creativecommons.org/licenses/by-sa/4.0/)
