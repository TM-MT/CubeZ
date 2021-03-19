###################################################################################
#
# CubeZ
#
# Copyright (C) 2018-2020 Research Institute for Information Technology(RIIT), Kyushu University.
# All rights reserved.
#
###################################################################################

include_directories(
       ${CBR_INC}
)

set(cz_files
       cz_solver.f90
       cz_blas.f90
       cz_utility.f90
       obsolete.f90
       cz_maf.f90
)


# Read environment variable `LAPACK_DIR` 
# assume `LAPACK_DIR` contains `liblapack.a` and `libblas.a`
if (DEFINED ENV{LAPACK_DIR})
    set(LAPACK_DIR $ENV{LAPACK_DIR})
    message(STATUS "LAPACK_DIR: " $LAPACK_DIR)
else()
    message(FATAL_ERROR "ENVIRONMENT VARIABLE `LAPACK_DIR` NOT DEFINED")
endif()

add_library(FCORE STATIC ${cz_files})
target_link_libraries(FCORE ${LAPACK_DIR}/liblapack.a ${LAPACK_DIR}/libblas.a )

if(with_ACC)
  if(CMAKE_CXX_COMPILER_ID STREQUAL "PGI")
    SET_TARGET_PROPERTIES(FCORE PROPERTIES LINKER_LANGUAGE Fortran)
  endif()
else()
  SET_TARGET_PROPERTIES(FCORE PROPERTIES LINKER_LANGUAGE CXX)
  target_link_libraries(FCORE ${CMAKE_CXX_IMPLICIT_LINK_LIBRARIES})
endif()

###
