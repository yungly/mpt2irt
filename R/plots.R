#' Plot true and estimated parameters.
#'
#' Plot estimates from a single fit using jags and stan (or estimates and true values). Only two object of jags.samp/stan.samp/true.par are allowed.
#' 
#' @param N number of participants
#' @param J number of items
#' @param S number of latent processes to be measured
#' @param model either "2012" or "ext"
# @param number of theta parameters to plot (either 3 or 4)
#' @param jags.samp a fitted mcmc.list from JAGS
#' @param stan.samp a fitted Stan array
#' @param true.par a list with true values for beta and theta
#' @param traitItem if more than a single trait is measured, items measuring different traits are shown in different colors
#' @param revItem if specified, reversed items are shown as different points
#' @import coda
#' @examples
#' \dontrun{
#' # generate data (Boeckenholt, 2012)
#' N <- 40; J <- 30; n.trait <- 3
#' traitItem=rep(1:n.trait, each=J/n.trait)
#' betas <- cbind(runif(J,0,1),
#'               runif(J,0,1),
#'               rnorm(J,0,2))
#'               
#' # analyze and plot
#' gen <- generate_irtree_2012(N=N, J=J, betas=betas, traitItem=traitItem, prop.rev=.5)
#' fit <- fit_irtree(gen$X, gen$revItem, gen$traitItem, fitModel="2012",
#'                  M= 500, n.chains=4, thin=1, fitMethod="jags", format="jags")
#' plot_singlefit(N, J, 2+n.trait, "2012", jags.samp=fit, revItem=gen$revItem,traitItem=gen$traitItem,
#'                true.par=list(theta=gen$theta, betas=gen$betas))
#'                
#' # check with stan
#' fit2 <- fit_irtree(gen$X, gen$revItem, gen$traitItem, fitModel="2012",
#'                   M= 500, n.chains=4, thin=1, fitMethod="stan", format="jags")
#' plot_singlefit(N, J, 2+n.trait, "2012", jags.samp=fit, stan=fit2, 
#'                revItem=gen$revItem,traitItem=gen$traitItem)
#' }
#' @export
plot_singlefit <- function(N, J, S, model, jags.samp, stan.samp, 
                           true.par, traitItem=rep(1,J), revItem=rep(1,J)){
    model <- as.character(model)
    
    if (model == "ext") {
        S.beta <- 4
        parnames <- c("middle", "extremity", "acquies", paste0("trait", 1:(S - 3)))
    } else if (model == "2012") {
        S.beta <- 3
        parnames <- c("middle","extremity", paste0("trait", 1:(S - 2)))
    } else {
        warning("check model name!")
    }
    n.trait <- S - S.beta
    
    ###################### correlation to expected values
    theta.jags <- theta.stan <- matrix(NA, N, S); 
    beta.jags <- beta.stan <- betaSE.jags <- betaSE.stan <- matrix(NA, J, S.beta)
    plotsel <- rep(F, 3)
    
    if (!missing(true.par)) {
        plotsel[1] <- T
        theta.true <- true.par$theta
        beta.true <- true.par$beta 
    }
    
    if (!missing(jags.samp)) {
        plotsel[2] <- T
        for (i in 1:S) {
            theta.jags[, i] <- summary(jags.samp[,paste0("theta[",1:N,",",i,"]")])$stat[,"Mean"]
        }
        for (i in 1:S.beta) {
            beta.jags[, i] <- summary(jags.samp[,paste0("beta[",1:J,",",i,"]")])$stat[,"Mean"]
        }
    }
    
    if (!missing(stan.samp)) {
        plotsel[3] <- T
        for (i in 1:S) {
            theta.stan[,i] <- summary(stan.samp)$summ[paste0("theta[",1:N,",",i,"]"),1]
        }
        for (i in 1:S.beta) {
            beta.stan[,i] <- summary(stan.samp)$summ[paste0("beta[",1:J,",",i,"]"),1]
        }
    }
    if (sum(plotsel) != 2)
        warning("please provide only two objects for plotting")
    
    if (plotsel[1]) {
        x1 <- theta.true; x2 <- beta.true
        xl <- "true"
        if (plotsel[2]) {
            y1 <- theta.jags; y2 <- beta.jags;
            yl <- "JAGS"
        } else {
            y1 <- theta.stan; y2 <- beta.stan;
            yl <- "Stan"
        }
    } else {
            x1 <- theta.jags; x2 <- beta.jags;
            y1 <- theta.stan; y2 <- beta.stan;
            xl <- "JAGS"; yl <- "Stan"
        }
    mfrow <- par()$mfrow
    thetacol <- c(rep(1, S.beta - 1), (1:n.trait) + 1)
    par(mfrow = c(2, S))
    for (i in 1:S) {
        plot(x1[,i],y1[1:N,i], main = paste("Theta",parnames[i]),
             xlab = xl, ylab = yl, col = thetacol[i])
        abline(0,1, pch = 5)
    }
    for (i in 1:S.beta) {
        plot(x2[,i],y2[1:J,i], col = traitItem + 1,
             pch = revItem + 1, main = paste("Beta", parnames[i]), xlab = xl, ylab = yl)
        abline(0,1, pch = 5)
        if (i == 2 & length(unique(revItem)) != 1)
            legend("topleft", c("","rev."), pch = 1:2, col = 1)
        #     if(S.beta==i)
        #         legend("topleft", paste0("trait", 1:(S-S.beta+1)), col=unique(traitItem+1), pch=1)
    }
    par(mfrow = mfrow)
    
    par(mfrow = c(1,1))
    
}


