#!/usr/bin/perl

use strict;
use warnings;
#use Data::Dumper;

=pod

=head2

         FILE:  Fasta2MLCalc.pl

        USAGE:  ./Fasta2MLCalc.pl input.fas > matrix.dat 

  DESCRIPTION:  Read a FASTA alignment with two sequences and print an input matrix for MLCalc

                From the MLCalc documentation (P. Lewis):

                Data file format

                A typical data file for this program is shown below:

                896
                    261     1     9      2
                      1   267     0     29
                     14     0    82      0
                      1    23     0    206

                The number of nucleotide sites (896) is given on the first line of the file. 
                This is followed by four lines, each having four values.  These four lines 
                provide the sixteen cells of the observed divergence matrix.  If MLCalc 
                determines that the sixteen numbers comprising the divergence matrix add to 
                1.0, then these values are interpreted as proportions, and each number is 
                multiplied by the number of sites before being stored internally.

      OPTIONS: ---
 REQUIREMENTS: ---
         BUGS: ---
         TODO: ---
        NOTES: No extensive error checking! 

               No IUPAC ambiguity symbols or missing data allowed.

               Sequences need to be of the same length.

               Format used for matrix:

                     To
                from     A    C    G    T
                     A   AA   AC   AG   AT
                     C   CA   CC   CG   CT
                     G   GA   GC   GG   GT
                     T   TA   TC   TG   TT

                If warnings are issued due to unrecognized sequence characters,
                the matrix is then calculated on the non-skipped sites.

                MLCalc can be found here (02/24/2015 03:03:51 PM):
                http://www.eeb.uconn.edu/people/plewis/downloads/mlcalc.zip

                MLCalc can be run on Linux (tested on Xubuntu 12.10) using Wine (http://www.winehq.org/).



       AUTHOR: Johan Nylander (JN), johan.nylander\@bils.se
      COMPANY: BILS
      VERSION: 1.0
      CREATED: 01/23/2013 12:35:56 AM
     REVISION: 02/24/2015 03:04:06 PM

      LICENSE: Copyright (c) 2013-2020 Johan Nylander
               
               Permission is hereby granted, free of charge, to any person
               obtaining a copy of this software and associated documentation
               files (the "Software"), to deal in the Software without
               restriction, including without limitation the rights to use,
               copy, modify, merge, publish, distribute, sublicense, and/or
               sell copies of the Software, and to permit persons to whom the
               Software is furnished to do so, subject to the following
               conditions:
               
               The above copyright notice and this permission notice shall be
               included in all copies or substantial portions of the Software.
               
               THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
               EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
               OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
               NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
               HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
               WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
               FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
               OTHER DEALINGS IN THE SOFTWARE.

=cut

## Globals
my $sum = 0;
my $seqlength = 0;
my $skipped = 0;
my @seqA = ();
my @seqB = ();
my @seq_array = (); 
my %count_hash = (
    'AA' => 0, 'AC' => 0, 'AG' => 0, 'AT' => 0,
    'CA' => 0, 'CC' => 0, 'CG' => 0, 'CT' => 0,
    'GA' => 0, 'GC' => 0, 'GG' => 0, 'GT' => 0,
    'TA' => 0, 'TC' => 0, 'TG' => 0, 'TT' => 0,
);

## Check arags
exec("perldoc", $0) unless (@ARGV);

## REad file name
my $infile = shift(@ARGV);
open my $IN, "<", $infile or die "Error: could not open infile; $infile : $! \n";

## Parse FASTA
local $/ = '>';
while (<$IN>) {
    s/^>//g;
    s/>$//g;
    next if !length($_);
    my ($header_info) = /^(.*)\n/;
    s/^(.*)\n//;
    my @rec = split /\|/, $header_info;
    s/\n//mg;
    $_ = uc($_);
    push @rec, $_;
    push @seq_array, \@rec;
}
close($IN);

#print Dumper(\@seq_array);
#print Dumper(${$seq_array[0]}[1]);

## Count sequences
if (scalar(@seq_array) ne 2) {
    die "Error: did not manage to count to two input sequences (required).\n";
}

## Check sequence length
if (length(${$seq_array[0]}[1]) ne length(${$seq_array[1]}[1])) {
    die "Error: could not see that sequences are of equal length.\n";
}

(@seqA) = split //, ${$seq_array[0]}[1];
(@seqB) = split //, ${$seq_array[1]}[1];

$seqlength = scalar(@seqA);

for (my $i=0 ; $i < $seqlength ; $i++) { 
    my $trans = $seqA[$i] . $seqB[$i];
    if (defined($count_hash{$trans})) {
        $count_hash{$trans}++;
    }
    else {
        $skipped = 1;
        my $site = $i+1;
        print STDERR "Warning: found ambiguities or missing data in sequences:\n";
        print STDERR "  skipping site $i : $seqA[$i] => $seqB[$i]\n";
    }
}

while ( my ($key, $val) = each %count_hash ) {
    $sum += $val;
}
if ($sum ne $seqlength) {
    if ($skipped) {
        #warn "Warning: could not sum transitions to sequence length.Probably due to ambiguities or missing data in sequences.\n";
    }
    else {
        die "Error: could not sum transitions to equal sequence length.\n";
    }
}

## Print
print STDOUT << "MAT"
$sum
    $count_hash{'AA'}   $count_hash{'AC'}   $count_hash{'AG'}   $count_hash{'AT'}
    $count_hash{'CA'}   $count_hash{'CC'}   $count_hash{'CG'}   $count_hash{'CT'}
    $count_hash{'GA'}   $count_hash{'GC'}   $count_hash{'GG'}   $count_hash{'GT'}
    $count_hash{'TA'}   $count_hash{'TC'}   $count_hash{'TG'}   $count_hash{'TT'}
MAT

__DATA__
>Apa
--ACCTAACGTGTTGTCTCTCCTTAAAGCG
>Bpa
GAATTCGATCTCCGCCGCCTACATAACCGG
