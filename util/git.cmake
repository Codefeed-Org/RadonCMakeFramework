#
# This module will looking for svn command line executable and
# obtain the svn revision and build version number of a specified repo.
#
FIND_PROGRAM(GIT_EXECUTABLE git DOC "git command line client")
mark_as_advanced(GIT_EXECUTABLE)

MACRO(GIT_GET_REVISION dir variable)
  EXECUTE_PROCESS(COMMAND ${GIT_EXECUTABLE} -C ${dir} rev-list HEAD --count
	OUTPUT_VARIABLE ${variable}
	OUTPUT_STRIP_TRAILING_WHITESPACE)
	IF("${variable}" STREQUAL "")
		SET(${variable} "0")
	ENDIF("${variable}" STREQUAL "")
ENDMACRO(GIT_GET_REVISION)