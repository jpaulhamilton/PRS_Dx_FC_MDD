% make propensity matched groups

% list compiled by Robin of EIDs of subjects with resting fMRI data 

fileID = fopen('available_DR_subjects.txt');
EID_cell = textscan(fileID,'%f');
fclose(fileID);
EIDmat = cell2mat(EID_cell);

% awk -F '\t' '{print $1,$1188,$1192,$4076,$1172,$1176,$1180,$1184,$1144,$1152}' ukb44344.txt | awk '$2!=""' > Dx_FI.txt
% yoked to first imaging session

fileID = fopen('Dx_FI.txt');
DXcell = textscan(fileID,'%f %f %f %f %f %f %f %f %f %f','HeaderLines',1,'Delimiter',' ');
fclose(fileID);
DXmat = cell2mat(DXcell);

% awk -F '\t' '{print $1,$11773,$11,$732,$1023,$899,$15721,$15723,$15725}' ukb44344.txt | awk '$2!=""' > Covs_FI.txt
% yoked to first imaging session; includes scanner position in x, y, and z

fileID = fopen('Covs_FI.txt');
COVcell = textscan(fileID,'%f %f %f %f %f %f %f %f %f','HeaderLines',1,'Delimiter',' ');
fclose(fileID);
COVmat = cell2mat(COVcell);

% from join_biosig_EID_PRS
fileID = fopen('EID_PRS.txt');
PRScell = textscan(fileID,'%f %f %f %f %f %f','HeaderLines',1,'Delimiter',' ');
fclose(fileID);
PRSmat = cell2mat(PRScell);

