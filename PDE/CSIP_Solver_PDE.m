classdef CSIP_Solver_PDE
    properties
        objective
        constraint_funcs
        constraint_dim
        domain_dim
        domain_bounds
        constraint_bounds
        equal_cons_funcs
        
        
    end
    
    methods
        function obj = CSIP_Solver_PDE(objective, constraint_funcs, domain_dim, constraint_dim, domain_bounds, constraint_bounds,equal_cons_funcs)
            obj.objective = objective;
            obj.constraint_funcs = constraint_funcs;
            obj.constraint_dim = constraint_dim;
            obj.domain_dim = domain_dim;
            obj.domain_bounds = domain_bounds;
            obj.constraint_bounds = constraint_bounds;
            obj.equal_cons_funcs = equal_cons_funcs;
            
            global maxim maxiarray viol counter;
            maxim = -1;
            maxiarray = [];
            counter = 0;
            viol = -1;
            
        end
       
        





        function fval = solve(obj,h,k)

            % insulationFactor = 1; % The higher the insulation factor the slower the temperature cools down. Adjusting this also depends on your initial temperature and reannealing interval 
            % % 
            % % % You need this definitely for the integer optimization
            % initialTemp = 1000; % this will do for the CustomTemperatureFCN
            % % 
            % minTemp = 3; % if you're doing integer optimization you want to at least kep the temperature greater than 2 so that your optimization progresses and potentially go uphill
            % % 
            % % % Solution space quantization. 
            % quantizationFactor = 0.1; 

            % options = optimoptions(@simulannealbnd,'Display','off');
            % options1 = optimoptions('simulannealbnd','FunctionTolerance',1e-6,'StallIterLimit', 50,'AnnealingFcn',{@(x,y)CustomAnnealingFCN(x,y,quantizationFactor)},'TemperatureFcn',{@(x,y) CustomTemperatureFCN(x,y,minTemp,insulationFactor)},...
            % 'InitialTemperature',initialTemp,'display','iter');
            % %lower_bound = zeros(obj.domain_dim*obj.constraint_dim);
            % %disp("hi");
            % %[opt,fval,~] = simulannealbnd(@(u) -1*obj.inner_minimization(x,u_def), randn(obj.domain_dim, 1), ones(obj.domain_dim,1)*(-1), ones(obj.domain_dim,1)*(2),options);
            % newey = repmat(obj.constraint_bounds,obj.domain_dim,1);
            % %disp(newey);
            % lb = newey(:, 1);
            % ub = newey(:, 2);
            % 
            % % Calculate initial guess as the average of lower and upper bounds
            % initialGuess = (lb + ub) / 2;
            % %{@(x,y) CustomTemperatureFCN(x,y,minTemp,insulationFactor)}
            % %initialGuess = ones(obj.domain_dim * obj.constraint_dim, 1) * 0.225;
            % options2 = optimoptions('simulannealbnd','AnnealingFcn', {@(x,y)mhalgo(x,y)});
            % ...
            % ,'TemperatureFcn','temperatureboltz','InitialTemperature',initialTemp);
            % disp(size(initialGuess));
            % disp("Now");
            f_name = "Ex-2";
            [opt,fval] = out_max2(@(u) -1*obj.inner_minimization(u),f_name,obj.domain_dim,obj.constraint_dim,h,k,obj.constraint_bounds);
            %[opt,fval,~,out] = simulannealbnd(@(u) -1*obj.inner_minimization(u), initialGuess, newey(:,1), newey(:,2),options);
            
            %[opt,fval] = ga(@(u) -1*obj.inner_minimization(u), obj.domain_dim*obj.constraint_dim,[],[],[],[],newey(:,1),newey(:,2));
            %options = optimset('Display','off');
            %[opt,fval] = fminsearch(@(u) -1*obj.inner_minimization(u), ones(obj.domain_dim*obj.constraint_dim,1)*(-0.5), options);
            % figure
            % subplot(1,2,1)
            % surf(reshape(Z,numel(xi),[]),'EdgeColor','none')
            % title(['Opt: ','Best Min/Error= ',num2str(fval),', Iteration= ', num2str(out.iterations),', Time= ',num2str(out.totaltime)])
            % axis equal
            disp(opt);
            
            obj.inner_minimization_2(opt);
            
            %obj_opt = obj.objective(x_opt);
        end
        
        function f_val = inner_minimization(obj, constraint_idxs)
           global maxim maxiarray viol counter;
           counter = counter + 1;
           disp(counter);
           %disp(constraint_idxs)
           %disp("Hi")
           %disp(size(constraint_idxs));
           constraint_idxs = reshape(constraint_idxs, obj.domain_dim, obj.constraint_dim);
           %disp(constraint_idxs)
           lb = obj.domain_bounds(:,1);
           ub = obj.domain_bounds(:,2);
           %initial_x = rand(obj.domain_dim,1)*0;
           %initial_x = lb + (ub - lb) .* rand(size(lb));
           %initial_x = (lb+ub)/2;
           initial_x = lb + (ub - lb) .* rand(size(lb));
           %inequality_constraints = [];
           %equality_constraints = [];
           
           mycon_handle = @(x) mycon(x, obj,constraint_idxs);
           
            
            %constraint_values = {inequality_constraints,equality_constraints}
            

           options = optimoptions(@fmincon,'algorithm','sqp','Display','off','TolCon', 1e-6);
           %options = optimoptions('fmincon', 'Algorithm', 'interior-point', 'ScaleProblem', true);
           %options = optimoptions('lsqnonlin');
           %disp(obj.domain_bounds(:,1))
           
           [x,f_val,~,output] = fmincon(obj.objective, initial_x, [],[],[],[],obj.domain_bounds(:,1),obj.domain_bounds(:,2),mycon_handle, options);
           
           %disp(output.constrviolation);
           %[x,f_res,f_val,~] = lsqnonlin(obj.objective, initial_x,obj.domain_bounds(:,1),obj.domain_bounds(:,2), [],[],[],[],mycon_handle, options);
