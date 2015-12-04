context('Testing custom model helpers')

expect_equal(TensorTransformer('f', 1, c(1,2,3)), 
             "\tX = f(X, 1, [1, 2, 3])\n")

expect_equal(TensorOperator('conv2d', n_filters = 3, filter_shape = c(1,2)), 
             "\tX = skflow.ops.conv2d(X, n_filters=3, filter_shape=[1, 2])\n")

expect_equal(TensorActivator('logistic_regression'), 
             "skflow.models.logistic_regression(X,y)")

expect_equal(capture.output(TensorProcessor('VocabularyProcessor',  max_document_length = 10)),
             "processor = skflow.preprocessing.VocabularyProcessor(max_document_length=10) ")

expect_equal(capture.output(TensorProcessor.transform('train')), 
             "X_train = np.array(list(processor.fit_transform(X_train))) ")
expect_equal(capture.output(TensorProcessor.transform('test')), 
             "X_test = np.array(list(processor.transform(X_test))) ")


