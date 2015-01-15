            

close all
clear all

% Основные параметры системы
Hours_count = 6000;               % время работы трансформатора в году(час)
Potpusk_real = 1384000000;        % Общий полезный отпуск в год, кВ*ч
Pless_all_consumers = 306800000;  % Общие нагрузочные потери, кВ*ч
Transformer_k_max = 1.4;          % Максимальный коэф-т загрузки трансформатора
Transformer_k_opt = 0.8;          % Оптимальный коэф-т загрузки трансформатора
Iter_max = 3;                     % Максимальное кол-во итераций

% Создаем объект класса PSNetworkOptimization, который позволяет выполнить
% оптимизацию потерь в трансформаторах и вычислить полезный отпуск
ps_opt = PSNetworkOptimization();

% Заносим данные о подстанциях, которые не имеют данные о трансформаторах
% входные параметры:
% параметр 1 - уникальный индекс подстанции
% параметр 2 - название подстанции
ps_opt = ps_opt.push_station(1,'Орджоникидзебад');
ps_opt = ps_opt.push_station(2,'Северная');
ps_opt = ps_opt.push_station(3,'Джангал');
ps_opt = ps_opt.push_station(4,'ОРУ ДТЭЦ');
ps_opt = ps_opt.push_station(5,'ГЭС 2');
ps_opt = ps_opt.push_station(6,'Новая');
ps_opt = ps_opt.push_station(7,'Джами');
ps_opt = ps_opt.push_station(8,'Жукова');
ps_opt = ps_opt.push_station(9,'Мех. кар');

