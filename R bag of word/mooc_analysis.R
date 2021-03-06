# Text retrieval and search engine

# Analysis of the mooc dataset

# Load the data ####

allqueries  <- read.csv(file = "data/moocs-queries.txt", header = FALSE, stringsAsFactors=FALSE, sep = "\n")
colnames(allqueries) <- "Query"
allqueries$ID <- 1:nrow(allqueries)
trainqueries  <- subset(allqueries,ID <= 100)
testqueries <- subset(allqueries,ID >  100)

# Load stopwords list
# I removed the punctation from the list (treate separatly with "removePunctuation")
stopwords <- read.csv(file = "lemur-stopwords.txt", header = FALSE, stringsAsFactors=FALSE, sep = "\n", comment = "", quote="")
stopwords.char <- gsub(pattern = "\"", replacement = "", x = stopwords$V1, fixed = TRUE)

# Preparing the corpora ####
library(tm)

# process Test set
corpusTest <- Corpus(VectorSource(testqueries$Query))
corpusTest
corpusTest[[2]]

corpusTest = tm_map(corpusTest, tolower)
corpusTest = tm_map(corpusTest, PlainTextDocument)
corpusTest = tm_map(corpusTest, removePunctuation)
corpusTest = tm_map(corpusTest, removeWords, stopwords.char)
corpusTest = tm_map(corpusTest, stemDocument)

dtmTest    = DocumentTermMatrix(corpusTest)
dtmTest
inspect(dtmTest[1:5,1:5])
findFreqTerms(dtmTest, lowfreq=2)  # find words appearing at least n times
# dtmTest    = removeSparseTerms(dtmTest, .95)
dtmTest    = as.data.frame(as.matrix(dtmTest))
str(dtmTest)
top20count.test <- sort(colSums(dtmTest), decreasing = TRUE)[1:20]  # top 10 words
top20names.test <- names(top20count.test)
testresult <- data.frame(word = top20names.test, count = top20count.test)

# process Train set
corpusTrain <- Corpus(VectorSource(trainqueries$Query))
corpusTrain
corpusTrain[[2]]

corpusTrain = tm_map(corpusTrain, tolower)
corpusTrain = tm_map(corpusTrain, PlainTextDocument)
corpusTrain = tm_map(corpusTrain, removePunctuation)
corpusTrain = tm_map(corpusTrain, removeWords, stopwords.char)
corpusTrain = tm_map(corpusTrain, stemDocument)

dtmTrain    = DocumentTermMatrix(corpusTrain)
dtmTrain
inspect(dtmTrain[1:5,1:5])
findFreqTerms(dtmTrain, lowfreq=2)  # find words appearing at least n times
# dtmTrain    = removeSparseTerms(dtmTrain, .95)
dtmTrain    = as.data.frame(as.matrix(dtmTrain))
str(dtmTrain)
top20count.train <- sort(colSums(dtmTrain), decreasing = TRUE)[1:20]  # top 10 words
top20names.train <- names(top20count.train)
trainresult <- data.frame(word = top20names.train, count = top20count.train)

# results
write.csv(testresult, file = "test_topwords.csv", row.names=FALSE)
write.csv(trainresult, file = "train_topwords.csv", row.names=FALSE)


# Inspect queries ####
grep("learn", testqueries$Query, value=TRUE)
grep("learn", trainqueries$Query, value=TRUE)

grep("cours", testqueries$Query, value=TRUE)
grep("cours", trainqueries$Query, value=TRUE)

grep("data", testqueries$Query, value=TRUE, fixed = TRUE)
grep("data", trainqueries$Query, value=TRUE, fixed = TRUE)

# Analyse MOOC dataset ####

mooc  <- read.csv(file = "data/moocs.dat", header = FALSE, stringsAsFactors=FALSE, sep = "\n", quote = "")
colnames(mooc) <- "mooc_description"

corpusMooc <- Corpus(VectorSource(mooc$mooc_description))

corpusMooc
corpusMooc[[20400]]

corpusMooc = tm_map(corpusMooc, tolower)
corpusMooc = tm_map(corpusMooc, PlainTextDocument)
corpusMooc = tm_map(corpusMooc, removePunctuation)
corpusMooc = tm_map(corpusMooc, removeWords, stopwords.char)
# corpusMooc = tm_map(corpusMooc, stemDocument) # do not stem to analyse potential new stopwords

dtmMooc    = DocumentTermMatrix(corpusMooc)
dtmMooc
inspect(dtmMooc[1:5,1:5])
dtmMooc    = removeSparseTerms(dtmMooc, .90)
findFreqTerms(dtmMooc, lowfreq=10000)  # find words appearing at least n times

dtmMooc    = as.data.frame(as.matrix(dtmMooc))
str(dtmMooc)
top50count.mooc <- sort(colSums(dtmMooc), decreasing = TRUE)[1:50]  # top 50 words
top50names.mooc <- names(top50count.mooc)
MoocResult <- data.frame(word = top50names.mooc, count = top50count.mooc)

write.csv(MoocResult, file = "mooc_topwords.csv", row.names=FALSE)

