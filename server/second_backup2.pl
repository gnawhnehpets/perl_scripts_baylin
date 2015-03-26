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
my $m450_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/Illumina sheet/work sheet/baylin/test/";
my $m450_data_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/methylation450 output/";

########################################################
my $dir = $m450_dir;
########################################################
my $txtdir = $dir."x/txt/";
my $dir_fullann = $txtdir."individual/";
#print "DIRFULLAN: $dir_fullann\n";
opendir(WD, $dir_fullann) or die "cannot open dirfullann";
my @wd = readdir WD;
closedir WD;
my $counter =0;
#filename = $file, no path
foreach my $file (@wd){
#    if($file =~ /^(\S+)\-.*\.txt$/){
    if($file =~ /\.csv$/i){
#	print $file."\n";
#	$counter++;
	#array that will save regex (e.g. first three columns of tab-del full_ann file)
	print "> FILE: ".$file."\n";
	my @array =();
	my $f = $dir_fullann.$file;
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
	    my $two = $row[0]."\t".$row[1]."\t".$row[2]."\t".$row[4]."\t".$row[33]."\t".$row[34]."\t".$row[35]."\t".$row[36]."\t".$row[5]."\t".$row[6];
#>>>>>>>>>>>>>>
#	    print $two."\n";
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
	#for each unique regex pattern (aka unique experiment), 

	#writeout row ($line) to unique file
	foreach my $x (@array){
	    #print "REGEX: ".$x."\n";
	    
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
#	    my($first, $second, $third, $fourth, $fifth, $sixth, $seventh, $eighth, $ninth, $eighth) = $x =~ /(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)$/;
	    my($pi, $submitter, $submit_date, $sample_type, $ship_date, $use_date, $array_type, $bc, $sample_name, $sample_description) = $x =~ /(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)\t(.*)$/;
	    
#	    my $exptfilepref = $first."_".$second."_".$third."_".$fourth."_".$fifth."_".$sixth;
	    my $exptfilepref = $pi."_".$submitter."_".$submit_date."_".$sample_type."_".$ship_date."_".$use_date;
	    print "FILEPREF: ".$exptfilepref."\n";
	    print "####################################################\n";
#	    print "FIRST: $first\n2nd: $second\n3rd: $third\n4th: $fourth\n5th: $fifth\n6th: $sixth\n7th: $seventh\n8th: $eighth\n";
	    
	    print "####################################################\n";

	    open(SEC, $f) || die "cannot open 2nd time\n";
	    while(my $line = <SEC>){
		chomp($line);
#		if($line =~/($first)\t($second)\t($third).*($fourth).*($fifth)\t($sixth)/){ #\t($seventh)/){
		if($line =~/($pi)\t($submitter)\t($submit_date).*($sample_type).*($ship_date)\t($use_date)/){
#		    my $output = $dir_fullann."expt/".$first."_".$second."_".$third."_".$fourth."_".$fifth."_".$sixth.".txt";
		    my $output = $dir_fullann."expt/".$pi."_".$submitter."_".$submit_date."_".$sample_type."_".$ship_date."_".$use_date.".txt";
		    
#		    my $output = $dir_fullann."expt/".$exptfilepref;
#		    print "OUTPUT: $output\n";
		    open(OUT, '>>', $output) || die "cannot write out: $!\n";
		    print OUT $line."\n";
		    close OUT;
		}
	    }

	}
    }
}

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
	@pi_ann = uniq(@pi_ann);
	@submitter_ann = uniq(@submitter_ann);
	@submitdate_ann = uniq(@submitdate_ann);
	@sampletype_ann = uniq(@sampletype_ann);
	@shipdate_ann = uniq(@shipdate_ann);
	@usedate_ann = uniq(@usedate_ann);
	@arraytype_ann = uniq(@arraytype_ann);
	@bc_ann = uniq(@bc_ann);
	@samplename_ann = uniq(@samplename_ann);
	@sampledescription_ann = uniq(@sampledescription_ann);
	
	my $anntxtpath = $expt_dir.$pref."_annotation.txt";
	open(ANN, '>', $anntxtpath) || die "cannot write ann.txt\n";
	foreach my $p (@pi_ann){
		print "PI:\t\t$p\n";	
	}
	foreach my $s (@submitter_ann){
	    print "submitter:\t$s\n";
	}
	foreach my $sd (@submitdate_ann){
	    print "submit_date:\t$sd\n";
	}
	foreach my $st (@sampletype_ann){
	    print "sample_type:\t$st\n";
	}
	foreach my $sn (@samplename_ann){
	    print "sample_name:\t$sn\n";
	}
	foreach my $desc (@sampledescription_ann){
	    print "sample_desc:\t$desc\n";
	}
	foreach my $ship (@shipdate_ann){
	    print "ship_date:\t$ship\n";
	}
	foreach my $u (@usedate_ann){
	    print "use_date:\t$u\n";
	}
	foreach my $at (@arraytype_ann){
	    print "array_type:\t$at\n";
	}
	foreach my $b (@bc_ann){
	    print "barcode:\t$b\n";
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
	#Write full stats out to Excel
	open(HXL, $filewithheader) || die "cannot open filewithheader to write to excel\n";
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
open(M,"<","data.txt");
@m = <M>;
close(M);
open(M,">","data.txt");
print M "foo\n";
#print OUT "PI Name 	User Name	Sample Send Date	Sample Type	Sample Name	Sample Description	Cell No.	Send Genomic DNA  Concentration (ng/µl)	Volume (ul)	Yield (µg)                  	Date Process	Genomic DNA Concentration (ng/µl)	Vol (ul)	Yield (ug)	OD 260/280	OD 260/230	Run Agarose gel Loading Conc. (ng/ul)	Result of gel	Send SsDNA Con.c (ng/ul)	Vol (ul)	Yield (ng)	Input Genimic DNA (ug)	SsDNA Con.c (ng/ul)	Vol (ul)	Yield (ng)	OD 260/280	OD 260/230	Sample Label	InputSsDNA  For Amplify(ul)	Plate Position   #	Hyb Temp & Speed	Hyb Time	Ship-in Date	Use Date	Array Type	 Array Bar Code	Array position	Name/Bar code/position	Batch Code	Kit Serial Number	\n";
print M @m;
close(M);

=d
	    open(SEC, $f) || die "cannot open 2nd time\n";
	    while(my $line = <SEC>){
		chomp $line;
		if($line =~ /($x)/){
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

		    my $output = $dir_fullann."indy/".$pi."-".$submitter."-".$date."-".$file.".txt";
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
#	open(BAR, '>>', $i_barcode) || die "cannot open indy barcode\n";
	
	my @uniq_barcodes = ();
	foreach my $il (@indylines){
#	    if($headerprint == 0){
#		print BAR "PI Name 	User Name	Sample Send Date	Sample Type	Sample Name	Sample Description	Cell No.	Send Genomic DNA  Concentration (ng/µl)	Volume (ul)	Yield (µg)                  	Date Process	Genomic DNA Concentration (ng/µl)	Vol (ul)	Yield (ug)	OD 260/280	OD 260/230	Run Agarose gel Loading Conc. (ng/ul)	Result of gel	Send SsDNA Con.c (ng/ul)	Vol (ul)	Yield (ng)	Input Genimic DNA (ug)	SsDNA Con.c (ng/ul)	Vol (ul)	Yield (ng)	OD 260/280	OD 260/230	Sample Label	InputSsDNA  For Amplify(ul)	Plate Position   #	Hyb Temp & Speed	Hyb Time	Ship-in Date	Use Date	Array Type	 Array Bar Code	Array position	Name/Bar code/position	Batch Code	Kit Serial Number	\n";
#		$headerprint++;
#	    }
	    #print BAR $il."\n";
	    if($il =~ /.*([0-9]{10}).*/){
		push(@uniq_barcodes, $1);
	    }
	}
	@uniq_barcodes = uniq(@uniq_barcodes);
	open(BAR, '>>', $i_barcode) || die "cannot open indy barcode\n";
	foreach my $b (@uniq_barcodes){
	    print BAR $b."\n";
	}
	close BAR;
    }
=d
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    #Archive::Zip object
    my $zip = Archive::Zip->new();
    #Name of zip file
    my $zip_name = $dir."x/".$file_prefix."\.zip";
    @barcode = uniq(@barcode);
    if(@barcode){
	print IND "######################################################################\n";
	print IND "#####UNIQUE BAR CODE WITHIN $ind_ann_output:\n";
	
	
	#For each unique barcode found in each xl file, 
	#find matching directory and add it to be compressed
	
	foreach my $code (@barcode){
	    print IND $code."\n";
	    #Set directory where data folders can be found
	    ####################################################
	    ####################################################
	    #NOTE: need to change *_data_dir depending on output
	    ####################################################
	    ####################################################
	    my $datadir = $m450_data_dir.$code;
	    my $member = basename $dir;
	    $zip -> addTree($datadir, $member);
	}
		
	close XL;
	close IND;
	close TABANN;
	close FULLANN;
	#####################################333
	#Write annotation out to Excel
	open(XL, $tab_ann_output) || die "cannot open ind_ann_output to write to excel\n";
	my $xl_row_num = 0;
	$write_xl_path = $dir."x/".$file_prefix."_annotation.xls";
	my $txt_xl_out = Spreadsheet::WriteExcel->new($write_xl_path);
	my $txt_xl = $txt_xl_out -> add_worksheet();
	my $format = $txt_xl_out->add_format();
	$format->set_color('red');
	while(my $line = <XL>){
	    chomp($line);
#		if($line =~ //){
	    my @data = split("\t", $line); 
	    my $size = scalar(@data);
	    for(my $col=0; $col < $size+1; $col++){
		$txt_xl->write($xl_row_num, $col, $data[$col], $format);
	    }
	    @data=();
	    $xl_row_num++;
#		}
	}
	$txt_xl_out -> close();
	close XL;
	#######################################
	#Write full stats out to Excel
	open(FULL, $full_ann_output) || die "cannot open $full_ann_output to write to excel\n";
	my $full_row_num = 0;
	$write_full_ann_path = $dir."x/".$file_prefix."_full_annotation.xls";
	my $full_ann_out = Spreadsheet::WriteExcel->new($write_full_ann_path);
	my $full_ann = $full_ann_out -> add_worksheet();
	my $full_format = $full_ann_out->add_format();
	$full_format->set_color('blue');
	while(my $full_line = <FULL>){
	    chomp($full_line);
	    my @full_data = split("\t", $full_line); 
	    my $full_size = scalar(@full_data);
	    for(my $col=0; $col < $full_size+1; $col++){
		$full_ann ->write($full_row_num, $col, $full_data[$col], $full_format);
	    }
	    @full_data=();
	    $full_row_num++;
	}
	$full_ann_out -> close();
	close FULL;
	
	open(ORG, $full_ann_output) || die "cannot open ORG $full_ann_output to write\n";
	while(my $line = <ORG>){
	    my @line_arr = split(/\t/, $line);
	    if($line_arr[0] ~~ @all_pi){
		#print $line_arr[0]."\n";
	    }
	}
	close ORG;
	
	my @files = ($xl_file, $ind_ann_output, $tab_ann_output, $full_ann_output, $write_xl_path, $write_full_ann_path);
	foreach my $x ( @files){
	    my $string = $x;
#		    print "FILE:\t$x\n";
	    my $member = basename $string;
#		    print "BASE:\t$member\n";
	    $zip -> addFile($x, $member);
	}	
		
		#Save the Zip file
		#$dir should be directory where zip file will be saved
=d
		unless ( $zip->writeToFileNamed( $zip_name ) == 0 ) {
		    die 'write error';
		}
=cut
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#}

#Function returns only unique values of an array
sub uniq {
    return keys %{{ map { $_ => 1 } @_ }};
}
