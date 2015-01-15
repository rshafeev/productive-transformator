classdef Transformer
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(GetAccess = 'public', SetAccess = 'private')
        type_name   % тип
        P_nominal   % номинальная мощность
        Voltages    % напряжение
        less_k1
        less_k2
    end
    
    methods
     
     function obj = Transformer(v_P_nominal,v_Voltages,v_type_name)
         
         if v_P_nominal == 40000
            obj.less_k1 = 170;
            obj.less_k2 = 34;
         end
         if v_P_nominal == 25000
            obj.less_k1 = 120;
            obj.less_k2 = 25;
         end
         if v_P_nominal == 20000
            obj.less_k1 = 120;
            obj.less_k2 = 25;
         end
         if v_P_nominal == 16000
            obj.less_k1 = 85;
            obj.less_k2 = 18;
         end
         if v_P_nominal == 10000
            obj.less_k1 = 60;
            obj.less_k2 = 12;
         end
         if v_P_nominal == 6300
            obj.less_k1 = 60;
            obj.less_k2 = 12;
         end
         if v_P_nominal == 5600
            obj.less_k1 = 46.5;
            obj.less_k2 = 8;
         end
         
         
         obj.P_nominal = v_P_nominal;
         obj.Voltages = v_Voltages;
         obj.type_name = v_type_name;
     end
     
     % Возвращает потери в трансформаторе и реальную мощность при полезном
     % отпуске P_otpusk
     function [p_real,p_less] = getP_real_less(obj,P_otpusk)
         p_real  = (obj.P_nominal^2 - obj.P_nominal*sqrt(obj.P_nominal^2 - 4*obj.less_k1*(obj.less_k2 + P_otpusk)))/(2*obj.less_k1);
         p_less  = obj.less_k1*(p_real^2)/(obj.P_nominal^2) + obj.less_k2;
     end
     
     
    end
    
end

