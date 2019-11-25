#include <stdio.h>

#define N 5000 //how to define venmoData.c as N
#define THREADS_PER_BLOCK 512 //min/max?? Cant define evenly

__global__ void filterByFood (int∗ v) {
    int index = blockIdx.x∗blockDim.x + threadIdx.x; 
    if (index < N  && index % 2 != 0)
        if (v[index] == "food") {
            results[counter] = v[index]
            results[counter - 1]  = v[index-1]
            counter ++;    
        }
}

int	main ( ) {

/ / (1) Allocate and initialize CPU memory 
    int∗ A = (int∗) malloc (N∗sizeof(int)); 
    for ( int i = 0; i < N; i ++) 
        A[i] =//assign values into here

/ / (2) Allocate GPU memory 
    int∗ gpu_A ;
    int* results = []
    int* counter = 1;
    cudaMalloc(&gpu_A , N∗sizeof(int));

/ / (3) Copy CPU to GPU 
    cudaMemcpy( gpu_A , A, N∗sizeof(int), cudaMemcpyHostToDevice) ;

/ / (4) Run GPU code
     int numblocks = N / THREADS_PER_BLOCK; 
     if (N % THREADS_PER_BLOCK != 0) 
        numblocks++;
	 filterByFood<<<numblocks,THREADS_PER_BLOCK>>>(gpu_A);

/ / (5) Copy GPU to CPU 
    cudaMemcpy(A, results , N∗sizeof (int) , cudaMemcpyDeviceToHost);

/ / (6) Free GPU and CPU memory 
    cudaFree(gpu_A); 
    free(A);
	return	0;
}
