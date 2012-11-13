#!/usr/bin/R
#Author: Sarven Capadisli <info@csarven.ca>
#Author URL: http://csarven.ca/#i

args <- commandArgs(TRUE)
argv <- length(args)
#if (is.null(argv) | length(argv)<1) {
#  cat("Usage: installr.r pkg1 [pkg2 pkg3 ...]0")
#  q()
#}
#print(args)

library(ggplot2)
indicators <- read.csv("indicators-notations-prefLabels.csv", header=T)

files <- dir("data/", "*.csv")
for (f in files) {
    data <- read.csv(paste("data/", f, sep=""), header=T)
    results <- cor(data, use="complete.obs", method="pearson")
    cat(paste(f, results[2], sep=","), file="coefficients.csv", sep="\n", append=TRUE)

    n <- substr(f, 0, nchar(f, type="chars")-9)

    title <- paste(indicators[indicators$notation == n,2], "2010", sep=", ")

    ggsave(ggplot(data, aes(indicatorValue, CPIRank)) + geom_point() + stat_smooth() + ggtitle(title), file=paste("charts/", f, ".svg", sep=""))
}
