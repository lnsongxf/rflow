context('Testing CNN classifier.')

test_percent <<- 0.25
n_classes <<- 10
steps <<- 400
learning_rate <<- .045
batch_size <<- 120

sink("test.py")
importDeps()
loadMINST()
trainTestSplit(test_percent)
ConvModel()
TensorFlowEstimator(n_classes=n_classes, steps=steps, learning_rate=learning_rate, batch_size=batch_size)
fit()
predict()
accuracyScore()
sink()

system("python test.py")
