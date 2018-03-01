#[[.rst Package management
==================
]]
get_filename_component(packagemanager_dir "${RCF_PATH}/intern/packages/" ABSOLUTE)

set(RCF_ADDED_PACKAGES "" CACHE INTERNAL "")

set(RCF_PACKAGES "" CACHE INTERNAL "")

#[[.rst .. cmake:function:: rcf_addpackage(packagename [version])

  This function will obtain and add the specified package to the project.  

  :param packagename: Which package should be added to the project.
  :param version: Specifies the version of the package.
]]
function(rcf_addpackage packagename)
  if(${packagename} IN_LIST RCF_ADDED_PACKAGES)
    return()
  else()
    set(RCF_ADDED_PACKAGES "${RCF_ADDED_PACKAGES};${packagename}" CACHE INTERNAL "")
  endif()

  set(package_version "newest")
  if(${ARGC} EQUAL 2)
    set(package_version ${ARGV1})
  endif()

  cmake_policy(PUSH)
  cmake_policy(SET CMP0057 NEW)
  if("${packagename}" IN_LIST RCF_PACKAGES)
    set(packagemanager_dir "${${packagename}_PACKAGE_DIR}")
  endif()
  cmake_policy(POP)

  set(package_file "")
  if(EXISTS "${packagemanager_dir}/${packagename}.cmake")
    message(STATUS "Looking for ${packagename} in the repo: found")
    set(package_file "${packagemanager_dir}/${packagename}.cmake")
    set(package_protocol "")
    set(package_source "")
    set(package_revision "")
    include("${packagemanager_dir}/${packagename}.cmake")    
  else()
    message("Looking for ${packagename} in the repo: not found")
  endif()
  
  if(NOT ${package_protocol} STREQUAL "")
    rcf_addlocation(${packagename}${package_version} ${package_protocol} ${package_source})
    if(NOT ${package_revision} STREQUAL "")
      rcf_obtain_project(${packagename}${package_version} outdir ${package_revision})      
    else()
      rcf_obtain_project(${packagename}${package_version} outdir)
    endif()

    build_package(${outdir})
  endif()
endfunction()

#[[.rst .. cmake:function:: rcf_register_package(name)

  This function will register the specified package in the internal register and 
  set the directory.

  :param name: Which package should be registered.
]]
function(rcf_register_package name)
  set(RCF_PACKAGES "${RCF_PACKAGES};${name}" CACHE INTERNAL "")
  set(${name}_PACKAGE_DIR "${CMAKE_CURRENT_LIST_DIR}/packages" CACHE INTERNAL "")
endfunction()

#[[.rst .. cmake:function:: rcf_register_package_repository(name protocol source)

  This function allows to register a 3rd party repository to the project.

  :param name: Specify the name of the repository.
  :param protocol: Which protocol should be used to obtain it? E.g. "git".
  :param source: Specify the location of the 3rd party repository.
]]
function(rcf_register_package_repository name protocol source)
  rcf_obtain(${name} ${protocol} ${source} dir)
  if (EXISTS ${dir}/packagelist.cmake)
    include("${dir}/packagelist.cmake")
  endif()
endfunction()