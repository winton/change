#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "murmur3.h"

int main(int argc, char **argv) {
  uint32_t hash[4];    /* Output for the hash */
  uint32_t seed = 42;  /* Seed value for hash */

  int x;

  for (x = 1; x < argc; x++) {
    FILE *fh = fopen(argv[x], "rb");

    if (fh != NULL) {
      fseek(fh, 0L, SEEK_END);
      long s = ftell(fh);

      char *buffer = malloc(s + 1);
      buffer[s] = '\0';
      
      rewind(fh);

      if (s != 0) {
        fread(buffer, s, 1, fh);
        fclose(fh);
        fh = NULL;
      }
   
      MurmurHash3_x86_32(buffer, strlen(buffer), seed, hash);
      printf("%08u\n", hash[0]);
 
      free(buffer);

      if (fh != NULL)
        fclose(fh);
    }
  }

  return 0;
}