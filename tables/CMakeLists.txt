FIND_PROGRAM(CREATE_DB ibus-table-createdb)
IF (CREATE_DB STREQUAL "CREATE_DB-NOTFOUND")
    MESSAGE(FATAL_ERROR "ibus-table-createdb is not installed")
ENDIF(CREATE_DB STREQUAL "CREATE_DB-NOTFOUND")

IF(NOT DEFINED DB_INSTALL_DIRECTORY)
    SET(DB_INSTALL_DIRECTORY "${DATA_DIR}/ibus-table/tables")
ENDIF(NOT DEFINED DB_INSTALL_DIRECTORY)

IF(NOT DEFINED DEFAULT_FREQ)
    SET(DEFAULT_FREQ 1000)
ENDIF(NOT DEFINED DEFAULT_FREQ)

IF(NOT DEFINED ICON_INSTALL_DIRECTORY)
    SET(ICON_INSTALL_DIRECTORY "${DATA_DIR}/ibus-table/icons")
ENDIF(NOT DEFINED ICON_INSTALL_DIRECTORY)

FIND_PROGRAM(SED_CMD sed)
IF(SED_CMD STREQUAL "SED_CMD-NOTFOUND")
    MESSAGE(FATAL_ERROR "sed is not found!")
ENDIF(SED_CMD STREQUAL "SED_CMD-NOTFOUND")

FIND_PROGRAM(ICONV_CMD iconv)
IF(ICONV_CMD STREQUAL "ICONV_CMD-NOTFOUND")
    MESSAGE(FATAL_ERROR "iconv is not found!")
ENDIF(ICONV_CMD STREQUAL "ICONV_CMD-NOTFOUND")

FIND_PROGRAM(AWK_CMD NAMES awk gawk)
IF(AWK_CMD STREQUAL "AWK_CMD-NOTFOUND")
    MESSAGE(FATAL_ERROR "awk or gawk is not found!")
ENDIF(AWK_CMD STREQUAL "AWK_CMD-NOTFOUND")


MACRO(CONVERT_ENCODING outputFile fromEncoding inputFile )
    SET(_GENERATE_FREQ 0)
    MESSAGE("Converting ${outputFile}")
    MESSAGE("  Appending ${inputFile}")
    EXECUTE_PROCESS(COMMAND ${SED_CMD} -e "s/^[\\xff][\\xfe]//" ${inputFile}
	OUTPUT_FILE "${outputFile}.tmp"
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	)

    FOREACH(_arg ${ARGN})
	IF(_arg STREQUAL "GENERATE_FREQ")
	    SET(_GENERATE_FREQ 1)
	ELSE(_arg STREQUAL "GENERATE_FREQ")
	    MESSAGE("  Appending ${_arg}")

	    # Need to strip Unicode BOM (0xfeff)
	    EXECUTE_PROCESS(COMMAND ${SED_CMD} -e "s/^[\\xff][\\xfe]//" ${_arg}
		OUTPUT_FILE "${_arg}.tmp"
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
		)

	    EXECUTE_PROCESS(COMMAND cat "${outputFile}.tmp" "${_arg}.tmp"
		OUTPUT_FILE "${outputFile}"
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
		)

	    EXECUTE_PROCESS(COMMAND cmake -E copy "${outputFile}" "${outputFile}.tmp"
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
		)

	    FILE(REMOVE "${_arg}.tmp")

	ENDIF(_arg STREQUAL "GENERATE_FREQ")
    ENDFOREACH(_arg ${ARGN})

    EXECUTE_PROCESS(COMMAND ${ICONV_CMD} -f ${fromEncoding} -t UTF8 "${outputFile}.tmp"
	COMMAND sed -e "s/\r//"
	COMMAND ${AWK_CMD} "{print tolower($0)}"
	COMMAND sort
	OUTPUT_FILE "${outputFile}"
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	)

    IF(_GENERATE_FREQ)
	EXECUTE_PROCESS(COMMAND cmake -E copy "${outputFile}" "${outputFile}.tmp"
	    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	    )
	EXECUTE_PROCESS(COMMAND ${AWK_CMD} -F "\\t"  "{ if (lastLine != $1) {lastLine=$1; freq=1000} else{ freq--}; printf(\"%s\\t%s\\t%d\\n\",$1,$2,freq)}" "${outputFile}.tmp"
	    OUTPUT_FILE "${outputFile}"
	    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	    )
    ENDIF(_GENERATE_FREQ)
    FILE(REMOVE "${outputFile}.tmp")
ENDMACRO(CONVERT_ENCODING CONVERT_ENCODING outputFile fromEncoding inputFile)

