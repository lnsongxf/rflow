import random

from sklearn import datasets, metrics

import skflow

import numpy as np

import sys, ast, getopt, types

def main(argv):
    classifier = skflow.TensorFlowDNNClassifier(hidden_units=[10, 20, 10], n_classes=3, steps=200)

    X = np.asarray(eval(argv[0]),dtype='float64')
    y = np.array(eval(argv[1]), dtype='int64')
    # Fit and predict.
    classifier.fit(X, y)
    score = metrics.accuracy_score(classifier.predict(X), y)
    print("Accuracy: %f" % score)

if __name__ == '__main__':
    main(sys.argv[1:])    
