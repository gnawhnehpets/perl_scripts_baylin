#!/usr/bin/perl
use strict;
use warnings;

#directory where pi-filename_full_annotation are
my $dir = "/home/steve/Desktop/";
#name of file
my $f = "a.txt";
#path to file
my $file = $dir.$f;

#array that will save regex (e.g. first three columns of tab-del full_ann file)
my @array =();
open(FILE, $file) || die "cannot open file";

#open file and create regex pattern (e.g. first three columns)
while(my $line = <FILE>){
    chomp($line);
    my @row = split("\t", $line);
    my $two = $row[0]."\t".$row[1]."\t".$row[2];
#    print $two."\n";
    push(@array, $two);
}

close FILE;

#save unique regex patterns
@array = uniq(@array);
my $counter = 0;
#@array contains "pi\tsubmitter\tdate"
#for each unique regex pattern (aka unique experiment), writeout row ($line) to unique file
foreach my $x (@array){
    #print $x."\n";
    #unique tab
    open(SEC, $file) || die "cannot open 2nd time\n";
    while(my $line = <SEC>){
	chomp $line;
	if($line =~ /($x)/){
	    my $date = "";
	    my $submitter = "";
	    my $pi = "";
	    if($x =~ /^(.*)\t(.*)\t(.*)$/){
		$pi = $1;
		$submitter = $2;
		$date = $3;
	    }
	    my $output = "/home/steve/Desktop/".$pi."-".$submitter."-".$date.".txt";
	    print "hit!\n";
	    open(OUT, '>>', $output) || die "cannot write out";
	    print OUT $line."\n";
	    close OUT;
	}
    }
    $counter++;
}

close SEC;
sub uniq {
    return keys %{{ map { $_ => 1 } @_ }};
}
