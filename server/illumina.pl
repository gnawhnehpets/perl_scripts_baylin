#!/usr/bin/perl
use strict;
use warnings;
#use Spreadsheet::ParseExcel;
require findxl;

my $dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/";
#findxl::find_all_xl_files($dir);
find({ wanted => \&find_all_xl, no_chdir=>1}, $dir);

=d
#This script will parse an excel file and print out stats of specific cells

my $path = "/home/steve/Desktop/MA_core_download/";
my $file = "04232013 GE worksheet.xls";
my $filename = $path.$file;

my $parser   = Spreadsheet::ParseExcel->new();
my $workbook = $parser->parse("$filename");

if ( !defined $workbook ) {
    die $parser->error(), ".\n";
}
open(FILE, '>', "parse.txt")||die "cannot open parse.txt!\n";

for my $worksheet ( $workbook->worksheets() ) {
    
    my ( $row_min, $row_max ) = $worksheet->row_range();
    my ( $col_min, $col_max ) = $worksheet->col_range();
    
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
    
}
close FILE;
