Minimum requirements:
  Multicore CPU, parallel BLAS/LAPACK (e.g. OpenBLAS on Ubuntu 26.04.1 LTS)
  32GB main memory, 512GB swap (SSD)
Conservative settings for GC within R (4.6.1):
  # ~/.Renviron
  R_GC_MEM_GROW=0
  # EOF
Convergence failures: Rural, Océanique altéré, Female, 20-39, 2005-2014 and 2015-2024
  mgcv::gam() instead of mgcv:bam() in Process.Rmd for the initial values/importance sample for the sensitivity model (SC)
  SC <- gam(fSC, nb(), di, knots = kf, chunk = 16384, gc = 2)
