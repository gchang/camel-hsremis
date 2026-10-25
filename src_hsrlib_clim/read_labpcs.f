      SUBROUTINE  read_labpcs(path_lab,clabvs)

    ! Description:
    ! read the eigenveectors and eigenvalues of the selected laboratory measurements
    ! 
    ! History:
    ! Version   Date     Comment
    ! -------   ----     -------
    !  0.6       05/11/2016  Original code E Borbas UW-Madison/CIMSS
    !  1.0(r04)07/11/2018  modified for adding Version 9 and 11 lab datasets 
    !
    ! Code Description:
    !   Language:           Fortran 90.
    !
    ! Declarations:
    ! Modules used:

       Implicit none
      include 'netcdf.inc'
      include 'hsriremis_clim_EDR.inc'
       SAVE
      
    ! Define Variables.

       Integer*4 :: nvars     ! number of variables
       Integer*4 :: ndims     ! number of dimensions
       Integer*4 :: errstat   ! error code
       Integer*4 :: recdim    ! record dimension
       Integer*4 :: nc_dim(2) !  lats, lons,hng_pnt
  
       Integer    :: i,j,k,l
       Integer*4 :: ncid, ngatts, nrecs, varid
 
       INTEGER :: err, errorstatus_fatal,errorstatus_success
    
       LOGICAL :: file_exists
   
       REAL, PARAMETER :: scale_factor=1.
       REAL, PARAMETER :: add_offset=0.
               
       REAL*8 ::  pcm1(numwave), pcu1(numwave,numwave)
       REAL*4 :: pcm(numwave),pcu(numwave,numwave)

       character*200 fn
       Character (len=1024) :: strbuf ! string buffer for var 
       Character(len=3) :: clabvs


!--------------------------------------------------       
! Open v8 Lab PC file on hsr resolution.
!--------------------------------------------------       

       fn=TRIM(path_lab)//'pchsr_v'//TRIM(clabvs)//'.2.nc'
       errstat = nf_open(Trim(fn),nf_nowrite,ncid)
       
        Inquire(FILE=fn, EXIST=file_exists)
        If (.not. file_exists) Then
           err = errorstatus_fatal
           write(*,*)  'Lab PC file not found : ',Trim(fn)
	   return
        End If
        write(*,*) 'Reading lab pc data: ', Trim(fn)
	   
    ! Get info on the record dimension for this file. 
      errstat = nf_inq(ncid,ndims,nvars,ngatts,recdim)
                
      Do i=1,ndims
        errstat = nf_inq_dim(ncid,i,strbuf,nrecs)
        nc_dim(i) = nrecs
      End Do
  	  
    ! Retrieve eigenvalues
      errstat = nf_inq_varid (ncid, 'Eigenvalues', varid)
      errstat = nf_get_var_double(ncid,varid,pcm1)
            
    ! Retrieve eigenvectors
      errstat = nf_inq_varid (ncid, 'Eigenvectors', varid)
      errstat = nf_get_var_double(ncid,varid,pcu1)
            
      errstat = nf_close(ncid)
   
!       pcm=real(pcm1)
!       pcu=real(pcu1)
     
      if(clabvs.eq.'10 ') then 
                 pc_hsr_v10=pcu1
                 pcm_hsr_v10=pcm1
      endif 		 
		 
      if(clabvs.eq.'8  ')  then
                 pc_hsr_v8=pcu1
                 pcm_hsr_v8=pcm1
      endif

      if(clabvs.eq.'12 ') then 
                 pc_hsr_v12=pcu1
                 pcm_hsr_v12=pcm1
      endif 		 
   
      if(clabvs.eq.'9 ') then 
                 pc_hsr_v9=pcu1
                 pcm_hsr_v9=pcm1
      endif 		 

      if(clabvs.eq.'11 ') then 
                 pc_hsr_v11=pcu1
                 pcm_hsr_v11=pcm1
      endif 		 
     
      END SUBROUTINE read_labpcs
  


 
 
 
