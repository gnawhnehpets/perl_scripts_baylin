#!usr/bin/perl
use strict;
use warnings;

##########
# Purpose:
##########
# This script is used to create the targets files necessary for the 'limma' R/Bioconductor package. 

#directory containing expression files
my $directory = "/home/steve/.gvfs/onc-analysis\$ on onc-cbio2.win.ad.jhu.edu/users/shwang26/geo/colon/extract/";
my $targets_file = $directory."targets.txt";
my $targets_full_file = $directory."targets_full.txt";

opendir my($dh), $directory or die "Couldn't open dir '$directory': $!";
my @files = readdir $dh;
closedir $dh;

#grep only for the expression files
open(DIR, ">", "txtindir.txt") || die "could not create text_in_dir.txt!";
foreach my $x (@files){
    if($x =~ /^jhu.*\.txt$/){ #all .txt files
	print DIR $x."\n";
    }
}
close DIR;


open(FILE, "txtindir.txt") || die "could not open file!";
######################
# example of filenames
######################
=d
jhu_251485071040_S01_GE2_107_Sep09_1_4_HCC1187  Mock Day10 RNA-Cy3_HCC1187  AZA Day10 RNA-Cy5.txt
jhu_251485071041_S01_GE2_107_Sep09_1_1_HCC1419  Mock Day1 RNA-Cy3_HCC1419  AZA Day1 RNA-Cy5.txt
jhu_251485071041_S01_GE2_107_Sep09_1_2_HCC1419  Mock Day3 RNA-Cy3_HCC1419  AZA Day3 RNA-Cy5.txt
jhu_251485071041_S01_GE2_107_Sep09_1_3_HCC1419  Mock Day7 RNA-Cy3_HCC1419  AZA Day7 RNA-Cy5.txt
jhu_251485071041_S01_GE2_107_Sep09_1_4_HCC1419 Mock Day10 RNA-Cy3_HCC1419  AZA Day10 RNA-Cy5.txt
=cut

#initialize arrays
my @samplenumber;
push(@samplenumber, "SampleNumber");
my @filename;
push(@filename, "FileName");
my @samplename;
push(@samplename, "SampleName");
my $samplename;
my $count = 1;
while(<FILE>){
    $samplename = "";
    #grep for and save metadata in filename
    if($_ =~ /jhu.*Sep09\_\d\_\d\_(.*)\-Cy3\_(.*)[\-?\_?]Cy5/i){
	chomp $_;
	print $1."/".$2."\n";
	$samplename = $1."/".$2;
	print $samplename."\n";
	push(@samplenumber, $count);
	$count++;
	push(@filename, $_);
	push(@samplename, $samplename);
    }
}
close FILE;

#save metadata in targets.txt, targets_full.txt
open(TARGETS, '>', $targets_file) || die "cannot create file targets.txt\n";
open(TARGETS_FULL, '>', $targets_full_file ) || die "cannot creat file targets_full.txt\n";

for(my $i=0; $i<scalar(@filename); $i++){
    my $num = $i+1;
    print $num."\n";
    print TARGETS $samplenumber[$i]."\t".$filename[$i]."\t".$samplename[$i]."\n";
}

close(TARGETS);
close(TARGETS_FULL);
print "done! (targets file created)\n";
