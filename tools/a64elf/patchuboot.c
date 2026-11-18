// patchuboot.c — 给 uboot_a.img 打补丁：让 normal 模式也执行模式探测链
//
// 缺口：
//   bootcmd = "cboot normal"  => w19 = 2
//   0x9f0076bc  cmp w19, 2
//   0x9f0076c0  b.ne 0x9f0076d4     <- w19==2 时不跳，走 0x9f0076c4（跳过探测链）
//   ...
//   未命中时：
//   0x9f00771c  mov w19, 0  ->  最终分发越界
//   0x9f00775c  mov w0, 0
//   0x9f007760  bl 0x9f03d6a8       <- 疑似 panic/halt
//   0x9f007764  b .                 <- 死循环
//
// 补丁：
//   1  0x9f0076c0  b.ne -> b 0x9f0076d4   （normal 也进探测链）
//   2  0x9f00775c  mov w0,0 -> b 0x9f0076c4（未命中直接回落 normal，
//                                            跳过 bl 0x9f03d6a8）
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define CODE_OFF 0x200
#define BASE     0x9f000000u

static uint8_t *d;
static size_t off_of(uint32_t abs){ return CODE_OFF + (abs - BASE); }

static uint32_t enc_b(uint32_t from, uint32_t to, int link){
    int64_t imm = (int64_t)to - (int64_t)from;
    int64_t off26 = imm >> 2;
    return (uint32_t)((link?0x94000000u:0x14000000u) | (off26 & 0x03FFFFFFu));
}
static uint32_t rd32(uint32_t abs){
    uint32_t w; memcpy(&w, d+off_of(abs), 4); return w;
}
static void show(uint32_t abs, const char *tag){
    printf("    %-12s 0x%08x : %08x  (文件 0x%zx)\n", tag, abs, rd32(abs), off_of(abs));
}

int main(int argc, char **argv){
    if (argc < 3){ fprintf(stderr,"用法: %s <in.img> <out.img>\n",argv[0]); return 1; }
    FILE *f=fopen(argv[1],"rb"); if(!f){perror("in");return 1;}
    fseek(f,0,SEEK_END); long sz=ftell(f); fseek(f,0,SEEK_SET);
    d=malloc(sz); fread(d,1,sz,f); fclose(f);
    printf("[*] 输入 %s  %ld 字节\n", argv[1], sz);
    if (memcmp(d,"DHTB",4)){ fprintf(stderr,"不是 DHTB 镜像\n"); return 1; }

    printf("\n=== 补丁前 ===\n");
    show(0x9f0076bc,"cmp w19,2");
    show(0x9f0076c0,"b.ne");
    show(0x9f00775c,"mov w0,0");
    show(0x9f007760,"bl halt?");
    show(0x9f007764,"b .");

    /* 期望值校验 */
    if (rd32(0x9f0076bc)!=0x71000a7f){ fprintf(stderr,"0x9f0076bc 期望 71000a7f，实际 %08x\n",rd32(0x9f0076bc)); return 1; }
    if (rd32(0x9f0076c0)!=0x540000a1){ fprintf(stderr,"0x9f0076c0 期望 540000a1，实际 %08x\n",rd32(0x9f0076c0)); return 1; }

    /* 补丁 1 */
    uint32_t p1 = enc_b(0x9f0076c0, 0x9f0076d4, 0);
    memcpy(d+off_of(0x9f0076c0), &p1, 4);
    printf("\n[补丁1] 0x9f0076c0 -> %08x  b 0x9f0076d4  (normal 也进探测链)\n", p1);

    /* 补丁 2：0x9f00775c 改为直接跳回落路径 */
    uint32_t p2 = enc_b(0x9f00775c, 0x9f0076c4, 0);
    memcpy(d+off_of(0x9f00775c), &p2, 4);
    printf("[补丁2] 0x9f00775c -> %08x  b 0x9f0076c4  (未命中回落 normal，跳过 halt)\n", p2);

    printf("\n=== 补丁后 ===\n");
    show(0x9f0076c0,"b chain");
    show(0x9f00775c,"b normal");
    if (memcmp(d,"DHTB",4)){ fprintf(stderr,"头被破坏\n"); return 1; }

    FILE *o=fopen(argv[2],"wb"); fwrite(d,1,sz,o); fclose(o);
    printf("\n[*] 写出 %s（DHTB 头完好，签名失效需自行绕过）\n", argv[2]);
    return 0;
}
