#Auxiliary file to discover OS,pataforms and other tools
#Based on findcudalib.mk from NVIDIA cuda toolkit 5.5
#By Edgar J. 
DSCUDA_VER 	:= 1.7.5.1

# OS Name (Linux or Darwin)
OSUPPER = $(shell uname -s 2>/dev/null | tr "[:lower:]" "[:upper:]")
OSLOWER = $(shell uname -s 2>/dev/null | tr "[:upper:]" "[:lower:]")


# Flags to detect 32-bit or 64-bit OS platform
OS_SIZE = $(shell uname -m | sed -e "s/i.86/32/" -e "s/x86_64/64/" -e "s/armv7l/32/")
OS_ARCH = $(shell uname -m | sed -e "s/i386/i686/")

# Determine OS platform and unix distribution
ifeq ("$(OSLOWER)","linux")
   # first search lsb_release
   DISTRO  = $(shell lsb_release -i -s 2>/dev/null | tr "[:upper:]" "[:lower:]")
   DISTVER = $(shell lsb_release -r -s 2>/dev/null)
   ifeq ("$(DISTRO)",'') 
     # second search and parse /etc/issue
     DISTRO = $(shell more /etc/issue | awk '{print $$1}' | sed '1!d' | sed -e "/^$$/d" 2>/dev/null | tr "[:upper:]" "[:lower:]")
     DISTVER= $(shell more /etc/issue | awk '{print $$2}' | sed '1!d' 2>/dev/null
   endif
   ifeq ("$(DISTRO)",'') 
     # third, we can search in /etc/os-release or /etc/{distro}-release
     DISTRO = $(shell awk '/ID/' /etc/*-release | sed 's/ID=//' | grep -v "VERSION" | grep -v "ID" | grep -v "DISTRIB")
     DISTVER= $(shell awk '/DISTRIB_RELEASE/' /etc/*-release | sed 's/DISTRIB_RELEASE=//' | grep -v "DISTRIB_RELEASE")
   endif
endif


# Common binaries
GCC   ?= g++
#CLANG ?= /usr/bin/clang

ifeq ("$(OSUPPER)","LINUX")
     NVCC ?= /usr/local/cuda/bin/nvcc -ccbin $(GCC)
endif

# Take command line flags that override any of these settings
ifeq ($(i386),1)
	OS_SIZE = 32
	OS_ARCH = i686
endif
ifeq ($(x86_64),1)
	OS_SIZE = 64
	OS_ARCH = x86_64
	LTYPEP64 := -DLTYPEP64
endif
ifeq ($(ARMv7),1)
	OS_SIZE = 32
	OS_ARCH = armv7l
	LTYPEP64 :=
endif

ifeq ("$(OSUPPER)","LINUX")
    # Each Linux Distribuion has a set of different paths.  This applies especially when using the Linux RPM/debian packages
    ifeq ("$(DISTRO)","ubuntu")
        CUDA_PATH  		:= /usr/local/cuda
				#CUDA_SDKPATH 	:= $(CUDA_PATH)/NVIDIA_GPU_Computing_SDK
				CUDA_SDKPATH 	:= $(CUDA_PATH)/samples
				DSCUDA_PATH		:= /usr/local/DSCUDA/dscudapkg$(DSCUDA_VER)
    endif
		#For Knoppix..............
    ifeq ("$(DISTRO)","debian")
        CUDA_PATH  		:= /usr/local/cuda
				#CUDA_SDKPATH 	:= $(CUDA_PATH)/NVIDIA_GPU_Computing_SDK
				CUDA_SDKPATH 	:= $(CUDA_PATH)/samples
				DSCUDA_PATH		:= /usr/local/DSCUDA/dscudapkg$(DSCUDA_VER)
    endif
		#For Fedora..............
    ifeq ("$(DISTRO)","fedora")
        CUDA_PATH  		:= /usr/local/cuda
				#CUDA_SDKPATH 	:= $(CUDA_PATH)/NVIDIA_GPU_Computing_SDK
				CUDA_SDKPATH 	:= $(CUDA_PATH)/samples
				DSCUDA_PATH		:= /usr/local/DSCUDA/dscudapkg$(DSCUDA_VER)
endif

  # Search for Linux distribution path for libcuda.so
  CUDALIB ?= $(shell find $(CUDAPATH) $(DFLT_PATH) -name libcuda.so -print 2>/dev/null)

  ifeq ("$(CUDALIB)",'')
      $(info >>> WARNING - CUDA Driver libcuda.so is not found.  Please check and re-install the NVIDIA driver. <<<)
      EXEC=@echo "[@]"
  endif
	
	# Search for DSCUDA libraries
	#This for TPC_ONLY
  DSCUDA_LIB_TCP ?= $(shell find $(DSCUDA_PATH)/src -name libdscuda_rpc.a -print 2>/dev/null)
  DSCUDA_LIB_IBV ?= $(shell find $(DSCUDA_PATH)/src -name libdscuda_ibv.a -print 2>/dev/null)

  ifeq ("$(DSCUDA_LIB_TCP)",'')
			$(info >>> WARNING - DSCUDA Libraries are not found. <<<)
  endif 
  
ifeq ("$(DSCUDA_LIB_IBV)",'')
			$(info >>> WARNING - DSCUDA Libraries are not found. <<<)
  endif 
	

else

  # This would be the Mac OS X path if we had to do anything special
endif
##############-Print information-###################################
TEMP = @echo "Architecture:$(OSUPPER), OS:$(OS_ARCH) Platform, $(OS_SIZE) Bits, $(DISTRO)"

