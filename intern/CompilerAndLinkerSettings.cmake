#[[.rst Compiler and linker setttings
=============================
]]
include("${RCF_PATH}/intern/VisualStudio.cmake")
include("${RCF_PATH}/intern/GCC.cmake")
include("${RCF_PATH}/intern/XCode.cmake")

macro(ConfigureCompilerAndLinker projectid buildtype)
	#
	# Options for general compiler features.
	#
	# To extensive use can slow down the program execution and bloat up the memory usage.
	option(${projectid}_COMPILER_USE_RTTI "Activate runtime type information(Default: off)" OFF)
    mark_as_advanced(${projectid}_COMPILER_USE_RTTI)
	# One of the easiest ways to produce memory leaks if used not correctly. Even then there are still rare cases when a memleak can be produced.
	option(${projectid}_COMPILER_USE_EXCEPTION "Activate exceptions(Default: off)" OFF)
    mark_as_advanced(${projectid}_COMPILER_USE_EXCEPTION)
	# Most compiler support a couple of intrinsic functions which will replace standard C routines(e.g. memcpy).
	option(${projectid}_COMPILER_USE_INTRINSIC "Activate intrinsic functions(Default: on)" ON)
    mark_as_advanced(${projectid}_COMPILER_USE_INTRINSIC)
	# Module support.
	option(${projectid}_COMPILER_EXPORT_AS_MODULE "Generate the project as module(Default: off)" OFF)
    if(${${projectid}_COMPILER_USE_INTRINSIC})
        option(${projectid}_COMPILER_USE_INTRINSIC_MMX "Activate MMX intrinsic functions(Default: on)" ON)
        option(${projectid}_COMPILER_USE_INTRINSIC_SSE "Activate SSE intrinsic functions(Default: on)" ON)
        option(${projectid}_COMPILER_USE_INTRINSIC_SSE2 "Activate SSE2 intrinsic functions(Default: on)" ON)
        option(${projectid}_COMPILER_USE_INTRINSIC_SSE3 "Activate SSE3 intrinsic functions(Default: on)" ON)
        option(${projectid}_COMPILER_USE_INTRINSIC_SSSE3 "Activate SSSE3 intrinsic functions(Default: on)" ON)
        option(${projectid}_COMPILER_USE_INTRINSIC_SSE41 "Activate SSE4.1 intrinsic functions(Default: on)" ON)
        option(${projectid}_COMPILER_USE_INTRINSIC_SSE42 "Activate SSE4.2 intrinsic functions(Default: on)" ON)
        option(${projectid}_COMPILER_USE_INTRINSIC_SSE4A "Activate SSE4A intrinsic functions(Default: on)" ON)
        option(${projectid}_COMPILER_USE_INTRINSIC_AVX "Activate AVX intrinsic functions(Default: on)" ON)
        option(${projectid}_COMPILER_USE_INTRINSIC_AVX2 "Activate AVX2 intrinsic functions(Default: on)" ON)
        option(${projectid}_COMPILER_USE_INTRINSIC_AVX512 "Activate AVX512 intrinsic functions(Default: on)" ON)
        option(${projectid}_COMPILER_USE_INTRINSIC_FMA3 "Activate FMA3 intrinsic functions(Default: on)" ON)
        option(${projectid}_COMPILER_USE_INTRINSIC_FMA4 "Activate FMA4 intrinsic functions(Default: on)" ON)
        option(${projectid}_COMPILER_USE_INTRINSIC_NEON "Activate NEON intrinsic functions(Default: on)" ON)
        option(${projectid}_COMPILER_USE_INTRINSIC_AES "Activate AES intrinsic functions(Default: on)" ON)
        option(${projectid}_COMPILER_USE_INTRINSIC_XOP "Activate XOP intrinsic functions(Default: on)" ON)
        option(${projectid}_COMPILER_USE_INTRINSIC_SHA1 "Activate SHA128 intrinsic functions(Default: on)" ON)
        option(${projectid}_COMPILER_USE_INTRINSIC_SHA2 "Activate SHA256 intrinsic functions(Default: on)" ON)
        option(${projectid}_COMPILER_USE_INTRINSIC_CRC32 "Activate CRC32 intrinsic functions(Default: on)" ON)
        option(${projectid}_COMPILER_USE_INTRINSIC_CPUID "Activate CPUID intrinsic functions(Default: on)" ON)
        mark_as_advanced(FORCE ${projectid}_COMPILER_USE_INTRINSIC_MMX ${projectid}_COMPILER_USE_INTRINSIC_SSE
            ${projectid}_COMPILER_USE_INTRINSIC_SSE2 ${projectid}_COMPILER_USE_INTRINSIC_SSE3
            ${projectid}_COMPILER_USE_INTRINSIC_SSSE3 ${projectid}_COMPILER_USE_INTRINSIC_SSE41
            ${projectid}_COMPILER_USE_INTRINSIC_SSE42 ${projectid}_COMPILER_USE_INTRINSIC_SSE4A
            ${projectid}_COMPILER_USE_INTRINSIC_AVX ${projectid}_COMPILER_USE_INTRINSIC_AVX2
            ${projectid}_COMPILER_USE_INTRINSIC_AVX512 ${projectid}_COMPILER_USE_INTRINSIC_FMA3
            ${projectid}_COMPILER_USE_INTRINSIC_FMA4 ${projectid}_COMPILER_USE_INTRINSIC_NEON
            ${projectid}_COMPILER_USE_INTRINSIC_AES ${projectid}_COMPILER_USE_INTRINSIC_XOP
            ${projectid}_COMPILER_USE_INTRINSIC_SHA1 ${projectid}_COMPILER_USE_INTRINSIC_SHA2
            ${projectid}_COMPILER_USE_INTRINSIC_CRC32 ${projectid}_COMPILER_USE_INTRINSIC_CPUID)
    endif()
	# Many bugs exists because this switch is turned off.
	option(${projectid}_COMPILER_TREAT_WARNINGS_AS_ERROR "Treat warnings as error(Default: on)" ON)
    mark_as_advanced(${projectid}_COMPILER_TREAT_WARNINGS_AS_ERROR)
	# A project which use dynamic linking need the libcrt.so/msvcrt.dll shared library on the target system to run.
	# Static linking increase the size of the binary but don't need further shared libraries.
	option(${projectid}_COMPILER_STATIC_LINKED_CRT "Told the compiler to compile the C runtime library functions or link them." OFF)
    mark_as_advanced(${projectid}_COMPILER_STATIC_LINKED_CRT)
	#option(${projectid}_COMPILER_WARNING)
	
	#
	# Options for general linker features.
	#
	if(${buildtype} STREQUAL "EXECUTABLE")
		# This option mostly used for the demo scene and embedded systems as like consoles.
		option(${projectid}_LINKER_USE_DEFAULTLIB "Use C runtime library and other system specific default libraries(Default: on)" ON)
        mark_as_advanced(${projectid}_LINKER_USE_DEFAULTLIB)
		# Mostly used in combination with DEFAULTLIB=OFF to build ultra small binaries.
		option(${projectid}_LINKER_USE_DEFAULTENTRYPOINT "Use the target system default entry point(Default: on)" ON)
        mark_as_advanced(${projectid}_LINKER_USE_DEFAULTENTRYPOINT)
		if(NOT ${${projectid}_LINKER_USE_DEFAULTENTRYPOINT})
			set(${projectid}_LINKER_ENTRYPOINT "entrypoint" CACHE STRING "Custom entry point(Default: entry")
            mark_as_advanced(${projectid}_LINKER_ENTRYPOINT)
		endif()
		option(${projectid}_LINKER_USE_WINDOW "The executable will contain at least one window(Default: off)." OFF)
	endif()
	
	# This allow to add and compile asm files commonly named with .s as extension
	enable_language(ASM)
	
	#
	# Initialize compiler flags.
	#
	# This flags will be merged into all compiler targets.
	set(${projectid}_COMPILER_FLAGS "")
	# This flags will be used for Debug target.
	set(${projectid}_COMPILER_FLAGS_DEBUG "")
	# This flags will be used for Release target.
	set(${projectid}_COMPILER_FLAGS_RELEASE "")
	# This flags will be used for "minimized Release" target.
	set(${projectid}_COMPILER_FLAGS_RELMINSIZE "")
	# This flags will be used for "Release with debug infos" target.
	set(${projectid}_COMPILER_FLAGS_RELWITHDEBINFO "")

	#
	# Initialize assembler compiler flags.
	#
	# This flags will be merged into all compiler targets.
	set(${projectid}_ASM_COMPILER_FLAGS "")
	# This flags will be used for Debug target.
	set(${projectid}_ASM_COMPILER_FLAGS_DEBUG "")
	# This flags will be used for Release target.
	set(${projectid}_ASM_COMPILER_FLAGS_RELEASE "")
	# This flags will be used for "minimized Release" target.
	set(${projectid}_ASM_COMPILER_FLAGS_RELMINSIZE "")
	# This flags will be used for "Release with debug infos" target.
	set(${projectid}_ASM_COMPILER_FLAGS_RELWITHDEBINFO "")
	
	#
	# Initialize linker flags.
	#
	if(${buildtype} STREQUAL "EXECUTABLE")
		# This flags will be merged into all linker targets.
		set(${projectid}_LINKER_FLAGS "")
		# This flags will be used for Debug target.
		set(${projectid}_LINKER_FLAGS_DEBUG "")
		# This flags will be used for Release target.
		set(${projectid}_LINKER_FLAGS_RELEASE "")
		# This flags will be used for "minimized Release" target.
		set(${projectid}_LINKER_FLAGS_RELMINSIZE "")
		# This flags will be used for "Release with debug infos" target.
		set(${projectid}_LINKER_FLAGS_RELWITHDEBINFO "")
	endif()
	
	#
	# Initialize necessary library list.
	#

	#
	# Include all compiler files.
	# Each include must handle it self.
	#
	ConfigureCompilerAndLinkerVS(${projectid} ${buildtype})
	ConfigureCompilerAndLinkerGCC(${projectid} ${buildtype})
	ConfigureCompilerAndLinkerXCode(${projectid} ${buildtype})

	#
	# gather hardware dependent information
	#
    set(${projectid}_COMPILEDFORARCHITECTURE ${${CMAKE_PROJECT_NAME}_COMPILEDFORARCHITECTURE})
    set(${projectid}_ENDIANNESS ${${CMAKE_PROJECT_NAME}_ENDIANNESS})
    
