      subroutine compute_clim_hsriremis( 
     & path_camel,      ! in
     & path_lab,        ! in
     & cmonth,          ! in
     & lat_site,        ! in
     & lon_site,        ! in
     & first,           ! in
     & instr_switch,    ! in
     & snow_corr,       ! in
     & debug,           ! in
     & hsriremis,       ! out
     % nchs,            ! in
     & snowfrac,          ! in, optional
     & instr_wn,        ! in, optional
     & instr_emis)      ! out, optional

c --------------------------------------------------------------------
    ! Description:
    !software to create library to compute high spectral resolution emissivity spectra 
    ! from the MEASURES CAMEL (Combined ASTER MODIS Emissivity over Land)
    !
    ! History:
    ! Version   Date     Comment
    ! -------   ----     -------
    !  0.6     05/11/2016  Original code E Borbas UW-Madison/CIMSS
    !  1.0     01/10/2017  Adjusted to the MEASUREs CAMEL products Version V001 (v01r02)
    !  3.0     10/20/2023  Adjusted to the MEASUREs CAMEL products Version V003 (v03r05)
    !                      with adding the actual snow correction
    !
    ! Code Description:
    !   Language:           Fortran 90.
    !   Software Standards: "European Standards for Writing and
    !   Documenting Exchangeable Fortran 90 Code".
    !
    !
    ! Input parameters:
    !
    !       cyear:  year
    !       cmonth: month
    !       lat_site: latitude of the pixel
    !       lon_site: longitude of teh pixel
    !       first: logical parameter if it is a first call or not
    !       instr_switch: logical parameter if the hsr shoudl be calucalted for a certain instruments
    !       snow_corr: logical parameter if adjusting to current snow condition
    !       debug: logical parameter for debuging
    !       snowfr: current snow fraction [0,1]
    !       instr_wn: optional input: central wave number of the instrument bands
    !
    ! Output parameters: 
    !       hsriremis:  hsr IR emissivity
    !       instr_emis: Emissivity calucalted for the isntrument bands
    !
    ! Calls
    !      init_hsriremis
    !      read_CAMEL_coef  
    !      recon_hsriremis            
    !      select_wavenum
    !
    ! NOTES:
    ! The logic of the land/snow emissivity calculation is as follows:
    ! if snowfrac = 1: avoid the usual (climatological) emissivity calculation, and reconstruct PC snow
    !     emissivity if available, otherwise use fixed snow spectrum
    ! if  0 < snowfrac < 1: if there is any snow among the PC spectra then return the PC climatological
    !     emissivity (this ignores the input snowfrac), otherwise return linear combination of (snow-free)
    !     climatological emissivity and fixed snow spectrum weighted by snowfrac
    !if snowfrac = 0 and snow_corr is true: if atlas climatological emissivity is snow-contaminated it
    !     tries to find a snow-free PC spectrum to use (this is done by setting the weights to zero for all
    !     PC sets and setting the weight for the snow-free set to 1 and running the emissivity calcualation
    !     as usual). If no snow-free spectrum is available or if snow_corr is false, the usual emissivity
    !     calculation is done.
 
!-------------------------------------------------------------

      Implicit None
      
      include 'hsriremis_clim_EDR.inc'

       Character (len=*) :: path_camel, path_lab

       Integer, Parameter :: nmonth=12
       Integer year, month
       integer nchs
       Integer sind,eind,icount
 
       Character (len=2) :: cmonth
       !Character (len=6) :: prd_ver
        Character (len=1) :: ctype
       
	Character*200 :: fn_emis

       INTEGER :: err, errorstatus_fatal,errorstatus_success
       INTEGER :: i, j,ii,ios, ich
       INTEGER:: gridy, gridx
       
       REAL :: lat_site, lon_site
       INTEGER :: ilat, ilon
 
        REAL*8  :: hsriremis(numwave)
        REAL*8 :: hsriremis_sum(numwave)
            
	Real*8,    Intent(in), Optional :: snowfrac
	Real*8,    Intent(in), Optional :: instr_wn(nchs)
	Real*8,    Intent(out), Optional :: instr_emis(nchs)
        
 
       LOGICAL :: file_exists
       LOGICAL :: instr_switch
       LOGICAL :: snow_corr
       LOGICAL :: first
       LOGICAL :: debug

