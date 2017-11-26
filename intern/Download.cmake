#
# Supported systems: http, https
# Provided functionality:
# -download files from web
# -execution chain

cmake_policy(SET CMP0057 NEW)

if(NOT DEFINED ${CMAKE_PROJECT_NAME}_DOWNLOAD_CACHE_KEYS)
    set(${CMAKE_PROJECT_NAME}_DOWNLOAD_CACHE_KEYS "" CACHE INTERNAL "Already loaded files.")
endif()

#
#
#

macro(rcf_generatefilepath targetdir url variable)
  get_filename_component(filename ${url} NAME)
	set(${variable} "${PROJECT_BINARY_DIR}/DownloadedDependencies/${targetdir}/${filename}")
endmacro()

function(rcf_download url projectid outdir)
	message(STATUS "${projectid} need ${url}")
	if("${url}" IN_LIST ${CMAKE_PROJECT_NAME}_DOWNLOAD_CACHE_KEYS)
    if(EXISTS ${${${CMAKE_PROJECT_NAME}_DOWNLOAD_CACHE_KEYS}_PATH})
      set(outdir ${${${CMAKE_PROJECT_NAME}_DOWNLOAD_CACHE_KEYS}_PATH} PARENT_SCOPE)	
      message(STATUS "Found ${url} at ${${${CMAKE_PROJECT_NAME}_DOWNLOAD_CACHE_KEYS}_PATH}.")
    else()
      message("Can't find ${url} at ${${${CMAKE_PROJECT_NAME}_DOWNLOAD_CACHE_KEYS}_PATH}. Start reloading!")
      list(APPEND DOWNLOAD_CACHE_KEYS ${${CMAKE_PROJECT_NAME}_DOWNLOAD_CACHE_KEYS})
      list(REMOVE_ITEM DOWNLOAD_CACHE_KEYS ${url})
      set(${CMAKE_PROJECT_NAME}_DOWNLOAD_CACHE_KEYS "${DOWNLOAD_CACHE_KEYS}" CACHE INTERNAL "Already loaded files.")	
      rcf_download(${url} ${projectid} ${outdir})
      set(outdir ${outdir} PARENT_SCOPE)
    endif()
	else()
    rcf_generatefilepath(${projectid} ${url} localdir)
		if(NOT EXISTS ${localdir})
			message(STATUS "Download ${url} to ${localdir}!")
			file(DOWNLOAD ${url} ${localdir} STATUS status)
			list(GET status 0 ErrorId)
			list(GET status 1 ErrorText)
			if(NOT ${ErrorId} EQUAL 0)
				if(COMMAND rcf_download_failed)
					rcf_download_failed(${projectid} ${url} ${localdir} ${ErrorId} ${ErrorText})
				endif()
				return()
			endif()
		else()
			message(STATUS "Found ${url} at ${localdir}")
		endif()
		list(APPEND DOWNLOAD_CACHE_KEYS ${${CMAKE_PROJECT_NAME}_DOWNLOAD_CACHE_KEYS} ${url})
    set(${CMAKE_PROJECT_NAME}_DOWNLOAD_CACHE_KEYS "${DOWNLOAD_CACHE_KEYS}" CACHE INTERNAL "Already loaded files.")	
		set(${${CMAKE_PROJECT_NAME}_DOWNLOAD_CACHE_KEYS}_PATH ${localdir} CACHE INTERNAL "Path to the loaded file.")	
		set(outdir ${localdir} PARENT_SCOPE)
		if(COMMAND rcf_download_success)
			rcf_download_success(${projectid} ${url} ${localdir})
		endif()
	endif()
endfunction()