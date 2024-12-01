set terminal pngcairo enhanced truecolor size 480,320 fontscale 0.8 # 设置输出图片参数，不设置的话，输出的png图片无法显示
#set nokey
set key left Left # 设置图例位置
set ylabel 'E-Ef/(ev)'
set xlabel 'High symmetry Kpath'
set output 'anatase_band.png' # 保存成 png格式图片，vm 表示 vasp和 wannier对比
set style data dots # this may be "set data style dots"

x_min = 0
x_max = 2.3418
y_min = -5.0
y_max = 5.0
Efermi = 7.16943909

x0 = 0.0000
x1 = 0.3977 
x2 = 1.1048
x3 = 1.3037
x4 = 1.8037
x5 = 2.3418

set xrange [0: 2.3418]
set yrange [ y_min :  y_max]
set arrow from  x1, y_min  to  x1, y_max nohead
set arrow from  x2, y_min  to  x2, y_max nohead
set arrow from  x3, y_min  to  x3, y_max nohead
set arrow from  x4, y_min  to  x4, y_max nohead
set xtics ("Z"  x0,"G"  x1,"X"  x2,"P"  x3,"N"  x4,"G"  x5)
plot 'anatase_bands.dat.gnu' u 1:($2-Efermi) w l t 'qe'  
#plot 'wann_Udf.spaghetti_ene' u ($4/0.53):5 w l t "wien2k", 'wann_Udf_band.dat' w l t "wannier90" # t 为 设置标题
