!###################################################################################
!#
!# CubeZ
!#
!# Copyright (C) 2018 Research Institute for Information Technology(RIIT), Kyushu University.
!# All rights reserved.
!#
!###################################################################################


!> ********************************************************************
!! @brief TDMA
!! @param [in]     nx   配列長
!! @param [in]     g    ガイドセル長
!! @param [in,out] d    RHS vector -> 解ベクトル (in-place)
!! @param [in]     cf   係数
!! @param [in]     w    U_1 vector
!! @param [in,out] flop flop count
!! @note resDのFalse sharering回避
!<
subroutine lsor_inner_c (d, sz, idx, g, d2, x, a, e, w, msk, rhs, omg, &
                         clsz, nt, itri, rd, flop)
!$ use omp_lib
implicit none
integer                                                ::  i, j, k, g, clsz, l, nt, itri
integer                                                ::  ist, ied, kst, ked, jst, jed, id
integer, dimension(3)                                  ::  sz
integer, dimension(0:5)                                ::  idx
double precision                                       ::  flop
double precision, dimension(clsz, nt)                  ::  rd
real, dimension(1-g:sz(1)+g, 1-g:sz(3)+g, 1-g:sz(2)+g) ::  d, d2, x, msk, rhs
real, dimension(1-g:sz(3)+g)                           ::  a, e, w
real                                                   ::  omg, r
real                                                   ::  dp, pp
!dir$ assume_aligned d:64, a:64, e:64, w:64, d2:64, x:64, msk:64, rhs:64, rd:64

ist = idx(0)
ied = idx(1)
jst = idx(2)
jed = idx(3)
kst = idx(4)
ked = idx(5)

r = 1.0/6.0

flop = flop + dble(jed-jst+1) * ( &
       dble((ied-ist+1)*(ked-kst+1))*3.0 &
     + dble(itri)* ( &
       dble((ied-ist+1)*(ked-kst+1))*(4.0+6.0) &
      +dble(ied-ist+1)*(3.0+3.0) &
      +dble((ied-ist+1)*(ked-2))*(3.0+2.0) ) )

!$OMP PARALLEL DO SCHEDULE(dynamic,1) private(dp,pp,id) reduction(+:rd)
do j=jst, jed
  id = omp_get_thread_num() + 1

  ! Source term I for AX=b

  !dir$ unroll(4)
  do k = kst, ked
    !dir$ vector aligned
    !dir$ simd
    do i = ist, ied
      d2(i, k, j) = ( x(i, k, j-1) &
                  +   x(i, k, j+1) ) * r + rhs(i, k, j)
    end do
  end do


  ! Inner Iteration
  do l=1, itri

    ! Source term II for AX=b

    !dir$ unroll(4)
    do k = kst, ked
      !dir$ vector aligned
      !dir$ simd
      do i = ist, ied
        d(i, k  , j) = (d2(i  , k  , j) &
                     + ( x(i-1, k  , j) &
                     +   x(i+1, k  , j) ) * r ) &
                     * msk(i  , k  , j)
      end do
    end do


    ! BC

    !dir$ vector aligned
    !dir$ simd
    do i=ist, ied
      d(i, kst, j) = ( d(i, kst  , j) &
                   + rhs(i, kst-1, j) * r ) &
                   * msk(i, kst  , j)
    end do


    !dir$ vector aligned
    !dir$ simd
    do i=ist, ied
      d(i, ked, j) = ( d(i, ked  , j) &
                   + rhs(i, ked+1, j) * r ) &
                   * msk(i, ked  , j)
    end do

    ! Forward

    !dir$ unroll(4)
    do k = 3, ked
      !dir$ vector aligned
      !dir$ simd
      do i=ist, ied
        d(i, k  , j) = (d(i, k  , j) - a(k  ) * d(i, k-1, j)) * e(k  )
      end do
    end do


    ! Backwad

    !dir$ unroll(4)
    do k=ked-1, 2 , -1
      !dir$ vector aligned
      !dir$ simd
      do i=ist, ied
        d(i, k  , j) = d(i, k  , j) - w(k  ) * d(i, k+1, j)
      end do
    end do


    ! Relax

    !dir$ unroll(4)
    do k = kst, ked
      !dir$ vector aligned
      !dir$ simd
      do i = ist, ied
        pp =   x(i, k  , j)
        dp = ( d(i, k  , j) - pp ) * omg * msk(i, k  , j)
        x(i, k, j) = pp + dp
        rd(l,id) = rd(l,id) + dp * dp
      end do
    end do

  end do ! ItrInner
