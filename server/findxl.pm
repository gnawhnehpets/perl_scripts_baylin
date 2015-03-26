#!/usr/bin/perl
use strict;
use warnings;
use File::Find;
use Spreadsheet::ParseExcel;
package findxl;

sub find_all_xl_files{
    my $dir = shift;
    #print path to folder
    print $dir."\n";
    my $path_txt = "xl_file_path.txt";
    open(XL, '>', $path_txt) || die "cannot open $path_txt\n";

    close XL;
}


sub find_all_xl{
    my $F = $File::Find::name;
    if($F =~ /\.xls$/){
	print "$F\n";
    }
}

=d
sub cell_handler {
    my ($workbook, $sheet_index, $row, $col, $cell) = @_;
    
    foreach my $re (@searchTerms) {
	if ($cell->Value =~ $re) {
	    #found a match; print out details
	    print $fh "File:  ", basename($workbook->{File}), "\n",
	    "Sheet: ", $workbook->{Worksheet}[$sheet_index]->{Name}, "\n",
	    "Cell: ", $columnMap[$col], ":", $row, "\n",
	    "Cell Contents: ", $cell->Value, "\n\n";
	    
	    $fileMatches++;
	} #end if
    } #end foreach
}
=cut
1;
