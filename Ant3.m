function [ResultRoute, ResulrTime, ResultLength, ResultDifficult] = Ant3(citys)
% citys = TempCitys2;         %编写时用于测试的
citys_difficult = citys(:, 5);
citys_index =1 : 20;
citys_num = size(citys, 1);
DD = Distance3(citys);

%初始化参数
v = 100;
MaxGen = 200;                             %最大迭代次数
AntNum = 14;                               %蚂蚁数量
alpha = 1;                                     %信息素因子
beta = 2;                                       %启发函数因子
rho = 0.3;                                        %信息素挥发因子
SumQ = 20;                                          %信息素总量
Gen = 1;                                          %迭代次数开始
Eta = 1./DD ;  %取距离的倒数即启发函数，需要重新进行修改
Pheromone = ones(citys_num, citys_num);                            %开始的信息素量
RouteTable = zeros(AntNum, citys_num);                       %路径记录表
BestRoute = zeros(MaxGen, citys_num);              %各代的最佳路线
MinTime = inf .* ones(MaxGen, 1);       %各代最佳路线的总长度 
BestRouteLength =  zeros(MaxGen, 1);
BestRouteDifficult =  zeros(MaxGen, 1);

%迭代开始
while Gen <= MaxGen
    %固定起点以及终点
    RouteTable(:, 1) = ones(AntNum, 1);
    RouteTable(:, citys_num) = 2* ones(AntNum, 1);   %终点为点131
    
    for i = 1 : AntNum
        for j = 2 : (citys_num - 1)
            %生成禁忌表，找到允许访问的城市
            j_index = [1 : (j - 1) citys_num];
            tabu = RouteTable(i, j_index);
            allow_index = ~ismember(citys_index, tabu);
            Allow = citys_index(allow_index);
            P = Allow;
            %计算这个点到这些允许访问的城市之间的可能性大小
            for k = 1 : size(Allow, 2)
                P(k) = Pheromone(tabu(end), Allow(k))^alpha * Eta(tabu(end), Allow(k))^beta;
            end
            P = P / sum(P);
            %采用轮盘赌法选择下一个城市
            Pc = cumsum(P);
            target_index = find(Pc >= rand);
            target = Allow(target_index(1));
            RouteTable(i, j) = target;
        end
    end
    
    %计算各个蚂蚁的路径距离和路径总难度
    length = zeros(AntNum, 1);
    RouteDifficult = zeros(AntNum, 1);
    for i = 1 : AntNum 
        Route = RouteTable(i, :);
        for j = 1 : (citys_num - 1)
            length(i) = length(i) + DD(Route(j), Route(j + 1));
            RouteDifficult(i) = RouteDifficult(i) + citys_difficult(Route(j));
        end
        RouteDifficult(i) = RouteDifficult(i) + citys_difficult(Route(end));
    end
    
    %计算各个蚂蚁的路径总时间
    RouteTime = zeros(AntNum, 1);
     for i = 1 : AntNum 
         RouteTime(i) = length(i) / v + RouteDifficult(i);
     end
    %计算最短路径距离及平均距离
    if Gen == 1
        [min_time, min_index] = min(RouteTime);
        MinTime(Gen) = min_time;
        BestRoute(Gen, :) = RouteTable(min_index, :);
        BestRoute(Gen, :) = change3(BestRoute(Gen, :), citys);
        BestRouteLength(Gen) = length(min_index);
        BestRouteDifficult(Gen) = RouteDifficult(min_index);
    else
        [min_time, min_index] = min(RouteTime);
        MinTime(Gen) = min(MinTime(Gen - 1), min_time);
        if   MinTime(Gen) == min_time
             BestRoute(Gen, :) = RouteTable(min_index, :);
             BestRoute(Gen, :) = change3(BestRoute(Gen, :), citys);
             BestRouteLength(Gen) = length(min_index);
             BestRouteDifficult(Gen) = RouteDifficult(min_index);
        else
            BestRoute(Gen, :) = BestRoute((Gen - 1), :);
            BestRouteLength(Gen) = BestRouteLength(Gen - 1);
            BestRouteDifficult(Gen) = BestRouteDifficult(Gen - 1);
        end
    end
   
    %还原最初的路线
    
    %更新信息素
    Delta_tau = zeros(citys_num, citys_num);
    for i = 1 : AntNum
        for j = 1 : (citys_num - 1)
            Delta_tau(RouteTable(i,j), RouteTable(i, j + 1)) = Delta_tau(RouteTable(i,j), RouteTable(i, j + 1)) + SumQ / length(i);
        end
    end
    Pheromone = (1 - rho) .* Pheromone + Delta_tau;
     
    %迭代次数加一，清空路径表
    Gen = Gen + 1;
    RouteTable = zeros(AntNum, citys_num);
end
ResultRoute = BestRoute(end, :);
ResulrTime = MinTime(end, :);
ResultLength = BestRouteLength(end, :);
ResultDifficult = BestRouteDifficult(end, :);
