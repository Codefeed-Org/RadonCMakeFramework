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

macro(GenerateExecutable projectid)
	add_executable(${${projectid}_NAME} ${${projectid}_FILES})
	target_link_libraries(${${projectid}_NAME} ${${projectid}_LIBS})
	set(${projectid}_ISEXECUTABLE ON CACHE INTERNAL "Project is an executable.")
endmacro()

macro(SharedGenerate what projectid projectname foldergroup)
	set(${projectid}_LOCATION "${${CMAKE_PROJECT_NAME}_PATH}")
	include("${${CMAKE_PROJECT_NAME}_PATH}/intern/CompilerAndLinkerSettings.cmake")	
	
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
            include("${${CMAKE_PROJECT_NAME}_PATH}/intern/VisualGDB.cmake")
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
		if(DEFINED ${${dep}_ID}_ISLIBRARY OR DEFINED ${${dep}_ID}_ISMODULE)
			# assign public libraries from the dependency
			target_link_libraries(${${projectid}_NAME} ${dep})
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
	
	include("${${CMAKE_PROJECT_NAME}_PATH}/intern/CompilerAndLinkerSettings.cmake")
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
	else()
		set(${projectid}_ISEXECUTABLE ON CACHE INTERNAL "Project is an executable.")
	endif()
	
	ConfigureCompilerAndLinker(${projectid})
endmacro()

macro(FinalizeCustomTargetMetaInfo projectid)
	FinalizeCompilerAndLinkerSettings(${projectid})
	set_property(TARGET ${${projectid}_NAME} PROPERTY FOLDER ${foldergroup})    
    SharedFinalize(${projectid})
endmacro()