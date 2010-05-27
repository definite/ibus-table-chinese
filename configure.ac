# vim:set ts=4
#
# ibus-table-chinese - Chinese tables for IBus-Table
#
# Copyright (c) 2008 Yu Yuwei <acevery at gmail.com>, Caius 'kaio' Chance <me at kaio.net>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
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
m4_define([package_name], [ibus-table-chinese])
m4_define([ibus_released], [0])
m4_define([ibus_major_version], [1])
m4_define([ibus_minor_version], [3])
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

AC_ARG_ENABLE([cantonese],
    [AC_HELP_STRING([--enable-cantonese],
        [Generate Cantonese Engine])], ,
    [enable_cantonese=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_CANTONESE],[test x"$enable_cantonese" != x"no"])

AC_ARG_ENABLE([cantonhk],
    [AC_HELP_STRING([--enable-cantonhk],
        [Generate Cantonese HK Engine])], ,
    [enable_cantonhk=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_CANTONHK],[test x"$enable_cantonhk" != x"no"])

AC_ARG_ENABLE([jyutping],
    [AC_HELP_STRING([--enable-jyutping],
        [Generate Jyut Ping Engine])], ,
    [enable_jyutping=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_JYUTPING],[test x"$enable_jyutping" != x"no"])

AC_ARG_ENABLE([stroke5],
    [AC_HELP_STRING([--enable-stroke5],
        [Generate Stroke5 Engine])], ,
    [enable_stroke5=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_STROKE5],[test x"$enable_stroke5" != x"no"])

AC_ARG_ENABLE([wubi86],
    [AC_HELP_STRING([--enable-wubi86],
        [Generate WuBi86 Engine])], ,
    [enable_wubi86=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_WUBI86],[test x"$enable_wubi86" != x"no"])

AC_ARG_ENABLE([xinhua],
    [AC_HELP_STRING([--enable-xinhua],
        [Generate XinHua Engine])], ,
    [enable_xinhua=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_XINHUA],[test x"$enable_xinhua" != x"no"])

AC_ARG_ENABLE([zhengma],
    [AC_HELP_STRING([--enable-zhengma],
        [Generate ZhengMa Engine])], ,
    [enable_zhengma=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_ZHENGMA],[test x"$enable_zhengma" != x"no"])

AC_ARG_ENABLE([erbi],
    [AC_HELP_STRING([--enable-erbi],
        [Generate ErBi Engine])], ,
    [enable_erbi=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_ERBI],[test x"$enable_erbi" != x"no"])

AC_ARG_ENABLE([erbiqs],
    [AC_HELP_STRING([--enable-erbiqs],
        [Generate ErBi QS Engine])], ,
    [enable_erbiqs=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_ERBIQS],[test x"$enable_erbiqs" != x"no"])

AC_ARG_ENABLE([wu],
    [AC_HELP_STRING([--enable-wu],
        [Generate Wu Engine])], ,
    [enable_wu=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_WU],[test x"$enable_wu" != x"no"])

AC_ARG_ENABLE([yong],
    [AC_HELP_STRING([--enable-yong],
        [Generate Yong Engine])], ,
    [enable_yong=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_YONG],[test x"$enable_yong" != x"no"])

AC_ARG_ENABLE([zhuyin],
    [AC_HELP_STRING([--enable-zhuyin],
        [Generate ZhuYin Engine])], ,
    [enable_zhuyin=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_ZHUYIN],[test x"$enable_zhuyin" != x"no"])

AC_ARG_ENABLE([zhuyinbig],
    [AC_HELP_STRING([--enable-zhuyinbig],
        [Generate ZhuYin (big) Engine])], ,
    [enable_zhuyinbig=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_ZHUYINBIG],[test x"$enable_zhuyinbig" != x"no"])

AC_ARG_ENABLE([ziranma],
    [AC_HELP_STRING([--enable-ziranma],
        [Generate ZiRanMa Engine])], ,
    [enable_ziranma=yes])

AM_CONDITIONAL([IBUS_TABLE_BUILD_ZIRANMA],[test x"$enable_ziranma" != x"no"])

# the option for extra phrases
AC_ARG_ENABLE([extra-phrases],
    [AC_HELP_STRING([--enable-extra-phrases],
        [Add extra phrases into built Engine])], ,
    [enable_extra_phrases=no])

AM_CONDITIONAL([IBUS_TABLE_EXTRA_PHRASES],[test x"$enable_extra_phrases" == x"yes"])

# check for ibus-table-extraphrase, if we need it.
if test x"$enable_extra_phrases" == x"yes"; then
    PKG_CHECK_MODULES([EXTRA_PHRASE],[ibus-table-extraphrase >= 1.1.0])
    IBUS_TABLE_EXTRAPHRASE=`$PKG_CONFIG --variable=extraphrasepath ibus-table-extraphrase`
    AC_SUBST(IBUS_TABLE_EXTRAPHRASE)
fi

# OUTPUT files
#ibus-table-chinese.spec
AC_CONFIG_FILES(
Makefile
icons/Makefile
tables/Makefile
m4/Makefile
)

AC_OUTPUT

AC_MSG_RESULT([
Build options:
  Version                   $VERSION
  Install prefix            $prefix

Build tables:
  Build Cang Jie 3          $enable_cangjie3
  Build Cang Jie 5          $enable_cangjie5
  Build Cang Jie Big        $enable_cangjiebig
  Build Cantonese           $enable_cantonese
  Build Cantonese HK        $enable_cantonhk
  Build Easy Big            $enable_easybig
  Build Er Bi               $enable_erbi
  Build Er Bi QS            $enable_erbiqs
  Build JyutPing            $enable_jyutping
  Build Quick 3             $enable_quick3
  Build Quick 5             $enable_quick5
  Build Quick Classic       $enable_quickclassic
  Build Speed Cang Jie 6    $enable_scj6
  Build Stroke 5            $enable_stroke5
  Build Wu                  $enable_wu
  Build Wu Bi 86            $enable_wubi86
  Build Xin Hua             $enable_xinhua
  Build Yong                $enable_yong
  Build ZhengMa             $enable_zhengma
  Build Zhu Yin             $enable_zhuyin
  Build Zhu Yin Big         $enable_zhuyinbig
  Build ZiRanMa             $enable_ziranma

Extra phrases table:
  Integrate Extra Phrases   $enable_extra_phrases
])

