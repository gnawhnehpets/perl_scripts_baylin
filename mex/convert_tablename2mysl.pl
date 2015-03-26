#!/usr/bin/perl;
use strict;
use warnings;

##############################################################
# This script creates MySQL commands to use to duplicate MySQL
# databases by only having the table names of the database you
# want to clone.
##############################################################

my $file = "/home/steve/Desktop/mextablenames.txt"; # contains table names you want to clone
open(MEX, $file) || die "cannot open mextablenames.txt\n";
my $output = "/home/steve/Desktop/mextablemysqlcommands.txt";
open(OUT,'>', $output) || die "cannot open output text\n";

while(my $line = <MEX>){
    chomp($line);
    # CREATE TABLE  name_of_new_table LIKE old_database.name_of_old_table
    print OUT "CREATE TABLE ". $line . " LIKE jhmi_su2c." . $line . ";\n";
    # INSERT INTO name_of_new_table SELECT * FROM old_database.name_of_old_table
    print OUT "INSERT INTO " . $line . " SELECT * FROM jhmi_su2c." . $line . ";\n";
}

close(OUT);
close(MEX);
