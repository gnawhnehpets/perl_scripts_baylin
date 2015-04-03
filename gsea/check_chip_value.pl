#!usr/bin/perl

##########
# Purpose:
##########
#Using raw .txt output, this script will parse the file to see whether the output is from Agilent/Illumina/Affy/etc. by regex-ing the motif

use strict;
use warnings;

my $filename = "/home/steve/Documents/Ahuja/Datasets/pancan_colon/raw_colon_trial_data/jhu_252665219945_S01_GE2_107_Sep09_1_3_JHH005 pre-Cy3_JHH005 post-Cy5.txt";

open(FILE, $filename) || die "unable to open file!\n";

# Agilent 4x44k arrays barcodes that begin with 16026652 or 2526652
my $motif="Agilent";

while(<FILE>){
    if(m/.*($motif).*/){
	print $_."\n";
    }
}

close(FILE);