end do ! j-loop

!do l=1,itri
!  do i=1,nt
!    write(*,*) l, i, rd(l,i)
!  end do
!end do

return
end subroutine lsor_inner_c

!> ********************************************************************
!! @brief TDMA
!! @param [in]     nx   配列長
!! @param [in]     g    ガイドセル長
!! @param [in,out] d    RHS vector -> 解ベクトル (in-place)
!! @param [in]     cf   係数
!! @param [in]     w    U_1 vector
!! @param [in,out] flop flop count
!<
subroutine lsor_inner_b4 (d, sz, idx, g, d2, x, a, e, w, &
                         msk, rhs, omg, itri, rd, flop)
implicit none
integer                                                ::  i, j, k, g, itri, l
integer                                                ::  ist, ied, kst, ked, jst, jed
integer, dimension(3)                                  ::  sz
integer, dimension(0:5)                                ::  idx
double precision                                       ::  flop
double precision, dimension(itri)                      ::  rd
real, dimension(1-g:sz(1)+g, 1-g:sz(3)+g, 1-g:sz(2)+g) ::  d, d2, x, msk, rhs
real, dimension(1-g:sz(3)+g)                           ::  a, e, w
real                                                   ::  omg, r
real                                                   ::  dp1, pp1
real                                                   ::  dp2, pp2
real                                                   ::  dp3, pp3
real                                                   ::  dp4, pp4
!dir$ assume_aligned d:64, a:64, e:64, w:64, d2:64, x:64, msk:64, rhs:64

ist = idx(0)
ied = idx(1)
jst = idx(2)
jed = idx(3)
kst = idx(4)
ked = idx(5)

r = 1.0/6.0

flop = flop + dble(jed-jst+1) * ( &
       dble((ied-ist+1)*(ked-kst+1))*3.0 &
     + dble(itri)* ( &
       dble((ied-ist+1)*(ked-kst+1))*(4.0+6.0) &
      +dble(ied-ist+1)*(3.0+3.0) &
      +dble((ied-ist+1)*(ked-2))*(3.0+2.0) ) )

!$OMP PARALLEL DO SCHEDULE(static) reduction(+:rd) &
!$OMP private(dp1,pp1,dp2,pp2,dp3,pp3,dp4,pp4)
do j=jst, jed

  ! Source term I for AX=b

  ! Intel 19.0 compiler can not unroll
  do k = kst, ked, 4
    !dir$ vector aligned
    !dir$ simd
    do i = ist, ied
      d2(i, k  , j) = ( x(i, k  , j-1) &
                    +   x(i, k  , j+1) ) * r + rhs(i, k  , j)
      d2(i, k+1, j) = ( x(i, k+1, j-1) &
                    +   x(i, k+1, j+1) ) * r + rhs(i, k+1, j)
      d2(i, k+2, j) = ( x(i, k+2, j-1) &
                    +   x(i, k+2, j+1) ) * r + rhs(i, k+2, j)
      d2(i, k+3, j) = ( x(i, k+3, j-1) &
                    +   x(i, k+3, j+1) ) * r + rhs(i, k+3, j)
    end do
  end do


  ! Inner Iteration
  do l=1, itri

    ! Source term II for AX=b

    do k = kst, ked, 4
      !dir$ vector aligned
      !dir$ simd
      do i = ist, ied
        d(i, k  , j) = (d2(i  , k  , j) &
                     + ( x(i-1, k  , j) &
                     +   x(i+1, k  , j) ) * r ) &
                     * msk(i  , k  , j)
        d(i, k+1, j) = (d2(i  , k+1, j) &
                     + ( x(i-1, k+1, j) &
                     +   x(i+1, k+1, j) ) * r ) &
                     * msk(i  , k+1, j)
        d(i, k+2, j) = (d2(i  , k+2, j) &
                     + ( x(i-1, k+2, j) &
                     +   x(i+1, k+2, j) ) * r ) &
                     * msk(i  , k+2, j)
        d(i, k+3, j) = (d2(i  , k+3, j) &
                     + ( x(i-1, k+3, j) &
                     +   x(i+1, k+3, j) ) * r ) &
                     * msk(i  , k+3, j)
      end do
    end do


    ! BC

    !dir$ vector aligned
    !dir$ simd
    do i=ist, ied
      d(i, kst, j) = ( d(i, kst  , j) &
                   + rhs(i, kst-1, j) * r ) &
                   * msk(i, kst  , j)
    end do


    !dir$ vector aligned
    !dir$ simd
    do i=ist, ied
      d(i, ked, j) = ( d(i, ked  , j) &
                   + rhs(i, ked+1, j) * r ) &
                   * msk(i, ked  , j)
    end do

    ! Forward

    do k = 3, ked
      !dir$ vector aligned
      !dir$ simd
      do i=ist, ied
        d(i, k  , j) = (d(i, k  , j) - a(k  ) * d(i, k-1, j)) * e(k  )
      end do
    end do


    ! Backwad

    do k=ked-1, 2 , -1
      !dir$ vector aligned
      !dir$ simd
      do i=ist, ied
        d(i, k  , j) = d(i, k  , j) - w(k  ) * d(i, k+1, j)
      end do
    end do


    ! Relax

    do k = kst, ked, 4
      !dir$ vector aligned
      !dir$ simd
      do i = ist, ied
        pp1 =   x(i, k  , j)
        dp1 = ( d(i, k  , j) - pp1 ) * omg * msk(i, k  , j)
        x(i, k  , j) = pp1 + dp1

        pp2 =   x(i, k+1, j)
        dp2 = ( d(i, k+1, j) - pp2 ) * omg * msk(i, k+1, j)
        x(i, k+1, j) = pp2 + dp2

        pp3 =   x(i, k+2, j)
        dp3 = ( d(i, k+2, j) - pp3 ) * omg * msk(i, k+2, j)
        x(i, k+2, j) = pp3 + dp3

        pp4 =   x(i, k+3, j)
        dp4 = ( d(i, k+3, j) - pp4 ) * omg * msk(i, k+3, j)
        x(i, k+3, j) = pp4 + dp4

        rd(l) = rd(l) + dp1 * dp1 &
                      + dp2 * dp2 &
                      + dp3 * dp3 &
                      + dp4 * dp4
      end do
    end do

  end do ! ItrInner
