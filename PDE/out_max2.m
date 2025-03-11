function [opt,fval]= out_max2(opt_fxn,f_name,dom_dim,n,h,k,dom)
global currentValues bestValues iterationCount css;
tic;
%n=2;
n = double(n);
%dom2 = [-10,10];
%disp(class(dom2));

newey = repmat(dom,dom_dim,1);
%h = 0.2;
%k = 7;

% disp(dom);
% disp(newey);
insulationFactor = 1; % The higher the insulation factor the slower the temperature cools down. Adjusting this also depends on your initial temperature and reannealing interval
%
% % You need this definitely for the integer optimization
initialTemp = 500; % this will do for the CustomTemperatureFCN
%
minTemp = 3; % if you're doing integer optimization you want to at least kep the temperature greater than 2 so that your optimization progresses and potentially go uphill
%
% % Solution space quantization.
p = 10;
f = 2;
q = 15;
quantizationFactor = 0.1;
options = optimoptions('simulannealbnd', 'Display','iter','PlotFcns',{@saplotbestf,@saplottemperature,@saplotf,@saplotstopping});
% options1 = optimoptions('simulannealbnd','PlotFcns',{@saplotbestf,@saplottemperature,@saplotf,@saplotstopping},'AnnealingFcn',{@(x,y)CustomAnnealingFCN(x,y,quantizationFactor)},'TemperatureFcn',{@(x,y) CustomTemperatureFCN(x,y,minTemp,insulationFactor)},...
%     'InitialTemperature',initialTemp,'display','iter');
% options2 = optimoptions('simulannealbnd','PlotFcns',{@saplotbestf,@saplottemperature,@saplotf,@saplotstopping},'AnnealingFcn', {@(x,y)mhalgo(x,y,1)},'InitialTemperature',initialTemp,'TemperatureFcn','temperatureboltz');
% options3 = optimoptions('simulannealbnd','PlotFcns',{@saplotbestf,@saplottemperature,@saplotf,@saplotstopping},'AnnealingFcn', {@(x,y)fakebarker(x,y,3)},'InitialTemperature',initialTemp);
% options4 = optimoptions('simulannealbnd','PlotFcns',{@saplotbestf,@saplottemperature,@saplotf,@saplotstopping},'AnnealingFcn', {@(x,y)walkerslice(x,y,k,h)},'InitialTemperature',initialTemp);
% options5 = optimoptions('simulannealbnd','PlotFcns',{@saplotbestf,@saplottemperature,@saplotf,@saplotstopping},'AnnealingFcn', {@(x,y)ws2(x,y,k,h)},'InitialTemperature',initialTemp);
options6 = optimoptions('simulannealbnd','PlotFcns',{@saplotbestf,@saplottemperature,@saplotf,@saplotstopping},'AnnealingFcn', {@(x,y)ws3(x,y,k,h,p,f,q,false)},'InitialTemperature',initialTemp,'MaxIterations', 5);
options7 = optimoptions('simulannealbnd','AnnealingFcn', {@(x,y)ws3(x,y,k,h,p,f,q,false)},'InitialTemperature',initialTemp,'MaxIterations', 10);
%,'TemperatureFcn','temperatureboltz');
%f_name = "Ackley";

[opt, fval] = globopt2(newey,options6,n,f_name,opt_fxn);
%
% [x, y] = meshgrid(-10:0.1:10, -10:0.1:10);

% % Evaluate the Ackley function at each point on the grid
% z = arrayfun(@(x, y) Ackley([x, y],2), x, y);
%
% % Plot the surface
% figure;
% surf(x, y, z, 'EdgeColor', 'none');
% xlabel('x');
% ylabel('y');
% zlabel('Ackley(x, y)');
% title('Ackley Function');
% colorbar;
% view(135, 45);

elapsed = toc;
fprintf('Elapsed time: %.4f seconds\n', elapsed);

% fig = gcf;
% plotFileName = sprintf('OptimizationPlot_%s.png', datestr(now, 'yyyymmdd_HHMMSS'));
% saveas(fig, plotFileName);
% 
% optFileName = sprintf('OptValues_%s.txt', datestr(now, 'yyyymmdd_HHMMSS'));
% saveOptValues(opt, optFileName);
% 
% % Log results
% logResults(f_name, n, k,h, elapsed, optFileName, fval, plotFileName, dom);
optFileName = sprintf('MSAOptValues_%s.txt', datestr(now, 'yyyymmdd_HHMMSS'));
saveOptValues(opt, optFileName);
[currentPlotFileName, bestPlotFileName, StepSizeFileName, dataFileName] = createAndSavePlots();
ws3([], [], [], [], [], [], [], true);

logResults(f_name, n, k,h, elapsed, optFileName, fval, dom);

    function [opt, fval] = globopt2(newey,options,n,f_name,opt_fxn)
        lb = newey(:, 1);
        ub = newey(:, 2);
        initialGuess = lb + (ub - lb) .* rand(size(lb));
        %initialGuess = ub;
        %disp(n);
        %disp(f_name);
        [opt,fval,~,out] = simulannealbnd(opt_fxn, initialGuess, lb, ub,options);

