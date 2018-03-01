#[[.rst Simple DirectMedia Layer(SDL)
=============================
]]
set(package_protocol "git")
set(package_source "https://github.com/SDL-mirror/SDL")

if(${package_version} STREQUAL "dev")
elseif(${package_version} STREQUAL "newest" OR ${package_version} STREQUAL "2.0.7")
  set(package_revision "236c143dd467bc18464ce2bac1bea9a66bd25588")
else()
  message(FATAL_ERROR "Unknown package version. Please use 'dev','newest' or '2.0.7'.")
endif()

function(build_package location)
  rcf_add_subdirectory_once(${location} "${PROJECT_BINARY_DIR}/SDL/")
  GenerateCustomTargetMetaInfo(MODULE SDL2main SDLMAIN "3rd Party Libraries/sdl")
  FinalizeCustomTargetMetaInfo(SDLMAIN)
  GenerateCustomTargetMetaInfo(MODULE SDL2-static SDL_STATIC "3rd Party Libraries/sdl")
  FinalizeCustomTargetMetaInfo(SDL_STATIC)
  GenerateCustomTargetMetaInfo(MODULE SDL2 SDL_SHARED "3rd Party Libraries/sdl")
  FinalizeCustomTargetMetaInfo(SDL_SHARED)
  set_property(TARGET uninstall PROPERTY FOLDER "3rd Party Libraries/sdl")
endfunction()