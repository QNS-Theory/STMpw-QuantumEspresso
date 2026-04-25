# Only line you need to update to point to the
# main directory of Quantum Espresso (QE)
# you might have to update the libraries called here
# if there are new libraries in QE

TOPDIR        = /usr/local/qe-7.5/src/
MPIF90        = mpiifort
#FC           = ifort
FC            = mpiifort
F77           = ifort

FLAGS =  -O 

MOD_FLAG      = -I

BASEMOD_FLAGS= $(MOD_FLAG)$(TOPDIR)/upflib \
               $(MOD_FLAG)$(TOPDIR)/XClib \
               $(MOD_FLAG)$(TOPDIR)/Modules \
               $(MOD_FLAG)$(TOPDIR)/FFTXlib \
               $(MOD_FLAG)$(TOPDIR)/FFTXlib/src \
               $(MOD_FLAG)$(TOPDIR)/LAXlib \
               $(MOD_FLAG)$(TOPDIR)/UtilXlib \
               $(MOD_FLAG)$(TOPDIR)/MBD \
               $(MOD_FLAG)$(TOPDIR)/KS_Solvers \
               $(MOD_FLAG)$(TOPDIR)/dft-d3/ \
               $(MOD_FLAG)$(TOPDIR)/PW/src/ \
               $(MOD_FLAG)$(TOPDIR)/external/devxlib/src 

# Added dft-d3/libdftd3qe.a to PWOBJS as required by QE 7.5
PWOBJS = $(TOPDIR)/PW/src/libpw.a \
         $(TOPDIR)/KS_Solvers/libks_solvers.a \
         $(TOPDIR)/dft-d3/libdftd3qe.a

# Replaced loose object files with libupf.a and updated libqefft.a path
QEMODS = $(TOPDIR)/Modules/libqemod.a \
         $(TOPDIR)/upflib/libupf.a \
         $(TOPDIR)/FFTXlib/src/libqefft.a \
         $(TOPDIR)/LAXlib/libqela.a \
         $(TOPDIR)/UtilXlib/libutil.a \
         $(TOPDIR)/MBD/libmbd.a \
         $(TOPDIR)/XClib/xc_lib.a \
         $(TOPDIR)/external/devxlib/src/libdevXlib.a

MODULES = $(PWOBJS) $(QEMODS)

LIBOBJS        =

BLAS_LIBS      =   -L$(MKLROOT)/lib/intel64/ -lmkl_intel_lp64  -lmkl_sequential -lmkl_core
LAPACK_LIBS    =  $(MKLROOT)/lib/intel64/libmkl_blacs_intelmpi_lp64.a
SCALAPACK_LIBS = -lmkl_scalapack_lp64 -lmkl_blacs_intelmpi_lp64

FFT_LIBS       =  -L/opt/fftw3/fftw-3.3.10/lib -lfftw3

# Emptied FOX_LIB since QE 7.5 uses a built-in replacement instead of the external FoX library
FOX_LIB      = 
BEEF_LIBS    = 

QELIBS         = -qmkl $(SCALAPACK_LIBS) $(LAPACK_LIBS) $(FOX_LIB) $(FFT_LIBS) $(BLAS_LIBS) $(BEEF_LIBS) $(LD_LIBS)

OBJ =   declaration.o declfft.o  \
	volumen.o Fourier.o currentBardeen.o  \
	STMpw.o 

STMpw.out: $(OBJ)
	$(FC) $(FLAGS) $(OBJ) $(TOPDIR)/PP/src/libpp.a $(MODULES) $(LIBOBJS) $(QELIBS) -o STMpw.out

utils: Imagen_Bardeen_gnu.out Cond_gnu.out

all: utils STMpw.out

Imagen_Bardeen_gnu.out: 
	$(FC) $(FLAGS) Utils/Imagen_Bardeen_gnu.f90 -o Utils/Imagen_Bardeen_gnu.out

Cond_gnu.out:
	$(FC) $(FLAGS) Utils/Cond_gnu.f90 -o Utils/Cond_gnu.out

Fourier.o: Fourier.f90
	$(FC) Fourier.f90 $(FLAGS) -c

declaration.o: declaration.f90
	$(FC) declaration.f90 $(FLAGS) -c

declfft.o: declfft.f90
	$(FC) declfft.f90 $(FLAGS) -c

determinequantities.o: determinequantities.f90
	$(FC) determinequantities.f90 $(FLAGS) -c

currentBardeen.o: currentBardeen.f90
	$(FC) currentBardeen.f90 $(FLAGS) -c

volumen.o: volumen.f90
	$(FC) volumen.f90 $(FLAGS) -c

STMpw.o: STMpw.f90
	$(FC) STMpw.f90 $(BASEMOD_FLAGS) $(FLAGS) -c	

mappingscar_gen.o: mappingscar_gen.f90
	$(FC) mappingscar_gen.f90 $(FLAGS) -c	

norm_name.o: norm_name.f90
	$(FC) norm_name.f90 $(FLAGS) -c	

clean: 
	@echo "Cleaning objects..."
	rm -f *.o *.mod

cleanall: 
	@echo "Cleaning all..."
	rm -f *.o *.mod *.out */*.out
