# vim:set ts=4
#
# ibus-table-chinese - Chinese tables for IBus-Table
#
# Copyright (c) 2008 Yu Yuwei <acevery at gmail.com>, Caius 'kaio' Chance <me at kaio.net>
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
#
# $Id: $
#

createdb = \
	$(IBUS_TABLE_CREATEDB) 

if IBUS_TABLE_EXTRA_PHRASES
createdb += -e @IBUS_TABLE_EXTRAPHRASE@
endif

tables_DATA =

if IBUS_TABLE_BUILD_CANGJIE3
tables_DATA += cangjie3.db
endif

if IBUS_TABLE_BUILD_CANGJIE5
tables_DATA += cangjie5.db
endif

if IBUS_TABLE_BUILD_CANGJIEBIG
tables_DATA += cangjie-big.db
endif

if IBUS_TABLE_BUILD_SCJ6
tables_DATA += scj6.db
endif

if IBUS_TABLE_BUILD_QUICK3
tables_DATA += quick3.db
endif

if IBUS_TABLE_BUILD_QUICK5
tables_DATA += quick5.db
endif

if IBUS_TABLE_BUILD_QUICKCLASSIC
tables_DATA += quick-classic.db
endif

if IBUS_TABLE_BUILD_EASYBIG
tables_DATA += easy-big.db
endif

if IBUS_TABLE_BUILD_CANTONESE
tables_DATA += cantonese.db
tables_DATA += cantonhk.db
tables_DATA += jyutping.db
endif

if IBUS_TABLE_BUILD_STROKE5
tables_DATA += stroke5.db
endif

if IBUS_TABLE_BUILD_WUBI86
tables_DATA += wubi86.db
endif

if IBUS_TABLE_BUILD_XINHUA
tables_DATA += xinhua-ibus.db
endif

if IBUS_TABLE_BUILD_ZHENGMA
tables_DATA += zhengma.db
endif

if IBUS_TABLE_BUILD_ERBI
tables_DATA += erbi.db
endif

if IBUS_TABLE_BUILD_ERBIQS
tables_DATA += erbi_qs.db
endif

if IBUS_TABLE_BUILD_WU
tables_DATA += wu.db
endif

if IBUS_TABLE_BUILD_YONG
tables_DATA += yong-ibus.db
endif

if IBUS_TABLE_BUILD_ZHUYIN
tables_DATA += zhuyin.db
endif

if IBUS_TABLE_BUILD_ZHUYINBIG
tables_DATA += zhuyin-big.db
endif

if IBUS_TABLE_BUILD_ZIRANMA
tables_DATA += ziranma.db
endif

tables_DATA += $(NULL)

tablesdir = $(datadir)/ibus-table/tables

EXTRA_DIST = \
	cangjie3.txt \
	cangjie5.txt \
	cangjie-big.txt \
	scj6.txt \
	quick3.txt \
	quick5.txt \
	quick-classic.txt \
	easy-big.txt \
        cantonese.txt \
        cantonhk.txt \
        jyutping.txt \
	stroke5.txt \
	wubi86.txt \
	xinhua-ibus.txt \
	zhengma.txt \
        erbi.txt \
        erbi_qs.txt \
        wu.txt \
        yong-ibus.txt \
        zhuyin.txt \
        zhuyin-big.txt \
        ziranma.txt \
	$(NULL)

DISTCLEANFILES = \
	*.db \
	$(NULL)

.txt.db:
	$(createdb) -n $@ -s $<

