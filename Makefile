#DS-CUDA SDK Template makefile #
#By Edgar J.                   #
################################

#Makefiles Includes..................
include aux.mk

#General Paths........................
#CUDA..............................
CUDA_PATH       ?= /usr/local/cuda
CUDA_SDKPATH    ?= $(CUDA_PATH)/samples
NVCC						?= $(CUDA_PATH)/bin/nvcc
#DSCUDA............................
DSCUDA_PATH			?= /usr/local/DSCUDA/dscudapkg$(DSCUDA_VER)
DSCUDA_SDKPATH	?= $(DSCUDA_PATH)/sample
DSCUDA_CPP			?= $(DSCUDA_PATH)/bin/dscudacpp
#Others............................
CPP							?= g++

#Libraries...........................
ifeq ($(OS_SIZE),64)
	OS_SIZE_LIB 	:= lib64
	CUTIL_SIZE		:= x86_64
endif
ifeq ($(OS_SIZE),32)
	OS_SIZE_LIB 	:= lib
	CUTIL_SIZE		:= i386 
endif

#CUDA........................
CUDA_LIB_DIR		:= 
CUDA_LIB				:= -lcudart -lcutil_$(CUTIL_SIZE) 
#DSCUDA......................
DSCUDA_LIB_DIR	:= -L$(DSCUDA_PATH)/lib
CONNECT_TCP     := $(DSCUDA_PATH)/lib/libdscuda_tcp.a
CONNECT_IBV     := $(DSCUDA_PATH)/lib/libdscuda_ibv.a
#Others......................
GL_LIB					:= -lglut -lGL -lGLU
IBV							:= -lrdmacm -libverbs -lpthread
#Includes............................
#CUDA
CUDA_INC				:= -I$(CUDA_PATH)/include -I$(CUDA_SDKPATH)/common/inc 
#DSCUDA......................
DSCUDA_INC			:= -I. -I$(DSCUDA_PATH)/include/common/inc
#Others......................
GL_INC					:= -I$(CUDA_SDKPATH)/common/inc 

#Specific Flags......................
#CUDA........................
CUDA_FLAGS			:= --cudart=shared -use_fast_math

#DSCUDA......................
CONNECT_LIB			:= $(DSCUDA_PATH)/lib/libdscuda_$(DSCUDA_LIB_TYPE).a
PERF_FLAG				:= 

#Others......................
OPENMP					:= -Xcompiler -fopenmp

#,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
#--------------------------------------
#.........GLOBAL VARIABLES.............
LIB							:=   
LIBDIR					:= $(CUDA_LIB_DIR) $(DSCUDA_LIB_DIR) 
INC							:= $(CUDA_INC) $(DSCUDA_INC)
FLAGS						:= $(CUDA_FLAGS)  

###########...Main Body...#############
TARGET = bandwidth

all: $(TARGET)_native

$(TARGET)_tcp: $(TARGET).cu $(CONNECT_TCP)
	$(DSCUDA_CPP) $(FLAGS) -DTCP_ONLY=1 $(INC) $(LIBDIR) -o $@ -i $< $(LIB) -ldscuda_tcp

$(TARGET)_native: $(TARGET).cu 
	$(NVCC) $(FLAGS) $(INC) $(LIBDIR) -o $@ $< $(LIB)


clean:
	rm -rf *.o *.ptx *.txt  $(TARGET)_* *.linkinfo ./dscudatmp

########################################

