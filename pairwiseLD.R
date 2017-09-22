### June 26, 2014
### Liz Cooper
### Calculate pairwise R-squared between all SNPs in a file
### save R-squared and distance values

### Read in the diploid genotypes file and an output filename from the command line
### R --vanilla --slave --args Filename.txt Outfile.txt <pairwiseLD.R

### Load the genetics library
install.packages("genetics", repos="https://cran.r-project.org")
library(genetics)

### Read in the input file, and save a list of chromosomes (w/ sig. SNPs) to process
my.data <- read.table(file=commandArgs()[5], stringsAsFactors=FALSE, header=FALSE)
outfile <- commandArgs()[6]

### Get rid of sites with too many NA values,
### Or more than 2 alleles
### Convert the rest to genotype objects
### Save the positions in a new vector
saved.pos = c()
filtered.genotypes = vector("list", nrow(my.data))
for (i in 1:nrow(my.data)) {
    l1 <- unlist(strsplit(my.data[i,3], ","))
    l2=l1[-(grep("NA", l1))]
    if (length(l2)>5) {
        g1 = genotype(l1)
        n1 = nallele(g1)
        if (n1 == 2) {
            filtered.genotypes[[i]]=g1
            saved.pos=append(saved.pos, my.data[i,2])
        }
    }
}
filtered.genotypes=filtered.genotypes[sapply(filtered.genotypes, length)>0]
### For each pair of saved genotypes
### Get the distance between positions
### and the r-squared value 
for (i in 1:((length(saved.pos))-1)){
    p1 <- saved.pos[i]
    g1 <- filtered.genotypes[[i]]
    for (j in (i+1):length(saved.pos)){
        p2 <- saved.pos[j]
        dist <- abs(p2 - p1)
        g2 <- filtered.genotypes[[j]]
        df <- data.frame(g1)
        df <- cbind(df, g2)
        data <- makeGenotypes(df)
        LD.saved <- LD(data)
        rtable <- LD.saved[[4]]
        rvalue <- rtable[1,2]
        output <- c(dist, rvalue)
        write(output, file=outfile, append=TRUE)
    }
}
    




