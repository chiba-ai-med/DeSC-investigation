library("RSQLite")
library("DBI")
library("data.table")
library("Rtsne")
library("Matrix")
library("irlba")
# library("GGally")
# library("ggplot2")

.NCOLUMNS <- c(7581, 215, 25)
names(.NCOLUMNS) <- c("small", "medium", "large")

.STARTPOSITION <- function(index, nrows){
	1 + (index - 1) * nrows
}

.skip.read.table <- function(infile, outfile,
	index=1, nrows=1000, size="large"){
	coo <- read.table(infile,
		skip=.STARTPOSITION(index, nrows), nrow=nrows)
	coo[,1] <- coo[,1] - max(coo[,1]) + 1
	sparseMatrix(
		i=coo[,1], j=coo[,2],
		x=rep(1, length=nrow(coo)),
		dims=c(nrow(coo), .NCOLUMNS[size])) |> writeMM(outfile)
}

fread(infile, stringsAsFactors=FALSE, sep="\t")


.lapply_pb <- function(X, FUN, ...)
{
 env <- environment()
 pb_Total <- length(X)
 counter <- 0
 pb <- txtProgressBar(min = 0, max = pb_Total, style = 3)

 # wrapper around FUN
 wrapper <- function(...){
   curVal <- get("counter", envir = env)
   assign("counter", curVal +1 ,envir=env)
   setTxtProgressBar(get("pb", envir=env), curVal +1)
   FUN(...)
 }
 res <- lapply(X, wrapper, ...)
 close(pb)
 res
}