#' Plot item parameters of an mpt2irt model.
#' 
#' This function takes the output from a fitted model and plots the item
#' parameters. More precisely, the probability to pass an item's threshold
#' \eqn{\Phi(0-\beta)} for an average person with \eqn{\theta=0} is depicted as a
#' function of the cognitive process involved (i.e., MRS, ERS, ARS, target
#' trait) and both \code{traitItem} and \code{revItem}.
#' 
#' @param fit a fitted object from \code{\link{fit_irtree}} or preferably from \code{\link{tidyup_irtree_fit}}.
# @param N number of participants
# @param J number of items
# @param revItem a vector with 1=reversed / 0=regular
# @param traitItem a vector specifying the trait of the item (e.g., with values from 1 to 5 for Big5)
# @param trait either "sample" (using the posterior mean estimates for each
#'   person) or a numeric value specifying the trait value used to plot response
#'   styles (e.g., trait=0 for an average person)
#' @param return_data Logical indicating whether the data frame used for
#'   plotting should be returned.
#' @param tt_names Optional character vector with the name(s) of the target
#'   trait(s).
#' @param measure Character vector that indicates whether the mean (default) or
#'   the median of the posterior distribution should be plotted.
#' @param rs_names Character vector. Names of the MPT parameters used for plotting, defaults to something like \code{c("m", "e", "a", "t")}.
#' @inheritParams fit_irtree
#' @inheritParams generate_irtree_ext
#' @import ggplot2
#' @examples 
#' \dontrun{
#' J <- 10
#' betas <- cbind(rnorm(J, .5), rnorm(J, .5), rnorm(J, 1.5), rnorm(J, 0))
#' dat <- generate_irtree_ext(N = 20, J = J, betas = betas, beta_ARS_extreme = .5)
#' 
#' # fit model
#' res1 <- fit_irtree(dat$X, revItem = dat$revItem, M = 200)
#' plot_irtree(res1)
#' }
#' @export
plot_irtree <- function(fit,
                        fitModel = NULL,
                        # S = NULL,
                        # J = NULL,
                        revItem = NULL,
                        traitItem = NULL,
                        # trait = "sample",
                        return_data = FALSE,
                        tt_names = NULL,
                        measure = c("Median", "Mean"),
                        rs_names = NULL
                        # fitMethod = NULL
                        ) {
    measure <- match.arg(measure)
    
    checkmate::qassert(fit, "L+")
    checkmate::assert_character(fitModel, min.chars = 1, any.missing = FALSE,
                                len = 1,
                                null.ok = !is.null(fit$args$fitModel))
    # checkmate::assert_int(S, lower = 1, null.ok = TRUE)
    # checkmate::qassert(J, "X1[1,]")
    # checkmate::assert_int(J, lower = 1, null.ok = !is.null(fit$args$J))
    # checkmate::qassert(revItem, "X+[0,1]")
    checkmate::assert_integerish(revItem, lower = 0, upper = 1, any.missing = FALSE,
                                 min.len = 1, null.ok = !is.null(fit$args$revItem))
    # checkmate::qassert(traitItem, "X+[1,]")
    checkmate::assert_integerish(traitItem, lower = 1, any.missing = FALSE,
                                 min.len = 1, null.ok = !is.null(fit$args$traitItem))
    if (is.null(traitItem)) traitItem <- fit$args$traitItem
    checkmate::assert_character(tt_names, len = length(unique(traitItem)),
                                null.ok = TRUE)
    
    # if (is.null(S)) S <- fit$args$S
    # if (is.null(J)) J <- fit$args$J
    if (is.null(revItem)) revItem <- fit$args$revItem
    # if (is.null(fitMethod)) fitMethod <- fit$args$fitMethod
    if (is.null(fitModel)) fitModel <- fit$args$fitModel
    
    S_b1 <- switch(fitModel,
                   "2012"  = 3,
                   "ext"   = 4,
                   "pcm"   = 4,
                   "steps" = 4,
                   "shift" = 3,
                   "ext2"  = 5,
                   ifelse(length(fit$args$S) > 0, fit$args$S, 4))
    checkmate::assert_character(rs_names, len = S_b1, null.ok = TRUE)
    
    if (is.null(rs_names)) {
        if (S_b1 == 3) {
            rs_names <- c("m", "e", "t")
        } else if (fitModel %in% c("pcm", "steps")) {
            rs_names <- paste("Threshold", 1:4)
        } else if (S_b1 == 4) {
            rs_names <- c("m", "e", "a", "t")
        } else if (S_b1 == 5) {
            rs_names <- c("m", "e", "a", "t", "e*")
        }  
    }
    
    if (!("beta" %in% names(fit))) {
        fit <- summarize_irtree_fit(fit, interact = F)
        fit <- tidyup_irtree_fit(fit)
    }
    dat_0 <- lapply(fit$beta, magrittr::set_colnames, rs_names)
    dat_1 <- reshape2::melt(dat_0) %>% 
        reshape2::dcast(Var1 + Var2 ~ L1)
    dat_1[, 3:6] <- apply(dat_1[, 3:6], 2, function(x) pnorm(-x))
    names(dat_1)[1:2] <- c("Item", "Type")
    
    dat_1$revItem <- factor(rep(revItem, each = S_b1))
    dat_1$traitItem <- factor(rep(traitItem, each = S_b1), levels = 1:max(traitItem))
    if (!is.null(tt_names))
        dat_1$traitItem <- factor(dat_1$traitItem, labels = tt_names)
    
    # if ("beta" %in% names(fit)) {
    #     dat_0 <- lapply(fit$beta, magrittr::set_colnames, rs_names)
    #     dat_1 <- reshape2::melt(dat_0) %>% 
    #         reshape2::dcast(Var1 + Var2 ~ L1)
    #     dat_1[, 3:6] <- apply(dat_1[, 3:6], 2, function(x) pnorm(-x))
    #     names(dat_1)[1:2] <- c("Item", "Type")
    #     # dat_1 <- dat_1[order(dat_1$Item), ]
    #     
    #     dat_1$revItem <- factor(rep(revItem, each = S_b1))
    #     dat_1$traitItem <- factor(rep(traitItem, each = S_b1), levels = 1:max(traitItem))
    #     if (!is.null(tt_names))
    #         dat_1$traitItem <- factor(dat_1$traitItem, labels = tt_names)
    # } else {
    #     fit <- summarize_irtree_fit(fit, interact = F)
    #     fit <- tidyup_irtree_fit(fit)
    #     # if (!any(names(fit) %in% c("args", "V"))) {
    #     #     fit <- list("samples" = fit)
    #     # }
    #     # if (!("summary" %in% names(fit))) {
    #     #     if (!("mcmc" %in% names(fit))) {
    #     #         if (fitMethod == "jags") {
    #     #             fit$mcmc <- fit$samples$mcmc
    #     #         } else {
    #     #             fit$mcmc <- rstan::As.mcmc.list(fit$samples)
    #     #         }
    #     #     }
    #     #     if (class(fit$mcmc) != "mcmc.list") stop("Unable to find or create object of class 'mcmc.list' in 'fit$mcmc'.")
    #     #     # fit$summary <- coda:::summary.mcmc.list(fit$mcmc)
    #     #     fit$summary <- summary(fit$mcmc)
    #     # }
    #     
    #     dat_1 <- merge(data.frame("id" = rownames(fit$summary$statistics), "Mean" = fit$summary$statistics[, "Mean"]),
    #                 cbind("id" = rownames(fit$summary$quantiles), as.data.frame(fit$summary$quantiles)))
    #     
    #     dat_1 <- dat_1[grep("^beta\\[[[:digit:]]+\\,[[:digit:]]]", dat_1$id), ]
    #     names(dat_1)[names(dat_1) %in% c("2.5%", "50%", "97.5%")] <- c("Q_025", "Median", "Q_975")
    #     dat_1[-1] <- apply(dat_1[-1], 2, function(x) pnorm(-x))
    #     dat_1$Type <- sapply(strsplit(as.character(dat_1$id), "[,]"), function(x) as.numeric(substr(x[2], 1, 1)))
    #     dat_1$Type <- factor(dat_1$Type, labels = rs_names)
    #     dat_1$Item <- factor(sapply(sapply(strsplit(as.character(dat_1$id), "\\["),
    #                                     function(x) strsplit(x[2], ",")),
    #                              function(x) as.numeric(x[1])))
    #     dat_1 <- dat_1[order(dat_1$Item), ]
    #     # dat_1$Item <- factor(rep(item_order, each = S_b1))
    #     # if (missing(revItem) | is.null(revItem))
    #     #     revItem <- rep(1,J)
    #     # if (missing(traitItem) | is.null(traitItem))
    #     #     traitItem <- rep(1,J)
    #     dat_1$revItem <- factor(rep(revItem, each = S_b1))
    #     dat_1$traitItem <- factor(rep(traitItem, each = S_b1), levels = 1:max(traitItem))
    #     if (!is.null(tt_names))
    #         dat_1$traitItem <- factor(dat_1$traitItem, labels = tt_names)
    # }
    
    # if(class(fit) != "mcmc.list")
    #     fit <- stan2mcmc.list(fit)
    # dat_1 <- data.frame(Item=rep(NA, S_b1*J), Type=NA, Mean=NA,SD=NA, "Q_025"=NA, "Median"=NA,"Q_975"=NA)
    # for(s in 1:S_b1) {
    #     beta_rs <- runjags::combine.mcmc(fit$mcmc[, paste0("beta[",1:J,",",s,"]")])
    #     M <- nrow(beta_rs)
    #     p.item.rs <- matrix(NA, M, J)
    # 
    #     if (is.null(trait)) {
    #         p.item.rs <- apply(beta_rs, 2, function(x) pnorm(x))
    #     } else if (trait == "sample"){
    #         # sample: f
    #         theta.rs <- colMeans(runjags::combine.mcmc(fit[, paste0("theta[",1:N,",",s,"]")]))
    #         p.item.rs <- apply(beta_rs, 2, function(x) colMeans(pnorm(outer(theta.rs, x,"-"))))
    #         # summary(p.item.rs)
    #     } else if (is.numeric(trait)) {
    #         # average:
    #         p.item.rs <- apply(beta_rs, 2, function(x) pnorm(as.numeric(trait)-x))
    #     }
    # 
    #     dat_1[seq(s,S_b1*J, S_b1), 3:7] <- t(apply(p.item.rs, 2, function(x) c( mean(x), sd(x),quantile(x, c(.025, .5, .975)))))
    #     dat_1[seq(s,S_b1*J, S_b1),1:2] <- cbind( 1:J,  rs_names[s])
    # }
    # dat_1$Type <- factor(dat_1$Type, levels=rs_names)
    # if (missing(revItem) | is.null(revItem))
    #     revItem <- rep(1,J)
    # if (missing(traitItem) |is.null(traitItem))
    #     traitItem <- rep(1,J)
    # dat_1$revItem <- factor(rep(revItem, each=S_b1))
    # dat_1$traitItem <- factor(rep(traitItem, each=S_b1), levels=1:max(traitItem))
    # dat_1$Item <- factor(dat_1$Item, levels=as.character(1:J))
    # if (!is.null(tt_names)) {
    #     dat_1$traitItem <- factor(dat_1$traitItem, labels = tt_names)
    #     try(levels(dat_1$traitItem) <- levels(tt_names), silent = T)
    # }
    
    # library("ggplot2")
    # loadNamespace("ggplot2")
    
    gg <- ggplot(aes_string(x = "Item", y = measure, col = "revItem"), data = dat_1) + 
        # ggplot(aes(x=Item, y=Mean, col=revItem), data=dat_1) + 
        geom_point() +
        theme_bw() +
        # facet_wrap(~ Type + traitItem, nrow = S_b1, scales = "free_x") +
        facet_grid(Type ~ traitItem, scales = "free_x") +
        geom_errorbar(aes_string(ymin = "Q_025", ymax = "Q_975")) + 
        ylim(0, 1) +
        labs(y = expression(Phi(-beta)),
             title = paste0("Estimated Item Parameters (", measure, ", 95% CI)"))
    # plot(gg)
    
    if (return_data == TRUE) {
        return(dat_1)
    } else {
        return(gg)
    }
}