% from join_biosig_EID_PCs
fileID = fopen('EID_PCS.txt');
PCScell = textscan(fileID,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','HeaderLines',1,'Delimiter',' ');
fclose(fileID);
PCSmat = cell2mat(PCScell);

% change drinking variable to be continuous
DrinkMat = COVmat(:,5);
DrinkMat(DrinkMat==6)=10;
DrinkMat(DrinkMat==5)=11;
DrinkMat(DrinkMat==4)=12;
DrinkMat(DrinkMat==3)=13;
DrinkMat(DrinkMat==2)=14;
DrinkMat(DrinkMat==1)=15;
DrinkMat=DrinkMat-10;

% change smoking variable to be continuous
SmokeMat = COVmat(:,6);
SmokeMat(SmokeMat==1)=3;
SmokeMat(SmokeMat==0)=1;

% awk -F '\t' '{print $1,$16030,$15687,$15691,$15697,$15695}' ukb44344.txt | awk 'NF>2' > rsfMRI_covs_FI.txt
fileID = fopen('rsfMRI_covs_FI.txt');
MRIcell = textscan(fileID,'%f %f %f %f %f %f','HeaderLines',1,'Delimiter',' ');
fclose(fileID);
MRImat = cell2mat(MRIcell);

% load up matrix with data for parsing into groups and including covariates
% for propensity matching

% this is getting unwieldy so here are notes on what each column in MainMat corresponds to
% 1 = EID; 
% 2 = PGC_UKB_polygenic risk;
% 3 = Seen doctor (GP) for nerves, anxiety, tension or depression
% 4 = Seen a psychiatrist for nerves, anxiety, tension or depression
% 5 = Ever manic/hyper for 2 days
% 6 = Frequency of depressed mood in last 2 weeks
% 7 = Sex
% 8 = Age
% 9 = Drinking
% 10 = Smoking
% 11 = genotyping array
% 12-17 = genetic PCs 1-6
% 18 = Echo time
% 19 = BOLD to T1 Discrepancy
% 20 = Mean head motion
% 21 = ITSNR of artifact cleaned and preprocessed BOLD

loopdim = length(PRSmat);
for i = 1:loopdim;
    DxRow = find(DXmat(:,1)==PRSmat(i,1));
    if length(DxRow)==1
        CovRow = find(COVmat(:,1)==PRSmat(i,1));
        if length(CovRow)==1
            MRIRow = find(MRImat(:,1)==PRSmat(i,1));
            if length(MRIRow)==1
                MainMat(i,:) = [PRSmat(i,1) PRSmat(i,3) DXmat(DxRow,2) DXmat(DxRow,3) DXmat(DxRow,4) DXmat(DxRow,5)...
                    COVmat(CovRow,3) COVmat(CovRow,2) DrinkMat(CovRow,1) SmokeMat(CovRow,1) PCSmat(i,2:8) MRImat(i,2:5)];
            end
        end
    end
end

% take out rows with all zeros
MainMat = MainMat(any(MainMat,2),:);

% compute PRS quantile thresholds
lower_dec = quantile(MainMat(:,2),0.25);
upper_dec = quantile(MainMat(:,2),0.75);

% now assign PRS, diagnostic, and sex groups
loopdim = length(MainMat);
for i = 1:loopdim;
    if MainMat(i,2) >= upper_dec
        PRS_dec = 2;
    elseif MainMat(i,2) <= lower_dec
        PRS_dec = 1;
    else
        PRS_dec = 0;
    end
    
% took out the mania qualifier here given that it was not answered much at
% inital assessment

    DepInd = MainMat(i,3) + MainMat(i,4);
    if (DepInd > 0) && (MainMat(i,6) >= 2)
        hMDD = 2;
        cMDD = 2;
    elseif (DepInd > 0) && (MainMat(i,6) == 1)
        hMDD = 2;
        cMDD = 1;
    elseif (DepInd == 0) && (MainMat(i,6) >= 2)
        hMDD = 1;
        cMDD = 2;
    elseif (DepInd == 0) && (MainMat(i,6) == 1)
        hMDD = 1;
        cMDD = 1;
    else
        hMDD = 0;
        cMDD = 0;
    end
    
    if (MainMat(i,7) == 0)
        sex = 1;
    else
        sex = 2;
    end
    GCtable(i,:) = [PRS_dec hMDD cMDD sex MainMat(i,1) MainMat(i,8:21)];
end

% make group-wise matrices
j=0;
k=0;
l=0;
m=0;
miss=0;
n=0;
o=0;
p=0;
q=0;
r=0;
s=0;
t=0;
u=0;

% iterate through and add covariate values on a group-wise basis
% disregarding subjects with any negative covariate value 
loopdim = length(GCtable);
for i = 1:loopdim;
    ismiss = ismissing(GCtable(i,1:19));
    sumismiss = sum(ismiss);
    if sumismiss > 0
        miss = miss+1;
    elseif (GCtable(i,1) == 1) && (GCtable(i,2) == 1) && (GCtable(i,3) == 1) && (GCtable(i,4) == 1) && (all(GCtable(i,5:8) >= 0))
        j = j+1;
        LowPRS_CTL_fem(j,:) = GCtable(i,5:19);
    elseif (GCtable(i,1) == 2) && (GCtable(i,2) == 1) && (GCtable(i,3) == 1) && (GCtable(i,4) == 1) && (all(GCtable(i,5:8) >= 0))
        k = k+1;
        HighPRS_CTL_fem(k,:) = GCtable(i,5:19);
    elseif (GCtable(i,1) == 1) && (GCtable(i,2) == 1) && (GCtable(i,3) == 1) && (GCtable(i,4) == 2) && (all(GCtable(i,5:8) >= 0))
        l = l+1;
        LowPRS_CTL_male(l,:) = GCtable(i,5:19);
    elseif (GCtable(i,1) == 2) && (GCtable(i,2) == 1) && (GCtable(i,3) == 1) && (GCtable(i,4) == 2) && (all(GCtable(i,5:8) >= 0))
        m = m+1;
        HighPRS_CTL_male(m,:) = GCtable(i,5:19);
    elseif (GCtable(i,1) == 1) && (GCtable(i,2) == 2) && (GCtable(i,3) == 1) && (GCtable(i,4) == 1) && (all(GCtable(i,5:8) >= 0))
        n = n+1;
        LowPRS_rMDD_fem(n,:) = GCtable(i,5:19);
    elseif (GCtable(i,1) == 2) && (GCtable(i,2) == 2) && (GCtable(i,3) == 1) && (GCtable(i,4) == 1) && (all(GCtable(i,5:8) >= 0))
        o = o+1;
        HighPRS_rMDD_fem(o,:) = GCtable(i,5:19);
    elseif (GCtable(i,1) == 1) && (GCtable(i,2) == 2) && (GCtable(i,3) == 1) && (GCtable(i,4) == 2) && (all(GCtable(i,5:8) >= 0))
        p = p+1;
        LowPRS_rMDD_male(p,:) = GCtable(i,5:19);
    elseif (GCtable(i,1) == 2) && (GCtable(i,2) == 2) && (GCtable(i,3) == 1) && (GCtable(i,4) == 2) && (all(GCtable(i,5:8) >= 0))
        q = q+1;
        HighPRS_rMDD_male(q,:) = GCtable(i,5:19);
    elseif (GCtable(i,1) == 1) && (GCtable(i,2) == 2) && (GCtable(i,3) == 2) && (GCtable(i,4) == 1) && (all(GCtable(i,5:8) >= 0))
        r = r+1;
        LowPRS_cMDD_fem(r,:) = GCtable(i,5:19);
    elseif (GCtable(i,1) == 2) && (GCtable(i,2) == 2) && (GCtable(i,3) == 2) && (GCtable(i,4) == 1) && (all(GCtable(i,5:8) >= 0))
        s = s+1;
        HighPRS_cMDD_fem(s,:) = GCtable(i,5:19);
    elseif (GCtable(i,1) == 1) && (GCtable(i,2) == 2) && (GCtable(i,3) == 2) && (GCtable(i,4) == 2) && (all(GCtable(i,5:8) >= 0))
        t = t+1;
        LowPRS_cMDD_male(t,:) = GCtable(i,5:19);
    elseif (GCtable(i,1) == 2) && (GCtable(i,2) == 2) && (GCtable(i,3) == 2) && (GCtable(i,4) == 2) && (all(GCtable(i,5:8) >= 0))
        u = u+1;
        HighPRS_cMDD_male(u,:) = GCtable(i,5:19);
    end
end

% maybe run a quick ANOVA or 17 on the pre-prop-matched data
for v = 2:15
    DV = [HighPRS_CTL_male(:,v); HighPRS_cMDD_male(:,v); HighPRS_rMDD_male(:,v); LowPRS_CTL_male(:,v); LowPRS_cMDD_male(:,v); LowPRS_rMDD_male(:,v)];
    PRSvec = [zeros(length(HighPRS_CTL_male),1); zeros(length(HighPRS_cMDD_male),1); zeros(length(HighPRS_rMDD_male),1); ones(length(LowPRS_CTL_male),1); ones(length(LowPRS_cMDD_male),1); ones(length(LowPRS_rMDD_male),1)];
    HighPRS_rMDD_vec = zeros(length(HighPRS_rMDD_male),1) + 2;
    LowPRS_rMDD_vec = zeros(length(LowPRS_rMDD_male),1) + 2;
    DxVec = [zeros(length(HighPRS_CTL_male),1); ones(length(HighPRS_cMDD_male),1); HighPRS_rMDD_vec; zeros(length(LowPRS_CTL_male),1); ones(length(LowPRS_cMDD_male),1); LowPRS_rMDD_vec];
    format longg
    prob = anovan(DV,{PRSvec DxVec},'model','full','varnames',{'PRS','Dx'})
    
    pause
    close('all','force')
end

% % now loop through all the groups and use propensity matching to yoke all
% % the groups in terms of control covariates to a given sub-group
% 
% % make the yoke-group matrix
% yokegroup = ["LowPRS_cMDD_male"];
% yokeveclength = length(eval(yokegroup));
% yokevec = ones(yokeveclength,1);
% outmat_yokegroup = [eval(yokegroup(1,:)) yokevec];
% 
% groupArray = ["LowPRS_CTL_male"; "HighPRS_CTL_male"; "LowPRS_rMDD_male"; "HighPRS_rMDD_male"; "HighPRS_cMDD_male"];
% 
% loopdim = length(groupArray);
% for i = 1:loopdim;
%     matchveclength = length(eval(groupArray(i,:)));
%     matchvec = zeros(matchveclength,1);
%     outmat_matchgroup = [eval(groupArray(i,:)) matchvec];
%     outmat = [outmat_yokegroup; outmat_matchgroup];
%     infilename = strjoin([groupArray(i,:) "_forPM.csv"],"");
%     outfilename = strjoin([groupArray(i,:) "_matched.txt"],"");
%     T = array2table(outmat);
%     T.Properties.VariableNames(1:16) = {'EID','age','drinking','smoking','array','PC1','PC2','PC3','PC4','PC5','PC6','TE','BOLD_2_T1','motion','ITSNR','yoke_group'};
%     writetable(T, infilename);
%     
%     %write the R script
%     R_line_1 = {'#! /usr/bin/Rscript'};
%     R_line_2 = {'library(MatchIt)'};
%     R_line_3 = {'library(dplyr)'};
%     R_line_4 = strjoin(['yokedata <- read.csv("' infilename '")'],"");
%     R_line_4 = cellstr(R_line_4);
%     R_line_5 = {'m_ps <- glm(yoke_group ~ age + drinking + smoking + array + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + TE + BOLD_2_T1 + motion + ITSNR,'};
%     R_line_6 = {'family = binomial(), data = yokedata)'};
%     R_line_7 = {'prs_df <- data.frame(pr_score = predict(m_ps, type = "response"),'};
%     R_line_8 = {'yoke_group = m_ps$model$yoke_group)'};
%     R_line_9 = {'mod_match <- matchit(yoke_group ~ age + drinking + smoking + array + PC1 + PC2 + PC3 + PC4 + PC5 + PC6 + TE + BOLD_2_T1 + motion + ITSNR,'};
%     R_line_10 = {'method = "nearest", data = yokedata)'};
%     R_line_11 = {'dta_m <- match.data(mod_match)'};
%     R_line_12 = strjoin(['write.table(dta_m, "' outfilename '", append = FALSE, sep = " ", dec = ".",'],"");
%     R_line_12 = cellstr(R_line_12);
%     R_line_13 = {'row.names = FALSE, col.names = TRUE)'};
%     R_lines = {R_line_1; R_line_2; R_line_3; R_line_4; R_line_5; R_line_6; R_line_7; R_line_8; R_line_9; R_line_10; R_line_11; R_line_12; R_line_13};
%     R_lines = vertcat(R_lines{:});
%     R_lines = string(R_lines);
%     filename = 'PropMatchMatlab.R';
%     fid = fopen(filename,'w');
%     fprintf(fid,'%s\n', R_lines);
%     
%     %execute the R script
%     command = 'chmod u+x /Users/pauha77/UKBB_projects/PolyGenetics/Imaging/IntrinsicFunConn/PropMatchMatlab.R';
%     [status, cmdout] = system(command);
% 
%     command = '/usr/local/bin/Rscript /Users/pauha77/UKBB_projects/PolyGenetics/Imaging/IntrinsicFunConn/PropMatchMatlab.R';
%     [status, cmdout] = system(command);
% end
