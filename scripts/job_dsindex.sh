#!/bin/bash
#job_dsindex.sh
#called by run_maker.sh  and is used to combine datastore from multiple jobs
#$ -V                      #Inherit the submission environment
#$ -cwd                    # Start job in submission directory
#$ -N dsindex               #job name
#$ -e $JOB_NAME.e$JOB_ID   # Combine stderr and stdout
#$ -o $JOB_NAME.o$JOB_ID   # Name of the output file (eg. myMPI.oJobID)
#$ -pe 12way 12            # Requests 12 tasks/node, 96 cores total (8 nodes)
#$ -q normal               # Queue name normal
#$ -l h_rt=00:15:00        # Run time (hh:mm:ss)
#$ -m bes                  # Email at Begin and End of job or if suspended

maker -base $1 -dsindex -g $2  #rebuilds datastore for combined jobs
