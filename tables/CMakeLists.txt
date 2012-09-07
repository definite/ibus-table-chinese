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
# CONVERT_ENCODING(outputFile fromEncoding inputFile)
#
MACRO(CONVERT_ENCODING outputFile fromEncoding inputFile )
    # Need to strip Unicode BOM (0xfeff)
    ADD_CUSTOM_COMMAND(OUTPUT ${outputFile}
	COMMAND ${SED_CMD} -e "s/^[\\xff][\\xfe]//" ${inputFile}
	| ${ICONV_CMD} -f ${fromEncoding} -t UTF8
	| ${SED_CMD} -e "s/\r//"
	| ${AWK_CMD} "{print tolower($0)}"
	| sort > ${outputFile}
	DEPENDS ${inputFile}
	COMMENT "Convert encoding from ${fromEncoding} for ${outputFile}"
	VERBATIM
	)
ENDMACRO(CONVERT_ENCODING outputFile fromEncoding inputFile)

################################################################
# MAKE_TABLE_SOURCE_TXT(outputFile inputFile1 [inputFile2 ....])
#
MACRO(MAKE_TABLE_SOURCE_TXT outputFile)
    ADD_CUSTOM_COMMAND(OUTPUT ${outputFile}
	COMMAND cat ${ARGN} > ${outputFile}
	DEPENDS ${ARGN}
	COMMENT "Making table source ${outputFile}"
	VERBATIM
	)
ENDMACRO(MAKE_TABLE_SOURCE_TXT outputFile)

ADD_CUSTOM_TARGET(convert_all ALL)

MACRO(CONVERT_DB targetName)
    SET(_tableList "")
    SET(_dependDb "")
    SET(_dependIcon "")
    FOREACH(_tabFile ${ARGN})
	GET_FILENAME_COMPONENT(_tabName "${_tabFile}" NAME_WE)
	SET(_dbF "${_tabName}.db")
	ADD_CUSTOM_COMMAND(OUTPUT ${_dbF}
	    COMMAND ${CREATE_DB} -n ${_dbF} -s ${_tabFile}
	    DEPENDS ${_tabFile}
	    COMMENT "Building ${_tabName} table"
	    )
	LIST(APPEND _dependDb "${_dbF}")
	IF(EXISTS "${CMAKE_SOURCE_DIR}/icons/${_tabName}.png")
	    LIST(APPEND _dependIcon "${CMAKE_SOURCE_DIR}/icons/${_tabName}.png")
	ELSEIF(EXISTS "${CMAKE_SOURCE_DIR}/icons/${_tabName}.svg")
	    LIST(APPEND _dependIcon "${CMAKE_SOURCE_DIR}/icons/${_tabName}.svg")
	ELSEIF(EXISTS "${CMAKE_SOUREC_DIR}/icons/${_tabName}.gif")
	    LIST(APPEND _dependIcon "${CMAKE_SOURCE_DIR}/icons/${_tabName}.gif")
	ELSEIF(EXISTS "${CMAKE_SOURCE_DIR}/icons/${_tabName}.jpg")
	    LIST(APPEND _dependIcon "${CMAKE_SOURCE_DIR}/icons/${_tabName}.jpg")
	ENDIF(EXISTS "${CMAKE_SOURCE_DIR}/icons/${_tabName}.png")
    ENDFOREACH(_tabFile ${ARGN})
    M_MSG(${M_INFO1} "[${targetName}] db files=${_dependDb}")

    ADD_CUSTOM_TARGET(convert_${targetName}
	COMMENT "Building ${targetName} table(s)..."
	DEPENDS ${_dependDb}
	)

    ADD_CUSTOM_TARGET(install_${targetName}
	COMMAND install ${_dependDb} ${DB_INSTALL_DIRECTORY}
	COMMAND install ${_dependIcon} ${ICON_INSTALL_DIRECTORY}
	COMMENT "Install ${targetName} table and icons"
	DEPENDS ${_dependDb}
	)

    ADD_DEPENDENCIES(convert_all convert_${targetName})
    #MESSAGE("_dependIcon=${_dependIcon}")

    INSTALL(FILES ${_dependDb}
	DESTINATION ${DB_INSTALL_DIRECTORY})
    INSTALL(FILES ${_dependIcon}
	DESTINATION ${ICON_INSTALL_DIRECTORY})
ENDMACRO(CONVERT_DB targetName)

ADD_SUBDIRECTORY(array)
ADD_SUBDIRECTORY(cangjie)
ADD_SUBDIRECTORY(cantonese)
ADD_SUBDIRECTORY(easy)
ADD_SUBDIRECTORY(erbi)
ADD_SUBDIRECTORY(quick)
ADD_SUBDIRECTORY(scj)
ADD_SUBDIRECTORY(stroke5)
ADD_SUBDIRECTORY(wu)
ADD_SUBDIRECTORY(wubi-haifeng)
ADD_SUBDIRECTORY(wubi-jidian)
ADD_SUBDIRECTORY(yong)

#CONVERT_DB(yong "yong/yong.txt")


