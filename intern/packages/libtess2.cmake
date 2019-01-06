#[[.rst libtess2
=========
]]
set(package_protocol "git")
set(package_source "https://github.com/memononen/libtess2.git")

if(${package_version} STREQUAL "dev")
elseif(${package_version} STREQUAL "newest")
  set(package_revision "24e4bdd4158909e9720422208ab0a0aca788e700")
else()
  message(FATAL_ERROR "Unknown package version. Please use 'dev' or 'newest'.")
endif()

function(build_package location)
  AddSourceDirectoryRecursive(filelist "${location}/Source" "Source")
  list(APPEND LIBTESS2_FILES ${filelist})	
  AddHeaderDirectoryRecursive(filelist "${location}/Source" "Includes")
  list(APPEND LIBTESS2_FILES ${filelist})	
  
  rcf_generate(module LIBTESS2 libtess2 "3rd Party Libraries/libtess2")
  AddPublicInclude(LIBTESS2 "${location}/Include/")
  rcf_endgenerate()  
endfunction()