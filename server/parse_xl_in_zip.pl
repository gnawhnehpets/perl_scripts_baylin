#!/usr/bin/perl

##########################################################################
#This script extracts certain cell information from excel files found in 
#zip files. The script will parse the zip file for excel files, and if the 
#file is found, it will parse the excel file with the a CPAN module
#`Speadsheet::ParseExcel` to extract the information.
##########################################################################
use strict;
use warnings;
use Archive::Zip;
use Spreadsheet::ParseExcel;

#download directory containing all zip files
my $dir = "/home/steve/Downloads/sb/agilent/";
opendir DIR, $dir or die "cannot open dir $dir: $!";
my @file= readdir DIR;
closedir DIR;
my $tab_output = $dir."tab_del_output.txt";
my $read_output = $dir."readable_output.txt";

my @zip_file_name = ();
my @xl_file_name = ();
foreach my $dir_file(@file){
    if($dir_file =~ m/(.*)\.zip/i){
	my $z = $1;
	chomp($z);
	push(@zip_file_name, $1);
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
	    my $parser = Speadsheet::ParseExcel->new();
	    my $previous_row=0;
	    my $find_row_min=0;
	    my $find_col_min=0;
	    #find all excel files
	    if($file =~ m/\.xls/){
		my $workbook = $parser->parse($xl_dir.$dir_file);
		if ( defined $workbook ) {
		    for my $worksheet ( $workbook->worksheets() ) {
#		my $worksheet = $workbook->worksheet(0);
			my ( $row_min, $row_max ) = $worksheet->row_range();
			my ( $col_min, $col_max ) = $worksheet->col_range();
		    
		    for my $row ( $row_min .. $row_max ) {
			for my $col ( $col_min .. $col_max ) {
			    my $cell = $worksheet->get_cell( $row, $col );
			    if($find_row_min == 0){
				next unless $cell;
			    my $set_row_min = $cell->value();		    
				#if($set_row_min =~ /user\s+name/i){
				if($set_row_min =~ /(user$)|(user\s+name)/){
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
}

#>>>>>>>>>>>>>>>>>>

=d
		push(@xl_file_name, $z);
		print "$file\n";
		$xl_counter++;
		#if no excel files are present in zip file, save name of files for manual examination
		if($xl_counter==0){
		    chomp($dir_file);
		    push(@no_xl, $dir_file);
#		$no_xl[$i]=$dir_file;
#		$i++;
		    print "no excel: $dir_file\n";
		    
		}
	    }
	}
    }
}
=cut
print "ZIP: ".scalar(@zip_file_name)."\n";
print "XL: ".scalar(@xl_file_name)."\n";
my @union = ();
my @isect = ();
my @diff = ();
my %union = ();
my %isect = ();
my %count = ();
=d
foreach my $x (@zip_file_name){
    print "ZIP: $x\n";
}

foreach my $x (@xl_file_name){
    print "XL: $x\n";
}

=cut
foreach my $e (@zip_file_name, @xl_file_name) { $count{$e}++ }
foreach my $e (keys %count) {
    push(@union, $e);
    if ($count{$e} == 2) {
        push(@isect, $e);
    } else {
        push(@diff, $e);
    }
}

foreach my $i (@isect){
    print "ISECT: $i\n"
}

foreach my $d (@diff){
    print "DIFF: $d\n";
}
