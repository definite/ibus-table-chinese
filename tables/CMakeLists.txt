FIND_PROGRAM(CREATE_DB ibus-table-createdb)
IF (CREATE_DB STREQUAL "CREATE_DB-NOTFOUND")
    MESSAGE(FATAL_ERROR "ibus-table-createdb is not installed")
ENDIF(CREATE_DB STREQUAL "CREATE_DB-NOTFOUND")

IF(NOT DEFINED DB_INSTALL_DIRECTORY)
    SET(DB_INSTALL_DIRECTORY "${DATA_DIR}/ibus-table/tables")
ENDIF(NOT DEFINED DB_INSTALL_DIRECTORY)

IF(NOT DEFINED ICON_INSTALL_DIRECTORY)
    SET(ICON_INSTALL_DIRECTORY "${DATA_DIR}/ibus-table/icons")
ENDIF(NOT DEFINED ICON_INSTALL_DIRECTORY)

ADD_CUSTOM_TARGET(convert_all ALL)


MACRO(CONVERT_DB targetName pattern)
    FILE(GLOB_RECURSE _tableList RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${pattern}.txt")
    FOREACH(_arg ${ARGN})
	FILE(GLOB_RECURSE _tableAppend RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${_arg}.txt")
	LIST(APPEND _tableList ${_tableAppend})
    ENDFOREACH(_arg ${ARGN})

    # CMakeLists.txt is not a table.
    LIST(REMOVE_ITEM _tableList "CMakeLists.txt")
    SET(_dependDb "")
    SET(_dependIcon "")
    FOREACH(_tabFile ${_tableList})
	GET_FILENAME_COMPONENT(_tabName "${_tabFile}" NAME_WE)
	ADD_CUSTOM_COMMAND(OUTPUT ${_tabName}.db
	    COMMAND ${CREATE_DB} -n ${_tabName}.db -s ${_tabFile}
	    COMMENT "Building ${_tabName} table..."
	    )
	LIST(APPEND _dependDb "${_tabName}.db")
	IF(EXISTS "../icons/${_tabName}.png")
	    LIST(APPEND _dependIcon "../icons/${_tabName}.png")
	ELSEIF(EXISTS "../icons/${_tabName}.svg")
	    LIST(APPEND _dependIcon "../icons/${_tabName}.svg")
	ELSEIF(EXISTS "../icons/${_tabName}.gif")
	    LIST(APPEND _dependIcon "../icons/${_tabName}.gif")
	ELSEIF(EXISTS "../icons/${_tabName}.jpg")
	    LIST(APPEND _dependIcon "../icons/${_tabName}.jpg")
	ENDIF(EXISTS "../icons/${_tabName}.png")
    ENDFOREACH(_tabFile ${_tableList})

    ADD_CUSTOM_TARGET(convert_${targetName}
	COMMENT "Building ${targetName} table..."
	DEPENDS ${_dependDb}
	)

    ADD_CUSTOM_TARGET(install_${targetName}
	COMMAND cmake -E copy ${_dependDb} ${DB_INSTALL_DIRECTORY}
	COMMAND cmake -E copy ${_dependIcon} ${ICON_INSTALL_DIRECTORY}
	COMMENT "Install ${targetName} table and icons"
	DEPENDS ${_dependDb}
	)

    ADD_DEPENDENCIES(convert_all convert_${targetName})

    INSTALL(FILES ${_dependDb}
	DESTINATION ${DB_INSTALL_DIRECTORY})
    INSTALL(FILES ${_dependIcon}
	DESTINATION ${ICON_INSTALL_DIRECTORY})
ENDMACRO(CONVERT_DB dbs targetName pattern)


CONVERT_DB(cangjie "cangjie*" "quick*" "scj*")
CONVERT_DB(canton "canton*" "jyutping*")
CONVERT_DB(easy "easy*")
CONVERT_DB(erbi "erbi*")
CONVERT_DB(stroke5 "stroke5")
CONVERT_DB(wu "wu")
CONVERT_DB(wubi "wubi*")
CONVERT_DB(xinhua "xinhua*")
CONVERT_DB(yong "yong*")
CONVERT_DB(zhengma "zhengma*")
CONVERT_DB(ziranma "ziranma*")


