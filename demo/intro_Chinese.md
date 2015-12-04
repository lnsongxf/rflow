# 短短几行R代码使用谷歌的TensorFlow

# 为何使用TensorFlow? 
谷歌最近开源了这个数值计算的工具包以及深度学习开发系统，为建立不同架构的深度学习模型提供了基石，才刚一发布，各种正面负面的评论也是呈爆炸性趋势增长。但是对于我们开源软件的爱好者来说，不应该只看看表面上的东西就开始展开评论，而是应该手把手的实际操作然后体验体验它和存在的深度学习软件的区别，仔细研究用户体验层面和系统架构层面，取其精华弃其糟粕，这一点DMLC(Deep Machine Learning Commons, http://dmlc.ml/)的mxnet做得很不错，仔细研究各个系统的区别和相似之处来互相交流和学习，而不是拼命指出其他系统的缺点和不足，这里有DMLC成员的总结，大家也可以参考一下(https://mxnet.readthedocs.org/en/latest/faq.html)。作者本人也是DMLC成员，但是目前只参与了mxnet为数不多的贡献。

因为TensorFlow目前简单易用的界面仅限于Python，网上能找到的的各种例子都是用Python实现的，为了让广大的R用户来体验体验传说中的“高端黑科技”，作者也是闲得不行，干脆写了一个简单易用的rflow R包来帮助大家用短短几行代码来实现一些常用的深度学习模型。长话短说，请看接下来的例子。安装方法请参考Github上的说明(https://github.com/terrytangyuan/rflow)。

# 深度神经网络分类
首先你需要设置一些变量
```{R}
predictors <- iris[1:4] # 自变量
target <- iris[,5] # 因变量
hidden_units <- c(10, 20, 10) # 每层的隐藏单元
n_classes <- length(unique(target)) # 类别数
steps <- 400 # 步数
```

接下来就是主要的几行代码了，应该都很简单明了，`eval_metric`是评估指标，可以参考帮助文档了解更多的选择，`test_percent`是测试集的比例，`TensorFlowDNNClassifier`是用来初始化分类器的，然后`preparePredictors`和`prepareTargetVar`是用来进行处理Python和R之间数据流动的一些细节，就这样轻松的建立好了模型。
```{R}
rflowPipeline(eval_metric = 'accuracy_score',
              test_percent = 0.25,
              TensorFlowDNNClassifier(hidden_units = hidden_units,
                                      n_classes = n_classes,
                                      steps=steps),
              preparePredictors(predictors),
              prepareTargetVar(target))
```

# 只需改一改参数，也可以轻松用rflow来建立深度神经网络回归模型。
```{R}
library(MASS)
data(Boston)
predictors <- Boston[,2:14]
target <- Boston[,1]
hidden_units <- c(10, 20, 10)
n_classes <- 0
steps <- 400

rflowPipeline(eval_metric = 'mean_squared_error',
              test_percent = 0.25,
              TensorFlowDNNRegressor(hidden_units = hidden_units),
              preparePredictors(predictors),
              prepareTargetVar(target))
```

接下来是最精彩的部分了，你也可以用rflow来实现灵活的个性化模型，来建立不同结构的深度学习模型。和之前的例子唯一不同的是我们使用用`customModelWriter`来写一个自定义的模型，可以设置输入和输出，可以通过`TensorActivator`来选择激活函数, 可以使用`TensorOperator`来加入深度神经网络层，在`customModelWriter`那可以加入的各种变形及处理没有上限，想加多少都可以，在`customize_model_helpers.R`里面有更多的方程可供选择来给自定义模型添色，最后你需要使用`TensorFlowEstimator`来初始化自定义模型，使用方法和`TensorFlowDNNClassifier`类似。如有细节方面不清楚的，请参考帮助文档，邮件联系我terrytangyuan@gmail.com，或者在Github上submit issue (https://github.com/terrytangyuan/rflow/issues)。
```{R}
predictors <- iris[1:4]
target <- iris[,5]
n_classes <- length(unique(target))

rflowPipeline(eval_metric = 'accuracy_score',
              test_percent = 0.25,
              customModelWriter(
                funcInput = c('X', 'y'),
                returnValue = TensorActivator('logistic_regression'),
                TensorOperator('dnn', c(12, 18, 12), keep_prob=0.45)),
              TensorFlowEstimator(n_classes = n_classes),
              preparePredictors(predictors),
              prepareTargetVar(target))
```

接下来我会介绍如何用rflow来建立卷积神经网络模型，为了方便大家使用，基本的已经在包里的源代码通过同以上例子类似的方法实现，大家只需要改改参数，使用这个`ConvModel`方程即可，可以参考`ConvModel`的帮助文档了解到更多的参数，比如说`pooling_method`, `n_filters`, `filter_shape`等等。“古老的黑科技” 卷积神经网络模型就这样被简单的调用了。
```{R}
n_classes <- 10
steps <- 400
learning_rate <- .045
batch_size <- 120

rflowPipeline(eval_metric = 'accuracy_score',
              test_percent = 0.25,
              loadMINST(),
              ConvModel(),
              TensorFlowEstimator(n_classes = n_classes,
                                  steps=steps,
                                  learning_rate = learning_rate,
                                  batch_size = batch_size))
```

这个R包也是这几天才开始写的，为了帮助大家更好的对TensorFlow进行实验，作者也是很拼的，希望大家能试试，欢迎任何意见。
