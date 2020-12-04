unction C = change(A, B)
TempRoute1 = A';
TempRoute2 = TempRoute1;
for i = 1 : 20
         for j = 1 : 20
            if TempRoute1(i, 1) == B(j, 5)
                TempRoute2(i,1) = B(j, 1);
                break
            end
         end
end
C = TempRoute2';
