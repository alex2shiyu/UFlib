#!/bin/bash
ipout='sypeng@159.226.35.226'
portout='4693'
#ipout='pengsy@115.156.131.251'
#portout='11022'

if [ $1 = "link" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget $2;pname=\$(find . -amin -2 | tail -n 1 |cut -d '/' -f 2) && echo \$pname"
   ssh -p $portout $ipout "cd ~/paper/ && wget -O $3.pdf $2"
   scp -P $portout $ipout:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper
elif [ $1 = "prb" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prb/pdf/10.1103/PhysRevB.$2" 
   ssh -p $portout $ipout "cd ~/paper/ && wget -O $3.pdf https://journals.aps.org/prb/pdf/10.1103/PhysRevB.$2" 
#   scp -P 4693 sypeng@159.226.36.28:~/paper/"PhysRevB.$2" /Users/sypeng/Desktop/paper 
   scp -P $portout $ipout:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
#   mv /Users/sypeng/Desktop/paper/"PhysRevB.$2" /Users/sypeng/Desktop/paper/"PhysRevB.$2.pdf"
elif [ $1 = "pr" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prb/pdf/10.1103/PhysRevB.$2" 
#   https://journals.aps.org/pr/pdf/10.1103/PhysRev.78.477
   ssh -p $portout $ipout "cd ~/paper/ && wget -O $3.pdf https://journals.aps.org/pr/pdf/10.1103/PhysRev.$2" 
#   scp -P 4693 sypeng@159.226.36.28:~/paper/"PhysRevB.$2" /Users/sypeng/Desktop/paper 
   scp -P $portout $ipout:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
#   mv /Users/sypeng/Desktop/paper/"PhysRevB.$2" /Users/sypeng/Desktop/paper/"PhysRevB.$2.pdf"
elif [ $1 = "pra" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prx/pdf/10.1103/PhysRevX.$2" 
   ssh -p $portout $ipout "cd ~/paper/ && wget -O $3.pdf https://journals.aps.org/pra/pdf/10.1103/PhysRevA.$2" 
   scp -P $portout $ipout:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
#   mv /Users/sypeng/Desktop/paper/"PhysRevX.$2" /Users/sypeng/Desktop/paper/"PhysRevX.$2.pdf"
elif [ $1 = "prd" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prx/pdf/10.1103/PhysRevX.$2" 
   ssh -p $portout $ipout "cd ~/paper/ && wget -O $3.pdf https://journals.aps.org/prd/pdf/10.1103/PhysRevD.$2" 
   scp -P $portout $ipout:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
#   mv /Users/sypeng/Desktop/paper/"PhysRevX.$2" /Users/sypeng/Desktop/paper/"PhysRevX.$2.pdf"
elif [ $1 = "prx" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prx/pdf/10.1103/PhysRevX.$2" 
   ssh -p $portout $ipout "cd ~/paper/ && wget -O $3.pdf https://journals.aps.org/prx/pdf/10.1103/PhysRevX.$2" 
   scp -P $portout $ipout:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
#   mv /Users/sypeng/Desktop/paper/"PhysRevX.$2" /Users/sypeng/Desktop/paper/"PhysRevX.$2.pdf"
elif [ $1 = "prl" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prl/pdf/10.1103/PhysRevLett.$2" 
   ssh -p $portout $ipout "cd ~/paper/ && wget -O $3.pdf https://journals.aps.org/prl/pdf/10.1103/PhysRevLett.$2" 
   scp -P $portout $ipout:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
#   mv /Users/sypeng/Desktop/paper/"PhysRevLett.$2" /Users/sypeng/Desktop/paper/"PhysRevLett.$2.pdf"
elif [ $1 = "prm" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prl/pdf/10.1103/PhysRevLett.$2" 
   ssh -p $portout $ipout "cd ~/paper/ && wget -O $3.pdf https://journals.aps.org/prmaterials/pdf/10.1103/PhysRevMaterials.$2" 
   scp -P $portout $ipout:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
elif [ $1 = "prr" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prl/pdf/10.1103/PhysRevLett.$2" 
   ssh -p $portout $ipout "cd ~/paper/ && wget -O $3.pdf https://journals.aps.org/prresearch/pdf/10.1103/PhysRevResearch.$2" 
   scp -P $portout $ipout:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
elif [ $1 = "nature" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prl/pdf/10.1103/PhysRevLett.$2" 
   ssh -p $portout $ipout "cd ~/paper/ && wget -O $3.pdf https://www.nature.com/articles/nature$2.pdf" 
   scp -P $portout $ipout:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
#   mv /Users/sypeng/Desktop/paper/"PhysRevLett.$2" /Users/sypeng/Desktop/paper/"PhysRevLett.$2.pdf"
elif [ $1 = "np" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prl/pdf/10.1103/PhysRevLett.$2" 
   ssh -p $portout $ipout "cd ~/paper/ && wget -O $3.pdf https://www.nature.com/articles/nphys$2.pdf" 
   scp -P $portout $ipout:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
#   mv /Users/sypeng/Desktop/paper/"PhysRevLett.$2" /Users/sypeng/Desktop/paper/"PhysRevLett.$2.pdf"
elif [ $1 = "nm" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prl/pdf/10.1103/PhysRevLett.$2" 
   ssh -p $portout $ipout "cd ~/paper/ && wget -O $3.pdf https://www.nature.com/articles/nmat$2.pdf" 
   scp -P $portout $ipout:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
elif [ $1 = "science" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prl/pdf/10.1103/PhysRevLett.$2" 
   ssh -p $portout $ipout "cd ~/paper/ && wget -O $3.pdf https://science.sciencemag.org/content/sci/$2.full.pdf" 
   scp -P $portout $ipout:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
#   mv /Users/sypeng/Desktop/paper/"PhysRevLett.$2" /Users/sypeng/Desktop/paper/"PhysRevLett.$2.pdf"
elif [ $1 = "epl" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prl/pdf/10.1103/PhysRevLett.$2" 
   ssh -p $portout $ipout "cd ~/paper/ && wget -O $3.pdf https://iopscience.iop.org/article/10.1209/0295-5075/$2/pdf" 
   scp -P $portout $ipout:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
#   mv /Users/sypeng/Desktop/paper/"PhysRevLett.$2" /Users/sypeng/Desktop/paper/"PhysRevLett.$2.pdf"
elif [ $1 = "rmp" ];then
#   ssh -p 4693 sypeng@159.226.36.28 "cd ~/paper/ && wget https://journals.aps.org/prl/pdf/10.1103/PhysRevLett.$2" 
   ssh -p $portout $ipout "cd ~/paper/ && wget -O $3.pdf https://journals.aps.org/rmp/pdf/10.1103/RevModPhys.$2" 
   scp -P $portout $ipout:~/paper/"$3.pdf" /Users/sypeng/Desktop/paper 
elif [ $1 = "show" ];then
   if [ $2 = "link" ];then
      echo "paper link https://journals.aps.org/prb/pdf/10.1103/PhysRevB.79.075114 dengxy_lda+gutz_prb79.075114_2009"
      echo "paper link https://journals.aps.org/prl/supplemental/10.1103/PhysRevLett.124.077401/Suppl.pdf xiaodi_prl_supplement"
   elif [ $2 = "prb" ];then
      echo "paper prb 79.075114 dengxy_lda+gutz_prb79.075114_2009"
   elif [ $2 = "pra" -o $2 = "prd" -o $2 = "prx" -o $2 = "prl" -o $2 = "rmp" -o $2 = "prm" -o $2 = "prr" ];then
      echo "see prb."
   elif [ $2 = "epl" ];then
      echo "take the representative paper of xydeng<EPL, 83, 37008 (2008)> for example:"
      echo "paper epl 83/37008 dengxy_lda_gutz_epl83.37008_2008"
   elif [ $2 = "nm" ];then
      echo "see np."
   elif [ $2 = "nature" -o $2 = "np" ];then
      echo "just search in the browser to get the unique number or link!"
      echo "nature: https://www.nature.com/articles/nature22391"
      echo "        just type: paper nature 22391"
      echo "natphy: https:https://www.nature.com/articles/nphys3371"
      echo "        just type: paper np 3371"
   elif [ $2 = "science" ];then
      echo "take the representative paper of Bernevig<Science, 314(5806):1757–1761, 2006> for example:"
      echo "paper science 314/5806/1757 bernevig_HgTe_quantumspinhall_science2006"
   elif [ $2 == "help" ];then
       echo "paper show X"
       echo "X : pr, pra, prb, prd, prl, prm, prr, prx"
       echo "  : science, nature, np, nm, rmp, epl"
       echo "  : link"
   else
      echo "the second option is wrong, check again!"
   fi
else
   echo "-option is wrong,check again!"
fi
