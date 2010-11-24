#!/bin/sh
LC_ALL=zh_CN.UTF-8
AWK=awk

TABLE_NAME=wubi-heifeng86

# Generate if freq is not available
function append_freq(){
    lastSeq=
    lastCh=
    freq=$freqDefault
    lastFreq=
    while read data;
    do
	seq=`echo $data | $AWK  '{print $1}'`
	ch=`echo $data | $AWK  '{print $2}'`
	freqOrig=`echo $data | $AWK  '{print $3}'`
#	echo "lastSeq=$lastSeq seq=$seq ch=$ch freqOrig=$freqOrig"
	if [ "$freqOrig" == "" ];then
	    freqOrig=0
	fi
	if [ "$seq" == "$lastSeq" ];then
	    if [ $lastFreq -le $freqOrig ];then
		freq=$((lastFreq-1))
	    else
		freq=$freqOrig
	    fi
	else
	    freq=$((freqOrig+freqDefault))
	    lastSeq=$seq
	fi

	if [ "$lastCh" != "$ch" ];then
	    echo -e "$seq\t$ch\t$freq"
	    lastCh=$ch
	    lastFreq=$freq
	fi
    done
}

function parse(){
    baseFreq=10;
    if [ "$1" == "-b" ];then
	baseFreq=$2
	shift 2
    fi
    file=$1
    outfile=$2
    keySeqIdx=$3
    charIdx=$4
    freqIdx=
    shift 4
    if [ "$1" != "" ]; then
	freqIdx=$1
	eval "${AWK} '\$${keySeqIdx} != \"\" && \$${keySeqIdx} != \".\"\
	&& \$${charIdx} != \"\" \
	{ print \$${keySeqIdx}  \"\t\" \$${charIdx} \"\t\" \$${freqIdx}+$baseFreq }'" $file |\
	    sort -k 1,1 -s > ${outfile}
    else
	eval "${AWK} '\$${keySeqIdx} != \"\" && \$${keySeqIdx} != \".\"\
	&& \$${charIdx} != \"\" \
	{ print \$${keySeqIdx}  \"\t\" \$${charIdx} \"\t$baseFreq\" }'" $file |\
	    sort -k 1,1 -s > ${outfile}
    fi
}


rm -f *.tmp ${TABLE_NAME}.utf8

catList=
tail -n +2 Word.tab > Word.tmp
for i in 3; do
    parse -b 10000 Word.tmp Word-$i.tmp $i 1 6
    catList="$catList Word-$i.tmp"
done

tail -n +2 GBK.tab > GBK.tmp
for i in 4 6 7 8 9; do
    parse -b 1000 GBK.tmp GBK-$i.tmp $i 3 18
    catList="$catList GBK-$i.tmp"
done

tail -n +2 CJKa.tab > CJKa.tmp
for i in 4 5; do
    parse CJKa.tmp CJKa-$i.tmp $i 3
    catList="$catList CJKa-$i.tmp"
done

tail -n +2 CJKb.tab > CJKb.tmp
for i in 4 5; do
    parse CJKb.tmp CJKb-$i.tmp $i 3
    catList="$catList CJKb-$i.tmp"
done

tail -n +2 CJKs.tab > CJKs.tmp
for i in 4 5; do
    parse CJKs.tmp CJKs-$i.tmp $i 3
    catList="$catList CJKs-$i.tmp"
done

tail -n +2 Symbol.tab > Symbol.tmp
for i in 4 5; do
    parse Symbol.tmp Symbol-$i.tmp $i 3
    catList="$catList Symbol-$i.tmp"
done

sort -s -k 3,3 -m $catList | sort -s -k 1,1 | append_freq >> ${TABLE_NAME}.utf8

#cat ${WUBI_HEIFENG_TMP} |  sort -u   >> wubi-heifeng86.utf8

