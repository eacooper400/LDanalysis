### June 26, 2014
### Liz Cooper
### Calculate LD bins from
### pairwise LD values

### Read in the diploid genotypes file and an output filename from the command line
### R --vanilla --slave --args Filename.txt Outfile.txt BinSize <calcLD_bins.R

my.data <- read.table(file=commandArgs()[5], stringsAsFactors=FALSE, header=FALSE)
outfile <- commandArgs()[6]
binSize <- as.numeric(commandArgs()[7])

### Find the bins
bins=seq(from=1, to=max(my.data$V1), by=100)

### A function to get the subset of data
### and return mean(LD) for a given bin
binLD <- function(start, end, LDdata) {
    x = LDdata[which(LDdata$V1>=start & LDdata$V1<end),]
    y = mean(x[,2])
    return(y)
}

### Run the function on all bins
bin.results = data.frame(Start=bins, End=(bins+binSize), MeanRsq=rep(0, length(bins)))
for (i in 1:nrow(bin.results)) {
    bin.results$MeanRsq[i] = binLD(bin.results$Start[i], bin.results$End[i], my.data)
}

write.table(bin.results, outfile, col.names=TRUE, row.names=FALSE, quote=FALSE, sep="\t")
