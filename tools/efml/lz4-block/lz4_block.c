/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */
/*
 * lz4-block — decode one raw LZ4 block, in either the standard variant (used
 * for the .ab block-info table) or the big-endian-offset variant the game uses
 * for data blocks ("LZ4Inv" in the EFML4A notes).
 *
 * Neither variant carries an end marker or a size, which is exactly the trap
 * the project notes call out: zero padding a compressed stream corrupts it.
 * That is why the uncompressed size is a required argument.
 *
 * The token layout and loop follow the EFML4A toolchain's lz4d() in abtool.c,
 * rewritten here as a standalone tool with explicit bounds checks.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static long decode_block(const uint8_t *input, long input_length, uint8_t *output,
                         long output_capacity, int inverted) {
  const uint8_t *in = input;
  const uint8_t *in_end = input + input_length;
  uint8_t *out = output;
  uint8_t *out_end = output + output_capacity;

  while (in < in_end) {
    uint8_t token = *in++;
    long literal_length;
    long match_length;

    if (inverted) {
      uint8_t literal_bits = token & 0x33u;
      uint8_t length_bits = (uint8_t)((token & 0xCCu) >> 2);
      literal_length = (literal_bits & 3) | (literal_bits >> 2);
      match_length = (length_bits & 3) | (length_bits >> 2);
    } else {
      literal_length = token >> 4;
      match_length = token & 0x0F;
    }

    if (literal_length == 15) {
      uint8_t extra;
      do {
        if (in >= in_end) return -1;
        extra = *in++;
        literal_length += extra;
      } while (extra == 255);
    }
    if (literal_length > in_end - in || literal_length > out_end - out) return -1;
    memcpy(out, in, (size_t)literal_length);
    in += literal_length;
    out += literal_length;

    if (in >= in_end) break; /* last sequence: literals only */

    if (in + 2 > in_end) return -1;
    long offset;
    if (inverted) offset = ((long)in[0] << 8) | in[1];
    else offset = (long)in[0] | ((long)in[1] << 8);
    in += 2;
    if (offset == 0 || offset > (out - output)) return -1;

    if (match_length == 15) {
      uint8_t extra;
      do {
        if (in >= in_end) return -1;
        extra = *in++;
        match_length += extra;
      } while (extra == 255);
    }
    match_length += 4;
    if (out + match_length > out_end) return -1;
    {
      const uint8_t *match = out - offset;
      for (long index = 0; index < match_length; index += 1) *out++ = *match++;
    }
  }
  return out - output;
}

static uint8_t *read_file(const char *path, long *length) {
  FILE *file = fopen(path, "rb");
  if (file == NULL) {
    perror(path);
    return NULL;
  }
  fseek(file, 0, SEEK_END);
  *length = ftell(file);
  fseek(file, 0, SEEK_SET);
  uint8_t *data = malloc((size_t)*length + 1);
  if (data == NULL || fread(data, 1, (size_t)*length, file) != (size_t)*length) {
    fprintf(stderr, "lz4-block: cannot read %s\n", path);
    fclose(file);
    free(data);
    return NULL;
  }
  fclose(file);
  return data;
}

static int selftest(void) {
  /* Standard variant: token 0x30 = 3 literals; then the stream ends. */
  const uint8_t std_literals[] = {0x30, 'A', 'B', 'C'};
  /* Standard variant: 1 literal + match of 4 at offset 1 => "AAAAA". */
  const uint8_t std_match[] = {0x10, 'A', 0x01, 0x00};
  /* Inverted variant: token 0x03 = 3 literals (bit-interleaved layout). */
  const uint8_t inv_literals[] = {0x03, 'x', 'y', 'z'};
  /* Inverted variant: 1 literal + match of 4, big-endian offset 1 => "AAAAA". */
  const uint8_t inv_match[] = {0x01, 'A', 0x00, 0x01};

  uint8_t output[32];

  long got = decode_block(std_literals, sizeof std_literals, output, sizeof output, 0);
  if (got != 3 || memcmp(output, "ABC", 3) != 0) return 1;

  got = decode_block(std_match, sizeof std_match, output, sizeof output, 0);
  if (got != 5 || memcmp(output, "AAAAA", 5) != 0) return 1;

  got = decode_block(inv_literals, sizeof inv_literals, output, sizeof output, 1);
  if (got != 3 || memcmp(output, "xyz", 3) != 0) return 1;

  got = decode_block(inv_match, sizeof inv_match, output, sizeof output, 1);
  if (got != 5 || memcmp(output, "AAAAA", 5) != 0) return 1;

  printf("lz4-block: selftest ok (standard + inverted, literals + match)\n");
  return 0;
}

int main(int argc, char **argv) {
  if (argc < 2) {
    fprintf(stderr, "usage: lz4-block <input> <output> <uncompressed-size> [--inv]\n       lz4-block --selftest\n");
    return 2;
  }
  if (strcmp(argv[1], "--selftest") == 0) return selftest();
  if (strcmp(argv[1], "--help") == 0 || strcmp(argv[1], "-h") == 0) {
    printf("usage: lz4-block <input> <output> <uncompressed-size> [--inv]\n"
           "       lz4-block --selftest\n\n"
           "  --inv   decode the big-endian-offset variant used for .ab data blocks\n");
    return 0;
  }
  if (argc < 4) {
    fprintf(stderr, "lz4-block: need <input> <output> <uncompressed-size> [--inv]\n");
    return 2;
  }
  int inverted = argc > 4 && strcmp(argv[4], "--inv") == 0;
  char *end = NULL;
  long capacity = strtol(argv[3], &end, 10);
  if (end == argv[3] || *end != '\0' || capacity <= 0) {
    fprintf(stderr, "lz4-block: uncompressed-size must be a positive integer\n");
    return 2;
  }

  long input_length = 0;
  uint8_t *input = read_file(argv[1], &input_length);
  if (input == NULL) return 1;

  uint8_t *output = malloc((size_t)capacity);
  if (output == NULL) {
    fprintf(stderr, "lz4-block: out of memory\n");
    free(input);
    return 1;
  }

  long produced = decode_block(input, input_length, output, capacity, inverted);
  if (produced < 0) {
    fprintf(stderr, "lz4-block: corrupt or truncated stream\n");
    free(input);
    free(output);
    return 1;
  }

  FILE *out = strcmp(argv[2], "-") == 0 ? stdout : fopen(argv[2], "wb");
  if (out == NULL) {
    perror(argv[2]);
    free(input);
    free(output);
    return 1;
  }
  fwrite(output, 1, (size_t)produced, out);
  if (out != stdout) fclose(out);
  else fflush(stdout);
  fprintf(stderr, "lz4-block: %ld bytes (%s)\n", produced, inverted ? "inverted" : "standard");
  free(input);
  free(output);
  return 0;
}
