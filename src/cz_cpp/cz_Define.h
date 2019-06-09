#ifndef _CZ_DEFINE_H_
#define _CZ_DEFINE_H_

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

/**
 * @file   cz_Define.h
 * @brief  CubeZ Definition Header
 */

#include <CB_Define.h>

#ifdef DISABLE_MPI
  typedef int MPI_Op;
  typedef int MPI_Comm;
  typedef int MPI_Request;
  typedef int MPI_Datatype;

  #define MPI_COMM_WORLD 0
  #define MPI_INT  1
  #define MPI_CHAR 2
  #define MPI_SUCCESS true
  #define MPI_MAX 100
  #define MPI_MIN 101
  #define MPI_SUM (MPI_Op)(0x58000003) // defined in PMlib

  inline int MPI_Allreduce(void *sendbuf, void *recvbuf, int count,
                  MPI_Datatype datatype, MPI_Op op, MPI_Comm comm)
  {
    return 0;
  }

#endif

#define GUIDE 2  ///< ガイドセル数

#define DETAIL      2

#ifdef _OPENMP
#include <omp.h>
#endif

#include <float.h>

#ifdef _REAL_IS_DOUBLE_
#define REAL_TYPE_EPSILON DBL_MIN
#else
#define REAL_TYPE_EPSILON FLT_MIN
#endif


// PCRのアクセス
#define _IDX_(_I,_SS)  ( _I+_SS ) // SSは最大ストライド幅


// PMlibの登録ラベル個数
#define PM_NUM_MAX 200

// ラベルの最大文字数
#define TM_LABEL_MAX 24


enum LinearSolver
{
  LS_PSOR=1,
  LS_SOR2SMA,
  LS_BICGSTAB,
  LS_JACOBI,
  LS_LSOR,
  LS_LSOR_P1,
  LS_LSOR_P2,
  LS_LSOR_P3,
  LS_LSOR_P4,
  LS_LSOR_P5,
  LS_LSOR_P6,
  LS_LSOR_P7
};


#endif // _CZ_DEFINE_H_
