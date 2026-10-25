      SUBROUTINE  read_CAMEL_clim_coef(fn_coef,pcacoefs)
      
      
    ! Description:
    ! read the 0.05 degree resolution MEASURES CAMEL (Combined ASTER MODIS Emissivity over Land)
    ! from the netCDF file into memory. 
    ! 
    ! History:
    ! Version   Date     Comment
    ! -------   ----     -------
    !   0.6     05/11/2016  Original code E Borbas UW-Madison/CIMSS
    !   1.0     01/10/2017  Adjusted to the MEASUREs CAMEL products Version V001 (v01r02)
    !
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
      Integer*4 :: nc_dim(4) !  lats, lons,hng_pnt, pack_leng
      INTEGER:: gridy, gridx
      
      real :: latitude(3600)
  
      Integer    :: i,j,k,l, eline
      Integer*4 :: ncid, ngatts, nrecs, varid,varid2
                      
      Character (len=1024) :: strbuf ! string buffer for var
      Character (len=6)    :: cfld 
      Integer*4  :: indexlut

!----------------------------------------------------   	  
    ! Open netCDF file.
!----------------------------------------------------   	  
 
      errstat = nf_open(Trim(fn_coef),nf_nowrite,ncid)      

!----------------------------------------------------   	  
    ! Get info on the record dimension for this file. 
!----------------------------------------------------   	  
!      errstat = nf_inq_dimid(file_id, 'latitude', dimid)
!      errstat = nf_inq_dimlen(file_id, dimid, nb_lats)
!      errstat = nf_inq_dimid(file_id, 'longitude', dimid)
!      errstat = nf_inq_dimlen(file_id, dimid, nb_lons)
!      errstat = nf_inq_dimid(file_id, 'number_of_coef_sets', dimid)
!      errstat = nf_inq_dimlen(file_id, dimid, nset)
!      errstat = nf_inq_dimid(file_id, 'total_number_of_coefs', dimid)
!      errstat = nf_inq_dimlen(file_id, dimid, ncoef)

              write(*,*) 'nb_lats: ', nb_lats
              write(*,*) 'nb_lons: ', nb_lons
              write(*,*) 'nset: ', nset
              write(*,*) 'ncoef: ', max_npcs
                  
!----------------------------------------------------   	  
    ! Retrieve emissivity database flag value
!----------------------------------------------------   
      errstat = nf_inq_varid (ncid, 'labvs_of_coef_set', varid)
      errstat = nf_get_var_int2(ncid,varid,labvs_set)
      
      errstat = nf_inq_varid (ncid, 'npcs_of_coef_set', varid)
      errstat = nf_get_var_int2(ncid,varid,npcs_set)

      errstat = nf_inq_varid (ncid, 'landflag', varid)
      errstat = nf_get_var_int2(ncid,varid,lsmask)
           
!----------------------------------------------------   	  
    ! Retrieve verson number of pcs of laboratory data
!----------------------------------------------------   

      errstat = nf_inq_varid (ncid, 'pc_coefs', varid)
      errstat = nf_get_var_double(ncid,varid,pcacoefs)
      
!----------------------------------------------------   	  
    ! Retrieve number of PCS for each pixels
!----------------------------------------------------   

      errstat = nf_inq_varid (ncid, 'pc_coef_weights', varid)
      errstat = nf_get_var_real(ncid,varid,weights)
       
 !----------------------------------------------------   	  
    ! Retrieve number of PCS for each pixels
!----------------------------------------------------   

!      errstat = nf_inq_varid (ncid, 'pc_coef_nsamps', varid)
!      errstat = nf_get_var_int1(ncid,varid,nsamps_set)
       

!----------------------------------------------------   
      ! closing coef file
!----------------------------------------------------   
      errstat = nf_close(ncid)


      END SUBROUTINE read_CAMEL_clim_coef













