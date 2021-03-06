% solving
%clearvars
%i=0;j=2;
%fragment_file=strcat('data/5m_.001_1_cov5/',num2str(i),'/frag',num2str(i),'_',num2str(j),'.txt')

function H_final=hap10(fragment_file,K)

addpath(genpath('/mnt/LTR_userdata/majid001/software/code_matlab/SDPNAL'))

name_out_mat=frag2mat(fragment_file);
name_hap=strcat(fragment_file(1:length(fragment_file)-3),'hap');
load(name_out_mat)

min_allele_row=3;

cov=sum(abs(full(R)));
[mean(cov),  min(cov)]
allel_each_row=sum(abs(full(R)),2);
[mean(allel_each_row), min(allel_each_row)]

size(R)
allel_each_row=sum(abs(full(R)),2);    
frags_good_length_ind=allel_each_row>min_allele_row;
R=R(frags_good_length_ind,:);   
cov=sum(abs(full(R)));
good_cov_snp= find(cov>2); % if coverage of a column is less than 3, remove it.
R=R(:,good_cov_snp);
hap_index=hap_index(good_cov_snp);
allel_each_row=sum(abs(full(R)),2);    
frags_good_length_ind=find(allel_each_row>=min_allele_row);
R=R(frags_good_length_ind,:);  
size(R)
cov=sum(abs(full(R)));
[mean(cov),  min(cov)]
allel_each_row=sum(abs(full(R)),2);
[mean(allel_each_row), min(allel_each_row)]



N=size(R,1);
l=size(R,2);
W=zeros(N,N);
diag_const=0;
W(1,1)=diag_const;
R1=full(R);
for i=2:N
    line_i=R1(i,:);
    W(i,i)=diag_const;
    for j=1:(i-1)
        line_j=R1(j,:);
        SNP_shared=sum( (line_i~=0) & (line_j~=0));
        allele_shared=sum( line_i.*line_j);
        if SNP_shared>0
            W(i,j)=(2*allele_shared-SNP_shared)/SNP_shared;
        end
    end
end
W=W'+tril(W,-1);
size(W)

 
X=sdp_solver(-W);
 

[Q, sig]=eig(X);
[val_eig, idx]=sort(diag(sig), 'descend'); % ascend[1,2,3]  descend [2,3,1]
three_ind_largest=idx(1:K); % sometimes  the third is zero
val_eig(1:7)'

V=Q(:,three_ind_largest)*sqrt(sig(three_ind_largest,three_ind_largest));


V_arch=V;


object_all=[];
indx_all=[];

 num_it=50*floor(log2(N));
for ii=1:num_it
    Z=normrnd(0,1,[K,K]); %Z=normalize(Z);
    VZ=V*Z;
    [val, index]=max(VZ');
    X_estimated=ones(N,N);
    for i=1:N
        for j=1:N
            if index(i)~=index(j)
                X_estimated(i,j)=-1;
            end
        end
    end
    object_all=[object_all; trace(W*X_estimated)  ];
    indx_all=[indx_all;index];
end

[vall,i_best]=max(object_all);
index_best=indx_all(i_best,:);
 
size(index_best)

R=full(R);
H=zeros(K,l);

for i_k=1:K
   R(index_best==i_k,:);
   H(i_k,:)=sum(R(index_best==i_k,:))>0;
end



% % % % %%% greedy refinement
H_new=2*H-1;


H_final=refiner(R,H_new);

mec_final=mec_calculator(R,H_final);




indces_block=hap_index'-1;  % The output file will be like sdhap. index starts from zero
H_with_ind=[indces_block, (H_final'+1)/2+1];

fileID_hap = fopen(name_hap,'w'); 
fprintf(fileID_hap,'Block 1\t Length of haplotype block %d\t Number of read %d\t Total MEC %d \n',length(indces_block),N,mec_final);
string_d=strcat(repmat('%d\t', 1, K),'%d\n');
fprintf(fileID_hap,string_d,H_with_ind');
fclose(fileID_hap);


end
