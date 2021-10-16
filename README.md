#C-DEEPSO
Canonical Differential Evolutionary Particle Swarm Optimization Algorithm with irace package

##Instructions

To execute C-DEEPSO+irace, do the following steps:
1) Install R version >=3.2.0
2) Inside R, instal the irace package with the command install.packages("irace")
3) Go to the folder tuning, the file target-runner-advanced (an python script), and change the lines 366 and 381 to add the PATH of the RUN.m script that is located inside the tuning folder
4) Execute runirace.R: an R process will open and will do the fine tuning of C-DEEPSO on the WPP problem. In the end of the process, there will be 96 files called results_X.rdata, with X beeing the number of the instance of the problem
5) Run C-DEEPSO: with the parameters generated by runirace.R (in the step 4, above), that you will find listed in results_X.rdata, you will open matlab and run the RUN.m file with this parameters

The computational simulation was done using a Intel i9 3.7 Ghz e 64 GB de RAM on Operational System Ubuntu 20.04.2.0LTS computer.
The code was implemented in Matlab using the MATPOWER package.
The integration of R (4.1.1) and Matlab is done with a Python (3.7) script.
