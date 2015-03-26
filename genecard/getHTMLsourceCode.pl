#!/usr/bin/perl;
use strict;
use warnings;
#use HTML::TreeBuilder;
use WWW::Mechanize;

#############################################################################################################
# This script takes a list of genes ($genelist) and then pulls the description information from genecard HTML
############################################################################################################# 

my $baseurl = "http://www.genecards.org/cgi-bin/carddisp.pl?gene=";
#my $baseurl = "http://en.wikipedia.org/wiki/";
#my $baseurl = "http://www.genecards.org/index.php?path=/Search/keyword/";
#my $genelist = "htmlgenelistp0001.txt";
#my $genelist = "htmlgenelistp001new.txt";
#my $genelist = "genes5vsaim.txt";
#my $genelist = "uniquegenesvsaim.txt";
my $genelist = "genes7.txt";
my @genes = ();
my @urls = ();
open(GENE, $genelist) || die "cannot open genelist.txt\n";
while(my $line = <GENE>){
    if($line =~ /\s+(\S+)$/){
#	print $1."\n";
	push(@genes, $1);
    }
}
close(GENE);
my $counter = 1;

foreach my $x (@genes){
    my $add = $baseurl.$x;
#    print $counter."\t".$add."\n";
    push(@urls, $add);
    $counter++;
}

print "Annotation for " . scalar(@genes) . " total genes\n";
my $mech = WWW::Mechanize->new();
foreach my $x (@urls){
#    print $x."\n";
    $mech -> get($x);
    my @links = $mech -> links();
    if($mech->content(format=>'text') =~ m/GeneCards Summary for (\w+) Gene\:(.*)(UniProtKB\/Swiss\-Prot\:)?/){
#	print substr($2,1,500)."\n";
	my $gene = $1;
	if(substr($2, 1, 500) =~ m/(.*)UniProtKB/){
	    print "########## " . $gene . " ##########\n";
	    print $1."\n";
#	    substr($1, 1, 200);
#	    print $mech-> links()."\n";
	}
    }
}
