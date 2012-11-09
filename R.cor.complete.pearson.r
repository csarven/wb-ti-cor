#!/usr/bin/R
#Author: Sarven Capadisli <info@csarven.ca>
#Author URL: http://csarven.ca/#i

library(ggplot2)
files <- dir("data/", "*.csv")
for (f in files) {
    data <- read.csv(paste("data/", f, sep=""), header=T)
    results <- cor(data, use="complete.obs", method="pearson")
    cat(paste(f, results[2], sep=","), file="coefficients.csv", sep="\n", append=TRUE)
    p <- ggplot(data, aes(indicatorValue, CPIRank))
    ggsave(p + geom_point(), file=paste("charts/", f, ".jpg", sep=""), scale=0.5)
}
