set(package_protocol "git")
set(package_source "https://github.com/tak2004/RadonFramework.git")

if(${package_version} STREQUAL "dev")
elseif(${package_version} STREQUAL "newest" OR ${package_version} STREQUAL "0.4.0")
  set(package_revision "b5c561fb59539773c6eee1ca9974af92aaeb11a6")
else()
  message(FATAL_ERROR "Unknown package version. Please use 'dev','newest' or '0.4.0'.")
endif()

function(build_package location)
  set(RADONFRAMEWORK_LOCATION ${location})
  rcf_add_subdirectory_once(${location} ${PROJECT_BINARY_DIR}/RADONFRAMEWORK/)
endfunction()