% Load the local cluster profile
c = parcluster('local');

% Set the number of workers to 72
c.NumWorkers = 72;

% Save the updated profile
saveProfile(c);

% Start a parallel pool with 72 workers
parpool('local', 72);

% Verify the number of workers
pool = gcp('nocreate');
disp(pool.NumWorkers);

% Run the reader.m file

