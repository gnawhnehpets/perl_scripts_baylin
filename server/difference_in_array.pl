#!/usr/bin/perl
use strict;
use warnings;

my @barcodes = qw( 1 2 3 4 5 6 );
my @matches = qw( 2 3 4 5 );

my @non_matches1 = diff(\@barcodes, \@matches);
my @non_matches2 = diff2(\@barcodes, \@matches);
foreach my $x(@non_matches1){
    print $x."\n";
}

sub diff{
  my %hash; 
  @hash{@{$_[1]}} = (1) x @{$_[1]};
  return grep { !defined $hash{$_} }  @{$_[0]};
}

sub diff2 {
  my %hash = map{ $_=>1} @{$_[1]}; 
  return grep { !defined $hash{$_} }  @{$_[0]};
}
