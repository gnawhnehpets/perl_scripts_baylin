#!/usr/bin/perl

###Log
#12/5: fixed $no_ann_counter bug

###########################################################################
#NOTE: for Agilent expression summary xl files
#This script will parse excel files for annotation information (for backup 
#data from MA core) and search for files that have the matching array bar 
#code information and create an annotation.txt of all related files as well
#as annotation information of experiment. Final step is to create a .zip
#file containing all related files (annotation.txt, .xls file, data files)

#Use:
#1. Create `/all/` directory under pi name
#2. Change `$pi` to pi of interest for compression
#3. Run script
#4. Check `/all/summary/manual_data_lookup`
#5. Check all `no_data_matches` and `noanno` manually by searching for
#   barcode under `/array data file/Two color expression`
#6. Extract .zip file to `/pi/all/zip/` and fill in missing annotation and
#   save in extracted folder. Send a copy of annotation.txt to 
#   '/all/txt/manual/'
#7. Transfer data files into `/pi/all/zip/extracted_folder/`.
#8. Compress folder and make copy into `/pi/all/zip`, overwriting the
#   original file.

#
###########################################################################
use strict;
use warnings;
use Archive::Zip;
use Spreadsheet::ParseExcel;
use Spreadsheet::WriteExcel;
#Used in conjunction with Archive::Zip to remove extraneous subdirectories
use File::Basename 'basename';

my $pi = "Steve Baylin";


my $datatype = "array CGH worksheet/CGH array user/";

###########################################################################
=d
#Directory containing excel files of expression data output
my $xl_dir = "/home/steve/Desktop/MA_core_download/backup/agilent backup/array worksheet/Two color expression array worksheet/".$pi."/all/";

#Directory containing txt files (annotation of xl files)
my $txt_dir = "/home/steve/Desktop/MA_core_download/backup/agilent backup/array worksheet/Two color expression array worksheet/".$pi."/all/txt/";

#Directory that will contain final compressed files
my $zip_dir = "/home/steve/Desktop/MA_core_download/backup/agilent backup/array worksheet/Two color expression array worksheet/".$pi."/all/zip/"; 
=cut

=d
#Files to run script
> /agilent backup/array worksheet/array CGH worksheet/CGH array user/
  Baylin

> /agilent backup/array worksheet/Baylin array project sample sheet/
  /CGH/Baylin
  /Chip-chip/Baylin
  /Expression/everyone

> /agilent backup/array worksheet/chip-chip/
  Baylin

> /agilent backup/array worksheet/miRNA expression array worksheet/
  Barry Nelkin
  Nita Ahuja
  Robert Casero
  Steve Baylin

> /agilent backup/array worksheet/two color expression array/
  Nita Ahuja
  Cynthia Zahnow
=cut
my $dir = "/home/steve/Desktop/MA_core_download/backup/agilent backup/array worksheet/";
my $extension = $datatype."/".$pi."/all/";
my $xl_dir = $dir.$extension; #"/home/steve/Desktop/MA_core_download/backup/agilent backup/array worksheet/Two color expression array worksheet/".$pi."/all/";
my $txt_dir = $dir.$extension."txt/";#"/home/steve/Desktop/MA_core_download/backup/agilent backup/array worksheet/Two color expression array worksheet/".$pi."/all/txt/";
#ann.txt directory
my $xl_form_dir = $txt_dir."xlformatted/";
my $ann_dir = $txt_dir."ann/";
#>>>>>>>>>>>>
#my $zip_dir = $dir.$extension."zip/";
my $zip_dir = $txt_dir."zip/";

=d
opendir DIR, $xl_dir or die "cannot open dir $xl_dir: $!";
my @xl_file = readdir DIR;
closedir DIR;
=cut

#Directory containing all data files 
###################################################################################################################
my $data_dir = "/home/steve/Desktop/MA_core_download/backup/agilent backup/array data file/array CGH/";
###################################################################################################################
#my $data_dir = "/home/steve/Desktop/MA_core_download/backup/agilent backup/array data file/ChIP-chip/";
opendir DATA, $data_dir or die "cannot open dir $data_dir: $!";
my @data_file = readdir DATA;
closedir DATA;


