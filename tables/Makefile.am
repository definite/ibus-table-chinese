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
#
# $Id: $
#

createdb = \
	$(IBUS_TABLE_CREATEDB) 

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
	$(NULL)

DISTCLEANFILES = \
	*.db \
	$(NULL)

.txt.db:
	$(createdb) -n $@ -s $<

