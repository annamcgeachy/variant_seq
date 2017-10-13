
####################### Un-collapse sam files ##########################

# Replace the following variables with appropriate ones for a given file:

collapsed.sam= "/Users/mahya/Downloads/binary_basecall_B000075_RUN_2017_6_22_16_35_17.R1P2N0G1E1.water.sam"
N=206   # number of rows in the header
output= "/Users/mahya/Downloads/Uncollapsed-binary_basecall_B000075_RUN_2017_6_22_16_35_17.R1P2N0G1E1.water.sam"


# Read in collapsed sam file and header:


collapsed<- read.table(collapsed.sam, skip=N)
head<- read.table(collapsed.sam, nrows = N)

# Uncollapse:

reps <- unlist(lapply(as.character(collapsed$V1), function(x) (as.numeric(strsplit(x,"count_")[[1]][2])) ))

SEQS=c()
for(i in 1:length(reps)){
    temp<- collapsed[i,]
    t<- as.data.frame(lapply(temp, rep, reps[i]))
    SEQS<- rbind(SEQS,t)
    cat(i,"\n")
}

# Add back header:
library("plyr")
Uncollapsed.sam<- rbind.fill(head, SEQS)

# Save output:
write.table(Uncollapsed.sam,output, na="", quote=FALSE, row.names=FALSE, col.names=FALSE, sep="\t")


