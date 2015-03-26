#!/usr/bin/perl

###########################################################################
#NOTE: for Agilent expression summary xl files
#This script will parse excel files for annotation information (for backup 
#data from MA core) and search for files that have the matching array bar 
#code information and create an annotation.txt of all related files as well
#as annotation information of experiment. Final step is to create a .zip
#file containing all related files (annotation.txt, .xls file, data files)

#Use:
#1. Create `/all/` directory under pi name

#2. Create the following subdir
#   - /pi/all/txt/ann/ - contains ann.txt
#   - /pi/all/txt/zip/ - contains .zip files
#   - /pi/all/txt/summary/ - contains masteroutput.txt

#3. Transfer all xl files for pi&array into '/all/'

#4. cp agilent.backup.pl array-pi.pl

#5. In array-pi.pl, change $pi to your pi of interest

#6. In array-pi.pl, change $datatype to '/array/' directory
#   - /CGH array/

#7. In array-pi.pl, change $data_dir to '/array data file/array/'
#   - /array data file/CGH array/

#8. Run array-pi.pl & make sure all excel files have 'pi' header in original excel
###########################################################################
use strict;
use warnings;
use Archive::Zip;
use Spreadsheet::ParseExcel;
use Spreadsheet::WriteExcel;
#Used in conjunction with Archive::Zip to remove extraneous subdirectories
use File::Basename 'basename';

#####   CHANGE THIS   #####

my $pi = "Steve Baylin";
#agilent backup/array worksheet/##########
my $datatype = "miRNA expression array worksheet/";
my $data_dir = "/home/steve/Desktop/MA_core_download/backup/agilent backup/array data file/miRNA array/";
###########################
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
my $xl_dir = $dir.$extension;
my $txt_dir = $dir.$extension."txt/";
my $xl_form_dir = $txt_dir."xlformatted/";
my $ann_dir = $txt_dir."ann/";
my $zip_dir = $txt_dir."zip/";

opendir DATA, $data_dir or die "cannot open dir $data_dir: $!";
my @data_file = readdir DATA;
closedir DATA;

#Readable file; master annotation list of xl filenames, annotation, data files
my $master_output = $txt_dir."summary/master_output.txt";
open(MASTER, '>', $master_output) || die "cannot open $master_output\n";
print MASTER "########################   FORMATTING   ################################\n\n";
print MASTER "#############   FILENAME  #####\n";
print MASTER "USER:\t\tname of user who submitted sample\n";
print MASTER "PI:\t\tname of PI\n";
print MASTER "SUBMIT:\t\tdate samples were submitted\n";
print MASTER "SAMPLE_TYPE:\ttype of sample\n";
print MASTER "SAMPLE_NAME:\tname of sample\n";
print MASTER "SAMPLE_LABEL:\taka 'SAMPLE_NAME'\n";
print MASTER "SHIPDATE:\tdate array was shipped\n";
print MASTER "USEDATE:\tdate array was used\n";
print MASTER "ARRAYTYPE:\tmodel of array\n";
print MASTER "BARCODE:\tbarcode of array, unique to submission\n";
print MASTER "ZIP:\t\tlocation of compressed file\n";
print MASTER "FILE:\t\tname of data file found to match bar code\n";
print MASTER "BC_NO_FILE:\tbarcode that does not match to any data files\n\n";
print MASTER "########################   ANNOTATION   ################################\n";

my $i=0;
#Saves data file names for Archive::Zip
my @files_to_zip;

#Saves xl file names that do not have any file matches
my @xl_no_file;
my $info_count=0;

