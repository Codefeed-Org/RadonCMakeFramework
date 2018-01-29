#
# This file will help you to integrate a Radon CMake framework based project into your project.
# http://www.radonframework.org/projects/rf/wiki/UserManualCMakeFramework
# http://www.radonframework.org/projects/rf/wiki/DeveloperManualCMakeFramework
#
macro(GenerateModule projectid)
	add_library(${${projectid}_NAME} STATIC ${${projectid}_FILES})
	target_link_libraries(${${projectid}_NAME} ${${projectid}_LIBS})
	set(${projectid}_ISMODULE ON CACHE INTERNAL "Project is a module.")
endmacro()

macro(GenerateSharedLibrary projectid)
	add_library(${${projectid}_NAME} SHARED ${${projectid}_FILES})
	target_link_libraries(${${projectid}_NAME} ${${projectid}_LIBS})
	set(${projectid}_ISLIBRARY ON CACHE INTERNAL "Project is a shared library.")
endmacro()

macro(GenerateHeaderOnly projectid)
	add_custom_target(${${projectid}_NAME} SOURCES ${${projectid}_FILES})
	set(${projectid}_ISHEADERONLY ON CACHE INTERNAL "Project is a header onnly target.")
endmacro()

macro(GenerateExecutable projectid)
	add_executable(${${projectid}_NAME} ${${projectid}_FILES})    
	target_link_libraries(${${projectid}_NAME} ${${projectid}_LIBS})
	set(${projectid}_ISEXECUTABLE ON CACHE INTERNAL "Project is an executable.")
endmacro()

macro(SharedGenerate what projectid projectname foldergroup)
    if (NOT DEFINED ${projectid}_LOCATION)
        set(${projectid}_LOCATION "${${CMAKE_PROJECT_NAME}_PATH}")
    endif()
    if(NOT ${${projectid}_NAME}_SOURCE_DIR)
        set(${${projectid}_NAME}_SOURCE_DIR ${CMAKE_SOURCE_DIR})
    endif()    
	include("${RCF_PATH}/intern/CompilerAndLinkerSettings.cmake")	
	
	# Activate solution directory feature
	set_property(GLOBAL PROPERTY USE_FOLDERS ON)

	set(${projectname}_ID ${projectid} CACHE INTERNAL "Projectid of ${projectname}")
	set(${projectid}_NAME ${projectname} CACHE INTERNAL "Projectname of ${projectid}")
	set(${projectid}_DEPS "" CACHE INTERNAL "Project specific dependencies of ${projectname}")
	set(${projectid}_PUBLIC_INCLUDES "" CACHE INTERNAL "Project public include directories")
    set(${projectid}_WHAT ${what} CACHE INTERNAL "Buildtype of ${projectname}")
	
	#
	# Initialized compiler defines.
	# This defines are public and will be delegated to projects which depend on this target.
	#
	# This defines will be merged into all compiler builds.
	set(${projectid}_COMPILER_DEFINES "" CACHE INTERNAL "Project public defines")
	# This defines will be used for Debug target.
	set(${projectid}_COMPILER_DEFINES_DEBUG "" CACHE INTERNAL "Project public defines")
	# This defines will be used for Release target.
	set(${projectid}_COMPILER_DEFINES_RELEASE "" CACHE INTERNAL "Project public defines")
	# This defines will be used for "minimized Release" target.
	set(${projectid}_COMPILER_DEFINES_RELMINSIZE "" CACHE INTERNAL "Project public defines")
	# This defines will be used for "Release with debug infos" target.
	set(${projectid}_COMPILER_DEFINES_RELWITHDEBINFO "" CACHE INTERNAL "Project public defines")
	
	set(CMAKE_DEBUG_POSTFIX D)
    set(CMAKE_RELMINSIZE_POSTFIX RM)
    set(CMAKE_RELWITHDEBINFO_POSTFIX RD)
    
    if(USE_VGDB)
        # Add a Visual GDB Execution target.
        option(${projectid}_VGDB_TARGET "Generate a Visual GDB compiler target." OFF)
        if(${${projectid}_VGDB_TARGET})
            include("${RCF_PATH}/intern/VisualGDB.cmake")
            GenerateVGDBTarget(${projectid})
        endif()    
    endif()
endmacro()

macro(SharedFinalize projectid)
    if(USE_VGDB)
        if(${${projectid}_VGDB_TARGET})
            FinalizeVGDBTarget(${projectid})
        endif()
    endif()
endmacro()

macro(Generate what projectid projectname foldergroup)
	SharedGenerate(${what} ${projectid} ${projectname} ${foldergroup})
	
	if(${what} STREQUAL "MODULE")
		GenerateModule(${projectid})
	elseif(${what} STREQUAL "SHARED")
		GenerateSharedLibrary(${projectid})
	elseif(${what} STREQUAL "HEADERONLY")
		GenerateHeaderOnly(${projectid})
	else()
		GenerateExecutable(${projectid})
	endif()	
	
	ConfigureCompilerAndLinker(${projectid} ${what})
	set_property(TARGET ${projectname} PROPERTY FOLDER ${foldergroup})
endmacro()

macro(AddDependency projectid)
	set(${projectid}_DEPS ${${projectid}_DEPS} ${ARGN} CACHE INTERNAL "")
endmacro()

