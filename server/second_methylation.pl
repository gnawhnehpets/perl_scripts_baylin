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
#my $exp_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/Illumina sheet/work sheet/expression/test/";
#my $exp_data_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/expression output/";

#Directory containing excel files of methylation experiments
#my $m27_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/Illumina sheet/work sheet/methylation27/test/";
#my $m27_data_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/methylation27 output/";

#my $m450_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/Illumina sheet/work sheet/methylation450/test/";
my $m450_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/Illumina sheet/work sheet/baylin/test-met/";
my $m450_data_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/methylation450 output/";

########################################################
my $dir = $m450_dir;
########################################################
my $txtdir = $dir."x/txt/";
my $dir_fullann = $txtdir."individual/";

#get all .csv files
opendir(WD, $dir_fullann) or die "cannot open dirfullann";
my @wd = readdir WD;
closedir WD;
my $counter =0;
#filename = $file, no path
foreach my $file (@wd){
    if($file =~ /\.csv$/i){
	#print name of pi.csv file
	print "> FILE: ".$file."\n";
	my @array =();
	#path to pi.csv file
	my $f = $dir_fullann.$file;
	#open pi.csv file
	open(FILE, $f) || die "cannot open file";
	
	#open file and create regex pattern (e.g. first three columns)
	while(my $line = <FILE>){
	    chomp($line);
	    my @row = split("\t", $line);
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	    #$pi = pi
	    #$submitter = submitter
	    #$submit_date = submit date
	    #$sample_type = sample type
	    #$ship_date = array order date
	    #$use_date = array use date
	    #$array_type = array type
	    #$barcode = barcode
	    #$sample_name = sample name
	    #$sample_description = sample description
#	    my $two = $row[0]."\t".$row[1]."\t".$row[2]."\t".$row[4]."\t".$row[33]."\t".$row[34]."\t".$row[35]."\t".$row[36];

	    #save regex pattern
	    my $two = $row[0]."\t".$row[1]."\t".$row[2]."\t".$row[4]."\t".$row[33]."\t".$row[34]."\t".$row[35]."\t".$row[36]."\t".$row[5]."\t".$row[6];
	    print "REGEX: ". $two."\n";
	    #save regex pattern in array
	    push(@array, $two);
	}
	close FILE;
	
	
	#save unique regex patterns
	@array = uniq(@array);
	my $counter = 0;
	#for each unique regex pattern (aka unique experiment), 
	#writeout row ($line) to unique file
	#FOREACH REGEX PATTERN...
	foreach my $x (@array){
	    #unique tab
	    #$first = pi
	    #$second = submitter
	    #$third = submit date
	    #$fourth = sample type
	    #$fifth = array order date
	    #$sixth = array use date
	    #$seventh = array type
	    #$eighth = barcode
	    #$ninth = sample name
	    #$tenth = sample description

# 	    my($first, $second, $third, $fourth, $fifth, $sixth, $seventh, $eighth, $ninth, $eighth) = $x =~ /(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)$/;
	    #Zahnow	Joo Mi Yi	2009-10-14	DNA-ssDNA	2009-10-13	2009-11-11	Human Methylation 27	4953087042	CZ1	Cell 

	    my($pi, $submitter, $submit_date, $sample_type, $ship_date, $use_date, $array_type, $bc, $sample_name, $sample_description) = $x =~ /(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)$/;

	    #CREATE A FILENAME BASED ON ATTRIBUTES
	    my $exptfilepref = $pi."_".$submitter."_".$submit_date."_".$sample_type."_".$ship_date."_".$use_date;
	    print "FILEPREF: ".$exptfilepref."\n";
#	    print "####################################################\n";
#	    print "FIRST: $first\n2nd: $second\n3rd: $third\n4th: $fourth\n5th: $fifth\n6th: $sixth\n7th: $seventh\n8th: $eighth\n";
#	    print "####################################################\n";

	    #$f = path to pi.csv
	    #READ PI.CSV...
	    open(SEC, $f) || die "cannot open 2nd time\n";
	    while(my $line = <SEC>){
		chomp($line);
#		my $output = $dir_fullann."expt/".$pi."_".$submitter."_".$submit_date."_".$sample_type."_".$ship_date."_".$use_date.".txt";
#		open(OUT, '>>', $output) || die "cannot write out: $!\n";
#		if($line =~/($first)\t($second)\t($third).*($fourth).*($fifth)\t($sixth)/){ #\t($seventh)/){
		if($line =~/($pi)\t($submitter).*($submit_date).*($sample_type).*($ship_date)\t($use_date)/){
		    
		    my $output = $dir_fullann."expt/".$pi."_".$submitter."_".$submit_date."_".$sample_type."_".$ship_date."_".$use_date.".txt";   
#		    print "OUTTEST: ".$output."\n";
#		    my $output = $dir_fullann."expt/".$exptfilepref;
		    open(OUT, '>>', $output) || die "cannot write out: $!\n";
		    print OUT $line."\n";
		    close(OUT);
		}
	    }
	    close(SEC);

	}
    }
}

