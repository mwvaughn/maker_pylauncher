#! /usr/bin/env perl
 
use strict;
use Getopt::Std;
use Bio::SeqIO;
use Bio::Seq;
 
$|=1;

my %opts = ();
getopts('hi:o:j:d:', \%opts);
usage() if (exists $opts{'h'});
 
################################################################
# Global Variables
################################################################

my $infile       = $opts{'i'} || usage();
my $outdir       = $opts{'o'} || usage();
my $jobs         = $opts{'j'} || '12';  #number of jobs in the array 
my $basename     = $opts{'d'} || 'seqfile';

split_fasta();

# Usage Sub: to print the usage statement
sub usage{
   my $program = `basename $0`; chomp ($program);
   print "
 
      $program splits up multi fasta file into a number of smaller files indicated with -j 
      $program -p program -i /path/to/fa_files -o path/to/output_directory -j <integer> -o <basename_of_split_files>
 
      $program -h (displays this message)
      
   ";
   exit 1;
}

sub split_fasta {
   
    my $in  = Bio::SeqIO->new(   
        -file   => $infile,
        -format => 'Fasta',
    );    

    my $file_counter = 1;

    while (my $seqobj = $in->next_seq()) {
  
        my $outfile = $outdir . '/' . $basename . '.' . $file_counter++;	
        my $out= Bio::SeqIO->new( 
            -format => 'Fasta', 
            -file   => ">>$outfile",
				  );
        $out->write_seq($seqobj);
        $file_counter = 1 if $file_counter > $jobs
    }
}