end do ! j-loop

return
end subroutine lsor_inner_b4

!> ********************************************************************
!! @brief TDMA
!! @param [in]     nx   配列長
!! @param [in]     g    ガイドセル長
!! @param [in,out] d    RHS vector -> 解ベクトル (in-place)
!! @param [in]     cf   係数
!! @param [in]     w    U_1 vector
!! @param [in,out] flop flop count
!<
subroutine lsor_inner_b (d, sz, idx, g, d2, x, a, e, w, &
                         msk, rhs, omg, itri, rd, flop)
implicit none
integer                                                ::  i, j, k, g, itri, l
integer                                                ::  ist, ied, kst, ked, jst, jed
integer, dimension(3)                                  ::  sz
integer, dimension(0:5)                                ::  idx
double precision                                       ::  flop
double precision, dimension(itri)                      ::  rd
real, dimension(1-g:sz(1)+g, 1-g:sz(3)+g, 1-g:sz(2)+g) ::  d, d2, x, msk, rhs
real, dimension(1-g:sz(3)+g)                           ::  a, e, w
real                                                   ::  omg, r
real                                                   ::  dp, pp
!dir$ assume_aligned d:64, a:64, e:64, w:64, d2:64, x:64, msk:64, rhs:64

ist = idx(0)
ied = idx(1)
jst = idx(2)
jed = idx(3)
kst = idx(4)
ked = idx(5)

r = 1.0/6.0

flop = flop + dble(jed-jst+1) * ( &
       dble((ied-ist+1)*(ked-kst+1))*3.0 &
     + dble(itri)* ( &
       dble((ied-ist+1)*(ked-kst+1))*(4.0+6.0) &
      +dble(ied-ist+1)*(3.0+3.0) &
      +dble((ied-ist+1)*(ked-2))*(3.0+2.0) ) )

