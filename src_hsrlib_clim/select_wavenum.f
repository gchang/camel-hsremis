      SUBROUTINE select_wavenum ( hsremis,nchs,instr_wavenum,instr_emis)       
  
    ! Description:
    ! subroutine to find the closest wavenumber from the MEASURES CAMEL HSR emissivity spectra 
    ! for the instrument frequency and assign the instrument emissivity by choosing the 
    ! closest spectral point value or bilinear interpolating  between the two 
    ! closest spectral point values
    !
    !
    ! History:
    ! Version   Date     Comment
    ! -------   ----     -------
    !           03/31/2009  Original code E Borbas UW-Madison/CIMSS
    !           03/31/2009  New F90 code with structures (E Borbas B Ruston)
    !   0.6     05/06/2016  Adjusted to the MEASUREs CAMEL products
    !   1.0     01/10/2017  Adjusted to the MEASUREs CAMEL products Version V001 (v01r02)
    !
    ! Code Description:
    !   Language:           Fortran 90.
    !   Software Standards: "European Standards for Writing and
    !     Documenting Exchangeable Fortran 90 Code".
    !
              
      include 'hsriremis_clim_EDR.inc'

      Integer, Intent(in) :: nchs
  
      Real*8, Intent(in) :: hsremis(numwave)
      !Real, Intent(in) :: emis_cov(numwave)
      Real, Intent(in) :: instr_wavenum(nchs)
  
      Real*8, Intent(out) :: instr_emis(nchs)
      !Real, Intent(out) :: instr_emis_cov(nchs)
  

      Integer :: j,k
  
      Real :: dist(numwave)
      Real :: mindist(nchs)
      Integer :: ind_mindist(nchs)
          
      Real :: dwvnum1,dwvnum2,dwvsum
      Real*8 :: hsremis1,hsremis2
      !Real*8 :: emis_cov1,emis_cov2
      Logical :: lcpu_emis, lcpu_cov
  
      !Real :: hkod = -999.
  
    ! initialize instrument emissivity
    
    !---------------------------------------------------------------
    ! finindg the closest frequency from the hsr emissivity spectr
    !--------------------------------------------------------------
      lcpu_emis = .True.
      lcpu_cov  = .True.
      If ( All(hsremis == hsremis(1)) ) lcpu_emis = .False.
      !If ( All(emis_cov == emis_cov(1)) ) lcpu_cov  = .False.
              
      If (lcpu_emis .or. lcpu_cov) Then           
        instr_emis(:)       = hkod
        !instr_emis_cov(:)   = hkod
        Do j=1,nchs
       
          If(instr_wavenum(j) <= hsr_wavenum(1)) Then

            instr_emis(j)=hsremis(1)
            !instr_emis_cov(j)=emis_cov(1)

          Elseif(instr_wavenum(j) >= hsr_wavenum(numwave)) Then     

            instr_emis(j)=hsremis(numwave)
            !instr_emis_cov(j)=emis_cov(numwave)

          Else ! within wavenumber compute range

            mindist(j) = 100.
            ind_mindist(j) = 100000
                                                  
            Do k=1,numwave
  
              ! calucalte distances between the instr freq end hsr emissivities                             
              dist(k) = abs( instr_wavenum(j) - hsr_wavenum(k) )
        
              ! finding the closest frequency from the hsr emissivity 
              If( dist(k) <=  mindist(j) ) Then
        
                mindist(j) = dist(k)
                ind_mindist(j) = k
        
              End If
            End do
  
    !--------------------------------
    ! assign instrument emissivity
    !-------------------------------- 
    !  closest spectral point
    !                       instr_emis(j)=hsremis(ind_mindist(j))
    !                       instr_emis_cov(j)=cov_emis(ind_mindist(j))
    
    ! or bilinear mean of the two closest spectral points
  
            k=1 
            dwvnum1=0.
            dwvnum2=0.
            hsremis1=0.
            hsremis2=0.
            emis_cov1=0.
            emis_cov2=0.
  
            If ( instr_wavenum(j) <= hsr_wavenum(ind_mindist(j)) ) k=-1

              dwvnum1 = dist( ind_mindist(j) )
              dwvnum2 = dist( ind_mindist(j) + k )
              dwvsum = dwvnum1 + dwvnum2

            If ( lcpu_emis ) Then
              hsremis1 = dwvnum1 * hsremis( ind_mindist(j) + k )
              hsremis2 = dwvnum2 * hsremis( ind_mindist(j) )
              instr_emis(j) = ( hsremis1 + hsremis2 ) / dwvsum
            Else
              instr_emis(j) = hsremis(1)
            End If

          !If ( lcpu_cov ) Then
          !  emis_cov1 = dwvnum1 * emis_cov( ind_mindist(j) + k )
          !  emis_cov2 = dwvnum2 * emis_cov( ind_mindist(j) )
          !  instr_emis_cov(j) = ( emis_cov1 + emis_cov2 ) / dwvsum
          !Else
          !  instr_emis_cov(j) = emis_cov(1)
          !End If
   
          End If    !==  (instr_wavenum(j) <= hsr_wavenum(1)) 
  
        End Do
  
      Else  ! all logical computes (lcpu_emis, lcpu_cov) are false
        instr_emis(:)=hsremis(1)
        !instr_emis_cov(:)=emis_cov(1)
      End If
  
      END SUBROUTINE select_wavenum
  
