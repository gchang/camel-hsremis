
   MEASURES High Spectral Resolution Emissivity Algorithm 
   CAMEL Climatology V003
   Fortran Library
   
   Created: Eva Borbas, UW-MAD, SSEC/CIMSS 
   
   Contact: eva.borbas@ssec.wisc.edu
   
   Date: March, 2024
   
   Version V3.0 (v03r05): 
---------------------------------------------------------------------------------- 
 
     The package contains a software to create a Fortran library to calculate 
     High Spectral Resolution (HSR) emissivity developed under the NASA MEASURES program called: 
     Unified and Coherent Land Surface Temperature and Emissivity (LST&LSE) Earth System Data Record (ESDR). 
     The software runs on the version 3.0 (V003 / v03r05) CAMEL Climatological emissivity coefficients data. 
     It also contains a sample program for users to understand how to run the algorithm. 
     
     This package also includes an optional snow fraction correction. Read more about it in 
     Chapter 3 of the EUMETSAT NWP-SAF report: 
                   https://nwp-saf.eumetsat.int/publications/vs_reports/nwpsaf-mo-vs-058.pdf     
 --------------------------------------------------------------------------------- 
  
Install the package: 

      1. download the package from: 
	https://bin.ssec.wisc.edu/pub/ICI/MEASURES_V003/hsremis_clim/MEASURES_CAMEL_CLIMAT_hsremis_lib_snowCorr_V003.tar.gz
	2. unzip and tar it. 
	3. a git copy of this package has no data folder (384 MB). The test reads only
	   data/CAMEL_coef_climatology_01Month_V003.nc (196 MB). Copy it from the data folder of
	   https://lpdaac.usgs.gov/documents/2234/FORTRAN_Source_Code.tar.gz (the same package at LP DAAC),
	   or download the LP DAAC granule (Earthdata login) and save it under that name:
	   https://data.lpdaac.earthdatacloud.nasa.gov/lp-prod-protected/CAM5K30CFCLIM.003/CAM5K30CFCLIM_coef_climatology_01Month_V003/CAM5K30CFCLIM_coef_climatology_01Month_V003.nc
	   Other months are the CAM5K30CFCLIM granules for 02 to 12; the library looks for
	   CAMEL_coef_climatology_<MM>Month_V003.nc in camel_dir, so rename or link them to that name.
	   The emissivity and uncertainty files are the CAM5K30EMCLIM and CAM5K30UCCLIM granules.


Software package contains: 

       src_hsrlib_clim - contains Fortran algorithm 
       lib - will contain the "libhsriremis_clim_V003.a" after installation
       coef - contains all the laboratory eigenvector and eigenvalues in netcdf files
       include - contains the hsriremis_clim_EDR.inc 
       data - includes one CAMEL coefficient file for test purposes
       test - includes a test code (run_hsriremis.f) to run on three geographical locations
 

Software requirement: netcdf4 library (gcc)  -  "module load gcc hdf hdf5 netcdf4" on the SSEC computers
                      or with conda: "conda env create -f environment.yml"; that file shows the make lines to use
                             
Create the HSR emis library:     

       1. cd src_hsrlib_clim
             
       2. make -f Makefile_lib clean
       
       3. make -f Makefile_lib
       
       4. make -f Makefile_lib install

Test code for the HSR emis library:

       1. cd test
       
       2. edit the netcdf inc and lib directory links in the Makefile 
       
       3. edit and save the code: chose month, add the path of the lab coefficients and the CAMEL input data, choose a location to test
                                  and if you wish, turn on snow_flag and add snow fraction for snow correction    
                cmonth='01'
                lab_dir='../coef/'
                camel_dir='../data/'
		lat_site= 45.67   
                lon_site= -89.4
	        site_name='NorthMadW'
		snowfr=1.
                snow_flag=.TRUE.
		              
       4. run: make clean  
       
       5. run: make
              
       6. run: ./run_hsriremis.exe
       
       7. compare results found in the save_results directory: 
             such as Namib_iasi_emis.txt Namib_iasi_emis.txt

	 
List of the directories : 

src_hsrlib_clim:
	compute_clim_hsriremis.f
	hsriremis_clim_EDR.inc
	init_hsriremis.f
	Makefile_lib
	read_CAMEL_clim_coef.f
	read_CAMEL_clim_coef_masked.f
	read_labpcs.f
	recon_hsriremis.f
	select_wavenum.f

test:
 	iasi_chans616.txt
	run_hsriremis.f
	Makefile
	save_results     
		MadisonW_hsremis.txt
		MadisonW_iasi_emis.txt
		Namib_hsremis.txt
		Namib_iasi_emis.txt
		Yemen_hsremis.txt
		Yemen_iasi_emis.txt		
coef:
	pchsr_v10.2.nc
	pchsr_v11.2.nc
	pchsr_v12.2.nc
	pchsr_v9.2.nc
	pchsr_v8.2.nc

data:	       
       CAMEL_coef_climatology_01Month_V003.nc
       CAMEL_emis_climatology_01Month_V003.nc
       CAMEL_uncertainty_climatology_01Month_V003.nc
lib:
       none
       
include: 
       none
              