!$OMP PARALLEL DO SCHEDULE(static) private(dp, pp) reduction(+:rd)
do j=jst, jed

  ! Source term I for AX=b

  do k = kst, ked
    !dir$ vector aligned
    !dir$ simd
    do i = ist, ied
      d2(i, k, j) = ( x(i, k, j-1) &
                  +   x(i, k, j+1) ) * r + rhs(i, k, j)
    end do
  end do


  ! Inner Iteration
  do l=1, itri

    ! Source term II for AX=b

    do k = kst, ked
      !dir$ vector aligned
      !dir$ simd
      do i = ist, ied
        d(i, k  , j) = (d2(i  , k  , j) &
                     + ( x(i-1, k  , j) &
                     +   x(i+1, k  , j) ) * r ) &
                     * msk(i  , k  , j)
      end do
    end do


    ! BC

    !dir$ vector aligned
    !dir$ simd
    do i=ist, ied
      d(i, kst, j) = ( d(i, kst  , j) &
                   + rhs(i, kst-1, j) * r ) &
                   * msk(i, kst  , j)
    end do


    !dir$ vector aligned
    !dir$ simd
    do i=ist, ied
      d(i, ked, j) = ( d(i, ked  , j) &
                   + rhs(i, ked+1, j) * r ) &
                   * msk(i, ked  , j)
    end do

    ! Forward

    do k = 3, ked
      !dir$ vector aligned
      !dir$ simd
      do i=ist, ied
        d(i, k  , j) = (d(i, k  , j) - a(k  ) * d(i, k-1, j)) * e(k  )
      end do
    end do


    ! Backwad

    do k=ked-1, 2 , -1
      !dir$ vector aligned
      !dir$ simd
      do i=ist, ied
        d(i, k  , j) = d(i, k  , j) - w(k  ) * d(i, k+1, j)
      end do
    end do


    ! Relax

    do k = kst, ked
      !dir$ vector aligned
      !dir$ simd
      do i = ist, ied
        pp =   x(i, k  , j)
        dp = ( d(i, k  , j) - pp ) * omg * msk(i, k  , j)
        x(i, k, j) = pp + dp
        rd(l) = rd(l) + dp * dp
      end do
    end do

  end do ! ItrInner
end do ! j-loop

return
end subroutine lsor_inner_b



!> ********************************************************************
!! @brief TDMA
!! @param [in]     nx   配列長
!! @param [in]     g    ガイドセル長
!! @param [in,out] d    RHS vector -> 解ベクトル (in-place)
!! @param [in]     cf   係数
!! @param [in]     w    U_1 vector
!! @param [in,out] flop flop count
!<
subroutine lsor_inner (d, sz, idx, g, j, d2, x, a, e, w, msk, rhs, omg, res, flop)
implicit none
integer                                                ::  i, j, k, g
integer                                                ::  ist, ied, kst, ked
integer, dimension(3)                                  ::  sz
integer, dimension(0:5)                                ::  idx
double precision                                       ::  flop, f1, f2, res
real, dimension(1-g:sz(1)+g, 1-g:sz(3)+g, 1-g:sz(2)+g) ::  d, d2, x, msk, rhs
real, dimension(1-g:sz(3)+g)                           ::  a, e, w
real                                                   ::  omg, r
real                                                   ::  dp1, pp1
real                                                   ::  dp2, pp2
real                                                   ::  dp3, pp3
real                                                   ::  dp4, pp4
!dir$ assume_aligned d:64, a:64, e:64, w:64, d2:64, x:64, msk:64, rhs:64

ist = idx(0)
ied = idx(1)
kst = idx(4)
ked = idx(5)

r = 1.0/6.0
f1 = dble( (ied-ist+1)*(ked-kst+1) )
f2 = dble( (ied-ist+1)*(ked-2) )

flop = flop + f1 * 4.0

! Source term for AX=b

!dir$ unroll(4)
do k = kst, ked

!dir$ vector aligned
!dir$ simd
do i = ist, ied
  d(i, k  , j) = (d2(i  , k  , j) &
               + ( x(i-1, k  , j) &
               +   x(i+1, k  , j) ) * r ) &
               * msk(i  , k  , j)
end do
end do


! BC

!dir$ vector aligned
!dir$ simd
do i=ist, ied
  d(i, kst, j) = ( d(i, kst  , j) &
               + rhs(i, kst-1, j) * r ) &
               * msk(i, kst  , j)
end do

flop = flop + f1 * 3.0


!dir$ vector aligned
!dir$ simd
do i=ist, ied
  d(i, ked, j) = ( d(i, ked  , j) &
               + rhs(i, ked+1, j) * r ) &
               * msk(i, ked  , j)
end do

flop = flop + f1 * 3.0



! Forward

!dir$ unroll(4)
do k = 3, ked
!dir$ vector aligned
!dir$ simd
do i=ist, ied
  d(i, k  , j) = (d(i, k  , j) - a(k  ) * d(i, k-1, j)) * e(k  )
end do
end do

flop = flop + f2 * 3.0


! Backwad

!dir$ unroll(4)
do k=ked-1, 2 , -1
!dir$ vector aligned
!dir$ simd
do i=ist, ied
  d(i, k  , j) = d(i, k  , j) - w(k  ) * d(i, k+1, j)
end do
end do