###########################################################################
#Write to file
#Tab-delimited file
my $tab_output = $xl_dir."summary/tab_del_output.txt";
#Readable file; master annotation list of xl filenames, annotation, data files
my $master_output = $xl_dir."summary/master_output.txt";
#Open output file
#open(TAB, '>', $tab_output) || die "cannot open tab_del_output.txt\n";
open(MASTER, '>', $master_output) || die "cannot open $master_output\n";
print MASTER "###FORMATTING#####################################################\n";
print MASTER "> FILENAME\n";
print MASTER "USER:\t\tname of user who submitted sample\n";
print MASTER "PI:\t\tname of PI\n";
print MASTER "SUBMIT:\t\tdate of submitting samples\n";
print MASTER "SAMPLETYPE:\ttype of sample\n";
print MASTER "SAMPLENAME:\tname of sample\n";
print MASTER "SHIPDATE:\tdate array/sample was shipped\n";
print MASTER "USEDATE:\tdate array was used\n";
print MASTER "ARRAYTYPE:\tmodel of array\n";
print MASTER "BARCODE:\tbarcode of array, unique to submission\n";
print MASTER "BC_NO_FILE:\tbarcode that does not match to any data files\n";
print MASTER "ZIPLOC:\t\tlocation of compressed file\n";
print MASTER "FILE:\t\tname of data file found to match bar cdoe\n";
print MASTER "REGEX_DATA:\tcurrent data file being compressed\n";
print MASTER "REGEX_TXT:\tcurrent annotation.txt being compressed\n";
print MASTER "REGEX_XL:\tcurrent xl file being compressed\n\n";
print MASTER "###ANNOTATION#####################################################\n";
#Header information for tab-delimited file
#print TAB "#file_name\n";
#print TAB ">filename\tsubmitter\tpi\tsample_submision_date\tsample_type\tsample_description\tsample_process_date\tship_in_date\tuse_date\tarray_type\tarray_bar_code\tlot_number\tsap_id\tserial_number\n";
###########################################################################
my $i=0;

#Saves data file names for Archive::Zip
my @files_to_zip;
my $zip_count=0;

#Saves xl file names that do not have any file matches
my @xl_no_file;
my $info_count=0;

my $txt_file = "";

#Annotation counter; if $ann_counter<5, manual parsing required
my $ann_counter=0;
#Saves xl file names that do not have any annotation
my @no_annotation;
my $no_ann_counter = 0;
my $find_row_min = 0;
my $find_col_min = 0;

opendir DIR, $xl_dir or die "cannot open dir $xl_dir: $!";
my @xl_file = readdir DIR;
closedir DIR;

#Parse original xl files to format data into txt file
foreach my $dir_file(@xl_file){
	my $parser  = Spreadsheet::ParseExcel->new();
	#If it's an xl file...
	my $previous_row = 0;
	$find_row_min = 0;
	$find_col_min = 0;
	if($dir_file =~ m/(.*)\.xls$/){
	    my $file_prefix = $1;
	    #Print xl file name
	    print "> $dir_file\n";
	    print "FILEPREF:\t$file_prefix\n";
	    #Create annotation.txt file per xl file
	    $txt_file = $file_prefix."\.txt";
	    #Path to annotation.txt file
	    my $tab_output = $txt_dir.$file_prefix."_tab.txt";
	    open(TAB, '>>', $tab_output) || die "cannot open tab_output.txt\n";
	    #Parse xl file for annotation information
	    my $workbook = $parser->parse($xl_dir.$dir_file);
	    if ( defined $workbook ) {
		for my $worksheet ( $workbook->worksheets() ) {
		    my ( $row_min, $row_max ) = $worksheet->row_range();
		    my ( $col_min, $col_max ) = $worksheet->col_range();
		    
		    for my $row ( $row_min .. $row_max ) {
			for my $col ( $col_min .. $col_max ) {
			    my $cell = $worksheet->get_cell( $row, $col );
#			    next unless $cell; 

			    if($find_row_min == 0){
#>>>
				next unless $cell;
				my $set_row_min = $cell->value();		    
				if($set_row_min =~ /user\s+name/i){
				    $row_min = $row;
				    $find_row_min++;
				}
			    }			    
			    if($find_row_min != 0){
				if($find_col_min == 0){
				    my $set_col_min = $cell->value();
				    if($row == $row_min){
					if($set_col_min =~ /\S+/i){
					    $col_min = $col;
					    $find_col_min++;
					}
				    }
				}

				#Find values of cell...
				my $cell_val;
				if($cell){
				    $cell_val = $cell->value();
				}else{
				    $cell_val = "NA";
				}
				if($col != $col_max){
				    print TAB $cell_val."\t"; 
#				}else{
				}
				if($col == $col_max){
				    print TAB $cell_val."\n";
				}
			    }
			}
		    }
		}
	    }
	}
}

