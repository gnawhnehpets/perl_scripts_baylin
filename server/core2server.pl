#!/usr/bin/perl

##########################################################################
# Script processes Agilent files uploaded to MA_core portal and prepares
# files for upload to file server

# 1. Download all Agilent files; transfer files from /home/steve/Downloads
#    to /home/steve/Downloads/pi/agilent
# 2. Run core2agilentserv_pi1.pl, select # next to task needed
# 3. Necessary QC steps
#    - after task#1: if xl files are missing, take note, inquire Wayne
#    - after task#2: if xl file missing pi_header, add to original xl_file

##########################################################################
use strict;
use warnings;
#use Archive::Zip;
use Archive::Zip qw( :ERROR_CODES );
use Spreadsheet::ParseExcel;
use Spreadsheet::WriteExcel;
use File::Basename 'basename';

print "task:\n";
print "1. make sure zip files have xl files\n";
print "2. make sure xl files have pi header\n";
print "3. create ann.txt, master_output.txt\n";
print "4. zip up ann.txt, formatted.xls\n";

my $selection = <STDIN>;
chomp($selection);

my $dir = "/home/steve/Downloads/cz/";#sb/agilent/";

if($selection == 1){
    opendir DIR, $dir or die "cannot open dir $dir: $!";
    my @file= readdir DIR;
    closedir DIR;
    
    my $i=0;
    foreach my $dir_file(@file){
	if($dir_file =~ /(.*)\.zip/){
	    my $file_prefix = $1;
	    my $find_row_min = 0;
	    my $find_col_min = 0;
#	print $dir_file."\n"; #print name of zip file
	    
	    my $parser  = Spreadsheet::ParseExcel->new();
	    my $zipFile = Archive::Zip->new();
	    my $xl_file = "";
	    # open zip file; read(directory+filename.zip);
	    $zipFile->read( $dir.$dir_file ) == 0 || die "cannot read $dir_file\n";
	    # if xl_counter==0, zip file does not have excel file
	    my @no_xl;
	    my $xl_counter=0;
	    # get all filenames within zip file
	    my @files = $zipFile -> memberNames( $dir.$dir_file );
	    foreach my $file (sort @files) {
		#find all excel files
		if($file =~ m/(.*xls?)/){
		    my $tab_output = $dir.$file_prefix."_tab.txt";
		    open(TAB, '>', $tab_output) || die "cannot open tab_output.txt\n";
		    #if excel file is found within zip, print name of zip file and $xl_counter++
		    $xl_counter++;
		    $xl_file = $1;
		    print "#    excel file found    # in: $dir_file\n";
		    #get contents of compressed file as a string
		    my $xls_content = $zipFile->contents($file);
		    #pass string as a reference and parse 
		    my $workbook = $parser->parse(\$xls_content);
####
		    for my $worksheet($workbook -> worksheets()){
		    my ( $row_min, $row_max) = $worksheet -> row_range();
		    my ( $col_min, $col_max) = $worksheet -> col_range();
		    
		    for my $row ( $row_min .. $row_max ) {
			for my $col ( $col_min .. $col_max ) {
			    my $cell = $worksheet->get_cell( $row, $col );
			    if($find_row_min == 0){
				next unless $cell;
				my $set_row_min = $cell->value();		    
#				print $set_row_min."\n";
				#if($set_row_min =~ /user\s+name/i){
				if($set_row_min =~ /(user$)|(user\s+name)/i){
				    if($set_row_min !~ /information/i){
#					print "SETROWMIN: ".$set_row_min."\n";
					$row_min = $row;
					$find_row_min++;
				    }
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
#				    print $cell_val."\t"; 
				    print TAB $cell_val."\t";
				}
				if($col == $col_max){
#				    print $cell_val."\n";
				    print TAB $cell_val."\n";
				}
			    }
			}
		    }
		    }
		    close(TAB);
		}
	    }
	    if($xl_counter==0){
		$no_xl[$i]=$dir_file;
		$i++;
		print "#----no excel found------# in: $dir_file\n";
	    }
	}
    }
}