!---------------------------------------
! check arguments

        if(debug) write(*,*) 'inputs=  ',cmonth,lat_site,lon_site,instr_switch, snow_corr, snowfrac

!----------------------------
! checking if the CAMEL coef data file exists
     
        fn_coef=TRIM(path_camel)//'CAMEL_coef_climatology_'//cmonth//'Month_V003.nc'
	Inquire(FILE=fn_coef, EXIST=file_exists)
        If (.not. file_exists) Then
           err = errorstatus_fatal
           write(*,*)  'CAMEL coef climatology file not found : ',Trim(fn_coef)
           return
        End If

!----------------------------
! checking if snow fraction is within the range [0,1]

      If (snow_corr) Then
                write(*,*) 'Snow fraction = ', snowfrac	     
	     	If (snowfrac > 1. .and. snowfrac < 0.) Then
		write(*,*) 'Snow fraction is not the [0,1] range, no snow correction will be applied'
		snow_corr=.FALSE.
		End IF
      End If      

!----------------------------
! get the grid coordinates 
 
      ilat = NInt(lat_site*1000.)
      ilon = NInt(lon_site*1000.)
    
      gridy = NInt(Abs(ygrid1-ilat)*1./gridres)+1
      gridx = NInt(Abs(xgrid1-ilon)*1./gridres)+1
              
      write(*,*) 'gridy =  ', gridy, 'gridx =  ',gridx        
       	
!----------------------------
! init isntr_emis
!	 do i=1,nchs
!	 instr_emis(i)=hkod
!         enddo
!----------------------------
! read PCS of laboratory data - init

        if(first) then
            call init_hsriremis(path_lab)

           write(*,*) 'Reading CAMEL climatology coef data: ',Trim(fn_coef)
           Call read_CAMEL_clim_coef_masked(fn_coef,pcacoefs,weights)
    
        endif
	  
        write(*,*) 'weights= ', weights(:,coef_lut(gridx,gridy))
        write(*,*) 'labvs_set = ', labvs_set
        write(*,*) 'npcs_set = ', npcs_set

        icount=0
	hsriremis_sum=0
 	
!------------------------------------
! Reading in the weights
	wgt(:)=weights(:,coef_lut(gridx,gridy))
        write(*,*) 'weights readin= ',wgt

!------------------------------------
! Making snow correction if set to true
 
        If (snow_corr) Then	     
	     	If (snowfrac >= 1) Then		   
                      If (wgt(1) > 0) Then
		        wgt=0.
			wgt(1)=1.
		     End If

	       Else If (snowfrac == 0) Then	            
	           ! Check if there are any snowy labsets (Version 12, 11 and 9): if there are, calculate emissivity
                   ! from a not-snowy set (version 10 or 8) by setting weights appropriately.
                   ! Otherwise the emissivity calculation proceeds as usual.

                   itype = 0
                    IF (wgt(1) > 0..OR.wgt(3) > 0..OR.wgt(6) > 0..OR.wgt(7) > 0.) THEN
                          IF (wgt(4) > 0.) THEN
                               ! most common not snowy lab version
                               itype = 4
                          ELSEIF (wgt(5) > 0.) THEN
                               ! carbonites
                               ! general version
                               itype = 5
                          ELSEIF (wgt(2) > 0.) THEN
                              itype = 2
                         ENDIF  

                         ! If we found a snow-free set then modify weights for emissivity calculation below
                         ! otherwise we do the emissivity calculation as usual
                         IF (itype > 0) THEN
                                 wgt(:) = 0.
                                 wgt(itype) = 1.
                        ENDIF	 
	         ENDIF       
              ENDIF
       ENDIF
       
       write(*,*) 'weights after snow corr= ',wgt
	    
