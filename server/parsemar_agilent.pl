#!/usr/bin/perl

##########################################################################
# Script processes Agilent files uploaded to MA_core portal and prepares
# files for upload to file server

# 1. Download all Agilent files; transfer files from /home/steve/Downloads
#    to /home/steve/Downloads/pi/agilent
# 2. Run core2agilentserv_pi1.pl
# 3. 
##########################################################################
use strict;
use warnings;
use Archive::Zip;
use Spreadsheet::ParseExcel;
use Spreadsheet::WriteExcel;

my $dir = "/home/steve/Downloads/sb/agilent/";
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

=d
	}
	#if no excel files are present in zip file, save name of files for manual examination
	if($xl_counter==0){
		$no_xl[$i]=$dir_file;
		$i++;
		print "no excel: $dir_file\n";
	}
    }
}

close TAB;
close READ;
