 Parallel Convolutional Neural Network (CNN) with Multi-GPU Support

This project demonstrates how to implement a parallel Convolutional Neural Network (CNN) for image classification using TensorFlow. The model is trained on the MNIST dataset, and the training process is optimized using multi-GPU data parallelism and an efficient data pipeline.

 Key Features

1. Multi-GPU Training:
   - The model uses TensorFlow's `MirroredStrategy` for multi-GPU support, which allows for data parallelism. This means the model’s training workload is distributed across multiple GPUs, leading to faster training times.

2. Optimized Data Pipeline:
   - Data loading and preprocessing are handled efficiently using TensorFlow's `tf.data` API, which supports parallel data loading, batching, and prefetching.

3. CNN Architecture:
   - A simple 3-layer CNN architecture is implemented with convolutional layers, max-pooling, and dense layers for classification on the MNIST dataset.

 Algorithm Overview

The algorithm is designed to take advantage of multiple GPUs to speed up the training process of a CNN by splitting the training data across different devices. Each GPU processes a portion of the data in parallel, and the results are averaged to update the model weights.

 Steps Involved:

1. Data Parallelism (Multi-GPU Training):
   - TensorFlow's `MirroredStrategy` is used to distribute the training process across multiple GPUs.
   - The training data is split into smaller batches, and each GPU processes one batch of data in parallel.
   - The gradients computed by each GPU are synchronized, and the model weights are updated collectively across all devices.

2. Optimized Data Pipeline:
   - The dataset is preprocessed to normalize the images and prepare them for input to the CNN.
   - The `tf.data.Dataset` API is used to create an efficient input pipeline, where data is loaded in parallel, and the batch of images is preprocessed while the model is training.
   - Prefetching ensures that data is loaded into memory ahead of time, reducing the waiting time during training.

 Parallelism Implementation

1. Multi-GPU Support with `MirroredStrategy`:
   TensorFlow’s `MirroredStrategy` allows the training process to be distributed across multiple GPUs. The strategy works by copying all of the model’s variables to each GPU. Then, it splits the data into mini-batches, which are processed by the GPUs in parallel. After each GPU computes its gradients, the strategy synchronizes the gradients and averages them to update the model weights.

   ```python
    Create a MirroredStrategy for multi-GPU training
   strategy = tf.distribute.MirroredStrategy()

    Within the strategy's scope, create and compile the model
   with strategy.scope():
       model = create_cnn_model(input_shape=(28, 28, 1), num_classes=10)
       model.compile(optimizer='adam',
                     loss='sparse_categorical_crossentropy',
                     metrics=['accuracy'])
