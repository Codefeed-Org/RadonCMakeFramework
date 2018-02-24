include("${CMAKE_CURRENT_LIST_DIR}/../intern/CMakeDocumentation.cmake")

rcf_generate_doc(out "rcf_doc"
  includes "*.cmake" 
  excludes "intern/CMakeDocumentation.cmake"
  workingdir "${CMAKE_CURRENT_LIST_DIR}/..")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/." DESTINATION "rcf_doc/")
execute_process(COMMAND sphinx-build -M html . build
  WORKING_DIRECTORY "rcf_doc/" ERROR_QUIET)
