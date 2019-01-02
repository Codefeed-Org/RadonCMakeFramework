#[[.rst Radon framework Enterprise
===============
]]
set(package_protocol "git")
set(package_source "https://github.com/tak2004/RF_Enterprise.git")

if(${package_version} STREQUAL "dev")
elseif(${package_version} STREQUAL "newest" OR ${package_version} STREQUAL "0.1.0")
  set(package_revision "65128141e974817f6a5fa10129c7b9650ce5c114")
else()
  message(FATAL_ERROR "Unknown package version. Please use 'dev','newest' or '0.1.0'.")
endif()

function(build_package location)
  set(RF_ENTERPRISE_LOCATION ${location})
  rcf_add_subdirectory_once(${location} ${PROJECT_BINARY_DIR}/RF_ENTERPRISE${package_version}/)
endfunction()