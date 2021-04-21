# 1 "./src/cz_f90/nvtx.f90"
# 1 "<built-in>"
# 1 "<command-line>"
# 1 "./src/cz_f90/nvtx.f90"
module nvtx
# 74 "./src/cz_f90/nvtx.f90"
  implicit none

contains

  subroutine nvtxStartRange(name,id)
    character(len=*) :: name
    integer, optional:: id
  end subroutine nvtxStartRange

  subroutine nvtxEndRange
  end subroutine nvtxEndRange

end module nvtx