#AT THIS POINT, WE HAVE OUT EXPT.TXT

#every expt_file.txt
my $expt_dir = $dir_fullann."expt/";
opendir(HD, $expt_dir) or die "cannot open dirfullann";
my @expt = readdir HD;
closedir HD;

#create ann.txt for each expt_file.txt
#>>>>>>>>>>>>>
#PI Name 	User Name	Sample Send Date	Sample Type	Sample Name	Sample Description	Sample Label	Ship-in Date	Use Date	Array Type	 Array Bar Code	Array position	
#store values of each attribute for annotation
foreach my $exp (@expt){
#    print $exp."\n";
    if($exp =~ /\.txt$/){
	my @pi_ann = ();
	my @submitter_ann = ();
	my @submitdate_ann = ();
	my @sampletype_ann = ();
	my @shipdate_ann = ();
	my @usedate_ann = ();
	my @arraytype_ann = ();
	my @bc_ann = ();
	my @samplename_ann = ();
	my @sampledescription_ann = ();
	
	my ($pref) = $exp =~ /(.*)\.txt/;
	my $filepath = $expt_dir.$exp;
	open(FI, $filepath) || die "cannot open file for ann.txt";
	while(my $line = <FI>){
	    chomp($line);
	    my @row = split("\t", $line);
	    
	    #$pi = pi
	    #$submitter = submitter
	    #$submit_date = submit date
	    #$sample_type = sample type
	    #$ship_date = array order date
	    #$use_date = array use date
	    #$array_type = array type
	    #$barcode = barcode
	    #$sample_name = sample name
	    #$sample_description = sample description
	    #my $two = $row[0]."\t".$row[1]."\t".$row[2]."\t".$row[4]."\t".$row[33]."\t".$row[34]."\t".$row[35]."\t".$row[36]."\t".$row[5]."\t".$row[6];
	    push(@pi_ann, $row[0]);
	    push(@submitter_ann, $row[1]);
	    push(@submitdate_ann, $row[2]);
	    if($row[4] ne ""){
		push(@sampletype_ann, $row[4]);
	    }
	    push(@shipdate_ann, $row[33]);
	    push(@usedate_ann, $row[34]);
	    push(@arraytype_ann, $row[35]);
	    push(@bc_ann, $row[36]);
	    push(@samplename_ann, $row[5]);
	    if($row[6] ne ""){
		push(@sampledescription_ann, $row[6]);
	    }
	}
	close FI;
	
	my %pi_seen;
	my %submitter_seen;
	my %submitdate_seen;
	my %shipdate_seen;
	my %usedate_seen;
	my %sampletype_seen;
	my %arraytype_seen;
	my %bc_seen;
	my %samplename_seen;
	my %sampledescription_seen;
	@pi_ann = grep { ! $pi_seen{$_}++ } @pi_ann;
	@submitter_ann = grep { ! $submitter_seen{$_}++ } @submitter_ann;
	@submitdate_ann = grep { ! $submitdate_seen{$_}++ } @submitdate_ann;
	@sampletype_ann = grep { ! $sampletype_seen{$_}++ } @sampletype_ann;
	@shipdate_ann = grep { ! $shipdate_seen{$_}++ } @shipdate_ann;
	@usedate_ann = grep { ! $usedate_seen{$_}++ } @usedate_ann;
	@arraytype_ann = grep { ! $arraytype_seen{$_}++ } @arraytype_ann;
	@bc_ann = grep { ! $bc_seen{$_}++ } @bc_ann;
	@samplename_ann = grep { ! $samplename_seen{$_}++ } @samplename_ann;
	@sampledescription_ann = grep { ! $sampledescription_seen{$_}++ } @sampledescription_ann;
	
#	@pi_ann = uniq(@pi_ann);
#	@submitter_ann = uniq(@submitter_ann);
#	@submitdate_ann = uniq(@submitdate_ann);
#	@sampletype_ann = uniq(@sampletype_ann);
#	@shipdate_ann = uniq(@shipdate_ann);
#	@usedate_ann = uniq(@usedate_ann);
#	@arraytype_ann = uniq(@arraytype_ann);
#	@bc_ann = uniq(@bc_ann);
#	@samplename_ann = uniq(@samplename_ann);
#	@sampledescription_ann = uniq(@sampledescription_ann);
	
	my $anntxtpath = $expt_dir.$pref."_annotation.txt";
	print $pref."\n";
	open(ANN, '>', $anntxtpath) || die "cannot write ann.txt\n";
#	print ANN "> FILENAME:\t\t\n";
	foreach my $p (@pi_ann){
	    print ANN "PI:\t$p\n";	
	}
	foreach my $s (@submitter_ann){
	    print ANN "submitter:\t$s\n";
	}
	foreach my $sd (@submitdate_ann){
	    print ANN "submit_date:\t$sd\n";
	}
	foreach my $st (@sampletype_ann){
	    print ANN "sample_type:\t$st\n";
	}
	foreach my $sn (@samplename_ann){
	    print ANN "sample_name:\t$sn\n";
	}
	foreach my $desc (@sampledescription_ann){
	    print ANN "sample_description:\t$desc\n";
	}
	foreach my $ship (@shipdate_ann){
	    print ANN "ship_date:\t$ship\n";
	}
	foreach my $u (@usedate_ann){
	    print ANN "use_date:\t$u\n";
	}
	foreach my $at (@arraytype_ann){
	    print ANN "array_type:\t$at\n";
	}
	foreach my $b (@bc_ann){
	    print ANN "barcode:\t$b\n";
	}
	close(ANN);
    }  
}
	    
