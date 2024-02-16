import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as colors
from matplotlib.ticker import FormatStrFormatter
import os

script_dir = os.path.dirname(__file__)
results_dir = os.path.join(script_dir, 'FIGS/')

def graphic_create(matrix, Xlab, Ylab,names,maps,name_clab):

    matrix = np.flipud(matrix)
    plt.rcParams['text.usetex'] = True
    plt.rcParams.update({'font.size':16})

    fig = plt.figure(figsize=(8,6))
    plot = plt.imshow(matrix,cmap= maps, extent= [0.0,1.0,0.0,1.0],interpolation='gaussian', aspect='auto')
    plt.xlabel(Xlab)
    plt.ylabel(Ylab)
    plt.colorbar(plot,label=name_clab)
    fig.subplots_adjust(wspace=0.455, hspace=0.51)
    plt.savefig(results_dir+names+"_.png",dpi=600,bbox_inches='tight')
    plt.savefig(results_dir+names+"_.pdf",format="pdf",dpi=600,bbox_inches='tight')
    plt.savefig(results_dir+names+"_.eps",format="eps",dpi=600)

outputs = ["sync", "entropy_x1","entropy_x3","entropy_x1_x_3","mutual_information","conditional_entropy"]
color_maps = ["inferno","Spectral","Spectral","Spectral","plasma","cividis_r"]
Clab = [r"$|\Omega_1-\Omega_2|$",r"$H_{x_1}$",r"$H_{x_3}$",r"$H_{x_1,x_3}$",r"$I(x_1,x_3)$",r"H(x1;x3)"]
N = 799
for i,  outs in enumerate(outputs):
    A = []
    for j in range(400,N):
        input    = "Res_"+str(j)+".dat"
        lyapunov = np.loadtxt(input, dtype = float)
        A.append(lyapunov[:,(i+1)])

    graphic_create(A, r'$a_0$', r'$b_0$',outs, color_maps[i], Clab[i])
    print("Figura--"+outs+"--salva"+"--com--colormap:"+color_maps[i])

