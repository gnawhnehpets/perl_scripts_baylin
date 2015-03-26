#!usr/bin/perl
use strict;
use warnings;

#This script extracts information out of the Agilent 4x44k annotation

my $filename = "/home/steve/Documents/Ahuja/Datasets/agilent4x44_ann.txt";

open(ANN, $filename) || die "cannot open annotation.txt\n";
open(NOHEAD, '>', "noheader_agilent4x44_ann.txt") || die "cannot open formatted_annotation.txt\n";

while(<ANN>){
    if($_ !~ /^\#/){
	print NOHEAD;
    }
}

close(NOHEAD);
close(ANN);

#ID	COL	ROW	NAME	SPOT_ID	CONTROL_TYPE	REFSEQ	GB_ACC	GENE	GENE_SYMBOL
#12	266	148	A_23_P146146	A_23_P146146	FALSE	NM_152565	NM_152565	245972	ATP6V0D2	ATPase, H+ transporting, lysosomal 38kDa, V0 subunit d2	Hs.436360

my $noheader_file = "/home/steve/Documents/Ahuja/perl_scripts/noheader_agilent4x44_ann.txt";
open(NEWFILE, $noheader_file) || die "cannot open noheader.txt\n";
open(ANNDBI, '>', 'agilent_ann.txt') || die "cannot open agilent_ann.txt\n";
while(<NEWFILE>){
    if(m/\d+\t\d+\t\d+\t(\w+)\t\w+\t\D+\t(\w+)\t\w+\t(\d+)\t(\w+)/){
	print ANNDBI $1."\t";
	#print $2."\n"; #EntrezID #s
	print ANNDBI $2."\n";
    }
}
close(ANNDBI);
close(NEWFILE);
