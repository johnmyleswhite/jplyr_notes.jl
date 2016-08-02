library("ggplot2")
library("dplyr")
library("reshape2")

perf <- read.csv("tmp.tsv", sep = "\t", header = FALSE)

names(perf) <- c("n", "Table", "Array", "r1", "r2")

p <- ggplot(
    melt(perf %>% select(n, Table, Array), id.vars = "n"),
    aes(x = n, y = value, color = variable)
) +
    geom_point() +
    scale_x_log10() +
    scale_y_log10() +
    xlab("Number of Rows on a Log Scale") +
    ylab("Total Latency in Seconds on a Log Scale") +
    ggtitle("Comparing Table + Macros Performance against Arrays + Functions") +
    guides(color = guide_legend(title = "Data Structure + API"))

ggsave("perf_comparison.png", height = 7, width = 10)
