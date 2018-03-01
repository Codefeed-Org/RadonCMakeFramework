#[[.rst Google Benchmark
================
]]
set(package_protocol "git")
set(package_source "https://github.com/google/benchmark.git")

if(${package_version} STREQUAL "dev")
elseif(${package_version} STREQUAL "newest" OR ${package_version} STREQUAL "1.3.0")
  set(package_revision "336bb8db986cc52cdf0cefa0a7378b9567d1afee")
else()
  message(FATAL_ERROR "Unknown package version. Please use 'dev','newest' or '1.3.0'.")
endif()

function(build_package location)
  set(BENCHMARK_ENABLE_TESTING Off CACHE BOOL "" FORCE)
  set(BENCHMARK_COMPILER_TREAT_WARNINGS_AS_ERROR Off CACHE BOOL "" FORCE)
  rcf_add_subdirectory_once(${location} "${PROJECT_BINARY_DIR}/google_benchmark/")
  GenerateCustomTargetMetaInfo(MODULE benchmark BENCHMARK "3rd Party Libraries/google_benchmark/")
  AddPublicInclude(BENCHMARK "${location}/include")
  FinalizeCustomTargetMetaInfo(BENCHMARK)
endfunction()