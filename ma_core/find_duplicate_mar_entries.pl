#!/usr/bin/perl
use strict;
use warnings;

### This script will find out whether there are duplicated
### within the microarrays core repository

### User needs to copy and paste all listings found in 
### Microarray Data Repository <http://lizst.onc.jhmi.edu/m_array_dr/Login>
### into `servlist.txt` before running this script.

open(FILE, "mar_list.txt") or die "cannot open file\n";
my @filename;
my @date;
my @time;
my @filesize;
my $counter=0;
while(<FILE>){
### example entry from microarray data repository
#ne_ycai_10302013.zip		10/30/2013 05:47:55 PM		309753351
    if(/^(.*)\s+(\d+\/\d+\/\d+) +(\d+\:\d+\:\d+ +[PA]M)\s+(\d+)/){
	$filename[$counter]=$1;
	$date[$counter]=$2;
	$time[$counter]=$3;
	$filesize[$counter]=$4;
    }
    $counter++;
}
close(FILE);

my %seen = ();
my @duplicate_names = map { 1==$seen{$_}++ ? $_ : () } @filename;
if(scalar(@duplicate_names)>0){
    print "\nDuplicates found! (microarray repository)\n";
    my $dup_count=1;
    foreach my $x(@duplicate_names){
	#Remove any white space at end
	$x =~ s/\s+$//;
	print "DUPLICATE#$dup_count: $x\n";
	$dup_count++;
    }
}else{
    print "\nNo duplicates found. (microarray repository)\n\n";
}
