##################################################################################################################
#This RScript creates batch files using a template. These batch scripts were run on RAMCC Summit Supercomputer 
#Sunetra Das
##################################################################################################################
#Read in the Template
x <- readLines("Inputs/MappingTemplate.txt")
x
#Reading in file where read group information is present. This text file was created by extracting the first line of fastq files using the following command in the terminal: zcat <filename> | head -n 1. I used the info from R1 files only. Here the fastq files are generated from Illumina sequencing. The location of information required for read group will change if different file types are used.
rgm <- readLines("Inputs/FastqInfo.txt")

#Remove blank lines ()
rgm = rgm[rgm != ""]
rgm

#number of lines in the FastqInfo File
numl <- length(rgm) 

#Reading the sample nomenclature 
file.names <- read.csv("Inputs/SampleIds.csv", check.names = FALSE, stringsAsFactors = FALSE)

#For each run change the following and then run the code
#date
date <- Sys.Date()

#Change these variables to appropriate project and batch script file names and location
#Project id
project.id <- c("OsteosarcomaWES")

#File extensions and location 
foldername = c("Outputs/")
fexten = paste0("_", project.id, "_Mapping.job")
sbatchFileName <- paste0(foldername, date, "_",project.id,"_MappingJobSubmissionCommands.txt")

##################################################################################################################
#Run this loop generate batch script files for mapping of each sample fastq files
##################################################################################################################

for(i in seq(1,numl,by=2)){
  #extracting the trimmed file name which is the input for BWA mapping 
  fname = gsub(" \\| head", "", strsplit(rgm[i], "zcat ") [[1]] [2])
  fname = gsub (" -n 1", "", fname)
  #Remove Leading/Trailing Whitespace
  fnameR1=trimws(fname)
  #Getting the the R2 filename
  fnameR2 <- gsub(pattern = "_R1", replacement = "_R2", x = fnameR1)
  #Substitute the word "fnameR1" and "fanmeR2" in the template
  x.mod <- gsub("fnameR1", fnameR1, x)
  x.mod <- gsub("fnameR2", fnameR2, x.mod)
  #Extracting sample names  
  fname.code = file.names$`Final SampleID for downstream analyses`[file.names$`Trimmed file name` %in% fname]
  #Substitute the word "fname.code" in the template 
  x.mod <- gsub("fname.code", fname.code, x.mod)
  #Here the unique adaptor and lane number for each library is extracted from the next line in fastqInfo
  rg = strsplit(rgm[1+i], ":") [[1]] [c(10,4)]
  #Here the two information extracted are pasted together separated with a "." 
  rg = paste0(rg[1],".",rg[2])
  #Subtituting the above information in the template 
  x.mod = gsub("rg.lane", rg, x.mod)
  
  #Creating RG_ID
  fname.id <- strsplit(rgm[1+i], ":") [[1]] [c(1)]
  #Subtituting "fname.id" in the template 
  x.mod = gsub("fname.id", fname.id, x.mod)
  #Creating library id (to demarcate sequencing batches) 
  lib.code <- paste0("lib", file.names$`Library number`[file.names$`Trimmed file name` %in% fnameR1])
  #Subtituting "lib.code" in the template 
  x.mod = gsub("lib.code", lib.code, x.mod)
  
  #Subtituting the date in the template 
  x.mod = gsub("insert.date", date, x.mod)
  
  #Substituting project name in the template
  x.mod = gsub("project.id", project.id, x.mod) 
  
  #Output of the substituted template as a batch script for running on RAMCC Summit Supercomputer
    b=paste0(foldername , fname.code, fexten, sep="")
    c=paste0(fname.code, fexten)
    cat(x.mod,file=b,sep="\n")
    cat (paste("sbatch ", c),
         file=sbatchFileName, sep="\n", append = TRUE)
  #prints out the varaibles 
  print(fnameR1)
  print(rg)
  print(lib.code)
  print(project.id)
  print(fname.code)
}

##################################################################################################################
##################################################################################################################
#Run this loop when no information from fastq is needed to be substituted in the template
##################################################################################################################
#Reading in the template - this job calls Somatic variants using Mutect2
x <- readLines("Inputs/Mutect2Template.txt")
x
#Change these variables to appropriate project and batch script file names and location
#Project id
project.id <- c("OsteosarcomaWES")

#File extensions and location 
foldername = c("Outputs/")
fexten = paste0("_", project.id, "_Mutect2.job")
sbatchFileName <- paste0(foldername, date, "_",project.id,"_Mutect2JobSubmissionCommands.txt")

for(i in 1:length(file.names$`Final SampleID for downstream analyses`)){
  # extract sample id
  fname.code = file.names$`Final SampleID for downstream analyses`[i]
  normal.name = file.names$`Normal ID`[i]
  #Subtituting the date in the template 
  x.mod = gsub("insert.date", date, x.mod)
  #Subtituting "fname.code" in the template
  x.mod <- gsub("fname.code", fname.code, x)
  #Subtituting "normal.name" in the template
  x.mod <- gsub("normal.name", normal.name, x.mod)
  #Subtituting "project.id" in the template
  x.mod <- gsub("project.id", project.id, x.mod)
  #Output of the substituted template as a batch script for running on RAMCC Summit Supercomputer
  b=paste0(foldername , fname.code, fexten, sep="")
  c=paste0(fname.code, fexten)
  cat(x.mod,file=b,sep="\n")
  cat (paste("sbatch ", c),
       file=sbatchFileName, sep="\n", append = TRUE)
  #Printing variables
  print(fname.code)
  print(normal.name)
}

##################################################################################################################
##################################################################################################################
