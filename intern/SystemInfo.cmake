#[[.rst System info
===========

.. cmake:macro:: rcf_getsysteminfos()

    This macro will set following global variables.
    
* ${CMAKE_PROJECT_NAME}_COMPILEDFORARCHITECTURE
* ${CMAKE_PROJECT_NAME}_ENDIANNESS
]]
macro(rcf_getsysteminfos)
    # Figure out if the target architecture is 32Bit or 64Bit.
    if(NOT DEFINED ${CMAKE_PROJECT_NAME}_COMPILEDFORARCHITECTURE)
        if(CMAKE_SIZEOF_VOID_P EQUAL 4)
            set(${CMAKE_PROJECT_NAME}_COMPILEDFORARCHITECTURE "_32Bit" CACHE STRING "")
        elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
            set(${CMAKE_PROJECT_NAME}_COMPILEDFORARCHITECTURE "_64Bit" CACHE STRING "")
        else()
            set(${CMAKE_PROJECT_NAME}_COMPILEDFORARCHITECTURE "Unknown" CACHE STRING "")
        endif()
    endif()

    #endianness
    if(NOT DEFINED ${CMAKE_PROJECT_NAME}_ENDIANNESS)
        include(TestBigEndian)
        TEST_BIG_ENDIAN(ENDIANNESS)
        IF(${ENDIANNESS})
            set(${CMAKE_PROJECT_NAME}_ENDIANNESS "Big" CACHE STRING "")
        else()
            set(${CMAKE_PROJECT_NAME}_ENDIANNESS "Little" CACHE STRING "")
        endif()
    endif()
endmacro()