#open _tab.txt to parse
opendir TAB, $txt_dir or die "cannot open dir $data_dir: $!";
my @txt_file = readdir TAB;
closedir TAB;

#Parse txt file to create/write out to xl_formatted file
foreach my $t (@txt_file){
    if($t =~ /(.*)\_tab\.txt$/){
	my $file_prefix = $1;
	my $file_tab = $txt_dir.$t;
#	my $file_ann = $file_prefix."_ann.txt";
#	my $path_to_ann = $txt_dir.$file_ann;
	open(TAB, $file_tab) || die "cannot open file_tab.txt\n";
	my $xl_name = $xl_form_dir.$file_prefix."_formatted.xls";
	my $workbook = Spreadsheet::WriteExcel->new($xl_name);
	my $worksheet = $workbook->add_worksheet();
	my $format=$workbook->add_format();
	$format->set_color('red');
	$format->set_align('left');
	my $row = 0;
	while(<TAB>){
	    chomp;
	    my @line = split("\t", $_);
	    my $col = 0;
	    foreach my $val (@line){
		$worksheet->write($row, $col, $val);
		$col++;
	    }
	    $row++;
	    
	    
	    
#	    close ANN;
	}
	close TAB;
    }
}

#READ IN FORMATTED XL
opendir FXL, $xl_form_dir or die "cannot open dir $xl_dir: $!";
my @xl_form = readdir FXL;
closedir FXL;

my $pi_count;
my @no_pi;

#Find which original xl files do not contain pi_header
foreach my $f (@xl_form){
    if($f =~ /(.*)\_formatted\.xls$/){
	$pi_count=0;
#	@no_pi = ();
	my $parser  = Spreadsheet::ParseExcel->new();
	my $file_prefix = $1;
	#Print xl file name
	#Create annotation.txt file per xl file
	$txt_file = $file_prefix."\.txt";
	#Path to annotation.txt file
	my $tab_output = $txt_dir.$file_prefix."_tab.txt";
	open(TAB, '>>', $tab_output) || die "cannot open tab_output.txt\n";
	#Parse xl file for annotation information
	my $xl_file = $txt_dir.$f;
	print "XL $xl_file\n";
	my $workbook = $parser->parse($xl_file);
#	my $workbook = $parser->parse($xl_dir.$dir_file);
	if ( defined $workbook ) {
	    for my $worksheet ( $workbook->worksheets() ) {
		my ( $row_min, $row_max ) = $worksheet->row_range();
		my ( $col_min, $col_max ) = $worksheet->col_range();
		
		for my $row ( $row_min .. $row_max ) {
		    for my $col ( $col_min .. $col_max ) {
			my $cell = $worksheet->get_cell( $row, $col );
			next unless $cell; 
			my $cell_val = $cell->value();
			if($cell_val =~ /pi/i){
			    $pi_count++;
			}
		    }
		}
	    }
	}
	if($pi_count==0){
#	    print "NO PI HEADER: $f\n";
	    push(@no_pi, $f);
	}
    }
}

#Find all excel files that do not have pi_header
if(scalar(@no_pi) > 0){
    print "#####################################################################################\n";
    print "#####################################################################################\n";
    print "NO PI HEADER: \n";
    foreach my $n (@no_pi){
	if($n =~ /(.*)\_formatted/){
	    print $1.".xls\n";
	}
    }
    print "> add pi header to the original xl files, delete all txt files (/txt/), re-run script\n";
    print "#####################################################################################\n";
    print "#####################################################################################\n";
}else{
    print "> All excel files have pi header\n";
}


