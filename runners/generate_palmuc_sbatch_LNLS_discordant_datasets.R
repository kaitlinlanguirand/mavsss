if (!require("optparse")) {install.packages("optparse", repos = "https://cloud.r-project.org")}
library(optparse)

option_list = list(
  make_option(c("-a", "--alpha"), type = "double", default = NULL,
              help = "Concentration parameter of the Dirichlet distribution", metavar = "double")
)

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

##############################################################
# Generate SLURM batch files for just those datasets we need #
##############################################################

dd <- read.csv("/home/dcerny/mavsss/Long_rjMCMC_vs_LNSS_discordant_datasets.csv")

parse.path <- function(filename) {
  full_path <- system(paste0('cd /home/dcerny/mavsss/datasets && find . -name "', filename, '"'),
                      intern = T)
  splt <- strsplit(full_path, "/")[[1]]
  return(data.frame( dir = splt[2], name = paste(splt[1], splt[3], sep = "/") ))
}

parsed_lst <- Map(parse.path, dd[, 1])
parsed_df <- do.call(rbind, parsed_lst)
rownames(parsed_df) <- NULL

# For alpha = 0.05, we discard the datasets from batches 1 and 2, which we have already run
if (opt$alpha == 0.05) {
  parsed_df <- parsed_df[!parsed_df$dir %in% c(1, 2), ]
}

Map(\(x, y) system( paste0('cd /home/dcerny/mavsss/runners && ',
                           'Rscript ./generate_palmuc_sbatch_LNLS.R -s "', x, '" -d "', y,
                           '" -a ', opt$alpha) ),
    x = parsed_df$dir, y = parsed_df$name)