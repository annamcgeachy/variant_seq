#!/bin/bash

WATER=/gennas/Anna/from_mohammad/water
SAMTOOLS=samtools
DIR=/home/anna/variant-analysis

REF=$DIR/ampliseq_genome/ampliseq_207_binary.fasta
QUERY=$DIR/binary_basecall.fasta

#OUTPUT=$DIR/binary_basecall_mean_Rec_Ntrick_170801_B_call_+0+0_-07-07_unique_modifiedheader.12.water.sam
OUTPUT=$DIR/binary_basecall.water.sam
max=1

# ------------------------------------------------------------------------------

# Launch Emboss in parallel (n jobs at a time, n = #CPUs)
i=0
currRead=""
currReadName=""
currReadSeq=""
tmpfile1=$(mktemp emboss-tmp-1-XXXXX.txt)
tmpfile2=$(mktemp emboss-tmp-2-XXXXX.txt)
echo -n "" > ${OUTPUT}.tmp
echo -n "" > ${OUTPUT}
while read line;
do
  if [[ "$i" == "0" ]]; then
    currRead=$line
    currReadName=${line//>}
    i=1
  elif [[ "$i" == "1" ]]; then
    currRead=${currRead}"\n"${line}
    currReadSeq=${line}
    i=0

    PARAMS=""
    PARAMS=${PARAMS}" -auto -stdout -aformat sam"
    PARAMS=${PARAMS}" -gapopen 1 -gapextend 1"
    PARAMS=${PARAMS}" -datafile EDNASIMPLE12.txt"
    PARAMS=${PARAMS}" -bsequence $QUERY"

    $WATER $PARAMS -asequence <(echo -e $currRead)            > ${tmpfile1} &
    $WATER $PARAMS -asequence <(echo -e $currRead) -sreverse2 > ${tmpfile2} &

    wait

    echo -e "@SQ\tSN:${currReadName}\tLN:${#currReadSeq}" >> ${OUTPUT}

    cat $tmpfile1 $tmpfile2 >> ${OUTPUT}.tmp
  fi
done < $REF

#rm $tmpfile1 $tmpfile2


# Find top N from SAM file
grep -vE '^@' $OUTPUT.tmp | \
\
sort -T /home/anna/variant-analysis -r -Vk1,1 -Vk12,12 | \
\
awk -v max=${max} '\
BEGIN \
{
    sensor_prev=""
    sensor_curr=""
    n=0
}{
    # If current sensor is different, reset counter
    sensor_curr = $1
    if(sensor_curr != sensor_prev)
        n = 0
    # If too many outputs already, skip this line
    if(n >= max)
        next;
    # If reach here, print and increment counter
    n++
    print
    sensor_prev = sensor_curr
}' >> $OUTPUT

#rm $OUTPUT.tmp

# Create BAM file
$SAMTOOLS view -bS -o ${OUTPUT//.sam/.bam} ${OUTPUT}
$SAMTOOLS sort ${OUTPUT//.sam/.bam} -o ${OUTPUT//.sam/.sorted.bam}
$SAMTOOLS index ${OUTPUT//.sam/.sorted.bam} ${OUTPUT//.sam/.sorted.bam}.bai