# Bed12Processing
This repository contains a set of Bash and Python3 scripts related to bed12 (or bed3, bed4) data processing

## BED12Extractor.sh
![](images/GeneStructure.png)

This script extracts 5’UTR, 3‘UTR, CDS or intron from a BED12 file

[Usage]: BED12Extractor.sh -a [utr5|cds|utr3|intron] -i [In.bed12] -o [Out.bed12]

[Output]: A new file in bed12 format

```
BED12Extractor.sh -a cds -i data/mm10.mRNA.bed12 -o data/mm10.mRNA.cds.bed12
BED12Extractor.sh -a utr3 -i data/mm10.mRNA.bed12 -o data/mm10.mRNA.utr3.bed12
BED12Extractor.sh -a utr5 -i data/mm10.mRNA.bed12 -o data/mm10.mRNA.utr5.bed12
BED12Extractor.sh -a intron -i data/mm10.mRNA.bed12 -o data/mm10.mRNA.intron.bed12
```

## BED12FeatureAdder.sh

This script adds a suffix to the end of all names in column 4

This is specially useful after feature extraction since CDS or UTR extracted data keep same transcript names

[Usage]: BED12FeatureAdder.sh [Data.bed12] [Suffix of col4] 

[Output]: The original file will be updated, with suffix added to column 4

```
BED12FeatureAdder.sh data/mm10.mRNA.cds.bed12 cds
```

## BED12LeftRightExtender.py

![](images/BorderExtension.png)

This script takes bed12 as input, extend column 2 and column 3 borders, and change column 11 and 12 accordingly

[Usage]: [BED12LeftRightExtender.py] [Gene.bed12] [LeftExtension] [RightExtension] [Output.ext.bed12]

[Output]: A new bed12 file

```
python3 BED12LeftRightExtender.py data/mm10.mRNA.bed12 100 200 data/mm10.mRNA.Left100Right200.Ext.bed12
```
