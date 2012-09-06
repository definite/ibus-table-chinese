# Array30
SET(UUID "fe1125da-3bff-47b8-9aa7-d7586633ae4a")
SET(ICON_FILE "array30.png")
SET(TABLE_NAME_EN "Array30")
SET(TABLE_NAME_ZH "行列30")
SET(DESC "Array 30 Chinese input method.")
CONFIGURE_FILE(array30.head.in array30.head @ONLY)

CONVERT_ENCODING(array30_27489.utf8 UTF16 array30_27489.txt)
GENERATE_FREQ(array30_27489.freq array30_27489.utf8)
MAKE_TABLE_SOURCE_TXT(array30.txt array30.head array30_27489.freq array30.tail)

# Array30-big
SET(UUID "3c28e5f1-0885-486e-8d15-b13680b9a44c")
SET(ICON_FILE "array30-big.png")
SET(TABLE_NAME_EN "Array30BigTable")
SET(TABLE_NAME_ZH "行列30大字集")
SET(DESC "Array 30 Chinese input method that include unicode Ext B.")
CONFIGURE_FILE(array30.head.in array30-big.head @ONLY)

CONVERT_ENCODING(array30_ExtB.utf8 UTF16 array30_ExtB.txt)

ADD_CUSTOM_COMMAND(OUTPUT array30-big.utf8
    COMMAND cat array30_27489.utf8 array30_ExtB.utf8 > array30-big.utf8
    DEPENDS array30_27489.utf8 array30_ExtB.utf8
    VERBATIM
    )

GENERATE_FREQ(array30-big.freq array30-big.utf8)
MAKE_TABLE_SOURCE_TXT(array30-big.txt array30-big.head array30-big.freq array30.tail)

CONVERT_DB(array "array30.txt" "array30-big.txt")


