#!/usr/bin/perl

use strict;
use warnings;

# /home/steve/.gvfs/onc-analysis$ on onc-cbio2.win.ad.jhu.edu/users/shwang26/michelle/BED_files

#my $infile = "/home/steve/Downloads/test.txt";
#my $infile = "/home/steve/.gvfs/onc-analysis\$ on onc-cbio2.win.ad.jhu.edu/users/shwang26/michelle/BED_files/C3MDNMT1_R1.bam.sorted.bam_FILTERED.bed_normalized.bed";
#my $outfile = "/home/steve/Downloads/output.txt";


my $usage = "Usage $0 <infile>\n";
my $infile = shift or die $usage;
#my $output = shift or die $usage;
my $infile_name="test";
if($infile =~ /.*\/(\w+)\_R1.bam.sorted.bam_FILTERED.bed_normalized.bed/){
    $infile_name = $1;
}else{
    print  "no match: ".$infile."\n";
}

print $infile_name."\n";
my $outfile = $infile."_output.wig";
open(IN, '<', $infile) || die "could not open infile\n";
open(OUT, '>', $outfile) || die "could not open outfile\n";
print OUT "track type=wiggle_0 name=".$infile_name." description=".$infile_name." visibility=full\n";
while(<IN>){

    chomp;
    my ($chr, $start, $end, $data) = split(/\t/);
    my $length = $end - $start;
    print OUT "fixedStep chrom=$chr start=$start step=1 span=1\n";
    for(0 .. $length){
	print OUT "$data\n";
    }

}

close(IN);
close(OUT);
