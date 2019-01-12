#[[.rst imgui
======
]]
set(package_protocol "git")
set(package_source "https://github.com/ocornut/imgui.git")

if(${package_version} STREQUAL "dev")
elseif(${package_version} STREQUAL "newest" OR ${package_version} STREQUAL "0.6.3")
  set(package_revision "bccd3d8a32961afb270488463d04b3986487059f")
else()
  message(FATAL_ERROR "Unknown package version. Please use 'dev','newest' or '0.6.3'.")
endif()

function(build_package location)
  AddSourceDirectory(fileSrcList "${location}" "Source")
  AddHeaderDirectory(fileHdrList "${location}" "Includes")
  set(IMGUI_FILES ${fileSrcList} ${fileHdrList})
  Generate(MODULE IMGUI IMGui "Libraries")
  #target_include_directories(IMGui PRIVATE ${location})
  AddPublicInclude(IMGUI ${location})
  Finalize(IMGUI)
endfunction()