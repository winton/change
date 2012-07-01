#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "murmur3.h"

int main(int argc, char **argv) {
  uint32_t hash[4];                /* Output for the hash */
  uint32_t seed = 42;              /* Seed value for hash */
  char *buffer;

  if (argc != 2) {
    printf("usage: %s \"path\"\n", argv[0]);
    exit(1);
  }

  FILE *fh = fopen(argv[1], "rb");

  if (fh != NULL) {
    fseek(fh, 0L, SEEK_END);
    long s = ftell(fh);
    buffer = malloc(s);
    
    rewind(fh);

    if (buffer != NULL) {
      fread(buffer, s, 1, fh);
      fclose(fh); fh = NULL;
 
      MurmurHash3_x86_32(buffer, strlen(buffer), seed, hash);
      printf("%08u\n", hash[0]);
 
      free(buffer);
    }
    if (fh != NULL) fclose(fh);
  }

  return 0;
}