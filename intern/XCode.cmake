#
# This file will help you to integrate a Radon CMake framework based project into your project.
# http://www.radonframework.org/projects/rf/wiki/UserManualCMakeFramework
# http://www.radonframework.org/projects/rf/wiki/DeveloperManualCMakeFramework
#
macro(ConfigureCompilerAndLinkerXCode projectid buildtype)
	if(CMAKE_GENERATOR STREQUAL Xcode)
		set(${projectid}_COMPILER_FLAGS "${${projectid}_COMPILER_FLAGS} -msse4.2")
		set(CMAKE_C_STANDARD 11)
		set(CMAKE_CXX_STANDARD 14)
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