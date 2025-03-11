function globopt(f_name,n,h,k,dom,p,f,q)
global currentValues bestValues iterationCount css;

tic;

n = double(n);


newey = repmat(dom,n,1);

insulationFactor = 1; % The higher the insulation factor the slower the temperature cools down. Adjusting this also depends on your initial temperature and reannealing interval
%
% % You need this definitely for the integer optimization
initialTemp = 500; 
%
minTemp = 3; % if you're doing integer optimization you want to at least kep the temperature greater than 2 so that your optimization progresses and potentially go uphill
%
% % Solution space quantization.
quantizationFactor = 0.1;
options = optimoptions('simulannealbnd', 'PlotFcns',{@saplotbestf,@saplottemperature,@saplotf,@saplotstopping},'MaxIterations', 10000);
options6 = optimoptions('simulannealbnd','PlotFcns',{@saplotbestf,@saplottemperature,@saplotf,@saplotstopping},'AnnealingFcn', {@(x,y)ws3(x,y,k,h,p,f,q,false)},'MaxIterations', 10,'InitialTemperature',initialTemp);
options7 = optimoptions('simulannealbnd','AnnealingFcn', {@(x,y)ws3(x,y,k,h,p,f,q)},'MaxIterations', 10,'InitialTemperature',initialTemp);

[opt, fval] = globopt2(newey,options6,n,f_name);


elapsed = toc;
fprintf('Elapsed time: %.4f seconds\n', elapsed);


optFileName = sprintf('OptValues_%s.txt', datestr(now, 'yyyymmdd_HHMMSS'));
saveOptValues(opt, optFileName);


[currentPlotFileName, bestPlotFileName, StepSizeFileName, dataFileName] = createAndSavePlots();
%createAndSavePlots();
ws3([], [], [], [], [], [], [], true);



logResults(f_name, n, k,h, elapsed, optFileName, fval, dom);

    function [opt, fval] = globopt2(newey,options,n,f_name)
        lb = newey(:, 1);
        ub = newey(:, 2);
        initialGuess = lb + (ub - lb) .* rand(size(lb));
        
        if f_name == "Ackley"
            
            [opt,fval,~,out] = simulannealbnd(@(x) Ackley(x,n), initialGuess, lb, ub,options);
        elseif f_name =="shekel"
            [opt,fval,~,out] = simulannealbnd(@(x) shekel(x,n), initialGuess, lb, ub,options);
        elseif f_name =="levy"
            [opt,fval,~,out] = simulannealbnd(@(x) levy(x,n), initialGuess, lb, ub,options);
        elseif f_name =="minlp"
            [opt,fval,~,out] = simulannealbnd(@(x) minlp(x), initialGuess, lb, ub,options);
        elseif f_name =="rosen"
            [opt,fval,~,out] = simulannealbnd(@(x) Rosenb(x), initialGuess, lb, ub,options);
        
        end
        % disp(opt);
        % disp(fval);


    end

    function saveOptValues(opt, filename)
        fileID = fopen(filename, 'w');
        fprintf(fileID, '%f\n', opt);
        fclose(fileID);
    end

    function logResults(funcName, dim, kValue, hValue, elapsedTime, optFileName, fval, domain)
        % Create or open the log file
        logFileName = 'OptimizationResultsVanilla.xlsx';

        data = table({funcName}, dim, kValue, hValue, elapsedTime, {sprintf('=HYPERLINK("%s", "%s")', optFileName, optFileName)}, fval, {mat2str(domain)}, ...
                     {sprintf('=HYPERLINK("%s", "%s")', currentPlotFileName, currentPlotFileName)}, {sprintf('=HYPERLINK("%s", "%s")', bestPlotFileName, bestPlotFileName)},  {sprintf('=HYPERLINK("%s", "%s")', StepSizeFileName, StepSizeFileName)},{sprintf('=HYPERLINK("%s", "%s")', dataFileName, dataFileName)}, ...
                     'VariableNames', {'Function', 'Dimensions', 'k_value', 'h_value', 'Time_taken', 'Opt_Values', 'fval', 'Domain_used', 'Current_Plot', 'Best_Plot', 'Step_Size','Data_File'});


        if exist(logFileName, 'file')
            existingData = readtable(logFileName);
            data = [existingData; data];
        end

        writetable(data, logFileName);
        
    end

    function [currentPlotFileName, bestPlotFileName, StepSizeFileName, dataFileName] = createAndSavePlots()
        % Retrieve logged values from ws3
        
        
        % Plot current iteration values
         % Plot current iteration values
    
    fig1 = figure('Visible','off');
    scatter(1:iterationCount, currentValues, 'filled');
    xlabel('Iteration');
    ylabel('Current Value');
    title('Current Value vs Iteration');
    currentPlotFileName = sprintf('CurrentValuesPlot_%s.png', datestr(now, 'yyyymmdd_HHMMSS'));
    saveas(fig1, currentPlotFileName,'png');
    close(fig1);

    % Plot best values
    fig2 = figure('Visible','off');
    scatter(1:iterationCount, bestValues, 'filled');
    xlabel('Iteration');
    ylabel('Best Value');
    title('Best Value vs Iteration');
    bestPlotFileName = sprintf('BestValuesPlot_%s.png', datestr(now, 'yyyymmdd_HHMMSS'));
    saveas(fig2, bestPlotFileName,'png');
    close(fig2);

    fig3 = figure('Visible','off');
    scatter(1:iterationCount, css, 'filled');
    xlabel('Iteration');
    ylabel('Step-Size');
    title('Step-Size vs Iteration');
    StepSizeFileName = sprintf('StepSizePlot_%s.png', datestr(now, 'yyyymmdd_HHMMSS'));
    saveas(fig3, StepSizeFileName,'png');
    close(fig3);

    dataFileName = sprintf('OptimizationData_%s.txt', datestr(now, 'yyyymmdd_HHMMSS'));
    fileID = fopen(dataFileName, 'w');
    fprintf(fileID, 'Iteration;currentValue;bestValue;current-Step-Size\n'); % Header
    for i = 1:iterationCount
        fprintf(fileID, '%d;%.6f;%.6f;%.6f\n', i, currentValues(i), bestValues(i),css(i));
    end
    fclose(fileID);

    end


end


