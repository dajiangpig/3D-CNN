clear
clc
load ucf101train2
%tabulate(B(:));%��Ƶ���ú�����
%һЩ���������Ĳ���
te = 1;
tes = 1;
yita = 670;
right = 0;%������ȷ�жϵ�����
plotxi = 0;
houhou = 1;
%%%%��ʼ����һ���м��͵ڶ����м�
col1 = 240;%�� 
row1 = 318;%�� 2to319
col3 = 78;%�� 2to79
row3 = 105;%�� 2to106
col2 = 910;%�� 26*35
row2 = 6;%��
%%% mu:��ֵ��sigma:��׼��
mu_ron=500;%����̬
sigma_ron=50;
mu_roff=50e3;%����̬
sigma_roff=5e3;
%��̬�ֲ�ֻ��Ҫ2��������
%randn() �Ǳ�׼��̬�ֲ�
NetR1 = normrnd(mu_ron,sigma_ron,col1,row1);      %��һ���У������
NetR3 = normrnd(mu_ron,mu_ron,col3,row3);      %�������У������
NetR2 = normrnd(mu_roff,sigma_roff,col2,row2);      %�ڶ����У�ȫ���Ӳ�
setchangeNetR2 = zeros(col2,row2);
reschangeNetR2 = zeros(col2,row2);

for allcontrol = 1:6000
     uncompress = ucf101train{te};
    te = te + 1;
   if te > 6
      te = 1;
   end    
   chicun = size(uncompress);
   tes = randperm(chicun(1),1); 
   out_ex = uncompress{tes,2};%��λ����
   numframe = uncompress{tes,5};%֡��
   count = 1;
   begin = randi([6,11],1,1);
   for i = begin : 6 : numframe + 5
     V1in{count} = uncompress{tes,i};
%     figure(1)
%      imshow(V1in{count});
     count = count + 1;
   end    
   long = length(V1in);
    A = zeros(240,320);
   for i = 1:long -1
       A = V1in{i+1} - V1in{i};
%        figure(2)
%      imshow(A);
      A(A>5) = 255;
      A = medfilt2(A);%��ֵ�˲�%�����Ϊ2
      I1{i} = double(A(:,2:319))./NetR1;
%       figure(3)
%      imshow(I1{i});
      A = zeros(240,320);
   end
   clear V1in
   A = zeros(240,318);
   long = length(I1);
   for i = 1 : long - 2
           A = I1{i} +  I1{i + 1} + I1{i + 2};
           for m = 1:col1/3
             for n = 1:row1/3
                 B(m,n) = sum(sum(A(((m - 1) * 3 + 1):(3*m) ,((n - 1) * 3 + 1 ):(3*n))));
             end    
           end   
           I1out{i} = B;
%              figure(4)
%             imshow(B);
           B = 0; 
    A = zeros(240,318);
  end         
  clear I1  
      A = zeros(80,106);
      I3out = zeros(col3,row3);
  for i = 1:length(I1out)
          A = I1out{i};
          I3{i} = A(2:79,2:106)*1e3./NetR3;
         I3{i} = medfilt2(I3{i});
%           figure(4)
%          imshow(I3{i});
         I3out =  I3out +  I3{i};
%          figure(5)
%          imshow(I3out);
            A = zeros(80,106);
  end    
  clear I1out
    for m = 1:col3/3
             for n = 1:row3/3
                 V2in(m,n) = sum(sum(I3out(((m - 1) * 3 + 1):(3*m) ,((n - 1) * 3 + 1 ):(3*n))));
             end    
    end  
       clear I3out
                T = mean(mean(V2in));
        V2in(V2in<T) = 0; 
          V2 = V2in(:);
          clear V2in
     for t = 1:10                
              for i = 1:row2
                 I2out(i) = sum(V2./NetR2(:,i)); %��һ�������ÿһ�е��������
                 Iobserve(houhou,i) = I2out(i);
              end
          [outmax,out] = max(I2out);%�ҳ�ÿһ�е����ֵ��ǰ�ߣ������������ǵ�λ�ã����ߣ���
            Iobserve(houhou,i + 1) = out;
            Iobserve(houhou,i + 2) = out_ex;
            Iobserve(houhou,i + 3) = tes;
            Iobserve(houhou,i + 4) = uncompress{tes,3};
            Iobserve(houhou,i + 5) = uncompress{tes,4};
        houhou = houhou + 1;
           %%%%%%%%%%%%%%%%�����Ƿ��򴫲�����
          I_ex = I2out(out_ex);    
          I_out = I2out(out); 
          if mod(out,10)==out_ex
            if t==1
                right = right + 1;%��ȷ�ж�+1    
            end
         %  break;
            %%����жϽ������
        else
            for m = 1:row2
                if mod(m,10) == out_ex%�ҵ���ȷ����һ��                         
                   for n = 1:col2     
                    setchangeNetR2(n,m) = setchangeNetR2(n,m) + (I_ex - I_out) * V2(n);
                    %��һ��˼·���£�����ÿһ���������ĵ�����Ҫ�õ�����Ҫ��ȥ
                    %�� ���� ��I_ex(n) - I_out(n)�� * V2_in(n)��2018.2.24
                   end
                   setchangeNetR2 = yita * sign(setchangeNetR2);
                   NetR2 = NetR2 + setchangeNetR2 ;
                   setchangeNetR2 = zeros(col2,row2);
                    %%%%%%%���Ϸ��򴫸��ڶ���
                    %%%%%%%����д���򵽵�һ���
                else
                    if m==out
                      for n = 1:col2     
                       reschangeNetR2(n,m) = reschangeNetR2(n,m) + (I_out - I_ex) * V2(n);
                      end
                   reschangeNetR2 = yita * sign(reschangeNetR2);
                   NetR2 = NetR2 + reschangeNetR2 ;
                   reschangeNetR2 = zeros(col2,row2);
                        %%%%%%%���Ϸ��򴫸��ڶ���
                        %%%%%%%����д���򵽵�һ���
                    end
                end
            end
          end
clear I2out
     end
     
      if rem(allcontrol,100)==0
       figure(1)
        plotxi = plotxi + 1;
        plotx(plotxi) = plotxi * 100;
        ploty(plotxi) = right/100;
        right=0;
        plot(plotx,ploty,'-*')
        % pause(n)�����÷����ڼ���ִ��ǰ��ִֹ�г���n��
        pause(0.1);
      end
  if allcontrol == 3000
       yita = yita/10;
  end    
%   if allcontrol == 3500
%        yita = yita/10;
%   end    
 clear V2
%       tes = tes + 1;
%    if tes > 75
%       tes = 1;
%    end   
end    
save NetR1 NetR1
save NetR2 NetR2
save NetR3 NetR3