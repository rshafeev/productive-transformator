classdef PowerStation
    
    

    
    properties(GetAccess = 'public', SetAccess = 'private')
        is_sub             % 0 - нет данных о трансформаторах, 1 - есть        
        name               % имя станции(подстанции)
        transformers       % трансформаторы
        consumers          % потребители (матрица [напряжение1 , количество1; ... ;напряжениеK , количествоK])
        P_consumers        % реальная мощность всех потребителей 
        P_consumers_less   % нагрузочные потери
        P_nominal          % номинальная общая мощность всех трансформаторов
        P_opt              % оптимальная мощность трансформаторов
        Transformer_k_max; % максимальный коэф-т загрузки трансформаторов
      end         
    
    methods
        function obj = PowerStation()

        end
        
        function f = isSubStation(obj)
            f = obj.is_sub;
        end
        function obj = set_P_opt(obj,p)
           obj.P_opt =  p;   
        end
        function obj = set_Transformer_k_max(obj,k)
           obj.Transformer_k_max = k;
        end
        
        function obj = init(obj,name,transformers,consumers)
            obj.name = name;
            obj.transformers = transformers;
            obj.consumers = consumers;
            obj.P_consumers = 0;   
            s  = size(transformers);
            
            if s(1) == 0 
                obj.P_nominal = 0;
                obj.is_sub = 0;
            else
                obj.P_nominal = 0;
                obj.P_opt = 0;
                obj.is_sub = 1;
                for i = 1 : s(1)
                   obj.P_nominal = obj.P_nominal + obj.transformers(i).P_nominal; 
                end
            end
        end
        
        function P = getP_nominal(obj)
           P = obj.P_nominal;
        end
        
        function kvolt_count  = getKVoltConsumers(obj)
            kvolt_count = 0;
            s = size(obj.consumers);
            for i = 1 : s(1)
                kvolt_count = kvolt_count + obj.consumers(i,1)*obj.consumers(i,2);
            end
        end
        
        function obj  = set_P_Consumers(obj,p, kvolt_count)
            obj.P_consumers = p/kvolt_count*obj.getKVoltConsumers();
        end
        
        function obj  = set_P_Consumers_less(obj,p, kvolt_count)
            obj.P_consumers_less = p/kvolt_count*obj.getKVoltConsumers();
        end
        
        function  RL = P_real_less(obj,P_otpusk)
            k = obj.P_opt/obj.P_nominal;
           if obj.is_sub == 1
               s = size(obj.transformers,1);
               RL = zeros(s,2);
               if s == 1
                   [p_real,p_less] = obj.transformers(1).getP_real_less(P_otpusk);
                   RL = [p_real , p_less ];
               end
               if s == 2
                   if P_otpusk<=k*obj.transformers(1).P_nominal
                      [p_real1,p_less1]  = obj.transformers(1).getP_real_less(P_otpusk);
                      [p_real2,p_less2]  = obj.transformers(2).getP_real_less(0);
                      RL = [p_real1,p_less1 ; p_real2,p_less2 ];
                   else
                      p1 = P_otpusk*obj.transformers(1).P_nominal/(obj.transformers(1).P_nominal+obj.transformers(2).P_nominal);
                      p2 = P_otpusk*obj.transformers(2).P_nominal/(obj.transformers(1).P_nominal+obj.transformers(2).P_nominal);
                      [p_real1,p_less1]  = obj.transformers(1).getP_real_less(p1);
                      [p_real2,p_less2]  = obj.transformers(2).getP_real_less(p2);
                      RL = [ p_real1,p_less1 ;  p_real2,p_less2 ];
                   end 
                   
               end
               
               if s > 2
                   
               end
               
           else
                RL = [P_otpusk , 0 ];
           end
           
        end
        
        
    end
    
end

