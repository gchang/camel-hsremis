      program run_hsriremis

!-------------------------------------------------------------
    ! Description:
    ! program to test the software to create library to compute high spectral resolution emissivity spectra
    ! from the MEASURES CAMEL (Combined ASTER MODIS Emissivity over Land)  
    !
    ! History:
    ! Version   Date     Comment
    ! -------   ----     -------
    !  2.1       05/11/2016  Original code E Borbas UW-Madison/CIMSS
    !            01/11/2016  Adpoted for MEASURES CAMEL Version 1.0
    !  3.05      10/10/2023  Updated for CAMEL Version V003
    !  3.05      10/20/2023  Snow correction is added
    !
    ! Code Description:
    !   Language:           Fortran 90.
    !   Software Standards: "European Standards for Writing and
    !   Documenting Exchangeable Fortran 90 Code".
    !
    !
    !   compile bash ./run_hsriremis_oneline.mk
!-------------------------------------------------------------

       Implicit None
      
       include 'hsriremis_clim_EDR.inc'

       Integer, Parameter :: nmonth=12
       Integer year, month
 
       Character (len=4) :: cyear
       Character (len=2) :: cmonth
       Character (len=400) :: camel_dir, lab_dir
       Character (len=10) :: site_name
       Character (len=70) :: site_fn1, site_fn2

       INTEGER :: err, errorstatus_fatal,errorstatus_success
       INTEGER :: i, j,ii, ios
       INTEGER:: gridy, gridx
       INTEGER :: ind1, ind2, ich, nchs
       
       REAL :: lat_site, lon_site
       REAL :: fwn,fwl
       REAL*8 :: snowfr
       INTEGER :: ilat, ilon

       REAL*8  :: hsriremis(numwave)
        REAL  :: hsrwnum(numwave)
      
        REAL,  ALLOCATABLE :: iasi_wavenum(:)          
        REAL,  ALLOCATABLE :: instr_wavenum(:)          
        REAL*8,  ALLOCATABLE :: instr_emis(:)          
      
       LOGICAL :: file_exists
       LOGICAL :: instr_switch= .TRUE.
       LOGICAL :: first
!       LOGICAL :: debug= .TRUE.
       LOGICAL :: debug= .FALSE.
       LOGICAL :: snow_flag=.FALSE.

!!__________________________
!!   SET UP INPUTS
!!__________________________   
       cmonth='01'
       camel_dir='../data/'
       lab_dir='../coef/'
       snowfr=1.
       snow_flag=.TRUE.
                
!!---------------------------
! Read locations
 
         !lat_site = -24.24 
	 !lon_site = 15.24  
	 !site_name='Namib'
         
	 !lat_site = 19.15 
	 !lon_site = 55.57   
	 !site_name='Yemen' 
                
	 !lat_site= 43.07   
         !lon_site= -89.4
	 !site_name='MadisonW'
	 
	 lat_site= 45.67   
         lon_site= -89.4
	 site_name='NorthMadW'
	 
!!___________________________
!!  END OF INPUTS   
!!---------------------------

!----------------------------
! Read instrument cwns

        ich=0
        OPEN(333, file='iasi_chans616.txt', status='old', iostat=ios)
       
        READ(333,*,iostat=ios) ind1, ind2 , fwn, fwl
	!write(*,*)ind1, ind2 , fwn, fwl 
         Do WHILE (ios == 0 )
             ich = ich + 1
             READ(333,*,iostat=ios) ind1, ind2, fwn, fwl
	     !write(*,*)ind1, ind2 , fwn, fwl 
         ENDDO
	 rewind(333)
         CLOSE(333)
	 nchs=ich
	 write(*,*) 'nchs= ', nchs

        allocate(iasi_wavenum(nchs))
        allocate(instr_wavenum(nchs))
        allocate(instr_emis(nchs))

        OPEN(333, file='iasi_chans616.txt', status='old', iostat=ios)
        
	do i=1,nchs
	     READ(333,*,iostat=ios) ind1, ind2 , fwn, fwl
             iasi_wavenum(i) = fwn
        ENDDO
        CLOSE(333)
 	  
        instr_wavenum=iasi_wavenum
	
	do i=1,numwave
	  hsrwnum(i) = 698. +(i-1)*5.
	  !write(*,*) i, hsrwnum(i)	
        enddo	  
		
!-------------------------------------------
!     calculate emissivty for the frequencies of the instrument
!--------------------------------------------

	 write(*,*) cyear,cmonth,lat_site,lon_site,prd_version
     
         first=.false.      
         ii=1
         if (ii.eq.1) first=.true.
	 hsriremis(:)= HKOD
	 instr_emis= HKOD
	
	call compute_clim_hsriremis(camel_dir,lab_dir,
     &	cmonth,lat_site,lon_site,first,instr_switch,snow_flag,debug,hsriremis,nchs,snowfr,instr_wavenum,instr_emis)
    
!-------------------------------------------
!     write out results
!-------------------------------------------
        	
        site_fn1=Trim(site_name)//'_iasi_emis.txt'
	OPEN(36, file=Trim(site_fn1), status='unknown', iostat=ios)
        do i=1,nchs
               write(36,*)  instr_wavenum(i), instr_emis(i)
        enddo
        close(36)
         	
       site_fn2=Trim(site_name)//'_hsremis.txt'
       OPEN(37, file=trim(site_fn2), status='unknown', iostat=ios)
       do i=1,numwave
               write(37,*) hsrwnum(i), hsriremis(i)
        enddo
       close(37)
	
		
	 Stop
	 End