%         options = optimset('Display','iter'); % Set display option to 'iter' for iteration details (optional)
% [opt, fval, exitflag, output] = fminsearch(opt_fxn, initialGuess, options);
        % if f_name == "Ackley"
        % 
        %     [opt,fval,~,out] = simulannealbnd(@(x) Ackley(x,n), initialGuess, lb, ub,options);
        % elseif f_name =="shekel"
        %     [opt,fval,~,out] = simulannealbnd(@(x) shekel(x,n), initialGuess, lb, ub,options);
        % elseif f_name =="levy"
        %     [opt,fval,~,out] = simulannealbnd(@(x) levy(x,n), initialGuess, lb, ub,options);
        % end
        disp(opt);
        disp(fval);


    end

    function saveOptValues(opt, filename)
        fileID = fopen(filename, 'w');
        fprintf(fileID, '%f\n', opt);
        fclose(fileID);
    end

    function logResults(funcName, dim, kValue, hValue, elapsedTime, optFileName, fval, domain)
        % Create or open the log file
        logFileName = 'OptimizationResultsCLF.xlsx';

        data = table({funcName}, dim, kValue, hValue, elapsedTime, {sprintf('=HYPERLINK("%s", "%s")', optFileName, optFileName)}, fval, {mat2str(domain)}, ...
                     {sprintf('=HYPERLINK("%s", "%s")', currentPlotFileName, currentPlotFileName)}, {sprintf('=HYPERLINK("%s", "%s")', bestPlotFileName, bestPlotFileName)},  {sprintf('=HYPERLINK("%s", "%s")', StepSizeFileName, StepSizeFileName)},{sprintf('=HYPERLINK("%s", "%s")', dataFileName, dataFileName)}, ...
                     'VariableNames', {'Function', 'Dimensions', 'k_value', 'h_value', 'Time_taken', 'Opt_Values', 'fval', 'Domain_used', 'Current_Plot', 'Best_Plot', 'Step_Size','Data_File'});


        if exist(logFileName, 'file')
            existingData = readtable(logFileName);
            data = [existingData; data];
        end

        writetable(data, logFileName);
        % if exist(logFileName, 'file')
        %     [~, ~, raw] = xlsread(logFileName);
        %     lastRow = size(raw, 1);
        % else
        %     lastRow = 0;
        % end
        % 
        % % Write the data to the log file
        % rowNum = lastRow + 1;
        % %data = {funcName, dim, kValue, hValue, elapsedTime, sprintf('=HYPERLINK("%s", "%s")', optFileName, optFileName), fval, sprintf('=HYPERLINK("%s", "%s")', plotFileName, plotFileName), sprintf('%s', mat2str(domain))};
        % data = {funcName, dim, kValue, hValue, elapsedTime, sprintf('=HYPERLINK("%s", "%s")', optFileName, optFileName), fval, sprintf('%s', mat2str(domain)),sprintf('=HYPERLINK("%s", "%s")', currentPlotFileName, currentPlotFileName),sprintf('=HYPERLINK("%s", "%s")', bestPlotFileName, bestPlotFileName),sprintf('=HYPERLINK("%s", "%s")', dataFileName, dataFileName)};
        % if lastRow == 0
        %     % Write the header if the file is new
        %     %header = {'Function', 'Dimensions', 'k-value', 'h-value', 'Time taken', 'Opt-Values', 'fval', 'Plot', 'Domain used'};
        %     header = {'Function', 'Dimensions', 'k-value', 'h-value', 'Time taken', 'Opt-Values', 'fval', 'Domain used','Current Plot','Best Plot','Data File'};
        %     xlswrite(logFileName, [header; data], 'Sheet1', 'A1');
        % else
        %     xlswrite(logFileName, data, 'Sheet1', sprintf('A%d', rowNum));
        % end
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
    currentPlotFileName = sprintf('MSACurrentValuesPlot_%s.png', datestr(now, 'yyyymmdd_HHMMSS'));
    saveas(fig1, currentPlotFileName,'png');
    close(fig1);

    % Plot best values
    fig2 = figure('Visible','off');
    scatter(1:iterationCount, bestValues, 'filled');
    xlabel('Iteration');
    ylabel('Best Value');
    title('Best Value vs Iteration');
    bestPlotFileName = sprintf('MSABestValuesPlot_%s.png', datestr(now, 'yyyymmdd_HHMMSS'));
    saveas(fig2, bestPlotFileName,'png');
    close(fig2);

    fig3 = figure('Visible','off');
    scatter(1:iterationCount, css, 'filled');
    xlabel('Iteration');
    ylabel('Step-Size');
    title('Step-Size vs Iteration');
    StepSizeFileName = sprintf('MSAStepSizePlot_%s.png', datestr(now, 'yyyymmdd_HHMMSS'));
    saveas(fig3, StepSizeFileName,'png');
    close(fig3);

    dataFileName = sprintf('MSAOptimizationData_%s.txt', datestr(now, 'yyyymmdd_HHMMSS'));
    fileID = fopen(dataFileName, 'w');
    fprintf(fileID, 'Iteration;currentValue;bestValue;current-Step-Size\n'); % Header
    for i = 1:iterationCount
        fprintf(fileID, '%d;%.6f;%.6f;%.6f\n', i, currentValues(i), bestValues(i),css(i));
    end
    fclose(fileID);

    end
    

end


