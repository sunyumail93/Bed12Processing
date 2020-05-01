#!/usr/bin/env bash
#BED12TranslateAddORF.sh
#This is a pipeline that takes Gene annotation and ORF genomic bed4 (first 4 columns from BED12TranslateTx2GenomePos.sh) as input
#It will loop through the names of Transcripts, and match the full RNA using Annotation, and add the ORF into col7 and col8
#This will only change col7 and col8 in Annotation
#Tx genomic data can have duplicates, while it's better to remove duplication in Annotation (or it will output multiple records)
#Version: Yu H. Sun, 2018-10-02

array=( "$@" )
if [ ! -n "$1" ]
then
  echo "****************************************************************************************************************"
  echo "*                                Welcome to use BED12TranslateAddORF.sh !                                      *"
  echo "*This pipeline that takes ORF genomic bed4 (first 4 columns from BED12TranslateTx2GenomePos.sh) as input       *"
  echo "*It loops through the names of Transcripts, matchs the full RNA using Annotation, and adds the ORF into col7-8 *"
  echo "*[Usage]: `basename $0` -i [Genes.bed12] -t [GenomePos.bed4|chr start end TxName] -o [Output.bed12]  *"
  echo "*[Output]: A bed12 annotation file with new orfs added. The ones that don't have new orfs WON'T be output      *"
  echo "*Tx genomic data allow duplicates, while it's better to remove duplication in Annotation                       *"
  echo "*    or it will output multiple records). This will only change col7 and col8 in Annotation                    *"
  echo "****************************************************************************************************************"

else
  echo "Starging BED12TranslateAddORF.sh pipeline"
  echo "1. Getting arguments"

for arg in "$@"
do
 if [[ $arg == "-i" ]]
  then
    Anno=${array[$counter+1]}
    echo '   Getting annotation: '$Anno
 elif [[ $arg == "-t" ]]
  then
    Data=${array[$counter+1]}
    echo '   Getting GenomePos bed: '$Data
 elif [[ $arg == "-o" ]]
  then
    Output=${array[$counter+1]}
    echo '   Getting output name: '$Output
 fi
  let counter=$counter+1
done

  echo "2. Parsing orfs"
rm -rf $Output
RecordNumber=`wc -l $Data|awk '{print $1}'`
for i in $(eval echo {1..$RecordNumber})
do
  Tx=`sed -n ${i}p $Data`
  chr=`echo $Tx | awk '{print $1}'`
  Name=`echo $Tx | awk '{print $4}'`
  GenoStart=`echo $Tx | awk '{print $2}'`
  GenoEnd=`echo $Tx | awk '{print $3}'`
  CurrAnno=`awk -v name=$Name -v chr=$chr '{if ($4==name && $1==chr) print $0}' $Anno`

  echo $CurrAnno | awk -v GenoStart=$GenoStart -v GenoEnd=$GenoEnd 'BEGIN{OFS="\t"}{$7=GenoStart;$8=GenoEnd;print $0}' >> $Output

done

if [ -s $Output ]
  then
    echo "3. Done"
else
   echo "Error occurred!"
fi

fi
