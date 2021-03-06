function sigcluster = limo_ecluster_test(orif,orip,th,alpha_value)
% function sigcluster = limo_ecluster_test(orif,orip,th,alpha_value)
%
% ECLUSTER_TEST computes sums of temporal clusters of significant F values and 
% compares them to a threshold obtained from ECLUSTER_MAKE.
% The function operates along the last dimension.
% For each electrode:
%       significant F values are clustered in time;
%       the sum of F values inside each cluster is computed;
%       this sum is compared to the threshold sum stored in TH.
% NOTE: for a two-tailed bootstrap t-test, enter a squared matrix of T values:
% th = ecluster_test(boott.^2,bootp,th,alpha_value)
%
% INPUTS:
%           ORIF = 2D or 1D matrix of F values with format electrode x
%               frames or 1 x frames;
%           ORIP = matrix of p values associated with orif, with same
%               format;
%           TH = output from ECLUSTER_MAKE
%           alpha_value = type I error rate, default 0.05
%
% OUTPUTS:
%           SIGCLUSTER.ELEC = significant [0/1] data points at each
%               electrode, based on a cluster threshold defined
%               independently at each electrode;
%           SIGCLUSTER.MAX = significant [0/1] data points at each
%               electrode, based on a cluster threshold defined by 
%               taking the max cluster across electrodes; this is a
%               more conservative way to control for multiple comparisons 
%               than using a spatial-temporal clustering technique.
%
% v1 Guillaume Rousselet, University of Glasgow, August 2010
% edit Marianne Latinus adding spm_bwlabel
% v2 Edited for return p values
% -----------------------------
%  Copyright (C) LIMO Team 2010
%
% See also ECLUSTER_MAKE

if nargin < 3
    alpha_value = 0.05;
end

if isfield(th, 'max') % Ne x Nf **************************

    Ne = size(orif,1);
    Nf = size(orif,2);
    sigcluster.elec_mask = zeros(Ne,Nf);
    sigcluster.elec_pvalues = zeros(Ne,Nf);
    sigcluster.max_mask = zeros(Ne,Nf);
    sigcluster.max_pvalues = zeros(Ne,Nf);
    ME = [];
    
    for E = 1:Ne % for each electrode
        try
            [L,NUM] = bwlabeln(orip(E,:)<=alpha_value); % find clusters 
        catch ME
            try
                [L,NUM] = spm_bwlabel(double(orip(E,:)<=alpha_value), 6);
            catch ME
                errordlg('You need either the Image Processing Toolbox or SPM in your path'); return
            end
        end
        
        for C = 1:NUM % for each cluster compute cluster sums & compare to bootstrap threshold
            % for the all space
            if sum(abs(orif(E,L==C))) >= th.max;
                sigcluster.max(E,L==C)=1; % flag clusters above threshold
            end
            % for that electrode
            if sum(abs(orif(E,L==C))) >= th.elec(E);
                sigcluster.elec(E,L==C)=1; % flag clusters above threshold
            end
        end
    end 
    
else % Nf only, no electrode dimension **************************

    Nf = length(orif);
    sigcluster.elec = zeros(1,Nf);
    ME = [];
    try
        [L,NUM] = bwlabeln(orip<=alpha_value); % find clusters
    catch ME
        try
            [L,NUM] = spm_bwlabel(double(orip<=alpha_value), 6);
        catch ME
            errordlg('You need either the Image Processing Toolbox or SPM in your path'); return
        end
    end

    for C = 1:NUM % compute cluster sums & compare to bootstrap threshold
        if sum(abs(orif(L==C))) >= th.elec;
            sigcluster.elec(L==C)=1; % flag clusters above threshold
        end
    end
end




