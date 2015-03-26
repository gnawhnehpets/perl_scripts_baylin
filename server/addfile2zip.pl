#!usr/bin/perl
use strict;
use warnings;
use Archive::Zip qw( :ERROR_CODES );
use File::Basename 'basename';
#######################################################
# This script adds file to an already existing zip file
# 
#######################################################

my $zip = Archive::Zip->new();
# read in existing zip file
$zip->read( '/home/steve/Downloads/sb/agilent/example.zip' ) == AZ_OK or die "read error\n";
# file to be added
my $string = '/home/steve/Downloads/sb/agilent/master_output.txt';
my $member = basename $string;
$zip -> addFile($string, $member); 
$zip->overwrite() == AZ_OK or die "write error\n";
