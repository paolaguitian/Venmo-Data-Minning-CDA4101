#include <stdio.h>
#include <stdbool.h>

#include "CPU_messages.h"
#include "GPU_messages.h"
#include "usernames.h"
#include "GPU_searchKeywords.h"

#define N 2500 //num of transaction
#define THREADS_PER_BLOCK 124 //num of search words
#define NUM_CORES 4992

__global__ void filterByFood(bool* GPU_boolResults) {
    const char *CM = GPU_messages[blockIdx.x]; //begin str
    const char *criteria = GPU_searchKeywords[threadIdx.x]; // pattern substr
    int s= 0;
    int i = 0;
    int j = 0;

    while(CM[s] != '\0') {
        i = 0, j = s;

        while(criteria[i] != '\0' && CM[j] != '\0') {
            if(CM[j] == criteria[i]) { 
                j++;
                i++;
            }

            else break;
        }
        if(criteria[i] == '\0'){ //match! :)
            GPU_boolResults[blockIdx.x] = true;
        };

        s++;
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
     cudaMemcpy(boolResults, GPU_boolResults, N*sizeof(bool), cudaMemcpyDeviceToHost);

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