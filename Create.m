function [CanChrom, CanMaxTime, CanRouteNum] = Create(ResultRoute6)
v = xlsread('fujian3.xlsx','参赛队平均速度','B2 : B121');
V = v .* 1000/60;
Length = ResultRoute6(:, 3);
Difficult = ResultRoute6(:, 2);
PeopleAndRoute = zeros(120, 41);
for i = 1 : 120
    for j = 1 : 41
        PeopleAndRoute(i, j) = Length(j) / V(i) + Difficult(j);
    end
end
Chrom = ceil(rand(100000,120) * 41);
RecordI = zeros(100000, 1);
MaxTime = zeros(100000, 1);
RouteNum = zeros(100000, 1);
for i = 1 : 100000
    RouteRecordPeople = zeros(41, 120);
    for j = 1 : 120
            RouteRecordPeople(Chrom(i, j), j) = j;
    end
    SumTempTime = zeros(41,1);
    for k = 1 : 41
        TempRouteRecordPeople = RouteRecordPeople(k, :);
        TempRouteRecordPeople(find(TempRouteRecordPeople ==0)) = [];
        if isempty(TempRouteRecordPeople) == 0
            TempTime = zeros(size(TempRouteRecordPeople));
            for  l = 1 : size(TempRouteRecordPeople, 2)
                TempTime(l) = PeopleAndRoute(TempRouteRecordPeople(l), k);
            end
            PeopleNum = length(TempTime);
            MinTime = min(TempTime);
            SumTempTime(k) = (PeopleNum - 1) * 10 + MinTime;
            
            if  SumTempTime(k) > 210
                RecordI(i, 1) = 1;
                break
            end
        end
    end
    MaxTime(i) = max(SumTempTime);
    RouteNum(i) = length(SumTempTime(SumTempTime(:, 1) ~= 0));
end
CanMaxTime = MaxTime(RecordI(:,1) == 0, :);
CanChrom = Chrom(RecordI(:,1) == 0, :);
CanRouteNum = RouteNum(RecordI(:,1) == 0, :);
