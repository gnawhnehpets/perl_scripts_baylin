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
#Used in conjunction with Archive::Zip to remove extraneous subdirectories
use File::Basename 'basename';

my $pi = "";

print "Which PI?\n";
print "1. Ahuja\n2. Baylin\n3. Brock\n4. Casero\n5. Zahnow\n";
my $input = <STDIN>;
if($input == 1){
    $pi = "Nita Ahuja";
}
if($input == 2){
    $pi = "Steve Baylin";
}
if($input == 3){
    $pi = "Malcolm Brock";
}
if($input == 4){
    $pi = "Robert Casero";
}
if($input == 5){
    $pi = "Cynthia Zahnow";
}



my $datatype = "Two color expression array worksheet";

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
my $zip_dir = $dir.$extension."zip/";#/home/steve/Desktop/MA_core_download/backup/agilent backup/array worksheet/Two color expression array worksheet/".$pi."/all/zip/"; 

opendir DIR, $xl_dir or die "cannot open dir $xl_dir: $!";
my @xl_file = readdir DIR;
closedir DIR;

#Directory containing all data files 
my $data_dir = "/home/steve/Desktop/MA_core_download/backup/agilent backup/array data file/Two color expression array/";
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
my $no_ann_counter=0;

foreach my $dir_file(@xl_file){
	my $parser  = Spreadsheet::ParseExcel->new();
	#If it's an xl file...
	if($dir_file =~ m/(.*)\.xls$/){
	    my $file_prefix = $1;
	    #Print xl file name
	    print "> $dir_file\n";
	    print MASTER "> $dir_file\n";
	    print "FILEPREF:\t$file_prefix\n";
	    #Create annotation.txt file per xl file
	    $txt_file = $file_prefix."\.txt";
	    #Path to annotation.txt file
	    my $ind_output = $txt_dir.$txt_file;
	    open(IND, '>', $ind_output) || die "cannot open ind_output.txt\n";
	    $zip_count=0;
	    #Parse xl file for annotation information
	    my $workbook = $parser->parse($xl_dir.$dir_file);
	    if ( defined $workbook ) {
		for my $worksheet ( $workbook->worksheets() ) {
		    my ( $row_min, $row_max ) = $worksheet->row_range();
		    my ( $col_min, $col_max ) = $worksheet->col_range();
		    
		    for my $row ( $row_min .. $row_max ) {
			for my $col ( $col_min .. $col_max ) {
			    
			    my $cell = $worksheet->get_cell( $row, $col );
			    next unless $cell;
#test open			    
#			    open(IND, '>', $ind_output) || die "cannot open ind_output.txt\n";
			    #Find values of cell...
			    my $cell_val = $cell->value();
###########################################################################
#pi
			    my @pi_info;
			    my $pi_count=0;
			    if($cell_val =~ m/^pi/i){
				for(my $i=2; $i < $row_max; $i++){
				    my $pi_name = $worksheet -> get_cell($i, $col);
				    if(defined $pi_name){
					my $pi_info = $pi_name -> value();
					$pi_info[$pi_count]=$pi_info;
					$pi_count++;
				    }
				}
			    }
			    #only keep unique values
			    @pi_info = uniq(@pi_info);
			    foreach my $x(@pi_info){
				if($x =~ /.*\D+.*/){
				    print "PI:\t\t$x\n";
				    print MASTER "PI:\t\t$x\n";
				    print MASTER "PI:\t\t$pi\n";
				    print IND "PI:\t\t$x\n";
				    print IND "PI:\t\t$pi\n";
				    $ann_counter++;
				}
			    }
			    #reset
			    @pi_info = ();
###########################################################################
#user
			    my @user_info;
			    my $user_count=0;
			    if($cell_val =~ m/(user)\s+/i){
				for(my $i=2; $i < $row_max; $i++){
				    my $name = $worksheet -> get_cell($i, $col);
				    if(defined $name){
					my $user_info = $name -> value();
					$user_info[$user_count]=$user_info;
					$user_count++;
				    }
				}
			    }
			    #only keep unique values
			    @user_info = uniq(@user_info);
			    foreach my $x(@user_info){
				if($x =~ /.*\D+.*/){
				    print "USER:\t\t$x\n";
				    print MASTER "USER:\t\t$x\n";
				    print IND "USER:\t\t$x\n";
				    $ann_counter++;
				}
			    }
			    #reset
			    @user_info=();
###########################################################################
#array_type
			    my @array_type;
			    my $arr_type_count=0;
			    if($cell_val =~ m/^arr(a)?y\s+type$/i){
				for(my $i=2; $i < $row_max; $i++){
				    my $arr = $worksheet -> get_cell($i, $col);
				    if(defined $arr){
					my $a = $arr -> value();
					$array_type[$arr_type_count]=$a;
					$arr_type_count++;
				    }
				}
			    }
			    #only keep unique values
			    @array_type = uniq(@array_type);
			    foreach my $x(@array_type){
				if($x =~ /.*\d+.*/){
				    print "ARRAYTYPE:\t$x\n";
				    print MASTER "ARRAYTYPE:\t$x\n";
				    print IND "ARRAYTYPE:\t$x\n";
				    $ann_counter++;
				}
			    }
			    #reset
			    @array_type=();
###########################################################################
#submit_date
			    my @submit_date;
			    my $submit_count=0;
			    if($cell_val =~ m/^sample\s+(rec\.)?(sent)?(send)?\s+date$/i){
				for(my $i=2; $i < $row_max; $i++){
				    my $submit = $worksheet -> get_cell($i, $col);
				    if(defined $submit){
					my $sub = $submit -> value();
					$submit_date[$submit_count]=$sub;
					$submit_count++;
				    }
				}
			    }
			    #only keep unique values
			    @submit_date = uniq(@submit_date);
			    foreach my $x(@submit_date){
				if($x =~ /.*\d+.*/){
				    print "SUBMIT:\t\t$x\n";
				    print MASTER "SUBMIT:\t\t$x\n";
				    print IND "SUBMIT:\t\t$x\n";
				    $ann_counter++;
				}
			    }
			    #reset
			    @submit_date=();
###########################################################################
#sample type
			    my @sample_type;
			    my $type_count=0;
			    if($cell_val =~ m/^sample\s+type$/i){
				for(my $i=2; $i < $row_max; $i++){
				    my $type = $worksheet -> get_cell($i, $col);
				    if(defined $type){
					my $t = $type -> value();
					$sample_type[$type_count]=$t;
					$type_count++;
				    }
				}
			    }
			    #only keep unique values
			    @sample_type = uniq(@sample_type);
			    foreach my $x(@sample_type){
				if($x =~ /.*\D+.*/){
				    print "SAMPLETYPE:\t$x\n";
				    print MASTER "SAMPLETYPE:\t$x\n";
				    print IND "SAMPLETYPE:\t$x\n";
				    $ann_counter++;
				}
			    }
			    #reset
			    @sample_type=();
###########################################################################
#sample description
			    my @description;
			    my $desc_count=0;
			    if($cell_val =~ m/.*description.*/i){
				for(my $i=2; $i < $row_max; $i++){
				    my $desc = $worksheet -> get_cell($i, $col);
				    if(defined $desc){
					my $d = $desc -> value();
					$description[$desc_count]=$d;
					$desc_count++;
				    }
				}
			    }
			    #only keep unique values
			    @description = uniq(@description);
			    foreach my $x(@description){
				if($x =~ /.*\D+.*/){
				    print "DESCRIPTION:\t$x\n";
				    print MASTER "DESCRIPTION:\t$x\n";
				    print IND "DESCRIPTION:\t$x\n";
				    $ann_counter++;
				}
			    }
			    #reset 
			    @description=();

###########################################################################
#ship-in date
			    my @ship_date;
			    my $ship_count=0;
			    if($cell_val =~ m/^(array\s+)?ship.*date$/i){
				for(my $i=2; $i < $row_max; $i++){
				    my $ship = $worksheet -> get_cell($i, $col);
				    if(defined $ship){
					my $s = $ship -> value();
					$ship_date[$ship_count]=$s;
					$ship_count++;
				    }
				}
			    }
			    #only keep unique values
			    @ship_date = uniq(@ship_date);
			    foreach my $x(@ship_date){
				if($x =~ /.*\d+.*/){
				    print "SHIPDATE:\t$x\n";
				    print MASTER "SHIPDATE:\t$x\n";
				    print IND "SHIPDATE:\t$x\n";
				    $ann_counter++;
				}
			    }
			    #reset
			    @ship_date=();
###########################################################################
#use date
			    my @use_date;
			    my $use_count=0;
			    if($cell_val =~ m/^(array\s+)?use.*date$/i){
				for(my $i=2; $i < $row_max; $i++){
				    my $use = $worksheet -> get_cell($i, $col);
				    if(defined $use){
					my $u = $use -> value();
					$use_date[$use_count]=$u;
					$use_count++;
				    }
				}
			    }
			    #only keep unique values
			    @use_date = uniq(@use_date);
			    foreach my $x(@use_date){
				if($x =~ /.*\d+.*/){
				    print "USEDATE:\t$x\n";
				    print MASTER "USEDATE:\t$x\n";
				    print IND "USEDATE:\t$x\n";
				    $ann_counter++;
				}
			    }
			    #reset
			    @use_date=();
###########################################################################
#sample name
			    my @sample_name;
			    my $name_count=0;
			    if($cell_val =~ m/^sample\s+name/i){
				for(my $i=2; $i < $row_max; $i++){
				    my $name = $worksheet -> get_cell($i, $col);
				    if(defined $name){
					my $n = $name -> value();
					$sample_name[$name_count]=$n;
					$name_count++;
				    }
				}
			    }
			    #only keep unique values
			    @sample_name = uniq(@sample_name);
			    foreach my $x(@sample_name){
				if($x =~ /.*\D+.*/){
				    print "SAMPLENAME:\t$x\n";
				    print MASTER "SAMPLENAME:\t$x\n";
				    print IND "SAMPLENAME:\t$x\n";
				    $ann_counter++;
				}
			    }
			    #reset
			    @sample_name=();
###########################################################################
#array bar code
			    #Store unique array #s
			    my @array_bar_code;
			    my $barcode_count=0;
			    if($cell_val =~ m/.*array\s+(bar\s+)?code.*/i){
				#If header cell is found, grab all cells beneath it
				for(my $i=2; $i < $row_max; $i++){
				    my $arr_info = $worksheet->get_cell($i, $col);
				    #If empty cell, then probably due to one value for two cells
				    if(defined $arr_info){
					my $file_regex =  $arr_info->value();
					#Array bar code cell
					if($file_regex =~ m/(\d+)([\-][\_]\d+)?/){
					    my $file_num = $1;
					    $array_bar_code[$barcode_count]=$file_num;
					    $barcode_count++;
					}	   		   
				    }
				}
				#only keep unique values
				@array_bar_code = uniq(@array_bar_code);

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
				    #$dir should be directory where zip file will be saved
				    unless ( $zip->writeToFileNamed( $zip_name ) == 0 ) {
					die 'write error';
				    }
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

#Finds annotation values for desired fields
=d
sub findvalue{
    my $c = shift;
    my $r = shift;
    my $m = shift;
    my $co = shift;
    my $w = shift;
    my $arr = shift;
    my $cou = shift;
    my $cell_val = $$c;
    my $regex = $$r;
    my $row_max = $$m;
    my $col = $$co;
    my $worksheet = $$w;
    my @array = @$arr;
    my $counter = $$cou;
    if($cell_val =~ m/($regex)/i){
	for(my $i=2; $i < $row_max; $i++){
	    my $cell = $worksheet -> get_cell($i, $col);
	    if(defined $cell){
		my $value = $cell -> value();
		$array[$counter++]=$value;
		$counter++;
	    }
	}
    }
}
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
