#!/usr/bin/env bash
#BED12Extractor.sh
#This script extracts 5’UTR, 3‘UTR, CDS or intron from a BED12 file
#This script reads column 7-8 for ORF start and end, and uses column 11-12 for splicing info
#The awk commands were adapted from the following links:
#http://onetipperday.sterding.com/2012/11/get-intron-utr-cds-from-bed12-format.html
#https://github.com/sterding/BRAINcode/blob/master/bin/bed12toAnnotation.awk
#Version: Yu H. Sun, 2017-12-04
#Version: Yu H. Sun, 2019-07-17, if cds annotation has error ($7<$2 or $8>$3), skip the lines

array=( "$@" )
if [ ! -n "$6" ]
then
  echo "****************************************************************************************"
  echo "*                       Welcome to use BED12Extractor.sh !                             *"
  echo "*       This script extracts 5’UTR, 3‘UTR, CDS or intron from a BED12 file             *"
  echo "*[Usage]: `basename $0` -a [utr5|cds|utr3|intron] -i [In.bed12] -o [Out.bed12]     *"
  echo "*[Output]: A new file in bed12 format                                                  *"
  echo "*This script reads column 7-8 for ORF start and end, column 11-12 for splicing info    *"
  echo "*For lncRNA, utr and cds are not defined (and sometimes they are same as col2 ans col3)*"
  echo "*So it is required filter out lncRNAs (col7=col8) before running this script           *"
  echo "*Some mRNAs don't have UTRs, and they will be discarded when extracting UTRs           *"
  echo "****************************************************************************************"
else
  echo "Starting BED12Extractor.sh pipeline"
  echo "1. Getting parameters"

for arg in "$@"
do
 if [[ $arg == "-a" ]]
  then
    Anno=${array[$counter+1]}
    echo '   Extract annotation: '$Anno
 elif [[ $arg == "-i" ]]    
  then
    Data=${array[$counter+1]}
    echo '   Getting input: '$Data
 elif [[ $arg == "-o" ]]
  then
    Output=${array[$counter+1]}
    echo '   Getting output name: '$Output
 fi
  let counter=$counter+1
done

  echo "2. Extracting annotation"
  
if [[ $Anno == "utr5" ]]
  then
    echo "   Extracting utr5"
    cat $Data |awk '{OFS="\t";split($11,blockSizes,","); split($12,blockStarts,","); blockCount=$10;A=""; B=""; 
           if($7==$8) next;
           N=0;
           if($6=="+" && $2<$7) {
                start=$2;end=$7; 
                for(i=1;i<=blockCount;i++) if(($2+blockStarts[i]+blockSizes[i])<=$7) {
                   A=A""blockSizes[i]",";B=B""blockStarts[i]","; end=($2+blockStarts[i]+blockSizes[i]); N++;} 
                   else { 
                      if(($2+blockStarts[i])<$7) {A=A""($7-$2-blockStarts[i])",";B=B""blockStarts[i]","; N++; end=$7;} 
                      break; 
                   } 
                print $1,start,end,$4,$5,$6,start,end,$9,N,A,B;
           } if($6=="-" && $8<$3) {
                start=$8;end=$3; 
                for(i=1;i<=blockCount;i++) if(($2+blockStarts[i])>=$8) {
                   if(start==0) {A=blockSizes[i];B=0; start=$2+blockStarts[i];} 
                   else {A=A","blockSizes[i];B=B","($2+blockStarts[i]-start);} N++;
                   } else { 
                     if(($2+blockStarts[i]+blockSizes[i])>$8) {
                       A=($2+blockStarts[i]+blockSizes[i]-$8);B=0; N++; start=$8;} 
                     if(($2+blockStarts[i]+blockSizes[i])==$8) start=0;} 
                 print $1,start,end,$4,$5,$6,start,end,$9,N,A,B;}}' \
        > $Output

elif [[ $Anno == "cds" ]]
  then
    echo "   Extracting cds"
    cat $Data |awk '{OFS="\t";split($11,blockSizes,","); split($12,blockStarts,","); blockCount=$10; A=""; B="";N=0;
        if($7<$2 || $8>$3 || $7>$8 || $7==$8) next;
        for(i=1;i<=blockCount;i++) if(($2+blockStarts[i]+blockSizes[i])>$7 && ($2+blockStarts[i])<$8) {
          N++; 
          start=$2+blockStarts[i]-$7; size=blockSizes[i]; 
          if(($2+blockStarts[i])<=$7) {start=0;size=size-($7-($2+blockStarts[i]));} 
          if(($2+blockSizes[i]+blockStarts[i])>=$8) {size=size-($2+blockSizes[i]+blockStarts[i]-$8);} 
          A=A""size",";B=B""start",";
        } 
    print $1,$7,$8,$4,$5,$6,$7,$8,$9,N,A,B;}' \
        > $Output

elif [[ $Anno == "utr3" ]]
  then
    echo "   Extracting utr3"
    cat $Data |awk '{OFS="\t";split($11,blockSizes,","); split($12,blockStarts,","); blockCount=$10;A=""; B=""; 
    if($7==$8) next;N=0;
    if($6=="-" && $2<$7) {start=$2;end=$7; 
      for(i=1;i<=blockCount;i++) if(($2+blockStarts[i]+blockSizes[i])<=$7) {
           A=A""blockSizes[i]",";B=B""blockStarts[i]","; end=($2+blockStarts[i]+blockSizes[i]); N++;} 
           else { 
              if(($2+blockStarts[i])<$7) {A=A""($7-$2-blockStarts[i])",";B=B""blockStarts[i]","; N++; end=$7;} 
              break; } 
           print $1,start,end,$4,$5,$6,start,end,$9,N,A,B;} 
    if($6=="+" && $8<$3) {start=$8;end=$3; 
      for(i=1;i<=blockCount;i++) if(($2+blockStarts[i])>$8) {
           if(start==0) {A=blockSizes[i];B=0; start=$2+blockStarts[i];} 
              else {A=A","blockSizes[i];B=B","($2+blockStarts[i]-start);} N++; 
           } 
           else { 
           if(($2+blockStarts[i]+blockSizes[i])>$8) {
              A=($2+blockStarts[i]+blockSizes[i]-$8);B=0; N++; start=$8;
           } 
           if(($2+blockStarts[i]+blockSizes[i])==$8) start=0;} 
           print $1,start,end,$4,$5,$6,start,end,$9,N,A,B;}}' \
        > $Output

elif [[ $Anno == "intron" ]]
  then
    echo "   Extracting intron"
    cat $Data | awk '{OFS="\t";split($11,blockSizes,","); split($12,blockStarts,","); blockCount=$10; A=""; B="";N=0;
    if(blockCount>1) {
      for(i=1;i<blockCount;i++) {A=A""(blockStarts[i+1]-blockStarts[i]-blockSizes[i])",";B=B""(blockStarts[i]+blockSizes[i]-(blockStarts[1]+blockSizes[1]))",";} 
      print $1,$2+blockSizes[1], $3-blockSizes[blockCount], $4,$5,$6,$2+blockSizes[1], $3-blockSizes[blockCount],$9,blockCount-1,A,B;}}' > $Output
fi

if [ -s $Output ]
  then
    echo "3. Done"
else
  echo "Error occurred!"
fi
  
fi
