
function X_out=sdp_solver(W)

N=size(W,1);

blk{1,1} = 's'; blk{1,2} = N;
C=cell(1);
L=cell(1);
At=cell(1);

C{1}=sparse(W);
L{1}=-.5*ones(N);

A_all=[];
for i=1:N
    A_i=zeros(N,N);
    A_i(i,i)=1;
    A_i_svec=svec(blk(1,:),A_i);
    A_all=[A_all, A_i_svec];
end
At{1}= A_all; 

b=ones(1,N);

X_init=cell(1);
X_init{1}=ones(N);


OPTIONS.printlevel=1;
OPTIONS.tol=1e-1; % 1e-2
OPTIONS.ADMtol=1e-1;
%OPTIONS.ADMmaxiter=100; 
%OPTIONS.maxiter=300;
OPTIONS.AATsolve.method='iterative'; % 'direct' (default) 


[obj,X,s,y,Z1,Z2,y2,v,info,runhist]=sdpnalplus(blk,At,C,b,L,[],[],[],[],OPTIONS,X_init);

X_out=X{1};
end
