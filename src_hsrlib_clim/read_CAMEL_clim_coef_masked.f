      SUBROUTINE  read_CAMEL_clim_coef_masked(fn_coef,pcacoefs, weights)
      
      
    ! Description:
    ! read the 0.05 degree resolution MEASURES CAMEL (Combined ASTER MODIS Emissivity over Land)
    ! from the netCDF file into memory. 
    ! 
    ! History:
    ! Version   Date     Comment
    ! -------   ----     -------
    !   0.6     05/11/2016  Original code E Borbas UW-Madison/CIMSS
    !   1.0     01/10/2017  Adjusted to the MEASUREs CAMEL products Version V001 (v01r02)
    !   3.0     10/20/2023  change lane 34, 134-136: to read pcacoef1 from double to real 
    !                       to avoid compiling error with ifort based on user's feedback 
    !                       (Virginie Caleppe (LMD, France)
    ! Code Description:
    !   Language:           Fortran 90.
    !

       Implicit none
       include 'netcdf.inc'
       include 'hsriremis_clim_EDR.inc'
       SAVE
      
    ! Define Variables.

      Integer*4 :: nvars     ! number of variables
      Integer*4 :: ndims     ! number of dimensions
      Integer*4 :: errstat   ! error code
      Integer*4 :: recdim    ! record dimension
      Integer*4 :: nc_dim(5) !  lats, lons,hng_pnt, pack_leng
      INTEGER:: gridy, gridx
      Integer*4  :: indexlut
     
      REAL, ALLOCATABLE :: pcacoefs1(:,:)      !(max_npcs,nmask)  
      INTEGER*2, ALLOCATABLE :: nsamps_set1(:,:)      !(nset,nmask)  
      REAL, ALLOCATABLE :: weights1(:,:)      !(nset,nmask)  
    
       real :: latitude(3600)
  
      Integer    :: i,j,k,l, eline
      Integer*4 :: ncid, ngatts, nrecs, varid,varid2
                      
      Character (len=1024) :: strbuf ! string buffer for var
      Character (len=6)    :: cfld 

!----------------------------------------------------   	  
    ! Open netCDF file.
!----------------------------------------------------   	  
 
      errstat = nf_open(Trim(fn_coef),nf_nowrite,ncid)      

!----------------------------------------------------   	  
    ! Get info on the record dimension for this file. 
!----------------------------------------------------   	  
 
      errstat = nf_inq(ncid,ndims,nvars,ngatts,recdim)
         
      Do i=1,ndims
        errstat = nf_inq_dim(ncid,i,strbuf,nrecs)
        nc_dim(i) = nrecs
      End Do
      write(*,*) 'nc_dim= ',nc_dim
      nmask=nc_dim(5) 
      write(*,*) 'mask: ', nmask
 !----------------------------------------------------   	  
    ! Retrieve emissivity database flag value
!----------------------------------------------------   
      errstat = nf_inq_varid (ncid, 'labvs_of_coef_set', varid)
      errstat = nf_get_var_int2(ncid,varid,labvs_set)
 
      !write(*,*) 'labvs_of_coef_set:   ',labvs_set
      
      errstat = nf_inq_varid (ncid, 'npcs_of_coef_set', varid)
      errstat = nf_get_var_int2(ncid,varid,npcs_set)
      
      !write(*,*) 'npcs_of_coef_set:   ',npcs_set

      errstat = nf_inq_varid (ncid, 'landflag', varid)
      errstat = nf_get_var_int2(ncid,varid,lsmask)
           
      !write(*,*) 'in read_camel_coef lsmask =', lsmask(3905,2285)
   
	   
!----------------------------------------------------   
    ! Generate the look-up table into the emissivity data
!----------------------------------------------------   
       coef_lut = -1
       indexlut = 1
           Do i=1,nc_dim(1)
             Do j=1,nc_dim(2)
           If (lsmask(j,i) > 0) then
             coef_lut(j,i) = indexlut
             indexlut = indexlut + 1
           End If
         End Do
       End Do
       
       !write(*,*) 'indexlut:  ',indexlut,coef_lut(3980,860), coef_lut(3905,2285)
!----------------------------------------------------   	  
    ! Retrieve weights each pixels
!----------------------------------------------------   
      allocate(weights1(nset,nmask))

      errstat = nf_inq_varid (ncid, 'pc_coef_weights', varid)
      errstat = nf_get_var_real(ncid,varid,weights1)
      
       weights(:,1:nmask) = weights1
       !write(*,*) 'in read_camel_coef weights1 =',weights1(:,coef_lut(3905,2285))
       !write(*,*) 'in read_camel_coef weights =',weights(:,coef_lut(3905,2285))
       !write(*,*) 'in read_camel_coef weights =',weights(:,coef_lut(3980,860))
    
       deallocate(weights1)

!----------------------------------------------------   	  
    ! Retrieve number of sampels each pixels
!----------------------------------------------------   
      allocate(nsamps_set1(nset,nmask))

      errstat = nf_inq_varid (ncid, 'pc_coef_nsamps', varid)
      errstat = nf_get_var_int2(ncid,varid,nsamps_set1)
      
       nsamps_set(:,1:nmask) = nsamps_set1
       !write(*,*) 'in read_camel_coef nsamps_set1 =',nsamps_set1(:,coef_lut(3905,2285))
       !write(*,*) 'in read_camel_coef nsamps_set =',nsamps_set(:,coef_lut(3905,2285))
     
       deallocate(nsamps_set1)
                 
!----------------------------------------------------   	  
    ! Retrieve verson number of pcs of laboratory data
!----------------------------------------------------   
       allocate(pcacoefs1(max_npcs,nmask))
   
      errstat = nf_inq_varid (ncid, 'pc_coefs', varid)
      errstat = nf_get_var_real(ncid,varid,pcacoefs1)

       pcacoefs(:,1:nmask) = dble(pcacoefs1)
       !write(*,*) 'in read_camel_coef coef1 =',pcacoefs1(:,coef_lut(3980,860))
       !write(*,*) 'in read_camel_coef coef =',pcacoefs(:,coef_lut(3980,860))

      deallocate(pcacoefs1)
      
      

!----------------------------------------------------   
      ! closing coef file
!----------------------------------------------------   
      errstat = nf_close(ncid)


      END SUBROUTINE read_CAMEL_clim_coef_masked













