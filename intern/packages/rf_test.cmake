#[[.rst Radon framework Test
===============
]]
set(package_protocol "git")
set(package_source "https://github.com/tak2004/RF_Test.git")

if(${package_version} STREQUAL "dev")
elseif(${package_version} STREQUAL "newest" OR ${package_version} STREQUAL "0.1.0")
  set(package_revision "f3964ba6b041e8c2fa1ee8bd4e8df4f8d2c1cd68")
else()
  message(FATAL_ERROR "Unknown package version. Please use 'dev','newest' or '0.1.0'.")
endif()

function(build_package location)
  set(RF_TEST_LOCATION ${location})
  rcf_add_subdirectory_once(${location} ${PROJECT_BINARY_DIR}/RF_TEST${package_version}/)
endfunction()