
s = size(ps_opt.stations);

P_otp = zeros(10,1);
P_otpusk = 0;
for i = 1 : s(2)
    P_otp(i) =  ps_opt.P_otpusk(ps_opt.x0,i);
end
for i = 1 : 9
    P_otpusk = P_otpusk +  ps_opt.P_otpusk(ps_opt.x0,i);
end

P_cons = 0;

for i = 1 : s(2)
    P_cons = P_cons + ps_opt.stations(i).P_consumers;
end

