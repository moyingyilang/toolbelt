/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */
/*
 * ab-header — inspect the 48-byte obfuscated header of an EFML4A `.ab`
 * container without decrypting anything.
 *
 * This is the header half of the EFML4A research toolchain, generalized to a
 * single command: verify the self-check pair, unscramble the six fields, and
 * report where the compression block and the data blocks start.
 *
 * The obfuscation constants and field pairings come from the EFML4A notes
 * (A2-ab-container.md) and the project's abtool/abverify sources.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define K_A 0x4A92F0CDu
#define K_B 0xD8B1E637u
#define K_ROT 0xF74324EEu
#define K_MIX 0xA121u
#define K_SIZE 0xDAD76848u
#define K_SIZE2 0xA4F1A11747816520ull
#define K_FLAGS 0xA7F49310u

static uint8_t *file_bytes;
static long file_size;

static uint32_t ror32(uint32_t x, int n) {
  n &= 31;
  return n ? (x >> n) | (x << (32 - n)) : x;
}

static uint32_t rol32(uint32_t x, int n) {
  n &= 31;
  return n ? (x << n) | (x >> (32 - n)) : x;
}

static uint64_t rol64(uint64_t x, int n) {
  n &= 63;
  return n ? (x << n) | (x >> (64 - n)) : x;
}

static uint32_t be32(long offset) {
  const uint8_t *p = file_bytes + offset;
  return ((uint32_t)p[0] << 24) | ((uint32_t)p[1] << 16) | ((uint32_t)p[2] << 8) | p[3];
}

static uint16_t be16(long offset) {
  const uint8_t *p = file_bytes + offset;
  return (uint16_t)(((uint16_t)p[0] << 8) | p[1]);
}

static void put_be16(uint8_t *buf, long offset, uint16_t value) {
  buf[offset] = (uint8_t)(value >> 8);
  buf[offset + 1] = (uint8_t)value;
}

static void put_be32(uint8_t *buf, long offset, uint32_t value) {
  buf[offset] = (uint8_t)(value >> 24);
  buf[offset + 1] = (uint8_t)(value >> 16);
  buf[offset + 2] = (uint8_t)(value >> 8);
  buf[offset + 3] = (uint8_t)value;
}

typedef struct {
  uint32_t compressed_block_info;
  uint32_t uncompressed_block_info;
  uint64_t size;
  uint32_t flags;
  uint32_t encryption_flags;
  uint32_t flags2;
} ab_header;

/* Decode the six scrambled fields from a 48-byte header. */
static int decode_header(const uint8_t *raw, ab_header *out) {
  file_bytes = (uint8_t *)raw;
  uint16_t cBI2 = be16(8);
  uint32_t flags2 = be32(10);
  uint32_t encF = be32(14);
  uint32_t size2 = be32(18);
  uint32_t flags1 = be32(22);
  uint16_t uBI1 = be16(26);
  uint16_t uBI2 = be16(32);
  uint32_t size1 = be32(34);
  uint16_t cBI1 = be16(38);

  uint32_t compBI = ((uint32_t)(cBI1 ^ cBI2 ^ K_MIX) << 16) | cBI2;
  compBI = ror32(compBI, 18) ^ K_ROT;
  uint32_t uncompBI = ((uint32_t)(uBI1 ^ uBI2 ^ K_MIX) << 16) | uBI2;
  uncompBI = ror32(uncompBI, 18) ^ K_ROT;
  uint64_t size = ((uint64_t)(size1 ^ size2 ^ K_SIZE) << 32) | size2;
  size = rol64(size, 14) ^ K_SIZE2;

  out->compressed_block_info = compBI;
  out->uncompressed_block_info = uncompBI;
  out->size = size;
  out->flags = flags1 ^ flags2 ^ K_FLAGS;
  out->encryption_flags = encF ^ flags2;
  out->flags2 = flags2;
  return 0;
}

/* Encode the six fields back into a header; used by --selftest. */
static void encode_header(uint8_t *raw, uint32_t a, const ab_header *in) {
  uint32_t cBI2, cBI1, uBI1, uBI2, flags1, size1, size2;
  uint32_t bc = in->compressed_block_info ^ K_ROT;
  uint32_t bu = in->uncompressed_block_info ^ K_ROT;
  uint64_t bs = in->size ^ K_SIZE2;

  bc = rol32(bc, 18);
  cBI2 = bc & 0xFFFFu;
  cBI1 = ((bc >> 16) & 0xFFFFu) ^ cBI2 ^ K_MIX;

  bu = rol32(bu, 18);
  {
    uint16_t u2 = (uint16_t)(bu & 0xFFFFu);
    uBI2 = u2;
    uBI1 = (uint16_t)(((bu >> 16) & 0xFFFFu) ^ u2 ^ K_MIX);
  }

  bs = rol64(bs, 50);
  size2 = (uint32_t)(bs & 0xFFFFFFFFu);
  size1 = (uint32_t)((bs >> 32) & 0xFFFFFFFFu) ^ size2 ^ K_SIZE;

  uint32_t flags2 = in->flags2;
  flags1 = in->flags ^ flags2 ^ K_FLAGS;
  uint32_t encF = in->encryption_flags ^ flags2;

  memset(raw, 0, 48);
  put_be32(raw, 0, a);
  put_be32(raw, 4, ((4 * (a ^ K_A)) & 0xFFFF0000u) ^ ror32(a ^ K_A, 14) ^ K_B);
  put_be16(raw, 8, (uint16_t)cBI2);
  put_be32(raw, 10, flags2);
  put_be32(raw, 14, encF);
  put_be32(raw, 18, size2);
  put_be32(raw, 22, flags1);
  put_be16(raw, 26, (uint16_t)uBI1);
  put_be16(raw, 32, (uint16_t)uBI2);
  put_be32(raw, 34, size1);
  put_be16(raw, 38, (uint16_t)cBI1);
}