flop = flop + f2 * 2.0


! Relax

!dir$ unroll(4)
do k = kst, ked
!dir$ vector aligned
!dir$ simd
do i = ist, ied
  pp1 =   x(i, k  , j)
  dp1 = ( d(i, k  , j) - pp1 ) * omg * msk(i, k  , j)
  x(i, k, j) = pp1 + dp1
  res = res + dp1 * dp1
end do
end do

flop = flop + f1 * 6.0

return
end subroutine lsor_inner




!> ********************************************************************
!! @brief lsor
!! @param [in,out] d    ソース項
!! @param [in]     sz   配列長
!! @param [in]     idx  インデクス範囲
!! @param [in]     g    ガイドセル長
!! @param [in]     x    解ベクトル
!! @param [in,out] flop flop count
!! @note あとでlsor_lu_rhs1でマスクをかける
!<
subroutine lsor_lu_rhs_j (d, sz, idx, g, j, x, rhs, flop)
implicit none
integer                                                ::  i, j, k, g
integer                                                ::  ist, kst
integer                                                ::  ied, ked
integer, dimension(3)                                  ::  sz
integer, dimension(0:5)                                ::  idx
double precision                                       ::  flop
real, dimension(1-g:sz(1)+g, 1-g:sz(3)+g, 1-g:sz(2)+g) ::  d, x, rhs
real                                                   ::  r
!dir$ assume_aligned d:64, x:64, rhs:64

ist = idx(0)
ied = idx(1)
kst = idx(4)
ked = idx(5)

r = 1.0/6.0

flop = flop + dble((ied-ist+1)*(ked-kst+1))*3.0

!dir$ unroll(4)
do k = kst, ked
!dir$ vector aligned
!dir$ simd
do i = ist, ied
  d(i, k, j) = ( x(i, k, j-1) &
             +   x(i, k, j+1) ) * r + rhs(i, k, j)
end do
end do

return
end subroutine lsor_lu_rhs_j


!> ********************************************************************
!! @brief lsor
!! @param [in,out] d    ソース項
!! @param [in]     sz   配列長
!! @param [in]     idx  インデクス範囲
!! @param [in]     g    ガイドセル長
!! @param [in]     x    解ベクトル
!! @param [in]     rhs  オリジナルの線形方程式の右辺項
!! @param [in,out] flop flop count
!<
subroutine lsor_lu_fwd (d, sz, idx, g, j, x, a, e, d2, msk, rhs, flop)
implicit none
integer                                                ::  i, j, k, g
integer                                                ::  ist, ied, kst, ked
integer, dimension(3)                                  ::  sz
integer, dimension(0:5)                                ::  idx
double precision                                       ::  flop
real, dimension(1-g:sz(1)+g, 1-g:sz(3)+g, 1-g:sz(2)+g) ::  d, x, msk, d2, rhs
real                                                   ::  r
real, dimension(1-g:sz(3)+g)                           ::  a, e
!dir$ assume_aligned d:64, x:64, msk:64, d2:64, rhs:64, a:64, e:64

ist = idx(0)
ied = idx(1)
kst = idx(4)
ked = idx(5)

r = 1.0/6.0

flop = flop + dble( (ied-ist+1)*(ked-kst+1) )*4.0

do k = kst, ked

!dir$ vector aligned
!dir$ simd
do i = ist, ied
  d(i  ,k, j) = (d2(i  , k, j  ) &
              + ( x(i-1, k, j  ) &
              +   x(i+1, k, j  ) ) * r ) &
              * msk(i  , k, j  )
end do
end do


!dir$ vector aligned
!dir$ simd
do i=ist, ied
  d(i, kst, j) = ( d(i, kst  , j) &
               + rhs(i, kst-1, j) * r ) &
               * msk(i, kst  , j)
end do

flop = flop + dble( (ied-ist+1) )*3.0


!dir$ vector aligned
!dir$ simd
do i=ist, ied
  d(i, ked, j) = ( d(i, ked  , j) &
               + rhs(i, ked+1, j) * r ) &
               * msk(i, ked  , j)
end do

flop = flop + dble( (ied-ist+1) )*3.0


do k = 3, ked

!dir$ vector aligned
!dir$ simd
do i=ist, ied
  d(i, k, j  ) = (d(i, k, j  ) - a(k) * d(i, k-1, j  )) * e(k)
end do
end do

flop = flop + dble( (ied-ist+1)*(ked-2) )*3.0


return
end subroutine lsor_lu_fwd



