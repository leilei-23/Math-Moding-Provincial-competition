clc
clear all

%数据写入以及获取
data = xlsread('fujian1.xlsx');
citys = data;
citys_difficult = citys(:, 4);
citys_index = citys(:, 1);
citys_num = size(citys, 1);
D = Distance2(citys);
D1 = sort(D(1, :));
v = 100;
%将城市按照距离分成5个区域。
citys1 = citys(0 < D(:, 1) & D(:, 1)<650, :);
citys2 = citys(650 < D(:, 1) & D(:, 1) <1060, :);
citys3 = citys(1060 < D(:, 1) &D(:, 1)  <1273, :);
citys4 = citys(D(:, 1) >1273, :);

%将每个区域按照难度分成两部分，也就是10个区域。
citys11 = citys1(citys1(:, 4) < 3, :);
citys12 = citys1(citys1(:, 4) > 2, :);
citys21 = citys2(citys2(:, 4) < 3, :);
citys22 = citys2(citys2(:, 4) > 2, :);
citys31 = citys3(citys3(:, 4) < 3, :);
citys32 = citys3(citys3(:, 4) > 2, :);
citys41 = citys4(citys4(:, 4) < 3, :);
citys42 = citys4(citys4(:, 4) > 2, :);


Start = citys11(1, :);
citys11(1, :) = [];
MustPass1 = citys22(5, :);
citys22(5, :) = [];
MustPass2 = citys32(7, :);
citys32(7, :) = [];
Final = citys41(8,:);
citys41(8, :) = [];

%进行重新分配城市点
Tempcitys11 = [citys11; citys12(1 : 3, :)];
citys11 = Tempcitys11;
citys12(1 : 3, :) = [];
Tempcitys22 = [citys22; citys21(11 : 14, :); citys21(3, :); citys21(7, :)];
citys22 = Tempcitys22;
citys21(11 : 14, :) = [];
citys21(3, :) = [];
citys21(7, :) = [];
Tempcitys31 = [citys31; citys32(1 : 2, :)];
citys31 = Tempcitys31;
citys32(1 : 2, :) = [];
Tempcitys41 = [citys41; citys42(12 : 14, :)];
citys41 = Tempcitys41;
citys42(12 : 14, :) = [];

%进行城市点的选取
SelectTime = 1;
MaxSelectTime = 2000;
ResultRoute = zeros(MaxSelectTime, 20);
ResultTime = zeros(MaxSelectTime, 1);
ResultDifficult = zeros(MaxSelectTime, 1);
ResultLength = zeros(MaxSelectTime, 1);
while SelectTime <= MaxSelectTime
    S = [Start; Final; MustPass1; MustPass2];
    TempCitys = zeros(20, 5);
    TempNum1 = randperm(12);
    TempNum2 = randperm(12);
    TempNum3 = randperm(12);
    TempNum4 = randperm(12);
    TempCitys(1 : 4, 1:4) = S;
    TempCitys(5 : 8,1:4) = [citys11(TempNum1(1 : 2), :); citys12(TempNum1(3 : 4), :)];
    TempCitys(9 : 12, 1:4) = [citys21(TempNum2(1 : 2), :); citys22(TempNum2(3 : 4), :)];
    TempCitys(13 : 16, 1:4) = [citys31(TempNum3(1 : 2), :); citys32(TempNum3(3 : 4), :)];
    TempCitys(17 : 20, 1:4) = [citys41(TempNum4(1 : 2), :); citys42(TempNum4(3 : 4), :)];

    TempCitys(1, 5) = 1;
    TempCitys(2, 5) = 2;
    B = TempCitys(3 : 20, :);
    B1 = sortrows(B, 1);
    B1(:, 5) = 3 : 20;
    TempCitys2 = [TempCitys(1 : 2, :); B1];
    [ResultRoute(SelectTime, :), ResultTime(SelectTime, :), ResultLength(SelectTime, :), ResultDifficult(SelectTime, :)] = Ant(TempCitys2);
    SelectTime = SelectTime + 1;
end

%数据处理
M = mean(ResultLength);
Result = [ResultTime ResultDifficult ResultLength ResultRoute];
Result1 = Result(Result(:, 2) < 53 & Result(:, 2) > 46 & Result(:, 3) < 9700 & Result(:, 3) > 9500 & Result(:, 1) <= 180, :);
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
TimeCitys = zeros(180,100);
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
TimeRoute4 = ResultRoute4(:, 1);
People = zeros(size(ResultRoute4, 1), 1);
People = floor((180 - TimeRoute4) ./ 10 + 1);
SumPeople = sum(People);
            

% 按难度取点
% data1 = citys(citys(:,4) == 1, :);
% x1 = data1(:, 2);
% y1 = data1(:, 3);
% data2 = citys(citys(:,4) == 2, :);
% x2 = data2(:, 2);
% y2 = data2(:, 3);
% data3 = citys(citys(:,4) == 3, :);
% x3 = data3(:, 2);
% y3 = data3(:, 3);
% data4 = citys(citys(:,4) == 4, :);
% x4 = data4(:, 2);
% y4 = data4(:, 3);
% Point4 = [data4(:,1) x4 y4];
% plot(x1,y1,'*g',x2,y2,'*r',x3,y3,'*b',x4,y4,'*y')
% hold on
