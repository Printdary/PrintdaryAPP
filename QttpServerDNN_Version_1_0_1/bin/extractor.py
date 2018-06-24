#!/usr/bin/env python
import torch.cuda
from torch.autograd import Variable
import numpy as np
from utils import resize_and_keep_aspect, put_image_on_fixed_length_black_image
import cv2
from parameters import parameters
import os
import operator
import sys
import time

def prepare_image_for_NN(image_path):
    image = cv2.imread(image_path)
    image = resize_and_keep_aspect(image)
    image_batch = np.zeros((1, parameters['image_size'], parameters['image_size'], 3))
    image_batch[0] = put_image_on_fixed_length_black_image(image_batch[0], image)
    image_batch = np.transpose(image_batch, (0, 3, 1, 2))
    image_batch = Variable(torch.from_numpy(image_batch), requires_grad=True).float()

    if torch.cuda.is_available():
        image_batch = image_batch.cuda()

    return image_batch

def isTxt(path):
    if(path[-3:]== "txt"):
        return True;
    else:
        return False;

database_path=sys.argv[1]
model_path =sys.argv[2]
database = os.listdir(database_path)
cnn = torch.load(model_path)

for i in range(len(database)):

    print(i)
    currImg=database_path+'/'+database[i]
    if(isTxt(currImg)==False):
        currImg=prepare_image_for_NN(currImg)
        currTextFile=database_path +'/'+database[i]+'.txt'
        feat=cnn(currImg)
        feat= feat[0].data.cpu().numpy()
        with open(currTextFile,'w+') as out:
                for j in range(len(feat)):
                        out.write(str(feat[j])+"\n")



#with open(currTextFile,'w+') as out:
#	out.write(feat)


