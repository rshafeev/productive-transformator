            

close all
clear all

% �������� ��������� �������
Hours_count = 6000;               % ����� ������ �������������� � ����(���)
Potpusk_real = 1384000000;        % ����� �������� ������ � ���, ��*�
Pless_all_consumers = 306800000;  % ����� ����������� ������, ��*�
Transformer_k_max = 1.4;          % ������������ ����-� �������� ��������������
Transformer_k_opt = 0.8;          % ����������� ����-� �������� ��������������
Iter_max = 3;                     % ������������ ���-�� ��������

% ������� ������ ������ PSNetworkOptimization, ������� ��������� ���������
% ����������� ������ � ��������������� � ��������� �������� ������
ps_opt = PSNetworkOptimization();

% ������� ������ � �����������, ������� �� ����� ������ � ���������������
% ������� ���������:
% �������� 1 - ���������� ������ ����������
% �������� 2 - �������� ����������
ps_opt = ps_opt.push_station(1,'���������������');
ps_opt = ps_opt.push_station(2,'��������');
ps_opt = ps_opt.push_station(3,'�������');
ps_opt = ps_opt.push_station(4,'��� ����');
ps_opt = ps_opt.push_station(5,'��� 2');
ps_opt = ps_opt.push_station(6,'�����');
ps_opt = ps_opt.push_station(7,'�����');
ps_opt = ps_opt.push_station(8,'������');
ps_opt = ps_opt.push_station(9,'���. ���');

% ������� ������ � ����������� � ���������� ������� � ���������������
% ������� ���������:
% �������� 1 - ���������� ������ ����������
% �������� 2 - �������� ����������
% �������� 3 - ������ ��������������� [�������������1(��������,[����������], ��������); �������������2(��������,[����������], ��������); ... ]
% �������� 4 - ����������� [n1<���-�� ������������>, U1<����������>;n2<���-�� ������������>, U2<����������>; ...]
ps_opt = ps_opt.push_sub_station(10,'�������������', [Transformer(16000,[110 35 10],'T-1') ; Transformer(16000,[110 35 10],'T-2')],[35 1; 10 12]);
ps_opt = ps_opt.push_sub_station(11,'�����', [Transformer(16000,[110 6],'T-1')],[6 4]);
ps_opt = ps_opt.push_sub_station(12,'�������', [Transformer(10000,[110 35 6],'T-1')],[6 5]);
ps_opt = ps_opt.push_sub_station(13,'�����', [Transformer(16000,[110 10],'T-1');Transformer(16000,[110 10],'T-2')],[10 14]);
ps_opt = ps_opt.push_sub_station(14,'������', [Transformer(16000,[110 6],'T-1')],[6 13]);
ps_opt = ps_opt.push_sub_station(15,'������������', [Transformer(10000,[35 6],'T-1');Transformer(10000,[35 6],'T-2')],[6 13]);
ps_opt = ps_opt.push_sub_station(16,'���������', [Transformer(25000,[110 35 6],'T-1');Transformer(25000,[110 35 6],'T-2')],[6 11]);
ps_opt = ps_opt.push_sub_station(17,'������������', [Transformer(10000,[35 6],'T-1')],[6 5]);
ps_opt = ps_opt.push_sub_station(18,'�������', [Transformer(40000,[110 35 6],'T-1');Transformer(25000,[110 35 6],'T-2')],[6 15]);
ps_opt = ps_opt.push_sub_station(19,'�������', [Transformer(16000,[110 35 10],'T-1');Transformer(20000,[110 35 10],'T-2')],[10 8]);
ps_opt = ps_opt.push_sub_station(20,'���������', [Transformer(25000,[110 35 10],'T-1');Transformer(25000,[110 35 10],'T-2')],[]);
ps_opt = ps_opt.push_sub_station(21,'��������', [Transformer(10000,[35 6],'T-1')],[6 4]);
ps_opt = ps_opt.push_sub_station(22,'������.���������', [Transformer(16000,[110 35 6],'T-1');Transformer(16000,[110 35 6],'T-2')],[35 3; 6 8]);
ps_opt = ps_opt.push_sub_station(23,'�����', [Transformer(16000,[110 10],'T-1');Transformer(16000,[110 10],'T-2')],[10 12]);
ps_opt = ps_opt.push_sub_station(24,'�������. ����������', [Transformer(10000,[35 6],'T-1');Transformer(10000,[35 6],'T-2')],[6 11]);
ps_opt = ps_opt.push_sub_station(25,'�����', [Transformer(5600,[35 6],'T-1');Transformer(5600,[35 6],'T-2')],[6 2]);
ps_opt = ps_opt.push_sub_station(26,'������������', [Transformer(25000,[110 35 10],'T-1');Transformer(25000,[110 35 10],'T-2')],[10 30; 35 4]);
ps_opt = ps_opt.push_sub_station(27,'���', [Transformer(6300,[35 10],'T-1')],[10 2]);
ps_opt = ps_opt.push_sub_station(28,'���������', [Transformer(16000,[110 10],'T-1');Transformer(40000,[110 10],'T-2')],[10 23]);
ps_opt = ps_opt.push_sub_station(29,'����������', [Transformer(10000,[35 10],'T-1');Transformer(10000,[35 10],'T-2')],[10 8]);
ps_opt = ps_opt.push_sub_station(30,'�����������', [Transformer(25000,[110 6],'T-1');Transformer(25000,[110 6],'T-2')],[6 26]);
ps_opt = ps_opt.push_sub_station(31,'��������', [Transformer(16000,[110 10],'T-1');Transformer(6300,[110 10],'T-2')],[10 5]);
ps_opt = ps_opt.push_sub_station(32,'���', [Transformer(20000,[110 35 10 6],'T-1');Transformer(40000,[110 35 10 6],'T-2')],[6 2; 10 3]);
ps_opt = ps_opt.push_sub_station(33,'�����������', [Transformer(16000,[35 6],'T-1');Transformer(16000,[35 6],'T-2')],[6 22]);
ps_opt = ps_opt.push_sub_station(34,'�����', [Transformer(25000,[35 6],'T-1')],[10 7]);
ps_opt = ps_opt.push_sub_station(35,'������', [Transformer(10000,[110 10],'T-1')],[6 3]);
ps_opt = ps_opt.push_sub_station(36,'���-���.�����.', [Transformer(10000,[110 6],'T-1');Transformer(10000,[110 6],'T-2')],[6 3]);



% ������� ������� ������������� ��������������� �����  ����� �����������
% ������: {[��������� ����] [�������� ���� 1] [�������� ���� 2] ...  }
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

% ������������� ������  
ps_opt = ps_opt.init(I,Hours_count,Potpusk_real,Pless_all_consumers,Transformer_k_max,Transformer_k_opt,Iter_max);

% ������������� ���������� �������
ps_opt = ps_opt.set_x0(26,25,0);
ps_opt = ps_opt.set_x0(20,25,1);
ps_opt = ps_opt.set_x0(26,27,0);
ps_opt = ps_opt.set_x0(8,27,1);


% ����������� ������ � ��������������� � ��������� �������
 [X,f_opt,P_in] = ps_opt.min_opt();

% ������������ ������
 ps_opt.createReport({'report.xlsx'},ps_opt.x0,'X_start');
 ps_opt.createReport({'report.xlsx'},X,'X_opt');