!> ********************************************************************
!! @brief TDMA
!! @param [in]     nx   配列長
!! @param [in]     g    ガイドセル長
!! @param [in,out] d    RHS vector -> 解ベクトル (in-place)
!! @param [in]     cf   係数
!! @param [in]     w    U_1 vector
!! @param [in,out] flop flop count
!<
subroutine lsor_tdma_b (d, sz, idx, g, j, w, flop)
implicit none
integer                                                ::  i, j, k, g
integer                                                ::  ist, ied
integer                                                ::  kst, ked
integer, dimension(3)                                  ::  sz
integer, dimension(0:5)                                ::  idx
double precision                                       ::  flop
real                                                   ::  ww
real, dimension(1-g:sz(1)+g, 1-g:sz(3)+g, 1-g:sz(2)+g) ::  d
real, dimension(1-g:sz(3)+g)                           ::  w
!dir$ assume_aligned d:64, w:64

ist = idx(0)
ied = idx(1)
kst = idx(4)
ked = idx(5)
flop = flop + dble((ied-ist+1)*(ked-2))*2.0

do k=ked-1, 2, -1

!dir$ vector aligned
!dir$ simd
do i=ist, ied
  d(i  , k  , j  ) = d(i  , k  , j  ) - w(k) * d(i  , k+1, j  )
end do
end do

return
end subroutine lsor_tdma_b

!> ********************************************************************
!! @brief TDMA
!! @param [in]     nx   配列長
!! @param [in]     g    ガイドセル長
!! @param [in,out] d    RHS vector -> 解ベクトル (in-place)
!! @param [in]     cf   係数
!! @param [in]     w    U_1 vector
!! @param [in,out] flop flop count
!<
subroutine lsor_tdma_b4 (d, sz, idx, g, j, w, flop)
implicit none
integer                                                ::  i, j, k, g
integer                                                ::  ist, ied
integer                                                ::  kst, ked
integer, dimension(3)                                  ::  sz
integer, dimension(0:5)                                ::  idx
double precision                                       ::  flop
real, dimension(1-g:sz(1)+g, 1-g:sz(3)+g, 1-g:sz(2)+g) ::  d
real, dimension(1-g:sz(3)+g)                           ::  w
!dir$ assume_aligned d:64, w:64

ist = idx(0)
ied = idx(1)
kst = idx(4)
ked = idx(5)
flop = flop + dble((ied-ist+1)*(ked-2))*2.0

do k=ked-1, 2, -4

!dir$ vector aligned
!dir$ simd
do i=ist, ied
  d(i, k  , j) = d(i, k  , j) - w(k  ) * d(i, k+1, j)
  d(i, k-1, j) = d(i, k-1, j) - w(k-1) * d(i, k  , j)
  d(i, k-2, j) = d(i, k-2, j) - w(k-2) * d(i, k-1, j)
  d(i, k-3, j) = d(i, k-3, j) - w(k-3) * d(i, k-2, j)
end do
end do

return
end subroutine lsor_tdma_b4


!> ********************************************************************
!! @brief lsor
!! @param [in,out] d    ソース項
!! @param [in]     sz   配列長
!! @param [in]     idx  インデクス範囲
!! @param [in]     g    ガイドセル長
!! @param [in]     x    解ベクトル
!! @param [in]     omg  加速係数
!! @param [out]    res  残差
!! @param [in,out] flop flop count
!<
subroutine lsor_relax (d, sz, idx, g, j, x, msk, omg, res, flop)
implicit none
integer                                                ::  i, j, k, g
integer                                                ::  ist, ied
integer                                                ::  kst, ked
integer, dimension(3)                                  ::  sz
integer, dimension(0:5)                                ::  idx
double precision                                       ::  flop, res
real                                                   ::  omg
real                                                   ::  dp1, pp1
real                                                   ::  dp2, pp2
real                                                   ::  dp3, pp3
real                                                   ::  dp4, pp4
real, dimension(1-g:sz(1)+g, 1-g:sz(3)+g, 1-g:sz(2)+g) ::  d, x, msk
!dir$ assume_aligned d:64, x:64, msk:64

ist = idx(0)
ied = idx(1)
kst = idx(4)
ked = idx(5)

flop = flop + dble((ked-kst+1)*(ied-ist+1))*6.0

do k = kst, ked

!dir$ vector aligned
!dir$ simd
do i = ist, ied
  pp1 =   x(i  , k  , j  )
  dp1 = ( d(i  , k  , j  ) - pp1 ) * omg * msk(i  , k  , j  )
  x(i  , k  , j  ) = pp1 + dp1

  res = res + dp1 * dp1
