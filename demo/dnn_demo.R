source('skflow_experiment.R')
# Deep Neural Network on iris data in R

data(iris)

hidden_units <- c(10, 20, 10)
n_classes <- 3
steps <- 200

sink("test.py")
importDeps()
skflow.TensorFlowDNNClassifier(hidden_units = hidden_units, n_classes = n_classes)
preparePredictors(iris[1:4])
prepareTargetVar(iris[,5])
classifier.fit()
cat(
'
score = metrics.accuracy_score(classifier.predict(X), y)
print("Accuracy: %f" % score)
')
sink()

system("python test.py")
