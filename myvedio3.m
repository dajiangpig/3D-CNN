clear
clc
load ucf101train2
%tabulate(B(:));%查频率用很有用
%一些经常调动的参数
te = 1;
tes = 1;
yita = 670;
right = 0;%代表正确判断的数量
plotxi = 0;
houhou = 1;
%%%%初始化第一阵列集和第二阵列集
col1 = 240;%行 
row1 = 318;%列 2to319
col3 = 78;%行 2to79
row3 = 105;%列 2to106
col2 = 910;%行 26*35
row2 = 6;%列
%%% mu:均值，sigma:标准差
mu_ron=500;%低阻态
sigma_ron=50;
mu_roff=50e3;%高阻态
sigma_roff=5e3;
%正态分布只需要2个参数。
%randn() 是标准正态分布
NetR1 = normrnd(mu_ron,sigma_ron,col1,row1);      %第一阵列：卷积层
NetR3 = normrnd(mu_ron,mu_ron,col3,row3);      %第三阵列：卷积层
NetR2 = normrnd(mu_roff,sigma_roff,col2,row2);      %第二阵列：全连接层
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
   out_ex = uncompress{tes,2};%单位代码
   numframe = uncompress{tes,5};%帧数
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
      A = medfilt2(A);%中值滤波%卷积核为2
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
                 I2out(i) = sum(V2./NetR2(:,i)); %这一步求出了每一列的输出电流
                 Iobserve(houhou,i) = I2out(i);
              end
          [outmax,out] = max(I2out);%找出每一列的最大值（前者），并返回他们的位置（后者）。
            Iobserve(houhou,i + 1) = out;
            Iobserve(houhou,i + 2) = out_ex;
            Iobserve(houhou,i + 3) = tes;
            Iobserve(houhou,i + 4) = uncompress{tes,3};
            Iobserve(houhou,i + 5) = uncompress{tes,4};
        houhou = houhou + 1;
           %%%%%%%%%%%%%%%%以下是反向传播部分
          I_ex = I2out(out_ex);    
          I_out = I2out(out); 
          if mod(out,10)==out_ex
            if t==1
                right = right + 1;%正确判断+1    
            end
         %  break;
            %%如果判断结果错误
        else
            for m = 1:row2
                if mod(m,10) == out_ex%找到正确的那一个                         
                   for n = 1:col2     
                    setchangeNetR2(n,m) = setchangeNetR2(n,m) + (I_ex - I_out) * V2(n);
                    %另一种思路如下，该列每一个忆阻器的电流都要用到，都要减去
                    %即 利用 （I_ex(n) - I_out(n)） * V2_in(n)，2018.2.24
                   end
                   setchangeNetR2 = yita * sign(setchangeNetR2);
                   NetR2 = NetR2 + setchangeNetR2 ;
                   setchangeNetR2 = zeros(col2,row2);
                    %%%%%%%以上反向传给第二层
                    %%%%%%%下面写反向到第一层的
                else
                    if m==out
                      for n = 1:col2     
                       reschangeNetR2(n,m) = reschangeNetR2(n,m) + (I_out - I_ex) * V2(n);
                      end
                   reschangeNetR2 = yita * sign(reschangeNetR2);
                   NetR2 = NetR2 + reschangeNetR2 ;
                   reschangeNetR2 = zeros(col2,row2);
                        %%%%%%%以上反向传给第二层
                        %%%%%%%下面写反向到第一层的
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
        % pause(n)：此用法将在继续执行前中止执行程序n秒
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