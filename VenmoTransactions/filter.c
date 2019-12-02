#include <stdio.h>
#include "messages.c"
#include "usernames.c"

#define N 2500
#define THREADS_PER_BLOCK 85 //amount of search words

__global__ void filterByFood (int∗ v) {
    int messageIndex = blockIdx.x;
    int searchWordIndex = threadIdx.x;
        if (searchWords[searchWordIndex] == messages[messageIndex]) {
            boolResults[messageIndex] = true;
        }
}
//write a function that BoolResults == true prints index of username and messages


int	main ( ) {

//Scan Messages and Usernames File and Place Messages in array and usernames in array
FILE *messagesFile;
FILE *usernamesFile;

messagesFile = fopen("./messages.c", "r");
usernamesFile = fopen("./usernames.c", "r");
string messages[N];
string usernames[N];

for (int i = 0; i < N; i ++) {
    fscanf(messagesFile,"%d", &messages[i]);
    fscanf(usernamesFile,"%d", &usernames[i]);
}

//Scan SearchWords File and Place SearchWords in array
FILE *searchWordFile;
messagesFile = fopen("./searchKeywords.c", "r");
string searchWords[THREADS_PER_BLOCK];

for (int i = 0; i < THREADS_PER_BLOCK; i ++)
    fscanf(searchWordFile,"%d", &searchWords[i]);

/ / (1) Allocate and initialize CPU memory
    int∗ A = (int∗) malloc (N∗sizeof(int));
    for ( int i = 0; i < N; i ++)
        A[i] =//assign values into here

/ / (2) Allocate GPU memory
    int∗ gpu_A ;
    bool* boolResults = []
    cudaMalloc(&gpu_A , N∗sizeof(int));

/ / (3) Copy CPU to GPU
    cudaMemcpy( gpu_A , A, N∗sizeof(int), cudaMemcpyHostToDevice) ;

/ / (4) Run GPU code
     int numCores = 2500
     if (N % THREADS_PER_BLOCK != 0)
        numCores++;
	 filterByFood<<<numCores,THREADS_PER_BLOCK>>>(gpu_A);

/ / (5) Copy GPU to CPU
    cudaMemcpy(A, boolResults, N∗sizeof (int) , cudaMemcpyDeviceToHost);

/ / (6) Free GPU and CPU memory
    cudaFree(gpu_A);
    free(A);
	return	0;
}
