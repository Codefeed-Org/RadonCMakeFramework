#[[.rst Radon framework console
===============
]]
set(package_protocol "git")
set(package_source "https://github.com/tak2004/RF_Console.git")

if(${package_version} STREQUAL "dev")
elseif(${package_version} STREQUAL "newest" OR ${package_version} STREQUAL "0.1.0")
  set(package_revision "e9b0b1e93b2f94ba3d9f065460380cec996068cf")
else()
  message(FATAL_ERROR "Unknown package version. Please use 'dev','newest' or '0.1.0'.")
endif()

function(build_package location)
  set(RF_CONSOLE_LOCATION ${location})
  rcf_add_subdirectory_once(${location} ${PROJECT_BINARY_DIR}/RF_CONSOLE${package_version}/)
endfunction()