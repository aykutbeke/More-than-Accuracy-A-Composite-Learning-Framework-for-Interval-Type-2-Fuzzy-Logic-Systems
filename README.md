# More than Accuracy: A Composite Learning Framework for Interval Type-2 Fuzzy Logic Systems
Matlab implementation of the composite learning algorithm in the following paper:

```
A. Beke and T. Kumbasar, "More than Accuracy: A Composite Learning Framework for Interval Type-2 Fuzzy Logic Systems," _IEEE Transaction on Fuzzy Systems_. 
```
We kindly ask that to cite the above mentioned paper if you use Composite Learning Framework for Interval Type-2 Fuzzy Logic Systems and you publish papers about work that was performed using these codes.

# How to Run IT2-FLS with CompositeLearning
1) Download or clone the repository into a convenient directory. Open MATLAB 2019b or a newer version.
2) Firstly run 'runFirst.m' to add path necessary functions.
3) In 'runFirst.m', you need to select the parametric IT2-FLS model you want to use. (In default H-L is selected) 

# How to Run Examples
1) We present an univariate Mcycle dataset example. Under this directory you'll find a .fis file which you need to arrange with respect to the parametric IT2-FLSs and the dataset you handle. 
2) 'exampleFIS' directory contains the you'll find the example .fis files for the all parametric IT2-FLSs. If you want to change your IT2-FLS structure you need to edit your .fis file, for instance 

      -you can change TypeRedMethod you can edit this field among 3 selections as "KM", "NT" and "SM",
      
      -you can edit your rule number by changing NumRules field but make sure that inputs also have same number of MFs as NumRules,
      
      -also you can set a parameter constant if you want to define it not learnable as defining like MF1L='mf1L':'gaussmf','[Sigma 0.5 pm]' instead MF1L='mf1L':'gaussmf','[Sigma Z pm]' so that you set the center parameter as not learnable and constant as 0.5.    
 
3) If you want to use a different dataset, you can use the same 'QR_DL.m' file under the ExampleMcycleDataset directory. However, before run it, you need to edit your .fis file according to your dataset feature size and also you need to edit load '.' field in QR_DL.m file.
      
