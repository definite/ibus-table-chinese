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


MACRO(CONVERT_ENCODING workDir outputFile fromEncoding inputFile )
    SET(_GENERATE_FREQ 0)
    MESSAGE("Converting ${workDir}/${outputFile}")
    MESSAGE("  Appending ${workDir}/${inputFile}")
    EXECUTE_PROCESS(COMMAND ${SED_CMD} -e "s/^[\\xff][\\xfe]//" ${inputFile}
	OUTPUT_FILE "${outputFile}.tmp"
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${workDir}
	)

    FOREACH(_arg ${ARGN})
	IF(_arg STREQUAL "GENERATE_FREQ")
	    SET(_GENERATE_FREQ 1)
	ELSE(_arg STREQUAL "GENERATE_FREQ")
	    MESSAGE("  Appending ${_arg}")

	    # Need to strip Unicode BOM (0xfeff)
	    EXECUTE_PROCESS(COMMAND ${SED_CMD} -e "s/^[\\xff][\\xfe]//" ${_arg}
		OUTPUT_FILE "${_arg}.tmp"
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${workDir}
		)

	    EXECUTE_PROCESS(COMMAND cat "${outputFile}.tmp" "${_arg}.tmp"
		OUTPUT_FILE "${outputFile}"
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${workDir}
		)

	    EXECUTE_PROCESS(COMMAND cmake -E copy "${outputFile}" "${outputFile}.tmp"
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${workDir}
		)

	    FILE(REMOVE "${CMAKE_CURRENT_SOURCE_DIR}/${workDir}/${_arg}.tmp")

	ENDIF(_arg STREQUAL "GENERATE_FREQ")
    ENDFOREACH(_arg ${ARGN})

    EXECUTE_PROCESS(COMMAND ${ICONV_CMD} -f ${fromEncoding} -t UTF8 "${outputFile}.tmp"
	COMMAND sed -e "s/\r//"
	COMMAND ${AWK_CMD} "{print tolower($0)}"
	COMMAND sort
	OUTPUT_FILE "${outputFile}"
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${workDir}
	)

    IF(_GENERATE_FREQ)
	EXECUTE_PROCESS(COMMAND cmake -E copy "${outputFile}" "${outputFile}.tmp"
	    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${workDir}
	    )
	EXECUTE_PROCESS(COMMAND ${AWK_CMD} -F "\\t"  "{ if (lastLine != $1) {lastLine=$1; freq=1000} else{ freq--}; printf(\"%s\\t%s\\t%d\\n\",$1,$2,freq)}" "${outputFile}.tmp"
	    OUTPUT_FILE "${outputFile}"
	    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${workDir}
	    )
    ENDIF(_GENERATE_FREQ)
    FILE(REMOVE "${CMAKE_CURRENT_SOURCE_DIR}/${workDir}/${outputFile}.tmp")
ENDMACRO(CONVERT_ENCODING CONVERT_ENCODING workDir outputFile fromEncoding inputFile)

#######################################################################
# Preprocessing tables
#

# Array
CONVERT_ENCODING(array array30_27489.utf8 UTF16 array30_27489.txt GENERATE_FREQ)
ADD_CUSTOM_COMMAND(OUTPUT array/array30.txt
    COMMAND cat array30.head.common array30.head array30_27489.utf8 array30.tail > array30.txt
    DEPENDS array/array30.head.common
      array/array30.head
      array/array30_27489.utf8
      array/array30.tail
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/array
    VERBATIM
    )

CONVERT_ENCODING(array array30-big.utf8 UTF16 array30_27489.txt array30_ExtB.txt GENERATE_FREQ)
ADD_CUSTOM_COMMAND(OUTPUT array/array30-big.txt
    COMMAND cat array30.head.common array30-big.head array30-big.utf8 array30.tail > array30-big.txt
    DEPENDS array/array30.head.common
      array/array30-big.head
      array/array30-big.utf8
      array/array30.tail
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/array
    VERBATIM
    )

# wubi-haifeng
# Generate the table tooks a long time
#ADD_CUSTOM_COMMAND(OUTPUT
#    ${CMAKE_CURRENT_SOURCE_DIR}/wubi-haifeng/wubi-haifeng86.UTF-8
#    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/wubi-haifeng/convertTable.sh
#    COMMENT "Building wubi-haifeng86.UTF-8"
#    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/wubi-haifeng
#    )

ADD_CUSTOM_COMMAND(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/wubi-haifeng/wubi-haifeng86.txt
    COMMAND cat wubi-haifeng86.head wubi-haifeng86.UTF-8 wubi-haifeng86.tail > wubi-haifeng86.txt
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/wubi-haifeng
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/wubi-haifeng/wubi-haifeng86.UTF-8
    COMMENT "Building wubi-haifeng86.txt"
    VERBATIM
    )

ADD_CUSTOM_TARGET(convert_all ALL)

MACRO(CONVERT_DB targetName pattern)
    FILE(GLOB_RECURSE _tableList RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${pattern}")
    FOREACH(_arg ${ARGN})
	FILE(GLOB_RECURSE _tableAppend RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${_arg}")
	GET_FILENAME_COMPONENT(_tabAppPath "${_tableAppend}" PATH)
	GET_FILENAME_COMPONENT(_tabAppWe "${_tableAppend}" NAME_WE)
	LIST(APPEND _tableList ${_tableAppend} )
    ENDFOREACH(_arg ${ARGN})

    MESSAGE("_tableList=${_tableList}")
    SET(_dependDb "")
    SET(_dependIcon "")
    FOREACH(_tabFile ${_tableList})
	GET_FILENAME_COMPONENT(_tabName "${_tabFile}" NAME_WE)
	GET_FILENAME_COMPONENT(_tabPath "${_tabFile}" PATH)
	SET(_tabF "${_tabPath}/${_tabName}.txt")
	SET(_dbF "${_tabPath}/${_tabName}.db")
	ADD_CUSTOM_COMMAND(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/${_dbF}
	    COMMAND ${CREATE_DB} -n ${_dbF} -s ${_tabF}
	    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
	    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${_tabF}
	    COMMENT "Building ${_tabName} table"
	    )
	LIST(APPEND _dependDb "${_dbF}")
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

CONVERT_DB(array "array/array30.head" "array/array30-big.head")
CONVERT_DB(cangjie "cangjie/cangjie*.txt")
CONVERT_DB(cantonese "cantonese/canton*.txt" "cantonese/jyutping*.txt")
CONVERT_DB(easy "easy/easy*.txt")
CONVERT_DB(erbi "erbi/erbi*.txt")
CONVERT_DB(quick "quick/quick*.txt")
CONVERT_DB(stroke5 "stroke5/stroke*.txt")
CONVERT_DB(scj "scj/scj*.txt")
CONVERT_DB(wu "wu/wu*.txt")
CONVERT_DB(wubi-haifeng "wubi-haifeng/wubi-haifeng86.head")
CONVERT_DB(wubi-jidian "wubi-jidian/wubi*.txt")
CONVERT_DB(yong "yong/yong.txt")


