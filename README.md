
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/hplieninger/mpt2irt.svg?branch=master)](https://travis-ci.org/hplieninger/mpt2irt)

Overview
========

`mpt2irt` is an `R` package that accompanies a manuscript submitted for publication. Therein, we extend the response style model of Böckenholt (2012) to acquiescence. The model is essentially a hierarchical multinomial processing tree (MPT) model with an item response theory (IRT) structure of its parameters. To estimate the model parameters, we build on Bayesian hierarchical modeling and fit the model in either Stan or JAGS.

Installation
============

The package can be installed directly from GitHub usings the `devtools` package.

``` r
install.packages("devtools")
devtools::install_github("hplieninger/mpt2irt")
```

In order to use the package, you will need either JAGS or Stan. To install Stan, visit [https://github.com/stan-dev](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started) or <http://mc-stan.org>, to install JAGS, visit <https://sourceforge.net/projects/mcmc-jags>.

Usage
=====

``` r
# This is a minimal working example, where data are generated and subsequently fit.
library("mpt2irt")
N <- 20
J <- 10
betas <- cbind(rnorm(J, .5), rnorm(J, .5), rnorm(J, 1.5), rnorm(J, 0))
dat   <- generate_irtree_ext(N = N, J = J, betas = betas, beta_ARS_extreme = .5)

# fit model
res1 <- fit_irtree(dat$X, revItem = dat$revItem, M = 200)
res2 <- summarize_irtree_fit(res1)
res3 <- tidyup_irtree_fit(res2)
res3$plot
```

Misc
====

The proposed Acquiescence Model is a mixture model. Existing approaches to ARS (e.g., Billiet & McClendon, 2000; Ferrando et al., 2016; Maydeu-Olivares & Coffman, 2006) view acquiescence as a shift process. A graphical comparison of the two approaches in terms of the predicted category probabilities may be found at <https://hplieninger.shinyapps.io/shift-vs-mixture-ARS>.
