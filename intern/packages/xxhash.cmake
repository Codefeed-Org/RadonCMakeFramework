set(package_protocol "git")
set(package_source "https://github.com/Cyan4973/xxHash.git")

if(${package_version} STREQUAL "dev")
elseif(${package_version} STREQUAL "newest" OR ${package_version} STREQUAL "0.6.3")
  set(package_revision "50a564c33c36b3f0c83f027dd21c25cba2967c72")
else()
  message(FATAL_ERROR "Unknown package version. Please use 'dev','newest' or '0.6.3'.")
endif()

function(build_package location)
  # Static library
  rcf_generate(module XXHASH_STATIC xxHash_Static "3rd Party Libraries/xxHash" 
               ${location}/xxhash.c ${location}/xxhash.h)
  AddPublicInclude(XXHASH_STATIC "${location}/")
  rcf_endgenerate()  
  
  # Shared library
  rcf_generate(shared XXHASH_SHARED xxHash_Shared "3rd Party Libraries/xxHash" 
               ${location}/xxhash.c ${location}/xxhash.h)
  AddPublicDefine(XXHASH_SHARED XXHASH_EXPORT)
  AddPublicInclude(XXHASH_SHARED "${location}/")
  rcf_endgenerate()
endfunction()