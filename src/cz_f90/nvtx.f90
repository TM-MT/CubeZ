module nvtx
  implicit none

contains

  subroutine nvtxStartRange(name,id)
    character(len=*) :: name
    integer, optional:: id
  end subroutine nvtxStartRange

  subroutine nvtxEndRange
  end subroutine nvtxEndRange

end module nvtx
