library(ggplot2)
library(ggrepel)

setwd("/Users/David/Grive/mavsss/output/")

read.ss <- function(path) {
  tmp <- readLines(path)
  # v1.2.1 output only includes 1 line: the MLE itself
  if (length(tmp) == 1)
  {
    return( as.numeric(tmp[1]) )
  }
  # v 1.4.2-preview output includes 2 lines: the MLE and its standard error
  else
  {
    return( data.frame(MLE = as.numeric(tmp[1]), SE = as.numeric(tmp[2])) )
  }
}

old <- list.files("ss100_v1.2.1", pattern = "*.ss", recursive = T, full.names = T)
new <- list.files("ss100_v1.4.1", pattern = "*.ss", recursive = T, full.names = T)

df <- cbind( sapply(old, read.ss), do.call(rbind, Map(read.ss, new)) )
df$label <- basename( rownames(df) )
df$label <- gsub("_alpha10_gen10000.ss", "", df$label)
df$label <- sapply(strsplit(df$label, "_"), \(x) paste(x, collapse = " "))
colnames(df) <- c("old_MLE", "new_MLE", "new_SE", "label")

# Get outliers
mask <- unlist(Map(\(x, y) abs(x - y) < abs(0.01 * (x + y)/2), x = df$old_MLE, y = df$new_MLE))
df$label[mask] <- NA

pdf("RevBayes_version_comparison.pdf", width = 10, height = 7.5)
  ggplot(df, aes(old_MLE, new_MLE)) +
    geom_point() +
    geom_errorbar(aes(ymin = new_MLE - new_SE, ymax = new_MLE + new_SE), width = 0.2) +
    geom_text_repel(aes(label = label), na.rm = TRUE) +
    geom_abline(slope = 1, intercept = 0, alpha = 0.3) +
    labs(x = "MLE using v1.2.1", y = "MLE using v1.4.2-preview") +
    theme_bw()
dev.off()