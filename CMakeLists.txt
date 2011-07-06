cmake_minimum_required(VERSION 2.6)
SET(CMAKE_INSTALL_PREFIX "/usr" CACHE PATH "Install path prefix")
#CMAKE_POLICY(VERSION 2.4)
#CMAKE_POLICY(SET CMP0005 OLD)
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
MESSAGE("CMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}")

INCLUDE(ManageVariable RESULT_VARIABLE MANAGE_VARIABLE)
IF(MANAGE_VARIABLE STREQUAL "NOTFOUND")
    MESSAGE(FATAL_ERROR "ManageVariable is not found in CMAKE_MODULE_PATH,
    please:
    1) install cmake-fedora, or;
    2) wget https://fedorahosted.org/releases/c/m/cmake-fedora/cmake-fedora-modules-only-latest.tar.gz; tar zxvf cmake-fedora-modules-only-latest.tar.gz")
ENDIF()

IF(CMAKE_VERSION)
    CMAKE_POLICY(SET CMP0005 OLD)
ENDIF(CMAKE_VERSION)

INCLUDE(ManageVersion)
LOAD_RELEASE_FILE("${CMAKE_SOURCE_DIR}/RELEASE-NOTES.txt")
INCLUDE(UseUninstall)

INCLUDE(CompileEnv)
SET_USUAL_COMPILE_ENVS()

INCLUDE(CMakeVersion)


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
# Packing
#
SET(MAINTAINER_SETTING "MAINTAINER_SETTING_NO_PACK")
INCLUDE(PackSource)
INCLUDE(PackRPM)
INCLUDE(ManageRelease)
INCLUDE(ManageReleaseOnFedora)

SET(PRJ_IGNORE_FILES_COMMON
    "\\\\.spec$" "messages.po$" "\\\\.orig$" "\\\\.db$"
    "/\\\\.cache/" "/Modules/"
    )

LIST(APPEND PRJ_IGNORE_FILES_COMMON
    "\\\\.utf8$" "\\\\.tmp$"
    "array30.txt" "array30-big.txt" "wubi-haifeng86.txt"
    )

LIST(APPEND PACK_SOURCE_IGNORE_FILES
    ${PRJ_IGNORE_FILES_COMMON} "/bin/")

PACK_SOURCE(PACK_SOURCE_FILE_NAME "${RPM_BUILD_SOURCES}")
PACK_RPM(PRJ_SRPM_FILE_NAME "${RPM_BUILD_SPECS}/project.spec.in"
    "${PACK_SOURCE_FILE_NAME}")

# "Off" Warning is displayed if mock is not installed.
USE_MOCK("${RPM_BUILD_SPECS}/project.spec.in")

####################################################################
# Hosting and Release
#

# "Off" Warning is displayed if ${MAINTAINER_SETTING} does not exist.
MANAGE_RELEASE(${MAINTAINER_SETTING} UPLOAD src ${RPM_BUILD_SOURCES}/${PACK_SOURCE_FILE_NAME})
RELEASE_ON_FEDORA("${RPM_BUILD_SRPMS}/${PRJ_SRPM_FILE_NAME}"
    TAGS ${FEDORA_CURRENT_RELEASE_TAGS} ${FEDORA_EPEL_RELEASE_TAGS})


####################################################################
# Test Suites.
#
#ENABLE_TESTING()
#ADD_TEST("Test" test_cmd1)


