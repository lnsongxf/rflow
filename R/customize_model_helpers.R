#  Copyright 2015 Yuan Tang
#  Copyright 2015 Google Inc. All Rights Reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

#' @name Tensor Transformer
#' @title Tensor Transformaer
#' @description This function performs transformation on tensor input and returns tensor input
#' @param NAME The name of the transoformation method to be used. 
#' @param ... Additional argument except the tensor input
#' # Available transformation method are list here: http://www.tensorflow.org/api_docs/python/array_ops.html#tensor-transformations
TensorTransformer <- function(NAME, ...){
  tabFuncExecuteWriter('X', NAME, 'X', ...)
}


#' @name Tensor Operator
#' @title Tensor Operater
#' @description This function performs operations on tensor input, such as conv2d for convolutional layer
#' and dnn for deep neural network layer
#' @param NAME The name of the operation method to be used. Available operators are: conv2d, dnn
#' @param ... Additional argument except the tensor input
TensorOperator <- function(NAME, ...){
  TensorTransformer(paste0('skflow.ops.', NAME), ...)
}


#' @name Tensor Activator
#' @title Tensor Activator
#' @description This function performs activation function on the tensor
#' @param NAME The name of the activation method to be used. Available activators are: linear_regression, logistic_regression, etc
#' @param ... Additional argument except the tensor input 
TensorActivator <- function(NAME, ...){
  paste0('skflow.models.', NAME, '(X,y)')
}


#' @name Tensor Processor
#' @title Tensor Processor
#' @description This function performs processing function on the tensor
#' @param NAME The name of processing function. A list can be found here: https://github.com/google/skflow/blob/master/skflow/preprocessing/text.py
#' @param ... Additional paramerters passed to processing function
TensorProcessor <- function(NAME, ...){
  cat(sprintf("processor = skflow.preprocessing.%s(%s)",
          NAME, insertPyObjsStr(...)), "\n")
}


#' @name Tensor Processor Transformation
#' @title Tensor Processor Transformation
#' @description This function fit and transform training text OR transform testing text
#' @param dataType Whether this is applying transformation for 'train' or 'test'
TensorProcessor.transform <- function(dataType = 'train'){
  cat(sprintf('X_%s = np.array(list(processor.%s(X_%s)))',
          dataType,
          ifelse(dataType == 'train', 'fit_transform', 'transform'),
          dataType), "\n")
}


