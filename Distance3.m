function D = Distance3(citys)
n = size(citys, 1);
D = zeros(n, n);
for i = 1 : n
    for j =(i +1) : n
        D(i, j) = sqrt((citys(i, 2) - citys(j, 2))^2 + (citys(i, 3) - citys(j, 3))^2 + (citys(i, 4) - citys(j, 4))^2);
        D(j, i) = D(i, j);
    end
    D(i, i) = 1e-4;  %对角线的值为0，但是为了防止出现0作为分母，所以设置为一个较小的数。
end
