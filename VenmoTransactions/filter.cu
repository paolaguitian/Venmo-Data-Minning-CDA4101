#include <stdio.h>
#include <stdbool.h>
#include <time.h>

#include "CPU_messages.h"
#include "GPU_messages.h"
#include "GPU_searchKeywords.h"
#include "CPU_searchKeywords.h"
#include "usernames.h"


#define N 2500 //num of transaction
#define THREADS_PER_BLOCK 124 //num of search words
#define NUM_CORES 4992

__global__ void GPU_filterByFood(bool* GPU_boolResults) {
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
        }

        s++;
    }
}

void CPU_filterByFood(bool* CPU_boolResults) { 
    int i;
    int j;
    for (i = 0; i < N; i++) {
        for (j = 0; j < THREADS_PER_BLOCK; j++) {
            const char *CM = CPU_messages[i]; //begin str
            const char *criteria = CPU_searchKeywords[j]; // pattern substr
            int s = 0;
            int m = 0;
            int n = 0;

            while(CM[s] != '\0') {
                m = 0, n = s;

                while(criteria[m] != '\0' && CM[n] != '\0') {
                    if(criteria[m] == CM[n]) { 
                        m++;
                        n++;                
                    }

                    else break;
                }
                if(criteria[m] == '\0'){ //match! :)
                    CPU_boolResults[i] = true;
                }

                s++;
            }
        }
    }
}

int main() {
    FILE *fp;
    fp = fopen("GPU_results.txt", "w");
    clock_t start, end;
        
    //(1) Allocate CPU memory
    bool* boolResults = (bool*) malloc(N*sizeof(bool));
    bool* CPU_boolResults = (bool*) malloc(N*sizeof(bool));

    //run  CPU code
    start = clock();
    
    CPU_filterByFood(CPU_boolResults);        

    end = clock();
    double CPU_time = double(end - start) / double(CLOCKS_PER_SEC);

    //(2) Allocate GPU memory
    bool* GPU_boolResults;
    cudaMalloc(&GPU_boolResults, N*sizeof(bool));

    // (3) Run GPU code
     start = clock();

     GPU_filterByFood<<<N,THREADS_PER_BLOCK>>>(GPU_boolResults);
     cudaMemcpy(boolResults, GPU_boolResults, N*sizeof(bool), cudaMemcpyDeviceToHost);

     end = clock();
     double GPU_time = double(end - start) / double(CLOCKS_PER_SEC);
     //print GPU output
     for(int i = 0; i < N; i++){
         if(boolResults[i]){
             fprintf(fp,"User: %s Message: %s\n", usernames[i], CPU_messages[i]);
         }
     }

     //print CPU output
     fclose(fp);
     fp = fopen("CPU_results.txt", "w");

     for(int i = 0; i < N; i++){
        if(CPU_boolResults[i]){
            fprintf(fp,"User: %s Message: %s\n", usernames[i], CPU_messages[i]);
        }
    }


    fclose(fp);

     cudaFree(GPU_boolResults);
     free(boolResults);
     free(CPU_boolResults);

     printf("Time taken by CPU: %lf\n", CPU_time);
     printf("Time taken by GPU: %lf\n", GPU_time);
     return 0;
}