my $txt_file = "";
#Used to generate xl_formatted.xls
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
#	    print "> $dir_file\n";
#	    print MASTER "> $dir_file\n";
#	    print "FILEPREF:\t$file_prefix\n";
	    #Create annotation.txt file per xl file
	    $txt_file = $file_prefix."\.txt";
	    #Path to annotation.txt file
	    my $tab_output = $txt_dir.$file_prefix."_tab.txt";
	    open(TAB, '>>', $tab_output) || die "cannot open tab_output.txt\n";
	    #Parse xl file for annotation information
	    my $workbook = $parser->parse($xl_dir.$dir_file);
	    if ( defined $workbook ) {
		my $worksheet = $workbook->worksheet(0);
#		for my $worksheet ( $workbook->worksheets() ) {
		my ( $row_min, $row_max ) = $worksheet->row_range();
		my ( $col_min, $col_max ) = $worksheet->col_range();
		    
		for my $row ( $row_min .. $row_max ) {
		    for my $col ( $col_min .. $col_max ) {
			my $cell = $worksheet->get_cell( $row, $col );
			if($find_row_min == 0){
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
				$cell_val = "";
			    }
			    if($col != $col_max){
				print TAB $cell_val."\t"; 
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

#open _tab.txt to parse
opendir TAB, $txt_dir or die "cannot open dir $data_dir: $!";
my @txt_file = readdir TAB;
closedir TAB;

#Parse txt file to create/write out to xl_formatted file
foreach my $t (@txt_file){
    if($t =~ /(.*)\_tab\.txt$/){
	my $file_prefix = $1;
	my $file_tab = $txt_dir.$t;
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
	my $parser  = Spreadsheet::ParseExcel->new();
	my $file_prefix = $1;
	#Print xl file name
	#Create annotation.txt file per xl file
	$txt_file = $file_prefix."\.txt";
	#Path to annotation.txt file
	my $tab_output = $txt_dir.$file_prefix."_tab.txt";
	open(TAB, '>>', $tab_output) || die "cannot open tab_output.txt\n";
	#Parse xl file for annotation information
	my $xl_file = $xl_form_dir.$f;
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
			if($cell_val =~ /pi/i){
			    $pi_count++;
			}
		    }
		}
	    }
	}
	if($pi_count==0){
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
			    my $cell_row = $row+1;
			    for(my $i = $cell_row; $i < $row_max; $i++){
				my $cell = $worksheet -> get_cell($i, $col);
				next unless $cell;
				my $cell_val = $cell->value();
#				push(@barcode, $cell_val);
				if($cell_val =~ /(\d+)/){
				    push(@barcode, $1);
				}
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
	print MASTER "\n";
	print MASTER "#############   $fxl   ######\n";
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
	    print "USER:\t\t".$u."\n";
	    print ANN "USER:\t\t".$u."\n";
	    print MASTER "USER:\t\t".$u."\n";
	}
	foreach my $p (@pi){
	    print "PI:\t\t".$p."\n";
	    print ANN "PI:\t\t".$p."\n";
	    print MASTER "PI:\t\t".$p."\n";
	}
	foreach my $st (@sampletype){
	    print "SAMPLE_TYPE:\t".$st."\n";
	    print ANN "SAMPLE_TYPE:\t".$st."\n";
	    print MASTER "SAMPLE_TYPE:\t".$st."\n";
	}
	foreach my $sn (@samplename){
	    print "SAMPLE_NAME:\t".$sn."\n";
	    print ANN "SAMPLE_NAME:\t".$sn."\n";
	    print MASTER "SAMPLE_NAME:\t".$sn."\n";
	}
	foreach my $sl (@samplelabel){
	    print "SAMPLE_LABEL:\t".$sl."\n";
	    print ANN "SAMPLE_LABEL:\t".$sl."\n";
	    print MASTER "SAMPLE_LABEL:\t".$sl."\n";
	}
	foreach my $d (@description){
	    print "DESCRIPTION:\t".$d."\n";
	    print ANN "DESCRIPTION:\t".$d."\n";
	    print MASTER "DESCRIPTION:\t".$d."\n";
	}
	foreach my $su (@submitdate){
	    print "SUBMIT:\t\t".$su."\n";
	    print ANN "SUBMIT:\t\t".$su."\n";
	    print MASTER "SUBMIT:\t\t".$su."\n";
	}
	foreach my $sh (@shipdate){
	    print "SHIPDATE:\t".$sh."\n";
	    print ANN "SHIPDATE:\t".$sh."\n";
	    print MASTER "SHIPDATE:\t".$sh."\n";
	}
	foreach my $ud (@usedate){
	    print "USEDATE:\t".$ud."\n";
	    print ANN "USEDATE:\t".$ud."\n";
	    print MASTER "USEDATE:\t".$ud."\n";
	}
	foreach my $at (@arraytype){
	    print "ARRAYTYPE:\t".$at."\n";
	    print ANN "ARRAYTYPE:\t".$at."\n";
	    print MASTER "ARRAYTYPE:\t".$at."\n";
	}
	foreach my $bc (@barcode){
	    print "BARCODE:\t".$bc."\n";
	    print ANN "BARCODE:\t".$bc."\n";
	    print MASTER "BARCODE:\t".$bc."\n";
	}

	#find all data files that match the barcodes and save names of those files
	my @files_to_zip;
	#File path to where zip files will be created
	my $zip_name = $zip_dir.$file_prefix.".zip";
	print MASTER "ZIP:\t\t$zip_name\n";

	#from $data_dir
	foreach my $filename (@data_file){
	    foreach my $bc (@barcode){
#		if($filename =~ m/^(copy of )?jhu\_?($bc)/i){
		if($filename =~ /($bc)/){
		    print "FILE:\t\t$filename\n";
		    print ANN "FILE:\t\t$filename\n";
		    print MASTER "FILE:\t\t$filename\n";
		    my $path_to_file = $data_dir.$filename;
		    push(@files_to_zip, $path_to_file);
		}
	    }
	}
	close ANN;
=d
	#File path to where zip files will be created
	my $zip_name = $zip_dir.$file_prefix.".zip";
	print MASTER "ZIP:\t\t$zip_name\n";
=cut
	opendir ANT, $ann_dir or die "cannot open dir $data_dir: $!";
	my @ann_file = readdir ANT;
	closedir ANT;
	
	#add txt/annotation file
	foreach my $ann (@ann_file){
	    if($ann =~ /($file_prefix)\_ann\.txt/i){
#		print "TEXT: ".$ann."\n";
		my $path_to_ann = $ann_dir.$ann;
		push(@files_to_zip, $path_to_ann);
	    }
	}
	
	foreach my $form (@xl_form){
	    if($form =~ /($file_prefix)\_formatted\.xls/i){
		my $path_to_form = $xl_form_dir.$form;
		push(@files_to_zip, $path_to_form);
#		print "XLLL: $form\n";
	    }
	}

	foreach my $orig (@xl_file){
	    if($orig =~ /($file_prefix)\.xls/i){
		my $path_to_orig = $xl_dir.$orig;
		push(@files_to_zip, $path_to_orig);
#		print "ORIG: $orig\n";
	    }
	}

#prepare files to be archived
	my $zip = Archive::Zip->new();
	my $string = "";
	foreach my $file (@files_to_zip){
	    #add files from disk
	    #if txt file, then path to ann
	    $string = $file;
	    my $member = basename $string;
#	    print "MEMBER: $member\n";
	    $zip -> addFile($string, $member);   
#	    print "CONTENTS: $file\n";
	}

#Zip files
#START#######################################################

	#Save the zip file
	unless ( $zip->writeToFileNamed( $zip_name ) == 0 ) {
	    die 'write error';
	}

#END#########################################################
  
	#Find xl files that do not contain barcodes
	my $original = $file_prefix.".xls";
	if(@barcode){
	}else{
	    push(@no_bc, $original);
	}
	
	if(@no_bc){
	    print "FILES WITH NO BC: \n";
	    print MASTER "FILES WITH NO BC: \n";
	    foreach my $nb (@no_bc){
		print "BC_NO_FILE:\t$nb\n";
		print MASTER "BC_NO_FILE:\t$nb\n";
	    }
	}
    }
}    

close MASTER;

#Function returns only unique values of an array
    sub uniq {
    return keys %{{ map { $_ => 1 } @_ }};
}

#Function finds differences between two arrays
sub diff {
    my %hash = map{ $_=>1} @{$_[1]}; 
    return grep { !defined $hash{$_} }  @{$_[0]};
}
