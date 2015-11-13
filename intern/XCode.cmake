#
# This file will help you to integrate a Radon CMake framework based project into your project.
# http://www.radonframework.org/projects/rf/wiki/UserManualCMakeFramework
# http://www.radonframework.org/projects/rf/wiki/DeveloperManualCMakeFramework
#
macro(ConfigureCompilerAndLinkerXCode projectid buildtype)
	if(CMAKE_GENERATOR STREQUAL Xcode)
        CheckIntrinsicSupportXCode(${projectid})
        set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++11")
        set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++")
		set(${projectid}_COMPILER_FLAGS "-std=c++11 -stdlib=libc++ ${${projectid}_COMPILER_FLAGS} -msse4.2")
	endif()
endmacro()

macro(ProcessDefinesXCode projectid)
	if(CMAKE_GENERATOR STREQUAL Xcode)
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

macro(CheckIntrinsicSupportXCode projectid)
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
    set(${projectid}_COMPILER_USE_INTRINSIC_NEON OFF CACHE BOOL "Activate NEON intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_AES OFF CACHE BOOL "Activate AES intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_XOP OFF CACHE BOOL "Activate XOP intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_SHA OFF CACHE BOOL "Activate SHA intrinsic functions(Default: on)" FORCE)
endmacro()