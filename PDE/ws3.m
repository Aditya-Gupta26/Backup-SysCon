function newState = ws3(optimValues, problem,k,h,p,f,q,resetflag)
    persistent bestValue bestIterationCount originalStepSize currentStepSize reducedStepSizeFlag reducedStepSizeIterationCount oldBenchmark;
    global currentValues bestValues iterationCount css;
    if resetflag
        bestValue = [];
        bestIterationCount = [];
        originalStepSize = [];
        currentStepSize = [];
        reducedStepSizeFlag = [];
        reducedStepSizeIterationCount = [];
        oldBenchmark = [];
        currentValues = [];
        bestValues = [];
        iterationCount = 0;
        css=[];
        return;
    end
    
    if isempty(currentValues)
        currentValues = [];
        bestValues = [];
        iterationCount = 0;
        css=[];
    end
    % Extract current state and objective function
    currentState = optimValues.x;
    %disp(currentState');
    currentObjective = optimValues.fval;
    objectiveFunc = problem.objective;

    
    if isempty(bestValue) 
        bestValue = Inf; % Initialize bestValue with a large number
        oldBenchmark = Inf;
        bestIterationCount = 0; % Initialize bestIterationCount
        originalStepSize = h; % Store the original step size
        currentStepSize = h; % Initialize the current step size to the original step size
        reducedStepSizeFlag = false; % Initialize the flag indicating if the step size has been reduced
        reducedStepSizeIterationCount = 0; % Initialize the iteration count since the step size was reduced
        currentValues = []; % Initialize current values log
        bestValues = []; % Initialize best values log
        iterationCount = 0; % Initialize iteration count
        css=[];
    end
    
    iterationCount = iterationCount + 1;
    currentValues = [currentValues; currentObjective];
    bestValues = [bestValues; bestValue];
    css=[css;currentStepSize];
    %disp(currentState);
    % Extract the problem bounds
    lb = problem.lb;
    ub = problem.ub;
    %disp(size(lb));
    % Number of variables
    numVars = length(currentState);
    % disp(numVars);
    % disp("step");
    % Initialize the new state
    %disp(size(currentState));
    newState = currentState;
    stepSize = h*ones(numVars,1);
    %(ub-lb)/100; % Define step size for neighbors
    %stepSize  = 0.2;
    % disp(size(stepSize));
    %disp(stepSize);
    % Determine how many dimensions are on the edge
    
    selectedNeighbour = currentState;
    % Generate all possible neighbors
    %neighbors = repmat(currentState', 2 * numVars, 1);
    
    nos = rand();
    arrays = zeros(2*k-1, numVars);
    stepMatrix = (1:k-1)' .* stepSize';
    % disp(stepMatrix);
    % disp(size(stepMatrix));
    arrays(1:k-1, :) = currentState' - stepMatrix;
    arrays(k+1:end, :) = currentState' + stepMatrix;
    arrays(k, :) = currentState';
    
    %temp = currentState;
    parfor i = 1:numVars
        
        
        
        %array(k,1) = temp(i,1);
        prob = zeros(2*k-1,1);
        array = arrays(:,i);
        check = 0;
        pi_table = ones(2*k-1,1)*(-1);
        pi2 = pi_table;
        for m = 1:2*k-1
            
            [prob(m,1),pi2] = compute_pA(m,k,k,array,i,currentState,lb,ub,objectiveFunc,optimValues,pi_table);
            %prob(m,1) = compute_pA(m,k,k,array,i,temp);
            check = check + prob(m,1);
            if(check>=nos)
                selectedNeighbour(i,1) = array(m,1);
                %temp(i,1) = array(m,1);
                break;
            end
            pi_table = pi2;
        
        end
        % disp("Change"); 
        % disp(prob);
        % disp("dekho");
        % 
        % disp(check);

    end

    newState = selectedNeighbour;
    
     if currentObjective < bestValue
        oldBenchmark = bestValue;
        bestValue = currentObjective;
        bestIterationCount = 0;
        if reducedStepSizeFlag

            reducedStepSizeIterationCount = 0;

        end
     else
        if reducedStepSizeFlag
            reducedStepSizeIterationCount=reducedStepSizeIterationCount+1;
            bestIterationCount=0;
        else
            bestIterationCount = bestIterationCount + 1;
        end
     end
     if bestValue>0
         if bestIterationCount >= p && currentObjective <= 1.1 * bestValue
            currentStepSize = currentStepSize / f;
            reducedStepSizeFlag = true;
            reducedStepSizeIterationCount = 0;
         end
     else
         if bestIterationCount >= p && currentObjective <= 0.9 * bestValue
            currentStepSize = currentStepSize / f;
            reducedStepSizeFlag = true;
            reducedStepSizeIterationCount = 0;
         end
     end

     if reducedStepSizeFlag && reducedStepSizeIterationCount >= q
        if bestValue>0
            if oldBenchmark <= 1.1*bestValue
                currentStepSize = originalStepSize;
                reducedStepSizeFlag = false;
                reducedStepSizeIterationCount = 0;
            else
                oldBenchmark = bestValue;
                currentStepSize = currentStepSize / f;
                reducedStepSizeFlag = true;
                reducedStepSizeIterationCount = 0;
            end
        else
            if oldBenchmark <= 0.9*bestValue
                currentStepSize = originalStepSize;
                reducedStepSizeFlag = false;
                reducedStepSizeIterationCount = 0;
            else
                oldBenchmark = bestValue;
                currentStepSize = currentStepSize / f;
                reducedStepSizeFlag = true;
                reducedStepSizeIterationCount = 0;
            end
        end
    end

     fprintf('Current Step Size: %.4f, Reduced Step Size Iteration Count: %d\n', currentStepSize, reducedStepSizeIterationCount);
     fprintf('Best Value So Far: %.4f, Old Benchmark : %.4f, Current Objective : %.4f, Iterations Since Best: %d\n', bestValue, oldBenchmark,currentObjective, bestIterationCount);
end


function [pA,table] = compute_pA(r, s, k, array,currdim,currentState,lb,ub,objectiveFunc,optimValues,pi_table)
        % Compute the probability pA(r|s) based on the provided formula
        % Inputs:
        %   r, s - states
        %   k - integer parameter
        %   pi - stationary distribution (vector)
        
        function pie = pi(r)
            if pi_table(r) == -1
                proObj = currentState;
                % disp(r);
                % disp("Look");
                proObj(currdim,1) = array(r,1);
                if proObj(currdim,1)<lb(currdim,1) || proObj(currdim,1)>ub(currdim,1)
                    pie = 0;
                    % disp("Yes");
                else
                    prop = objectiveFunc(proObj);
                    %pie = 1/(1 + exp(prop/optimValues.temperature(currdim,1)));
                    pie = exp(-prop/optimValues.temperature(currdim,1));
                end
                pi_table(r) = pie;
            else
                pie = pi_table(r);
            end
            % disp(array(r,1));
            % disp(pie);
        end
        % Calculate the minimum and maximum limits for l
        l_min = max(s, r);
        l_max = min(s + k - 1, r + k - 1);

        % Initialize the sum
        sum_l = 0;

        % Loop over the range of l values
        for l = l_min:l_max
            % Calculate the denominator for the current l
            sum_j = 0;
            for j = max(1, l - k + 1):l
                sum_j = sum_j + pi(j);
            end

            % Add the current term to the total sum
            sum_l = sum_l + 1 / sum_j;
        end
        table = pi_table;
        % Multiply by the stationary probability of r and divide by k
        pA = (pi(r) / k) * sum_l;
    end