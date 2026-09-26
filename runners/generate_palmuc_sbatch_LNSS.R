if (!require("optparse")) {install.packages("optparse", repos = "https://cloud.r-project.org")}
library(optparse)

option_list = list(
  make_option(c("-s", "--subdir"), type = "character", default = NULL, 
              help = "Subdirectory number", metavar = "character"),
  make_option(c("-d", "--dataset"), type = "character", default = NULL, 
              help = "Nexus file name (incl. file ending)", metavar = "character"),
  make_option(c("-a", "--alpha"), type = "double", default = NULL,
              help = "Concentration parameter of the Dirichlet distribution", metavar = "double")
)

opt_parser = OptionParser(option_list = option_list)
opt = parse_args(opt_parser)

# Strip the string of the leading "./", and of the file ending
path <- gsub("^./", "", opt$dataset)
dataset <- gsub(".nex.clean", "", path)

# Convert the alpha value to a string and strip it of the decimal dot
tag <- gsub("\\.", "", opt$alpha)

sbatch_vect <- vector()
sbatch_vect[1] <- "#!/bin/bash"

sbatch_vect[2] <- ""

sbatch_vect[3] <- paste0("#SBATCH --job-name=", dataset, "_", tag, "_LNSS")
sbatch_vect[4] <- paste0("#SBATCH --output=", dataset, "_", tag, "_LNSS.out")
sbatch_vect[5] <- paste0("#SBATCH --error=", dataset, "_", tag, "_LNSS.err")
sbatch_vect[6] <-        "#SBATCH --partition=lemmium"
sbatch_vect[7] <-        "#SBATCH --nodes=1"
sbatch_vect[8] <-        "#SBATCH --ntasks=50"          # 2 stones per CPU
sbatch_vect[9] <-        "#SBATCH --cpus-per-task=1"
sbatch_vect[10] <-       "#SBATCH --mem-per-cpu=2G"
sbatch_vect[11] <-       "#SBATCH --time=27-23:59:59"   # maximum for normal-priority jobs
sbatch_vect[12] <- ""

sbatch_vect[13] <- "module load gnu/12"
sbatch_vect[14] <- "module load openmpi/4.1.6"
sbatch_vect[15] <- "module load boost/1.82.0"

sbatch_vect[16] <- ""

sbatch_vect[17] <- "cd /home/dcerny/mavsss"

# Using RevBayes v1.4.2-preview, up-to-date as of 2026-09-18
sbatch_vect[18] <- paste0('mpirun -np 50 ../revbayes-4166bad/projects/cmake/build-mpi/rb-mpi ',
                          './scripts/large_number_small_stones.Rev "', opt$subdir, '" "',
                          dataset, '" ', opt$alpha)

write(sbatch_vect, file = paste0("/home/dcerny/mavsss/analysis/", opt$subdir, "_", dataset, "_",
                                 tag, "_LNSS.sbatch"))

# We do not automatically execute the batch script after writing it out