end do
end do

return
end subroutine lsor_relax


!> ********************************************************************
!! @brief lsor
!! @param [in,out] d    ソース項
!! @param [in]     sz   配列長
!! @param [in]     idx  インデクス範囲
!! @param [in]     g    ガイドセル長
!! @param [in]     x    解ベクトル
!! @param [in]     omg  加速係数
!! @param [out]    res  残差
!! @param [in,out] flop flop count
!<
subroutine lsor_relax4 (d, sz, idx, g, j, x, msk, omg, res, flop)
implicit none
integer                                                ::  i, j, k, g
integer                                                ::  ist, ied
integer                                                ::  kst, ked
integer, dimension(3)                                  ::  sz
integer, dimension(0:5)                                ::  idx
double precision                                       ::  flop, res
real                                                   ::  omg
real                                                   ::  dp1, pp1
real                                                   ::  dp2, pp2
real                                                   ::  dp3, pp3
real                                                   ::  dp4, pp4
real, dimension(1-g:sz(1)+g, 1-g:sz(3)+g, 1-g:sz(2)+g) ::  d, x, msk
!dir$ assume_aligned d:64, x:64, msk:64

ist = idx(0)
ied = idx(1)
kst = idx(4)
ked = idx(5)

flop = flop + dble((ked-kst+1)*(ied-ist+1))*6.0

do k = kst, ked, 4

!dir$ vector aligned
!dir$ simd
do i = ist, ied
  pp1 =   x(i, k  , j)
  dp1 = ( d(i, k  , j) - pp1 ) * omg * msk(i, k  , j)
  x(i, k, j) = pp1 + dp1

  pp2 =   x(i, k+1, j)
  dp2 = ( d(i, k+1, j) - pp2 ) * omg * msk(i, k+1, j)
  x(i, k+1, j) = pp2 + dp2

  pp3 =   x(i, k+2, j)
  dp3 = ( d(i, k+2, j) - pp3 ) * omg * msk(i, k+2, j)
  x(i, k+2, j) = pp3 + dp3

  pp4 =   x(i, k+3, j)
  dp4 = ( d(i, k+3, j) - pp4 ) * omg * msk(i, k+3, j)
  x(i, k+3, j) = pp4 + dp4

  res = res + dp1 * dp1 &
            + dp2 * dp2 &
            + dp3 * dp3 &
            + dp4 * dp4
end do
end do

return
end subroutine lsor_relax4




!> ********************************************************************
!! @brief lsor
!! @param [in,out] d    ソース項
!! @param [in]     sz   配列長
!! @param [in]     idx  インデクス範囲
!! @param [in]     g    ガイドセル長
!! @param [in]     x    解ベクトル
!! @param [in]     w    work
!! @param [in]     a    coef
!! @param [in]     b    coef
!! @param [in]     c    coef
!! @param [in]     rhs  オリジナルの線形方程式の右辺項
!! @param [in]     omg  加速係数
!! @param [out]    res  残差
!! @param [in,out] flop flop count
!<
subroutine tdma_lsor_e (d, sz, idx, g, x, w, a, c, rhs, omg, res, flop)
implicit none
integer                                                ::  i, j, k, g
integer                                                ::  ist, jst, kst
integer                                                ::  ied, jed, ked
integer, dimension(3)                                  ::  sz
integer, dimension(0:5)                                ::  idx
double precision                                       ::  flop, res
real                                                   ::  omg, dp, pp, pn
real, dimension(1-g:sz(3)+g, 1-g:sz(1)+g, 1-g:sz(2)+g) ::  d, x, w, rhs
real                                                   ::  r, e
real, dimension(1-g:sz(3)+g)                           ::  a, c
!dir$ assume_aligned d:64, x:64, w:64, rhs:64, a:64, c:64


ist = idx(0)
ied = idx(1)
jst = idx(2)
jed = idx(3)
kst = idx(4)
ked = idx(5)

r = 1.0/6.0

flop = flop + dble((ied-ist+1)*(jed-jst+1)*(ked-kst+1))*(4.0+16.0+5.0) &
            + dble((ied-ist+1)*(jed-jst+1)) * 2.0;

