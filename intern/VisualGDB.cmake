include(CMakeDependentOption)
if(MSVC)
    option(USE_VGDB "Enable Visual GDB support" OFF)
endif()

if(USE_VGDB)
    FIND_PROGRAM(VSGDB_EXECUTABLE VisualGDB PATHS "C:/Program Files (x86)/Sysprogs/VisualGDB/" DOC "VisualGDB.exe")    
endif()

if(USE_VGDB)
set(VGDB_HOSTNAME "192.168.178.46" CACHE STRING "Hostname/IP of the target linux machine.")
set(VGDB_USERNAME "pi" CACHE STRING "Username of the target linux machine.")
set(VGDB_ARGUMENTS "" CACHE STRING "Additional arguments which should passed to remote cmake.")

if(NOT TARGET VGDB)
    set(HOSTNAME ${VGDB_HOSTNAME})
    set(USERNAME ${VGDB_USERNAME})
    set(ARGUMENTS ${VGDB_ARGUMENTS})
    set(LOCALDIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    configure_file("${${CMAKE_PROJECT_NAME}_PATH}/intern/Debug.vgdbsettings.template" "${CMAKE_CURRENT_BINARY_DIR}/VGDB-Debug.vgdbsettings" @ONLY)
    configure_file("${${CMAKE_PROJECT_NAME}_PATH}/intern/Release.vgdbsettings.template" "${CMAKE_CURRENT_BINARY_DIR}/VGDB-Release.vgdbsettings" @ONLY)
    add_custom_target(VGDB ${VSGDB_EXECUTABLE} "${CMAKE_CURRENT_BINARY_DIR}/VGDB-Debug.vgdbsettings"
                     WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                     SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt)
    set(VGDB_TARGET_ALL ON)
endif()

macro(GenerateVGDBTarget projectid)
    set(${projectid}_VGDB_HOSTNAME ${VGDB_HOSTNAME})    
    set(${projectid}_VGDB_USERNAME ${VGDB_USERNAME})        
    set(${projectid}_VGDB_ARGUMENTS ${VGDB_ARGUMENTS})
           
    set(HOSTNAME ${${projectid}_VGDB_HOSTNAME})
    set(USERNAME ${${projectid}_VGDB_USERNAME})
    set(ARGUMENTS ${${projectid}_VGDB_ARGUMENTS})
    set(LOCALDIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    configure_file("${${CMAKE_PROJECT_NAME}_PATH}/intern/Debug.vgdbsettings.template" "${CMAKE_CURRENT_BINARY_DIR}/${${projectid}_NAME}_VGDB-Debug.vgdbsettings" @ONLY)
    configure_file("${${CMAKE_PROJECT_NAME}_PATH}/intern/Release.vgdbsettings.template" "${CMAKE_CURRENT_BINARY_DIR}/${${projectid}_NAME}_VGDB-Release.vgdbsettings" @ONLY)

    add_custom_target("${${projectid}_NAME}_VGDB" ${VSGDB_EXECUTABLE} "${CMAKE_CURRENT_BINARY_DIR}/${${projectid}_NAME}_VGDB-Debug.vgdbsettings"
                     WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                     SOURCES ${${projectid}_FILES})
endmacro()

macro(FinalizeVGDBTarget projectid)
    foreach(dep ${${projectid}_DEPS})
        if(DEFINED ${${dep}_ID}_ISLIBRARY OR DEFINED ${${dep}_ID}_ISMODULE)
            add_dependencies(${${projectid}_NAME}_VGDB ${dep}_VGDB)
            list(APPEND deps ${dep}_VGDB)
        endif()
    endforeach()  
    message(STATUS "Finalized project: ${${projectid}_NAME}_VGDB Depends on: ${deps}")    
endmacro()

endif()