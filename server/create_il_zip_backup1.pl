#!/usr/bin/perl

###########################################################################
#This script parses full_annotation files created from current.pl/il2c.pl
#and creates text files for individual experiments
#NOTE: need to change `$dir = ` and `$datadir = `to directory of files
###########################################################################
use strict;
use warnings;
use Archive::Zip;
use Spreadsheet::ParseExcel;
use Spreadsheet::WriteExcel;
#Used in conjunction with Archive::Zip to remove extraneous subdirectories
use File::Basename 'basename';

#directory where pi-filename_full_annotation are
#Directory containing excel files of expression data output
my $exp_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/Illumina sheet/work sheet/expression/test/";
my $exp_data_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/expression output/";
my $m27_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/Illumina sheet/work sheet/methylation27/test/";
my $m27_data_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/methylation27 output/";
#Directory containing excel files of expression data output
my $m450_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/Illumina sheet/work sheet/methylation450/test/";
my $m450_data_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/methylation450 output/";

########################################################
my $dir = $m450_dir;
########################################################
my $txtdir = $dir."x/txt/";
my $dir_fullann = $txtdir."individual/";
print "DIRFULLAN: $dir_fullann\n";
opendir(WD, $dir_fullann) or die "cannot open dirfullann";
my @wd = readdir WD;
closedir WD;
my $counter =0;
#filename = $file, no path
foreach my $file (@wd){
    if($file =~ /^(\S+)\-.*\.txt$/){
#	print $file."\n";
#	$counter++;
	#array that will save regex (e.g. first three columns of tab-del full_ann file)
	my @array =();
	my $f = $dir_fullann.$file;
	open(FILE, $f) || die "cannot open file";
	
#open file and create regex pattern (e.g. first three columns)
	while(my $line = <FILE>){
	    chomp($line);
	    my @row = split("\t", $line);
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	    my $two = $row[0]."\t".$row[1]."\t".$row[2];
	    #my $bc = "";
	    #if($line =~ /([0-9]{10})/){
		#$bc = $1;
	    #}
	    #my $two = $row[0]."\t".$row[1]."\t".$bc;
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
	    open(SEC, $f) || die "cannot open 2nd time\n";
	    while(my $line = <SEC>){
		chomp $line;
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#		my $first = "";
#		my $second = "";
#		my $third = "";
#		if($x =~ /(.*)\t(.*)\t(.*)/){
#		    $first = $1;
#		    $second = $2;
#		    $third = $3;
#		}
		if($line =~ /($x)/){
		#if($line =~ /($first).*($second).*($third)/){
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		    my $date = "";
		    my $submitter = "";
		    my $pi = "";
		    #PI \t submitter \t dataprocess?
		    if($x =~ /^(.*)\t(.*)\t(.*)$/){
			$pi = $1;
			$submitter = $2;
			$date = $3;
		    }
		    $pi =~ s/N\/A/none/;
		    $submitter =~ s/N\/A/none/;
		    $date =~ s/N\/A/none/;
		    $date =~ s/\//\-/;
		    $date =~ s/\//\-/;

		    my $output = $dir_fullann."indy/".$pi."-".$submitter."-".$date.".txt";
		    #print "OUTPUT $output\n";
		    #print "hit!\n";
		    open(OUT, '>>', $output) || die "cannot write out";
		    print OUT $line."\n";
		    close OUT;
		}
	    }
	    $counter++;
	}
	close SEC;
    }
}

#format with header
my $dir_fullann_indy = $dir_fullann."indy/";
opendir(IND, $dir_fullann_indy) or die "cannot open dirfullann";
my @ind_wd = readdir IND;
closedir IND;

#for all individual file...
foreach my $indy (@ind_wd){
    my @indylines = ();
    if($indy =~ /^(.*)\.txt$/){
	my $headerprint=0;
	#path to individual file
	my $i = $dir_fullann_indy.$indy;
	#open each individual file
	print "FILE: $indy\n";
	open(INDYF, $i) || die "cannot open indy file \n";
	while(my $indyline = <INDYF>){
	    chomp($indyline);
	    push(@indylines, $indyline);
	}
	print "INDYARRAY: ".scalar(@indylines)."\n";
	close INDYF;
	#path to formatted file
	my $i_barcode = $dir_fullann_indy.$1."-barcode.txt";
	open(BAR, '>>', $i_barcode) || die "cannot open indy barcode\n";

	foreach my $il (@indylines){
	    if($headerprint == 0){
		print BAR "PI Name 	User Name	Sample Send Date	Sample Type	Sample Name	Sample Description	Cell No.	Send Genomic DNA  Concentration (ng/µl)	Volume (ul)	Yield (µg)                  	Date Process	Genomic DNA Concentration (ng/µl)	Vol (ul)	Yield (ug)	OD 260/280	OD 260/230	Run Agarose gel Loading Conc. (ng/ul)	Result of gel	Send SsDNA Con.c (ng/ul)	Vol (ul)	Yield (ng)	Input Genimic DNA (ug)	SsDNA Con.c (ng/ul)	Vol (ul)	Yield (ng)	OD 260/280	OD 260/230	Sample Label	InputSsDNA  For Amplify(ul)	Plate Position   #	Hyb Temp & Speed	Hyb Time	Ship-in Date	Use Date	Array Type	 Array Bar Code	Array position	Name/Bar code/position	Batch Code	Kit Serial Number	\n";
		$headerprint++;
	    }
	    print BAR $il."\n";
	}
	close BAR;
    }
}

#Function returns only unique values of an array
sub uniq {
    return keys %{{ map { $_ => 1 } @_ }};
}
