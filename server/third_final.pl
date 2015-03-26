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
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
my $expt_dir = $dir_fullann."indy/";
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#print "DIRFULLAN: $dir_fullann\n";
opendir(EX, $expt_dir) or die "cannot open exptdir";
my @ex = readdir EX;
closedir EX;
my $counter =0;
#filename = $file, no path
foreach my $expt (@ex){
#    if($file =~ /^(\S+)\-.*\.txt$/){
#    if($ex =~ /^\w+.*\.txt$/){
    my @barcode = ();
    if($expt =~ /(.*)\.txt$/){
#	print $ex."\n";
#	$counter++;
	my $file_prefix = $1;
#	print $file_prefix."\n";
	#Archive::Zip object
	my $zip = Archive::Zip -> new();
	my $zip_name = $expt_dir.$file_prefix."\.zip";
#	print $zip_name."\n";
	#experiment text file
	my $expt_file = $expt_dir.$expt;

	#get unique barcode from each file
	open(EXP, $expt_file) || die "cannot open experiment.txt\n";
	while(my $entry = <EXP>){
	    #print $entry."\n";
	    my @line = split("\t", $entry);
#	    print $line[35]."\n";
	    push(@barcode, $line[35]);
	}
	close(EXP);
	@barcode = uniq(@barcode);
	print "FILE: $expt\n";
	foreach my $bcode (@barcode){
	    print "BARCODE $bcode\n";
=d
	    my $datadir = $m450_data_dir.$bcode;
	    my $member = basename $datadir;
	    $zip -> addTree($datadir, $member);
=cut
	    my $fourdatadir = $m450_data_dir.$bcode;
	    my $twodatadir = $m27_data_dir.$bcode;
	    my $fourmember = basename $fourdatadir;
	    my $twomember = basename $twodatadir;
	    $zip -> addTree($fourdatadir, $fourmember);
	    $zip -> addTree($twodatadir, $twomember);
#=cut
	}
#	my @files = ($xl_file, $ind_ann_output, $tab_ann_output, $full_ann_output, $write_xl_path, $write_full_ann_path);
	my @files = ($expt_file);
	foreach my $x ( @files){
	    my $string = $x;
#		    print "FILE:\t$x\n";
	    my $member = basename $string;
#		    print "BASE:\t$member\n";
	    $zip -> addFile($x, $member);
	}	
	
	#Save the Zip file
	#$dir should be directory where zip file will be saved
	
	unless ( $zip->writeToFileNamed( $zip_name ) == 0 ) {
	    die 'write error';
	}
    }
}
#print "COUNTER: $counter\n";


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
