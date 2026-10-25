#------------------------------------------------
# FORTRAN Makefile  
# for the test "run_hsriremis.f" program
# 
# Created by  Eva Borbas UW-Madison SSEC/WISC 
#
#  Version history: 
#             may 2016  Support version: V0.6
#             March 2024	Update for V003 (3.05)
#
#
# !!!!!
#Need to update 
#    $(SSEC_NETCDF4_INC)
#    $(SSEC_NETCDF4_LIB)
# for the local netdcdf4 libraries
#------------------------------------------------
#------------------------------------------------

INC = -I$(SSEC_NETCDF4_INC) -I../include
LIB = -L$(SSEC_NETCDF4_LIB) -lnetcdff -L../lib/ -lhsriremis_clim_V003 

TARGET = run_hsriremis.exe
     
# Object file names

OBJS = \
run_hsriremis.o 


# Compiler names

F90 = gfortran

F90FLAGS = -O2 -mcmodel=large -ffixed-line-length-none -frecord-marker=4 
#F90FLAGS = -g -mcmodel=large -ffixed-line-length-none -frecord-marker=4 
 
 
#LINK_FLAGS = -Bstatic
#LINK_FLAGS = -static

#----------------------------------------
# No edits are necessary after this point
#----------------------------------------

# Rules

$(TARGET):        $(OBJS)
	$(F90) -o $@ $(LINK_FLAGS) $(OBJS) $(LIB) 

clean:
	/bin/rm -f *.o *.exe

.SUFFIXES: .o .c .f

.f.o:
	$(F90) -c $(F90FLAGS) $(INC) $<
