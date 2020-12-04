clc
clear all

%数据写入以及获取
data = xlsread('fujian2.xlsx');
citys = data;
citys_difficult = citys(:, 5);
citys_index = citys(:, 1);
citys_num = size(citys, 1);
D = Distance3(citys);
D1 = sort(D(1, :));
v = 100;
%将城市按照距离分成4个区域。
citys1 = citys(0 < D(:, 1) & D(:, 1)<570, :);
citys2 = citys(570 < D(:, 1) & D(:, 1) <828, :);
citys3 = citys(828 < D(:, 1) &D(:, 1)  <1150, :);
citys4 = citys(D(:, 1) >1150, :);

%将每个区域按照难度分成两部分，也就是10个区域。
citys11 = citys1(citys1(:, 5) < 3, :);
citys12 = citys1(citys1(:, 5) > 2, :);
citys21 = citys2(citys2(:, 5) < 3, :);
citys22 = citys2(citys2(:, 5) > 2, :);
citys31 = citys3(citys3(:, 5) < 3, :);
citys32 = citys3(citys3(:, 5) > 2, :);
citys41 = citys4(citys4(:, 5) < 3, :);
citys42 = citys4(citys4(:, 5) > 2, :);


Start = citys11(1, :);
citys11(1, :) = [];
MustPass1 = citys22(11, :);
citys22(11, :) = [];
MustPass2 = citys32(11, :);
citys32(11, :) = [];
Final = citys41(13,:);
citys41(13, :) = [];

%进行重新分配城市点
Tempcitys12 = [citys12; citys11(1 : 2, :)];
citys12 = Tempcitys12;
citys11(1 : 2, :) = [];
Tempcitys22 = [citys22; citys21(18 : 20, :)];
citys22 = Tempcitys22;
citys21(18 : 20, :) = [];
Tempcitys32= [citys32; citys31(11 : 13, :)];
citys32 = Tempcitys32;
citys31(11 : 13, :) = [];
Tempcitys41 = [citys41; citys42(3 : 5, :)];
citys41 = Tempcitys41;
citys42(3 : 5, :) = [];

%进行城市点的选取
SelectTime = 1;
MaxSelectTime = 2000;
ResultRoute = zeros(MaxSelectTime, 20);
ResultTime = zeros(MaxSelectTime, 1);
ResultDifficult = zeros(MaxSelectTime, 1);
ResultLength = zeros(MaxSelectTime, 1);
while SelectTime <= MaxSelectTime
    S = [Start; Final; MustPass1; MustPass2];
    TempCitys = zeros(20, 6);
    TempNum1 = randperm(18);
    TempNum2 = randperm(18);
    TempNum3 = randperm(18);
    TempNum4 = randperm(18);
    TempCitys(1 : 4, 1:5) = S;
    TempCitys(5 : 8,1:5) = [citys11(TempNum1(1 : 2), :); citys12(TempNum1(3 : 4), :)];
    TempCitys(9 : 12, 1:5) = [citys21(TempNum2(1 : 2), :); citys22(TempNum2(3 : 4), :)];
    TempCitys(13 : 16, 1:5) = [citys31(TempNum3(1 : 2), :); citys32(TempNum3(3 : 4), :)];
    TempCitys(17 : 20, 1:5) = [citys41(TempNum4(1 : 2), :); citys42(TempNum4(3 : 4), :)];

    TempCitys(1, 6) = 1;
    TempCitys(2, 6) = 2;
    B = TempCitys(3 : 20, :);
    B1 = sortrows(B, 1);
    B1(:, 6) = 3 : 20;
    TempCitys2 = [TempCitys(1 : 2, :); B1];
    [ResultRoute(SelectTime, :), ResultTime(SelectTime, :), ResultLength(SelectTime, :), ResultDifficult(SelectTime, :)] = Ant3(TempCitys2);
    SelectTime = SelectTime + 1;
end

%数据处理
M = mean(ResultLength);
Result = [ResultTime ResultDifficult ResultLength ResultRoute];
Result1 = Result(Result(:, 2) < 53 & Result(:, 2) > 46 & Result(:, 3) < 10100 & Result(:, 3) > 9800 & Result(:, 1) <= 180, :);
Result1 = sortrows(Result1,1);
ResultRoute1 = Result1(:, 4 : 23);
RowsNum = size(ResultRoute1, 1);
ClumnsNum = size(ResultRoute1, 2);


