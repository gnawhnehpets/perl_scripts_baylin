#!usr/bin/perl
use strict;
use warnings;

# Use this to create samplesheet.csv for minfi workflow
# Reference: http://www.bioconductor.org/packages/release/bioc/vignettes/minfi/inst/doc/minfi.pdf
# This script creates .csv file that is required for the minfi workflow.
# $path has to point to directory that contains the idat files; script will pull metadata from the
# name of the idat file through regular expressions

#my $path = "/home/steve/.gvfs/onc-analysis\$ on onc-cbio2.win.ad.jhu.edu/users/shwang26/methylation_ex/";

#AUTOMATIC INPUT
###############################################
my $first = $ARGV[0];
my $path = "";
if(length($first) <1){
    $path = "./";
}

my $input = $path.$first;
open(IN, $input) || die "this file does not exist. Please check your path to file argument.\n";
print "Data has succesffuly been imported from: ". $input."\n";
close(IN);

my $output = $ARGV[1];
if(-e $output){
    die "This file already exists! Please choose another filename.\n";
}
###############################################
#MANUAL INPUT
my $path = "/home/steve/.gvfs/d\$ on onc-cbio2.win.ad.jhu.edu/users/shwang26/mdanderson/sunilaidats/";
my $metafile = "samplestable.txt";
my $filename = $path.$metafile;
#my $filename = $input;
my @samples = ();
my @group = ();
my @barcode = ();
my @arraypos = ();

open(FILE, $filename) || die "cannot open file\n";
my $counter = 0;
while(my $line = <FILE>){
    #skip header
    if($counter == 0){
	$counter++;
	next;
    }
    chomp($line);
    #regex for metadata
    if($line =~ /(\w+) (\w+)\_(\w+)\t(\w+)\_(\w+)/){
	my $sample = $1."_".$2."_".$3;
	push(@samples, $sample);
	push(@group, $2);
	push(@barcode, $4);
	push(@arraypos, $5);
#	print "1:$1\n";
#	print "2:$2\n";
    }
    $counter++;
}    
close(FILE);

foreach my $x (@group){
    print $x."\n";
}
my $csv = $path."/minfisample.csv";
#my $csv = $output;
print scalar(@samples)."\n";
print scalar(@group)."\n";
print scalar(@barcode)."\n";
print scalar(@arraypos)."\n";

open(CSV, '>', $csv) || die "cannot open csv\n";
#print CSV "Sample_Name\tSample_Well\tSample_Plate\tSample_Group\tPool_ID\tSentrix_ID\tSentrix_Position\tperson\tage\tsex\tstatus\n";
print CSV "Sample_Name,Sample_Well,Sample_Plate,Sample_Group,Pool_ID,Sentrix_ID,Sentrix_Position,person,age,sex,status\n";
for(my $i=0; $i < scalar(@samples); $i++){
#    print CSV "$samples[$i]\twell\tplate\t$group[$i]\tpool\t$barcode[$i]\t$arraypos[$i]\tperson\tage\tsex\t$group[$i]\n";    
    print CSV "$samples[$i],well,plate,$group[$i],pool,$barcode[$i],$arraypos[$i],person,age,sex,$group[$i]\n";
}
close(CSV);
=d
open(CSV, '>', $csv) || die "cannot open csv\n";
print CSV "Sample_Name\tSample_Well\tSample_Plate\tSample_Group\tPool_ID\tperson\tage\tsex\tstatus\tArray\tSlide\n";
for(my $i=0; $i < scalar(@samples); $i++){
    print CSV "$samples[$i]\twell\tplate\t$group[$i]\tpool\tperson\tage\tsex\t$group[$i]\t$arraypos[$i]\t$barcode[$i]\n";
}
close(CSV);




