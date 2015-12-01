context('Testing util functions')

expect_equal(toPyObjStr(c(2,3)), "[2, 3]")

expect_equal(insertPyObjsStr(3, c(1,2,3)), "3, [1, 2, 3]")
expect_equal(insertPyObjsStr(shape=c(3,3)), "shape=[3, 3]")
expect_equal(insertPyObjsStr(3, shape=c(3,3)), "3, shape=[3, 3]")
expect_equal(insertPyObjsStr(dim=3, shape=c(3,3)), "dim=3, shape=[3, 3]")

expect_equal(createFuncStr('f', 3, c(1,2,3), prob=3), "f(3, [1, 2, 3], prob=3)")

expect_equal(funcExecuteWriter('X', 'f', 'X', 3, c(1,2,3)), "X = f(X, 3, [1, 2, 3])\n")
expect_equal(tabFuncExecuteWriter('X', 'f', 'X', 3, c(1,2,3)), "\tX = f(X, 3, [1, 2, 3])\n")

expect_equal(capture.output(customModelWriter(returnValue = NULL,
                               funcInput = c('X', 'y'),
                               tabFuncExecuteWriter('X', 'f1', 'X', 3, c(1,2,3)),
                               tabFuncExecuteWriter('y', 'f2', 'X', 3, c(1,2,3)))),
             c("def custom_model(X,y):", "\tX = f1(X, 3, [1, 2, 3])", " \ty = f2(X, 3, [1, 2, 3])"))

expect_equal(capture.output(customModelWriter(returnValue = 'returnValue',
                                              funcInput = c('X', 'y'),
                                              tabFuncExecuteWriter('X', 'f1', 'X', 3, c(1,2,3)),
                                              tabFuncExecuteWriter('y', 'f2', 'X', 3, c(1,2,3)))),
             c("def custom_model(X,y):", "\tX = f1(X, 3, [1, 2, 3])",
               " \ty = f2(X, 3, [1, 2, 3])", "\treturn(returnValue)"))

