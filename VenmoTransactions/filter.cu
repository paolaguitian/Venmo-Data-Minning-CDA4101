#include <stdio.h>
#include <stdbool.h>
#include <sys/time.h>

#include "CPU_messages.h"
#include "GPU_messages.h"
#include "GPU_searchKeywords.h"
#include "CPU_searchKeywords.h"
#include "usernames.h"


#define N 2500 //num of transaction
#define THREADS_PER_BLOCK 124 //num of search words
#define NUM_CORES 4992

// function to filter food items within GPU
__global__ void GPU_filterByFood(bool* GPU_boolResults) {
    int numloop = N / NUM_CORES;
    if(numloop == 0) numloop = 1; 

    for(int m = 0; m < numloop; m++) {
        int messageIndex = blockIdx.x + (NUM_CORES * m);
        int criteriaIndex = threadIdx.x;
        const char *CM = GPU_messages[messageIndex]; //begin str
        const char *criteria = GPU_searchKeywords[criteriaIndex]; // pattern substr
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
                GPU_boolResults[messageIndex] = true;
            }

            s++;
        }
    }
}

// function to filter food items within CPU
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
    struct timeval start, end;
        
    //(1) Allocate CPU memory
    bool* boolResults = (bool*) malloc(N*sizeof(bool));
    bool* CPU_boolResults = (bool*) malloc(N*sizeof(bool));

    //run  CPU code
    gettimeofday( &start, 0);
    
    CPU_filterByFood(CPU_boolResults);        

    gettimeofday( &end, 0 );
    double CPU_time = ( end.tv_sec - start.tv_sec ) * 1000.0 + ( end.tv_usec - start.tv_usec ) / 1000.0;


    //(2) Allocate GPU memory
    bool* GPU_boolResults;
    cudaMalloc(&GPU_boolResults, N*sizeof(bool));

    // (3) Run GPU code
     gettimeofday( &start, 0);

     GPU_filterByFood<<<N,THREADS_PER_BLOCK>>>(GPU_boolResults);
     cudaMemcpy(boolResults, GPU_boolResults, N*sizeof(bool), cudaMemcpyDeviceToHost);

     gettimeofday( &end, 0 );
     double GPU_time = ( end.tv_sec - start.tv_sec ) * 1000.0 + ( end.tv_usec - start.tv_usec ) / 1000.0;
     
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

     printf("Number of transactions: %d\n", N);
     printf("-------------------------\n");
     printf("Time taken by CPU: %lf ms\n", CPU_time);
     printf("Time taken by GPU: %lf ms\n", GPU_time);
     return 0;
}