#Create annotation txt by parsing xl_formatted
my @user;
my @pi;
my @sampletype;
my @submitdate;
my @samplename;
my @shipdate;
my @usedate;
my @arraytype;
my @barcode;
my @description;
my @samplelabel;
my @no_bc = ();
foreach my $fxl (@xl_form){
    if($fxl =~ /(.*)\_formatted/){
	@user = ();
	@pi = ();
	@sampletype = ();
	@submitdate = ();
	@samplename = ();
	@shipdate = ();
	@usedate = ();
	@arraytype = ();
	@barcode = ();
	@description = ();
	@samplelabel = ();
	my $file_prefix = $1;
	my $xl_file = $xl_form_dir.$fxl;
#	print "X: $xl_file\n";
	my $parser  = Spreadsheet::ParseExcel->new();
	my $workbook = $parser->parse($xl_file);
	if ( defined $workbook ) {
	    for my $worksheet ( $workbook->worksheets() ) {
		my ( $row_min, $row_max ) = $worksheet->row_range();
		my ( $col_min, $col_max ) = $worksheet->col_range();
		
		for my $row ( $row_min .. $row_max ) {
		    for my $col ( $col_min .. $col_max ) {
			my $cell = $worksheet->get_cell( $row, $col );
			next unless $cell; 
			
			my $cell_val = $cell->value();
#user########################################################################
=d
			if($cell_val =~ /user/i){
			    my $user_row = $row+1;
			    for(my $i = $user_row; $i < $row_max; $i++){
				my $user = $worksheet -> get_cell($i, $col);
				next unless $user;
				my $user_val = $user->value();
				push(@user, $user_val);
			    }
			}
=cut

			if($cell_val =~ /user/i){
			    my $cell_row = $row+1;
			    for(my $i = $cell_row; $i < $row_max; $i++){
				my $cell = $worksheet -> get_cell($i, $col);
				next unless $cell;
				my $cell_val = $cell->value();
				push(@user, $cell_val);
			    }
			}

#pi########################################################################
			if($cell_val =~ /pi/i){
			    my $cell_row = $row+1;
			    for(my $i = $cell_row; $i < $row_max; $i++){
				my $cell = $worksheet -> get_cell($i, $col);
				next unless $cell;
				my $cell_val = $cell->value();
				push(@pi, $cell_val);
			    }
			}
#sample type###############################################################
			if($cell_val =~ /sample\s+type/i){
			    my $cell_row = $row+1;
			    for(my $i = $cell_row; $i < $row_max; $i++){
				my $cell = $worksheet -> get_cell($i, $col);
				next unless $cell;
				my $cell_val = $cell->value();
				push(@sampletype, $cell_val);
			    }
			}

#submit date ###############################################################
#			if($cell_val =~ /submit\s+date/i){
			if($cell_val =~ m/^sample\s+(rec\.)?(sent)?(send)?\s+date$/i){
			    my $cell_row = $row+1;
			    for(my $i = $cell_row; $i < $row_max; $i++){
				my $cell = $worksheet -> get_cell($i, $col);
				next unless $cell;
				my $cell_val = $cell->value();
				push(@submitdate, $cell_val);
			    }
			}
#samplename###############################################################
			if($cell_val =~ /sample\s+name/i){
			    my $cell_row = $row+1;
			    for(my $i = $cell_row; $i < $row_max; $i++){
				my $cell = $worksheet -> get_cell($i, $col);
				next unless $cell;
				my $cell_val = $cell->value();
				push(@samplename, $cell_val);
			    }
			}
#shipdate###############################################################
			if($cell_val =~ /ship.*date/i){
			    my $cell_row = $row+1;
			    for(my $i = $cell_row; $i < $row_max; $i++){
				my $cell = $worksheet -> get_cell($i, $col);
				next unless $cell;
				my $cell_val = $cell->value();
				push(@shipdate, $cell_val);
			    }
			}
			if($cell_val =~ /date.*ship/i){
			    my $cell_row = $row+1;
			    for(my $i = $cell_row; $i < $row_max; $i++){
				my $cell = $worksheet -> get_cell($i, $col);
				next unless $cell;
				my $cell_val = $cell->value();
				push(@shipdate, $cell_val);
			    }
			}
#usedate###############################################################
			if($cell_val =~ /use.*date/i){
			    my $cell_row = $row+1;
			    for(my $i = $cell_row; $i < $row_max; $i++){
				my $cell = $worksheet -> get_cell($i, $col);
				next unless $cell;
				my $cell_val = $cell->value();
				push(@usedate, $cell_val);
			    }
			}
			if($cell_val =~ /date.*use/i){
			    my $cell_row = $row+1;
			    for(my $i = $cell_row; $i < $row_max; $i++){
				my $cell = $worksheet -> get_cell($i, $col);
				next unless $cell;
				my $cell_val = $cell->value();
				push(@usedate, $cell_val);
			    }
			}

#arraytype###############################################################
#			if($cell_val =~ /arra?y/i){
			if($cell_val =~ m/^arr(a)?y\s+type$/i){
			    my $cell_row = $row+1;
			    for(my $i = $cell_row; $i < $row_max; $i++){
				my $cell = $worksheet -> get_cell($i, $col);
				next unless $cell;
				my $cell_val = $cell->value();
				push(@arraytype, $cell_val);
			    }
			}
#barcode###############################################################
			if($cell_val =~ m/.*array\s+(bar\s+)?code.*/i){
#			if($cell_val =~ /barcode/i){
			    my $cell_row = $row+1;
			    for(my $i = $cell_row; $i < $row_max; $i++){
				my $cell = $worksheet -> get_cell($i, $col);
				next unless $cell;
				my $cell_val = $cell->value();
				push(@barcode, $cell_val);
			    }
			}

#description###############################################################
			if($cell_val =~ m/.*description.*/i){
			    my $cell_row = $row+1;
			    for(my $i = $cell_row; $i < $row_max; $i++){
				my $cell = $worksheet -> get_cell($i, $col);
				next unless $cell;
				my $cell_val = $cell->value();
				push(@description, $cell_val);
			    }
			}

#sample label###############################################################
			if($cell_val =~ m/sample\s+label/i){
			    my $cell_row = $row+1;
			    for(my $i = $cell_row; $i < $row_max; $i++){
				my $cell = $worksheet -> get_cell($i, $col);
				next unless $cell;
				my $cell_val = $cell->value();
				push(@samplelabel, $cell_val);
			    }
			}
		    }
		}
	    }
	}
	print "> $fxl\n";
	@pi = uniq(@pi);
	@user = uniq(@user);
	@sampletype = uniq(@sampletype);
	@submitdate = uniq(@submitdate);
	@samplename = uniq(@samplename);
	@shipdate = uniq(@shipdate);
	@usedate = uniq(@usedate);
	@arraytype = uniq(@arraytype);
	@barcode = uniq(@barcode);
	@description = uniq(@description);
	@samplelabel = uniq(@samplelabel);
	my $ann_txt = $ann_dir.$file_prefix."_ann.txt";

	#CREATE ANN.TXT
	open(ANN, '>', $ann_txt) || die "cannot open ann.txt\n";
	foreach my $u (@user){
#	    print "USER:\t\t".$u."\n";
	    print ANN "USER:\t\t".$u."\n";
	}
	foreach my $p (@pi){
#	    print "PI:\t\t".$p."\n";
	    print ANN "PI:\t\t".$p."\n";
	}
	foreach my $st (@sampletype){
#	    print "SAMPLE_TYPE:\t".$st."\n";
	    print ANN "SAMPLE_TYPE:\t".$st."\n";
	}
	foreach my $sn (@samplename){
#	    print "SAMPLE_NAME:\t".$sn."\n";
	    print ANN "SAMPLE_NAME:\t".$sn."\n";
	}
	foreach my $sl (@samplelabel){
#	    print "SAMPLE_LABEL:\t".$sl."\n";
	    print ANN "SAMPLE_LABEL:\t".$sl."\n";
	}
	foreach my $d (@description){
#	    print "DESCRIPTION:\t".$d."\n";
	    print ANN "DESCRIPTION:\t".$d."\n";
	}
	foreach my $su (@submitdate){
#	    print "SUBMIT:\t\t".$su."\n";
	    print ANN "SUBMIT:\t\t".$su."\n";
	}
	foreach my $sh (@shipdate){
#	    print "SHIPDATE:\t".$sh."\n";
	    print ANN "SHIPDATE:\t".$sh."\n";
	}
	foreach my $ud (@usedate){
#	    print "USEDATE:\t".$ud."\n";
	    print ANN "USEDATE:\t".$ud."\n";
	}
	foreach my $at (@arraytype){
#	    print "ARRAYTYPE:\t".$at."\n";
	    print ANN "ARRAYTYPE:\t".$at."\n";
	}
	foreach my $bc (@barcode){
	    print "BARCODE:\t".$bc."\n";
	    print ANN "BARCODE:\t".$bc."\n";
	}

	#find all data files that match the barcodes and save names of those files
	my @files_to_zip;
	#from $data_dir
	foreach my $filename (@data_file){
	    foreach my $bc (@barcode){
		if($filename =~ m/^(copy of )?jhu\_?($bc)/i){
		    print "FILE:\t\t$filename\n";
		    print ANN "FILE:\t\t$filename\n";
		    $filename = $data_dir.$filename;
		    push(@files_to_zip, $filename);
		}
	    }
	}
	#File path to where zip files will be created
	my $zip_name = $zip_dir.$file_prefix.".zip";

	opendir ANT, $ann_dir or die "cannot open dir $data_dir: $!";
	my @ann_file = readdir ANT;
	closedir ANT;
	
	#add txt/annotation file
	foreach my $ann (@ann_file){
	    if($ann =~ /($file_prefix)\_ann\.txt/i){
#		print "TEXT: ".$ann."\n";
		$ann = $ann_dir.$ann;
		push(@files_to_zip, $ann);
	    }
	}
	
	foreach my $form (@xl_form){
	    if($form =~ /($file_prefix)\_formatted\.xls/i){
		$form = $xl_form_dir.$form;
		push(@files_to_zip, $form);
#		print "XLLL: $form\n";
	    }
	}

	foreach my $orig (@xl_file){
	    if($orig =~ /($file_prefix)\.xls/i){
		$orig = $txt_dir.$orig;
		push(@files_to_zip, $orig);
#		print "ORIG: $orig\n";
	    }
	}

#COMPRESS FILES
	my $zip = Archive::Zip->new();
	my $string = "";
	foreach my $files (@files_to_zip){
	    #add files from disk
	    #if txt file, then path to ann
	    my $member = basename $string;
	    $zip -> addFile($string, $member);   
	    print "CONTENTS: $files\n";
	}
	
=d       
	#Save the zip file
	unless ( $zip->writeToFileNamed( $zip_name ) == 0 ) {
	    die 'write error';
	}
=cut	
	
    
	#Find xl files that do not contain barcodes
	my $original = $file_prefix.".xls";
	if(@barcode){
	}else{
	    push(@no_bc, $original);
	}
	
	if(@no_bc){
	    print "FILES WITH NO BC: \n";
	    foreach my $nb (@no_bc){
		print "NO BC: $nb\n";
	    }
	}
    }
}    
#my $ind_output = $txt_dir.$file_prefix.".txt";
#open(IND, '>', $ind_output) || die "cannot open ind_output.txt\n";
    
