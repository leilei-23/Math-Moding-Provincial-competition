function newpop = crossover(pop,pc)  %pc是指交叉的概率。pop是指种群。
[px,py] =size(pop);
newpop = ones(size(pop));
%对后8位进行交叉
for i = 1 : 2 : px - 1                   
    if (rand < pc)
        cpoint = round(rand * py);
        newpop(i, :) = [pop(i, 1 : cpoint),pop(i + 1, cpoint + 1 : py)];
        newpop(i + 1,:) = [pop(i + 1, 1 : cpoint),pop(i, cpoint + 1 : py)];
    else
        newpop(i, :) = pop(i,:);
        newpop(i + 1, :) = pop(i + 1, :);
    end
end
