using Distributed
addprocs(10)
@everywhere using DynamicalSystems, SharedArrays, Statistics, Plots, DelimitedFiles, InformationMeasures
@everywhere using FdeSolver

@everywhere function F(t, u, par)

	######################
	## parameters
	#####################

    a     =  0.5;
    beta  =  1.0;
    delta = -1.0;
    f0    =  2.5;
    mu    =  0.8;
     k    = par[1];
     w    =  1.0;

    du1 = u[2];
    du2 = mu*(1-u[1]^2)*u[2]-u[1]-u[1]^3+f0*cos(w*t)+k*(u[3]-u[1]);
    du3 = u[4];
    #du4 = mu*(1-u[3]^2)*u[4]-u[3]-u[3]^3+k*(u[1]-u[3]);#
    du4 = -a*u[4]-delta*u[3]-beta*u[3]^3+k*(u[1]-u[3]);
    
    return [du1, du2, du3, du4]
end

@everywhere  function SINCRO(x1, x2, x3, x4)

    teta1 = atan.(x2./x1);
    teta2 = atan.(x4./x3);
    omega1 = mean(teta1);
    omega2 = mean(teta2);
    
    PS = abs.(teta1 .- teta2)
    FS = abs(omega1 - omega2)

    return FS;

end

q = range(0.5,1.0,length=800)
coupled = range(0.0,1.0,length=800)
for k = 200:1:399
    sync  = SharedMatrix{Float64}(length(q),6);
   @sync @distributed  for i = 1:1:length(q)
        tSpan = [0, 1000]
        y0    = [0.01, 0.01, 0.01, 0.01]
        par   = [coupled[k]]
        alpha = [1.0;1.0;1.0;1.0].*q[i]
        t, tr = FDEsolver(F, tSpan, y0, alpha, par, h = 0.01, nc =3, tol =1e-3)
        Ttr = Int(round(length(t)*0.1));
        x1 = tr[Ttr:end,1];
        x2 = tr[Ttr:end,2];
        x3 = tr[Ttr:end,3];
        x4 = tr[Ttr:end,4];
        sync[i,1] = SINCRO(x1, x2, x3, x4)
        sync[i,2] = get_entropy(x1)
    	sync[i,3] = get_entropy(x3)
    	sync[i,4] = get_entropy(x1, x3)
	sync[i,5] = get_mutual_information(x1,x3)
	sync[i,6] = get_conditional_entropy(x1, x3)
    end
    writedlm("Res_$(k).dat",[q sync])
    @show k
end
