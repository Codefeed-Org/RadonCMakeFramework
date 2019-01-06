#[[.rst Radon framework UI
===============
]]
set(package_protocol "git")
set(package_source "https://github.com/tak2004/RF_UI.git")

if(${package_version} STREQUAL "dev")
elseif(${package_version} STREQUAL "newest" OR ${package_version} STREQUAL "0.1.0")
  set(package_revision "5f4b5d73360c268ad3fcfd02615d2694ebfe3e7d")
else()
  message(FATAL_ERROR "Unknown package version. Please use 'dev','newest' or '0.1.0'.")
endif()

function(build_package location)
  set(RF_UI_LOCATION ${location})
  rcf_add_subdirectory_once(${location} ${PROJECT_BINARY_DIR}/RF_UI{package_version}/)
endfunction()