function(Enable_target_OOP target)
    get_target_property(temp ${target} SOURCES)
    get_target_property(target_bin_dir ${target} BINARY_DIR)
    set(out_file "${target_bin_dir}/dragoneer2/OOP/OOP_.h")
    file(WRITE "${out_file}" "// Generated\n\n"
            "#ifndef GENERATED_OOP__H\n"
            "#define GENERATED_OOP__H\n")
    #    message(${out_file})
    message(STATUS "Sources file in ${target}: ${temp}")

    foreach (source ${temp})
        get_target_property(target_src_dir ${target} SOURCE_DIR)
        set(source "${target_src_dir}/${source}")
        _Dgn2_OOP_scan_source(${source} ${target})
    endforeach ()

    file(APPEND "${out_file}" "///////////////"
            "\n#endif // GENERATED_OOP__H\n")

endfunction()

function(_Dgn2_OOP_scan_source source target)
    set(space "[ \t\n\r]")
    set(idregex "[a-zA-Z0-9_]")

    get_target_property(target_bin_dir ${target} BINARY_DIR)

    set(out_file "${target_bin_dir}/dragoneer2/OOP/OOP_.h")
    target_include_directories(${target} PRIVATE ${target_bin_dir}/dragoneer2)
    #    message(STATUS "out file: ${out_file}/OOP/")

    message(STATUS "Scanning source: ${source}")
    FILE(READ "${source}" content)
    #    message(STATUS "${content}")
    set(pattern "DgnInterface${space}*\\(${space}*${idregex}+${space}*\\)${space}*\\{[^}]*}")
    #    message(${pattern})
    string(REPLACE ";" "~SEMI~" content "${content}")
    string(REGEX MATCHALL
            "${pattern}"
            matches "${content}")
    #    message(STATUS "matches: ${matches}")
    foreach (match ${matches})
        string(REGEX REPLACE "DgnInterface${space}*\\(${space}*(${idregex}+)${space}*\\).*" "\\1" int_name "${match}")
        #        message(STATUS "match ${int_name} got  ${c_call} ${c_func}")
        _Dgn2_OOP_scan_interface("${match}" ${int_name} c_call c_func c_sfunc)


        file(APPEND ${out_file} "\n\n//===== Interface ${int_name} \n\n")

        # Virtual table

        set(result "struct ${int_name}_Vft {")
        foreach (sfunc ${c_sfunc})
            set(result "${result} ${sfunc};")
        endforeach ()
        set(result "${result}\n};\n")
        file(APPEND ${out_file} "${result}\n\n")

        # Implementation Helper


        set(result "#define Implement_${int_name}(CLASS)\\\n")
        foreach (func ${c_func})
            string(REPLACE "\n" "" func "${func}")
            string(REPLACE "*" "* " func "${func}")
            string(REGEX REPLACE "struct${space}*${int_name} " "void* " func "${func};")
            string(REPLACE " ${int_name}_" " CLASS##_" func "${func}")
            set(result "${result} ${func}\\\n")
        endforeach ()
        set(result "${result} static struct ${int_name}_Vft CLASS##_Vft_${int_name} = {\\\n")
        foreach (func ${c_call})
            string(REPLACE " \n" "" func "${func}")
            #            string(REPLACE "${int_name} " " void* " func " ${func}")
            #            string(REPLACE " ${int_name}_" " CLASS##_" func "${func};")
            string(REGEX REPLACE "\\(self.pVft\\)->${space}*(${idregex}+).*" "\\1" func "${func}")
            string(REGEX REPLACE " " "" func "${func}")
            set(result "${result}   .${func}   =  CLASS##_${func},\\\n")
        endforeach ()
        set(result "${result}};\\\n\n")
        file(APPEND ${out_file} "${result}\n")


        # wrapper struct

        file(
                APPEND ${out_file}
                "struct ${int_name} {\n"
                "   void* data;\n"
                "   struct ${int_name}_Vft* pVft;\n"
                "};\n\n"
        )

        # functions

        foreach (item IN ZIP_LISTS c_func c_call)
            set(result "static inline ${item_0} {\n      return ${item_1}; \n    }\n")
            #            message(STATUS "${result}")
            file(APPEND ${out_file} "${result}")
        endforeach ()
    endforeach ()
endfunction()

function(_Dgn2_OOP_scan_interface decl int_name out_call out_func out_sfunc)
    set(space "[ \t\n\r]")
    set(idregex "[a-zA-Z0-9_]")

    string(REPLACE "~SEMI~" ";" decl "${decl}")
    string(REGEX REPLACE "DgnInterface[^{]*{|}" "" decl "${decl}")
    #    message(STATUS "Scanning interface: ${decl}")
    string(REGEX MATCHALL "^.+DgnMethod[^;]*;" calling "${decl}")
    string(REGEX REPLACE "DgnMethod${space}*\\(${space}*(${idregex}+)${space}\\)" "${int_name}_\\1" func "${calling}")
    string(REGEX REPLACE "DgnMethod${space}*\\(${space}*(${idregex}+)${space}\\)" "(*\\1)" sfunc "${calling}")
    string(REGEX REPLACE "DgnSelf" "struct ${int_name} self" func "${func}")
    string(REGEX REPLACE "DgnSelf" "void * self" sfunc "${sfunc}")
    #    message(${sfunc})
    set(${out_func} ${func} PARENT_SCOPE)
    set(${out_sfunc} ${sfunc} PARENT_SCOPE)
    #    message(STATUS "Calling:" ${calling})
    string(REGEX REPLACE "DgnMethod${space}*\\(${space}*(${idregex}+)${space}\\)" "\\1" calling "${calling}")
    string(REGEX REPLACE "[^a-zA-Z0-9(),_;]" " " calling "${calling}")
    string(REGEX REPLACE "${space}+" " " calling "${calling}")
    string(REGEX REPLACE "${space}*([,()])${space}*" "\\1" calling "${calling}")
    string(REGEX REPLACE "[A-Za-z0-9_ ]+( ${idregex}+[,)])" "\\1" calling "${calling}")
    string(REGEX REPLACE "DgnSelf" "self.data" calling "${calling}")
    string(REGEX REPLACE "${idregex}+(([^;])+)" "(self.pVft)->\\1" calling "${calling}")
    #    message(STATUS "Calling: ${calling}")
    set(${out_call} ${calling} PARENT_SCOPE)
endfunction()