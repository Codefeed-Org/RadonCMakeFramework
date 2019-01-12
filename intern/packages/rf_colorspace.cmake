#[[.rst Radon framework color space
===============
]]
set(package_protocol "git")
set(package_source "https://github.com/tak2004/RF_ColorSpace.git")

if(${package_version} STREQUAL "dev")
elseif(${package_version} STREQUAL "newest" OR ${package_version} STREQUAL "0.1.0")
  set(package_revision "946d861c586b5c2f3c9652aad7e0863793638b1b")
else()
  message(FATAL_ERROR "Unknown package version. Please use 'dev','newest' or '0.1.0'.")
endif()

function(build_package location)
  set(RF_COLORSPACE_LOCATION ${location})
  rcf_add_subdirectory_once(${location} ${PROJECT_BINARY_DIR}/RF_COLORSPACE${package_version}/)
endfunction()