static int selftest(void) {
  static const uint32_t cases[][5] = {
      {1, 4096, 0x00020000u, 0x00000000u, 7},
      {101, 1, 0x10000000u, 0x00000005u, 6},
      {65535, 65535, 0x7FFFFFFF, 0x00000105u, 9},
  };
  for (size_t index = 0; index < sizeof cases / sizeof cases[0]; index += 1) {
    ab_header input;
    input.compressed_block_info = cases[index][0];
    input.uncompressed_block_info = cases[index][1];
    input.size = cases[index][2];
    input.flags = cases[index][3];
    input.encryption_flags = cases[index][4];
    input.flags2 = 0x13572468u;
    uint8_t raw[48];
    encode_header(raw, 0xA1B2C3D4u, &input);
    ab_header output;
    decode_header(raw, &output);
    if (output.compressed_block_info != input.compressed_block_info
        || output.uncompressed_block_info != input.uncompressed_block_info
        || output.size != input.size || output.flags != input.flags
        || output.encryption_flags != input.encryption_flags) {
      fprintf(stderr, "ab-header: selftest case %zu failed\n", index);
      return 1;
    }
    if (be32(4) != (((4 * (0xA1B2C3D4u ^ K_A)) & 0xFFFF0000u) ^ ror32(0xA1B2C3D4u ^ K_A, 14) ^ K_B)) {
      fprintf(stderr, "ab-header: selftest header check failed\n");
      return 1;
    }
  }
  printf("ab-header: selftest ok (%zu cases)\n", sizeof cases / sizeof cases[0]);
  return 0;
}

int main(int argc, char **argv) {
  if (argc < 2) {
    fprintf(stderr, "usage: ab-header <file.ab> [--json]\n       ab-header --selftest\n");
    return 2;
  }
  if (strcmp(argv[1], "--selftest") == 0) return selftest();
  if (strcmp(argv[1], "--help") == 0 || strcmp(argv[1], "-h") == 0) {
    printf("usage: ab-header <file.ab> [--json]\n       ab-header --selftest\n");
    return 0;
  }

  int json = argc > 2 && strcmp(argv[2], "--json") == 0;
  FILE *file = fopen(argv[1], "rb");
  if (file == NULL) {
    perror(argv[1]);
    return 1;
  }
  fseek(file, 0, SEEK_END);
  file_size = ftell(file);
  fseek(file, 0, SEEK_SET);
  if (file_size < 48) {
    fprintf(stderr, "ab-header: %s is shorter than a 48-byte header\n", argv[1]);
    fclose(file);
    return 1;
  }
  uint8_t *raw = malloc((size_t)file_size);
  if (raw == NULL || fread(raw, 1, (size_t)file_size, file) != (size_t)file_size) {
    fprintf(stderr, "ab-header: cannot read %s\n", argv[1]);
    fclose(file);
    free(raw);
    return 1;
  }
  fclose(file);
  file_bytes = raw;

  uint32_t a = be32(0);
  uint32_t stored = be32(4);
  uint32_t expected = ((4 * (a ^ K_A)) & 0xFFFF0000u) ^ ror32(a ^ K_A, 14) ^ K_B;
  int check_ok = stored == expected;

  ab_header header;
  decode_header(raw, &header);

  long block_info_offset;
  if (header.flags & 0x100u) block_info_offset = (long)(header.size - header.compressed_block_info);
  else block_info_offset = header.encryption_flags >= 7 ? 48 : 40;
  long data_offset = 48 + ((long)header.compressed_block_info + 15) / 16 * 16;

  if (json) {
    printf("{\n");
    printf("  \"file\": \"%s\",\n", argv[1]);
    printf("  \"bytes\": %ld,\n", file_size);
    printf("  \"header_check\": %s,\n", check_ok ? "true" : "false");
    printf("  \"compressed_block_info\": %u,\n", header.compressed_block_info);
    printf("  \"uncompressed_block_info\": %u,\n", header.uncompressed_block_info);
    printf("  \"size\": %llu,\n", (unsigned long long)header.size);
    printf("  \"flags\": %u,\n", header.flags);
    printf("  \"encryption_flags\": %u,\n", header.encryption_flags);
    printf("  \"block_info_offset\": %ld,\n", block_info_offset);
    printf("  \"data_offset\": %ld\n", data_offset);
    printf("}\n");
  } else {
    printf("file        %s\n", argv[1]);
    printf("bytes       %ld\n", file_size);
    printf("self-check  %s\n", check_ok ? "ok" : "MISMATCH (not an EFML4A .ab, or damaged)");
    printf("compBI      %u\n", header.compressed_block_info);
    printf("uncompBI    %u\n", header.uncompressed_block_info);
    printf("size        %llu\n", (unsigned long long)header.size);
    printf("flags       0x%08x\n", header.flags);
    printf("encFlags    %u\n", header.encryption_flags);
    printf("block info  @%ld\n", block_info_offset);
    printf("data        @%ld\n", data_offset);
  }

  free(raw);
  return check_ok ? 0 : 1;
}
