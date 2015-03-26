#!/usr/bin/perl
use strict;
use warnings;

my $dir = "/home/steve/Documents/Ahuja/perl_scripts/";
opendir DIR, $dir or die "cannot open dir $dir: $!";
my @files = readdir DIR;
closedir DIR;

foreach my $x(@files){
    print $x."\n";
}
