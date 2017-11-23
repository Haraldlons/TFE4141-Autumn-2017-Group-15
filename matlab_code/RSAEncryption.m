M = 157139229090403119999531685279699344660;
P = M;
C = 1;
e = 172287003218737821789203137825200603137;
n = 172289632109778146794629697239730443773;

e = de2bi(e);

for i = 1:length(e)
    p = de2bi(P);
    if i == 1
        %P = mod(P*1, n);
        tmp = 0;
        for j = 0:length(p)-1
            if p(length(p)-j) == 1
                tmp = 2*tmp + 1;
            else
                tmp = 2*tmp;
            end
            if tmp >= n
                tmp = tmp - n;
            end
            if tmp >= n
                tmp = tmp - n;
            end
        end
        P = tmp;
    else
        %P = mod(P * P, n);
        tmp = 0;
        for j = 0:length(p)-1
            if p(length(p)-j) == 1
                tmp = 2*tmp + P;
            else
                tmp = 2*tmp;
            end
            if tmp >= n
                tmp = tmp - n;
            end
            if tmp >= n
                tmp = tmp - n;
            end
        end
        P = tmp;
    end
    
    p = de2bi(P);
    if e(i) == 1
        %C = mod(C * P, n);
        tmp = 0;
        for k = 0:length(p)-1
            if p(length(p)-k) == 1
                tmp = 2*tmp + C;
            else
                tmp = 2*tmp;
            end
            if tmp >= n
                tmp = tmp - n;
            end
            if tmp >= n
                tmp = tmp - n;
            end
        end
        C = tmp;
    end
end
disp(C);
