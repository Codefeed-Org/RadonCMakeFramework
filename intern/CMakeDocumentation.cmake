#[[.rst CMake documentation
===================
This file provides functions to generate documentation of CMake files.
]]
include(${CMAKE_ROOT}/Modules/CMakeParseArguments.cmake)

#[[.rst .. cmake:function:: rcf_generate_doc([includes filepattern] [excludes filepattern])

  Generates a rst files of each passed cmake file.

  :param includes filepattern: A list of regex values to capture the cmake files.
  :param excludes filepattern: A list of regex values to capture the cmake files which should be ignored.
]]
function(rcf_generate_doc )
    cmake_parse_arguments(PARSE_CMAKE_DOCUMENTATION "" "out;workingdir" "includes;excludes" ${ARGN} )

    if(NOT DEFINED PARSE_CMAKE_DOCUMENTATION_includes)
        set(PARSE_CMAKE_DOCUMENTATION_includes "*.cmake")
    endif()

    if(NOT DEFINED PARSE_CMAKE_DOCUMENTATION_workingdir)
        set(PARSE_CMAKE_DOCUMENTATION_workingdir "${CMAKE_SOURCE_DIR}")
    endif()

    if(NOT DEFINED PARSE_CMAKE_DOCUMENTATION_out)
        set(PARSE_CMAKE_DOCUMENTATION_out "${PROJECT_BINARY_DIR}")
    endif()

    set(cmake_files_list)
    foreach(includeFilePathPattern ${PARSE_CMAKE_DOCUMENTATION_includes})
        file(GLOB_RECURSE cmake_files "${PARSE_CMAKE_DOCUMENTATION_workingdir}/${includeFilePathPattern}")
        list(APPEND cmake_files_list ${cmake_files}) 
    endforeach()

    foreach(excludeFilePathPattern ${PARSE_CMAKE_DOCUMENTATION_excludes})
        file(GLOB_RECURSE cmake_files_exclude "${PARSE_CMAKE_DOCUMENTATION_workingdir}/${excludeFilePathPattern}")
        list(REMOVE_ITEM cmake_files_list ${cmake_files_exclude})
    endforeach()

    # Process for each file of the list
    foreach(cmake_file ${cmake_files_list})
        file(READ ${cmake_file} cmake_file_content)
        message(STATUS "Generate cmake doc for : ${cmake_file}")
        string(REPLACE "${PARSE_CMAKE_DOCUMENTATION_workingdir}" "${PARSE_CMAKE_DOCUMENTATION_out}" doc_file "${cmake_file}")
        file(WRITE "${doc_file}.rst" "")
        string(REGEX MATCHALL "#\\[\\[.rst[ \t]*([^]]*][^]]*)]*" docSection ${cmake_file_content})
        list(LENGTH docSection len)
        foreach(entry ${docSection})
            string(REGEX REPLACE "#\\[\\[.rst " "" block ${entry})
            string(REGEX REPLACE "]]" "" block ${block})
            file(APPEND "${doc_file}.rst" "${block}\n")
        endforeach()
        string(REGEX MATCHALL "^[ ]*#.rst[^\n]*(\n#[^\n]*)*" docSection ${cmake_file_content})
        foreach(entry ${docSection})
            string(REGEX REPLACE "#.rst " "" block ${entry})
            string(REGEX REPLACE "\n#" "\n" block ${block})
            file(APPEND "${doc_file}.rst" "${block}\n")
        endforeach()
        set(cmake_file_content "")
    endforeach()
endfunction()