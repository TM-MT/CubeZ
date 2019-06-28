# CubeZ

## OUTLINE

CubeZ is a platform for testing iterative solvers.


## Copyright
- Copyright (c) 2018-2019 Research Institute for Information Technology(RIIT), Kyushu University. All rights reserved.



## Prerequisite

- Cmake
- MPI library (if parallel)
- PMlib
- PAPI (Optional)
- CBrick (Even compiling without MPI, a header file CB_Define.h is essential. See serial build.)


## How to build

### Build

~~~
$ export CZ_HOME=/hogehoge
$ mkdir build
$ cd build
$ cmake [options] ..
$ make
$ sudo make install
~~~


### Options

`-D INSTALL_DIR=` *Install_directory*
>  Specify the directory that this library will be installed. Built library is
   installed at `install_directory/lib` and the header files are placed at
   `install_directory/include`.

`-D enable_OPENMP=` {yes | no}
>  This option makes OpenMP directives effect. Default is yes.

`-D with_MPI=` {yes | no}
>  If you use an MPI library, specify `with_MPI=yes` (default).

`-D real_type=` {float | double}
>  Specify the type of floating point. If this option is omitted, the default is float.

`-D with_PM=` {*Installed_Directory* | OFF}
> Specify the directory path that PMlib is installed, or OFF.

`-D with_CBR=` *Installed_Directory*
> Specify the directory path that CBrick is installed.

`-D with_PAPI=` *Installed_Directory*
> Specify the directory path that PAPI is installed.

`-D with_SIMD=` {OFF | 256|512}
> Specify SIMD length. The default is OFF. If you want to use AVX512 specify 512.

`-D with_Ftrace=` (off | on)
> In the case of Aurora, if you want to use Ftrace option, specify turn on this option.


### Default settng
~~~
with_MPI = ON
enable_OPENMP = ON
real_type = float
with_PAPI = OFF
with_SIMD = OFF
with_Ftrace = OFF
~~~


## Configure Examples

`$ export CZ_HOME=hogehoge`

In following examples, assuming that TextParser, PMlib, and CBrick are installed under the CZ_HOME directory. If not, please specify applicable directory paths.


### Serial build
When even compiling without MPI, the heaｄder files `CB_Define.h` and `CB_SubDomain.h` in CBrick library are required.
Copy them form CBrick directory into cz_cpp, then make. In this case, specify `-D with_CBR=OFF` to suppress linking to CBrick library.

In case of some Intel compiler environment, please specify environment variables before compilation.
`export CC=icc CXX=icpc F90=ifort FC=ifort`
`export CZ_HOME=hoge`

#### INTEL/GNU compiler serial without PAPI

~~~
cmake -DINSTALL_DIR=${CZ_HOME}/CubeZ/CZ \
-Dwith_MPI=no \
-Dwith_PM=${CZ_HOME}/CubeZ/PMlib \
-Dwith_SIMD=256 \
-Dwith_CBR=OFF ..
~~~

#### Mac PGI
~~~
$ module load pgi/17.7
$ export CC=pgcc CXX=pgc++ F90=pgf90 FC=pgf90
$ cmake -DINSTALL_DIR=${CZ_HOME}/CubeZ/CZ \
-Dwith_MPI=no \
-Dreal_type=float \
-Denable_OPENMP=yes \
-Dwith_PM=${CZ_HOME}/CubeZ/PMlib_PGI \
-Dwith_SIMD=256 \
-Dwith_CBR=OFF ..
~~~


### ITO A/B with PAPI

~~~
$ module load intel/2018
export CC=icc CXX=icpc F90=ifort FC=ifort

cmake -DINSTALL_DIR=${HOME}/CZ/CZ \
-Dwith_MPI=no \
-Dwith_PM=${HOME}/CZ/PMlib \
-Dwith_PAPI=${HOME}/CZ/PAPI \
-Dwith_SIMD=256 \
-Dwith_CBR=OFF ..
~~~


### Aurora without PAPI