#>>>>>>>>>>>>>

#add header to each expt_file.txt
foreach my $e (@expt){
    if($e =~ /\.txt$/){
	#print $e."\n";
	my ($pref) = $e =~ /(.*)\.txt/;
	my $filepath = $expt_dir.$e;
	open(F, "<", $filepath) || die "cannot open filepath";
	my @filecontents = <F>;
	close(F);
#	my $filewithheader = $expt_dir.$e."_withheader.txt";
	my $filewithheader = $expt_dir.$pref."_withheader.txt";
	open(H, ">", $filewithheader) || die "cannot open filewithheader\n";
	print H "PI Name 	User Name	REFERENCE\tSample Send Date	Sample Type	Sample Name	Sample Description	Cell No.	Send Genomic DNA  Concentration (ng/µl)	Volume (ul)	Yield (µg)                  	Date Process	Genomic DNA Concentration (ng/µl)	Vol (ul)	Yield (ug)	OD 260/280	OD 260/230	Run Agarose gel Loading Conc. (ng/ul)	Result of gel	Send SsDNA Con.c (ng/ul)	Vol (ul)	Yield (ng)	Input Genimic DNA (ug)	SsDNA Con.c (ng/ul)	Vol (ul)	Yield (ng)	OD 260/280	OD 260/230	Sample Label	InputSsDNA  For Amplify(ul)	Plate Position   #	Hyb Temp & Speed	Hyb Time	Ship-in Date	Use Date	Array Type	 Array Bar Code	Array position	Name/Bar code/position	Batch Code	Kit Serial Number	\n";
	print H @filecontents;
	close(H);
	
	#######################################
	#unique entries only
	open(HE, "<", $filewithheader) || die "cannot open filewithheader";
	my @entries = <HE>;
	close(HE);
	my %entry_seen;
	my @entries_unique = grep { ! $entry_seen{$_}++ } @entries;
	my $uniqueentries = $expt_dir.$pref."_uniqueentries.txt";
	open(UNI, '>', $uniqueentries) || die "cannot open _uniqueentries.txt";
	print UNI @entries_unique;
	close(UNI);
	#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

	#######################################
	#Write full stats out to Excel
#	open(HXL, $filewithheader) || die "cannot open filewithheader to write to excel\n";
	open(HXL, $uniqueentries) || die "cannot open uniqueentries.txt to write to xl";
	my $full_row_num = 0;
	my $final_xl_path = $expt_dir.$pref.".xls";
	my $xl = Spreadsheet::WriteExcel->new($final_xl_path);
	my $full_ann = $xl -> add_worksheet();
	my $full_format = $xl->add_format();
	$full_format->set_color('blue');
	while(my $full_line = <HXL>){
	    chomp($full_line);
	    my @full_data = split("\t", $full_line); 
	    my $full_size = scalar(@full_data);
	    for(my $col=0; $col < $full_size+1; $col++){
		$full_ann ->write($full_row_num, $col, $full_data[$col], $full_format);
	    }
	    @full_data=();
	    $full_row_num++;
	}
	$xl -> close();
	close HXL;
    }
}

=d
=cut
#Function returns only unique values of an array
sub uniq {
    return keys %{{ map { $_ => 1 } @_ }};
}
