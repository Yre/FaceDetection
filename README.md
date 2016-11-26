# Face Detection using HoG
### Report: <https://computervision-2016-spring.github.io/FaceDetection/>
### HKUST COMP5421 Project2
[Project Page](https://course.cs.ust.hk/comp5421/Password_Only/projects/faces/index.html) (You may need a HKUST CSD to login to the page)  
### Project Description 
The sliding window model is conceptually simple: independently classify all image patches as being object or non-object. Sliding window classification is the dominant paradigm in object detection and for one object category in particular -- faces -- it is one of the most noticeable successes of computer vision.  
  
For this project, we have implemented the simpler (but still very effective!) sliding window detector of [Dalal and Triggs 2005](https://lear.inrialpes.fr/people/triggs/pubs/Dalal-cvpr05.pdf). Dalal-Triggs focuses on representation more than learning and introduces the SIFT-like **Histogram of Gradients (HoG)** representation.  

This project has implement the rest of the detection pipeline -- handling heterogeneous training and testing data, training a linear classifier (a HoG template), and using resulted classifier to classify millions of sliding windows at multiple scales. Fortunately, linear classifiers are compact, fast to train, and fast to execute. A linear SVM can also be trained on large amounts of data, including mined hard negatives.
### Details
Please refer to our [report page](https://computervision-2016-spring.github.io/FaceDetection/).
### Usage
You need to provide training and testing data for this program.  
The main entry of the program is proj4.m (a Matlab program).  
There are detailed comments in the codes.
### Requirements
Matlab   
  

***For Further questions, Please issue on this repo.***
