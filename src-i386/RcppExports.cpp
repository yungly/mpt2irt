// Generated by using Rcpp::compileAttributes() -> do not edit by hand
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <RcppEigen.h>
#include <Rcpp.h>

using namespace Rcpp;

// sample_pp
NumericVector sample_pp(NumericMatrix prob);
RcppExport SEXP _mpt2irt_sample_pp(SEXP probSEXP) {
BEGIN_RCPP
    Rcpp::RObject rcpp_result_gen;
    Rcpp::RNGScope rcpp_rngScope_gen;
    Rcpp::traits::input_parameter< NumericMatrix >::type prob(probSEXP);
    rcpp_result_gen = Rcpp::wrap(sample_pp(prob));
    return rcpp_result_gen;
END_RCPP
}

RcppExport SEXP _rcpp_module_boot_stan_fit4stan_boeck_2012_mod();
RcppExport SEXP _rcpp_module_boot_stan_fit4stan_boeck_ext2_mod();
RcppExport SEXP _rcpp_module_boot_stan_fit4stan_boeck_ext_mod();
RcppExport SEXP _rcpp_module_boot_stan_fit4stan_boeck_ext_HH_mod();
RcppExport SEXP _rcpp_module_boot_stan_fit4stan_boeck_shift_mod();
RcppExport SEXP _rcpp_module_boot_stan_fit4stan_pcm_mod();
RcppExport SEXP _rcpp_module_boot_stan_fit4stan_steps_mod();

static const R_CallMethodDef CallEntries[] = {
    {"_mpt2irt_sample_pp", (DL_FUNC) &_mpt2irt_sample_pp, 1},
    {"_rcpp_module_boot_stan_fit4stan_boeck_2012_mod", (DL_FUNC) &_rcpp_module_boot_stan_fit4stan_boeck_2012_mod, 0},
    {"_rcpp_module_boot_stan_fit4stan_boeck_ext2_mod", (DL_FUNC) &_rcpp_module_boot_stan_fit4stan_boeck_ext2_mod, 0},
    {"_rcpp_module_boot_stan_fit4stan_boeck_ext_mod", (DL_FUNC) &_rcpp_module_boot_stan_fit4stan_boeck_ext_mod, 0},
    {"_rcpp_module_boot_stan_fit4stan_boeck_ext_HH_mod", (DL_FUNC) &_rcpp_module_boot_stan_fit4stan_boeck_ext_HH_mod, 0},
    {"_rcpp_module_boot_stan_fit4stan_boeck_shift_mod", (DL_FUNC) &_rcpp_module_boot_stan_fit4stan_boeck_shift_mod, 0},
    {"_rcpp_module_boot_stan_fit4stan_pcm_mod", (DL_FUNC) &_rcpp_module_boot_stan_fit4stan_pcm_mod, 0},
    {"_rcpp_module_boot_stan_fit4stan_steps_mod", (DL_FUNC) &_rcpp_module_boot_stan_fit4stan_steps_mod, 0},
    {NULL, NULL, 0}
};

RcppExport void R_init_mpt2irt(DllInfo *dll) {
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
