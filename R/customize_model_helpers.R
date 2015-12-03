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

#' @param ... Additional argument except the tensor input
#' e.g. TensorTransformer('f', 1, c(1,2,3))  => X = f(X, 1, [1, 2, 3])
#' Available transformation method are list here: http://www.tensorflow.org/api_docs/python/array_ops.html#tensor-transformations
TensorTransformer <- function(NAME, ...){
  tabFuncExecuteWriter('X', NAME, 'X', ...)
}

# TensorOperator('conv2d', n_filters = 3, filter_shape = c(1,2))
# => "\tX = skflow.ops.conv2d(X, n_filters=3, filter_shape=[1, 2])\n"
# Available operators are: conv2d, dnn
TensorOperator <- function(NAME, ...){
  TensorTransformer(paste0('skflow.ops.', NAME), ...)
}

# TensorActivator('logistic_regression') => "skflow.models.logistic_regression(X,y)"
# Available activators are: linear_regression, logistic_regression
TensorActivator <- function(NAME, ...){
  paste0('skflow.models.', NAME, '(X,y)')
}

# TensorProcessor(name='VocabularyProcessor',  max_document_length = 10)
# => "processor = skflow.preprocessing.VocabularyProcessor(max_document_length=10)"
TensorProcessor <- function(NAME, ...){
  cat(sprintf("processor = skflow.preprocessing.%s(%s)",
          NAME, insertPyObjsStr(...)), "\n")
}

# Fit and transform training text OR transform testing text
# TensorProcessor.transform('train') => "X_train = np.array(list(processor.fit_transform(X_train)))"
# TensorProcessor.transform('test') => "X_test = np.array(list(processor.transform(X_test)))"
TensorProcessor.transform <- function(dataType = 'train'){
  cat(sprintf('X_%s = np.array(list(processor.%s(X_%s)))',
          dataType,
          ifelse(dataType == 'train', 'fit_transform', 'transform'),
          dataType), "\n")
}


