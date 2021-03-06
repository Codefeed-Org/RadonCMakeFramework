#[[.rst jsoncpp
=======
]]
set(package_protocol "git")
set(package_source "https://github.com/open-source-parsers/jsoncpp.git")

if(${package_version} STREQUAL "dev")
elseif(${package_version} STREQUAL "newest" OR ${package_version} STREQUAL "1.8.3")
  set(package_revision "2de18021fcb11370e9b5a1fbe7dcfd673533a134")
else()
  message(FATAL_ERROR "Unknown package version. Please use 'dev','newest' or '1.8.3'.")
endif()

function(build_package location)
  set(JSONCPP_SHARED_COMPILER_USE_EXCEPTION OFF CACHE BOOL "Activate exceptions(Default: off)" FORCE)
  set(JSONCPP_STATIC_COMPILER_USE_EXCEPTION OFF CACHE BOOL "Activate exceptions(Default: off)" FORCE)
  set(JSONCPP_SHARED_COMPILER_TREAT_WARNINGS_AS_ERROR OFF CACHE BOOL "" FORCE)
  set(JSONCPP_STATIC_COMPILER_TREAT_WARNINGS_AS_ERROR OFF CACHE BOOL "" FORCE)

  set(JSONCPP_WITH_TESTS OFF CACHE BOOL "Compile and run JsonCpp test executables" FORCE)
  set(JSONCPP_WITH_POST_BUILD_UNITTEST OFF CACHE BOOL "Automatically run unit-tests as a post build step" FORCE)
  set(JSONCPP_WITH_PKGCONFIG_SUPPORT OFF CACHE BOOL "Generate and install .pc files" FORCE)
  set(BUILD_SHARED_LIBS ON CACHE BOOL "Build jsoncpp_lib as a shared library." FORCE)  
  rcf_add_subdirectory_once(${location} "${PROJECT_BINARY_DIR}/JSONCPP/")
  GenerateCustomTargetMetaInfo(MODULE jsoncpp_lib_static JSONCPP_STATIC "3rd Party Libraries/jsoncpp")
  FinalizeCustomTargetMetaInfo(JSONCPP_STATIC)
  GenerateCustomTargetMetaInfo(MODULE jsoncpp_lib JSONCPP_SHARED "3rd Party Libraries/jsoncpp")
  FinalizeCustomTargetMetaInfo(JSONCPP_SHARED)
endfunction()