#!/bin/bash

#$ -N maker_py
# We know maker scales very well at 96 cores so
# The total core count should be a multiple of 96
# Since we are running 12 Maker tasks, lets just ask for
# the maximum number of CPUS this arrangement can
# take advantage of
#
# 12 * 96 = 1152 CPUs
#$ -pe 12way 1152 
# Use the normal queue. To increase the amount of work
# done in a given time frame, split your data up into
# more chunks and/or ask for more CPUs (in blocks of 96)
#$ -q normal
#$ -l h_rt=6:00:00
#$ -V
#$ -cwd

# We will now use the TACC PyLauncher
# (https://github.com/TACC/pylauncher)
# to orchestrate multiple concurrent MPI tasks.
# Our scri[t splits the contig data up into 12 chunks,
# writes out a simple command file to analyze each one
# using 96 cores, then hands off that command file
# to PyLauncher to run. At the end, Maker is run once
# more on the output directory to index all output
# into a unified database. The configuration
# shown here allowed us to annotate a 12 chromosome
# 600 Mb genome in a handful of hours

module purge
module load TACC
module swap mvapich2 openmpi 
module load maker
module load bioperl
# TACC Python parametric launcher
module load python/2.7.1
module load pylauncher/2.1

# Number of concurrent Maker tasks to run. A rule of thumb
# we use is 1 per chromosome (or major linkage group)
JOBNUM=12
# Number of cores per task. We are currently recommending 96
# as we know there is almost perfect scaling up to that point
CORE_PER_TASK=96
# INPUT is a Fasta file containing your contigs
# You also need all the various Maker control (.ctl)
# files to be accessible to the directory 
# you are running out of.
INPUT='all.chrs.fa'
OUTPUT='genome'

# Internal variables. Don't need to worry about editing these
SEQ='seqfile'
SCRIPTS='scripts'
SPLITDIR='split_fasta'
PARAMLIST='paramlist'

# Split the input Fasta into chunks in a local directory
echo "Dividing fasta into files in ${SPLITDIR}"
if [ ! -d "$SPLITDIR" ]; then
    mkdir $SPLITDIR
fi
time ${SCRIPTS}/divide_fasta.pl -i $INPUT -o $SPLITDIR -j $JOBNUM -d $SEQ

# Create paramlist for maker for use by PyLauncher
rm -f $PARAMLIST
for C in $(ls ${SPLITDIR}/*)
do
	# Cores,Command line
	echo "${CORE_PER_TASK},maker -base $OUTPUT -g $C" >> $PARAMLIST
done

# Invoke the mighty PyLauncher
# You have to know that launcher_file.py is configured to operate on a file named 'paramlist'
# This is kind of baroque, but hey, it works
echo "Running Maker. Hang on a bit..."
time python launcher_file.py

# Harmonize the Maker data store after multiple runs
echo "Post-processing...."
time maker -base $OUTPUT -dsindex -g $INPUT_F