%创建分钟记录表
MinutesRecord = zeros(RowsNum, ClumnsNum);
for i = 1 : RowsNum
    for j = 1 : (ClumnsNum - 1)
        MinutesRecord(i, j + 1) = floor(MinutesRecord(i, j ) + D(ResultRoute1(i, j), ResultRoute1(i, j + 1)) / v + citys_difficult(ResultRoute1(i, j)));
    end
end
TimeCitys = zeros(180,150);
ResultRoute2 = zeros(RowsNum, ClumnsNum);
S1 = S(:, 1)';
for i = 1 : RowsNum
    for j = 1 : (ClumnsNum - 1)
            if TimeCitys(MinutesRecord(i, j + 1),ResultRoute1(i, j + 1) ) < 5
                TimeCitys(MinutesRecord(i, j + 1),ResultRoute1(i, j + 1) ) = TimeCitys(MinutesRecord(i, j + 1), ResultRoute1(i, j + 1) ) + 1;
            else
                ResultRoute2(i, :)=  ResultRoute1(i, :);
                break
            end
    end
end
ResultRoute3 = ResultRoute1(ResultRoute2(:, 2) ==0, :);
ResultRoute4 = Result1(ResultRoute2(:, 2) ==0, :);

%计算高度
RowsResultRoute3 = size(ResultRoute3, 1);
ClumnsResultRoute3 = size(ResultRoute3, 2);
Height = zeros(RowsResultRoute3, 1);
for i = 1 : RowsResultRoute3
    for j = 1 : (ClumnsResultRoute3 - 1)
        if citys(citys(:, 1)==ResultRoute3(i, j + 1), 4) > citys(citys(:, 1)==ResultRoute3(i, j), 4)
            Height(i) = citys(citys(:, 1)==ResultRoute3(i, j + 1), 4) - citys(citys(:, 1)==ResultRoute3(i, j), 4);
        end
    end
end
ResultRoute5 = ResultRoute3(Height(:, 1) < 8 & Height(:, 1) > 3, :);
ResultRoute6 = ResultRoute4(Height(:, 1) < 8 & Height(:, 1) > 3, :);
RowsResultRoute5 = size(ResultRoute5, 1);
ClumnsResultRoute5 = size(ResultRoute5, 2);
ResultHeight = zeros(RowsResultRoute5, 1);
for i = 1 : RowsResultRoute5
    for j = 1 : (ClumnsResultRoute5 - 1)
        if citys(citys(:, 1)==ResultRoute5(i, j + 1), 4) > citys(citys(:, 1)==ResultRoute5(i, j), 4)
            ResultHeight(i) = citys(citys(:, 1)==ResultRoute5(i, j + 1), 4) - citys(citys(:, 1)==ResultRoute5(i, j), 4);
        end
    end
end
TimeRoute4 = ResultRoute6(:, 1);
People = zeros(size(ResultRoute4, 1), 1);
People = floor((180 - TimeRoute4) ./ 10 + 1);
SumPeople = sum(People);




% % 按难度取点
% data1 = citys(citys(:,5) == 1, :);
% x1 = data1(:, 2);
% y1 = data1(:, 3);
% z1 = data1(:, 4);
% data2 = citys(citys(:,5) == 2, :);
% x2 = data2(:, 2);
% y2 = data2(:, 3);
% z2 = data2(:, 4);
% data3 = citys(citys(:,5) == 3, :);
% x3 = data3(:, 2);
% y3 = data3(:, 3);
% z3=  data3(:, 4);
% data4 = citys(citys(:,5) == 4, :);
% x4 = data4(:, 2);
% y4 = data4(:, 3);
% z4 = data4(:, 4);
% Point4 = [data4(:,1) x4 y4];
% plot3(x1,y1,z1,'*g',x2,y2,z2,'*r',x3,y3,z3,'*b',x4,y4,z4,'*y')
% xlabel('x')
% ylabel('y')
% zlabel('z')
% hold on
