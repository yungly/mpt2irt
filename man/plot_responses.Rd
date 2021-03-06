% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plots2.R
\name{plot_responses}
\alias{plot_responses}
\title{Plot observed frequencies.}
\usage{
plot_responses(X, revItem = rep(0, ncol(X)), traitItem = rep(1, ncol(X)),
  points = 5, ...)
}
\arguments{
\item{X}{an N x J matrix of observed responses for categories 1...5 (use
\code{\link{mult_to_cat}} to transform a multinomial frequency matrix with 1s/0s to
responses from 1...5)}

\item{revItem}{vector of length J specifying reversed items (1=reversed,
0=regular)}

\item{traitItem}{vector of length J specifying the underlying traits (e.g.,
indexed from 1...5). Standard: only a single trait is measured by all
items. If the Big5 are measured, might be something like
c(1,1,1,2,2,2,...,5,5,5,5)}

\item{points}{how many resposne categories in Likert scale}

\item{...}{Additional arguments passed to \code{\link[graphics]{barplot}}.}
}
\description{
Plot histograms of observed response frequencies separately for each item.
This is especially helpful to judge whether simulated data are reasonable
(i.e., unimodal etc.).
}
\examples{
N <- 20
J <- 10
betas <- cbind(rnorm(J, .5), rnorm(J, .5), rnorm(J, 1.5), rnorm(J, 0))
dat <- generate_irtree_ext(N = N, J = J, betas = betas, beta_ARS_extreme = .5)
plot_responses(dat$X, revItem = dat$revItem, traitItem = dat$traitItem)
}
