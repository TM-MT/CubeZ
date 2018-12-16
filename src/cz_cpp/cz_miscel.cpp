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

#include "cz.h"
#include "czVersion.h"


// #################################################################
/* @brief 計算する内点のインデクス範囲と点数
 * @retval 計算点数
 */
double CZ::range_inner_index()
{
  int ist, jst, kst, ied, jed, ked;

  ist = 2;
  jst = 2;
  kst = 2;
  ied = size[0];
  jed = size[1];
  ked = size[2];

  if (nID[I_plus] < 0)  ied = size[0] - 1;
  if (nID[J_plus] < 0)  jed = size[1] - 1;
  if (nID[K_plus] < 0)  ked = size[2] - 1;

  innerFidx[I_minus] = ist;
  innerFidx[I_plus]  = ied;
  innerFidx[J_minus] = jst;
  innerFidx[J_plus]  = jed;
  innerFidx[K_minus] = kst;
  innerFidx[K_plus]  = ked;

  double sum = 0.0;
  sum = (double)(ied-ist+1)
      * (double)(jed-jst+1)
      * (double)(ked-kst+1);
/*
  printf("[%d] :%3d %3d %3d %3d %3d %3d : %3d %3d %3d\n",
    myRank, ist, ied, jst, jed, kst, ked,
    size[0], size[1], size[2]);
*/
  return sum;
}

// #################################################################
/* @brief メモリ消費情報を表示
 * @param [in]     fp    ファイルポインタ
 * @param [in]     G_mem グローバルメモリサイズ
 * @param [in]     L_mem ローカルメモリサイズ
 * @param [in]     str   表示用文字列
 */
bool CZ::displayMemoryInfo(FILE* fp, double& G_mem, double L_mem, const char* str)
{
  if ( !Comm_SUM_1(&G_mem) ) return false;

  Hostonly_
  {
    MemoryRequirement(str, G_mem, L_mem, fp);
    fprintf(fp, "\n\n");
  }

  return true;
}


// #################################################################
// メモリ使用量を表示する
void CZ::MemoryRequirement(const char* mode, const double Memory, const double l_memory, FILE* fp)
{
  const double mem = Memory;
  const double lmem= l_memory;
  const double KB = 1024.0;
  const double MB = 1024.0*KB;
  const double GB = 1024.0*MB;
  const double TB = 1024.0*GB;
  const double PB = 1024.0*TB;
  const double factor = 1.05; // estimate 5% for addtional

  fprintf (fp,"\t>> Memory required for %s : ", mode);

  // Global memory
  fprintf (fp," Global=");
  if ( mem > PB ) {
    fprintf (fp,"%6.2f (PB)", mem / PB *factor);
  }
  else if ( mem > TB ) {
    fprintf (fp,"%6.2f (TB)", mem / TB *factor);
  }
  else if ( mem > GB ) {
    fprintf (fp,"%6.2f (GB)", mem / GB *factor);
  }
  else if ( mem > MB ) {
    fprintf (fp,"%6.2f (MB)", mem / MB *factor);
  }
  else if ( mem > KB ) {
    fprintf (fp,"%6.2f (KB)", mem / KB *factor);
  }
  else if ( mem <= KB ){
    fprintf (fp,"%6.2f (B)", mem *factor);
  }
  else {
    fprintf (fp,"Caution! Memory required : %d (Byte)", (int)(mem *factor) );
  }

  // Local memory
  fprintf (fp," : Local=");
  if ( lmem > PB ) {
    fprintf (fp,"%6.2f (PB)\n", lmem / PB *factor);
  }
  else if ( lmem > TB ) {
    fprintf (fp,"%6.2f (TB)\n", lmem / TB *factor);
  }
  else if ( lmem > GB ) {
    fprintf (fp,"%6.2f (GB)\n", lmem / GB *factor);
  }
  else if ( lmem > MB ) {
    fprintf (fp,"%6.2f (MB)\n", lmem / MB *factor);
  }
  else if ( lmem > KB ) {
    fprintf (fp,"%6.2f (KB)\n", lmem / KB *factor);
  }
  else if ( lmem <= KB ){
    fprintf (fp,"%6.2f (B)\n", lmem *factor);
  }
  else {
    fprintf (fp,"Caution! Memory required : %d (Byte)\n", (int)(lmem *factor) );
  }

  fflush(fp);
}


