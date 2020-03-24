# Fasta2MLCalc


## Description

Create a distance matrix for Paul Lewis's MLCalc program from a fasta-formatted
sequence file


## Usage

    $ ./Fasta2MLCalc.pl input.fas > matrix.dat

Type 'perldoc Fasta2MLCalc.pl' for details.


## Files

- `Fasta2MLCalc.pl` -- Perl script

- `input.fas` -- example input file

- `matrix.dat` -- example output file


The MLCalc software can be found here (Accessed Tue 24 mar 2020 16:40:21):

<http://hydrodictyon.eeb.uconn.edu/people/plewis/downloads/mlcalc.zip>


## MLCalc

MLCalc is a Windows software but can be run on Linux (tested on
Xubuntu 18.04) using Wine (<http://www.winehq.org/>):

    $ wget http://hydrodictyon.eeb.uconn.edu/people/plewis/downloads/mlcalc.zip
    $ unzip mlcalc.zip
    $ cd mlcalc
    $ wine mlcalc.exe

