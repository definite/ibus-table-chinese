cmake_minimum_required(VERSION 2.6.2)

# Included scripts do automatic cmake_policy PUSH and POP.
# OLD: CMake policy in included script will affect the invoker.
# CMAKE_POLICY(SET CMP0011 OLD)

# Default CMAKE_INSTALL_PREFIX should be set before PROJECT()
SET(CMAKE_INSTALL_PREFIX "/usr" CACHE PATH "Install dir prefix")

# Whether to build on fedora
SET(CMAKE_FEDORA_ENABLE_FEDORA_BUILD "1" CACHE STRING "Enable fedora build")

# Message level INFO1 (5)
SET(MANAGE_MESSAGE_LEVEL 5 CACHE STRING "Message (Verbose) Level")

####################################################################
# Project specific information
#
PROJECT(ibus-table-chinese NONE)
SET(PRJ_SUMMARY "Chinese input tables for IBus")

SET(SUMMARY_TRANSLATIONS
    "zh_CN" "中文码表输入法"
    "zh_TW" "中文碼表輸入法"
    )

SET(PRJ_DESCRIPTION
"ibus-table-chinese is provides the infrastructure for Chinese input methods.
Input tables themselves are in subpackages."
    )

SET(DESCRIPTION_TRANSLATIONS
    "zh_TW" "ibus-table-chinese 提供了中文碼表輸入法的基礎架構。
    輸入法本身則在子套件裡。"
    )

SET(AUTHORS "Yuwei Yu, Caius 'kaio' Chance, Ding-Yi Chen")
SET(MAINTAINER "Ding-Yi Chen <dchen@redhat.com>")
SET(VENDOR "Red Hat, Inc")
SET(LICENSE "GPLv3+")
SET(PRJ_GROUP "System Environment/Libraries")
SET(BUILD_ARCH "noarch")
SET(RPM_SPEC_URL "http://code.google.com/p/ibus/")
SET(RPM_SPEC_SOURCES "https://fedorahosted.org/releases/c/m/%{name}/%{name}-%{version}-Source.tar.gz")

####################################################################
# Includes
#
LIST(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_SOURCE_DIR}/Modules)

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
INCLUDE(ManageArchive)
INCLUDE(ManageFile)
INCLUDE(ManageSourceVersionControl)
INCLUDE(ManageTarget)
INCLUDE(ManageTranslation)
INCLUDE(ManageUninstall)
ENABLE_TESTING()

####################################################################
# Dependencies
#

INCLUDE(ManageDependency)
## Requires
MANAGE_DEPENDENCY(REQUIRES IBUS-TABLE VER "1.2.0" REQUIRED)

## Build Requires
MANAGE_DEPENDENCY(BUILD_REQUIRES CMAKE VER "2.6.2" REQUIRED)
MANAGE_DEPENDENCY(BUILD_REQUIRES IBUS-TABLE VER "1.2.0" REQUIRED DEVEL)
PRJ_INFO_CMAKE_APPEND(${PRJ_INFO_CMAKE} REQUIRES)
PRJ_INFO_CMAKE_APPEND(${PRJ_INFO_CMAKE} BUILD_REQUIRES)

####################################################################
# Building
#
ADD_SUBDIRECTORY(tables)

####################################################################
# Installing
#

MANAGE_SOURCE_VERSION_CONTROL_GIT()

INSTALL(FILES AUTHORS README ChangeLog COPYING DESTINATION ${PRJ_DOC_DIR})

####################################################################
# Packing
#

## Pack Source 
SET(SOURCE_ARCHIVE_DIR ${CMAKE_BINARY_DIR}/SOURCES CACHE PATH "Source Archive Dir")
PACK_SOURCE_ARCHIVE("${SOURCE_ARCHIVE_DIR}"
    GITIGNORE ${CMAKE_SOURCE_DIR}/.gitignore
    )

## Pack RPM
IF(CMAKE_FEDORA_ENABLE_FEDORA_BUILD)
    SET(RPM_BUILD_SOURCES ${SOURCE_ARCHIVE_DIR})
    INCLUDE(ManageRPM)
    PACK_RPM(SPEC_IN "SPECS/project.spec.in")
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

INCLUDE(ManageRelease)
IF(CMAKE_FEDORA_ENABLE_FEDORA_BUILD)
    INCLUDE(ManageReleaseFedora)
    RELEASE_FEDORA(fedora el6)
    # "Off" Warning is displayed if mock is not installed.
    MANAGE_RELEASE(tag_push release_fedora)
ELSE(CMAKE_FEDORA_ENABLE_FEDORA_BUILD)
    MANAGE_RELEASE(tag_push)
ENDIF(CMAKE_FEDORA_ENABLE_FEDORA_BUILD)


####################################################################
# Test Suites.
#
#ADD_TEST("Test" test_cmd1)