!------------------------------------
!      emis calculation
	
	Do itype=1,nset   
             labvs=labvs_set(itype)
             npcs=npcs_set(itype)

             if(debug)write(*,*) 'itype= ', itype
             if(debug)write(*,*) 'labvs=     ',labvs
             if(debug)write(*,*) 'numberpcs= ',npcs
             if(debug)write(*,*) 'lat_site= ', lat_site
             if(debug)write(*,*) 'lon_site= ', lon_site
             if(debug)write(*,*) 'gridx=    ', gridx
             if(debug)write(*,*) 'gridy=    ', gridy
!             if(debug)write(*,*) 'lmask= ',lsmask(gridy,gridx)
             if(debug)write(*,*) 'lmask= ',lsmask(gridx,gridy)
             if(debug)write(*,*) 'weights= ',wgt(itype)
!            if(debug)write(*,*) 'instr_emis_flag= ',instr_emis_flag
                		 
	      if (itype.eq.1) then 
	           sind=1
	           eind=npcs
		   else
	           sind=eind+1
	           eind=sind+npcs-1
              endif
	      
	      !write(*,*) itype,labvs,npcs,sind, eind

              coeff = 0.
	      coeff= pcacoefs(sind:eind,coef_lut(gridx,gridy))
	      
	      if (wgt(itype).gt.0.) then 	      
	           icount=icount+1		   
		   hsriremis=0.
		           
                  !----------------------------
                  ! calcualte hsr emis
	
 	         !write(*,*) 'hsriremis before = ', itype, wgt(itype),npcs,labvs,coeff
                 call recon_hsriremis( npcs,labvs,coeff,hsriremis,icount)   
	          
                  if(debug)  then 		  
		         !write(*,*) 'hsriremis = ',hsriremis 
	                 ! write(*,*) 'hsriremis after = ', itype, wgt(itype), npcs,labvs,hsriremis 
                         write(ctype,'(i0)') itype
		         write(*,*) 'CTYPE=  ',ctype
		  
		         fn_emis='emis'//ctype//'.txt'
		         OPEN(3, file=fn_emis, status='unknown', iostat=ios)
                         do ich=1,numwave
                              write(3,*)  hsr_wavenum(ich), hsriremis(ich)
                        enddo
                        close(3)		  
		  endif
        
	         !----------------------------
                  ! calcualte the weighted mean
	    
	           Do ii=1,numwave
		   hsriremis_sum(ii)=hsriremis(ii)*wgt(itype)+hsriremis_sum(ii)
		   End Do
            End If ! wgt
      Enddo! itype

      hsriremis=hsriremis_sum

      If (snow_corr) Then
	       	If (snowfrac >=1. .and. wgt(1) == 0 ) Then
  	              ! use laboratory snow emissivity        
	              hsriremis(:) = snow_emis_init(:)
		      write(*,*) 'Lab snow emis is used! '
		End If
		
		If (snowfrac > 0. .and. snowfrac < 1.) Then
                     ! if there is no snowy type in the climatological database (Version 12, 11 and 9), 
		     ! emis is blended with the fixed lab snow spectra, otherwise keep CAMEL emis

                     IF (wgt(1) == 0..AND.wgt(3) == 0..AND.wgt(6) == 0..AND.wgt(7) == 0.) THEN
                             hsriremis(:) = snowfrac * snow_emis_init(:) + (1.- snowfrac) * hsriremis(:)
 		             write(*,*) 'Blended emis is used! '
                    ENDIF		         	 
	 	End If	   
      End If  ! snow_corr		   
           
      !-------------------
      !Checking for emis > 1
       Do j=1,numwave
                If ( hsriremis(j) > 1.) hsriremis(j) = 1.                        
      End Do
	           
    !----------------------------
    ! calcualte instr emis of isntr_switch is TRUE

       If (instr_switch) Then  	  	       
             call select_wavenum( hsriremis,nchs,instr_wn,instr_emis)   	
       End If   ! Instr_switch
             		 
      End Subroutine compute_clim_hsriremis
 
