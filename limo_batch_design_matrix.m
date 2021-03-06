function limo_batch_design_matrix(LIMOfile)
global EEG

load(LIMOfile);
if exist('EEG','var')
    if ~strcmp([LIMO.data.data_dir filesep LIMO.data.data],[EEG.filepath filesep EEG.filename])
        cd (LIMO.data.data_dir);
        disp('reloading data ..');
        EEG=pop_loadset(LIMO.data.data);
    end
else
    disp('reloading data ..');
    EEG=pop_loadset(LIMO.data.data);
end

if strcmp(LIMO.Analysis,'Time')
    Y = EEG.data(:,LIMO.data.trim1:LIMO.data.trim2,:);
    clear EEG
    
elseif strcmp(LIMO.Analysis,'Frequency')
    Y = EEG.etc.limo_psd(:,LIMO.data.trim1:LIMO.data.trim2,:);
    clear EEG
    
elseif strcmp(LIMO.Analysis,'Time-Frequency')
    clear EEG; disp('Time-Frequency implementation - loading tf data...');
    try
        Y = load(LIMO.data.tf_data_filepath);  % Load tf data from path in *.set from import stage
    catch no_file
          error(sprintf('oops look like the time frequency data cannot be located \n edit LIMO.data.tf_data_filepath for %s',LIMO.data.data));
          return
    end
    Y = getfield(Y,cell2mat(fieldnames(Y))); % take the actual data from the structure
    Y = Y(:,LIMO.data.trim_low_f:LIMO.data.trim_high_f,LIMO.data.trim1:LIMO.data.trim2,:); % trim
    LIMO.data.size4D= size(Y);
    LIMO.data.size3D= [LIMO.data.size4D(1) LIMO.data.size4D(2)*LIMO.data.size4D(3) LIMO.data.size4D(4)];
end

clear ALLCOM ALLEEG CURRENTSET CURRENTSTUDY LASTCOM STUDY
cd (LIMO.dir) ; save LIMO LIMO

% make the design matrix
disp('computing design matrix');
if strcmp(LIMO.Analysis,'Time-Frequency') % use limo_design_matrix_tf
    [LIMO.design.X, LIMO.design.nb_conditions, LIMO.design.nb_interactions,...
        LIMO.design.nb_continuous] = limo_design_matrix_tf(Y, LIMO,0);
else  % for time or power use limo_design_matrix
    [LIMO.design.X, LIMO.design.nb_conditions, LIMO.design.nb_interactions,...
        LIMO.design.nb_continuous] = limo_design_matrix(Y, LIMO,0);
end

% update LIMO.mat
LIMO.design.name  = 'batch processing';
LIMO.design.status = 'to do';
save LIMO LIMO; clear Y

end


