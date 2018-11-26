#[[.rst Macros
======
]]
function(AddResources projectid location destination)
    if (IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${location})
        set(mode copy_directory)
    else()
        set(mode copy_if_different)
    endif()
    
    add_custom_command(TARGET ${${projectid}_NAME} 
        POST_BUILD 
        COMMAND ${CMAKE_COMMAND} -E ${mode} ${CMAKE_CURRENT_SOURCE_DIR}/${location} ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${destination})
endfunction()

function(AddSourceDirectory var)
	# - Add a directory to the current project.
	string(REGEX REPLACE "/" "\\\\" locale_SourceGroupPath ${ARGV2} )
	list(LENGTH ARGN num_of_args)
	if (${num_of_args} EQUAL 3)
		file(GLOB locale_files RELATIVE ${ARGV3} ${ARGV1}/[^.]*.cc ${ARGV1}/[^.]*.cpp ${ARGV1}/[^.]*.c  ${ARGV1}/[^.]*.mpp)
	else()
		file(GLOB locale_files ${ARGV1}/[^.]*.cc ${ARGV1}/[^.]*.cpp ${ARGV1}/[^.]*.c ${ARGV1}/[^.]*.mpp)
	endif()
	source_group(${locale_SourceGroupPath} FILES ${locale_files})	
	set("${var}" ${locale_files} PARENT_SCOPE)
	foreach(src ${locale_files})
		# If the file extension is a module file then handle it like a c++ file.  
		get_filename_component(fileextension ${src} EXT)
		if (${fileextension} MATCHES ".mpp$")
			set_source_files_properties("${src}" PROPERTIES LANGUAGE CXX)
		endif()
	endforeach()
endfunction()

function(AddHeaderDirectory var)	
	# - Add a directory to the current project.
	string(REGEX REPLACE "/" "\\\\" locale_HeaderGroupPath ${ARGV2} )
	list(LENGTH ARGN num_of_args)
	if (${num_of_args} EQUAL 3)	
		file(GLOB locale_files RELATIVE ${ARGV3} ${ARGV1}/[^.]*.h ${ARGV1}/[^.]*.hpp)
	else()
		file(GLOB locale_files ${ARGV1}/[^.]*.h ${ARGV1}/[^.]*.hpp)
	endif()
	source_group(${locale_HeaderGroupPath} FILES ${locale_files})	
	set("${var}" ${locale_files} PARENT_SCOPE)
endfunction()

function(AddAssemberDirectory var)	
	# - Add a directory to the current project.
	string(REGEX REPLACE "/" "\\\\" locale_HeaderGroupPath ${ARGV2} )
	list(LENGTH ARGN num_of_args)
	if (${num_of_args} EQUAL 3)	
		file(GLOB locale_files RELATIVE ${ARGV3} ${ARGV1}/[^.]*.s ${ARGV1}/[^.]*.asm)
	else()
		file(GLOB locale_files ${ARGV1}/[^.]*.s ${ARGV1}/[^.]*.asm)
	endif()
	source_group(${locale_HeaderGroupPath} FILES ${locale_files})	
	set("${var}" ${locale_files} PARENT_SCOPE)
	set_property(SOURCE ${locale_files} PROPERTY LANGUAGE ASM)	
endfunction()

