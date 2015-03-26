#!/usr/bin/perl
use strict;
use warnings;

#This script will find out whether there are duplicated
#within the microarrays core repository

#User needs to copy and paste all listings found in 
#file server into `fs_servlist.txt` before running this script.

open(FILE, "filenames.txt") or die "cannot open file\n";
my @filename;
my @date;
my @time;
my @filesize;
my $counter=0;
while(<FILE>){
### example entry from microarray data repository
# -rw-rw-r-- 1 steve steve 1479 Oct 31 14:54 find_duplicate_fs_entries.pl
# -rw-rw-r-- 1 steve steve 1475 Oct 31 14:53 find_duplicate_fs_entries.pl~

#     if(/^(.*)\s+(\d+\/\d+\/\d+) +(\d+\:\d+\:\d+ +[PA]M)\s+(\d+)/){
    if(/^(\-.+)\s+(\d+\s+\D+\s+\D+)\s+(\d+)\s+(\D+\s+\d+)\s+(\d+\:\d+)\s+(.*\.\w+)$/){
	print "\nPermissions:$1\n";
#	print "Junk:$2\n";
	print "File size:$3\n";
	print "Date:$4\n";
	print "Time:$5\n";
	print "Filename:$6\n";
    }
    $counter++;
}
close(FILE);

### CHECK
=d
print scalar(@filename)."\n";
print scalar(@date)."\n";
print scalar(@time)."\n";
print scalar(@filesize)."\n";
print $counter."\n";

foreach my $x(@filename){
    print $x."\n";
}
=cut

=d
my %seen = ();
my @duplicate_names = map { 1==$seen{$_}++ ? $_ : () } @filename;
if(scalar(@duplicate_names)>0){
    print "\nDuplicates found! (file server)\n";
    my $dup_count=1;
    foreach my $x(@duplicate_names){
	#Remove any white space at end
	$x =~ s/\s+$//;
	print "DUPLICATE#$dup_count: $x\n";
	$dup_count++;
    }
}else{
    print "\nNo duplicates found. (file server)\n\n";
}
