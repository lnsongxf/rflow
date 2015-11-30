
createArgs <- function(names, getFunc=get){
  if(length(names) == 0) return(NULL)
  if(is.list(names)){names <- names(names)} # deal with additional arguments
  paste(unlist(lapply(names, function(name){
    RHS <- toPyObjStr(getFunc(name))
    paste0(name, "=", RHS)
  })), collapse = ", ")
}


# c(1,2,3) => [1,2,3]
toPyObjStr <- function(rObj){
  python.assign('tmp_var', rObj)
  python.exec(sprintf('
                      from json import dumps
                      with open("tmp_var.txt", "w") as f:
                        f.write(dumps(%s))
                        f.close()', 'tmp_var'))
  pyObjStr <- suppressWarnings(readLines('tmp_var.txt'))
  unlink('tmp_var.txt')
  return(pyObjStr)
}


# save a Python object to a text file
savePyObjToFile <- function(pyVarName){

  fileName <- paste0(pyVarName, '.txt')
  cat(sprintf('
with open("%s", "w") as f:
\tif(isinstance(%s, ndarray)):
\t\tf.write(dumps(ndarray.tolist(%s)))
\telse:
\t\tf.write(dumps(%s))
\tf.close()', fileName, pyVarName, pyVarName, pyVarName))
}


# load a python string from a file to an R object
loadPyStrToR <- function(pyVarName){
  fileName <- paste0(pyVarName, '.txt')
  python.exec(paste0(pyVarName, " = ", readLines(fileName)))
  return(python.get(pyVarName))
}


# for annonymous args
# insertPyObjsStr(3, c(1,2,3))  => "3, [1, 2, 3]"
insertPyObjsStr <- function(...){
  args <- list(...)
  namedArgsInds <- names(args) != ""
  namedArgs <- names(args)[namedArgsInds]

  namedStr <- paste(unlist(lapply(namedArgs, function(name){
    paste0(name, '=', args[[name]])
  })), collapse = ", ")

  if(length(namedArgsInds) == 0){
    unNamedArgs <- args
  } else {
    unNamedArgs <- args[!namedArgsInds]
  }
  unNamedStr <- paste(unlist(lapply(unNamedArgs, function(arg){
    toPyObjStr(arg)
  })), collapse = ", ")

  paste0(unNamedStr, ifelse(namedStr == "", '', ', '), namedStr)
}


# createFuncStr('f', 3, c(1,2,3), prob=3)  => "f(3, [1, 2, 3], prob=3)"
createFuncStr <- function(funcName, ...){
  argStr <- insertPyObjsStr(...)
  paste0(funcName, sprintf('(%s)', argStr))
}


# for named arguments
additionalArgs <- function(theDots){
  paste0(ifelse(length(theDots) != 0, ", ", ""),
         createArgs(theDots, getFunc = get))
}

funcWriter <- function(body, funcHeader= 'def f():', returnValue = NULL){
  cat(paste0(funcHeader, "\n"))
  cat(body)
  if(!is.null(returnValue)){
    cat(paste0("\treturn(", returnValue, ")\n"))
  }
}


# not used yet
# funcExecuteWriter('X', 'f', 'X', 3, c(1,2,3))  => "X = f(X, 3, [1, 2, 3])\n"
funcExecuteWriter <- function(LHS, funcName, firstArg, ...){
  sprintf("%s = %s(%s, %s)\n",
         LHS, funcName, firstArg, insertPyObjsStr(...))
}


# tabFuncExecuteWriter('X', 'f', 'X', 3, c(1,2,3))
tabFuncExecuteWriter <- function(LHS, funcName, firstArg, ...){
  sprintf("\t%s = %s(%s, %s)\n",
          LHS, funcName, firstArg, insertPyObjsStr(...))
}


# customModelWriter(returnValue = NULL, funcInput = c('X', 'y'),
#                   tabFuncExecuteWriter('X', 'f1', 'X', 3, c(1,2,3)),
#                   tabFuncExecuteWriter('y', 'f2', 'X', 3, c(1,2,3)))
# ==>
# def custom_model(X,y):
#   X = f1(X, 3, [1, 2, 3])
#   y = f2(X, 3, [1, 2, 3])
customModelWriter <- function(returnValue, funcInput, ...){
  funcWriter(body = unlist(list(...)),
             funcHeader = sprintf('def custom_model(%s):',
                                  paste(funcInput, collapse = ",")),
             returnValue = returnValue)
}




