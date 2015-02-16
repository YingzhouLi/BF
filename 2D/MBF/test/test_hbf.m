close all;
clear all;
clc;

addpath('../src/');
data_path = '/home/ryanli/Documents/Research/HBF/data/';
log_path = './log/';

if(~exist(data_path, 'dir'))
    mkdir(data_path);
end
if(~exist(log_path, 'dir'))
    mkdir(log_path);
end

%% Set up parameters
N = 128;
tol=1e-6;
mR = 25;         %max rank
tukey_r = 0.1;

k = -N/2:N/2-1;
kbox = [-N/2,N/2;-N/2,N/2];
[k1s,k2s] = ndgrid(k);
k1s = k1s(:);  k2s = k2s(:);
kk = [k1s k2s];

x = (0:N-1)'/N;
xbox = [0,1;0,1];
[x1s,x2s] = ndgrid(x);
x1s = x1s(:);  x2s = x2s(:);
xx = [x1s x2s];

func_name = 'fun0W';
switch func_name
    case 'funF'
        fun = @funF;
    case 'fun0'
        fun = @fun0;
    case 'fun0W'
        fun = @(x,k)fun0W(x,k,N,tukey_r);
        func_name = [func_name num2str(tukey_r)];
    case 'fun1'
        fun = @fun1;
    case 'fun1W'
        fun = @(x,k)fun1W(x,k,N,tukey_r);
        func_name = [func_name num2str(tukey_r)];
    case 'fun2'
        fun = @fun2;
    case 'fun2W'
        fun = @(x,k)fun2W(x,k,N,tukey_r);
        func_name = [func_name num2str(tukey_r)];
end

%% Begin test
if(1)
    if(1)
        f = randn(N,N) + sqrt(-1)*randn(N,N);
        binstr = sprintf('f_%d.bin', N);
        fid = fopen(binstr,'w');
        string = {'CpxNumMat'};
        serialize(fid, f, string);
    end
    if(0)
        binstr = sprintf('f_%d.bin', N);
        fid = fopen(binstr,'r');
        string = {'CpxNumMat'};
        f = deserialize(fid, string);
    end
    f = reshape(f,N^2,1);

    tic;
    y = zeros(N^2,1);
    for i=1:N^2
        y(i) = fun(xx(i,:),kk)*f;
    end
    toc;

    tic;
    Factors = hbf(N, fun, xx, xbox, kk, kbox, mR, tol, 1, 1);
    FactorT = toc;

    tic;
    yy = apply_hbf(Factors,f);
    ApplyT = toc;
    RunT = FactorT + ApplyT;

    disp(['------------------------------------------']);
    disp(['N                 : ' num2str(N)]);
    disp(['Function name     : ' func_name]);
    disp(['Max Rank          : ' num2str(mR)]);
    disp(['Tolerance         : ' num2str(tol)]);
    disp(['Relative Error_1  : ' num2str(norm(y-yy,1)/norm(y,1))]);
    disp(['Relative Error_2  : ' num2str(norm(y-yy)/norm(y))]);
    disp(['Relative Error_inf: ' num2str(norm(y-yy,inf)/norm(y,inf))]);
    disp(['Running Time      : ' num2str(RunT/60) ' mins']);
    disp(['Factorization Time: ' num2str(FactorT/60) ' mins']);
    disp(['Applying Time     : ' num2str(ApplyT) ' s']);
    disp(['------------------------------------------']);

    save([data_path 'Factors_' func_name '_' num2str(N) '_' num2str(mR) '.mat'],'Factors','-v7.3');
    fid = fopen([log_path 'Factors_' func_name '_' num2str(N) '_' num2str(mR) '.log'],'w+');
    fclose(fid);

end