function(AddHeaderDirectoryRecursive var)	
	# - Add a directory to the current project.
	string(REGEX REPLACE "/" "\\\\" locale_HeaderGroupPath ${ARGV2} )
	list(LENGTH ARGN num_of_args)
    file(GLOB_RECURSE locale_files ${ARGV1}/[^.]*.h ${ARGV1}/[^.]*.hpp)
	foreach(hdr ${locale_files})
        if (${num_of_args} EQUAL 3)
            string(REGEX REPLACE "${ARGV3}" "" REL_DIR "${hdr}")
        else()
            string(REGEX REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/${ARGV1}" "" REL_DIR "${hdr}")
        endif()
		string(REGEX REPLACE "[\\\\/][^\\\\/]*$" "" REL_DIR "${REL_DIR}")		
		string(REGEX REPLACE "^[\\\\/]" "" REL_DIR "${REL_DIR}")
		string(REGEX REPLACE "/" "\\\\" REL_DIR "${REL_DIR}" )
		source_group("${ARGV2}\\${REL_DIR}" FILES ${hdr})
	endforeach()
	set("${var}" ${locale_files} PARENT_SCOPE)
endfunction()

function(AddSourceDirectoryRecursive var)	
	# - Add a directory to the current project.
	string(REGEX REPLACE "/" "\\\\" locale_SourceGroupPath ${ARGV2} )
	list(LENGTH ARGN num_of_args)
    file(GLOB_RECURSE locale_files ${ARGV1}/[^.]*.cc ${ARGV1}/[^.]*.cpp ${ARGV1}/[^.]*.c ${ARGV1}/[^.]*.mpp)
	foreach(src ${locale_files})
        if (${num_of_args} EQUAL 3)
            string(REGEX REPLACE "${ARGV3}" "" REL_DIR "${src}")
        else()
            string(REGEX REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/${ARGV1}" "" REL_DIR "${src}")
        endif()
		string(REGEX REPLACE "[\\\\/][^\\\\/]*$" "" REL_DIR "${REL_DIR}")		
		string(REGEX REPLACE "^[\\\\/]" "" REL_DIR "${REL_DIR}")
		string(REGEX REPLACE "/" "\\\\" REL_DIR "${REL_DIR}" )
		source_group("${ARGV2}\\${REL_DIR}" FILES ${src})
		# If the file extension is a module file then handle it like a c++ file.  
		get_filename_component(fileextension ${src} EXT)
		if (${fileextension} MATCHES ".mpp$")
			set_source_files_properties("${src}" PROPERTIES LANGUAGE CXX)
		endif()
	endforeach()
	set("${var}" ${locale_files} PARENT_SCOPE)
endfunction()

#[[.rst .. cmake:function:: rcf_get_current_projectid(writeTo)

  Obtain the project id of the current target. This function must be called after
  rcf_generate(...) and before rcf_endgenerate(...).

  :param writeTo: The target at which the project id will be written at.
]]
function(rcf_get_current_projectid writeTo)
	set(projects ${RCF_GENERATE_SCOPE_STACK})	
	list(LENGTH projects last)
	math(EXPR last ${last}-1)
	list(GET projects ${last} projectid)
	set(${writeTo} ${projectid} PARENT_SCOPE)
endfunction()

#[[.rst .. cmake:function:: rcf_add_recursive(rootdir suggested_ide_dirname)

  This function will add recursive all header and source files of the specified 
  directory and their childs. If the cmake generator supports virtual folder 
  then the files will be placed relative to the specified name.

  :param rootdir: Specifies the directory at which the files should be searched.
  :param suggested_ide_dirname: Name of the virtual folder which should be used in the IDE.
]]
function(rcf_add_recursive rootdir suggested_ide_dirname)
	AddSourceDirectoryRecursive(src_list ${rootdir} ${suggested_ide_dirname})
	AddHeaderDirectoryRecursive(hdr_list ${rootdir} ${suggested_ide_dirname})
	rcf_get_current_projectid(projectid)
	target_sources(${${projectid}_NAME} PRIVATE ${${projectid}_FILES} ${src_list} ${hdr_list})
endfunction()

