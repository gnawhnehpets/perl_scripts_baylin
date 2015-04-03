#!/usr/bin/perl
use strict;
use warnings;

##########
# Purpose:
##########
# Directory bedgraph files (mislabeled '.bed' from source) need to be converted into .wig files in order to be converted to .tdf files with IGVTools in order to view global coverage within IGV browser

#grep for all bedgraph files
my @files = <*.bed>;
my $usage = "Usage $0 <infile>\n";

#for each bedgraph file...
foreach my $file (@files){
    print "> ".$file."\n";
    my $infile = $file;
    my $infile_name="test";
    if($infile =~ /(\w+)\_R1.bam.sorted.bam_FILTERED.bed_normalized.bed/){
	#regex for the sample name (format: timepoint.samplemark/type
	$infile_name = $1;
    }else{
	print  "no match: ".$infile."\n";
    }
    #name of sample
    print $infile_name."\n";
    my $outfile = $infile."_output.wig";
    print $outfile."\n";
    #open bedgraph file
    open(IN, $file) || die "could not open infile\n";
    open(OUT, '>', $outfile) || die "could not open outfile\n";
    #print header to output file
    print OUT "track type=wiggle_0 name=".$infile_name." description=".$infile_name." visibility=full\n";
    #parse through bedgraph file...
    while(<IN>){
	chomp;
	#grep bedgraph stats
	my ($chr, $start, $end, $data) = split(/\t/);
	my $length = $end - $start;
	if($data != 0){
	    #print out bedgraph stats in .wig format
	    print OUT "fixedStep chrom=$chr start=$start step=1 span=1\n";
	    for(0 .. $length){
		print OUT "$data\n";
	    }
	}
	
    }
    
    close(IN);
    close(OUT);
}
