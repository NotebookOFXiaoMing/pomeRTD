library(tidyverse)
library(data.table)

input_folder = snakemake@input[['sjsfolder']]
output_file = snakemake@output[['sjsfilter']]

list.files(input_folder,
            pattern = "*_SJ.out.tab",
            recursive = TRUE,
            full.names = TRUE) %>%
            map(read_tsv,col_names=FALSE,show_col_types=FALSE) %>%
            bind_rows() %>%
            filter(X5>0&X7>2&X6==0) %>%
            select(1:6) %>%
            arrange(across(everything())) %>%
            distinct() %>%
            #write.table(file=output_file,sep="\t",col.names = FALSE,quote=FALSE)
            fwrite(file=output_file,sep="\t",col.names=FALSE,quote=FALSE)
