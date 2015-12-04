# Convolutional Neural Network in R

# parameters for TensorFlowEstimator needs to be defined first
n_classes <- 10
steps <- 400
learning_rate <- .045
batch_size <- 120

rflowPipeline(eval_metric = 'accuracy_score',
              test_percent = 0.25,
              loadMINST(),
              # Convolutional Neural Network Architecture
              ConvModel(), # See ?ConvModel for possible parameters to change the architecture
              TensorFlowEstimator(n_classes = n_classes,
                                  steps=steps,
                                  learning_rate = learning_rate,
                                  batch_size = batch_size)
)
