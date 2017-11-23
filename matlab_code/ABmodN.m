M = 2061;
P = 13;
p = de2bi(P);
n = 16403;

tmp = 0;
for j = 0:length(p)-1
    if p(length(p)-j) == 1
        tmp = 2*tmp + M;
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