% Заносим данные о подстанциях с известными данными о трансформаторах
% входные параметры:
% параметр 1 - уникальный индекс подстанции
% параметр 2 - название подстанции
% параметр 3 - массив трансформаторов [Трансформатор1(мощность,[напряжение], название); Трансформатор2(мощность,[напряжение], название); ... ]
% параметр 4 - потребители [n1<кол-во потребителей>, U1<напряжение>;n2<кол-во потребителей>, U2<напряжение>; ...]
ps_opt = ps_opt.push_sub_station(10,'Академгородок', [Transformer(16000,[110 35 10],'T-1') ; Transformer(16000,[110 35 10],'T-2')],[35 1; 10 12]);
ps_opt = ps_opt.push_sub_station(11,'Анзоб', [Transformer(16000,[110 6],'T-1')],[6 4]);
ps_opt = ps_opt.push_sub_station(12,'Авиатор', [Transformer(10000,[110 35 6],'T-1')],[6 5]);
ps_opt = ps_opt.push_sub_station(13,'Бахор', [Transformer(16000,[110 10],'T-1');Transformer(16000,[110 10],'T-2')],[10 14]);
ps_opt = ps_opt.push_sub_station(14,'Вахдат', [Transformer(16000,[110 6],'T-1')],[6 13]);
ps_opt = ps_opt.push_sub_station(15,'Винзаводская', [Transformer(10000,[35 6],'T-1');Transformer(10000,[35 6],'T-2')],[6 13]);
ps_opt = ps_opt.push_sub_station(16,'Восточная', [Transformer(25000,[110 35 6],'T-1');Transformer(25000,[110 35 6],'T-2')],[6 11]);
ps_opt = ps_opt.push_sub_station(17,'Водонасосная', [Transformer(10000,[35 6],'T-1')],[6 5]);
ps_opt = ps_opt.push_sub_station(18,'Главная', [Transformer(40000,[110 35 6],'T-1');Transformer(25000,[110 35 6],'T-2')],[6 15]);
ps_opt = ps_opt.push_sub_station(19,'Душанбе', [Transformer(16000,[110 35 10],'T-1');Transformer(20000,[110 35 10],'T-2')],[10 8]);
ps_opt = ps_opt.push_sub_station(20,'Заводская', [Transformer(25000,[110 35 10],'T-1');Transformer(25000,[110 35 10],'T-2')],[]);
ps_opt = ps_opt.push_sub_station(21,'Истиклол', [Transformer(10000,[35 6],'T-1')],[6 4]);
ps_opt = ps_opt.push_sub_station(22,'Кофарн.водозабор', [Transformer(16000,[110 35 6],'T-1');Transformer(16000,[110 35 6],'T-2')],[35 3; 6 8]);
ps_opt = ps_opt.push_sub_station(23,'Лучоб', [Transformer(16000,[110 10],'T-1');Transformer(16000,[110 10],'T-2')],[10 12]);
ps_opt = ps_opt.push_sub_station(24,'Очистит. сооружения', [Transformer(10000,[35 6],'T-1');Transformer(10000,[35 6],'T-2')],[6 11]);
ps_opt = ps_opt.push_sub_station(25,'Памир', [Transformer(5600,[35 6],'T-1');Transformer(5600,[35 6],'T-2')],[6 2]);
ps_opt = ps_opt.push_sub_station(26,'Промышленная', [Transformer(25000,[110 35 10],'T-1');Transformer(25000,[110 35 10],'T-2')],[10 30; 35 4]);
ps_opt = ps_opt.push_sub_station(27,'РЭЗ', [Transformer(6300,[35 10],'T-1')],[10 2]);
ps_opt = ps_opt.push_sub_station(28,'Советская', [Transformer(16000,[110 10],'T-1');Transformer(40000,[110 10],'T-2')],[10 23]);
ps_opt = ps_opt.push_sub_station(29,'Спортивная', [Transformer(10000,[35 10],'T-1');Transformer(10000,[35 10],'T-2')],[10 8]);
ps_opt = ps_opt.push_sub_station(30,'Текстильмаш', [Transformer(25000,[110 6],'T-1');Transformer(25000,[110 6],'T-2')],[6 26]);
ps_opt = ps_opt.push_sub_station(31,'Фирдавси', [Transformer(16000,[110 10],'T-1');Transformer(6300,[110 10],'T-2')],[10 5]);
ps_opt = ps_opt.push_sub_station(32,'ХБК', [Transformer(20000,[110 35 10 6],'T-1');Transformer(40000,[110 35 10 6],'T-2')],[6 2; 10 3]);
ps_opt = ps_opt.push_sub_station(33,'Центральная', [Transformer(16000,[35 6],'T-1');Transformer(16000,[35 6],'T-2')],[6 22]);
ps_opt = ps_opt.push_sub_station(34,'Шахри', [Transformer(25000,[35 6],'T-1')],[10 7]);
ps_opt = ps_opt.push_sub_station(35,'Шурсай', [Transformer(10000,[110 10],'T-1')],[6 3]);
ps_opt = ps_opt.push_sub_station(36,'Юго-зап.водоз.', [Transformer(10000,[110 6],'T-1');Transformer(10000,[110 6],'T-2')],[6 3]);



% Зададим матрицу инцидентности оринтированного графа  узлов электросети
% Шаблон: {[начальный узел] [конечный узел 1] [конечный узел 2] ...  }
I = { {1 16 22};              
      {2 10 11 14 17 21 35};
      {3 22 28};
      {4 18 32};
      {5 18};
      {6 34 23 20 26};
      {7 36};
      {8 20 27};
      {9 24};
      {16 15 10};
      {18 32 28 29 33};
      {20 36 25 26 28};
      {26 13 25 27};
      {28 31 19};
      {32 30 12}
      };

% Инициализация данных  
ps_opt = ps_opt.init(I,Hours_count,Potpusk_real,Pless_all_consumers,Transformer_k_max,Transformer_k_opt,Iter_max);

% Корректировка начального решения
ps_opt = ps_opt.set_x0(26,25,0);
ps_opt = ps_opt.set_x0(20,25,1);
ps_opt = ps_opt.set_x0(26,27,0);
ps_opt = ps_opt.set_x0(8,27,1);


% Оптимизация потерь в трансформаторах и полезного отпуска
 [X,f_opt,P_in] = ps_opt.min_opt();

% Формирование отчета
 ps_opt.createReport({'report.xlsx'},ps_opt.x0,'X_start');
 ps_opt.createReport({'report.xlsx'},X,'X_opt');






