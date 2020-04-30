#!/usr/bin/env bash
#BED12FeatureAdder.sh
#This script mimics the bam2x to add features to the bed12 annotation, in the col4 name
#Version: Yu H. Sun, 2020-04-29

if [ ! -n "$2" ]
then
  echo "*******************************************************************************************"
  echo "*                        Welcome to use BED12FeatureAdder.sh !                            *"
  echo "*This script mimics the bam2x to add a suffix to the bed12 annotation, in the col4 name   *"
  echo "*The original file will be modified                                                       *"
  echo "*This solves the confusion in gene names after CDS/UTR feature extraction                 *"
  echo "[Usage]: `basename $0` [Data.bed12] [Suffix of col4]                                      *"
  echo "[Output]: same file name with suffix (cds) added to col4, for example: col4_cds           *"
  echo "*******************************************************************************************"
else
  Data=$1
  Suffix=$2

  mv $Data ${Data}.toaddsuffixttt
  awk -v Suffix=$Suffix 'BEGIN{OFS="\t"}{$4=$4"_"Suffix;print $0}' ${Data}.toaddsuffixttt > ${Data}
  rm -rf ${Data}.toaddsuffixttt
fi
