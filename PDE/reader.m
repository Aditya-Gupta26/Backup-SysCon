% Main script to read input file and run the optimization code for each line of arguments

% Read the input file
inputFileName = 'input4.txt'; % Change this to your input file name
fid = fopen(inputFileName, 'r');
inputData = textscan(fid, '%s %d %f %f %s %f %f %f', 'Delimiter', ';');
fclose(fid);

% Extract data from inputData
functionNames = string(inputData{1});


dimensions = inputData{2};
kValues = inputData{3};
hValues = inputData{4};
domainsCell = inputData{5}; 
iterLim = inputData{6}; 
redFactor = inputData{7}; 
rediterLimit = inputData{8}; % Read domains as cell array of strings

% Convert domains to numeric arrays
domains = cell(size(domainsCell));
for i = 1:length(domainsCell)
    domains{i} = eval(domainsCell{i});        % Evaluate each string to convert to numeric array
end

for i=1:length(functionNames)
    
    
    globopt(functionNames(i),dimensions(i),hValues(i),kValues(i),domains{i},iterLim(i),redFactor(i),rediterLimit(i));
    
end
