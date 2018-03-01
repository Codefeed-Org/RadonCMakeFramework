#[[.rst libmorton
=========
]]
set(package_protocol "git")
set(package_source "https://github.com/Forceflow/libmorton.git")

if(${package_version} STREQUAL "dev")
elseif(${package_version} STREQUAL "newest")
  set(package_revision "b962d12dd11ac5b6c45f50b88743551039136349")
else()
  message(FATAL_ERROR "Unknown package version. Please use 'dev' or 'newest'.")
endif()

function(build_package location)
  AddHeaderDirectoryRecursive(filelist "${location}/libmorton/include/" "Includes")
  list(APPEND LIBMORTON_FILES ${filelist})	
  rcf_generate(headeronly LIBMORTON libmorton "3rd Party Libraries/libmorton")
  AddPublicInclude(LIBMORTON "${location}/libmorton/include/")
  rcf_endgenerate()  
endfunction()