endmacro()

macro(FinalizeCompilerAndLinkerSettings projectid)
    # Disable all flags and set them per target and config.
    # This ensures that no default flags are added to the project like exceptions on VC++.
	set(CMAKE_ASM_FLAGS "")
    set(CMAKE_C_FLAGS "")
    set(CMAKE_CXX_FLAGS "")
    
	# following macros will attach the defines to the compiler targets in the format
	# they need them
	ProcessDefinesVS(${projectid})
	ProcessDefinesGCC(${projectid})
	ProcessDefinesXCode(${projectid})

    message(STATUS "flags: ${${projectid}_COMPILER_FLAGS}")
	set_target_properties(${${projectid}_NAME} PROPERTIES COMPILE_FLAGS ${${projectid}_COMPILER_FLAGS})
	if(NOT ${${projectid}_WHAT} STREQUAL "HEADERONLY")
    	target_compile_options(${${projectid}_NAME} PRIVATE $<$<CONFIG:DEBUG>:${${projectid}_COMPILER_FLAGS_DEBUG}> $<$<CONFIG:RELEASE>:${${projectid}_COMPILER_FLAGS_RELEASE}> $<$<CONFIG:RELWITHDEBINFO>:${${projectid}_COMPILER_FLAGS_RELWITHDEBINFO}> $<$<CONFIG:MINSIZEREL>:${${projectid}_COMPILER_FLAGS_RELMINSIZE}>)
	endif()

    if(${${projectid}_WHAT} STREQUAL "EXECUTABLE")    
        if (NOT ${${projectid}_LINKER_FLAGS} STREQUAL "")
            set_target_properties(${${projectid}_NAME} PROPERTIES LINK_FLAGS ${${projectid}_LINKER_FLAGS})
        endif()
        if (NOT ${${projectid}_LINKER_FLAGS_DEBUG} STREQUAL "")
            set_target_properties(${${projectid}_NAME} PROPERTIES LINK_FLAGS_DEBUG ${${projectid}_LINKER_FLAGS_DEBUG})
        endif()
        if (NOT ${${projectid}_LINKER_FLAGS_RELEASE} STREQUAL "")
            set_target_properties(${${projectid}_NAME} PROPERTIES LINK_FLAGS_RELEASE ${${projectid}_LINKER_FLAGS_RELEASE})
        endif()
        if (NOT ${${projectid}_LINKER_FLAGS_RELWITHDEBINFO} STREQUAL "")
            set_target_properties(${${projectid}_NAME} PROPERTIES LINK_FLAGS_RELWITHDEBINFO ${${projectid}_LINKER_FLAGS_RELWITHDEBINFO})
        endif()
        if (NOT ${${projectid}_LINKER_FLAGS_RELMINSIZE} STREQUAL "")
            set_target_properties(${${projectid}_NAME} PROPERTIES LINK_FLAGS_MINSIZEREL ${${projectid}_LINKER_FLAGS_RELMINSIZE})
        endif()
    endif()
    
    if(TARGET ${${projectid}_NAME})
      set_target_properties(${${projectid}_NAME} PROPERTIES DEBUG_POSTFIX ${CMAKE_DEBUG_POSTFIX})
      set_target_properties(${${projectid}_NAME} PROPERTIES RELMINSIZE_POSTFIX ${CMAKE_RELMINSIZE_POSTFIX})
      set_target_properties(${${projectid}_NAME} PROPERTIES RELWITHDEBINFO_POSTFIX ${CMAKE_RELWITHDEBINFO_POSTFIX})
      set_target_properties(${${projectid}_NAME} PROPERTIES LIBRARY_OUTPUT_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}" )          
      set_target_properties(${${projectid}_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}" )          
      set_target_properties(${${projectid}_NAME} PROPERTIES ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}" )          
    endif()

	rcf_file_specific_flags_VS(${projectid})
endmacro()