#' Plot Gelman-Rubin statistic.
#'
#' Plot a histogram of the Gelman and Rubin's convergence diagnostic.
#' 
#' @param parameter Character. The group of parameters for which the statistic is
#'   to be calculated. Using the empty vector (\code{""}) uses all parameters in
#'   \code{fit}.
#' @param estimate Character, either \code{"point"} or \code{"upper"}. Whether
#'   the point estimate or the upper limit of the 95\% CI is to be used.
#' @param plot Logical. Either return a histogram or the results.
#' @param return.odd Logical. Whether the output for (odd) parameters with a point
#'   estimate > 1.05 should be returned.
#' @param ... Optional arguments passed to \code{\link[graphics]{hist}}.
#' @inheritParams plot_irtree
#' @seealso \code{\link{gelman.diag}}
# @importFrom coda gelman.diag
#' @export
plot_GRS <- function(fit, parameter = "beta", estimate = "point", plot = TRUE,
                     return.odd = TRUE, ...){
    param <- substr(parameter, 1, 4)
    cols <- grep(param, substr(dimnames(fit[[1]])[[2]], 1, 4))
    n.chains <- length(fit)
    fit.name <- substitute(fit)
    
    fit <- fit[][, cols]
    
    grs <- coda::gelman.diag(fit, multivariate = F)
    if (plot == TRUE) {
        hist(grs$psrf[, ifelse(estimate == "point", 1, 2)],
             main = paste0("Gelman-Rubin Statistic for ", parameter, " Parameters"),
             xlab = "", ...)
        grs.l <- c(1.05, 1.1, 1.2)
        grs.p <- numeric(3)
        for (ii in 1:3) {
            grs.p[ii] <- sum(grs$psrf[, ifelse(estimate == "point", 1, 2)] >= grs.l[ii]) /
                ncol(fit[[1]])
        }
        legend("topright", legend = paste0("Prop. >= ", format(grs.l, digits = 3), ": ", round(grs.p, 2)),
               bty = "n")
        if (return.odd == TRUE) {
            grs2 <- grs
            grs2$psrf <- grs$psrf[grs$psrf[, ifelse(estimate == "point", 1, 2)] >= 1.05, ]
            return(grs2)
        }
    } else {
        return(grs)
    }
}