macro(Finalize projectid)
	list(LENGTH ${projectid}_DEPS count)
	if(${count} GREATER 0)
		add_dependencies(${${projectid}_NAME} ${${projectid}_DEPS})
	endif()
	
	foreach(dep ${${projectid}_DEPS})
		if(DEFINED ${${dep}_ID}_ISLIBRARY OR DEFINED ${${dep}_ID}_ISMODULE OR DEFINED ${${dep}_ID}_ISHEADERONLY)
			# assign public libraries from the dependency
			if(NOT DEFINED ${${dep}_ID}_ISHEADERONLY)
				target_link_libraries(${${projectid}_NAME} ${dep})
			endif()
			# assign public includes from the dependency
			include_directories(${${${dep}_ID}_PUBLIC_INCLUDES})
			# assign public defines from the dependency
			AddPublicDefine(${projectid} ${${${dep}_ID}_COMPILER_DEFINES})
			AddPublicTargetDefine(${projectid} RELEASE ${${${dep}_ID}_COMPILER_DEFINES_RELEASE})
			AddPublicTargetDefine(${projectid} DEBUG ${${${dep}_ID}_COMPILER_DEFINES_DEBUG})
			AddPublicTargetDefine(${projectid} RELWITHDEBINFO ${${${dep}_ID}_COMPILER_DEFINES_RELWITHDEBINFO})
			AddPublicTargetDefine(${projectid} MINSIZEREL ${${${dep}_ID}_COMPILER_DEFINES_MINSIZEREL})
		endif()
	endforeach()
	
	include("${RCF_PATH}/intern/CompilerAndLinkerSettings.cmake")
	FinalizeCompilerAndLinkerSettings(${projectid} )	
    set_property(GLOBAL PROPERTY "${projectid}_FINALIZED" ON)
	message(STATUS "Finalized project: ${${projectid}_NAME} Depends on: ${${projectid}_DEPS}")
    SharedFinalize(${projectid})
endmacro()

macro(GenerateCustomTargetMetaInfo what projectname projectid foldergroup)
	SharedGenerate(${what} ${projectid} ${projectname} ${foldergroup})
	
	if(${what} STREQUAL "MODULE")
		set(${projectid}_ISMODULE ON CACHE INTERNAL "Project is a module.")
	elseif(${what} STREQUAL "SHARED")
		set(${projectid}_ISLIBRARY ON CACHE INTERNAL "Project is a shared library.")
	elseif(${what} STREQUAL "HEADERONLY")
		set(${projectid}_ISHEADERONLY ON CACHE INTERNAL "Project is a header only target.")		
	else()
		set(${projectid}_ISEXECUTABLE ON CACHE INTERNAL "Project is an executable.")
	endif()
	
	ConfigureCompilerAndLinker(${projectid} ${what})
	set_property(TARGET ${${projectid}_NAME} PROPERTY FOLDER ${foldergroup})        
endmacro()

macro(FinalizeCustomTargetMetaInfo projectid)
	FinalizeCompilerAndLinkerSettings(${projectid})
    SharedFinalize(${projectid})
endmacro()

set(RCF_GENERATE_SCOPE_STACK "" CACHE INTERNAL "A stack of the not closed rcf_generate calls.")

macro(rcf_generate what projectid projectname foldergroup)
  set(RCF_GENERATE_SCOPE_STACK "${RCF_GENERATE_SCOPE_STACK};${projectid}" CACHE INTERNAL "A stack of the not closed rcf_generate calls.")
  if(${ARGC} GREATER_EQUAL 5)
    set(${projectid}_FILES ${ARGN})
  endif()
  string(TOUPPER ${what} what_uppercase)
  Generate(${what_uppercase} ${projectid} ${projectname} ${foldergroup})
endmacro()

macro(rcf_endgenerate)
  if(${ARGC} EQUAL 0)
	set(projects ${RCF_GENERATE_SCOPE_STACK})	
	list(LENGTH projects last)
	math(EXPR last ${last}-1)
    list(GET projects ${last} projectid)
	list(REMOVE_AT projects ${last})
	set(RCF_GENERATE_SCOPE_STACK ${projects} CACHE INTERNAL "A stack of the not closed rcf_generate calls.")
    Finalize(${projectid})
  else()
	set(projects ${RCF_GENERATE_SCOPE_STACK})
	set(projects_left ${ARGN})
    list(REVERSE projects)
	foreach(projectid ${projects})
      list(FIND projects_left ${projectid} entry_index)
      if(NOT ${entry_index} EQUAL -1)
		list(REMOVE_ITEM projects ${projectid})
		list(REMOVE_AT projects_left ${entry_index})
        Finalize(${projectid})
	  else()
	  	list(LENGTH projects_left projects_left_length)
		if(${projects_left_length} GREATER 0)
		  message(FATAL_ERROR "Project ${projectid} have to be finished first. Add it to the rcf_endgenerate(...) call.")
		endif()
      endif()
	endforeach()
	if(NOT ${projects_left} STREQUAL "")
		message(FATAL_ERROR "Attempt to finish following targets ${projects_left} failed. Because they don't exist.")
	endif()
	set(RCF_GENERATE_SCOPE_STACK ${projects} CACHE INTERNAL "A stack of the not closed rcf_generate calls.")
  endif()
endmacro()