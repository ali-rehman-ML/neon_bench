cmake_minimum_required(VERSION 3.15)
project(MatMulBenchmark)

# Enable C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Detect changes in YAML file
set(YAML_FILE "${CMAKE_SOURCE_DIR}/dimensions.yaml")
set(STATIC_BUILD "${CMAKE_BINARY_DIR}/static_build")

add_custom_command(
    OUTPUT ${STATIC_BUILD}
    COMMAND ${CMAKE_COMMAND} -E copy_if_different ${YAML_FILE} ${CMAKE_BINARY_DIR}/
    COMMAND ${CMAKE_COMMAND} -E touch ${STATIC_BUILD}
    DEPENDS ${YAML_FILE}
)

add_custom_target(UpdateYAML DEPENDS ${STATIC_BUILD})

# Google Benchmark
find_package(benchmark REQUIRED)

# Add subdirectories for implementation files
enable_language(ASM) # Enable Assembly language support

add_library(matmul_4x4 STATIC 4x4/4x4.s)
set_target_properties(matmul_4x4 PROPERTIES LANGUAGE ASM)

add_library(matmul_4x8 STATIC 4x8/4x8.s)
set_target_properties(matmul_4x8 PROPERTIES LANGUAGE ASM)

add_library(matmul_6x8 STATIC 6x8/6x8.s)
set_target_properties(matmul_6x8 PROPERTIES LANGUAGE ASM)

# Benchmark executable
add_executable(bench_matmul bench_matmul.cpp)
add_dependencies(bench_matmul UpdateYAML)

target_link_libraries(bench_matmul PRIVATE matmul_4x4 matmul_4x8 matmul_6x8 benchmark::benchmark)
