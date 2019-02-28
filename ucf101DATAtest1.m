clc
clear
load BalanceBeam4
ucf101test{1} = BalanceBeam2;
clear BalanceBeam2
load Lip4
ucf101test{2} = Lip2;
clear Lip2
load Jack4
ucf101test{3} = Jack2;
clear Jack2
load Fencing4
ucf101test{4} = Fencing2;
clear Fencing2
load Throw4
ucf101test{5} = Throw2;
clear Throw2
load High4
ucf101test{6} = High2;
clear High2
save ucf101test2 ucf101test