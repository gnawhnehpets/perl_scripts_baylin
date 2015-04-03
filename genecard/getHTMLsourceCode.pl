#!/usr/bin/perl;
use strict;
use warnings;
use WWW::Mechanize;

##########
# Purpose: 
##########
# Instead of manually searching for functional description of a gene, this script takes a list of genes ($genelist) and then pulls the description information from genecard's HTML source code

#base url
my $baseurl = "http://www.genecards.org/cgi-bin/carddisp.pl?gene=";
#list of genes of interest needing functional annotation
my $genelist = "genes7.txt";
my @genes = ();
my @urls = ();

#import genes of interest into array
open(GENE, $genelist) || die "cannot open genelist.txt\n";
while(my $line = <GENE>){
    if($line =~ /\s+(\S+)$/){
	push(@genes, $1);
    }
}
close(GENE);
my $counter = 1;

#for each gene...
foreach my $x (@genes){
    #create & save url using the base url
    my $add = $baseurl.$x;
    push(@urls, $add);
    $counter++;
}

print "Annotation for " . scalar(@genes) . " total genes\n";
my $mech = WWW::Mechanize->new();
foreach my $x (@urls){
    #pull the HTML source code using the url and regex for the description information
    $mech -> get($x);
    my @links = $mech -> links();
    if($mech->content(format=>'text') =~ m/GeneCards Summary for (\w+) Gene\:(.*)(UniProtKB\/Swiss\-Prot\:)?/){
	my $gene = $1;
	if(substr($2, 1, 500) =~ m/(.*)UniProtKB/){
	    print "########## " . $gene . " ##########\n";
	    print $1."\n";
	}
    }
}
