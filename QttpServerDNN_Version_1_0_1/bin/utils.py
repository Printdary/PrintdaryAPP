import numpy as np
from parameters import parameters
import cv2
import random
from data_augmentation import flip_image, random_crop_image, blur_image, rotate_image
import copy
import os


def resize_and_keep_aspect(image):
    # resize image and keep its aspect ratio
    image_height, image_width = image.shape[:2]
    aspect = float(image_width) / image_height

    if aspect > 1:
        scaled_width = parameters['image_size']
        scaled_height = int(parameters['image_size'] * (float(image_height) / image_width))
    else:
        scaled_height = parameters['image_size']
        scaled_width = int(parameters['image_size'] * aspect)

    image = cv2.resize(image, (scaled_width, scaled_height))

    return image


def get_augmented_image(image):
    # augment the image, randomly flip, crop, blur and/or rotate the image
    if random.randint(0, 1) == 0:
        image = flip_image(image)
    if random.randint(0, 1) == 0:
        image = random_crop_image(image)
    if random.randint(0, 1) == 0:
        image = blur_image(image)
    if random.randint(0, 1) == 0:
        image = rotate_image(image)
    return image


def put_image_on_fixed_length_black_image(output_image, input_image):
    # NN input must be fixed, so the resized input image is placed onto a black image of a fixed size
    positioning = random.randint(0, 3)
    if positioning == 0:
        output_image[0:input_image.shape[0], 0:input_image.shape[1]] = input_image
    elif positioning == 1:
        output_image[0:input_image.shape[0], parameters['image_size'] - input_image.shape[1]:] = input_image
    elif positioning == 2:
        output_image[parameters['image_size'] - input_image.shape[0]:, 0:input_image.shape[1]] = input_image
    elif positioning == 3:
        output_image[parameters['image_size'] - input_image.shape[0]:,
        parameters['image_size'] - input_image.shape[1]:] = input_image
    return output_image


def get_batch(dict_):
    # get batch of images
    image_batch = np.zeros((parameters['batch_size'], 3, parameters['image_size'], parameters['image_size'], 3))

    path = parameters['ImageNet_dataset_path']

    batch = 0
    while batch < parameters['batch_size']:
        positive_category, negative_category = random.sample(list(dict_.keys()), 2)
        positive_images = dict_[positive_category]
        negative_images = dict_[negative_category]

        anchor, positive = random.sample(positive_images, 2)
        negative = random.sample(negative_images, 1)[0]

        anchor_image = cv2.imread(path + '/' + positive_category + '/' + anchor)
        if parameters['data_augmentation']:
            anchor_image = get_augmented_image(anchor_image)
        anchor_image = resize_and_keep_aspect(anchor_image)

        positive_image = cv2.imread(path + '/' + positive_category + '/' + positive)
        if parameters['data_augmentation']:
            positive_image = get_augmented_image(positive_image)
        positive_image = resize_and_keep_aspect(positive_image)

        negative_image = cv2.imread(path + '/' + negative_category + '/' + negative)
        if parameters['data_augmentation']:
            negative_image = get_augmented_image(negative_image)
        negative_image = resize_and_keep_aspect(negative_image)

        image_batch[batch][0] = put_image_on_fixed_length_black_image(image_batch[batch][0], anchor_image)
        image_batch[batch][1] = put_image_on_fixed_length_black_image(image_batch[batch][1], positive_image)
        image_batch[batch][2] = put_image_on_fixed_length_black_image(image_batch[batch][2], negative_image)

        #cv2.imwrite('anchor_image.jpg', image_batch[batch][0])
        #cv2.imwrite('positive_image.jpg', image_batch[batch][1])
        #cv2.imwrite('negative_image.jpg', image_batch[batch][2])

        batch += 1

    return image_batch


def get_batch_custom_dataset(dict_):
    # get batch of images
    image_batch = np.zeros((parameters['batch_size'], 3, parameters['image_size'], parameters['image_size'], 3))

    path = parameters['custom_dataset_path']

    batch = 0
    while batch < parameters['batch_size']:

        positive_image, negative_image = random.sample(dict_, 2)

        anchor_image = cv2.imread(path + '/' + positive_image)
        anchor_image = get_augmented_image(anchor_image)
        anchor_image = resize_and_keep_aspect(anchor_image)

        positive_image = cv2.imread(path + '/' + positive_image)
        positive_image = get_augmented_image(positive_image)
        positive_image = resize_and_keep_aspect(positive_image)

        negative_image = cv2.imread(path + '/' + negative_image)
        negative_image = get_augmented_image(negative_image)
        negative_image = resize_and_keep_aspect(negative_image)

        image_batch[batch][0] = put_image_on_fixed_length_black_image(image_batch[batch][0], anchor_image)
        image_batch[batch][1] = put_image_on_fixed_length_black_image(image_batch[batch][1], positive_image)
        image_batch[batch][2] = put_image_on_fixed_length_black_image(image_batch[batch][2], negative_image)

        #cv2.imwrite('anchor_image.jpg', image_batch[batch][0])
        #cv2.imwrite('positive_image.jpg', image_batch[batch][1])
        #cv2.imwrite('negative_image.jpg', image_batch[batch][2])

        batch += 1

    return image_batch


def get_positive_negative_pairs(dict_, size):
    path = parameters['ImageNet_dataset_path']

    i = 0
    positives = []
    while i < size:
        positive_category = random.choice(list(dict_.keys()))
        positive_images = dict_[positive_category]
        positive = random.sample(positive_images, 2)

        image_path_1 = path + '/' + positive_category + '/' + positive[0]
        image_path_2 = path + '/' + positive_category + '/' + positive[1]

        if not (image_path_1, image_path_2) in positives and not (image_path_2, image_path_1) in positives:
            positives.append((image_path_1, image_path_2))
            i += 1

    i = 0
    negatives = []
    while i < size:
        positive_category = random.choice(list(dict_.keys()))
        negative_category = random.choice(list(dict_.keys()))

        while positive_category == negative_category:
            positive_category = random.choice(list(dict_.keys()))
            negative_category = random.choice(list(dict_.keys()))

        positive_images = dict_[positive_category]
        negative_images = dict_[negative_category]

        positive = random.choice(positive_images)
        negative = random.choice(negative_images)

        image_path_1 = path + '/' + positive_category + '/' + positive
        image_path_2 = path + '/' + negative_category + '/' + negative

        if not (image_path_1, image_path_2) in negatives and not (image_path_2, image_path_1) in negatives:
            negatives.append((image_path_1, image_path_2))
            i += 1

    return positives, negatives


def get_positive_negative_pairs_custom_dataset(dict_, size):
    path = parameters['custom_dataset_path']

    i = 0
    positives = []
    while i < size:
        positive = random.choice(dict_)

        image_path_1 = path + '/' + positive
        image_path_2 = path + '/' + positive

        positives.append((image_path_1, image_path_2))
        i += 1

    i = 0
    negatives = []
    while i < size:
        positive = random.choice(dict_)
        negative = random.choice(dict_)

        while positive == negative:
            positive = random.choice(dict_)
            negative = random.choice(dict_)

        image_path_1 = path + '/' + positive
        image_path_2 = path + '/' + negative

        negatives.append((image_path_1, image_path_2))
        i += 1

    return positives, negatives


if __name__ == "__main__":
    pass
