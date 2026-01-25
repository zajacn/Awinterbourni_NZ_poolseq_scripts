#Skeleton for how to run diyabc
/Users/nataliazajac/diyabc/build/src-JMC-C++/general -p ./ -n "t:8"
/Users/nataliazajac/diyabc/build/src-JMC-C++/general -p ./ -r 1000 -t 4 -g 100
/Users/nataliazajac/abcranger/build/abcranger --header headerRF.txt --reftable reftable.bin --statobs statobs.txt --output modelchoice_out --ntree 2000
/Users/nataliazajac/abcranger/build/abcranger --header headerRF.txt --reftable reftable.bin --statobs statobs.txt --parameter r1 --chosenscen  4 --noob 5 > parameter_estimation.r1.txt
