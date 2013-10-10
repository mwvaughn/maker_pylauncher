#!/bin/bash
#job_maker.sh
#called by run_maker.sh
#$ -V                      #Inherit the submission environment
#$ -cwd                    # Start job in submission directory
#$ -e $JOB_NAME.e$JOB_ID   # Combine stderr and stdout
#$ -o $JOB_NAME.o$JOB_ID   # Name of the output file (eg. myMPI.oJobID)
#$ -q normal               # Queue name normal
#$ -m bes                  # Email at Begin and End of job or if suspended

ibrun maker -base $1 -g $2

