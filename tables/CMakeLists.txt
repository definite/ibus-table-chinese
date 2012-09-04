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


################################################################
# GENERATE_FREQ(outputFile inputFile)
#
MACRO(GENERATE_FREQ outputFile inputFile)
    ADD_CUSTOM_COMMAND(OUTPUT ${outputFile}
	COMMAND ${AWK_CMD} -F "\\t"
	"{ if (lastLine != $1) {lastLine=$1; freq=1000} else{ freq--}; printf(\"%s\\t%s\\t%d\\n\",$1,$2,freq)}"
	${inputFile} > ${outputFile}
	DEPENDS ${inputFile}
	COMMENT "Generate frequency information for ${outputFile}"
	VERBATIM
	)
ENDMACRO(GENERATE_FREQ outputFile inputFile)


################################################################
# CONVERT_ENCODING(workDir outputFile fromEncoding inputFile)
#
MACRO(CONVERT_ENCODING outputFile fromEncoding inputFile )
    # Need to strip Unicode BOM (0xfeff)
    ADD_CUSTOM_COMMAND(OUTPUT ${outputFile}
	COMMAND ${SED_CMD} -e "s/^[\\xff][\\xfe]//" ${inputFile}
	COMMAND ${ICONV_CMD} -f ${fromEncoding} -t UTF8
	COMMAND ${SED_CMD} -e "s/\r//"
	COMMAND ${AWK_CMD} "{print tolower($0)}"
	COMMAND sort > ${outputFile}
	DEPENDS ${inputFile}
	COMMENT "Convert encoding from ${fromEncoding} for ${outputFile}"
	VERBATIM
	)
ENDMACRO(CONVERT_ENCODING outputFile fromEncoding inputFile)

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

    M_MSG(${M_INFO1} "_tableList=${_tableList}")
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


