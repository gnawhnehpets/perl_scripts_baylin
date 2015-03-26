#!/usr/bin/perl
use strict;
use warnings;

# This script will takes Broad Institute's geneset annotation which is organized as:
# geneset1 \t    gene1, gene2, gene3
# and reorganizes it so that it lists what genesets each gene is part of
# gene1 \t       geneset1, geneset2, geneset3

# usage:
#      genelist.pl > genetogroup.txt

my %groups;

my $path = "../GENELIST.symbols.csv";
open(PATH, $path) || die "cannot open csv\n";

while(<PATH>){
    my($group, @cols) = split;
    push @{$groups{$_}}, $group for @cols;
}

use Data::Dump;
#for(my $i=0; $i<100; $i++){
    dd \%groups;
#}

my @genesets = ();
while(my $line = <PATH>){
#    print $line."\n";
    if($line =~ /^(\w+)\t/){
#	print $1."\n";
	push(@genesets, $1);
    }
}
close(PATH);

my $num_gs = scalar(@genesets);



foreach my $gs (@genesets){
    print $gs."\n";
}
