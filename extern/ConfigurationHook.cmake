#[[.rst Configuration hook
==================
]]
set(RCF_PATH "${CMAKE_CURRENT_LIST_DIR}/..")

get_property(checkRepo GLOBAL PROPERTY RCF_REPO_CHECK)
if(NOT DEFINED checkRepo)
    message(STATUS "Check for newest version of Radon CMake framework.")
    execute_process(COMMAND "${GIT_EXECUTABLE}" "pull" "-q"
                    WORKING_DIRECTORY "${RCF_PATH}")
    set_property(GLOBAL PROPERTY RCF_REPO_CHECK true)
endif()

include("${RCF_PATH}/util/Macros.cmake")
include("${RCF_PATH}/intern/FileVersionSystem.cmake")
include("${RCF_PATH}/intern/Download.cmake")
include("${RCF_PATH}/extern/Integrate.cmake")
include("${RCF_PATH}/intern/SystemInfo.cmake")
include("${RCF_PATH}/intern/PackageManagement.cmake")
include("${RCF_PATH}/intern/CMakeDocumentation.cmake")

rcf_getsysteminfos()

if(NOT DEFINED RCF_DEFAULT_DIST_DIR)
	set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/dist")
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/dist")
	set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/dist")
endif()

#[[.rst .. cmake:macro:: rcf_addlocation(targetid protocol location)

	You can register an additional possible location where the target could be located.

	:param targetid: For which target you want to add an additional location.
	:param protocol: Which protocol will be used ? E.g. "git".
	:param location: Specifies the location e.g. "https://github.com/Codefeed-Org/RadonCMakeFramework.git".
]]
macro(rcf_addlocation targetid protocol location)
	set(${targetid}_Locations ${${targetid}_Locations} "${protocol} ${location}")
endmacro()

#[[.rst .. cmake:macro:: rcf_getlocation(targetid locations)

	Get all locations registered for the specified target.

	:param targetid: For which target you want to get the locations.
	:param locations: The variable name to which the locations should be copied.
]]
macro(rcf_getlocations projectid locations)
	set(${locations} ${${projectid}_Locations})
endmacro()

macro(ConfigureProject projectid path)
	set(${projectid}_LOCATION "${path}")
	set(${projectid}_PUBLIC_INCLUDES "" CACHE INTERNAL "include directories")
	if ((DEFINED ${projectid}_FINALIZED AND NOT ${${projectid}_FINALIZED}) OR
		NOT DEFINED ${projectid}_FINALIZED)
		rcf_add_subdirectory_once(${${projectid}_LOCATION} "${PROJECT_BINARY_DIR}/${projectid}/")
	endif()
endmacro()

# everything went right :)
macro(FoundProject projectid projectname path)
	message(STATUS "Found ${projectname}")
	mark_as_advanced(${projectid}_DIR)
	set(${projectid}_FOUND ON)
	mark_as_advanced(${projectid}_FOUND)
	ConfigureProject(${projectid} ${path})
endmacro()

# everything gone wrong :(
macro(NoProjectFound projectid projectname)
	set(${projectid}_FOUND OFF)
	mark_as_advanced(${projectid}_FOUND)
	message(FATAL_ERROR "Couldn't find or integrate ${projectname}. Please use ${projectid}_DIR to specify the location.")
endmacro()

# first try failed this is the backup
macro(FailSafe projectid projectname)
	if(NOT DEFINED ${projectid}_DIR)
		set(${projectid}_DIR "-NOTFOUND" CACHE PATH "Path to ${projectname} directory.")
	endif()
	if(EXISTS "${${projectid}_DIR}")
		if(NOT IS_ABSOLUTE "${${projectid}_DIR}")
			get_filename_component(absolute_path "${CMAKE_BINARY_DIR}/${${projectid}_DIR}" ABSOLUTE)
			set(${projectid}_DIR "${absolute_path}" CACHE PATH "Path to ${projectname} directory." FORCE)
			message(STATUS "Convert relative path into a absolute one ${${projectid}_DIR}")
		endif()
		# on windows there are some cases where we have to encounter backslashes
		STRING(REGEX REPLACE "\\\\" "/" ${projectid}_DIR ${${projectid}_DIR}) 	
		FoundProject(${projectid} ${projectname} "${${projectid}_DIR}")
	else()
		NoProjectFound(${projectid} ${projectname})
	endif()
endmacro()

