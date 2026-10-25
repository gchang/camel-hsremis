      SUBROUTINE recon_hsriremis( numpcs,labvs,coef,hsriremis,is)                         
          
    ! Description:
    ! To creates high spectra resolution emissivties at 417 wavenumbers
    ! from the MEASURES CAMEL emissivity database (at 13 hinge points) 
    ! and labratory measurements using principal component analyses
    !
    !
    ! History:
    ! Version   Date     Comment
    ! -------   ----     -------
    !           03/31/2009  Original code E Borbas UW-Madison/CIMSS
    !           03/31/2009  New F90 code with structures (E Borbas B Ruston)
    !           05/06/2016  Adjusted to the MEASUREs CAMEL products
    !   1.0     01/10/2017  Adjusted to the MEASUREs CAMEL products Version V001 (v01r02)
    !   1.0(r04)07/11/2018  modified for adding Version 9 and 11 lab datasets 
    !
    ! Code Description:
    !   Language:           Fortran 90.
    !   Software Standards: "European Standards for Writing and
    !     Documenting Exchangeable Fortran 90 Code".
    !
          
  
      Implicit None
 
      include 'hsriremis_clim_EDR.inc'

      Integer :: j,k, numpcs,is
  
      Real*8 :: coef(numpcs) 
      Real*8 :: emis(numwave) 
      Real*8 :: hsriremis(numwave)
      Real*8 :: pcu(numwave,numwave)
      real*8:: pcm(numwave)
      
!      write(*,*) 'inuts for recon_hsremis = ', numpcs,labvs,coef
  
!       pcu=hkod
!       pcm=hkod
!       coef=hkod
       
    !-----------------------------------
    ! apply regcoef to get the hsr dataset
    !-----------------------------------
    
       if(labvs.eq.10) then 
                  pcu=pc_hsr_v10
                  pcm=pcm_hsr_v10
		  !write(*,*) 'labvs = ', labvs
       endif		  
		  
       if(labvs.eq.8) then 
                  pcu=pc_hsr_v8
                  pcm=pcm_hsr_v8
		  !write(*,*) 'labvs = ', labvs
       endif		  

       if(labvs.eq.12) then 
                  pcu=pc_hsr_v12
                  pcm=pcm_hsr_v12
		  !write(*,*) 'labvs = ', labvs
       endif		  
  
        if(labvs.eq.9) then 
                  pcu=pc_hsr_v9
                  pcm=pcm_hsr_v9
		  !write(*,*) 'labvs = ', labvs
       endif		  

        if(labvs.eq.11) then 
                  pcu=pc_hsr_v11
                  pcm=pcm_hsr_v11
		  !write(*,*) 'labvs = ', labvs
       endif		  
 
       emis=0.
         
       If ( coef(1) .ne. 0. ) Then
  
            Do k=1,numwave
            Do j=1,numpcs
!                  emis(k) = emis(k) + coef(j) * Real(pcu(j,k))
!                  emis(k) = emis(k) + coef(j) * Real(pcu(j,numwave+1-k))
                  emis(k) = emis(k) + coef(j) * (pcu(j,numwave+1-k))
		  
		  
            End Do
  
!      flip pcm and pcu
!             emis(k) = emis(k) + pcm(k)
              emis(k) = emis(k) + pcm(numwave+1-k)
  
            End Do
	    
!	    write(32,*) pcm
! 	    Do k=1,numwave
!	       if(is.eq.1) then 
!	       write(33,'(7f10.4)') pcu(1,k), pcu(2,k),pcu(3,k),pcu(4,k),pcu(5,k),pcu(6,k),pcu(7,k)
!	       else
!	       write(34,'(7f10.4)') pcu(1,k), pcu(2,k),pcu(3,k),pcu(4,k),pcu(5,k),pcu(6,k),pcu(7,k)
!	       endif
!	    Enddo
	    
	    
  
    !--------------------------------------------
    !  filter out emissivty values larger then 1.
    !--------------------------------------------
  
            Do j=1,numwave
                If ( emis(j) > 1.) emis(j) = 1.                        
!                hsriremis(j) = emis(j)
               hsriremis(numwave+1-j) = emis(j)
            End Do
          
       Else
                  
            coef = 0.
            hsriremis = 0.
              
       EndIf
                  
       END SUBROUTINE recon_hsriremis
  
