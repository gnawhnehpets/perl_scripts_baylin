#!/usr/bin/perl

##################################################################################
#This script will parse a zip file and return all excel files within the zip file.
##################################################################################

use strict;
use warnings;
use Archive::Zip;
use Spreadsheet::ParseExcel;

my $zipFile = Archive::Zip->new();
my $xl_file = "";
#open zipfile; direct path to file

my $path = '/home/steve/Desktop/MA_core_download/';
my $file_name = '04232013 RVatapalli Agilent GE.zip';
my $path_to_file = $path.$file_name;
$zipFile->read( $path_to_file ) == 0 || die "cannot read zip file\n";

#find all excel files within zipfile
my @files = $zipFile->memberNames( $path_to_file );
print "file: $file_name\n";
foreach my $file (sort @files) {
    #find all excel files
    if($file =~ m/(.*xls)/){
	$xl_file = $1;
	print "###excel file found.###\n";
	print $xl_file."\n";
	print "#######################\n";
    }
}

