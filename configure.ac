# vim:set ts=4
#
# ibus-table-cangjie - The Cang Jie and derived tables for IBus-Table
#
# Copyright (c) 2008-2010 Yu Yuwei <acevery@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

# if not 1, append datestamp to the version number.
m4_define([package_name], [ibus-table-cangjie])
m4_define([ibus_released], [0])
m4_define([ibus_major_version], [1])
m4_define([ibus_minor_version], [2])
m4_define([ibus_micro_version], [0])
m4_define(ibus_maybe_datestamp,
    m4_esyscmd([if test x]ibus_released[ != x1; then date +.%Y%m%d | tr -d '\n\r'; fi]))

m4_define([ibus_version],
    ibus_major_version.ibus_minor_version.ibus_micro_version[]ibus_maybe_datestamp)

AC_INIT([package_name], [ibus_version], [http://code.google.com/p/ibus/issues/entry], [package_name])
AM_INIT_AUTOMAKE([1.10])
AM_MAINTAINER_MODE

# AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])

# check python
#AM_PATH_PYTHON([2.5])

# check for ibus-table-createdb
PKG_CHECK_MODULES([IBUS_TABLE], [ibus-table >= 1.2.0])
AC_ARG_VAR([IBUS_TABLE_CREATEDB],[[ibus-table-createdb, which generate db]])

AC_PATH_PROG([IBUS_TABLE_CREATEDB],[ibus-table-createdb],
        [AC_MSG_ERROR([ibus-table-createdb not found.])])

# choose table
AC_ARG_ENABLE([cangjie3],
    [AC_HELP_STRING([--enable-cangjie3],
        [Generate CangJie3 Engine])], ,
    [enable_cangjie3=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_CANGJIE3],[test x"$enable_cangjie3" != x"no"])

AC_ARG_ENABLE([cangjie5],
    [AC_HELP_STRING([--enable-cangjie5],
        [Generate CangJie5 Engine])], ,
    [enable_cangjie5=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_CANGJIE5],[test x"$enable_cangjie5" != x"no"])

AC_ARG_ENABLE([cangjiebig],
    [AC_HELP_STRING([--enable-cangjiebig],
        [Generate CangJie \(big\) Engine])], ,
    [enable_cangjiebig=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_CANGJIEBIG],[test x"$enable_cangjiebig" != x"no"])

AC_ARG_ENABLE([scj6],
    [AC_HELP_STRING([--enable-scj6],
        [Speed CangJie 6 Engine])], ,
    [enable_scj6=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_SCJ6],[test x"$enable_scj6" != x"no"])

AC_ARG_ENABLE([quick3],
    [AC_HELP_STRING([--enable-quick3],
        [Generate Quick3 Engine])], ,
    [enable_quick3=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_QUICK3],[test x"$enable_quick3" != x"no"])

AC_ARG_ENABLE([quick5],
    [AC_HELP_STRING([--enable-quick5],
        [Generate Quick5 Engine])], ,
    [enable_quick5=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_QUICK5],[test x"$enable_quick5" != x"no"])

AC_ARG_ENABLE([quickclassic],
    [AC_HELP_STRING([--enable-quickclassic],
        [Generate Quick Classic Engine])], ,
    [enable_quickclassic=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_QUICKCLASSIC],[test x"$enable_quickclassic" != x"no"])

AC_ARG_ENABLE([easybig],
    [AC_HELP_STRING([--enable-easybig],
        [Generate Easy \(big\) Engine])], ,
    [enable_easybig=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_EASYBIG],[test x"$enable_easybig" != x"no"])

# OUTPUT files
AC_CONFIG_FILES(Makefile
icons/Makefile
tables/Makefile
m4/Makefile
ibus-table-cangjie.spec
)

AC_OUTPUT

AC_MSG_RESULT([
Build options:
  Version                   $VERSION
  Install prefix            $prefix
  Build CangJie3            $enable_cangjie3
  Build CangJie5            $enable_cangjie5
  Build CangJie (big)       $enable_cangjiebig
  Build Speed CangJie 6     $enable_scj6
  Build Quick3              $enable_quick3
  Build Quick5              $enable_quick5
  Build Quick Classic       $enable_quickclassic
  Build Easy (big)          $enable_easybig
])

