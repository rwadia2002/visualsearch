function mahaladst = mahalsearch(F1,F2,matrix)
%MAHALSEARCH Summary of this function goes here
%   Detailed explanation goes here
mahalfunc1=sqrt(mahal(matrix(F1,:),matrix));
mahalfunc2=sqrt(mahal(matrix(F2,:),matrix));
mahaladst =sqrt(( mahalfunc1 - mahalfunc2)^2);
end

