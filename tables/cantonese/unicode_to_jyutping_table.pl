#!/usr/bin/perl -CS

##########################################################################
#
#  unicode_to_jyutping_table.pl
#  Create an ibus table by using Unihan dataset. Character frequency uses
#  the data from the cantonese table.
#
#  Copyright (C) 2017 Anthony Wong
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version
#  2 of the License, or (at your option) any later version.
#
##########################################################################

use strict;
use warnings;

my $unihan_file='Unihan_Readings.txt';
my $freq_file='cantonese.txt';

my %all_pinyin;
my %freq_table;
my %mapping_table = (
    # Special cases
    "m"  => "m",
    "ng" => "ng",
    "zou" => "jo",  # for 做，早
);
my %initials = (
    # jyutping => cantonese
    "b" => "b",
    "p" => "p",
    "m" => "m",
    "f" => "f",
    "d" => "d",
    "t" => "t",
    "n" => "n",
    "l" => "l",
    "g" => "g",
    "k" => "k",
    "ng" => "ng",
    "h" => "h",
    "gw" => "gw",
    "kw" => "kw",
    "w" => "w",
    "z" => "j",
    "c" => "ch",
    "s" => "s",
    "j" => "y",
);
my %finals = (
    # jyutping => cantonese
    "aa" => "a",
    "aai" => "aai",
    "aau" => "aau",
    "aam" => "aam",
    "aan" => "aan",
    "aang" => "aang",
    "aap" => "aap",
    "aat" => "aat",
    "aak" => "aak",
    "ai" => "ai",
    "au" => "au",
    "am" => "am",
    "an" => "an", # special case: 燜 uses 'men'
    "ang" => "ang",
    "ap" => "ap",
    "at" => "at",
    "ak" => "ak",
    "e" => "e",
    "ei" => "ei",
    "eu" => "eu", # no such pronuncation in original cantonese romanization
    "em" => "em",
    "en" => "en",
    "eng" => "eng",
    "ep" => "ep",
    "et" => "et",
    "ek" => "ek",
    "i" => "i",
    "iu" => "iu",
    "im" => "im",
    "in" => "in",
    "ing" => "ing",
    "ip" => "ip",
    "it" => "it",
    "ik" => "ik",
    "o" => "oh",
    "oi" => "oi",
    "ou" => "ou",  # cantonese romanization also use 'o'
    "om" => "yam", # 媕, om
    "on" => "on",
    "ong" => "ong",
    "ot" => "ot",
    "ok" => "ok",
    "u" => "oo",
    "ui" => "ooi",
    "un" => "oon",
    "ung" => "ung",
    "ut" => "oot",
    "uk" => "uk",
    "oe" => "oe", # seems no corresponding romanization in cantonese
    "eoi" => "ui",
    "eon" => "un",
    "oeng" => "eung",
    "eot" => "ut",
    "oet" => "ut", # 㖀, loet
    "oek" => "euk",
    "yu" => "ue",
    "yun" => "uen",
    "yut" => "uet",
    "m" => "am",   # 噷, hm
    "ng" => "ang", # 哼, hng
);

# Convert from Jyutping to the Cantonese romanization used in cantonese.txt
sub convert_jp_to_cantonese {
    my $jp = $_[0];

    return $mapping_table{$jp} if (exists $mapping_table{$jp});

    my $initial = "";
    foreach my $i (keys %initials) {
        next unless $jp =~ /^$i/;
        if (length($jp) == length($i)) {
            return $mapping_table{$jp} = $initials{$i};
        }
        $initial = $i if length($i) > length($initial);
    }
    foreach my $final (keys %finals) {
        next unless $jp =~ /^$initial$final$/;
        if ($initial eq "") {
            return $mapping_table{$jp} = $finals{$final};
        } else {
            return $mapping_table{$jp} = $initials{$initial}.$finals{$final};
        }
    }
    die "Impossible!";
}

open(my $fh, '<:encoding(UTF-8)', $freq_file) or die "Cannot open file '$freq_file' $!";
while (<$fh>) {
    next unless /^([a-zA-Z]+)\s(.+)\s([0-9]+)$/;
    $freq_table{$1}{$2} = $3;
}
# Debug
#foreach my $key (sort keys %freq_table) {
#        foreach my $char (sort keys $freq_table{$key}) {
#                print $key."\t".$char."\t".$freq_table{$key}{$char}."\n";
#        }
#}
#
#use Data::Dumper qw(Dumper);

open(my $fh2, '<:encoding(UTF-8)', $unihan_file) or die "Cannot open file '$unihan_file' $!";
while (<$fh2>) {
    next unless /^(U\+[0-9A-Z]+)\skCantonese\s([a-zA-Z1-6 ]+)$/;
    my @pinyins = split(/ /,$2);
    my $char = Encode::decode_utf8(`/usr/bin/unicode --format {pchar} $1`);
    foreach my $p (@pinyins) {
        $p = substr($p, 0, -1);
        my $cantonese = convert_jp_to_cantonese($p);
        if (exists $freq_table{$cantonese}{$char}) {
            $all_pinyin{$p}{$char} = $freq_table{$cantonese}{$char};
        } else {
            $all_pinyin{$p}{$char} = 0;
        }
    }
}

# Debug
#print "========\n";
#print Dumper \%all_pinyin;
#print "========\n";

# Print results
foreach my $p (sort keys %all_pinyin) {
    foreach my $char (sort keys %{$all_pinyin{$p}}) {
        print $p."\t".$char."\t".$all_pinyin{$p}{$char}."\n";
    }
}
