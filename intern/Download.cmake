#
# Supported systems: http, https
# Provided functionality:
# -download files from web
# -execution chain

set(${CMAKE_PROJECT_NAME}_DOWNLOAD_CACHE_KEYS "" CACHE INTERNAL "Already loaded files.")

#
#
#

macro(rcf_generatefilepath url variable)
	get_filename_component(filename ${url} NAME)
	set(${variable} "${PROJECT_BINARY_DIR}/DownloadedDependencies/Files/${filename}")
endmacro()

function(rcf_download url projectid outdir)
	message(STATUS "${projectid} need ${url}")
	if(NOT ";${url};" MATCHES ";${${CMAKE_PROJECT_NAME}_DOWNLOAD_CACHE_KEYS};")
		rcf_generatefilepath(${url} localdir)
		if(NOT EXISTS ${localdir})
			message(STATUS "Download ${url} !")
			#file(DOWNLOAD ${url} ${localdir} STATUS status)
			set(LIST status 1 "asdf")
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
		
		list(APPEND ${CMAKE_PROJECT_NAME}_DOWNLOAD_CACHE_KEYS ${url})
		set(${${CMAKE_PROJECT_NAME}_DOWNLOAD_CACHE_KEYS}_PATH ${localdir} CACHE INTERNAL "Path to the loaded file.")	
		set(outdir ${localdir})
		if(COMMAND rcf_download_success)
			rcf_download_success(${projectid} ${url} ${outdir})
		endif()
	else()
		set(outdir ${${${CMAKE_PROJECT_NAME}_DOWNLOAD_CACHE_KEYS}_PATH})	
		message(STATUS "Found ${url} at ${${${CMAKE_PROJECT_NAME}_DOWNLOAD_CACHE_KEYS}_PATH}.")
	endif()
endfunction()