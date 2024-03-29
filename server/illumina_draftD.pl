#!/usr/bin/perl

###########################################################################
#This script parses Illumina annotation excel files and grabs information
#that pertain only to PIs in Baylin's lab. Excel files containing smaller
#subsets of the data are created, as well as tab-delimited .txt and 
#readable annotation files. The original .xls file is included as well as
#all directories matching the unique bar code found in the xl_file

#NOTE: need to change `$dir = ` and `$datadir = `to directory of files
###########################################################################
use strict;
use warnings;
use Archive::Zip;
use Spreadsheet::ParseExcel;
use Spreadsheet::WriteExcel;
#Used in conjunction with Archive::Zip to remove extraneous subdirectories
use File::Basename 'basename';

###########################################################################
#Directory containing excel files of expression data output
my $exp_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/Illumina sheet/work sheet/expression/test/";
my $exp_data_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/expression output/";
#Directory containing excel files of expression data output
my $m27_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/Illumina sheet/work sheet/methylation27/test/";
my $m27_data_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/methylation27 output/";
#Directory containing excel files of expression data output
my $m450_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/Illumina sheet/work sheet/methylation450/test/";
my $m450_data_dir = "/home/steve/Desktop/MA_core_download/backup/illumina backup/DataOutput/methylation450 output/";

#Directory containing annotation
#NOTE: change $*_dir based on which data you want to organize
my $dir = $exp_dir;
my $dir_array = set_dir(\$dir);;
my @dir_files = @$dir_array;
=d
opendir EXP, $exp_dir or die "cannot open dir $exp_dir: $!";
my @exp_file = readdir EXP;
closedir EXP;

opendir M27, $m27_dir or die "cannot open dir $m27_dir: $!";
my @m27_file = readdir M27;
closedir M27;

opendir M45, $m450_dir or die "cannot open dir $m450_dir: $!";
my @m45_file = readdir M45;
closedir M45;
=cut

#Name of annotation .txt file
my $ann_file = "annotation.txt";

#Name of full stats .txt file
my $full_ann = "annotation.txt";

print_array(\@dir_files, \$dir, \$ann_file, \$full_ann);
#print_array(\@m27_file, \$m27_dir, \$ann_file, \$full_ann);
#print_array(\@m45_file, \$m450_dir, \$ann_file, \$full_ann);

my $zip_count=0;



