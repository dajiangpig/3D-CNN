clc
clear
load ucf101test2
load NetR11
load NetR22
load NetR33
%一些经常调动的参数
te = 1;
tes = 7;
tright=zeros(2,1);
right=zeros(10,2);
total=zeros(10,2);
result=zeros(10,10);
accuracy = zeros(7,2);
Iobserve = 0; 
probability = zeros(1,6);
%%%%初始化第一阵列集和第二阵列集
col1 = 240;%行 
row1 = 318;%列 2to319
col3 = 78;%行 2to79
row3 = 105;%列 2to106
col2 = 910;%行 26*35
row2 = 6;%列
%%%%%%%%%%%未使用概率的版本
for allcontrol = 1:1000
     uncompress = ucf101test{te};
   te = te + 1;
   if te > 6
      te = 1;
   end    
   chicun = size(uncompress);
   tes = randperm(chicun(1),1); 
   out_ex = uncompress{tes,2};
   numframe = uncompress{tes,5};
    begin = randi([6,11],1,1);
      count = 1;
   for i = begin : 6 : numframe + 5
     V1in{count} = uncompress{tes,i};
%      figure(1)
%      imshow(V1in{count});
     count = count + 1;
   end    
    count = 1;  
   long = length(V1in);
      A = zeros(240,320);
for i = 1:long - 1
    A = V1in{i+1} - V1in{i};
      A(A>5) = 255;
% %            figure(2)
% %            imshow(A);
      A = medfilt2(A);%中值滤波%卷积核为2
      I1{i} = double(A(:,2:319))./NetR1;
%        figure(2)
%        imshow(I1{i});
      A = zeros(240,320);
   end
   clear V1in
   A = zeros(240,318);
   long = length(I1);
   for i = 1:long - 2
  A = I1{i} +  I1{i + 1} + I1{i + 2};%卷积核为2
           for m = 1:col1/3
             for n = 1:row1/3
                 B(m,n) = sum(sum(A(((m - 1) * 3 + 1):(3*m) ,((n - 1) * 3 + 1 ):(3*n))));
             end    
           end   
%            B = medfilt2(B);
           I1out{i} = B;
%            figure(3)
%            imshow(I1out{i});
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
         I3out =  I3out +  I3{i};
%          figure(4)
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
%     figure(3)
%    imshow(V2in)  
            V2 = V2in(:);     
            clear V2in
              for i = 1:row2
                 I2out(i) = sum(V2./NetR2(:,i)); %这一步求出了每一列的输出电流
                 Iobserve(allcontrol,i) = I2out(i);
              end
              [outmax,out] = max(I2out);%找出每一列的最大值（前者），并返回他们的位置（后者）。
            Iobserve(allcontrol,i + 1) = out;
            Iobserve(allcontrol,i + 2) = out_ex;
            Iobserve(allcontrol,i + 3) = tes;
            clear I2out
            clear V2
           tes = tes + 1; 
       if mod(out,10)  == 0
        if out == out_ex 
        tright(1) = tright(1) + 1;
        right(out_ex,1)=right(out_ex,1)+1;   
        end
       end   
    if mod(out,10) == out_ex
        tright(1) = tright(1) + 1;
        right(out_ex,1)=right(out_ex,1)+1;
    end
        total(out_ex,1)=total(out_ex,1)+1;
        result(out_ex,out)=result(out_ex,out)+1;  
end
for te=1:6
        accuracy(te,1) = right(te,1)/total(te,1);
        fprintf('Number: %d, successful rate: %d\n',te,accuracy(te,1));
end
  fprintf('Total successful rate for all: %d\n',tright(1)/allcontrol );
  accuracy(7,1) = tright(1)/allcontrol;
%%%%%%%使用概率的版本
for allcontrol = 1:300
     uncompress = ucf101test{te};
   te = te + 1;
   if te > 6
      te = 1;
   end    
   chicun = size(uncompress);
   tes = randperm(chicun(1),1); 
   out_ex = uncompress{tes,2};
   numframe = uncompress{tes,5};

%    begin = randi([5,10],1,1);
   for begin = 6 : 11
         count = 1;  
   for i = begin : 6 : numframe + 5
     V1in{count} = uncompress{tes,i};
%      figure(1)
%      imshow(V1in{count});
     count = count + 1;
   end    
            count = 1;  
   long = length(V1in);
      A = zeros(240,320);
for i = 1:long - 1
    A = V1in{i+1} - V1in{i};
      A(A>5) = 255;
      A = medfilt2(A);%中值滤波%卷积核为2
      I1{i} = double(A(:,2:319))./NetR1;
%        figure(2)
%        imshow(I1{i});
      A = zeros(240,320);
end
   clear V1in
   A = zeros(240,318);
   long = length(I1);
   for i = 1:long - 2
  A = I1{i} +  I1{i + 1} + I1{i + 2};%卷积核为2
           for m = 1:col1/3
             for n = 1:row1/3
                 B(m,n) = sum(sum(A(((m - 1) * 3 + 1):(3*m) ,((n - 1) * 3 + 1 ):(3*n))));
             end    
           end   
