#
# This file will help you to integrate a Radon CMake framework based project into your project.
# http://www.radonframework.org/projects/rf/wiki/UserManualCMakeFramework
# http://www.radonframework.org/projects/rf/wiki/DeveloperManualCMakeFramework
#
include("${${CMAKE_PROJECT_NAME}_PATH}/intern/VisualGDB.cmake")
include(CHECK_INCLUDE_FILES)

macro(ConfigureCompilerAndLinkerVS projectid buildtype)
	if(MSVC)
        CheckIntrinsicSupportVS(${projectid})
		#
		# Options for general compiler features.
		#
		if(${${projectid}_COMPILER_USE_RTTI})
			set(${projectid}_COMPILER_FLAGS "${${projectid}_COMPILER_FLAGS} /GR")
		else()
			set(${projectid}_COMPILER_FLAGS "${${projectid}_COMPILER_FLAGS} /GR-")
		endif()
		
		# _HAS_EXCEPTIONS will be used by STL to figure out if exceptions should be used.
		if (${${projectid}_COMPILER_USE_EXCEPTION})
			set(${projectid}_COMPILER_FLAGS "${${projectid}_COMPILER_FLAGS} /EHsc /D_HAS_EXCEPTIONS=1")
		else()
			set(${projectid}_COMPILER_FLAGS "${${projectid}_COMPILER_FLAGS} /D_HAS_EXCEPTIONS=0")
		endif()
		
		if(${${projectid}_COMPILER_USE_INTRINSIC})
			set(${projectid}_COMPILER_FLAGS "${${projectid}_COMPILER_FLAGS} /Oi")
		endif()

		if(${${projectid}_COMPILER_TREAT_WARNINGS_AS_ERROR})
			set(${projectid}_COMPILER_FLAGS "${${projectid}_COMPILER_FLAGS} /WX")
		else()
			set(${projectid}_COMPILER_FLAGS "${${projectid}_COMPILER_FLAGS} /WX-")
		endif()
		
		if(${buildtype} STREQUAL "EXECUTABLE")
			if(NOT ${${projectid}_LINKER_USE_DEFAULTLIB})
				set(${projectid}_LINKER_FLAGS "${${projectid}_LINKER_FLAGS} /NODEFAULTLIB")
			endif()		
			
			message(STATUS "--> ${projectid}_LINKER_USE_WINDOW = ${${projectid}_LINKER_USE_WINDOW}")
			if(${${projectid}_LINKER_USE_WINDOW})
				set(${projectid}_LINKER_FLAGS "${${projectid}_LINKER_FLAGS} /SUBSYSTEM:WINDOWS")
			message(STATUS "--> ${${projectid}_LINKER_FLAGS}")
				endif()
			
			if(NOT ${${projectid}_LINKER_USE_DEFAULTENTRYPOINT})
				set(${projectid}_LINKER_FLAGS "${${projectid}_LINKER_FLAGS} /ENTRY:\"${${projectid}_LINKER_ENTRYPOINT}\"")
			endif()			
		endif()
		
		if (${${projectid}_LINKER_STATIC_LINKED_CRT})
			# MT/MTd = Link against runtime multithreaded and multithreaded debug static library.
			# NDEBUG/_DEBUG = Signal the MS CRT if it's debug build or not.
			set(${projectid}_COMPILER_FLAGS_DEBUG "${${projectid}_COMPILER_FLAGS_DEBUG} /MTd /D_DEBUG")
			set(${projectid}_COMPILER_FLAGS_RELEASE "${${projectid}_COMPILER_FLAGS_RELEASE} /MT /D NDEBUG")
			set(${projectid}_COMPILER_FLAGS_RELWITHDEBINFO "${${projectid}_COMPILER_FLAGS_RELWITHDEBINFO} /MT /D NDEBUG")
			set(${projectid}_COMPILER_FLAGS_RELMINSIZE "${${projectid}_COMPILER_FLAGS_RELMINSIZE} /MT /D NDEBUG")		
		else()
			# MD/MDd = Link against runtime multithreaded and multithreaded debug shared library.
			# NDEBUG/_DEBUG = Signal the MS CRT if it's debug build or not.
			set(${projectid}_COMPILER_FLAGS_DEBUG "${${projectid}_COMPILER_FLAGS_DEBUG} /MDd /D_DEBUG")
			set(${projectid}_COMPILER_FLAGS_RELEASE "${${projectid}_COMPILER_FLAGS_RELEASE} /MD /D NDEBUG")
			set(${projectid}_COMPILER_FLAGS_RELWITHDEBINFO "${${projectid}_COMPILER_FLAGS_RELWITHDEBINFO} /MD /D NDEBUG")
			set(${projectid}_COMPILER_FLAGS_RELMINSIZE "${${projectid}_COMPILER_FLAGS_RELMINSIZE} /MD /D NDEBUG")		
			
			if(NOT ${${projectid}_COMPILER_USE_EXCEPTION})
				# VS2010 have some bugs in STL with wrong defines related to dynamic crt and disabled exceptions(fixed since VS2012)
				set(${projectid}_COMPILER_FLAGS "${${projectid}_COMPILER_FLAGS} /wd4275")
			endif()
		endif()
		
		#
		# Compiler specific settings
		#
		
		# Activate string pooling.
		# This feature will reduce the binary size and increase cache hits.
		set(${projectid}_COMPILER_FLAGS "${${projectid}_COMPILER_FLAGS} /GF")
		
		# Set single byte character string because it's compatible with ANSI/ASCII/UTF8.
		# Windows API's always probe the right encode for a string, independent of which
		# character encoding was used.
		set(${projectid}_COMPILER_FLAGS "${${projectid}_COMPILER_FLAGS} /D_SBCS")

		# Inline Function Expansion
		# Ob0 = disable inline function
		# Ob1 = only __inline marked functions will be inlined
		# Ob2 = any suitable function will be inlined(e.g. getter/setter functions)
		set(${projectid}_COMPILER_FLAGS_DEBUG "${${projectid}_COMPILER_FLAGS_DEBUG} /Ob0")
		set(${projectid}_COMPILER_FLAGS_RELEASE "${${projectid}_COMPILER_FLAGS_RELEASE} /Ob2")
		set(${projectid}_COMPILER_FLAGS_RELWITHDEBINFO "${${projectid}_COMPILER_FLAGS_RELWITHDEBINFO} /Ob2")
		set(${projectid}_COMPILER_FLAGS_RELMINSIZE "${${projectid}_COMPILER_FLAGS_RELMINSIZE} /Ob1")		

		# Debug Information Format
		set(${projectid}_COMPILER_FLAGS_DEBUG "${${projectid}_COMPILER_FLAGS_DEBUG} /Zi")
		set(${projectid}_COMPILER_FLAGS_RELWITHDEBINFO "${${projectid}_COMPILER_FLAGS_RELWITHDEBINFO} /Zi")
		
		# Basic Runtime Checks
		set(${projectid}_COMPILER_FLAGS_DEBUG "${${projectid}_COMPILER_FLAGS_DEBUG} /RTC1")
		
		# Optimization
		# Od = disabled
		# O1 = minimize size
		# O2 = maximize speed		
		set(${projectid}_COMPILER_FLAGS_DEBUG "${${projectid}_COMPILER_FLAGS_DEBUG} /Od")
		set(${projectid}_COMPILER_FLAGS_RELEASE "${${projectid}_COMPILER_FLAGS_RELEASE} /O2")
		set(${projectid}_COMPILER_FLAGS_RELWITHDEBINFO "${${projectid}_COMPILER_FLAGS_RELWITHDEBINFO} /O2")
		set(${projectid}_COMPILER_FLAGS_RELMINSIZE "${${projectid}_COMPILER_FLAGS_RELMINSIZE} /O1")		
		
		# Activate multi-processor compiling.
		set(${projectid}_COMPILER_FLAGS "${${projectid}_COMPILER_FLAGS} /MP")
	
		# Ot = favor speed
		# Os = favor size
		set(${projectid}_COMPILER_FLAGS_RELEASE "${${projectid}_COMPILER_FLAGS_RELEASE} /Ot")
		set(${projectid}_COMPILER_FLAGS_RELWITHDEBINFO "${${projectid}_COMPILER_FLAGS_RELWITHDEBINFO} /Ot")
		set(${projectid}_COMPILER_FLAGS_RELMINSIZE "${${projectid}_COMPILER_FLAGS_RELMINSIZE} /Os")
		
		# GS-/+ = Buffer Security Check off/on
		set(${projectid}_COMPILER_FLAGS_DEBUG "${${projectid}_COMPILER_FLAGS_DEBUG} /GS")
		set(${projectid}_COMPILER_FLAGS_RELEASE "${${projectid}_COMPILER_FLAGS_RELEASE} /GS-")
		set(${projectid}_COMPILER_FLAGS_RELWITHDEBINFO "${${projectid}_COMPILER_FLAGS_RELWITHDEBINFO} /GS-")
		set(${projectid}_COMPILER_FLAGS_RELMINSIZE "${${projectid}_COMPILER_FLAGS_RELMINSIZE} /GS-")
		
		# struct byte alignment
		set(${projectid}_COMPILER_FLAGS "${${projectid}_COMPILER_FLAGS} /Zp16")
		
		# OPT:REF = Remove unused references.
		# OPT:ICF = Combine same code chunks into one and point to the shared code.
		set(${projectid}_COMPILER_FLAGS_RELEASE "${${projectid}_COMPILER_FLAGS_RELEASE} /OPT:REF /OPT:ICF")
		set(${projectid}_COMPILER_FLAGS_RELMINSIZE "${${projectid}_COMPILER_FLAGS_RELMINSIZE} /OPT:REF /OPT:ICF")
		
		#
		# fix visual studio output directory
		#
		if ("${CMAKE_GENERATOR}" MATCHES "Visual Studio")
		  foreach (config ${CMAKE_CONFIGURATION_TYPES})
			string(TOUPPER ${config} config_upper)
			set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${config_upper} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
			set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${config_upper} ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY})
			set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${config_upper} ${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
		  endforeach ()
		endif ()	
	endif()
endmacro()

macro(ProcessDefinesVS projectid)
	if(MSVC)
		foreach(flag ${${projectid}_COMPILER_DEFINES})
			set(${projectid}_COMPILER_FLAGS "${${projectid}_COMPILER_FLAGS} /D${flag}")
		endforeach()
		
		foreach(flag ${${projectid}_COMPILER_DEFINES_DEBUG})
			set(${projectid}_COMPILER_FLAGS_DEBUG "${${projectid}_COMPILER_FLAGS_DEBUG} /D${flag}")
		endforeach()
		
		foreach(flag ${${projectid}_COMPILER_DEFINES_RELEASE})
			set(${projectid}_COMPILER_FLAGS_RELEASE "${${projectid}_COMPILER_FLAGS_RELEASE} /D${flag}")
		endforeach()
		
		foreach(flag ${${projectid}_COMPILER_DEFINES_RELMINSIZE})
			set(${projectid}_COMPILER_FLAG_RELMINSIZE "${${projectid}_COMPILER_FLAGS_RELMINSIZE} /D${flag}")
		endforeach()
		
		foreach(flag ${${projectid}_COMPILER_DEFINES_RELWITHDEBINFO})
			set(${projectid}_COMPILER_FLAGS_RELWITHDEBINFO "${${projectid}_COMPILER_FLAGS_RELWITHDEBINFO} /D${flag}")
		endforeach()
	endif()
endmacro()

macro(CheckIntrinsicSupportVS projectid)
    CHECK_INCLUDE_FILES(mmintrin.h HAVE_MMINTRIN_H)
    if(NOT HAVE_MMINTRIN_H)
        set(${projectid}_COMPILER_USE_INTRINSIC_MMX OFF CACHE BOOL "Activate MMX intrinsic functions(Default: on)" FORCE)   
    endif()
    
    CHECK_INCLUDE_FILES(xmmintrin.h HAVE_XMMINTRIN_H)
    if(NOT HAVE_XMMINTRIN_H)
        set(${projectid}_COMPILER_USE_INTRINSIC_SSE OFF CACHE BOOL "Activate SSE intrinsic functions(Default: on)" FORCE)    
    endif()
    
    CHECK_INCLUDE_FILES(emmintrin.h HAVE_EMMINTRIN_H)
    if(NOT HAVE_EMMINTRIN_H)
        set(${projectid}_COMPILER_USE_INTRINSIC_SSE2 OFF CACHE BOOL "Activate SSE2 intrinsic functions(Default: on)" FORCE)
    endif()
    
    CHECK_INCLUDE_FILES(tmmintrin.h HAVE_TMMINTRIN_H)
    if(NOT HAVE_TMMINTRIN_H)
        set(${projectid}_COMPILER_USE_INTRINSIC_SSSE3 OFF CACHE BOOL "Activate SSSE3 intrinsic functions(Default: on)" FORCE)
    endif()

    CHECK_INCLUDE_FILES(pmmintrin.h HAVE_PMMINTRIN_H)
    if(NOT HAVE_PMMINTRIN_H)
        set(${projectid}_COMPILER_USE_INTRINSIC_SSE3 OFF CACHE BOOL "Activate SSE3 intrinsic functions(Default: on)" FORCE)    
    endif()
    
    CHECK_INCLUDE_FILES(wmmintrin.h HAVE_WMMINTRIN_H)
    if(NOT HAVE_WMMINTRIN_H)
        set(${projectid}_COMPILER_USE_INTRINSIC_AES OFF CACHE BOOL "Activate AES intrinsic functions(Default: on)" FORCE)
    endif()
    
    CHECK_INCLUDE_FILES(smmintrin.h HAVE_SMMINTRIN_H)
    if(NOT HAVE_SMMINTRIN_H)
        set(${projectid}_COMPILER_USE_INTRINSIC_SSE41 OFF CACHE BOOL "Activate SSE4.1 intrinsic functions(Default: on)" FORCE)
    endif()    
    
    CHECK_INCLUDE_FILES(immintrin.h HAVE_IMMINTRIN_H)
    if(NOT HAVE_IMMINTRIN_H)
        set(${projectid}_COMPILER_USE_INTRINSIC_AVX OFF CACHE BOOL "Activate AVX intrinsic functions(Default: on)" FORCE)    
        set(${projectid}_COMPILER_USE_INTRINSIC_AVX2 OFF CACHE BOOL "Activate AVX2 intrinsic functions(Default: on)" FORCE)
    endif()  

    CHECK_INCLUDE_FILES("immintrin.h;ammintrin.h" HAVE_AMMINTRIN_H)
    if(NOT HAVE_AMMINTRIN_H)
        set(${projectid}_COMPILER_USE_INTRINSIC_XOP OFF CACHE BOOL "Activate XOP intrinsic functions(Default: on)" FORCE)
        set(${projectid}_COMPILER_USE_INTRINSIC_FMA3 OFF CACHE BOOL "Activate FMA3 intrinsic functions(Default: on)" FORCE)
        set(${projectid}_COMPILER_USE_INTRINSIC_FMA4 OFF CACHE BOOL "Activate FMA4 intrinsic functions(Default: on)" FORCE)
    endif() 
    
    CHECK_INCLUDE_FILES(nmmintrin.h HAVE_NMMINTRIN_H)
    if(NOT HAVE_NMMINTRIN_H)
        set(${projectid}_COMPILER_USE_INTRINSIC_SSE42 OFF CACHE BOOL "Activate SSE4.2 intrinsic functions(Default: on)" FORCE)
    endif()  
    
    CHECK_INCLUDE_FILES(arm_neon.h arm64_neon.h HAVE_ARMNEON_H)
    if(NOT HAVE_ARMNEON_H)
        set(${projectid}_COMPILER_USE_INTRINSIC_NEON OFF CACHE BOOL "Activate NEON intrinsic functions(Default: on)" FORCE)    
    endif() 
    
    CHECK_INCLUDE_FILES(intrin.h HAVE_INTRIN_H)
    if(HAVE_INTRIN_H)
        CHECK_FUNCTION_EXISTS(_mm_stream_ss HAVE_SSE4A)
        if (NOT HAVE_SSE4A)
            set(${projectid}_COMPILER_USE_INTRINSIC_SSE4A OFF CACHE BOOL "Activate SSE4A intrinsic functions(Default: on)" FORCE)        
        endif()
    else()
        set(${projectid}_COMPILER_USE_INTRINSIC_CPUID OFF CACHE BOOL "Activate CPUID intrinsic functions(Default: on)" FORCE)        
    endif()  

    set(${projectid}_COMPILER_USE_INTRINSIC_AVX512 OFF CACHE BOOL "Activate AVX512 intrinsic functions(Default: on)" FORCE)
    set(${projectid}_COMPILER_USE_INTRINSIC_SHA OFF CACHE BOOL "Activate SHA intrinsic functions(Default: on)" FORCE)
endmacro()