%            for i = 1:length(obj.constraint_funcs)
%                     for j = 1:size(constraint_idxs, 1)
%                       % Append function handles to the list
%                       disp("u-values")
%                       disp(constraint_idxs(j,:));
%                       disp(obj.constraint_funcs{i}(x,constraint_idxs(j,:)));
%                     end
%            end
           
%%%%%%%%%CVX%%%%%%%%%%
            % results = ResultContainer();
            % results.cdash = [];
            % results.ceqdash = [];
            % mycon_handle = @(x) mycon(x, obj,constraint_idxs,results);
            % 
            % cvx_begin quiet
            % variable x(obj.domain_dim)
            % mycon_handle;
            % disp(length(results.cdash));
            % disp(length(results.ceqdash));
            % % Define the objective function
            % minimize(obj.objective(x))
            % 
            % % Define the constraints
            % subject to
            % lb <= x <= ub;
            % 
            % for k = 1:length(results.cdash)
            % 
            %     results.cdash(k) <= 0;
            % end
            % for k = 1:length(results.ceqdash)
            %     results.ceqdash(k) == 0;
            % end
            % cvx_end
            % 
            % f_val = cvx_optval;
            % for j = 1:size(constraint_idxs, 1)
            %     % Append function handles to the list
            %     disp("u-values")
            %     disp(constraint_idxs(j,:));
            % end
            if(output.constrviolation>1e-6)
                f_val = -1e9;
            end
           disp("x-value");
           disp(x);
