!         SUBROUTINE init_hsriremis(fn_coef)
         SUBROUTINE init_hsriremis(path_lab)
	 
    ! History:
    ! Version   Date     Comment
    ! -------   ----     -------
    !   0.6     05/11/2016  Original code E Borbas UW-Madison/CIMSS
    !   1.0(r04)07/11/2018  modified for adding Version 9 and 11 lab datasets 
    !
    ! Code Description:
    !   Language:           Fortran 90.
    !
	 Implicit none
         include 'hsriremis_clim_EDR.inc'
	 
	 integer i, numchs
         	 
    !--------------------------------------------------       
    ! read lab PCS files
    !--------------------------------------------------    
       
       call read_labpcs(path_lab,'9  ')
       call read_labpcs(path_lab,'11 ')
       call read_labpcs(path_lab,'12 ')
       call read_labpcs(path_lab,'10 ')
       call read_labpcs(path_lab,'8  ')
	
    !--------------------------------------------------       
    ! create hsr_wavenum array
    !--------------------------------------------------    
    !  hsr_wavenum = 2778:-5:694 (698) 	
	
	do i=1,numwave
	  hsr_wavenum(i) = 698. +(i-1)*5.
	  !write(*,*) i, hsr_wavenum(i)	
        enddo	  

    !---------------------------------------------------
    ! pc_coef initialization
    !---------------------------------------------------
    
!        pc_labvs = 0
!        pc_npcs = 0
!	snowf=-999.
!	pcacoefs=-999.
    
    
!      call get_mask_dim(fn_coef)
!      write(*,*) 'nmask=',nmask      
!      allocate(pc_labvs(nb_pack))
!      allocate(sf(nb_pack))
!      allocate(pc_npcs(nb_pack))
!      allocate(pcacoefs(wout_npcs,nb_pack))
     
    
      END SUBROUTINE init_hsriremis
