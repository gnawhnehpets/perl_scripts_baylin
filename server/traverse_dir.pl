#!/usr/bin/perl
use strict;
use warnings;
use File::Find;

my $dir = "/home/steve/Desktop/MA_core_download/backup/agilent backup/array worksheet/Two color expression array worksheet";
finddepth(\&wanted, $dir);

sub wanted { 
    if(m/.*\.xls$/){
	print "\t";
	print;
	print "\n";
    }else{
    print ;
    print "\n";
    };
}