sub print_array{
    my $array = shift;
    my $directory = shift;
    my $anno = shift;
    my $full = shift;
    
    #@folder contains all files within directory
    my @folder = @$array;
    #path to directory containing xl files
    my $path2xl= $$directory;
    #path to ann.txt files
    my $path2ann = $path2xl."txt/";
    my $ind_output = $$anno;
    my $full_output = $$full;

    my @all_pi = (
	qr/ah\D+a/i,
	qr/bay\D+/i,
	qr/n\D+kin/i,
	qr/brock/i,
	qr/z\D+w/i,
	qr/qindy/i,
	qr/huili/i,
	qr/casero/i,	
	qr/joo\s+mi/i
	);

    my @header_pattern = (
	qr/pi.*name/i,
	qr/user\s+name/i,
	qr/sample\s+send\s+date/i,
	qr/sample\s+type/i,
	qr/sample\s+name/i,
	qr/sample\s+description/i,
	qr/date\s+process/i,
	qr/ship.*date/i,
	qr/use\s+date/i,
	qr/array\s+type/i,
	qr/array\s+bar\s+code/i,
	qr/array\s+position/i,
	qr/name.*position/i
	);
    
    my @header;
    my $header_count=0;
    my @row_contents;
    my $row_count=0;
    my @barcode;
    my $barcode_count=0;
    my $print_header=0;
    my $pi_counter=0;
    my $print_txt=0;
    #foreach my $dirfile(@file)
    foreach my $files(@folder){
	my $parser  = Spreadsheet::ParseExcel->new();
	if($files =~ m/(.*)\.xls$/){
	    my $xl_file = $dir.$files;
	    print "XLFILE: $files\n";
	    my $file_prefix = $1;

	    #File names include prefix
	    my $ind_ann_output = $dir."x/txt/".$file_prefix."_sum_".$ind_output;
	    my $tab_ann_output = $dir."x/txt/".$file_prefix."_tab_".$ind_output;
	    my $full_ann_output = $dir."x/txt/".$file_prefix."_full_".$full_output;
	    my $write_xl_path = "";
	    my $write_full_ann_path = "";
		
	    print "IND:\t".$ind_ann_output."\n";;
	    print "TAB:\t".$tab_ann_output."\n";
	    print "FULL:\t".$full_ann_output."\n";
	    open(IND, '>', $ind_ann_output) || die "cannot open ind_output.txt\n";
	    open(FULLANN, '>', $full_ann_output) || die "cannot open full_ann_output.txt\n";
	    open(TABANN, '>', $tab_ann_output) || die "cannot open tab_ann_output.txt\n";
	    #Print xl file name
	    print IND "##############################################################\n";
 	    print IND "# FILENAME:\t$files\n";
	    
	    $zip_count=0;
	    #Parse xl file for annotation information
	    my $workbook = $parser->parse($path2xl.$files);
	    if ( defined $workbook ) {       
		for my $worksheet ( $workbook->worksheets() ) {
		    #Name of worksheet
		    my $worksheet_name = $worksheet->get_name();
		    my ( $row_min, $row_max ) = $worksheet->row_range();
		    my ( $col_min, $col_max ) = $worksheet->col_range();
		    if($row_max>0){
			print IND "> WORKSHEET:\t$worksheet_name\n";
		    }
		    for my $row ( $row_min .. $row_max ) {
			for my $col ( $col_min .. $col_max ) {
			    
			    my $cell = $worksheet->get_cell( $row, $col );
			    next unless $cell;
			    my $col_counter = 0;
			    #Find values of cell...
			    my $cell_val = $cell->value();
##############################################################################
#print all header info into exel
			    #Get column for PI name...
			    if($cell_val =~ m/pi\s+name/i){
##############################################################################
#PRINT HEADER IN NEW EXCEL
				if($print_header == 0){
				    for(my $xlcol = 0; $xlcol<$col_max; $xlcol++){
					my $h_v = $worksheet->get_cell(1,$xlcol);
					my $head_val = "N/A";
					if($h_v){
					    $head_val = $h_v -> value();
					    if($head_val =~ /project/i){
						next;
					    }
					    print FULLANN $head_val."\t";
					    if($head_val ~~ @header_pattern){
						print TABANN $head_val."\t";
#						$write_xl->write(0,$xlcol,$head_val);
					    }
					}
				    }
				    $print_header++;
				    print TABANN "\n";
				    print FULLANN "\n";
				}
##############################################################################
#FIND ROWS WITH MATCHING PI
				for(my $p_row = $row; $p_row < $row_max; $p_row++){
				    my $enc_pi = $worksheet -> get_cell($p_row, $col);
				    if($enc_pi){
					my $pi_names = $enc_pi -> value();
					#Print row stats of desired PIs only
					if($pi_names ~~ @all_pi){
#					    print TABANN "PI: $pi_names\t";
##############################################################################
#Traverse all cells within a row; $h_col is used to go to next column
					    for(my $h_col = $col; $h_col < $col_max; $h_col++){
						#Get header info
						my $hv = $worksheet -> get_cell($row,$h_col);
						my $hv_val = "";
						if($hv){
						    $hv_val = $hv -> value();
						}
						if($hv_val =~ /project/i){
						    next;
						}
						
						my $h = $worksheet -> get_cell($row, $h_col);
						#If there is a value in the cell
						if($h){
						    my $h_val = $h->value();
						    
						    if($h_val !~ @header_pattern){
 							my $row_stat = print_row(\$worksheet, \$p_row, \$h_col);
							my $out_val = $$row_stat;
							#Write out all entire row with pi match
							my $fr = print_row(\$worksheet, \$p_row, \$h_col);
							my $full_row = $$fr;
							print FULLANN $full_row."\t";
							
						    }
 						    #If other headers are found
						    if($h_val ~~ @header_pattern){
							#Process header string
							$h_val =~ s/^\s+//;
							$h_val =~ s/\s+$//;
							$h_val =~ s/\s+\//\//;
							#get row stats
							my $rs = print_row(\$worksheet, \$p_row, \$h_col);
							my $wh_val = $$rs;
							print IND "ROW:$p_row\t";
							print IND "COL:$h_col\t";
							print IND $h_val.":\t$wh_val\n";
							print TABANN $wh_val."\t";
							$header[$header_count]=$h_val;
							$header_count++;
							#Save bar code
							if($h_val =~ /array\s+bar\s+code/i){
							    $barcode[$barcode_count]=$wh_val;
							    $barcode_count++;
							}
						    }
						}
						#For the # of columns...
						$col_counter++;
					    }
					    print IND "\n";
					    print TABANN "\n";
					    print FULLANN "\n";
					}
				    }
				}
				#For each worksheet...
			    }
			    $header_count=0;
			}
		    }
		}
	    }
	    #Archive::Zip object
	    my $zip = Archive::Zip->new();
	    #Name of zip file
	    my $zip_name = $dir."x/".$file_prefix."\.zip";
	    @barcode = uniq(@barcode);
	    if(@barcode){
		print IND "######################################################################\n";
		print IND "#####UNIQUE BAR CODE WITHIN $ind_ann_output:\n";
		
	    
		#For each unique barcode found in each xl file, 
		#find matching directory and add it to be compressed
		
		foreach my $code (@barcode){
		    print IND $code."\n";
		    #Set directory where data folders can be found
		    ####################################################
		    ####################################################
		    #NOTE: need to change *_data_dir depending on output
		    ####################################################
		    ####################################################
		    my $datadir = $exp_data_dir.$code;
		    my $member = basename $dir;
		    $zip -> addTree($datadir, $member);
		}
		
		close XL;
		close IND;
		close TABANN;
		close FULLANN;
		#####################################333
		#Write annotation out to Excel
		open(XL, $tab_ann_output) || die "cannot open ind_ann_output to write to excel";
		my $xl_row_num = 0;
		$write_xl_path = $dir."x/".$file_prefix."_annotation.xls";
		my $txt_xl_out = Spreadsheet::WriteExcel->new($write_xl_path);
		my $txt_xl = $txt_xl_out -> add_worksheet();
		my $format = $txt_xl_out->add_format();
		$format->set_color('red');
		while(my $line = <XL>){
		    chomp($line);
#		if($line =~ //){
		    my @data = split("\t", $line); 
		    my $size = scalar(@data);
		    for(my $col=0; $col < $size+1; $col++){
			$txt_xl->write($xl_row_num, $col, $data[$col], $format);
		    }
		    @data=();
		    $xl_row_num++;
#		}
		}
		$txt_xl_out -> close();
		close XL;
		#######################################
		#Write full stats out to Excel
		open(FULL, $full_ann_output) || die "cannot open $full_ann_output to write to excel";
 		my $full_row_num = 0;
		$write_full_ann_path = $dir."x/".$file_prefix."_full_annotation.xls";
		my $full_ann_out = Spreadsheet::WriteExcel->new($write_full_ann_path);
		my $full_ann = $full_ann_out -> add_worksheet();
		my $full_format = $full_ann_out->add_format();
		$full_format->set_color('blue');
		while(my $full_line = <FULL>){
		    chomp($full_line);
		    my @full_data = split("\t", $full_line); 
		    my $full_size = scalar(@full_data);
		    for(my $col=0; $col < $full_size+1; $col++){
			$full_ann ->write($full_row_num, $col, $full_data[$col], $full_format);
		    }
		    @full_data=();
		    $full_row_num++;
		}
		$full_ann_out -> close();
		close FULL;
		
		my @files = ($xl_file, $ind_ann_output, $tab_ann_output, $full_ann_output, $write_xl_path, $write_full_ann_path);
		foreach my $x ( @files){
		    my $string = $x;
#		    print "FILE:\t$x\n";
		    my $member = basename $string;
#		    print "BASE:\t$member\n";
		    $zip -> addFile($x, $member);
		}	
		
		#Save the Zip file
		#$dir should be directory where zip file will be saved
=d
		unless ( $zip->writeToFileNamed( $zip_name ) == 0 ) {
		    die 'write error';
		}
=cut
		@barcode=();
		$barcode_count=0;
	    }
	}
	$print_header=0;
    }
}

#Function returns only unique values of an array
sub uniq {
    return keys %{{ map { $_ => 1 } @_ }};
}

#Function finds differences between two arrays
sub diff {
    my %hash = map{ $_=>1} @{$_[1]}; 
    return grep { !defined $hash{$_} }  @{$_[0]};
}

sub print_row {
    #$worksheet
    my $w = shift;
    #$p_row
    my $r = shift;
    #$h_col
    my $c = shift;

    #DEREF
    my $worksheet = $$w;
    my $row = $$r;
    my $col = $$c;
    
    my $out = $worksheet -> get_cell($row, $col);
    my $out_val= "N/A";
    if($out){
	$out_val = $out -> value();
    }else{
	$out_val = "N/A";
    }
    	return \$out_val;
}

sub set_dir{
    my $d = shift;
    my $w_dir = $$d;
    opendir WD, $w_dir or die "cannot open dir $w_dir: $!";
    my @wd = readdir WD;
    closedir WD;
    return \@wd;

}
