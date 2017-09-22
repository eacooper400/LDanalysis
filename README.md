# Linkage Disequilibrium Analysis

### Convert Data into Diploid Genotypes Format

This is the format taken as input by R's 'genetics' package.  If you have data starting in the HapMap format (used by ![TASSEL](http://www.maizegenetics.net/tassel), you can use the script `hmp2diploid.pl`.  You should only run the LD analysis on 1 chromosome at a time (and I recommend using an even smaller window if possible, especially if you have a lot of SNPs).  The `hmp2diploid.pl` script will let you automatically specify a region when making the diploid format input file.

```perl
./hmp2diploid.pl <input.hmp.txt> <output.diploid.txt> <chr> <start> <end>
		input.hmp.txt = The input file in hapmap format
		output.diploid.txt = The output file in R genetics format to be created
		chr = The chromosome to extract genotypes from
		start = The start position of the region to extract genotypes from
		end = The end position of the region to extract genotypes from

```

In the example below, I'm using the script to get the first 2Mb of chromosome 7 in my input file:
```perl
./hmp2diploid.pl input.hmp output.diploid.txt 7 0 2000000
```

### Run the pairwiseLD.R script on the input files

Once you have the correct input format, you can run the LD analysis provided in R's `genetics` package using the pairwiseLD.R script.  This script will return a tab-delimited text file with the distance between every position pair in column 1, and the r-squared value for every position pair in column 2.  If you want different output, you can modify the script.  If you don't need to change anything, you can run the script from the command line like this:

```bash
R --vanilla --slave --args input.diploid.txt output.rsq.txt <pairwiseLD.R
```

The first arguments (after `--args` is the name of the input file, followed by the name of the output file, then the name of the script to run.

### Bin the values to get a moving average

Before plotting, it is strongly recommened to bin the values (by distances of 100bp increments, or more if desired) in order to be able to see the curve of LD decay without as much noise.  To do this you can use the script `calcLDbins.R`:

```bash
R --vanilla --slave --args input.rsq.txt output.bins.txt 100 <calcLDbins.R
```

The first argument after `--args` is the name of the input file, which should be the output file from the pairwiseLD.R.  The next argument is the name of the output file, followed by the desired bin size (in base pairs), followed by the name of the script.

This script will output a tab-delimited text file with 3 columns: The start position of the bin, the end position of the bin, and the mean r-squared value for that bin.

### Plot the Decay with Distance

Here is a simple R script for reading in multiple bin files (from multiple chromosomes), and plotting the decay with distance for each in a different color:

```r
bin.files = list.files(pattern="*.bins.txt")
num.files = length(bin.files)
install.packages("RColorBrewer")
library(RColorBrewer)
plot.col = brewer.pal(n=num.files, "Paired")

for (i in seq_along(bin.files)) {
	dat <- read.table(bin.files[i], header=TRUE)
	if (i==1) {
	plot(dat$Start, temp.dat$MeanRsq, xlim=c(0,100000), main="Decay of Linkage Disequilibrium", xlab="Distance between Markers (bp)", ylab="R-squared", col=plot.col[i], pch=20)
	} else {
	points(dat$Start, dat$MeanRsq, col=plot.col[i], pch=20)
	}
}
```