elsif($selection == 2){
#open _tab.txt to parse
    opendir TABFOR, $dir or die "cannot open dir $dir: $!";
    my @txt_file = readdir TABFOR;
    closedir TABFOR;
    
#Parse txt file to create/write out to xl_formatted file
    foreach my $t (@txt_file){
	if($t =~ /(.*)\_tab\.txt$/){
	    my $file_prefix = $1;
	    my $file_tab = $dir.$t;
	    open(FTAB, $file_tab) || die "cannot open file_tab.txt\n";
	    my $xl_name = $dir.$file_prefix."_formatted.xls";
	    my $workbook = Spreadsheet::WriteExcel->new($xl_name);
	    my $worksheet = $workbook->add_worksheet();
	    my $format=$workbook->add_format();
	    $format->set_color('red');
	    $format->set_align('left');
	    my $row = 0;
	    while(<FTAB>){
		chomp;
		my @line = split("\t", $_);
		my $col = 0;
		foreach my $val (@line){
		    $worksheet->write($row, $col, $val);
		    $col++;
		}
		$row++;
	    }
	    close FTAB;
	}
    }
    
##################################
    
#READ IN FORMATTED XL
    opendir FXL, $dir or die "cannot open dir $dir: $!";
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
	    #Parse xl file for annotation information
	    my $xl_file = $dir.$f;
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
}elsif($selection == 3){
#######################################################################################
    #Readable file; master annotation list of xl filenames, annotation, data files
    my $master_output = $dir."master_output.txt";
    open(MASTER, '>', $master_output) || die "cannot open $master_output\n";
    print MASTER "########################   FORMATTING   ################################\n\n";
    print MASTER "#############   FILENAME  #####\n";
    print MASTER "USER:\tname of user who submitted sample\n";
    print MASTER "PI:\tname of PI\n";
    print MASTER "SUBMIT:\tdate samples were submitted\n";
    print MASTER "SAMPLE_TYPE:\ttype of sample\n";
    print MASTER "SAMPLE_NAME:\tname of sample\n";
    print MASTER "SAMPLE_LABEL:\taka 'SAMPLE_NAME'\n";
    print MASTER "SHIPDATE:\tdate array was shipped\n";
    print MASTER "USEDATE:\tdate array was used\n";
    print MASTER "ARRAYTYPE:\tmodel of array\n";
    print MASTER "BARCODE:\tbarcode of array, unique to submission\n";
#    print MASTER "ZIP:\tlocation of compressed file\n";
    print MASTER "FILES:\tALL FILES CURRENTLY INCLUDED IN ZIP FILE\n\n";
    print MASTER "########################   ANNOTATION   ################################\n";

    print "GROUP 3\n";
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

    #Filenames
    opendir FXL, $dir or die "cannot open dir $dir: $!";
    my @xl_form = readdir FXL;
    closedir FXL;

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
	    my $xl_file = $dir.$fxl;
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
=d
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
=cut
	    my %pi_seen;
	    my %user_seen;
	    my %sampletype_seen;
	    my %submitdate_seen;
	    my %samplename_seen;
	    my %shipdate_seen;
	    my %usedate_seen;
	    my %arraytype_seen;
	    my %barcode_seen;
	    my %description_seen;
	    my %samplelabel_seen;
	    my %barcode_seen;
	    @pi = grep { ! $pi_seen{$_}++ } @pi;
	    @user = grep { ! $user_seen{$_}++ } @user;
	    @sampletype = grep { ! $sampletype_seen{$_}++ } @sampletype;
	    @submitdate = grep { ! $submitdate_seen{$_}++ } @submitdate;
	    @shipdate = grep { ! $shipdate_seen{$_}++ } @shipdate;
	    @usedate = grep { ! $usedate_seen{$_}++ } @usedate;
	    @arraytype = grep { ! $arraytype_seen{$_}++ } @arraytype;
	    @barcode = grep { ! $barcode_seen{$_}++ } @barcode;
	    @samplename = grep { ! $samplename_seen{$_}++ } @samplename;
	    @description = grep { ! $description_seen{$_}++ } @description;
	    @samplelabel = grep {! $samplelabel_seen{$_}++ } @samplelabel;
	    my $ann_txt = $dir.$file_prefix."_ann.csv";
	    
	    #CREATE ANN.TXT
	    open(ANN, '>', $ann_txt) || die "cannot open ann.txt\n";
	    foreach my $u (@user){
		print "USER:\t\t".$u."\n";
		print ANN "USER:\t".$u."\n";
		print MASTER "USER:\t".$u."\n";
	    }
	    foreach my $p (@pi){
		print "PI:\t\t".$p."\n";
		print ANN "PI:\t".$p."\n";
		print MASTER "PI:\t".$p."\n";
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
		print ANN "SUBMIT:\t".$su."\n";
		print MASTER "SUBMIT:\t".$su."\n";
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
	}
    }
    close(MASTER);
}elsif($selection == 4){
    print "GROUP 4\n";
####################################################################################################################################################
=d
use strict;
use warnings;
use Archive::Zip qw( :ERROR_CODES );
use File::Basename 'basename';
#######################################################
# This script adds file to an already existing zip file
#######################################################

my $zip = Archive::Zip->new();
# read in existing zip file
$zip->read( '/home/steve/Downloads/sb/agilent/example.zip' ) == AZ_OK or die "read error\n";
# file to be added
my $string = '/home/steve/Downloads/sb/agilent/master_output.txt';
my $member = basename $string;
$zip -> addFile($string, $member); 
$zip->overwrite() == AZ_OK or die "write error\n";

=cut
    opendir DIR, $dir or die "cannot open dir $dir: $!";
    my @file= readdir DIR;
    closedir DIR;
    foreach my $dir_file(@file){
	if($dir_file =~ /(.*)\.zip/){
	    my $file_prefix = $1;
	    #find all data files that match the barcodes and save names of those files
	    my @files_to_add;
	    # archive::zip object
	    my $zip = Archive::Zip->new();
	    # path to existing zip where ann.txt, formatted.xls will be added
	    my $zip_name = $dir.$file_prefix.".zip";
	    print "##################################\n";
	    print "ZIPNAME: $zip_name\n";
	    # read in existing zip file
	    $zip -> read ( $zip_name ) == AZ_OK or die "read errors\n";
	    #add txt/annotation file
	    foreach my $ann (@file){
		if($ann =~ /($file_prefix)\_ann\.csv/i){
		    my $path_to_ann = $dir.$ann;
		    push(@files_to_add, $path_to_ann);
		}
	    }
	    
	    foreach my $form (@file){
		if($form =~ /($file_prefix)\_formatted\.xls/i){
		    my $path_to_form = $dir.$form;
		    push(@files_to_add, $path_to_form);
		}
	    }
=d
	    #print out each file that is to be added to the existing zip file
	    foreach my $f(@files_to_add){
		print "\t- file: $f\n";
	    }
=cut
	    #prepare files to be archived
	    my $string = "";
	    foreach my $file (@files_to_add){
		#add files from disk
		#if txt file, then path to ann
		$string = $file;
		my $member = basename $string;
		$zip -> addFile($string, $member);   
	    }

	    $zip->overwrite() == AZ_OK or die "write error\n";
#Zip files
#START#######################################################

	#Save the zip file
#	unless ( $zip->writeToFileNamed( $zip_name ) == 0 ) {
#	    die 'write error';
#	}

#END#########################################################
	    
	}
    }
#######################################################################################
}else{
    die "not a valid task\n";
}



#Function returns only unique values of an array
sub uniq {
    return keys %{{ map { $_ => 1 } @_ }};
}
