#!/bin/bash

# This scipt finds certain files based on user parameters

#for files in /home/jhmi/shwang/proj/methylation_ex/idats/Robjects/*.txt
#do
#echo grep 'output' files $(basename $files)
#done;

#PATH = /home/steve/.gvfs/onc-analysis$ on onc-cbio2.win.ad.jhu.edu/users/shwang26/perl_scripts
#echo $PATH;

#finds all files with cell or mex in  filename
for pattern in cell mex #regex for this pattern
do
#find /home/ -maxdepth 1 | grep $pattern -l $output *.txt
test=find /home/steve/Desktop/ -maxdepth 1 -type f -name '*.txt' | grep -E $pattern | xargs -r #finds all txt files with 'cell' or 'mex' in their names
echo $(basename $test)
done;