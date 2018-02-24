#[[.rst Generate
========
]]
macro(GenerateModule projectid)
	add_library(${${projectid}_NAME} STATIC ${${projectid}_FILES} "")
	target_link_libraries(${${projectid}_NAME} ${${projectid}_LIBS})
	set(${projectid}_ISMODULE ON CACHE INTERNAL "Project is a module.")
endmacro()

macro(GenerateSharedLibrary projectid)
	add_library(${${projectid}_NAME} SHARED ${${projectid}_FILES} "")
	target_link_libraries(${${projectid}_NAME} ${${projectid}_LIBS})
	set(${projectid}_ISLIBRARY ON CACHE INTERNAL "Project is a shared library.")
endmacro()

macro(GenerateHeaderOnly projectid)
	add_custom_target(${${projectid}_NAME} SOURCES ${${projectid}_FILES} "")
	set(${projectid}_ISHEADERONLY ON CACHE INTERNAL "Project is a header onnly target.")
endmacro()

macro(GenerateExecutable projectid)
	add_executable(${${projectid}_NAME} ${${projectid}_FILES} "")
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

#[[.rst .. cmake:function:: rcf_dependencies(targetids)

  This function allows to add one or more targets to the current active target.

  :param targetids: A List of target IDs which should be added to the current target.
]]
function(rcf_dependencies targetids)
	rcf_get_current_projectid(targetid)
	set(${targetid}_DEPS ${${targetid}_DEPS} ${targetids} CACHE INTERNAL "")
endfunction()

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

#[[.rst .. cmake:macro:: rcf_generate(what targetid targetname foldergroup [files])

  Generate a target with the specified parameter.

  :param what: Defines the target type e.g. shared.
  :param targetid: Defines the identifier which will be used in cmake.
  :param targetname: Defines the user readable name.
  :param foldergroup: Defines the logical location of the target e.g. "3rd Party" 
  	will be add the target in a Visual Studio folder with this name.
  :param files: You can add a list of files which will be part of the target.
]]
macro(rcf_generate what targetid targetname foldergroup)
  set(RCF_GENERATE_SCOPE_STACK "${RCF_GENERATE_SCOPE_STACK};${targetid}" CACHE INTERNAL "A stack of the not closed rcf_generate calls.")
  if(${ARGC} GREATER_EQUAL 5)
    set(${targetid}_FILES ${ARGN})
  endif()
  string(TOUPPER ${what} what_uppercase)  
  Generate(${what_uppercase} ${targetid} ${targetname} ${foldergroup})
endmacro()

#[[.rst .. cmake:macro:: rcf_endgenerate([targetids])

  Finalize the last generated target if no targetid was passed else all targets
  will be closed in the order they are passed.  

  :param targetids: A list of target IDs which should be closed in order.
]]
macro(rcf_endgenerate)
  if(${ARGC} EQUAL 0)
	set(targets ${RCF_GENERATE_SCOPE_STACK})	
	list(LENGTH targets last)
	math(EXPR last ${last}-1)
    list(GET targets ${last} targetid)
	list(REMOVE_AT targets ${last})
	set(RCF_GENERATE_SCOPE_STACK ${targets} CACHE INTERNAL "A stack of the not closed rcf_generate calls.")
    Finalize(${targetid})
  else()
	set(targets ${RCF_GENERATE_SCOPE_STACK})
	set(targets_left ${ARGN})
    list(REVERSE targets)
	foreach(targetid ${targets})
      list(FIND targets_left ${targetid} entry_index)
      if(NOT ${entry_index} EQUAL -1)
		list(REMOVE_ITEM targets ${targetid})
		list(REMOVE_AT targets_left ${entry_index})
        Finalize(${targetid})
	  else()
	  	list(LENGTH targets_left targets_left_length)
		if(${targets_left_length} GREATER 0)
		  message(FATAL_ERROR "Target ${targetid} have to be finished first. Add it to the rcf_endgenerate(...) call.")
		endif()
      endif()
	endforeach()
	if(NOT ${targets_left} STREQUAL "")
		message(FATAL_ERROR "Attempt to finish following targets ${targets_left} failed. Because they don't exist.")
	endif()
	set(RCF_GENERATE_SCOPE_STACK ${targets} CACHE INTERNAL "A stack of the not closed rcf_generate calls.")
  endif()
endmacro()