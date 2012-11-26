cmake_minimum_required(VERSION 2.6.2)

# CMP0011 should be set here, otherwise policy set in module won't affect
# here.
CMAKE_POLICY(SET CMP0011 OLD)

# Default CMAKE_INSTALL_PREFIX should be set before PROJECT()
SET(CMAKE_INSTALL_PREFIX "/usr" CACHE PATH "Install dir prefix")

# Whether to build on fedora
SET(CMAKE_FEDORA_ENABLE_FEDORA_BUILD "0" CACHE STRING "Enable fedora build")

# Message level M_OFF (4)
SET(MANAGE_MESSAGE_LEVEL 4 CACHE STRING "Message (Verbose) Level")

# Default support Gnome shell
SET(GNOME_SHELL 1)

####################################################################
# Project specific information
#
PROJECT(ibus-table-chinese NONE)
SET(PRJ_SUMMARY "Chinese input tables for IBus")

SET(PRJ_DESCRIPTION
"ibus-table-chinese is provides the infrastructure for Chinese input methods.
Input tables themselves are in subpackages."
    )

SET(AUTHORS "Yuwei Yu, Caius 'kaio' Chance, Ding-Yi Chen")
SET(MAINTAINER "Ding-Yi Chen <dchen@redhat.com>")
SET(VENDOR "Red Hat, Inc")
SET(LICENSE "GPLv3+")

####################################################################
# Includes
#
SET(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/Modules ${CMAKE_ROOT}/Modules )

# Create a link if Modules/ does not exists
IF(EXISTS ${CMAKE_SOURCE_DIR}/cmake-fedora/Modules)
    IF(NOT EXISTS ${CMAKE_SOURCE_DIR}/Modules)
	EXECUTE_PROCESS(COMMAND ln -s ${CMAKE_SOURCE_DIR}/cmake-fedora/Modules .)
    ENDIF(NOT EXISTS ${CMAKE_SOURCE_DIR}/Modules)
ENDIF(EXISTS ${CMAKE_SOURCE_DIR}/cmake-fedora/Modules)

# Use standard FHS if Fedora build is not enabled
IF(NOT CMAKE_FEDORA_ENABLE_FEDORA_BUILD)
    IF(CMAKE_SYSTEM_PROCESSOR MATCHES "64")
	SET(LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib64" CACHE PATH "Library dir")
    ELSE(CMAKE_SYSTEM_PROCESSOR MATCHES "64")
	SET(LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib" CACHE PATH "Library dir")
    ENDIF(CMAKE_SYSTEM_PROCESSOR MATCHES "64")
    SET(LIBEXEC_DIR "${LIB_DIR}" CACHE PATH "LIBEXEC dir")
    MESSAGE("*Hi")
ENDIF(NOT CMAKE_FEDORA_ENABLE_FEDORA_BUILD)

INCLUDE(ManageEnvironment RESULT_VARIABLE MANAGE_ENVIRONMENT_PATH)
IF(MANAGE_ENVIRONMENT_PATH STREQUAL "NOTFOUND")
    MESSAGE(FATAL_ERROR "ManageEnvironment is not found in CMAKE_MODULE_PATH,
    please:
    1) git submodule init; git submodule update
    2) or install cmake-fedora/
    3) wget -P SOURCES https://fedorahosted.org/releases/c/m/cmake-fedora/cmake-fedora-modules-only-latest.tar.gz
    tar zxvf SOURCES/cmake-fedora-modules-only-latest.tar.gz")
ENDIF(MANAGE_ENVIRONMENT_PATH STREQUAL "NOTFOUND")

INCLUDE(ManageVersion)
RELEASE_NOTES_READ_FILE()
INCLUDE(ManageUninstall)

####################################################################
# Required
#

FIND_PACKAGE(PkgConfig)
PKG_CHECK_MODULES(IBUS_TABLE REQUIRED ibus-table>=1.2)

####################################################################
# Building
#

ADD_SUBDIRECTORY(tables)

####################################################################
# Installing
#

# Install docs
# Note: Need to use filename only, otherwise
# ${CMAKE_SOURCE_DIR}/RELEASE-NOTES.txt will be deleted in spec
#

GET_FILENAME_COMPONENT(_releaseFileName "${RELEASE_FILE}" NAME)
SET(INSTALL_DOCS ${_releaseFileName} AUTHORS README ChangeLog COPYING README)
STRING_JOIN(PRJ_DOC_LIST " " ${INSTALL_DOCS})

INSTALL(FILES ${INSTALL_DOCS}
    DESTINATION "${PRJ_DOC_DIR}")

####################################################################
# Source Version Control
#
INCLUDE(ManageSourceVersionControl)
MANAGE_SOURCE_VERSION_CONTROL_GIT()

####################################################################
# Packing
#
INCLUDE(ManageArchive)

IF(CMAKE_FEDORA_ENABLE_FEDORA_BUILD)
    INCLUDE(ManageRPM)
    INCLUDE(ManageReleaseFedora)
ENDIF(CMAKE_FEDORA_ENABLE_FEDORA_BUILD)
INCLUDE(ManageRelease)

SET(PRJ_IGNORE_FILES_COMMON
    "/doc/"  "\\\\.spec$" "messages.po$" "\\\\.orig$" "/cmake-fedora/"
    "/\\\\.cache/"
    "\\\\.db$"
    )

LIST(APPEND PRJ_IGNORE_FILES_COMMON
    "\\\\.utf8$" "\\\\.tmp$" "\\\\.freq$" "\\\\.tab$"
    "tables/array/.*\\\\.head$"
    "array30.txt" "array30-big.txt" "wubi-haifeng86.txt"
    )

LIST(APPEND SOURCE_ARCHIVE_IGNORE_FILES
    ${PRJ_IGNORE_FILES_COMMON} "/bin/" "\\\\.xml$" "\\\\.schemas")

IF(RPM_BUILD_SOURCES)
    SET(SOURCE_ARCHIVE_DIR ${RPM_BUILD_SOURCES})
ELSE(RPM_BUILD_SOURCES)
    SET(SOURCE_ARCHIVE_DIR ${CMAKE_BINARY_DIR}/SOURCES)
ENDIF(RPM_BUILD_SOURCES)

PACK_SOURCE_ARCHIVE("${SOURCE_ARCHIVE_DIR}")
IF(CMAKE_FEDORA_ENABLE_FEDORA_BUILD)
    PACK_RPM()
    RELEASE_FEDORA(fedora el6)
    # "Off" Warning is displayed if mock is not installed.
    RPM_MOCK_BUILD()
    MANAGE_RELEASE(release_fedora)
ENDIF(CMAKE_FEDORA_ENABLE_FEDORA_BUILD)

####################################################################
# Hosting and Release
#
# Set to "True" to build against updates-candidate if possible.

#INCLUDE(ManageUpload)
#ADD_CUSTOM_TARGET(upload
#    COMMENT "Uploading all files"
#    )

#MANAGE_UPLOAD_CMD(scp src UPLOAD_FILES ${SOURCE_ARCHIVE_FILE})
#ADD_DEPENDENCIES(upload upload_src)

####################################################################
# Test Suites.
#
#ENABLE_TESTING()
#ADD_TEST("Test" test_cmd1)


