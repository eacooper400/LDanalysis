#!/usr/bin/perl -w
#
# hmp2diploid.pl
#
# Convert hmp format to diploid genotypes for R genetics package
#
# January 8, 2016
# Liz Cooper

use strict;

# Take as input the name of the hapmap file, the name of the output,
# the chromosome, and the start and end positions of the chromosomal region 
my ($USAGE) = "\n$0 <input.hmp.txt> <output.diploid.txt> <chr> <start> <end>
\t\tinput.hmp.txt = The input file in hapmap format
\t\toutput.diploid.txt = The output file in R genetics format to be created
\t\tchr = The chromosome to extract genotypes from
\t\tstart = The start position of the region to extract genotypes from
\t\tend = The end position of the region to extract genotypes from\n\n";

unless (@ARGV) {
  print $USAGE;
  exit;
}
my ($input, $output, $chr, $start, $end) = @ARGV;

# Open the output file for printing
open (OUT, ">$output") || die "\nUnable to open the file $output!\n";

# Open the snps file to process one line at a time
open (IN, $input) || die "\nUnable to open the file $input!\n";

while (<IN>) {
  chomp $_;
  
  # Skip the header line
  if ($_ =~ /^rs/) {
    next;
  }

  my @info = split(/\t/, $_);

  # Check if the chromosome matches the predefined region
  unless ($info[2] == $chr) {
    next;
  }

  # Check if the position is in the predefined region
  unless (($info[3] >= $start) && ($info[3] <= $end)) {
    next;
  }

  # For SNPs in the correct window, convert to diploid format
  # and output to the new file
  my @snps = @info[11..(scalar @info - 1)];
  my $snp_string = join('', @snps);
  
  my $diploid_string = '';

  for (my $p = 0; $p < length $snp_string; $p++) {
    my $code = substr($snp_string, $p, 1);
    if ($code =~ /N/) {
      $diploid_string .= "NA,";
    } elsif ($code =~ /[MRWSYK]/) {
      $diploid_string .= $info[1] . "/" . $info[2] . ",";
    } else {
      $diploid_string .= $code . "/" . $code . ",";
    }
  }
  chop $diploid_string;
  
  print OUT $chr, "\t", $info[3], "\t", $diploid_string, "\n";
}
close(IN);
close(OUT);
exit;
