#[[.rst Radon framework
===============
]]
set(package_protocol "git")
set(package_source "https://github.com/tak2004/RadonFramework.git")

if(${package_version} STREQUAL "dev")
elseif(${package_version} STREQUAL "newest" OR ${package_version} STREQUAL "0.5.0")
  set(package_revision "ccb90e12ccca6f5ef969dc90cd2beea17723ddc0")
else()
  message(FATAL_ERROR "Unknown package version. Please use 'dev','newest' or '0.5.0'.")
endif()

function(build_package location)
  set(RADONFRAMEWORK_LOCATION ${location})
  rcf_add_subdirectory_once(${location} ${PROJECT_BINARY_DIR}/RADONFRAMEWORK${package_version}/)
endfunction()