// #################################################################
/**
 * @brief タイミング測定区間にラベルを与えるラッパー
 * @param [in] label     ラベル
 * @param [in] type      測定対象タイプ(COMM or CALC)
 * @param [in] exclusive 排他測定フラグ(ディフォルトtrue)
 */
void CZ::set_label(const string label, pm_lib::PerfMonitor::Type type, bool exclusive)
{
  // 登録個数のチェック
  order_of_PM_key++;

  if ( order_of_PM_key > PM_NUM_MAX )
  {
    printf("\tThe number of labels for Performance monitor goes over limit.\n");
    exit(0);
  }

  // 文字数がTM_LABEL_MAX-1を超えるものはカット
  if ( strlen(label.c_str()) > TM_LABEL_MAX-1 )
  {
    printf("\tWarning: Length of timing label must be less than %d\n", TM_LABEL_MAX-1);
  }

  // Performance Monitorへの登録
  PM.setProperties(label, type, exclusive);
}


// #################################################################
/**
 * @brief タイミング測定区間にラベルを与える
 */
void CZ::set_timing_label()
{
using namespace pm_lib;

  set_label("Comm_RHS",            PerfMonitor::COMM);

  set_label("Dot1"   ,             PerfMonitor::CALC);
  set_label("Dot2"   ,             PerfMonitor::CALC);
  set_label("A_R_Dot",             PerfMonitor::COMM);
  set_label("Blas_Copy",           PerfMonitor::CALC);
  set_label("Blas_Clear",          PerfMonitor::CALC);
  set_label("Blas_Residual",       PerfMonitor::CALC);
  set_label("Blas_BiCG_1",         PerfMonitor::CALC);
  set_label("Blas_BiCG_2",         PerfMonitor::CALC);
  set_label("Blas_AX",             PerfMonitor::CALC);
  set_label("Blas_TRIAD",          PerfMonitor::CALC);

  set_label("JACOBI_kernel",    PerfMonitor::CALC, true);
  set_label("SOR_kernel",       PerfMonitor::CALC, true);
  set_label("SOR2SMA_kernel",   PerfMonitor::CALC, true);
  set_label("LSOR2SMA_kernel",  PerfMonitor::CALC, true);
  set_label("LSOR_MS_kernel",   PerfMonitor::CALC, true);
  set_label("TDMA_kernel",      PerfMonitor::CALC, true);
  set_label("TDMA_readback",    PerfMonitor::CALC, true);
  set_label("TDMA_trsps",       PerfMonitor::CALC, true);
  set_label("LSOR_kernel",      PerfMonitor::CALC, true);
  set_label("LJCB_MS_kernel",   PerfMonitor::CALC, true);
  set_label("LJCB_f0_kernel",   PerfMonitor::CALC, true);
  set_label("LJCB_f1_kernel",   PerfMonitor::CALC, true);
  set_label("LJCB_f2_kernel",   PerfMonitor::CALC, true);
  set_label("LJCB_f3_kernel",   PerfMonitor::CALC, true);
  set_label("LJCB_f4_kernel",   PerfMonitor::CALC, true);

  set_label("Comm_Poisson",     PerfMonitor::COMM);
  set_label("Comm_Res_Poisson", PerfMonitor::COMM);

  set_label("BoundaryCondition",PerfMonitor::CALC);


  // 非排他, 計算
  set_label("JACOBI",           PerfMonitor::CALC, false);
  set_label("PSOR",             PerfMonitor::CALC, false);
  set_label("SOR2SMA",          PerfMonitor::CALC, false);
  set_label("PBiCGSTAB",        PerfMonitor::CALC, false);
  set_label("LSOR",             PerfMonitor::CALC, false);
  set_label("LSOR_MS",          PerfMonitor::CALC, false);
  set_label("LSOR_MSB",         PerfMonitor::CALC, false);
  set_label("LSOR_MSC",         PerfMonitor::CALC, false);
  set_label("LJCB_MSD",         PerfMonitor::CALC, false);
  set_label("LJCB_MSE",         PerfMonitor::CALC, false);
  set_label("LJCB_MSF",         PerfMonitor::CALC, false);
}
