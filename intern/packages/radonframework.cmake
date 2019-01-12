#[[.rst Radon framework
===============
]]
set(package_protocol "git")
set(package_source "https://github.com/tak2004/RadonFramework.git")

if(${package_version} STREQUAL "dev")
elseif(${package_version} STREQUAL "newest" OR ${package_version} STREQUAL "0.5.0")
  set(package_revision "87ffc61a92b04d1c5222cb7a99e5fb1f8f9dd264")
else()
  message(FATAL_ERROR "Unknown package version. Please use 'dev','newest' or '0.5.0'.")
endif()

function(build_package location)
  set(RADONFRAMEWORK_LOCATION ${location})
  rcf_add_subdirectory_once(${location} ${PROJECT_BINARY_DIR}/RADONFRAMEWORK${package_version}/)
endfunction()