#[[.rst .. cmake:function:: rcf_obtain(name protocol location outdir)

	This function allows you to obtain one or more files from different protocols
	and return the directory it's located at.

	:param name: The name which should be used in output if necessary.
	:param protocol: Which protocol will be used ? E.g. "git".
	:param location: Specifies the location e.g. "https://github.com/Codefeed-Org/RadonCMakeFramework.git"
	:param outdir: The variable name to which the locations should be copied.
]]
function(rcf_obtain name protocol location outdir)
	if(${protocol} STREQUAL "file")
		if(EXISTS "${location}")
			set(${outdir} ${location} PARENT_SCOPE)
		else()
			message(AUTHOR_WARNING "${name} '${location}' doesn't exists !")
		endif()
	elseif(${protocol} STREQUAL "env")
		if(EXISTS "$ENV{${location}}/")
			set(${outdir} "$ENV{${location}}/" PARENT_SCOPE)
		else()
			message(AUTHOR_WARNING "Add user or system environment variable ${environmentname} !")
		endif()
	elseif(${protocol} STREQUAL "download")
		rcf_download(${location} ${name} dir)
		set(${outdir} ${dir} PARENT_SCOPE)
	else()#file version system
		if(DEFINED GetSpecificVersion)
			rfc_getreporevision(${location} ${protocol} ${name} ${GetSpecificVersion} dir)                
			unset(GetSpecificVersion)
		else()
			rcf_getrepo(${location} ${protocol} ${name} dir)
		endif()
		set(${outdir} ${dir} PARENT_SCOPE)
	endif()
endfunction()

#[[.rst .. cmake:macro:: rcf_obtain_project(targetid outdir [revision])

	This macro allows you to obtain the specified target by checking all registed
	locations in order they were added and return the location of the first hit.

	:param targetid: The target ID which should be obtained.
	:param outdir: The variable name to which the location should be copied.
	:param revision: If specified and the first location is a version control system 
		the revision will be used to switch to the specific commit.
]]
macro(rcf_obtain_project targetid outdir)
    set(outdir "")
    set (extra_macro_args ${ARGN})
    list(LENGTH extra_macro_args num_extra_args)
    if (${num_extra_args} GREATER 0)
        # specific revision of file version system
        list(GET extra_macro_args 0 GetSpecificVersion)
    endif()
    
	foreach(entry ${${targetid}_Locations})
		separate_arguments(entry)
		list(GET entry 0 protocol)
		list(GET entry 1 location)
		if(${protocol} STREQUAL "file")
			if(EXISTS "${location}")
				set(outdir ${location})
			else()
				message(AUTHOR_WARNING "${projectname} '${location}' doesn't exists !")
			endif()
		elseif(${protocol} STREQUAL "env")
			if(EXISTS "$ENV{${location}}/")
				set(outdir "$ENV{${location}}/")
			else()
				message(AUTHOR_WARNING "Add user or system environment variable ${environmentname} !")
			endif()
		elseif(${protocol} STREQUAL "download")
			rcf_download(${location} ${targetid} outdir)
		else()#file version system
            if(DEFINED GetSpecificVersion)
                rfc_getreporevision(${location} ${protocol} ${targetid} ${GetSpecificVersion} outdir)                
                unset(GetSpecificVersion)
            else()
                rcf_getrepo(${location} ${protocol} ${targetid} outdir)            
            endif()
		endif()
		
		if(EXISTS ${outdir})
			break()
		endif()
	endforeach()
    
    if(${outdir} STREQUAL "")
        MESSAGE(FATAL_ERROR "Could not find an entry for ${projectid}! Use rcf_addlocation(${projectid} ...).")
    endif()
endmacro()

# projectid = will be used as pre-name for all variables
# projectname = will be used as output in the option description
# environmentname = will be used as key for the search in the environment variables
macro(Integrate projectid projectname environmentname)
	# check if initialization order is valid
    get_property(finalized GLOBAL PROPERTY "${projectid}_FINALIZED")

	if(DEFINED ${projectid}_FOUND AND "${finalized}" STREQUAL "")
		message(FATAL_ERROR "${projectname} is involved in an circular dependency. Please track the project which call Integrate() for ${projectname} and move it behind Finalize().")
	endif()
	
	if(NOT DEFINED ${projectid}_FOUND)
		option(${projectid}_USE "Include ${projectname} into the project." ON)	
		
		if(${projectid}_USE)
			message(STATUS "Integrate ${projectid}:")
			set(outdir "")
			rcf_obtain_project(${projectid} outdir)
			if(EXISTS ${outdir})
				FoundProject(${projectid} ${projectname} ${outdir})
			else()
				FailSafe(${projectid} ${projectname})
			endif()			
		endif()
	endif()

	string(REGEX MATCH "${${projectid}_NAME}" match "${RCF_INTEGRATED}")
	if ("${match}" STREQUAL "")
		set(RCF_INTEGRATED "${${projectid}_NAME} ${RCF_INTEGRATED}" CACHE INTERNAL "Integrated projects")	
	endif()	
	include_directories(${${projectid}_PUBLIC_INCLUDES})
endmacro()