%            B = medfilt2(B);
           I1out{i} = B;
%            figure(3)
%            imshow(I1out{i});
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
         I3out =  I3out +  I3{i};
%          figure(4)
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
%     figure(3)
%    imshow(V2in)  
            V2 = V2in(:);     
            clear V2in
              for i = 1:row2
                 I2out(i) = sum(V2./NetR2(:,i)); %这一步求出了每一列的输出电流
                 Iobserve(allcontrol,i) = I2out(i);
              end
              [outmax,out] = max(I2out);%找出每一列的最大值（前者），并返回他们的位置（后者）。
            Iobserve(allcontrol,i + 1) = out;
            Iobserve(allcontrol,i + 2) = out_ex;
            Iobserve(allcontrol,i + 3) = tes;
            Iobserve(allcontrol,i + 4) = uncompress{tes,3};
            Iobserve(allcontrol,i + 5) = uncompress{tes,4};
            clear I2out
            clear V2
     probability(out) = probability(out) + 1; 
   end    
      probability = probability / sum(probability); %概率计数
      [pmax,pmaxnumber] = max(probability);%得到最终结果
      probability = zeros(1,6);
           tes = tes + 1; 
       if mod(pmaxnumber,10)  == 0
        if pmaxnumber == out_ex 
        tright(2) = tright(2) + 1;
        right(out_ex,2)=right(out_ex,2)+1;   
        end
    end   
    if mod(pmaxnumber,10) == out_ex
        tright(2) = tright(2) + 1;
        right(out_ex,2)=right(out_ex,2)+1;
    end
        total(out_ex,2)=total(out_ex,2)+1;
        result(out_ex,pmaxnumber)=result(out_ex,pmaxnumber)+1;  
  if tes > 9
      tes = 7;
   end  
end
for te=1:6
        accuracy(te,2) = right(te,2)/total(te,2);
        fprintf('Number: %d, successful rate: %d\n',te,accuracy(te,2));
end
  fprintf('Total successful rate for all: %d\n',tright(2)/allcontrol );
  accuracy(7,2) = tright(2)/allcontrol;
 

figure(1)

x = 1:1:7;
y = 0.4:0.1:1.0;
% zifux = {'Sh1','Sh2','Sh3','Sh4','Sh5','Sh6','Sh7','Sh8','Sh9','Sh10','Total'};
zifux = {'Sh1','Sh2','Sh3','Sh4','Sh5','Sh6','Total'};
zifuy = {'40%','50%','60%','70%','80%','90%','100%'};
axis tight
plot(x,accuracy,'*')
%下面定义x轴的刻度
set(gca,'XTick',x)
%下面是x轴的刻度值
set(gca,'XTickLabel',zifux)
%下面定义y轴的刻度
set(gca,'YTick',y)
%下面是y轴的刻度值
set(gca,'YTickLabel',zifuy)
h = gca;
%th=rotateticklabel(h);
%加入百分号
Hpercent = num2cell(accuracy(:,1));
for te=1: length(accuracy(:,1))
    Hpercent(te)={[num2str(accuracy(te,1) * 100),'%']};
end
for te = 1:length(x)
    text(x(te),accuracy(te,1)+0.02,Hpercent(te))
end
%xLabel('Shape');
%yLabel('Accuracy')
title('The Final Accuracy')
accuracy = roundn(accuracy,-4);%保留两位小数
figure(2)
% h = bar(x,[accuracy(:,1) accuracy(:,2) accuracy(:,3)]);
h = bar(x,[accuracy(:,1) accuracy(:,2)]);
y = 0:0.1:1.0;
zifuy = {'0','10%','20%','30%','40%','50%','60%','70%','80%','90%','100%'};
ylim([0 1]);
%下面定义x轴的刻度
set(gca,'XTick',x)
%下面是x轴的刻度值
set(gca,'XTickLabel',zifux)
%%下面定义y轴的刻度
set(gca,'YTick',y)
%下面是y轴的刻度值
set(gca,'YTickLabel',zifuy)
%%%%加入百分号
Hpercent = num2cell(accuracy);
for j = 1:2
   for i=1: length(accuracy(:,1))
     Hpercent(i,j)={[num2str(accuracy(i,j) * 100),'%']};
   end
end
  for i = 1:length(x)
     text(x(i) + 0.13,accuracy(i,2)+0.03,Hpercent(i,2),'fontsize',13)
  end
set(h(1), 'facecolor', 'r');
set(h(2), 'facecolor', 'k');
% set(h(3), 'facecolor', 'm');
% legend('Epoch = 2000','Epoch = 4000','Epoch = 6000');
%legend('Without Probability','With Probability');
% xLabel('Shape','fontsize',13);
% yLabel('Accuracy','fontsize',13);
% title('The Final Accuracy')
set(gca,'FontSize',13);

fclose('all');
for te=1:10
    for j=1:10
    resultrate(te,j)=result(te,j)/total(te);
    end
end