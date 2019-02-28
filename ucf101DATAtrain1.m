clc
clear
load BalanceBeam3
ucf101train{1} =  BalanceBeam1;
clear BalanceBeam1
load Lip3
ucf101train{2} =  Lip1;
clear Lip1
load Jack3
ucf101train{3} = Jack1;
clear Jack1
load Fencing3
ucf101train{4} = Fencing1;
clear Fencing1
load Throw3
ucf101train{5} = Throw1;
clear Throw1
load High3
ucf101train{6} = High1;
clear High1
save ucf101train2 ucf101train
