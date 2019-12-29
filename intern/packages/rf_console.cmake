#[[.rst Radon framework console
===============
]]
set(package_protocol "git")
set(package_source "https://github.com/tak2004/RF_Console.git")

if(${package_version} STREQUAL "dev")
elseif(${package_version} STREQUAL "newest" OR ${package_version} STREQUAL "0.1.0")
  set(package_revision "f6a7eac56a3669a0b17cba29b80711aaed344c9e")
else()
  message(FATAL_ERROR "Unknown package version. Please use 'dev','newest' or '0.1.0'.")
endif()

function(build_package location)
  set(RF_CONSOLE_LOCATION ${location})
  rcf_add_subdirectory_once(${location} ${PROJECT_BINARY_DIR}/RF_CONSOLE${package_version}/)
endfunction()