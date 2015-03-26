#!/usr/bin/perl
use strict;
use warnings;

#Used in conjunction with ag2c_data.pl

my $dir ="/home/steve/Desktop/MA_core_download/backup/agilent backup/array worksheet/Two color expression array worksheet/Steve Baylin/all/txt/";

opendir DATA, $dir or die "cannot open dir $dir: $!";
my @data_file = readdir DATA;
closedir DATA;

my $pi_counter=0;

foreach my $x (@data_file){
    if($x =~ /\.txt/){
	open(DAT, $dir.$x) || die "cannot open $x\n";
	while(<DAT>){
	    if(m/^pi\:/i){
		$pi_counter++;
	    }
	}
	close DAT;
	if($pi_counter == 0){
	    print "no PI found in $x\n";
	}
	$pi_counter=0;
    }
}
