#!/usr/bin/perl
use strict;
use warnings;

##########
# Purpose:
##########

# This script will takes Broad Institute's geneset annotation which is organized as:
#      geneset1 \t    gene1, gene2, gene3
# and reorganizes it so that it lists what genesets each gene is part of
#      gene1 \t       geneset1, geneset2, geneset3

########
# usage:
########
#      genelist.pl > genetogroup.txt

my %groups;

#original file pulled from Broad Institute's GSEA website
#http://www.broadinstitute.org/gsea/downloads.jsp
my $path = "../GENELIST.symbols.csv";
open(PATH, $path) || die "cannot open csv\n";

while(<PATH>){
    my($group, @cols) = split;
    push @{$groups{$_}}, $group for @cols;
}

use Data::Dump;
dd \%groups;

my @genesets = ();
while(my $line = <PATH>){
    if($line =~ /^(\w+)\t/){
	push(@genesets, $1);
    }
}
close(PATH);

my $num_gs = scalar(@genesets);

foreach my $gs (@genesets){
    print $gs."\n";
}
