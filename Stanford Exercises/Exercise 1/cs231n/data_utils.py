import cPickle as pickle
import numpy as np
import os

def load_CIFAR_batch(filename):
  """ load single batch of cifar """
  with open(filename, 'rb') as f:
    datadict = pickle.load(f)
    X = datadict['data']
    Y = datadict['labels']
    #(m, n) = X.shape
    #print n
    #X1 = X[:, :n/2].reshape(5000, 3, 32, 32).transpose(0,2,3,1).astype("float")
    #X2 = X[:, n/2:].reshape(5000, 3, 32, 32).transpose(0, 2, 3, 1).astype("float")
    X = X.reshape(10000, 3, 32, 32).transpose(0,2,3,1).astype("float")
    #X = np.hstack((X1, X2))
    Y = np.array(Y)
    return X, Y

def load_CIFAR10(ROOT):
  """ load all of cifar """
  xs = []
  ys = []
  for b in range(1,6):
    f = os.path.join(ROOT, 'data_batch_%d' % (b, ))
    X, Y = load_CIFAR_batch(f)
    xs.append(X)
    ys.append(Y)    
  Xtr = np.concatenate(xs)
  Ytr = np.concatenate(ys)
  del X, Y
  Xte, Yte = load_CIFAR_batch(os.path.join(ROOT, 'test_batch'))
  return Xtr, Ytr, Xte, Yte
