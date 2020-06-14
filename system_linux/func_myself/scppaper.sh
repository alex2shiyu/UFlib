#!/bin/bash

if [ $1 = "link" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget $2;pname=\$(find . -amin -2 | tail -n 1 |cut -d '/' -f 2) && echo \$pname"
   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget -O $3.pdf $2"
   scp -P 4693 sypeng@159.226.36.28:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper
elif [ $1 = "prb" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prb/pdf/10.1103/PhysRevB.$2" 
   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget -O $3.pdf https://journals.aps.org/prb/pdf/10.1103/PhysRevB.$2" 
#   scp -P 4693 sypeng@159.226.36.28:~/paper/"PhysRevB.$2" /Users/sypeng/Desktop/paper 
   scp -P 4693 sypeng@159.226.36.28:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
#   mv /Users/sypeng/Desktop/paper/"PhysRevB.$2" /Users/sypeng/Desktop/paper/"PhysRevB.$2.pdf"
elif [ $1 = "pra" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prx/pdf/10.1103/PhysRevX.$2" 
   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget -O $3.pdf https://journals.aps.org/pra/pdf/10.1103/PhysRevA.$2" 
   scp -P 4693 sypeng@159.226.36.28:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
#   mv /Users/sypeng/Desktop/paper/"PhysRevX.$2" /Users/sypeng/Desktop/paper/"PhysRevX.$2.pdf"
elif [ $1 = "prd" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prx/pdf/10.1103/PhysRevX.$2" 
   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget -O $3.pdf https://journals.aps.org/prd/pdf/10.1103/PhysRevD.$2" 
   scp -P 4693 sypeng@159.226.36.28:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
#   mv /Users/sypeng/Desktop/paper/"PhysRevX.$2" /Users/sypeng/Desktop/paper/"PhysRevX.$2.pdf"
elif [ $1 = "prx" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prx/pdf/10.1103/PhysRevX.$2" 
   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget -O $3.pdf https://journals.aps.org/prx/pdf/10.1103/PhysRevX.$2" 
   scp -P 4693 sypeng@159.226.36.28:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
#   mv /Users/sypeng/Desktop/paper/"PhysRevX.$2" /Users/sypeng/Desktop/paper/"PhysRevX.$2.pdf"
elif [ $1 = "prl" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prl/pdf/10.1103/PhysRevLett.$2" 
   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget -O $3.pdf https://journals.aps.org/prl/pdf/10.1103/PhysRevLett.$2" 
   scp -P 4693 sypeng@159.226.36.28:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
#   mv /Users/sypeng/Desktop/paper/"PhysRevLett.$2" /Users/sypeng/Desktop/paper/"PhysRevLett.$2.pdf"
elif [ $1 = "nature" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prl/pdf/10.1103/PhysRevLett.$2" 
   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget -O $3.pdf https://www.nature.com/articles/nature$2.pdf" 
   scp -P 4693 sypeng@159.226.36.28:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
#   mv /Users/sypeng/Desktop/paper/"PhysRevLett.$2" /Users/sypeng/Desktop/paper/"PhysRevLett.$2.pdf"
elif [ $1 = "np" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prl/pdf/10.1103/PhysRevLett.$2" 
   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget -O $3.pdf https://www.nature.com/articles/nphys$2.pdf" 
   scp -P 4693 sypeng@159.226.36.28:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
#   mv /Users/sypeng/Desktop/paper/"PhysRevLett.$2" /Users/sypeng/Desktop/paper/"PhysRevLett.$2.pdf"
elif [ $1 = "science" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prl/pdf/10.1103/PhysRevLett.$2" 
   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget -O $3.pdf https://science.sciencemag.org/content/sci/$2.full.pdf" 
   scp -P 4693 sypeng@159.226.36.28:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
#   mv /Users/sypeng/Desktop/paper/"PhysRevLett.$2" /Users/sypeng/Desktop/paper/"PhysRevLett.$2.pdf"
else
   echo "-option is wrong,check again!"
fi