function(AddAssemblerDirectoryRecursive var)	
	# - Add a directory to the current project.
	string(REGEX REPLACE "/" "\\\\" locale_SourceGroupPath ${ARGV2} )
	list(LENGTH ARGN num_of_args)
    file(GLOB_RECURSE locale_files ${ARGV1}/[^.]*.asm ${ARGV1}/[^.]*.s)
	foreach(src ${locale_files})
        if (${num_of_args} EQUAL 3)
            string(REGEX REPLACE "${ARGV3}" "" REL_DIR "${src}")
        else()
            string(REGEX REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/${ARGV1}" "" REL_DIR "${hdr}")
        endif()
		string(REGEX REPLACE "[\\\\/][^\\\\/]*$" "" REL_DIR "${REL_DIR}")		
		string(REGEX REPLACE "^[\\\\/]" "" REL_DIR "${REL_DIR}")
		string(REGEX REPLACE "/" "\\\\" REL_DIR "${REL_DIR}" )
		source_group("${ARGV2}\\${REL_DIR}" FILES ${src})
		set_property(SOURCE ${src} PROPERTY LANGUAGE ASM)
	endforeach()
	set("${var}" ${locale_files} PARENT_SCOPE)
endfunction()

macro(CreatePrecompiledHeader projectid _header _source _sourceList)
	set(${projectid}_PRECOMPILED_HEADER ${_header})
	set(${projectid}_PRECOMPILED_SOURCE ${_source})
	set(${projectid}_PRECOMPILED_FILES ${_sourceList})
	
    if(MSVC)
		get_filename_component(PrecompiledBasename ${_header} NAME_WE)
		set(PrecompiledBinary "$(IntDir)/${PrecompiledBasename}.pch")
		
		set(Sources ${${_sourceList}})
		set_source_files_properties(${Sources} PROPERTIES COMPILE_FLAGS "/Yu\"${PrecompiledBinary}\" /FI\"${PrecompiledBinary}\" /Fp\"${PrecompiledBinary}\"" OBJECT_DEPENDS "${PrecompiledBinary}")
        set_source_files_properties(${_source} PROPERTIES COMPILE_FLAGS "/Yc\"${_header}\" /Fp\"${PrecompiledBinary}\"" OBJECT_OUTPUTS "${PrecompiledBinary}")		
		list(APPEND ${_sourceList} ${_source})
    endif()
endmacro()

macro(SubDirlist curdir result)
  file(GLOB children RELATIVE ${curdir} ${curdir}/*)
  set(dirlist "")
  foreach(child ${children})
    if(IS_DIRECTORY ${curdir}/${child})
        set(dirlist ${dirlist} ${child})
    endif()
  endforeach()
  set(${result} ${dirlist})
endmacro()

macro(AddPublicInclude projectid addpath)
	set(${projectid}_PUBLIC_INCLUDES ${${projectid}_PUBLIC_INCLUDES} ${addpath} CACHE INTERNAL "include directories")
	include_directories(${addpath})
endmacro()

#[[.rst .. cmake:function:: rcf_add_public_include(addpath)

  Add the specified path to the public include directories.
  This function calls include_directories(), keep track of the public directories
  and add the directories to all targets which depend on the current target.

  :param addpath: The directory which should be added to the public include list.
]]
function(rcf_add_public_include addpath)
	rcf_get_current_projectid(projectid)
	set(${projectid}_PUBLIC_INCLUDES ${${projectid}_PUBLIC_INCLUDES} ${addpath} CACHE INTERNAL "include directories")
	include_directories(${addpath})
endfunction()

macro(AddPublicDefine projectid)
	set(${projectid}_COMPILER_DEFINES "${${projectid}_COMPILER_DEFINES};${ARGN}" CACHE INTERNAL "Project public defines")
endmacro()

macro(AddPublicTargetDefine projectid target)
	set(${projectid}_COMPILER_DEFINES_${target} "${${projectid}_COMPILER_DEFINES_${target}};${ARGN}" CACHE INTERNAL "Project public defines")
endmacro()

macro(AddPrivateDefine define)
	add_definitions("-D${define}")
endmacro()

if(NOT DEFINED ${CMAKE_PROJECT_NAME}_ADDED_SUBDIRECTORIES)
	set(${CMAKE_PROJECT_NAME}_ADDED_SUBDIRECTORIES "" CACHE INTERNAL "List of all source_dir passed to add_subdirectory.")
endif()

#[[.rst .. cmake:function:: rcf_add_subdirectory_once(source_dir)

  Add the specified directory if not happend yet and block upcomming request.
  The function use a internal list to remember all added directories by this function.
  If you want to execute a script only once per run then use rcf_add_subdirectory_once_per_run().

  :param source_dir: The directory which should be added to CMake and executed.
]]
macro(rcf_add_subdirectory_once source_dir)
	if(NOT ";${source_dir};" MATCHES ";${${CMAKE_PROJECT_NAME}_ADDED_SUBDIRECTORIES};")
		add_subdirectory(${source_dir} ${ARGN})
		list(APPEND ${CMAKE_PROJECT_NAME}_ADDED_SUBDIRECTORIES ${source_dir})
	endif()
endmacro()

set(${CMAKE_PROJECT_NAME}_ADDED_SUBDIRECTORIES_CURRENT_RUN "" CACHE INTERNAL "List of all source_dir passed to add_subdirectory.")

#[[.rst .. cmake:function:: rcf_add_subdirectory_once_per_run(source_dir)

  Add the specified directory if not happend yet and block upcomming request for this run.
  The function use a internal list to remember all added directories by this function.
  If you want to execute a script only once over multiple runs then use rcf_add_subdirectory_once().

  :param source_dir: The directory which should be added to CMake and executed.
]]
macro(rcf_add_subdirectory_once_per_run source_dir)
	if(NOT ";${source_dir};" MATCHES ";${${CMAKE_PROJECT_NAME}_ADDED_SUBDIRECTORIES_CURRENT_RUN};")
		add_subdirectory(${source_dir} ${ARGN})
		list(APPEND ${CMAKE_PROJECT_NAME}_ADDED_SUBDIRECTORIES_CURRENT_RUN ${source_dir})
	endif()
endmacro()

macro(rcf_add_internal variable entry)
    if(${variable})
        list(FIND ${variable} ${entry} index)
        if(${index} EQUAL -1)
            set(${variable} ${${variable}} ${entry} CACHE INTERNAL "")
        endif()
      else()
        set(${variable} ${entry} CACHE INTERNAL "")
      endif()
endmacro()

macro(rcf_remove_internal variable entry)
    list(FIND ${variable} ${entry} index)
    if(${index} GREATER -1)
        set(newList ${${variable}})
        list(REMOVE_AT newList ${index})
        set(${variable} ${newList} CACHE INTERNAL "")
    endif()
endmacro()