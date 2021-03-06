#=============================================================================#
# Sets compiler flags on the given target, according also to the given board ID.
#       _target_name - Name of the target (Executable or Library) to set flags on.
#       _board_id - Target's bounded board ID.
#=============================================================================#
function(set_compiler_target_flags _target_name _board_id)

    set(option_args PRIVATE PUBLIC INTERFACE)
    set(single_args LANGUAGE)
    cmake_parse_arguments(compiler "${option_args}" "${single_args}" "" ${ARGN})

    if (compiler_LANGUAGE)
        if (compiler_PRIVATE)
            set(scope PRIVATE)
        elseif (compiler_INTERFACE)
            set(scope INTERFACE)
        else ()
            set(scope PUBLIC)
        endif ()
        parse_compiler_recipe_flags("${_board_id}" compiler_recipe_flags
                LANGUAGE "${compiler_LANGUAGE}")
        target_compile_options(${_target_name} ${scope}
                $<$<COMPILE_LANGUAGE:${compiler_LANGUAGE}>:${compiler_recipe_flags}>)
    else ()
        parse_compiler_recipe_flags("${_board_id}" compiler_recipe_flags)
        target_compile_options(${_target_name} PUBLIC ${compiler_recipe_flags})
    endif ()

endfunction()

#=============================================================================#
# Sets linker flags on the given target, according also to the given board ID.
#       _target_name - Name of the target (Executable or Library) to set flags on.
#       _board_id - Target's bounded board ID.
#=============================================================================#
function(set_linker_flags _target_name _board_id)

    parse_linker_recpie_pattern("${_board_id}" linker_recipe_flags)
    string(REPLACE ";" " " cmake_compliant_linker_flags "${linker_recipe_flags}")
    set(CMAKE_EXE_LINKER_FLAGS "${cmake_compliant_linker_flags}" CACHE STRING "" FORCE)

endfunction()

#=============================================================================#
# Sets compiler and linker flags on the given Executable target,
# according also to the given board ID.
#       _target_name - Name of the target (Executable) to set flags on.
#       _board_id - Target's bounded board ID.
#=============================================================================#
function(set_executable_target_flags _target_name _board_id)

    set_compiler_target_flags(${_target_name} "${_board_id}")
    set_linker_flags(${_target_name} "${_board_id}")

    target_link_libraries(${_target_name} PUBLIC m) # Add math library

    # Modify executable's suffix to be '.elf'
    set_target_properties("${_target_name}" PROPERTIES SUFFIX ".elf")

endfunction()

#=============================================================================#
# Sets upload/flash flags on the given target, according also to the given board ID.
#       _target_name - Name of the target (Executable) to set flags on.
#       _board_id - Target's bounded board ID.
#=============================================================================#
function(set_upload_target_flags _target_name _board_id _upload_port _return_var)

    set(upload_flags "")

    # Parse and append recipe flags
    parse_upload_recipe_pattern("${_board_id}" "${_upload_port}" upload_recipe_flags)
    list(APPEND upload_flags "${upload_recipe_flags}")

    set(target_binary_base_path "${CMAKE_CURRENT_BINARY_DIR}/${_target_name}")

    list(APPEND upload_flags "-Uflash:w:\"${target_binary_base_path}.hex\":i")
    list(APPEND upload_flags "-Ueeprom:w:\"${target_binary_base_path}.eep\":i")

    set(${_return_var} "${upload_flags}" PARENT_SCOPE)

endfunction()

