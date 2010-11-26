#!/bin/sh
LC_ALL=zh_CN.UTF-8
AWK=awk

TABLE_NAME=wubi-haifeng86

# Generate if freq is not available
function append_freq(){
    echo "Fixing freq" > /dev/stderr
    lastSeq=
    lastCh=
    freq=$freqDefault
    lastFreq=
    count=0
    while read data;
    do
	seq=`echo $data | $AWK  '{print $2}'`
	ch=`echo $data | $AWK  '{print $3}'`
	freqOrig=`echo $data | $AWK  '{print $1}'`
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
	count=$((count+1))
	countMod=$((count % 1000))
	if [ "$countMod" == "0" ];then
	    echo -e "$count\telements processed" > /dev/stderr
	fi
    done
    echo -e "Total $count\telements processed" > /dev/stderr
}

function parse(){
    baseFreq=100;
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
	eval "${AWK} -F \"\t\" \
	'\$${keySeqIdx} != \"\" && \$${keySeqIdx} != \".\" && \$${charIdx} != \"\" \
	{ print \$${freqIdx}+$baseFreq \"\t\" \$${keySeqIdx}  \"\t\" \$${charIdx} }'" $file |\
	    sort -nrs -k 1,1 > ${outfile}
    else
	eval "${AWK} -F \"\t\" \
	'\$${keySeqIdx} != \"\" && \$${keySeqIdx} != \".\" && \$${charIdx} != \"\" \
	{ print \"$baseFreq\t\" \$${keySeqIdx}  \"\t\" \$${charIdx}  }'" $file | \
	    sort -nrs -k 1,1  > ${outfile}
    fi
}


rm -f *.tmp ${TABLE_NAME}.UTF-8

catList=
echo "Converting Word" > /dev/stderr
tail -n +2 Word.tab > Word.tmp
for i in 3; do
    parse -b 10000 Word.tmp Word-$i.tmp $i 1 6
    catList="$catList Word-$i.tmp"
done

echo "Converting GBK" > /dev/stderr
tail -n +2 GBK.tab > GBK.tmp
for i in 4 6 7 8 9; do
    parse -b 1000 GBK.tmp GBK-$i.tmp $i 3 18
    catList="$catList GBK-$i.tmp"
done

echo "Converting CJKa" > /dev/stderr
tail -n +2 CJKa.tab > CJKa.tmp
for i in 4 5; do
    parse CJKa.tmp CJKa-$i.tmp $i 3
    catList="$catList CJKa-$i.tmp"
done

echo "Converting CJKb" > /dev/stderr
tail -n +2 CJKb.tab > CJKb.tmp
for i in 4 5; do
    parse CJKb.tmp CJKb-$i.tmp $i 3
    catList="$catList CJKb-$i.tmp"
done

echo "Converting CJKs" > /dev/stderr
tail -n +2 CJKs.tab > CJKs.tmp
for i in 5 6; do
    parse CJKs.tmp CJKs-$i.tmp $i 4
    catList="$catList CJKs-$i.tmp"
done

echo "Converting Symbol" > /dev/stderr
tail -n +2 Symbol.tab > Symbol.tmp
for i in 6 7 8; do
    parse Symbol.tmp Symbol-$i.tmp $i 5
    catList="$catList Symbol-$i.tmp"
done

echo "Merge tables" > /dev/stderr
sort -nr -k 1,1 -m $catList | sort -s -k 2,2 | append_freq >> ${TABLE_NAME}.UTF-8

