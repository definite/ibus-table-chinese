cmake_minimum_required(VERSION 2.6)
# CMP0011 should be set here, otherwise policy set in module won't affect
# here.
CMAKE_POLICY(SET CMP0011 OLD)

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
INCLUDE(ManageEnvironment RESULT_VARIABLE MANAGE_ENVIRONMENT_PATH)
IF(MANAGE_ENVIRONMENT_PATH STREQUAL "NOTFOUND")
    MESSAGE(FATAL_ERROR "ManageEnvironment is not found in $CMAKE_MODULE_PATH,
    please:
    1) install cmake-fedora, or;
    2) wget -P SOURCES https://fedorahosted.org/releases/c/m/cmake-fedora/cmake-fedora-modules-only-latest.tar.gz
    tar zxvf SOURCES/cmake-fedora-modules-only-latest.tar.gz")
ENDIF(MANAGE_ENVIRONMENT_PATH STREQUAL "NOTFOUND")

INCLUDE(ManageVersion)
LOAD_RELEASE_FILE("${CMAKE_SOURCE_DIR}/RELEASE-NOTES.txt")
INCLUDE(UseUninstall)

####################################################################
# Required
#
FIND_PACKAGE(PkgConfig)
PKG_CHECK_MODULES(IBUS_TABLE REQUIRED ibus-table>=1.2)
SET(CMAKE_FEDORA_VER 0.7.994)

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
# Set to "True" to build against updates-candidate if possible.

SET(FEDORA_CANDIDATE_PREFERRED 1 CACHE BOOL FEDORA_CANDIDATE_PREFERRED)

# Set to "True" to build against testing-candidate if possible.
SET(EPEL_CANDIDATE_PREFERRED 1 CACHE BOOL EPEL_CANDIDATE_PREFERRED)
RELEASE_ON_FEDORA("${RPM_BUILD_SRPMS}/${PRJ_SRPM_FILE_NAME}"
    TAGS ${FEDORA_CURRENT_RELEASE_TAGS} el6)

####################################################################
# Stand-alone package (cmake-fedora modules included)
#

SET(CMAKE_FEDORA_MODULE_ONLY_TARBALL
    cmake-fedora-${CMAKE_FEDORA_VER}-modules-only.tar.gz)
SET(CMAKE_FEDORA_MODULE_ONLY_TARBALL_FULL
    ${RPM_BUILD_SOURCES}/${CMAKE_FEDORA_MODULE_ONLY_TARBALL})

SET(PACK_SOURCE_STANDALONE ${PROJECT_NAME}-${PRJ_VER}-Source-Standalone)

SET(PACK_SOURCE_STANDALONE_FULL ${RPM_BUILD_SOURCES}/${PACK_SOURCE_STANDALONE}.${PACK_SOURCE_FILE_EXTENSION})

IF(EXISTS ${CMAKE_FEDORA_MODULE_ONLY_TARBALL_FULL})
    SET(_tmpDir "NO_PACK")
    SET(_project_tarball_we ${PROJECT_NAME}-${PRJ_VER}-Source)
    SET(_tmpProjDir ${_tmpDir}/${_project_tarball_we})
    ADD_CUSTOM_COMMAND(OUTPUT ${PACK_SOURCE_STANDALONE_FULL}
	COMMAND ${CMAKE_COMMAND} -E make_directory ${_tmpDir}
	COMMAND tar -C ${_tmpDir} -xzf ${RPM_BUILD_SOURCES}/${PACK_SOURCE_FILE_NAME}
	COMMAND tar -C ${_tmpProjDir} -xzf ${CMAKE_FEDORA_MODULE_ONLY_TARBALL_FULL}
	COMMAND tar -C ${_tmpDir} -czf ${PACK_SOURCE_STANDALONE_FULL} ${_project_tarball_we}
	COMMAND ${CMAKE_COMMAND} -E remove_directory ${_tmpDir}
	DEPENDS ${RPM_BUILD_SOURCES}/${PACK_SOURCE_FILE_NAME}
            ${CMAKE_FEDORA_MODULE_ONLY_TARBALL_FULL}
	VERBATIM
	)

    ADD_CUSTOM_TARGET(pack_src_standalone
	DEPENDS ${PACK_SOURCE_STANDALONE_FULL}
	)

    MANAGE_MAINTAINER_TARGETS_UPLOAD(
	${PACK_SOURCE_STANDALONE_FULL}
	FILE_ALIAS standalone )
ENDIF(EXISTS ${CMAKE_FEDORA_MODULE_ONLY_TARBALL_FULL})

####################################################################
# Test Suites.
#
#ENABLE_TESTING()
#ADD_TEST("Test" test_cmd1)