=d
###########################################################################
#pi
			    if($cell_val =~ m/^pi/i){
###########################################################################
#user
			    if($cell_val =~ m/(user)\s+/i){
###########################################################################
#array_type
			    if($cell_val =~ m/^arr(a)?y\s+type$/i){
###########################################################################
#submit_date
			    if($cell_val =~ m/^sample\s+(rec\.)?(sent)?(send)?\s+date$/i){
###########################################################################
#sample type
			    if($cell_val =~ m/^sample\s+type$/i){
###########################################################################
#sample description
			    if($cell_val =~ m/.*description.*/i){
###########################################################################
#ship-in date
			    if($cell_val =~ m/^(array\s+)?ship.*date$/i){
###########################################################################
#use date
			    if($cell_val =~ m/^(array\s+)?use.*date$/i){
###########################################################################
#sample name
			    if($cell_val =~ m/^sample\s+name/i){
###########################################################################
#array bar code
			    if($cell_val =~ m/.*array\s+(bar\s+)?code.*/i){
###########################################################################
#save xl files with no data file matches
				#Save xl file names that do not have any txt/pdf file hits
				if(@array_bar_code){
				}else{
				    $xl_no_file[$info_count]=$dir_file;
				    $info_count++;
				}
				#print unique bar code
				foreach my $x (@array_bar_code){
				    print "BARCODE:\t$x\n";
				    print MASTER "BARCODE:\t$x\n";
				    print IND "BARCODE:\t$x\n";
				    $ann_counter++;
				}
##########################################################################
#save bar codes that have data file matches
				#Barcode that has file matches
				my @bc_matches;
				my $count_bc_matches=0;
				#Barcodes that do not have file matches
				my @bc_no_matches;

				#For every data file (array data)...
				foreach my $filename (@data_file){
				    #For every unique array bar code (from xl file)...
				    foreach my $bar_code (@array_bar_code){
					#If data file name contains a unique bar code...
					if($filename =~ m/^(copy of )?jhu\_?($bar_code)/i){
					    print MASTER "FILENAME:\t$filename\n";
#FILENAME TEST
					    print IND "FILE:\t\t$filename\n";
					    #Save filename to zip later
					    $files_to_zip[$zip_count]=$filename;
					    $zip_count++;
					    #Save bar code with matches
					    $bc_matches[$count_bc_matches]=$bar_code;
					    $count_bc_matches++;
					}
				    }
				}
				@bc_matches = uniq(@bc_matches);
##########################################################################
#identify bar codes that do not have data file matches. bc_no_matches
#stores non common files between array_bar_code & bc_matches (aka bar 
#codes that do not have file matches
				@bc_no_matches = diff(\@array_bar_code, \@bc_matches);
			
				#Print barcodes that do not have any matched files
				foreach my $x(@bc_no_matches){
				    print "BC_NO_FILE:\t$x\n";
				    print MASTER "BC_NO_FILE:\t$x\n";
				    print IND "BC_NO_FILE:\t$x\n";
				}

=cut

=d
##########################################################################
#prep files for file compression
				print "\n";
				print MASTER "\n";
				print IND "\n";
				my $string="";
				#File path to where zip files will be created
				my $zip_name = $zip_dir.$file_prefix."\.zip";
				print "ZIPLOC:\t$zip_name\n";
				#Add txt/annotation file
				push(@files_to_zip,$txt_file);
				#Add excel file
				push(@files_to_zip, $dir_file);
				foreach my $x(@files_to_zip){
				    print "FILE: $x\n";
				}		
				#reset
				@array_bar_code=();
##########################################################################
#compress files
				#need to close annotation.txt in order to write
				close IND;
#START

				my $zip = Archive::Zip->new();
				foreach my $i (@files_to_zip){
				    #Add files from disk
				    #If txt file name, then path to txt file
				    if($i =~ /($file_prefix)\.txt/i){
					print "REGEX_TXT:\t$i\n";
					$string = $txt_dir.$i;
				    #If xl file name, then path to xl file
				    }elsif($i =~ /\.xls$/i){
					print "REGEX_XL:\t$i\n";
					$string = $xl_dir.$i;
				    #If all other files, then path to data files
				    }else{
					print "REGEX_DATA:\t$i\n";
					#$dir should be directory containing data files
					$string = $data_dir.$i;
				    }
				    
				    my $member = basename $string;
				    #$zip->addFile( $string );
				    #Only keep basename and remove unnecessary subdirs
				    $zip -> addFile($string, $member);
				    #Save the Zip file
=d
				    #$dir should be directory where zip file will be saved
				    unless ( $zip->writeToFileNamed( $zip_name ) == 0 ) {
					die 'write error';
				    }
=cut
=d
				}

#END
				#######	
				if($ann_counter<5){
				    $no_annotation[$no_ann_counter]=$dir_file;
				    $no_ann_counter++;
				}
				#######

##########################################################################
				#reset
				@files_to_zip=();
			    }
			}
		    }
		}
	    }
	}
	#reset
	$txt_file="";
	$dir_file="";
	$ann_counter=0;
#	$no_ann_counter=0;
	print "\n\n";
}


#Print out excel files that do not have any regex matches to files (pdf/txt)
my $no_matches_dir = $xl_dir."summary/manual_data_lookup.txt";
open(MANUAL, '>', $no_matches_dir) || die "cannot open $no_matches_dir\n";
print "###################################################################\n";
print "> excel files that do not have any regex matches to files (pdf/txt)\n";
print MANUAL "> excel files that do not have any regex matches to files (pdf/txt)\n";
foreach my $s(@xl_no_file){
    print "NOINFO:\t$s\n";
    print MANUAL "NO_DATA_MATCHES:\t$s\n";    
}
print "### manual regex/search necessary ###\n\n";
print MANUAL "### manual regex/search necessary ###\n\n";

#Print out all file names that have very little annotation
foreach my $n(@no_annotation){
    print "NOANNO:\t$n\n";
    print MANUAL "NOANNO:\t\t\t$n\n";
}

close MANUAL;
#close TAB;
close MASTER;
=cut


#Function returns only unique values of an array
    sub uniq {
    return keys %{{ map { $_ => 1 } @_ }};
}

#Function finds differences between two arrays
sub diff {
    my %hash = map{ $_=>1} @{$_[1]}; 
    return grep { !defined $hash{$_} }  @{$_[0]};
}
