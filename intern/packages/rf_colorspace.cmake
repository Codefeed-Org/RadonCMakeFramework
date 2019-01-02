#[[.rst Radon framework color space
===============
]]
set(package_protocol "git")
set(package_source "https://github.com/tak2004/RF_ColorSpace.git")

if(${package_version} STREQUAL "dev")
elseif(${package_version} STREQUAL "newest" OR ${package_version} STREQUAL "0.1.0")
  set(package_revision "e2ccea55f3f8c204aa25486fab90e3e3f8248dd0")
else()
  message(FATAL_ERROR "Unknown package version. Please use 'dev','newest' or '0.1.0'.")
endif()

function(build_package location)
  set(RF_COLORSPACE_LOCATION ${location})
  rcf_add_subdirectory_once(${location} ${PROJECT_BINARY_DIR}/RF_COLORSPACE${package_version}/)
endfunction()