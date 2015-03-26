#!usr/bin/perl
use strict;
use warnings;

my $directory = "/home/steve/.gvfs/onc-analysis\$ on onc-cbio2.win.ad.jhu.edu/users/shwang26/geo/colon/extract/";
my $targets_file = $directory."targets.txt";
my $targets_full_file = $directory."targets_full.txt";

opendir my($dh), $directory or die "Couldn't open dir '$directory': $!";
my @files = readdir $dh;
closedir $dh;

open(DIR, ">", "txtindir.txt") || die "could not create text_in_dir.txt!";
foreach my $x (@files){
    if($x =~ /^jhu.*\.txt$/){ #all .txt files
	print DIR $x."\n";
    }
}
close DIR;

open(FILE, "txtindir.txt") || die "could not open file!";
#filename
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
=d
jhu_251485071040_S01_GE2_107_Sep09_1_4_HCC1187  Mock Day10 RNA-Cy3_HCC1187  AZA Day10 RNA-Cy5.txt
jhu_251485071041_S01_GE2_107_Sep09_1_1_HCC1419  Mock Day1 RNA-Cy3_HCC1419  AZA Day1 RNA-Cy5.txt
jhu_251485071041_S01_GE2_107_Sep09_1_2_HCC1419  Mock Day3 RNA-Cy3_HCC1419  AZA Day3 RNA-Cy5.txt
jhu_251485071041_S01_GE2_107_Sep09_1_3_HCC1419  Mock Day7 RNA-Cy3_HCC1419  AZA Day7 RNA-Cy5.txt
jhu_251485071041_S01_GE2_107_Sep09_1_4_HCC1419 Mock Day10 RNA-Cy3_HCC1419  AZA Day10 RNA-Cy5.txt
=cut
#    if($_ =~ /^jhu.*\d+\_\d+\_(\w+) (\w+)\-(\w+)\_(\w+) (\w+)\-(\w+)/){
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
#print scalar(@filename)."\n";
#print scalar(@samplename)."\n";
close FILE;
#CHECK

open(TARGETS, '>', $targets_file) || die "cannot create file targets.txt\n";
open(TARGETS_FULL, '>', $targets_full_file ) || die "cannot creat file targets_full.txt\n";

for(my $i=0; $i<scalar(@filename); $i++){
    my $num = $i+1;
    print $num."\n";
    print TARGETS $samplenumber[$i]."\t".$filename[$i]."\t".$samplename[$i]."\n";
}

close(TARGETS);
close(TARGETS_FULL);
=d
print TARGETS "SampleNumber\tFileName\tCy3\tCy5\n";#\tCellLine\tDay\n";
print TARGETS_FULL "SampleNumber\tFileName\tCy3\tCy5\tCy3_Sample\tCy5_sample\n";

$counter=1;
for(my $i=1; $i<scalar(@filename); $i++){
    #print sample number / filename / sample in cy3 / sample in cy5 
    my $file = chomp($filename[$i]);
    #print status & sample name (pre-sample_id/post-sample_id)
#    print TARGETS "$i\t$filename[$i]\t$three_stat[$i]-$three[$i]\t$five_stat[$i]-$five[$i]\n";
    # print status (pre or post)
    print TARGETS "$i\t$filename[$i]\t$three_stat[$i]\t$five_stat[$i]\n";
    print TARGETS_FULL "$i\t$filename[$i]\t$three_stat[$i]\t$five_stat[$i]\t$three[$i]\t$five[$i]\n";
}
#print scalar(@filename)."\n";
close(TARGETS);
close(TARGETS_FULL);
=cut
print "done! (targets file created)\n";
