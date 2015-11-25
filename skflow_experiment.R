require(rPython)

data(iris)

hidden_units <- c(10, 20, 10)
n_classes <- 3
steps <- 200

createArgs <- function(names){
  paste(unlist(lapply(names, function(name){
    paste0(name, "=", capture.output(dput(get(name))))
  })), collapse = ", ")
}

skflow.TensorFlowDNNClassifier <- function(hidden_units, n_classes, tf_master="",
                                           batch_size=32, steps=50, optimizer="SGD",
                                           learning_rate=0.1, tf_random_seed=42){
  paste0("classifier = skflow.TensorFlowDNNClassifier(",
         createArgs(c("hidden_units", "n_classes", "tf_master", 
                      "batch_size", "steps", "optimizer",
                      "learning_rate", "tf_random_seed")),
         ")")
}

python.assign("X", iris[1:4])
python.exec('
import pandas as pd
import os
X_df = pd.DataFrame(X)
X_lists = X_df.values.tolist()
f = open("X_lists.txt", "w")
f.write(json.dumps(X_lists))
f.close()')
X_lists <- readLines("X_lists.txt")
python.exec('os.remove("X_lists.txt")')

python.assign("y", as.integer(as.factor(iris[,5]))-1) # starts from 0
python.exec('
f = open("y_lists.txt", "w")
f.write(json.dumps(y))
f.close()')
y_lists <- readLines("y_lists.txt")
python.exec('os.remove("y_lists.txt")')

system(paste0("python TensorFlowDNNClassifier.py ",
              paste0('"', X_lists, '"'),
              " ", 
              paste0('"', y_lists, '"')))

# python.exec('import random')
# python.exec('from sklearn import datasets, metrics')
# python.exec('import skflow')

# system("python iris_test.py")

# system(paste0("python TensorFlowDNNClassifier.py ", '--l="[1,2,3]" --l="[2,3,4]"'))


# python.exec(paste0("type(eval(", paste0('"', y_lists, '"'), "))"))



