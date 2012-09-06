# wubi-haifeng
# It takes very long to generate the table from scratch
#ADD_CUSTOM_COMMAND(OUTPUT wubi-haifeng86.UTF-8
#    COMMAND convertTable.sh
#    COMMENT "Building wubi-haifeng86.UTF-8"
#    )

MAKE_TABLE_SOURCE_TXT(wubi-haifeng86.txt wubi-haifeng86.head wubi-haifeng86.UTF-8 wubi-haifeng86.tail)
CONVERT_DB(wubi-haifeng "wubi-haifeng86.txt")

