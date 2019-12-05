#include <stdio.h>
#include <stdbool.h>

#include "CPU_messages.h"
#include "GPU_messages.h"
#include "usernames.h"
#include "searchKeywords.h"

#define N 25000 //num of transaction
#define THREADS_PER_BLOCK 85 //num of search words
#define NUM_CORES 4992

__global__ void filterByFood(bool* boolResults) {
    int messageIndex = blockIdx.x;
    int searchWordIndex = threadIdx.x;

    while(*GPU_messages[messageIndex]) {
        char* currentMessage = GPU_messages[messageIndex]; //begin str
        char* criteria = GPU_searchKeywords[searchWordIndex]; // pattern substr

        while(*GPU_messages[messageIndex] && *criteria && *GPU_messages[messageIndex] == *criteria ) {
            GPU_messages[messageIndex]++;
            criteria++;
        }

        if(!*criteria)
            boolResults[messageIndex] = true;

        GPU_messages[messageIndex] = currentMessage + 1;
    }
}

int main(){
    FILE *fp;
    fp = fopen("Output.txt", "w");

    //(1) Allocate CPU memory
    bool* boolResults = (bool*) malloc(N*sizeof(bool));

    //(2) Allocate GPU memory
    bool* GPU_boolResults;
    cudaMalloc(&GPU_boolResults, N*sizeof(bool));


    // (3) Run GPU code
     filterByFood<<<N,THREADS_PER_BLOCK>>>(GPU_boolResults);
     cudaMemCpy(boolResults, GPU_boolResults, N*sizeof(bool), cudaMemcpyDeviceToHost);

     for(int i = 0; i < N; i++){
         if(boolResults[i]){
             fprintf(fp,"User: %s Message: %s\n", usernames[i], CPU_messages[i]);
         }
     }
     fclose(fp);
     cudaFree(GPU_boolResults);
     free(boolResults);
     return 0;
}