~~~
export CZ_HOME=${HOME}
export CC=ncc CXX=nc++ F90=nfort FC=nfort
cmake -DINSTALL_DIR=${CZ_HOME}/CubeZ/CZ \
-DCMAKE_TOOLCHAIN_FILE=../cmake/Toolchain_NEC_Aurora.cmake \
-Dwith_MPI=no \
-Dwith_PM=OFF \
-Dwith_CBR=OFF \
-Dwith_Ftrace=ON ..
~~~


#### PGI on ITO B

~~~
$ module load pgi/17.7
$ export CC=pgcc CXX=pgc++ F90=pgf90 FC=pgf90
$ cmake -DINSTALL_DIR=${CZ_HOME}/CubeZ/CZ \
-Dwith_MPI=no \
-Dreal_type=float \
-Denable_OPENMP=yes \
-Dwith_PM=${CZ_HOME}/CZ/PAPI-5.5.1_gcc4.8.5 \
-Dwith_SIMD=256 \
-Dwith_PAPI=${HOME}/opt/papi-5.5.1_gcc4.8.5 \
-Dwith_ACC=Pascal \
-Dwith_CBR=OFF ..
~~~




### FUJITSU compiler / FX100, K computer on login nodes (Cross compilation) and Fujitsu TCS environment for intel PC

~~~
$ cmake -DINSTALL_DIR=${CZ_HOME}/RAinWATER \
        -DCMAKE_TOOLCHAIN_FILE=../cmake/Toolchain_fx100.cmake \
        -Dreal_type=float \
        -Denable_OPENMP=yes \
        -Dwith_MPI=yes \
        -Dwith_PM=${CZ_HOME}/PMlib \
        -Dwith_PAPI=OFF \
        -Dwith_CBR=${CZ_HOME}/CBrick ..

$ cmake -DINSTALL_DIR=${CZ_HOME}/RAinWATER \
        -DCMAKE_TOOLCHAIN_FILE=../cmake/Toolchain_K.cmake \
        -Dreal_type=float \
        -Denable_OPENMP=yes \
        -Dwith_MPI=yes \
        -Dwith_PM=${CZ_HOME}/PMlib \
        -Dwith_PAPI=OFF \
        -Dwith_CBR=${CZ_HOME}/CBrick ..

$ cmake -DINSTALL_DIR=${CZ_HOME}/RAinWATER \
        -DCMAKE_TOOLCHAIN_FILE=../cmake/Toolchain_intel_F_TCS.cmake \
        -Dreal_type=float \
        -Denable_OPENMP=yes \
        -Dwith_MPI=yes \
        -Dwith_PM=${CZ_HOME}/PMlib \
        -Dwith_PAPI=OFF \
        -Dwith_CBR=${CZ_HOME}/CBrick ..
~~~

##### Note
- On Fujitsu machines(K, fx100), confirm appropriate directory path for compiler environment.
- Before building, execute following command to clean for sure. `$ make distclean`





## Contributors

- Kenji Ono


### Comment of precision of Fortran
For example, the `-CcdRR8` option for fortran preprocessor convert variables, functions, and constants higher precision version in source code. Thus, functions in source code is described by floating version.

## 使い方

~~~
$ ./cz gsz_x, gsz_y, gsz_z, linear_solver, IterationMax coef [gdv_x, gdv_y, gdv_z]
$ ./cz 124 124 124 sor2sma 10000 1.5
$ ./cz 124 124 124 sor2sma_maf 10000 1.5
$ ./cz 124 124 124 pbicgstab 10000 1.5 {jacobi, psor, sor2sma, pcr}
$ ./cz 124 124 124 pbicgstab_maf 10000 1.5 {jacobi, psor, sor2sma, pcr}
$ ./cz 124 124 124 pcr 10000 1.5
$ ./cz 124 124 124 pcr_maf 10000 1.5
~~~
 - gsz_x, gsz_y, gsz_z  全計算領域の要素数
 - linear_solver        線形ソルバの指定
   - jacobi
   - sor
   - sor2sma
   - pbicgstab
   - pcr
 - IterationMax         最大反復回数
 - coef  緩和/加速係数
 - gdv_x, gdv_y, gdv_z  領域分割数の指定、指定しない場合には自動分割
