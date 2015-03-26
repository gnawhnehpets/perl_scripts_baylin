For methylation data:

1. If FINAL_REPORT file is present, then use D:/mex_data/Rscripts/readIlluminaData.R to extract beta values
2. If raw idat files are only present (ie. microarray core):
	a. find NAME_OF_PI.xls from /onc-cbio2/onc-analysis/data/illumina data/methylation/NAME_OF_PI/NAME_OF_PI.xls
	b. create a newmeta.txt and tab-delimited file in the following format:

biopsy	filename
PATIENT1	BARCODE_ARRAYPOSITION1
PATIENT2	BARCODE_ARRAYPOSITION2
PATIENT3	BARCODE_ARRAYPOSITION3
PATIENT4	BARCODE_ARRAYPOSITION4
PATIENT5	BARCODE_ARRAYPOSITION5
PATIENT6	BARCODE_ARRAYPOSITION6
PATIENT7	BARCODE_ARRAYPOSITION7
	c. Method #1: Use Illumina spreadsheet submitted to core to get barcode & array position information; concatenate `filename` information in spreadsheet. 

3. Run /onc-cbio/onc-analysis/users/shwang26/perl_scripts/make_minfi_samplesheet.pl "PATH/TO/META.TXT" "PATH/TO/readIlnfiniumData_rawidats.R/source/filename.CSV"
	a. perl make_minfi_samplesheet.pl meta.txt "D:/steve/mex_data/new_data/lung.csv"
	b. perl make_minfi_samplesheet.pl "../meta.txt" "D:/steve/mex_data/new_data/lung.csv"

4. Run D:/mex_data/Rscripts/readIlluminaData_rawidats.R