!$OMP PARALLEL DO SCHEDULE(static) &
!$OMP REDUCTION(+:res) PRIVATE(pp, dp, pn, e)
do j = jst, jed
do i = ist, ied

  !dir$ vector aligned
  !dir$ simd
  do k = kst, ked
     d(k,i,j) = ( x(k,i-1,j  ) &
              +   x(k,i+1,j  ) &
              +   x(k,i  ,j-1) &
              +   x(k,i  ,j+1) ) * r + rhs(k,i,j)
  end do
  d(kst,i,j) = d(kst,i,j) + rhs(kst-1,i,j)*r
  d(ked,i,j) = d(ked,i,j) + rhs(ked+1,i,j)*r

  ! TDMA
  w(kst,i,j) = c(kst)

  !dir$ vector aligned
  do k=kst+1, ked
    e = 1.0 / (1.0 - a(k) * w(k-1,i,j))
    w(k,i,j) = e * c(k)
    d(k,i,j) = (d(k,i,j) - a(k) * d(k-1,i,j)) * e
  end do

  !dir$ vector aligned
  do k=ked-1, kst, -1
    d(k,i,j) = d(k,i,j) - w(k,i,j) * d(k+1,i,j)
  end do


  !dir$ vector aligned
  !dir$ simd
  do k = kst, ked
    pp = x(k,i,j)
    dp = ( d(k,i,j) - pp ) * omg
    pn = pp + dp
    x(k,i,j) = pn
    res = res + dp*dp
  end do

end do
end do
!$OMP END PARALLEL DO


return
end subroutine tdma_lsor_e

!> ********************************************************************
!! @brief lsor
!! @param [in,out] d    ソース項
!! @param [in]     sz   配列長
!! @param [in]     idx  インデクス範囲
!! @param [in]     g    ガイドセル長
!! @param [in]     x    解ベクトル
!! @param [in]     w    work
!! @param [in]     a    coef
!! @param [in]     b    coef
!! @param [in]     c    coef
!! @param [in]     rhs  オリジナルの線形方程式の右辺項
!! @param [in]     omg  加速係数
!! @param [out]    res  残差
!! @param [in,out] flop flop count
!<
subroutine tdma_lsor_f (d, sz, idx, g, x, w, e, a, rhs, omg, res, flop)
implicit none
integer                                                ::  i, j, k, g
integer                                                ::  ist, jst, kst
integer                                                ::  ied, jed, ked
integer, dimension(3)                                  ::  sz
integer, dimension(0:5)                                ::  idx
double precision                                       ::  flop, res
real                                                   ::  omg, dp, pp, pn
real, dimension(1-g:sz(3)+g, 1-g:sz(1)+g, 1-g:sz(2)+g) ::  d, x, rhs
real                                                   ::  r
real, dimension(1-g:sz(3)+g)                           ::  a, w, e
!dir$ assume_aligned d:64, x:64, w:64, rhs:64, a:64, e:64

ist = idx(0)
ied = idx(1)
jst = idx(2)
jed = idx(3)
kst = idx(4)
ked = idx(5)

r = 1.0/6.0

flop = flop + dble((ied-ist+1)*(jed-jst+1)*(ked-kst+1))*(5.0+5.0+5.0) &
            + dble((ied-ist+1)*(jed-jst+1)) * 5.0;


!$OMP PARALLEL DO SCHEDULE(static) &
!$OMP REDUCTION(+:res) PRIVATE(pp, dp, pn)
do j = jst, jed
do i = ist, ied

  !dir$ vector aligned
  !dir$ simd
  do k = kst, ked
     d(k,i,j) = ( x(k,i-1,j  ) &
              +   x(k,i+1,j  ) &
              +   x(k,i  ,j-1) &
              +   x(k,i  ,j+1) ) * r + rhs(k,i,j)
  end do
  d(kst,i,j) = d(kst,i,j) + rhs(kst-1,i,j)*r
  d(ked,i,j) = d(ked,i,j) + rhs(ked+1,i,j)*r

  ! TDMA
  d(kst,i,j) = d(kst,i,j)

  !dir$ vector aligned
  do k=kst+1, ked
    d(k,i,j) = (d(k,i,j) - a(k) * d(k-1,i,j)) * e(k)
  end do

  !dir$ vector aligned
  do k=ked-1, kst, -1
    d(k,i,j) = d(k,i,j) - w(k) * d(k+1,i,j)
  end do


  !dir$ vector aligned
  !dir$ simd
  do k = kst, ked
    pp = x(k,i,j)
    dp = ( d(k,i,j) - pp ) * omg
    pn = pp + dp
    x(k,i,j) = pn
    res = res + dp*dp
  end do

end do
end do
!$OMP END PARALLEL DO


return
end subroutine tdma_lsor_f
