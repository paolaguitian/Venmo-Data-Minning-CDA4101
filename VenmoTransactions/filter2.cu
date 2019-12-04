#include <stdio.h>
#include <stdbool.h>

#include "messages.h"
#include "usernames.h"
#include "searchKeywords.h"

#define N 25000 //num of transaction
#define THREADS_PER_BLOCK 85 //num of search words
#define NUM_CORES 4992

//TODO
// what needs to be initialized in GPU (messages, searchwords,booolean)
// what needs to be initialized in CPU (messages, searchwords,booolean)
// what needs to be cudaMemCpy and what is the type --  Copy CPU to GPU??
// filerByFood parameter types - char arrays, and bool array
// what to send to filterByFood

__global__ void filterByFood(gpu_m,gpu_s) {
    int messageIndex = blockIdx.x;
    int searchWordIndex = threadIdx.x;

    if (searchWords[searchWordIndex] == messages[messageIndex]) {
        boolResults[messageIndex] = true;
    }
}
int main(){
    __constant__ gpuMessages = messages;
    __constant__ gpuUsernames = usernames;
    __constant__ gpuSearchKeywords= searchKeywords;


    //(2) Allocate GPU memory
    char∗ gpu_m;
    char∗ gpu_s;
    // TODO: fill with false
    bool* boolResults = []

    //(3) Copy CPU to GPU
    cudaMemcpy( gpu_m, gpuMessages, N∗sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy( gpu_s,gpuSearchKeywords, N∗sizeof(char), cudaMemcpyHostToDevice);

    / / (4) Run GPU code

     int N = 2500
	 filterByFood<<<N,THREADS_PER_BLOCK>>>(gpu_m,gpu_s);

}