%            disp(x(19));
%            disp(x(20));
%            disp(x(21));
           %disp("Check");
           %disp(min(2*alpha(1)*x(1)*x(1) + 3*alpha(2)*(x(1)^3) + 1*(2*alpha(1)*x(1) + 3*alpha(2)*x(1)*x(1)) + alpha(2)*sqrt(x(1)^2), 2*alpha(1)*x(1)*x(1) + 3*alpha(2)*(x(1)^3) - 1*(2*alpha(1)*x(1) + 3*alpha(2)*x(1)*x(1)) + alpha(2)*sqrt(x(1)^2)));
           %disp("f-value");
            viol = output.constrviolation;
           disp(f_val);
           % if (maxim<=f_val) && (viol <= 1e-6) 
           %     maxim = f_val;
           %     maxiarray = x;
           %     viol = output.constrviolation;
           % end   
           % disp("Extra");
           % disp(maxim);
           % disp(maxiarray');
           % disp("Maximum Constraint Violation")
           disp(viol);
           disp("End of this iteration");
           
        end

         function f_val = inner_minimization_2(obj, constraint_idxs)
           global maxim maxiarray viol counter;
           % counter = counter + 1;
           % disp(counter);
           % %disp(constraint_idxs)
           % disp("Hi")
           %disp(size(constraint_idxs));
           constraint_idxs = reshape(constraint_idxs, obj.domain_dim, obj.constraint_dim);
           %disp(constraint_idxs)
           lb = obj.domain_bounds(:,1);
           ub = obj.domain_bounds(:,2);
           %initial_x = rand(obj.domain_dim,1)*0;
           %initial_x = lb + (ub - lb) .* rand(size(lb));
           %initial_x = (lb+ub)/2;
           initial_x = lb + (ub - lb) .* rand(size(lb));
           %inequality_constraints = [];
           %equality_constraints = [];
           
           mycon_handle = @(x) mycon(x, obj,constraint_idxs);
           
            
            %constraint_values = {inequality_constraints,equality_constraints}
            

           options = optimoptions(@fmincon,'algorithm','sqp','Display','off','TolCon', 1e-6);
           %options = optimoptions('fmincon', 'Algorithm', 'interior-point', 'ScaleProblem', true);
           %options = optimoptions('lsqnonlin');
           %disp(obj.domain_bounds(:,1))
           
           [x,f_val,~,output] = fmincon(obj.objective, initial_x, [],[],[],[],obj.domain_bounds(:,1),obj.domain_bounds(:,2),mycon_handle, options);
           
           disp(output.constrviolation);
           %[x,f_res,f_val,~] = lsqnonlin(obj.objective, initial_x,obj.domain_bounds(:,1),obj.domain_bounds(:,2), [],[],[],[],mycon_handle, options);
%            for i = 1:length(obj.constraint_funcs)
%                     for j = 1:size(constraint_idxs, 1)
%                       % Append function handles to the list
%                       disp("u-values")
%                       disp(constraint_idxs(j,:));
%                       disp(obj.constraint_funcs{i}(x,constraint_idxs(j,:)));
%                     end
%            end
           
%%%%%%%%%CVX%%%%%%%%%%
            % results = ResultContainer();
            % results.cdash = [];
            % results.ceqdash = [];
            % mycon_handle = @(x) mycon(x, obj,constraint_idxs,results);
            % 
            % cvx_begin quiet
            % variable x(obj.domain_dim)
            % mycon_handle;
            % disp(length(results.cdash));
            % disp(length(results.ceqdash));
            % % Define the objective function
            % minimize(obj.objective(x))
            % 
            % % Define the constraints
            % subject to
            % lb <= x <= ub;
            % 
            % for k = 1:length(results.cdash)
            % 
            %     results.cdash(k) <= 0;
            % end
            % for k = 1:length(results.ceqdash)
            %     results.ceqdash(k) == 0;
            % end
            % cvx_end
            % 
            % f_val = cvx_optval;
            % for j = 1:size(constraint_idxs, 1)
            %     % Append function handles to the list
            %     disp("u-values")
            %     disp(constraint_idxs(j,:));
            % end

           disp("x-value");
           disp(x);
%            disp(x(19));
%            disp(x(20));
%            disp(x(21));
           %disp("Check");
           %disp(min(2*alpha(1)*x(1)*x(1) + 3*alpha(2)*(x(1)^3) + 1*(2*alpha(1)*x(1) + 3*alpha(2)*x(1)*x(1)) + alpha(2)*sqrt(x(1)^2), 2*alpha(1)*x(1)*x(1) + 3*alpha(2)*(x(1)^3) - 1*(2*alpha(1)*x(1) + 3*alpha(2)*x(1)*x(1)) + alpha(2)*sqrt(x(1)^2)));
           %disp("f-value");
           %  disp(maxiarray);
           %  disp(maxim);
           % disp(f_val);
           % if (maxim<=f_val) && (output.constrviolation <= 1e-6) 
           %     maxim = f_val;
           %     maxiarray = x;
           %     viol = output.constrviolation;
           % end   
           % disp("Extra");
           % disp(maxim);
           % disp(maxiarray');
           % disp("Maximum Constraint Violation")
           % disp(viol)
           
        end
        
        %{
function f_val = inner_minimization(obj, constraint_idxs)
            constraint_idxs = reshape(constraint_idxs, obj.domain_dim, obj.constraint_dim);
            initial_x = randn(obj.domain_dim, 1);
    
            % Define the objective function handle
            obj_fun = @(x) obj.objective(x);
    
            % Define the nonlinear constraint function handle
            nonlcon_fun = @(x) mycon(x, obj, constraint_idxs);
    
            % Define lower and upper bounds for variables
            lb = obj.domain_bounds(:, 1);
            ub = obj.domain_bounds(:, 2);
    
            % Perform constrained optimization using ga
            options = optimoptions('ga', 'Display', 'off');
            [x, f_val] = ga(obj_fun, obj.domain_dim, [], [], [], [], lb, ub, nonlcon_fun, options);
    end
    %}


        
        function cx = vari(x)
            N = 40;
            w = x; % Assuming w is a variable representing the angular frequency
            cx = [2*cos((N:-1:0)*w), 1]';
        end

        function c3 = vari2(alpha)
            c3 = alpha(1:end-1)'; % Exclude the last value of alpha and transpose to a column vector
        end
        function [c,ceq] = mycon(x,obj,constraint_idxs)
                c = [];
                ceq = [];
                %c = [x(1)^2 + 2*x(2)^2 - 1]
                %hie = constraint_idxs(:,1);
                %disp(@(x) -obj.constraint_funcs{1}(constraint_idxs(:,1),x))
                %c(1) = -obj.constraint_funcs{1}(constraint_idxs(':',1), x);
                %disp(size(constraint_idxs, 1));
                for i = 1:length(obj.constraint_funcs)
                    for j = 1:size(constraint_idxs, 1)
                      % Append function handles to the list
                      
                      c = [c; obj.constraint_funcs{i}(x,constraint_idxs(j,:))];
                    end
                end
                for i = 1:length(obj.equal_cons_funcs)
                    ceq = [ceq; obj.equal_cons_funcs{i}(x,constraint_idxs(j,:))];
                end
                
        end
    end
end