#' Plot Geweke statistic.
#'
#' Plot a histogram of the Geweke convergence diagnostic.
#' 
#' @param parameter Character. The group of parameters for which the stistic is
#'   to be calculated. Using the empty vector (\code{""}) uses all parameters in
#'   \code{fit}.
#' @param D Numeric. If the plot should be grouped according to different types
#'   of parameters, \code{D} should be equal to the number of different types of
#'   processes (e.g., \code{D = 4}) for a 1/2/3/ect-dimensional "ext" model or
#'   \code{D=3} for a 1/2/ect-dimensional "Boeckenholt2012" model)
#' @param plot Logical. Either return a histogram or the results.
#' @param ... Optional arguments passed to \code{\link[graphics]{hist}}.
#' @inheritParams plot_irtree
#' @inheritParams coda::geweke.diag
#' @seealso \code{\link{geweke.diag}}
# @importFrom coda geweke.diag
#' @export
plot_Geweke <- function(fit, parameter = "beta", D = 1, frac1=0.1, frac2=0.5,
                        plot = TRUE, ...){
    param <- substr(parameter, 1, 4)
    cols <- grep(param, substr(dimnames(fit[[1]])[[2]], 1, 4))
    J <- length(cols) / D
    n.chains <- length(fit)
    
    fit <- fit[][, cols]
    
    gew <- coda::geweke.diag(fit, frac1 = frac1, frac2 = frac2)
    if (plot == TRUE) {
        # col.1 <- rainbow(n.chains, alpha = .25)
        col.1 <- heat.colors(n.chains, alpha = .25)
        
        # First, two loops with plot=FALSE are done in order to calculate the break
        # points and the heigth/ylim for the histograms
        plot.1 <- sapply(vector(length = n.chains*D), function(x) NULL)
        kk <- 1
        for (ii in 1:n.chains) {
            for (jj in 1:D) {
                plot.1[[kk]] <- hist(gew[[ii]][[1]][(J*(jj - 1)):(J*jj)], plot = F)
                kk <- kk + 1
            }
        }
        breaks.1 <- min(unlist(lapply(plot.1, "[[", "breaks")))
        breaks.2 <- max(unlist(lapply(plot.1, "[[", "breaks")))
        kk <- 1
        for (ii in 1:n.chains) {
            for (jj in 1:D) {
                plot.1[[kk]] <- hist(gew[[ii]][[1]][(J*(jj - 1)):(J*jj)], 
                                     breaks = seq(breaks.1, breaks.2, 0.5), plot = F)
                kk <- kk + 1
            }
        }
        y.max <- max(unlist(lapply(plot.1, "[[", "counts")))
        
        par(mfrow = c(ceiling(sqrt(D)), round(sqrt(D))))
        for (jj in 1:D) {
            hist(gew[[1]][[1]][(J*(jj - 1)):(J*jj)], breaks = seq(breaks.1, breaks.2, 0.5),
                 ylim = c(0, y.max), col = col.1[1],
                 main = paste0("Geweke Statistic: ", parameter, ifelse(D > 1, jj, "")),
                 xlab = "", ...)
            for (ii in 2:n.chains) {
                hist(gew[[ii]][[1]][(J*(jj - 1)):(J*jj)], breaks = seq(breaks.1, breaks.2, 0.5),
                     ylim = c(0, y.max), col = col.1[ii], add = TRUE)
            }
            prop.1 <- unlist(lapply(lapply(
                lapply(gew, "[[", "z"), "[", (J*(jj - 1)):(J*jj)
                ), function(x) sum(abs(x) > qnorm(.975))))/J
            legend("topleft", legend = round(prop.1, 2), col = col.1,
                   title = "Proportion > +/- 1.96", pch = 15, bty = "n",
                   y.intersp = .8, cex = 1/D^.1)
        }
    } else {
        return(gew)
    }
}  