CONVERT_ENCODING(array30_27489.utf8 UTF16 array30_27489.txt GENERATE_FREQ)
EXECUTE_PROCESS(COMMAND cat array.head array30_27489.utf8 array.tail
    OUTPUT_FILE array30.txt
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )

CONVERT_ENCODING(array30-big.utf8 UTF16 array30_27489.txt array30_ExtB.txt GENERATE_FREQ)

EXECUTE_PROCESS(COMMAND cat array-big.head array30-big.utf8 array.tail
    OUTPUT_FILE array30-big.txt
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )

EXECUTE_PROCESS(COMMAND ln -fs xinhua-ibus.txt xinhua.txt
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )

EXECUTE_PROCESS(COMMAND ln -fs yong-ibus.txt yong.txt
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )

SET_SOURCE_FILES_PROPERTIES(array30_27489.utf8 array30-big.tmp array30-big.utf8
    array30.txt array30-big.txt xinhua.txt yong.txt
   PROPERTIES GENERATED true)

ADD_CUSTOM_TARGET(convert_all ALL)

MACRO(CONVERT_DB targetName pattern)
    FILE(GLOB_RECURSE _tableList RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${pattern}.txt")
    FOREACH(_arg ${ARGN})
	FILE(GLOB_RECURSE _tableAppend RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${_arg}.txt")
	LIST(APPEND _tableList ${_tableAppend})
    ENDFOREACH(_arg ${ARGN})

    # CMakeLists.txt is not a table.
    LIST(REMOVE_ITEM _tableList "CMakeLists.txt")
    #MESSAGE("_tableList=${_tableList}")
    SET(_dependDb "")
    SET(_dependIcon "")
    FOREACH(_tabFile ${_tableList})
	GET_FILENAME_COMPONENT(_tabName "${_tabFile}" NAME_WE)
	ADD_CUSTOM_COMMAND(OUTPUT ${_tabName}.db
	    COMMAND ${CREATE_DB} -n ${_tabName}.db -s ${_tabFile}
	    DEPENDS ${_tabFile}
	    COMMENT "Building ${_tabName} table..."
	    )
	LIST(APPEND _dependDb "${_tabName}.db")
	IF(EXISTS "${CMAKE_SOURCE_DIR}/icons/${_tabName}.png")
	    LIST(APPEND _dependIcon "../icons/${_tabName}.png")
	ELSEIF(EXISTS "${CMAKE_SOURCE_DIR}/icons/${_tabName}.svg")
	    LIST(APPEND _dependIcon "../icons/${_tabName}.svg")
	ELSEIF(EXISTS "${CMAKE_SOUREC_DIR}/icons/${_tabName}.gif")
	    LIST(APPEND _dependIcon "../icons/${_tabName}.gif")
	ELSEIF(EXISTS "${CMAKE_SOURCE_DIR}/icons/${_tabName}.jpg")
	    LIST(APPEND _dependIcon "../icons/${_tabName}.jpg")
	ENDIF(EXISTS "${CMAKE_SOURCE_DIR}/icons/${_tabName}.png")
    ENDFOREACH(_tabFile ${_tableList})

    ADD_CUSTOM_TARGET(convert_${targetName}
	COMMENT "Building ${targetName} table(s)..."
	DEPENDS ${_dependDb}
	)

    ADD_CUSTOM_TARGET(install_${targetName}
	COMMAND cmake -E copy ${_dependDb} ${DB_INSTALL_DIRECTORY}
	COMMAND cmake -E copy ${_dependIcon} ${ICON_INSTALL_DIRECTORY}
	COMMENT "Install ${targetName} table and icons"
	DEPENDS ${_dependDb}
	)

    ADD_DEPENDENCIES(convert_all convert_${targetName})
    #MESSAGE("_dependIcon=${_dependIcon}")

    INSTALL(FILES ${_dependDb}
	DESTINATION ${DB_INSTALL_DIRECTORY})
    INSTALL(FILES ${_dependIcon}
	DESTINATION ${ICON_INSTALL_DIRECTORY})
ENDMACRO(CONVERT_DB dbs targetName pattern)

CONVERT_DB(array "array30" "array30-big")
CONVERT_DB(cangjie "cangjie*" "scj*")
CONVERT_DB(cantonese "canton*" "jyutping*")
CONVERT_DB(easy "easy*")
CONVERT_DB(erbi "erbi*")
CONVERT_DB(quick "quick*")
CONVERT_DB(stroke5 "stroke5")
CONVERT_DB(wu "wu")
CONVERT_DB(wubi-jidian "wubi*")
CONVERT_DB(wubi-heifeng "wubi*")
CONVERT_DB(cangjie "cangjie*" "scj*")
CONVERT_DB(yong "yong")
CONVERT_DB(ziranma "ziranma*")


