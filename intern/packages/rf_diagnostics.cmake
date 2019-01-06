#[[.rst Radon framework Diagnostics
===============
]]
set(package_protocol "git")
set(package_source "https://github.com/tak2004/RF_Diagnostics.git")

if(${package_version} STREQUAL "dev")
elseif(${package_version} STREQUAL "newest" OR ${package_version} STREQUAL "0.1.0")
  set(package_revision "b46c568ec5bd6ef25b47838e149ac57ce26ceacd")
else()
  message(FATAL_ERROR "Unknown package version. Please use 'dev','newest' or '0.1.0'.")
endif()

function(build_package location)
  set(RF_DIAGNOSTICS_LOCATION ${location})
  rcf_add_subdirectory_once(${location} ${PROJECT_BINARY_DIR}/RF_DIAGNOSTICS${package_version}/)
endfunction()