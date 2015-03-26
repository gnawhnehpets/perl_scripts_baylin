#!/usr/bin/perl
use strict;
use warnings;
use Archive::Zip;
use Spreadsheet::ParseExcel;

#This script is the beta script for `parse_excel_from_zip.pl`
#This script will parse a single excel file within a zip file.
#Improvements in newer script writes statistics to file.

my $dir = "/home/steve/Desktop/MA_core_download/";
opendir DIR, $dir or die "cannot open dir $dir: $!";
my @file= readdir DIR;
closedir DIR;

foreach my $dir_file(@file){
    if($dir_file =~ m/(.*zip)/){
	print $dir_file."\n";
    }
}

my $parser  = Spreadsheet::ParseExcel->new();
my $zipFile = Archive::Zip->new();
my $xl_file = "";
#open zipfile
$zipFile->read( '/home/steve/Desktop/MA_core_download/04232013 RVatapalli Agilent GE.zip' ) == 0 || die "cannot read zip file\n";

#find all files within zipfile
my @files = $zipFile->memberNames('/home/steve/Desktop/MA_core_download/04232013 RVatapalli Agilent GE.zip');
foreach my $file (sort @files) {
    #find all excel files
    if($file =~ m/(.*xls)/){
	$xl_file = $1;
	print "excel file found.\n";
	#get contents of compressed file as a string
	my $xls_content = $zipFile->contents($file);
	#pass strign as a reference and parse 
	my $content = \$xls_content;
	my $workbook = $parser->parse(\$xls_content);

	for my $worksheet ( $workbook->worksheets() ) {
	    my $submitter = $worksheet -> get_cell(2,2);
	    my $pi = $worksheet-> get_cell(2,3);
	    my $sample_receive_date = $worksheet -> get_cell(2,4);
	    my $sample_type = $worksheet -> get_cell(2,5);
	    my $sample_description = $worksheet -> get_cell(2,7);
	    my $process_date = $worksheet -> get_cell(2,12);
	    #ship-in date 33
	    my $ship_in_date = $worksheet -> get_cell(2,33);
	    #use date 34
	    my $use_date = $worksheet -> get_cell(2,34);
	    #array type 35
	    my $array_type = $worksheet -> get_cell(2,35);
	    #array bar code 36
	    my $array_bar_code = $worksheet -> get_cell(2,36);
	    #lot number 37
	    my $lot_number = $worksheet -> get_cell(2,37);
	    #sap id 38
	    my $sap_id = $worksheet -> get_cell(2,38);
	    #kit serial number 39
	    my $serial_number = $worksheet -> get_cell(2,39);
=d
	    print $submitter->value()."\n";
	    print $pi->value()."\n";
	    print $sample_receive_date->unformatted()."\n";
	    print $sample_type->unformatted()."\n";
	    print $sample_description->unformatted()."\n";
	    print $process_date->unformatted()."\n";
	    print $ship_in_date->unformatted()."\n";
	    print $use_date->unformatted()."\n";
	    print $array_type->unformatted()."\n";
	    print $array_bar_code->unformatted()."\n";
	    print $lot_number->unformatted()."\n";
	    print $sap_id->unformatted()."\n";
	    print $serial_number->unformatted()."\n";
=cut
	}
    }
}

