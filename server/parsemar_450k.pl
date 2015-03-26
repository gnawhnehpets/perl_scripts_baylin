#!/usr/bin/perl

##########################################################################
#This script extracts information from Illumina  methylation zip files
##########################################################################
use strict;
use warnings;
use Archive::Zip;
use Archive::Zip::MemberRead;
=d
#download directory containing all AGILENT GE zip files
print "select pi:\n1.ahuja\n2.baylin\n3.zahnow\n";
my $input = <STDIN>;
chomp($input);
my $pi="";
if($input == 1){
    $pi="ahuja";
}
elsif($input == 2){
    $pi="baylin";
}
elsif($input == 3){
    $pi="zahnow";
}else{
    die "enter one of the three choices\n";
}
my $dir = "/home/steve/Desktop/MA_core_download/".$pi."/expression/";
=cut


# NEED TO CHANGE
#############################################################
#download directory containing all Illumina 450k zip files
my $dir = "/home/steve/Downloads/sb/methylation/";
my $pi = "baylin";
#############################################################

opendir DIR, $dir or die "cannot open dir $dir: $!";
my @file= readdir DIR;
closedir DIR;
my $tab_output = $dir."tab_del_output.txt";
my $read_output = $dir."readable_output.txt";

# open output file
open(TAB, '>', $tab_output) || die "cannot open tab_del_output.txt\n";
open(READ, '>', $read_output) || die "cannot open readable_output.txt\n";
# header information
#print TAB "#file_name\n";
#print TAB ">submitter\tpi\tsample_submision_date\tsample_type\tsample_description\tsample_process_date\tship_in_date\tuse_date\tarray_type\tarray_bar_code\tlot_number\tsap_id\tserial_number\n";
my $i=0;
my $counter=0;
foreach my $dir_file(@file){
    #change () to whatever motif
    my $motif = "methyl";
    if($dir_file =~ m/($motif)+.*zip/i){
#    if($dir_file =~ /.*zip?/){
	$counter++;
	print "$counter ###".$dir_file."\n"; #print name of zip file
	my $file_prefix = "";
	if($dir_file =~ m/(.*)\.zip/i){
	    $file_prefix = $1;
	}
	my $date = "";
	if($file_prefix =~ /(\d{8})/){
	    $date = $1;
	    if($date =~ /(20\d\d)(\d\d)(\d\d)/){
		$date = $1."-".$2."-".$3;
	    }
	    if($date =~ /(\d\d)(\d\d)(20\d\d)/){
		$date = $1."-".$2."-".$3;
	    
		print "DATE:\t $date\n";
	    }
	}
	my $zipFile = Archive::Zip->new();
	# open zip file; read(directory+filename.zip);
	$zipFile->read( $dir.$dir_file ) == 0 || die "cannot read $dir_file\n";
	# get all filenames within zip file
	my @files = $zipFile -> memberNames( $dir.$dir_file );
	#print contents of zip file
	foreach my $file (sort @files) {
#	    print "\t".$file."\n";
#	    if($file =~ m/samples table.*\.txt?/i){
	    my @barcode = ();
	    my $user = "";
	    if($file =~ m/control profile\_(\w+)\_/i){
		$user = $1;
		print "FOUND: $1\n";
	    }
	    if($file =~ m/table/i){
		print "PI:\t\t$pi\n";
#		print "USER:\t\t$user\n";
#		print "TARGET: $file\n";
		#if 0, do not print; wait til "sample id" line is found
#		my @barcode = ();
		my $count = 0;
		my $fh = Archive::Zip::MemberRead->new($zipFile, $file);
		while (defined (my $line = $fh->getline())){
		    if($line =~ /^index\tsample id/i){
#			print $line."\n";
			$count++;
			next;
		    }
		    if($count > 0){
			my $sample = "";
			my $barcode = "";
			if($line){
			    if($line =~ /\w+\t(.*)\_\S+\t/){
				$sample = $1;
				$sample =~ s/\_/ /g;
				if($sample =~ /(.*)\s+(\d+)$/){
				    $sample = $1;
				    $barcode = $2;
				    push(@barcode, $barcode);
				}
#				$barcode = $2;
#				$barcode =~ s/\_/ /g;
			    }
			    print "SAMPLE_NAME:\t$sample\n";
#			    print "BARCODE:\t$barcode\n";
			}
		    }
		}
		@barcode = uniq(@barcode);
		foreach my $b (@barcode){
		    print "BARCODE:\t$b\n";
		}
		
=d	    if($file =~ m/profile.*\.txt?/i){
		print "\t".$file."\n";
		my $fh  = Archive::Zip::MemberRead->new($zipFile, $file);

#SGX Version	1.1.0
#Report Date	8/9/2013 10:17:12 AM
#Project	Methylation450_YYjang etc_08092013
#Group Set	Methylation450_YYJang_08092013
#Analysis	Methylation450_YYJang_08092013_nonorm_nobkgd
#Normalization	none
		my $groupset="";
		my $analysis="";
		my $normalization="";
		my $bg_correction="";
		while (defined(my $line = $fh->getline()))
		{

		    if($line =~ m/^Report Date\s+(\d+\/\d+\/\d+)\s+(\d+\:\d+\:\d+)/){
			#get date
			my $date = $1;
			#get time
			my $time = $2;
			print "\tDate:\t\t$date\n";
			print "\tTime:\t\t$time\n";
		    }
		    if($line =~ m/^Project\s+(.*)?/){
			#get project name
#			print $1."\n";
		    }
		    if($line =~ m/^Group Set\s+(.*)?/){
			#get group set info
#			print $1."\n";
			$groupset=$1;
			print "\tGroupset:\t".$groupset."\n";
		    }
		    if($line =~ m/^Analysis\s+(.*)?/){
			#get analysis info
			$analysis=$1;
#			print $groupset."\n";
			$analysis =~ s/($groupset)//g;
#			print $analysis."\n";
			if($analysis =~ /\_(\D+)\_(\D+)/){
			    $normalization=$1;
			    $bg_correction=$2;
			    print "\tnorm:\t\t".$normalization."\n";
			    print "\tbg:\t\t".$bg_correction."\n";
			}
		    }
		}
=cut
	    }
	}
    }
}
print "total files: ".(scalar(@file)-2)."\n";;
print "regex match: $counter\n";
close TAB;
close READ;

#Function returns only unique values of an array
sub uniq {
    return keys %{{ map { $_ => 1 } @_ }};
}
