function [newpop] = selection(pop, fitvalue)
totalfit = sum(fitvalue);                  %求适应度之和
fitvalue = fitvalue / totalfit;            %单个个体被选择的概率。
fitvalue = cumsum(fitvalue);
newpop = ones(size(pop));
[px, py] = size(pop);                      %要简单进行修改
ms = sort(rand(px,1));
fitin = 1;
newin = 1;
while newin <= px
    if (ms(newin)) < fitvalue(fitin)
        newpop(newin,:) = pop(fitin,:);
        newin = newin +1;
    else
        fitin = fitin + 1;
    end
end
