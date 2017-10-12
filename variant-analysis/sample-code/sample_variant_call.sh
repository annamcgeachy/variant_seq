
Variant calling using samtools:

samtools mpileup -ugf ref.fasta aligned.sorted.bam | bcftools call -vmO z -o variants.vcf.gz


Exporting IGV stats:

./igvtools count -w 1 --bases --strands read --includeDuplicates input.sorted.bam output.wig ref.fasta
