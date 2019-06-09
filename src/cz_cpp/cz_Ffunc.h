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

void bc_k_    (int* sz,
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

void tdma_0_ (int* nx,
              REAL_TYPE* d,
              REAL_TYPE* a,
              REAL_TYPE* b,
              REAL_TYPE* c,
              REAL_TYPE* w);

void tdma_1_ (int* nx,
              REAL_TYPE* d,
              REAL_TYPE* cf,
              REAL_TYPE* w,
              double* flop);

  void tdma_p_(int* nx,
               REAL_TYPE* d,
               REAL_TYPE* a,
               REAL_TYPE* c,
               REAL_TYPE* w);
  
  void tdma_mp_(int* nx,
                int* mp,
                REAL_TYPE* d,
                REAL_TYPE* a,
                REAL_TYPE* c,
                REAL_TYPE* w);
  
// cz_losr.f90
void lsor_pcr_kij_(int* sz,
                   int* idx,
                   int* g,
                   int* pn,
                   REAL_TYPE* x,
                   REAL_TYPE* a,
                   REAL_TYPE* c,
                   REAL_TYPE* d,
                   REAL_TYPE* a1,
                   REAL_TYPE* c1,
                   REAL_TYPE* d1,
                   REAL_TYPE* msk,
                   REAL_TYPE* rhs,
                   REAL_TYPE* omg,
                   double* res,
                   double* flop);
  
  void lsor_pcr_kij_1d_(int* sz,
                     int* idx,
                     int* g,
                     int* pn,
                     REAL_TYPE* x,
                     REAL_TYPE* a,
                     REAL_TYPE* c,
                     REAL_TYPE* d,
                     REAL_TYPE* a1,
                     REAL_TYPE* c1,
                     REAL_TYPE* d1,
                     REAL_TYPE* msk,
                     REAL_TYPE* rhs,
                     REAL_TYPE* omg,
                     double* res,
                     double* flop);
  
void lsor_pcr_kij2_(int* sz,
                    int* idx,
                    int* g,
                    int* pn,
                    REAL_TYPE* x,
                    REAL_TYPE* a,
                    REAL_TYPE* c,
                    REAL_TYPE* d,
                    REAL_TYPE* a1,
                    REAL_TYPE* c1,
                    REAL_TYPE* d1,
                    REAL_TYPE* msk,
                    REAL_TYPE* rhs,
                    REAL_TYPE* omg,
                    double* res,
                    double* flop);
  
void lsor_pcr_kij3_(int* sz,
                    int* idx,
                    int* g,
                    int* pn,
                    REAL_TYPE* x,
                    REAL_TYPE* a,
                    REAL_TYPE* c,
                    REAL_TYPE* d,
                    REAL_TYPE* a1,
                    REAL_TYPE* c1,
                    REAL_TYPE* d1,
                    REAL_TYPE* msk,
                    REAL_TYPE* rhs,
                    REAL_TYPE* omg,
                    double* res,
                    double* flop);
  
void lsor_pcr_kij4_(int* sz,
                    int* idx,
                    int* g,
                    int* pn,
                    REAL_TYPE* x,
                    REAL_TYPE* a,
                    REAL_TYPE* c,
                    REAL_TYPE* d,
                    REAL_TYPE* a1,
                    REAL_TYPE* c1,
                    REAL_TYPE* d1,
                    REAL_TYPE* msk,
                    REAL_TYPE* rhs,
                    REAL_TYPE* omg,
                    double* res,
                    double* flop);
  
void lsor_pcr_kij5_(int* sz,
                    int* idx,
                    int* g,
                    int* pn,
                    REAL_TYPE* x,
                    REAL_TYPE* msk,
                    REAL_TYPE* rhs,
                    REAL_TYPE* omg,
                    double* res,
                    double* flop);
  
void lsor_pcr_kij6_(int* sz,
                    int* idx,
                    int* g,
                    int* pn,
                    REAL_TYPE* x,
                    REAL_TYPE* msk,
                    REAL_TYPE* rhs,
                    REAL_TYPE* omg,
                    double* res,
                    double* flop);
  
void lsor_pcr_kij7_(int* sz,
                    int* idx,
                    int* g,
                    int* pn,
                    int* ofst,
                    int* color,
                    REAL_TYPE* x,
                    REAL_TYPE* msk,
                    REAL_TYPE* rhs,
                    REAL_TYPE* omg,
                    double* res,
                    double* flop);
  
void lsor_pcr_q_(int* sz,
                 int* idx,
                 int* g,
                 int* s,
                 int* i,
                 int* j,
                 REAL_TYPE* a,
                 REAL_TYPE* c,
                 REAL_TYPE* d,
                 REAL_TYPE* a1,
                 REAL_TYPE* c1,
                 REAL_TYPE* d1,
                 double* flop);


// cz_blas.f90

void imask_k_       (REAL_TYPE* x,
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
  
  
void blas_copy_in_   (REAL_TYPE* dst,
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

void fileout_t_ (int* sz,
               int* g,
               REAL_TYPE* s,
               REAL_TYPE* dh,
               REAL_TYPE* org,
               char* fname);

void exact_t_ (int* sz,
               int* g,
               REAL_TYPE* e,
               REAL_TYPE* dh,
               REAL_TYPE* org);

void err_t_   (int* sz,
               int* idx,
               int* g,
               double* d,
               REAL_TYPE* p,
               REAL_TYPE* e,
               int* loc);
}



#endif // _CZ_F_FUNC_H_
