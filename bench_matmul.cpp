#include <benchmark/benchmark.h>
#include <cstddef>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include <iostream>
#include <arm_neon.h>


// Include headers for each implementation
#include "4x4/4x4_neon_arm_8_2.h"
#include "4x8/4x8_neon_arm_8_2.h"
#include "6x8/6x8_neon_arm_8_2.h"

// extern "C" void matmul_6x8(float* a, float* b, float* c, size_t N, size_t K, size_t i, size_t j, size_t k, size_t a_idx, size_t b_idx, size_t loop_count);
// extern "C" void matmul_4x4(float* a, float* b, float* c, size_t N, size_t K, size_t i, size_t j, size_t k, size_t a_idx, size_t b_idx, size_t loop_count);
// extern "C" void matmul_4x8(float* a, float* b, float* c, size_t N, size_t K, size_t i, size_t j, size_t k, size_t a_idx, size_t b_idx, size_t loop_count);
void initialize_matrix(int M, int N, float* ptr, float value) {
    for (int i = 0; i < M * N; i++) {
        ptr[i] = value;
    }
}


uint32_t PrefetchToL1(const void* ptr, size_t size) {
  uint32_t step = 16;


  const uint8_t* u8_ptr = static_cast<const uint8_t*>(ptr);
  uint32_t sum = 0;
  while (size >= step) {
    sum += uint32_t(*u8_ptr);
    u8_ptr += step;
    size -= step;
  }
  return sum;
}

std::vector<std::tuple<int, int, int>> read_dimensions(const std::string& yaml_path) {
    std::vector<std::tuple<int, int, int>> dimensions;
    std::ifstream file(yaml_path);
    std::string line;
    while (std::getline(file, line)) {
        std::istringstream ss(line);
        std::string token;
        std::vector<int> dims;
        while (std::getline(ss, token, ',')) {
            dims.push_back(std::stoi(token));
        }
        if (dims.size() == 3) {
            dimensions.emplace_back(dims[0], dims[1], dims[2]);
        }
    }
    return dimensions;
}

static void Benchmark_MatMul(benchmark::State& state, void (*matmul_func)(float*, float*, float*, size_t, size_t, size_t, size_t, size_t, size_t, size_t, size_t),size_t mb , size_t nb) {
    const int M = state.range(0);
    const int N = state.range(1);
    const int K = state.range(2);

    // float* A = static_cast<float*>(std::aligned_alloc(64, M * N * sizeof(float)));
    // float* B = static_cast<float*>(std::aligned_alloc(64, N * K * sizeof(float)));
    // float* C = static_cast<float*>(std::aligned_alloc(64, M * K * sizeof(float)));

    // std::fill(A, A + M * N, 1.0f);
    // std::fill(B, B + N * K, 1.0f);
    // std::fill(C, C + M * K, 0.0f);

    // int M = state.range(0), N = state.range(1), K = state.range(2);
    float* A = static_cast<float*>(std::aligned_alloc(64, M * N * sizeof(float)));
    float* B = static_cast<float*>(std::aligned_alloc(64, N * K * sizeof(float)));
    float* C = static_cast<float*>(std::aligned_alloc(64, M * K * sizeof(float)));
    initialize_matrix(M, N, A, 1.0f);
    initialize_matrix(N, K, B, 1.0f);
    initialize_matrix(M, K, C, 0.0f);

    for (auto _ : state) {
        for (int i = 0; i < M; i += mb) {

            PrefetchToL1(A+i*N, N * sizeof(float));
            for (int j = 0; j < K; j += nb) {

                int k = 0, c_idx = i * K + j, loop_count = 0;
                int a_idx= i*N;
                int b_idx= j*N;
                matmul_func(A + a_idx, B + b_idx, C + c_idx, N * sizeof(float), K * sizeof(float), i, j, k, a_idx, b_idx, loop_count);
 
            }
        }
    }

    state.counters["M"] = M;
    state.counters["K"] = K;
    state.counters["N"] = N;

    std::free(A);
    std::free(B);
    std::free(C);
}

int main(int argc, char** argv) {
    std::vector<std::tuple<int, int, int>> dimensions = read_dimensions("dimensions.yaml");

    for (const auto& [M, N, K] : dimensions) {
        benchmark::RegisterBenchmark("MatMul_4x4", Benchmark_MatMul, matmul_4x4, 4,4)
            ->Args({M, N, K})->Unit(benchmark::kMillisecond);
        benchmark::RegisterBenchmark("MatMul_4x8", Benchmark_MatMul, matmul_4x8,4,8)
            ->Args({M, N, K})->Unit(benchmark::kMillisecond);
        benchmark::RegisterBenchmark("MatMul_6x8", Benchmark_MatMul, matmul_6x8,6,8)
            ->Args({M, N, K})->Unit(benchmark::kMillisecond);
    }

    benchmark::Initialize(&argc, argv);
    benchmark::RunSpecifiedBenchmarks();
    return 0;
}
