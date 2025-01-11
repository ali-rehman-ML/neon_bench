# MatMul Block Size Benchmark for ARM NEON Architectures

This project benchmarks matrix multiplication performance for ARM NEON architectures using different block sizes.

## Build Instructions

### Prerequisites

Ensure your system is up-to-date and install the required tools:

```bash
sudo apt-get update
sudo apt-get install git build-essential cmake
```

### Google Benchmark Library (Required)

Clone and build the Google Benchmark library:

```bash
git clone https://github.com/google/benchmark.git
cd benchmark
cmake -E make_directory "build"
cmake -E chdir "build" cmake -DBENCHMARK_DOWNLOAD_DEPENDENCIES=on -DCMAKE_BUILD_TYPE=Release ../
cmake --build "build" --config Release
sudo cmake --build "build" --config Release --target install
```

### Build the NEON Benchmark

Clone the NEON benchmark repository and build it:

```bash
cd ..
git clone https://github.com/ali-rehman-ML/neon_benchmark.git
cd neon_benchmark
mkdir build
cd build
cmake ..
make
```

## Usage

The `dimensions.yaml` file contains the matrix dimensions in the format `(M, N, K)` where:
- **A**: Matrix of size `MxN`
- **B**: Matrix of size `NxK`
- **C**: Resulting matrix of size `MxK`

To test with new dimensions, simply add the desired dimensions as a new line in the `dimensions.yaml` file. Each line should have three values separated by commas:

```yaml
192,768,768
192,768,3072
1080,1080,1080
# Add more dimensions as needed
```

Run the benchmark after updating the dimensions file to measure the performance for the specified configurations.
