#ifndef MATMUL_4x4_NEON_ARM_8_2_H
#define MATMUL_4x4_NEON_ARM_8_2_H

#include <cstddef>

extern "C" void matmul_4x4(float* a, float* b, float* c,
                           size_t N, size_t K, size_t i, size_t j, size_t k,
                           size_t a_idx, size_t b_idx, size_t loop_count);

#endif // MATMUL_4x4_NEON_ARM_8_2_H
