QUERY=binary_basecall.fasta
REF=binary_sequence.fasta

makeblastdb -in  $REF -parse_seqids -dbtype 'nucl' 

blastn  -task blastn -db $REF  -num_threads 6 -query $QUERY -out $QUERY.1211.vs.binary_sequence.xml -evalue 1000 -word_size 7 -max_target_seqs 1 -max_hsps 1 -reward 1 -penalty -2 -gapopen 1 -gapextend 1  -outfmt 5

blastn  -task blastn -db $REF  -num_threads 6 -query $QUERY -out $QUERY.1211.vs.binary_sequence.csv -evalue 1000 -word_size 7 -max_target_seqs 1 -max_hsps 1 -reward 1 -penalty -2 -gapopen 1 -gapextend 1  -outfmt "10 sseqid sstart send qseqid qlen qstart qend sframe bitscore evalue pident length"

## convert fasta to fastq     uploaded to :  /gennas/Anna/from_mohammad
perl fasta_to_fastq.pl binary_basecall.fasta>binary_basecall.fq

## https://github.com/guyduche/Blast2Bam

blast2bam -c binary_basecall.fasta.1211.vs.binary_sequence.xml binary_sequence.fasta binary_basecall.fq>binary_basecall.fasta.1211.vs.binary_sequencee1000_1211.sam

CSV=binary_basecall.fasta.1211.vs.binary_sequence.csv

awk -F "," '{ if($10 < 0.001 && $12 >= 30) print }' $CSV | tr ',' $'\t' > tmp

SAM=binary_basecall.fasta.1211.vs.binary_sequencee1000_1211.sam

awk '{ if($1 !~ /^@/)print }' $SAM > tmp2

join -1 4 -2 1 -t $'\t' -a 1 <(sort -k4,4 tmp) <(sort -k1,1 tmp2) > tmp3.txt

awk '{print $1,$13,$2,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26 }' tmp3.txt>output.sam

## You may need to add the SAM header copied from binary_basecall.fasta.1211.vs.binary_sequencee1000_1211.sam

sam_file_name="output"
#awk '!/^@/ { t = $1; $1 = $3; $3 = t; print; } ' ${sam_file_name}.sam>${sam_file_name}.reordered.sam
samtools view -bS -o  ${sam_file_name}.bam ${sam_file_name}.sam
samtools sort ${sam_file_name}.bam -o ${sam_file_name}.sorted.bam
samtools index ${sam_file_name}.sorted.bam ${sam_file_name}.sorted.bam.bai