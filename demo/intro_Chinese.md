# 短短几行R代码使用谷歌的TensorFlow

# 为何使用TensorFlow? 
谷歌最近开源了这个数值计算的工具包以及深度学习开发系统，为建立不同架构的深度学习模型提供了基石，才刚一发布，各种正面负面的评论也是呈爆炸性趋势增长。但是对于我们开源软件的爱好者来说，不是只看看表面上的东西就开始展开评论，而是手把手的实际操作然后体验体验它和存在的深度学习软件的区别，仔细研究用户体验层面和系统架构层面，取其精华弃其糟粕，这一点DMLC(Deep Machine Learning Commons)的mxnet做得很不错，仔细研究各个系统的区别和相似之处来互相交流和学习，这里有DMLC成员的总结，大家也可以参考一下(https://mxnet.readthedocs.org/en/latest/faq.html)。作者本人也是DMLC成员，但是目前只参与了mxnet为数不多的贡献。

因为TensorFlow目前简单易用的界面仅限于Python，网上能找到的的各种例子都是用Python实现的，为了让广大的R用户来体验体验传说中的“高端黑科技”，作者也是闲得不行，干脆写了一个简单易用的rflow R包来帮助大家用短短几行代码来实现一些常用的深度学习模型。长话短说，请看接下来的例子。

## 深度神经网络分类
# 首先你需要设置一些变量
predictors <- iris[1:4] # 自变量
target <- iris[,5] # 因变量
hidden_units <- c(10, 20, 10) # 每层的隐藏单元
n_classes <- length(unique(target)) # 类别数
steps <- 400 # 步数

# 接下来就是主要的几行代码了，应该都很简单明了，eval_metric是评估指标，可以参考帮助文档了解更多的选择，test_percent是测试集的比例，TensorFlowDNNClassifier是用来初始化分类器的，然后preparePredictors和prepareTargetVar是用来进行处理Python和R之间数据流动的一些细节，就这样轻松的建立好了模型。
rflowPipeline(eval_metric = 'accuracy_score',
              test_percent = 0.25,
              TensorFlowDNNClassifier(hidden_units = hidden_units,
                                      n_classes = n_classes,
                                      steps=steps),
              preparePredictors(predictors),
              prepareTargetVar(target))

# 只需改一改参数，也可以轻松用rflow来建立深度神经网络回归模型。
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

# 接下来是最精彩的部分了，你也可以用rflow来实现灵活的个性化模型，来建立不同结构的深度学习模型

