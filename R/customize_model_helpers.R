#' @param ... Additional argument except the tensor input
#' e.g. TensorTransformer('f', 1, c(1,2,3))  => X = f(X, 1, [1, 2, 3])
#' Available transformation method are list here: http://www.tensorflow.org/api_docs/python/array_ops.html#tensor-transformations
TensorTransformer <- function(name, ...){
  tabFuncExecuteWriter('X', name, 'X', ...)
}

# TensorOperator('conv2d', nfilters = 3, filter_shape = c(1,2))
# => "\tX = skflow.ops.conv2d(X, nfilters=3, filter_shape=[1, 2])\n"
# Available operators are: conv2d, dnn
TensorOperator <- function(name, ...){
  TensorTransformer(paste0('skflow.ops.', name), ...)
}

# TensorActivator('logistic_regression') => "skflow.models.logistic_regression(X,y)"
# Available activators are: linear_regression, logistic_regression
TensorActivator <- function(name, ...){
  paste0('skflow.models.', name, '(X,y)')
}
