#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <unistd.h>
#include <sys/time.h>
#include <cutil.h>
#include <cutil_inline.h>

#define MAXDEV 32
#define NLOOP 2e11
#define PKG	  1024
#define MAXSIZE 1024*1024*600
static const double MEGA  = 1e6;
static const double MICRO = 1e-6;

static void
get_cputime(double *nowp, double *deltap)
{
    struct timeval t;
    double now0;

    gettimeofday(&t, NULL);
    now0 = t.tv_sec + t.tv_usec/1000000.0;
    *deltap = now0 - *nowp;
    *nowp   = now0;
}

static void
sendperf(int argc, char **argv)
{
    int maxsize = MAXSIZE;
    int i, j;
    size_t size;
    double sized;
    double now = 0.0, dt = 0.0;
    double ratio = 2;
    double nloop = NLOOP;
    char *src[MAXDEV];
    char *dst[MAXDEV];
    int ndev;

    ndev = 1; // !!!

    printf("# %d device%s found.\n", ndev, ndev > 1 ? "s" : "");
    for (i = 0; i < ndev; i++) {
        cudaSetDevice(i);
        cutilSafeCall(cudaMalloc((void**) &dst[i], sizeof(char) * maxsize));
	src[i] = (char *)malloc(sizeof(char) * maxsize);
    }
    printf("\n#\n# cudaMemcpy (HostToDevice)\n#\n");

    for (sized = 1024; sized < maxsize; sized *= ratio) {

        size = (size_t)sized;

	get_cputime(&now, &dt);
	for (j = 0; j < nloop/size; j++) {
	    for (i = 0; i < ndev; i++) {
  	        cudaMemcpy(dst[i], src[i], size, cudaMemcpyHostToDevice);
	    }
	}
        cudaDeviceSynchronize();
	get_cputime(&now, &dt);


	  printf("%d byte    %f sec    %f MB/s\n", size, dt, nloop/MEGA/dt);

    }


}

static void
receiveperf(int argc, char **argv)
{
    int maxsize = MAXSIZE;
    int i, j;
    size_t size;
    double sized;
    double now = 0.0, dt = 0.0;
    double ratio = 2;
    double nloop = NLOOP;
    char *src[MAXDEV];
    char *dst[MAXDEV];
    int ndev;


    ndev = 1; // !!!

    printf("# %d device%s found.\n", ndev, ndev > 1 ? "s" : "");
    for (i = 0; i < ndev; i++) {

        cutilSafeCall(cudaMalloc((void**) &src[i], sizeof(char) * maxsize));
	dst[i] = (char *)malloc(sizeof(char) * maxsize);
    }
    printf("\n#\n# cudaMemcpy (DeviceToHost)\n#\n");


    for (sized = 1024; sized < maxsize; sized *= ratio) {

    	size = (size_t)sized;

		get_cputime(&now, &dt);
		for (j = 0; j < nloop/size; j++) {
			for (i = 0; i < ndev; i++) {
				cudaSetDevice(i);
					cudaMemcpy(dst[i], src[i], size, cudaMemcpyDeviceToHost);
		}
	}

	cudaDeviceSynchronize();
	get_cputime(&now, &dt);
	printf("%d byte    %f sec    %f MB/s\n",size, dt, nloop/MEGA/dt);
	}
}

int main(int argc, char **argv)
{
	printf("Starting Bandwidth Test...\n");
    sendperf(argc, argv);
    receiveperf(argc, argv);

    fprintf(stderr, "going to quit...\n");
    return 0;
}
