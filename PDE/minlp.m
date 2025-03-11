function y = minlp(x)
    y = (x(4)-1)^2 + (x(5)-2)^2 + (x(6)-1)^2 - log(x(7)+1) + (x(1)-1)^2 + (x(2)-2)^2 + (x(3)-3)^2 + pen(x);
    y = y(imag(y) == 0);

    disp(y);
end
function y = pen(x)
    res = constraints(x);
    y = res;
    y = y(imag(y) == 0);
end
function y = constraints(x)
    % Inequality constraints
    c(1) = x(4) + x(5) + x(6) + x(1) + x(2) + x(3)-5;  % Example: x(1) <= 2
    c(2) = x(6)^2 + x(1)^2 + x(2)^2 + x(3)^2 - 5.5;  % Example: x(2) >= 3
    c(3) = x(4) + x(1)-1.2;
    c(4) = x(5) + x(2) - 1.8;
    c(5) = x(6) + x(3) - 2.5;
    c(6) = x(7) + x(1) - 1.2;
    c(7) = x(5)^2 + x(2)^2 - 1.64;
    c(8) = x(6)^2 + x(3)^2 - 4.25;
    c(9) = x(5)^2 + x(3)^2 - 4.64;
    c(10) = (x(4))*(x(4)-1)*(x(5))*(x(5)-1)*(x(6))*(x(6)-1)*(x(7))*(x(7)-1);
    if(c(1)>1e-6 || c(2)>1e-6 || c(3)>1e-6 || c(4)>1e-6 || c(5)>1e-6 || c(6)>1e-6 || c(7)>1e-6)
        disp(c(1));
        disp(c(2));
        disp(c(3));
        disp(c(4));
        disp(c(5));
        disp(c(6));
        disp(c(7));
        
    end
    disp(" ");
    y = (max(0,c(1))^2)*1e3 + (max(0,c(2))^2)*1e3 + (max(0,c(3))^2)*1e3 + (max(0,c(4))^2)*1e3 + (max(0,c(5))^2)*1e3 + (max(0,c(6))^2)*1e3 + (max(0,c(7))^2)*1e3 + c(10)*1e3 ;
    y = y(imag(y) == 0);
    % Equality constraints
    ceq(1) = x(1) + x(2) - 5;  % Example: x(1) + x(2) == 5
end
