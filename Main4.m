% clc
% clear all

%数据写入以及获取
data = xlsread('fujian3.xlsx','候选检查点');
citys = data;
citys_difficult = citys(:, 5);
citys_index = citys(:, 1);
citys_num = size(citys, 1);
D = Distance3(citys);
D1 = sort(D(1, :));
v = xlsread('fujian3.xlsx','参赛队平均速度','B2 : B121');
V = v .* 1000/60;
vMean = round(mean(V));
%将城市按照距离分成4个区域。
citys1 = citys(0 < D(:, 1) & D(:, 1)<723, :);
citys2 = citys(723 < D(:, 1) & D(:, 1) <1085.7, :);
citys3 = citys(1085.7 < D(:, 1) &D(:, 1)  <1390, :);
citys4 = citys(D(:, 1) >1390, :);

%将每个区域按照难度分成两部分，也就是8个区域。
citys11 = citys1(citys1(:, 5) < 4, :);
citys12 = citys1(citys1(:, 5) > 3, :);
citys21 = citys2(citys2(:, 5) < 4, :);
citys22 = citys2(citys2(:, 5) > 3, :);
citys31 = citys3(citys3(:, 5) < 4, :);
citys32 = citys3(citys3(:, 5) > 3, :);
citys41 = citys4(citys4(:, 5) < 4, :);
citys42 = citys4(citys4(:, 5) > 3, :);


Start = citys11(1, :);
citys11(1, :) = [];
MustPass1 = citys22(8, :);
citys22(8, :) = [];
MustPass2 = citys32(4, :);
citys32(4, :) = [];
Final = citys41(13,:);
citys41(13, :) = [];

%进行重新分配城市点
Tempcitys11 = [citys11; citys12(9 : 11, :); citys12(20 : 21, :); citys12(30 : 32, :)];
citys11 = Tempcitys11;
citys12(30 : 32, :) = [];
citys12(20 : 21, :) = [];
citys12(9 : 11, :) = [];
Tempcitys21 = [citys21; citys22(3 : 5, :); citys22(15 : 16, :); citys22(22 : 24, :)];
citys21 = Tempcitys21;
citys22(22 : 24, :) = [];
citys22(15 : 16, :) = [];
citys22(3 : 5, :) = [];
Tempcitys31 = [citys31; citys32(2 : 9, :); citys32(28, :); citys32(32 : 34, :)];
citys31 = Tempcitys31;
citys32(32 : 34, :) = [];
citys32(28, :) = [];
citys32(2 : 9, :) = [];
Tempcitys41 = [citys41; citys42(3 : 4, :); citys42(1, :); citys42(20 : 21, :)];
citys41 = Tempcitys41;
citys42(20 : 21, :) = [];
citys42(3 : 4, :) = [];
citys42(1, :) = [];



%进行城市点的选取
SelectTime = 1;
MaxSelectTime = 20000;
ResultRoute = zeros(MaxSelectTime, 20);
ResultTime = zeros(MaxSelectTime, 1);
ResultDifficult = zeros(MaxSelectTime, 1);
ResultLength = zeros(MaxSelectTime, 1);
while SelectTime <= MaxSelectTime
    S = [Start; Final; MustPass1; MustPass2];
    TempCitys = zeros(20, 6);
    TempNum1 = randperm(24);
    TempNum2 = randperm(24);
    TempNum3 = randperm(24);
    TempNum4 = randperm(24);
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
    [ResultRoute(SelectTime, :), ResultTime(SelectTime, :), ResultLength(SelectTime, :), ResultDifficult(SelectTime, :)] = Ant4(TempCitys2);
    SelectTime = SelectTime + 1;
end

%数据处理
M = mean(ResultLength);
Result = [ResultTime ResultDifficult ResultLength ResultRoute];
Result1 = Result(Result(:, 2) < 84 & Result(:, 2) > 74 & Result(:, 3) < 11000 & Result(:, 3) > 9000 & Result(:, 1) <= 210, :);
Result1 = sortrows(Result1,1);
ResultRoute1 = Result1(:, 4 : 23);
RowsNum = size(ResultRoute1, 1);
ClumnsNum = size(ResultRoute1, 2);


%创建分钟记录表
MinutesRecord = zeros(RowsNum, ClumnsNum);
for i = 1 : RowsNum
    for j = 1 : (ClumnsNum - 1)
        MinutesRecord(i, j + 1) = floor(MinutesRecord(i, j ) + D(ResultRoute1(i, j), ResultRoute1(i, j + 1)) / vMean + citys_difficult(ResultRoute1(i, j)));
    end
end
TimeCitys = zeros(210,200);
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
ResultRoute5 = ResultRoute3(Height(:, 1) > 6, :);
ResultRoute6 = ResultRoute4(Height(:, 1) > 6, :);
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
People = zeros(size(ResultRoute6, 1), 1);
People = floor((210 - TimeRoute4) ./ 10 + 1);
SumPeople = sum(People);

%进行遗传算法寻优
MaxGen = 100;
pc = 0.6;      %交叉概率
pm = 0.001; %变异概率
w1 = 1;
w2 = 5;
[CanChrom, CanMaxTime, CanRouteNum] = Create(ResultRoute6);
fitvalue = [w1 .* CanMaxTime + w2 .* CanRouteNum CanMaxTime CanRouteNum CanChrom];
Fitvalue = sortrows(fitvalue, 1);
PeopleOrder = Fitvalue(1, 4:123)';
RoutePeople = zeros(41, 120);
for i = 1 : 41
    for j = 1 : 120
        if PeopleOrder(j) == i
            RoutePeople(i, j) = j;
        end
    end
end
for i = 1 : 41
    AA = RoutePeople(i, :);
    AA(find(AA ==0)) =[]
end
NewChrom = selection(CanChrom, fitvalue);
NewChrom = crossover(NewChrom, pc);
