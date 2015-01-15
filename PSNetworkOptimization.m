
classdef PSNetworkOptimization
    
    properties
     % contant
     I_list ;  % Матрица смежности
     I;        % Матрица инцидентности
     stations; % Массив подстанций
     x0;       % Начальное решение
     
     vconst_ind; % индексы переменных, которые не меняются в процессе оптимизации (всегда равны 1) 
     xopt_ind;   % индексы переменных, участвующих в оптимизации(лежат в промежутке [0,1])
     
     Hours_count;  % Среднее кол-во часов в году, в которые трансформатор находился в рабочем состоянии,Ч
     Potpusk_real; % Фактический полезный отпуск электросети в году, кв*Ч
     
     Pless_all_consumers; % Нагрузочные потери потребителей, кв*Ч
     Transformer_k_max;   % Максимальный коэф-т загрузки трансформатора
     Transformer_k_opt;   % Оптимальный коэф-т загрузки трансформатора
     Iter_max;            % Максимальное кол-во итераций
    end
    
        
    methods
     % Инициализация объекта
     function obj = PSNetworkOptimization()
     
     end
     
     
     % Инициализация данных объекта
     % Входные параметры:
     % I - матрица смежности
     % Hours_count -  Среднее кол-во часов в году, в которые трансформатор
     % находился в рабочем состоянии, Ч
     % Potpusk_real - Фактический полезный отпуск электросети, кВ*Ч
     % Pless_all_consumers - Нагрузочные потери потребителей, кв*Ч
     % Transformer_k_max - Максимальный коэф-т загрузки трансформатора
     % Transformer_k_opt - Оптимальный коэф-т загрузки трансформатора
     % Возвращает: объект с иниц. данными
     function obj = init(obj,I,Hours_count,Potpusk_real,Pless_all_consumers,Transformer_k_max,Transformer_k_opt,Iter_max)
       obj.Iter_max = Iter_max;
       obj.I_list = I;
       obj.Hours_count = Hours_count; 
       obj.Potpusk_real = Potpusk_real;
       obj.Pless_all_consumers = Pless_all_consumers;
       obj.Transformer_k_max = Transformer_k_max;
       obj.Transformer_k_opt = Transformer_k_opt;
     
       s = size(I);
       st  = size(obj.stations);
       obj.I = zeros(st(2),st(2));
       for i = 1 : s(1)
          mass = cell2mat(I{i,1});
          sm = size(mass);
          ind_i = mass(1);
          for j = 2 : sm(2)
              obj.I(ind_i,mass(j)) = 1; 
          end
       end
       
       s = size(obj.stations);
       kvolt_count = 0;
       for i = 1: s(2)
           kvolt_count = kvolt_count + obj.stations(i).getKVoltConsumers();
       end
       
       for i = 1: s(2)
           obj.stations(i) = obj.stations(i).set_P_Consumers(obj.Potpusk_real/obj.Hours_count,kvolt_count);
           obj.stations(i) = obj.stations(i).set_P_Consumers_less(obj.Pless_all_consumers/obj.Hours_count,kvolt_count);
           obj.stations(i) = obj.stations(i).set_P_opt(obj.stations(i).P_nominal*Transformer_k_opt);
           obj.stations(i) = obj.stations(i).set_Transformer_k_max(Transformer_k_max);
       end    
       
        % form vopt and vopt_ind
       s = size(obj.stations);
      
       ind1 = 1;
       ind2 = 1;
        for j = 1 : s(2)
            sum_i = sum(obj.I(:,j)); 
            if sum_i == 1
                 for i = 1 : s(2)
                     if obj.I(i,j)==1
                          obj.vconst_ind{ind1,1} ={i,j};
                          ind1 = ind1 + 1;
                          
                     end
                 end                   
            end
            
            if sum_i>1
                 for i = 1 : s(2)
                     if obj.I(i,j)==1
                          obj.xopt_ind{ind2,1} ={i,j};
                          xopt{ind2,1} = 1 / sum_i;
                          ind2 = ind2 + 1;
                          
                     end
                 end
            end
        end     
       
        obj.x0 = cell2mat(xopt);
     end
     
     
     % Добавление подстанции в объект
     % index - уникальный индекс подстанции
     % name - название подстанции
     function obj = push_station(obj,index,name)
         s = size(obj.stations);
         p = PowerStation();
         p = p.init(name,[],[]);
         if s(1) ==  0
            obj.stations  = repmat(p,1,1);
            obj.stations(index) = p;
         else
            obj.stations(index) = p;
         end
     end
     
     
     % Добавление подстанции в объект
     % index - уникальный индекс подстанции
     % name - название подстанции
     % transformers: [], массив объектов Transformer
     % consumers: [], данные о потребителях: [n1<кол-во потребителей>,
     % U1<напряжение>;n2<кол-во потребителей>, U2<напряжение>; ...]
     function obj = push_sub_station(obj,index,name, transformers,consumers)
         s = size(obj.stations);
         p = PowerStation();
         p = p.init(name,transformers,consumers);
         if s(1) ==  0
            obj.stations  = repmat(p,1,1);
            obj.stations(index) = p;
         else
              obj.stations(index) = p;
         end
   
     end
     
     
     % Оптимизация(поиск минимума целевой функции)
     function [X,fval,P_real]=min_opt(obj)
       st  = size(obj.stations);
       %'trust-region-reflective', 'active-set', or 'interior-point'.
       options=optimset('Algorithm','active-set','LargeScale','on', 'MaxIter', obj.Iter_max,'Display', 'iter','Jacobian','on');
       [X,fval]=fmincon(@obj.F,obj.x0,[],[],[],[],[],[],@obj.fun_con,options);
       P_real = zeros(size(X,1),1);
       for i = 1 : size(X,1)
          P_real(i) = obj.P_real(X,i);
       end
     end
     
     % Целевая функция 
     function f=F(obj,X)
       r = 0;
       for i = 1 : size(X,1)
           st = obj.stations(i);
           if st.isSubStation()==1
                r = r + obj.Q(st.P_opt - obj.P_otpusk(X,i));
           end
       end
         f = r;
     end
     
     % Ограничения
     function [fc,fceq]=fun_con(obj,X)
 
         s = size(X,1);
         c = zeros(s + size(obj.stations,2),1);
         c_ind = 1;
        
         % Ограничения X>=0
         for k = 1 : s
            c(c_ind) = 100000*X(k)*(-1);
            c_ind = c_ind + 1;      
         end
         
         % Ограничение сверху реальной мощности трансформаторов
         for i = 1 : size(obj.stations,2)
             if obj.stations(i).isSubStation() == 1
                c(c_ind) =  obj.P_real(X,i) - 1.4*obj.stations(i).P_nominal;
                c_ind = c_ind + 1;
             end
         end
         
         % Ограничения sum(X)=1
         c_temp{size(obj.stations,2)} = []; 
         ceq_count = 0;
         for k = 1: s
            %ind_i = obj.vconst_ind{k,1}{1};
            ind_j = obj.xopt_ind{k,1}{2};
            if size(c_temp{ind_j},1) == 0
                c_temp{ind_j} = X(k) - 1.0; 
                ceq_count = ceq_count + 1;
            else
                c_temp{ind_j} = c_temp{ind_j} + X(k);
            end
         end
         ceq = zeros(ceq_count,1);
         ceq_ind = 1;
         for k = 1: size(obj.stations,2)
            if size(c_temp{k},1) ~= 0
                ceq(ceq_ind) = c_temp{k};
                ceq_ind = ceq_ind+1;
            end
         end
             
         fc = c;
         fceq = ceq;   % Compute nonlinear equalities at x.
     end
     
     % Функция потерь
     function q=Q(obj,x)
        q = x*x;
     end
     
     % Полезный отпуск i-й подстанции при весах дуг между подстанциями, равные X   
     function p=P_otpusk(obj,X,i)
            p_t = obj.stations(i).P_consumers +  obj.stations(i).P_consumers_less;
            
            s = size(obj.vconst_ind);
            for k = 1: s(1)
              ind_i = obj.vconst_ind{k,1}{1};
              ind_j = obj.vconst_ind{k,1}{2};
              if(ind_i==i)
                 p_t = p_t +  obj.P_real(X,ind_j);
              end
            end
            
            s = size(obj.xopt_ind);
            for k = 1: s(1)
              ind_i = obj.xopt_ind{k,1}{1};
              ind_j = obj.xopt_ind{k,1}{2};
              if(ind_i==i)
                 p_t = p_t +  obj.P_real(X,ind_j)*X(k);
              end
            end          
            p = p_t;
     end;
     
     % Функция возвращает реальную мощность, потери в трансформаторах и
     % полезный отпуск для i-й подстанции
     function [p_real,p_less,p_otpusk] = P(obj, X, i)
         p_real = 0;
         p_less = 0;
         p_otpusk = obj.P_otpusk(X,i);
         RL = obj.stations(i).P_real_less(p_otpusk);
         s = size(RL,1);
         for i = 1 : s
             p_less = p_less + RL(i,2);
         end
          p_real = p_otpusk + p_less;
     end
     
     
     % Функция возвращает реальную мощность i-й подстанции
     function p_real = P_real(obj, X, i)
        [p,p_less,p_otpusk] = obj.P(X,i);
        p_real = p;
     end
     
     
     % Функция задает вес дуги между подстанцией i и j, равный v 
     function obj = set_x0(obj,i,j,v)
          s = size(obj.xopt_ind);
           for k = 1: s(1)
              ind_i = obj.xopt_ind{k,1}{1};
              ind_j = obj.xopt_ind{k,1}{2};
              if(ind_i==i && ind_j == j)
                 obj.x0(k) = v;
              end
           end  
     end
     
     % Функция возвращает вес дуги между подстанцией i и j 
     function v = get_x0(obj,i,j)
          s = size(obj.xopt_ind);
           for k = 1: s(1)
              ind_i = obj.xopt_ind{k,1}{1};
              ind_j = obj.xopt_ind{k,1}{2};
              if(ind_i==i && ind_j == j)
                 v = obj.x0(k);
              end
           end  
           
           s = size(obj.vconst_ind);
           for k = 1: s(1)
              ind_i = obj.vconst_ind{k,1}{1};
              ind_j = obj.vconst_ind{k,1}{2};
              if(ind_i==i && ind_j == j)
                 v = 1;
              end
           end  
           
     end
     
     
     
     % Функци сохраняет отчет для решения X в файл "file_name" на лист "sheet"
     function createReport(obj,file_name,X,sheet)
         
         s = size(obj.stations);
         count1 = 0;
         count2 = 0;
         
         for i = 1 : s(2)
             if obj.stations(i).isSubStation() == 1
                count1 = count1 + size(obj.stations(i).transformers,1);
             else
                count2 = count2 + 1;
             end
         end    
         row = 1;
         count = count1 + count2;
         
         P_real = zeros(count,1);
         P_less = zeros(count,1);
         P_otpusk = zeros(count,1);
         P_otpuskm = zeros(count,1);
         P_nominal = zeros(count,1);
         P_consumers_less = zeros(count,1);
         
         trans_P_real = zeros(count,1);
         trans_P_less = zeros(count,1);
         trans_P_otpusk = zeros(count,1);
         trans_P_nominal =  zeros(count,1);

         Index = zeros(count,1); 
         P_all = 0;
         for i = 1 : s(2)
             
            [P_real(row),P_less(row),P_otpusk(row)] = obj.P(X,i);
            P_otpuskm(row) = P_otpusk(row)*obj.Hours_count/1000000.0;
            P_nominal(row) =  obj.stations(i).P_nominal;
            Station_name{row,1} = obj.stations(i).name;
            P_consumers_less(row) = obj.stations(i).P_consumers_less;
            Index(row) = i;      
            if obj.stations(i).isSubStation() == 1
                
                s_tr = size(obj.stations(i).transformers,1);
                RL =  obj.stations(i).P_real_less(P_otpusk(row));

                for j = 1 : s_tr
                    trans_P_real(row) = RL(j,1);
                    trans_P_less(row) = RL(j,2);
                    trans_P_otpusk(row) = trans_P_real(row) - trans_P_less(row);
                    trans_P_nominal(row) =  obj.stations(i).transformers(j).P_nominal;
                    trans_name{row,1} = [obj.stations(i).transformers(j).type_name,'  '];
                    row = row + 1;
                    Station_name{row,1} = ['  '];
                end
                
            else
                P_all = P_all + obj.P_otpusk(X,i)*obj.Hours_count/1000000.0;
                row = row + 1;
            end
         end
         row_start = 4;
         xlswrite(file_name{1}, Index, sheet, ['B',num2str(row_start)]);
         xlswrite(file_name{1}, Station_name, sheet, ['C',num2str(row_start)]);
         xlswrite(file_name{1}, P_nominal, sheet, ['D',num2str(row_start)]);
         xlswrite(file_name{1}, P_otpusk, sheet, ['E',num2str(row_start)]);
         xlswrite(file_name{1}, P_otpuskm, sheet, ['F',num2str(row_start)]);
         xlswrite(file_name{1}, P_consumers_less, sheet, ['G',num2str(row_start)]);
         
         
         xlswrite(file_name{1}, P_less, sheet, ['H',num2str(row_start)]);
         xlswrite(file_name{1}, trans_name, sheet, ['I',num2str(row_start)]);
         xlswrite(file_name{1}, trans_P_nominal, sheet, ['J',num2str(row_start)]);
         xlswrite(file_name{1}, trans_P_otpusk, sheet, ['K',num2str(row_start)]);
         xlswrite(file_name{1}, trans_P_less, sheet, ['L',num2str(row_start)]);             
         
         
         
         InitData(1) = obj.Hours_count;
         InitData(2) = obj.Potpusk_real/1000000.0;
         InitData(3) = obj.Pless_all_consumers/1000000.0;
         xlswrite(file_name{1}, InitData', sheet,['E',num2str(row_start+row+1)]);         
    
         ResultData(1) = obj.F(X);
         ResultData(2) = P_all;
         ResultData(3) = sum(P_less)*obj.Hours_count/1000000.0;
         xlswrite(file_name{1}, ResultData', sheet,['E',num2str(row_start+row+1+6)]);         
    
    
         
         
     end
    end
    
end

