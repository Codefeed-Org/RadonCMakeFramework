macro(rcf_getsysteminfos)
    # Figure out if the target architecture is 32Bit or 64Bit.
    if(CMAKE_SIZEOF_VOID_P EQUAL 4)
        set(${CMAKE_PROJECT_NAME}_COMPILEDFORARCHITECTURE "_32Bit")
    elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(${CMAKE_PROJECT_NAME}_COMPILEDFORARCHITECTURE "_64Bit")
    else()
        set(${CMAKE_PROJECT_NAME}_COMPILEDFORARCHITECTURE "Unknown")
    endif()

    #endianness
    include(TestBigEndian)
    TEST_BIG_ENDIAN(ENDIANNESS)
    IF(${ENDIANNESS})
        set(${CMAKE_PROJECT_NAME}_ENDIANNESS "Big")
    else()
        set(${CMAKE_PROJECT_NAME}_ENDIANNESS "Little")
    endif()
endmacro()