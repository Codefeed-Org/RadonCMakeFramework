#[[.rst GCC
===
]]
include(CheckIncludeFiles)

macro(ConfigureCompilerAndLinkerGCC projectid buildtype)
	if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_COMPILER_IS_GNUCC)
        CheckIntrinsicSupportGCC(${projectid})
		set(${projectid}_COMPILER_FLAGS "${${projectid}_COMPILER_FLAGS} -Wno-unknown-pragmas")
        
        # older gcc on raspberry pi 3 have some issues to detect the right architecture
        if(EXISTS "/opt/vc/include/bcm_host.h")
            set(${projectid}_COMPILER_FLAGS "${${projectid}_COMPILER_FLAGS} -march=armv8-a")
        else()
            set(${projectid}_COMPILER_FLAGS "${${projectid}_COMPILER_FLAGS} -march=native")
        endif()
    endif()
endmacro()

macro(ProcessDefinesGCC projectid)
	if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_COMPILER_IS_GNUCC)
        set(CMAKE_C_FLAGS "-std=c11")
        set(CMAKE_CXX_FLAGS "-std=c++11")
    
		foreach(flag ${${projectid}_COMPILER_DEFINES})
			set(${projectid}_COMPILER_FLAGS "${${projectid}_COMPILER_FLAGS} -D${flag}")
		endforeach()
		
		foreach(flag ${${projectid}_COMPILER_DEFINES_DEBUG})
			set(${projectid}_COMPILER_FLAGS_DEBUG "${${projectid}_COMPILER_FLAGS_DEBUG} -D${flag}")
		endforeach()
		
		foreach(flag ${${projectid}_COMPILER_DEFINES_RELEASE})
			set(${projectid}_COMPILER_FLAGS_RELEASE "${${projectid}_COMPILER_FLAGS_RELEASE} -D${flag}")
		endforeach()
		
		foreach(flag ${${projectid}_COMPILER_DEFINES_RELMINSIZE})
			set(${projectid}_COMPILER_FLAG_RELMINSIZE "${${projectid}_COMPILER_FLAGS_RELMINSIZE} -D${flag}")
		endforeach()
		
		foreach(flag ${${projectid}_COMPILER_DEFINES_RELWITHDEBINFO})
			set(${projectid}_COMPILER_FLAGS_RELWITHDEBINFO "${${projectid}_COMPILER_FLAGS_RELWITHDEBINFO} -D${flag}")
		endforeach()	
	endif()
endmacro()

macro(CheckIntrinsicSupportGCC projectid)
    CHECK_INCLUDE_FILES(arm_neon.h HAVE_ARMNEON_H)
    if(NOT HAVE_ARMNEON_H)
        set(${projectid}_COMPILER_USE_INTRINSIC_NEON OFF CACHE BOOL "Activate NEON intrinsic functions(Default: on)" FORCE)    
    else()
        set(${projectid}_COMPILER_FLAGS "${${projectid}_COMPILER_FLAGS} -mfloat-abi=softfp -mpfu=neon")
    endif() 
    
    CHECK_INCLUDE_FILES(cpuid.h HAVE_CPUID_H)
    if(NOT HAVE_CPUID_H)
        set(${projectid}_COMPILER_USE_INTRINSIC_CPUID OFF CACHE BOOL "Activate CPUID intrinsic functions(Default: on)" FORCE)    
    endif()     

    set(${projectid}_COMPILER_USE_INTRINSIC_MMX OFF CACHE BOOL "Activate MMX intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_SSE OFF CACHE BOOL "Activate SSE intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_SSE2 OFF CACHE BOOL "Activate SSE2 intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_SSE3 OFF CACHE BOOL "Activate SSE3 intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_SSSE3 OFF CACHE BOOL "Activate SSSE3 intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_SSE41 OFF CACHE BOOL "Activate SSE4.1 intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_SSE42 OFF CACHE BOOL "Activate SSE4.2 intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_SSE4A OFF CACHE BOOL "Activate SSE4A intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_AVX OFF CACHE BOOL "Activate AVX intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_AVX2 OFF CACHE BOOL "Activate AVX2 intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_AVX512 OFF CACHE BOOL "Activate AVX512 intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_FMA3 OFF CACHE BOOL "Activate FMA3 intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_FMA4 OFF CACHE BOOL "Activate FMA4 intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_AES OFF CACHE BOOL "Activate AES intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_XOP OFF CACHE BOOL "Activate XOP intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_SHA1 OFF CACHE BOOL "Activate SHA128 intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_SHA2 OFF CACHE BOOL "Activate SHA256 intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_CRC32 OFF CACHE BOOL "Activate CRC32 intrinsic functions(Default: on)" FORCE)
endmacro()