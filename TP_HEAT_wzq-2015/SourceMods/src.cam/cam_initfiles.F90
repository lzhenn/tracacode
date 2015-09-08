module cam_initfiles
!----------------------------------------------------------------------- 
! 
! Open, close, and provide access to the initial conditions and topography files.
! 
!-----------------------------------------------------------------------

use pio,          only: file_desc_t

implicit none
private
save

! Public methods

public :: &
   cam_initfiles_open,   &! open initial and topo files
   initial_file_get_id,  &! returns filehandle for initial file
   topo_file_get_id,     &! returns filehandle for topo file
   tpmask_file_get_id,     &! returns filehandle for tp mask file
   cam_initfiles_close     ! close initial and topo files

type(file_desc_t), pointer :: fh_ini, fh_topo, fh_tpmask

!======================================================================= 
contains
!======================================================================= 

function initial_file_get_id()
  type(file_desc_t), pointer :: initial_file_get_id
  initial_file_get_id => fh_ini
end function initial_file_get_id

function topo_file_get_id()
  type(file_desc_t), pointer :: topo_file_get_id
  topo_file_get_id => fh_topo
end function topo_file_get_id

function tpmask_file_get_id()
  type(file_desc_t), pointer :: tpmask_file_get_id
  tpmask_file_get_id => fh_tpmask
end function tpmask_file_get_id
!======================================================================= 

subroutine cam_initfiles_open()

   ! Open the initial conditions and topography files.

   use filenames,        only: ncdata, bnd_topo
   use ioFileMod,        only: getfil

   use cam_pio_utils,    only: cam_pio_openfile
   use pio,              only: pio_nowrite

   use readinitial,      only: read_initial

   character(len=256) :: ncdata_loc     ! filepath of initial file on local disk
   character(len=256) :: bnd_topo_loc   ! filepath of topo file on local disk
   character(len=256) :: bnd_tpmask_loc   ! filepath of topo file on local disk

   bnd_tpmask_loc = "/users/yangsong3/wzq/TP_noPBL_HEAT/data/TPmask.nc"
   !----------------------------------------------------------------------- 
   
   ! Open initial, topography, and landfrac datasets
   call getfil (ncdata, ncdata_loc)

   allocate(fh_ini)
   call cam_pio_openfile(fh_ini, ncdata_loc, PIO_NOWRITE, .TRUE.)
   ! Backward compatibility: look for topography data on initial file if topo file name not provided.
   if (trim(bnd_topo) /= 'bnd_topo' .and. len_trim(bnd_topo) > 0) then
      allocate(fh_topo)
      call getfil(bnd_topo, bnd_topo_loc) !getfil is check process
      call cam_pio_openfile(fh_topo, bnd_topo_loc, PIO_NOWRITE)
   else
      fh_topo => fh_ini
   end if


   ! 20150721 Add for TP mask
   allocate(fh_tpmask)
   call cam_pio_openfile(fh_tpmask, bnd_tpmask_loc, PIO_NOWRITE)

   ! Check for consistent settings on initial dataset -- this is dycore
   ! dependent -- should move to dycore interface
   call read_initial (fh_ini)

end subroutine cam_initfiles_open

!======================================================================= 

subroutine cam_initfiles_close()

  use pio,          only: pio_closefile

  if(associated(fh_ini)) then
     if(.not. associated(fh_ini, target=fh_topo)) then
        call pio_closefile(fh_topo)
        deallocate(fh_topo)
     end if
     
     call pio_closefile(fh_ini)
     deallocate(fh_ini)
     nullify(fh_ini)
     nullify(fh_topo)
  end if


  call pio_closefile(fh_tpmask)
  deallocate(fh_tpmask)
  nullify(fh_tpmask)
end subroutine cam_initfiles_close

!======================================================================= 

end module cam_initfiles
