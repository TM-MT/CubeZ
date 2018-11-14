/*
###################################################################################
#
# CubeZ
#
# Copyright (C) 2018 Research Institute for Information Technology(RIIT), Kyushu University.
# All rights reserved.
#
###################################################################################
*/

#ifndef _CZ_F_FUNC_H_
#define _CZ_F_FUNC_H_


extern "C" {

// cz_lsolver.f90
void bc_      (int* sz,
               int* g,
               REAL_TYPE* e,
               REAL_TYPE* dh,
               REAL_TYPE* org,
               int* nID);

void jacobi_        (REAL_TYPE* p,
                     int* sz,
                     int* idx,
                     int* g,
                     REAL_TYPE* cf,
                     REAL_TYPE* omg,
                     REAL_TYPE* b,
                     double* res,
                     REAL_TYPE* wk2,
                     double* flop);

void psor_          (REAL_TYPE* p,
                     int* sz,
                     int* idx,
                     int* g,
                     REAL_TYPE* cf,
                     REAL_TYPE* omg,
                     REAL_TYPE* b,
                     double* res,
                     double* flop);

void psor2sma_core_ (REAL_TYPE* p,
                     int* sz,
                     int* idx,
                     int* g,
                     REAL_TYPE* cf,
                     int* ip,
                     int* color,
                     REAL_TYPE* omg,
                     REAL_TYPE* b,
                     double* res,
                     double* flop);

void src_dirichlet_ (REAL_TYPE* b,
                     int* sz,
                     int* g,
                     REAL_TYPE* dh,
                     int* nID);




// cz_blas.f90
void init_mask_     (REAL_TYPE* x,
                     int* sz,
                     int* idx,
                     int* g);

void blas_clear_    (REAL_TYPE* x,
                     int* sz,
                     int* g);

void blas_copy_     (REAL_TYPE* dst,
                     REAL_TYPE* src,
                     int* sz,
                     int* g);

void blas_triad_    (REAL_TYPE* z,
                     REAL_TYPE* x,
                     REAL_TYPE* y,
                     double* a,
                     int* sz,
                     int* idx,
                     int* g,
                     double* flop);

void blas_dot1_     (double* r,
                     REAL_TYPE* p,
                     int* sz,
                     int* idx,
                     int* g,
                     double* flop);

void blas_dot2_     (double* r,
                     REAL_TYPE* p,
                     REAL_TYPE* q,
                     int* sz,
                     int* idx,
                     int* g,
                     double* flop);

void blas_bicg_1_ (REAL_TYPE* p,
                   REAL_TYPE* r,
                   REAL_TYPE* q,
                   double* beta,
                   double* omg,
                   int* sz,
                   int* idx,
                   int* g,
                   double* flop);

void blas_bicg_2_   (REAL_TYPE* z,
                     REAL_TYPE* x,
                     REAL_TYPE* y,
                     double* a,
                     double* b,
                     int* sz,
                     int* idx,
                     int* g,
                     double* flop);

void blas_calc_ax_  (REAL_TYPE* ap,
                     REAL_TYPE* p,
                     int* sz,
                     int* idx,
                     int* g,
                     REAL_TYPE* cf,
                     double* flop);

void blas_calc_rk_  (REAL_TYPE* r,
                     REAL_TYPE* p,
                     REAL_TYPE* b,
                     int* sz,
                     int* idx,
                     int* g,
                     REAL_TYPE* cf,
                     double* flop);

void blas_calc_r2_  (double* res,
                     REAL_TYPE* p,
                     REAL_TYPE* b,
                     int* sz,
                     int* idx,
                     int* g,
                     REAL_TYPE* cf,
                     double* flop);

// utility.f90
void fileout_ (int* sz,
               int* g,
               REAL_TYPE* s,
               REAL_TYPE* dh,
               REAL_TYPE* org,
               char* fname);

void exact_   (int* sz,
               int* g,
               REAL_TYPE* e,
               REAL_TYPE* dh,
               REAL_TYPE* org);

void err_     (int* sz,
               int* idx,
               int* g,
               double* d,
               REAL_TYPE* p,
               REAL_TYPE* e);
}



#endif // _CZ_F_FUNC_H_
