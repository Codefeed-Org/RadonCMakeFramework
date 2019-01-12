#[[.rst Assimp
======
]]
set(package_protocol "git")
set(package_source "https://github.com/assimp/assimp.git")

if(${package_version} STREQUAL "dev")
elseif(${package_version} STREQUAL "newest" OR ${package_version} STREQUAL "4.1.0")
  set(package_revision "80799bdbf90ce626475635815ee18537718a05b1")
else()
  message(FATAL_ERROR "Unknown package version. Please use 'dev','newest' or '4.1.0'.")
endif()

function(build_package location)
  add_subdirectory("${location}/")
  GenerateCustomTargetMetaInfo(MODULE assimp ASSIMP "3rd Party Libraries/Assimp")
  AddPublicInclude(ASSIMP ${outdir}/include/)
  FinalizeCustomTargetMetaInfo(ASSIMP)
endfunction()