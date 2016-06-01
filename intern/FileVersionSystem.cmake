#
# Supported systems: git, svn
# Provided functionality:
# -locate binaries
# -get revision or identifier of current version

set(RCF_REPO_CACHE_KEYS "" CACHE INTERNAL "Already loaded repositories.")

#
# Find the location of supported binaries.
#

find_package(Git QUIET)
if (GIT_FOUND)
	set("RCF_REPOTYPEMAP_git" "${GIT_EXECUTABLE}")
	set("RCF_REPOTYPEMAP_git_get" "clone")
    set("RCF_REPOTYPEMAP_git_update" "pull" "-q")
endif()

find_package(Subversion QUIET)
if (SUBVERSION_FOUND)
	set("RCF_REPOTYPEMAP_svn" "${Subversion_SVN_EXECUTABLE}")
	set("RCF_REPOTYPEMAP_svn_get" "co")
    set("RCF_REPOTYPEMAP_svn_update" "update")
endif()	

#
# Obtain the identifier and build a version number of the specified repo.
#

macro(GIT_GET_REVISION dir variable)
  execute_process(COMMAND ${GIT_EXECUTABLE} -C ${dir} rev-list HEAD --count
	OUTPUT_VARIABLE ${variable}
	OUTPUT_STRIP_TRAILING_WHITESPACE)
	IF(${variable} STREQUAL "")
		SET(${variable} "0")
	ENDIF()
endmacro(GIT_GET_REVISION)

macro(Subversion_GET_REVISION dir variable)
  execute_process(COMMAND ${SVN_EXECUTABLE} info ${dir}
	OUTPUT_VARIABLE ${variable}
	OUTPUT_STRIP_TRAILING_WHITESPACE)
  STRING(REGEX REPLACE "^(.*\n)?Revision: ([^\n]+).*"
	"\\2" ${variable} "${${variable}}")
	IF(${variable} STREQUAL "")
		SET(${variable} "0")
	ENDIF()
endmacro(Subversion_GET_REVISION)

#
#
#

macro(rcf_generaterepopath targetdir variable)
	set(${variable} "${PROJECT_BINARY_DIR}/DownloadedDependencies/${targetdir}")
endmacro()

#
# A wrapper to get the repository.
#

macro(rcf_getrepo repo type targetdir outdir)
	message(STATUS "${targetdir} need ${repo}")
	if (DEFINED RCF_REPOTYPEMAP_${type})
		if(NOT ";${repo};" MATCHES ";${RCF_REPO_CACHE_KEYS};")
			rcf_generaterepopath(${targetdir} localdir)
			if(NOT EXISTS ${localdir})
				message(STATUS "Download ${repo} !")
				execute_process(COMMAND "${RCF_REPOTYPEMAP_${type}}" ${RCF_REPOTYPEMAP_${type}_get} "${repo}" "${localdir}")
			else()
				message(STATUS "Found ${repo} at ${localdir}")
                message(STATUS "Check ${localdir} for updates.")
                execute_process(COMMAND "${RCF_REPOTYPEMAP_${type}}" ${RCF_REPOTYPEMAP_${type}_update}
                                WORKING_DIRECTORY "${localdir}")                
			endif()
			list(APPEND RCF_REPO_CACHE_KEYS ${repo})
			set(${repo}_PATH ${localdir} CACHE INTERNAL "Path to the loaded repository.")	
			set(outdir ${localdir})
		else()
			set(outdir ${${repo}_PATH})	
			message(STATUS "Found ${repo} at ${${repo}_PATH}.")
		endif()
	endif()
endmacro()