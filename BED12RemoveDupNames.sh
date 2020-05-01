#!/usr/bin/env bash
#BED12DupNameIDGenerator.sh
#This pipeline takes a bed12 file as input, add _1, _2, ... ids on column 4, for duplicated col4 items.
#This script can be used to rename uAUG, uCUG ORF ids.
#Version: Yu H. Sun, 2019-07-16

if [ ! -n "$1" ]
then
  echo "**********************************************************************************************"
  echo "*                          Welcome to use BED12DupNameIDGenerator.sh                         *"
  echo "*This pipeline takes a bed12 file as input, add _1, _2, ... on column 4, for duplicated col4 *"
  echo "*[Usage]: `basename $0` [Data|File in bed12 format] [OutputName]                    *"
  echo "*This script can be used to rename uAUG, uCUG ORF ids                                        *"
  echo "*Please make sure col4 names are clustered, because this script won't run sort command       *"
  echo "**********************************************************************************************"
else
  Data=$1
  Output=$2
  rm -rf $Output
  touch $Output

  echo "1. Getting list"
  awk '{print $4}' $Data |uniq > $Data.runlist
  NowLine=`wc -l $Data.runlist|awk '{print $1}'`
  UniLine=`awk '{print $4}' $Data |sort|uniq|wc -l`
  echo $NowLine,$UniLine
  if [[ $NowLine -eq $UniLine ]];then
      echo "   Data names are clustered. Run further analysis"
  else
      echo "   Data names are not clustered. please sort by col4!"
      exit 1
  fi

  echo "2. Looping through the ids"
  
  for name in `cat $Data.runlist`
  do
      echo $name
      awk -v t=$name '{OFS="\t";if ($4==t) print $0}' $Data > ${Data}.${name}
      GetLines=`wc -l ${Data}.${name}|awk '{print $1}'`
      for i in $(eval echo {1..$GetLines});do echo "_"$i;done > ${Data}.${name}.id
      awk '{print $4}' ${Data}.${name} > ${Data}.${name}.name
      awk '{OFS="\t";print $1,$2,$3}' ${Data}.${name} > ${Data}.${name}.col1-3
      paste -d"\0" ${Data}.${name}.name ${Data}.${name}.id > ${Data}.${name}.col4
      awk '{OFS="\t";print $5,$6,$7,$8,$9,$10,$11,$12}' ${Data}.${name} > ${Data}.${name}.col12
      paste ${Data}.${name}.col1-3 ${Data}.${name}.col4 ${Data}.${name}.col12 > ${Data}.${name}.new
      cat ${Data}.${name}.new >> ${Output}

      rm -rf ${Data}.${name} ${Data}.${name}.name ${Data}.${name}.id ${Data}.${name}.col1-3 ${Data}.${name}.col4 ${Data}.${name}.col12 ${Data}.${name}.new
  done

  rm -rf $Data.runlist

fi
