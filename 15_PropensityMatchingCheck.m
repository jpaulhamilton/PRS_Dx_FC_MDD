% for testing quality of propensity matching

% first the females
% read in data from propensity matched groups
for k = 2:15;
    groupArray = ["LowPRS_CTL_fem"; "HighPRS_CTL_fem"; "LowPRS_rMDD_fem"; "HighPRS_rMDD_fem"; "HighPRS_cMDD_fem"];
    loopdim = length(groupArray);
    for i = 1:loopdim
        filename = strjoin([groupArray(i,:) "_matched.txt"],"");
        fileID = fopen(filename);
        temp = textscan(fileID,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %*[^\n]','HeaderLines',1,'Delimiter',' ');
        tempMat= cell2mat(temp);
        % pull out variable for just the group of interest
        subtempMat=tempMat(any(tempMat(:,16)==0,2),:);
        datmat(:,i) = subtempMat(:,k);
    end
    % bring the yoking group in
    subtempMat=tempMat(any(tempMat(:,16)==1,2),:);
    i=i+1;
    datmat(:,i) = subtempMat(:,k);
    
    % get group averages and stdev
    HighPRS_CTL_fem_ave = mean(datmat(:,2),'omitnan');
    temp = datmat(:,2);
    act_length = length(temp(~isnan(temp)));
    HighPRS_CTL_fem_SE = std(datmat(:,2),'omitnan')/sqrt(act_length);

    HighPRS_cMDD_fem_ave = mean(datmat(:,5),'omitnan');
    temp = datmat(:,5);
    act_length = length(temp(~isnan(temp)));
    HighPRS_cMDD_fem_SE = std(datmat(:,5),'omitnan')/sqrt(act_length);

    HighPRS_rMDD_fem_ave = mean(datmat(:,4),'omitnan');
    temp = datmat(:,4);
    act_length = length(temp(~isnan(temp)));
    HighPRS_rMDD_fem_SE = std(datmat(:,4),'omitnan')/sqrt(act_length);

    LowPRS_CTL_fem_ave = mean(datmat(:,1),'omitnan');
    temp = datmat(:,1);
    act_length = length(temp(~isnan(temp)));
    LowPRS_CTL_fem_SE = std(datmat(:,1),'omitnan')/sqrt(act_length);

    LowPRS_cMDD_fem_ave = mean(datmat(:,6),'omitnan');
    temp = datmat(:,6);
    act_length = length(temp(~isnan(temp)));
    LowPRS_cMDD_fem_SE = std(datmat(:,6),'omitnan')/sqrt(act_length);

    LowPRS_rMDD_fem_ave = mean(datmat(:,3),'omitnan');
    temp = datmat(:,3);
    act_length = length(temp(~isnan(temp)));
    LowPRS_rMDD_fem_SE = std(datmat(:,3),'omitnan')/sqrt(act_length);
    
%     % configure for and run ANOVA
%     group_size = length(datmat);
%     DV = [datmat(:,2); datmat(:,5); datmat(:,4); datmat(:,1); datmat(:,6); datmat(:,3)];
%    
%     % make sub-arrays
%     dumvar1 = zeros(group_size,1);
%     dumvar2 = ones(group_size,1);
%     dumvar3 = 2*dumvar2;
%     PRSvec = [dumvar2; dumvar2; dumvar2; dumvar1; dumvar1; dumvar1];
%     DxVec = [dumvar1; dumvar2; dumvar3; dumvar1; dumvar2; dumvar3];
%     format longg
%     p = anovan(DV,{PRSvec DxVec},'model','full','varnames',{'PRS','Dx'})
%     close('all','force')

    % now dudes
    % read in data from propensity matched groups
    % clear some stuff
    clear datmat;
    groupArray = ["LowPRS_CTL_male"; "HighPRS_CTL_male";"LowPRS_rMDD_male"; "HighPRS_rMDD_male"; "HighPRS_cMDD_male"];
    loopdim = length(groupArray);
    for i = 1:loopdim
        filename = strjoin([groupArray(i,:) "_matched.txt"],"");
        fileID = fopen(filename);
        temp = textscan(fileID,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %*[^\n]','HeaderLines',1,'Delimiter',' ');
        tempMat= cell2mat(temp);
        % pull out variable for just the group of interest
        subtempMat=tempMat(any(tempMat(:,16)==0,2),:);
        datmat(:,i) = subtempMat(:,k);
    end
    % bring the yoking group in
    subtempMat=tempMat(any(tempMat(:,16)==1,2),:);
    i=i+1;
    datmat(:,i) = subtempMat(:,k);
    
    % get group averages and stdev

    HighPRS_CTL_male_ave = mean(datmat(:,2),'omitnan');
    temp = datmat(:,2);
    act_length = length(temp(~isnan(temp)));
    HighPRS_CTL_male_SE = std(datmat(:,2),'omitnan')/sqrt(act_length);

    HighPRS_cMDD_male_ave = mean(datmat(:,5),'omitnan');
    temp = datmat(:,5);
    act_length = length(temp(~isnan(temp)));
    HighPRS_cMDD_male_SE = std(datmat(:,5),'omitnan')/sqrt(act_length);

    HighPRS_rMDD_male_ave = mean(datmat(:,4),'omitnan');
    temp = datmat(:,4);
    act_length = length(temp(~isnan(temp)));
    HighPRS_rMDD_male_SE = std(datmat(:,4),'omitnan')/sqrt(act_length);

    LowPRS_CTL_male_ave = mean(datmat(:,1),'omitnan');
    temp = datmat(:,1);
    act_length = length(temp(~isnan(temp)));
    LowPRS_CTL_male_SE = std(datmat(:,1),'omitnan')/sqrt(act_length);

    LowPRS_cMDD_male_ave = mean(datmat(:,6),'omitnan');
    temp = datmat(:,6);
    act_length = length(temp(~isnan(temp)));
    LowPRS_cMDD_male_SE = std(datmat(:,6),'omitnan')/sqrt(act_length);

    LowPRS_rMDD_male_ave = mean(datmat(:,3),'omitnan');
    temp = datmat(:,3);
    act_length = length(temp(~isnan(temp)));
    LowPRS_rMDD_male_SE = std(datmat(:,3),'omitnan')/sqrt(act_length);
    
%     % configure for and run ANOVA
%     group_size = length(datmat);
%     DV = [datmat(:,2); datmat(:,5); datmat(:,4); datmat(:,1); datmat(:,6); datmat(:,3)];
%    
%     % make sub-arrays
%     dumvar1 = zeros(group_size,1);
%     dumvar2 = ones(group_size,1);
%     dumvar3 = 2*dumvar2;
%     PRSvec = [dumvar2; dumvar2; dumvar2; dumvar1; dumvar1; dumvar1];
%     DxVec = [dumvar1; dumvar2; dumvar3; dumvar1; dumvar2; dumvar3];
%     format longg
%     p = anovan(DV,{PRSvec DxVec},'model','full','varnames',{'PRS','Dx'})
%     close('all','force')


% now graph it
figure(1)
groups = {'CTL', 'cMDD', 'rMDD'};
groups = categorical(cellstr(groups.'));
y1 = [LowPRS_CTL_fem_ave LowPRS_cMDD_fem_ave LowPRS_rMDD_fem_ave];
e1 = [LowPRS_CTL_fem_SE LowPRS_cMDD_fem_SE LowPRS_rMDD_fem_SE];
errorbar(groups,y1,e1,'-o','MarkerSize',10, 'LineWidth',1);
hold on
y2 = [HighPRS_CTL_fem_ave HighPRS_cMDD_fem_ave HighPRS_rMDD_fem_ave];
e2 = [HighPRS_CTL_fem_SE HighPRS_cMDD_fem_SE HighPRS_rMDD_fem_SE];
errorbar(groups,y2,e2,'-o','MarkerSize',10, 'LineWidth',1);
legend('Female Low PRS','Female High PRS')
grid

figure(2)
groups = {'CTL', 'cMDD', 'rMDD'};
groups = categorical(cellstr(groups.'));
y1 = [LowPRS_CTL_male_ave LowPRS_cMDD_male_ave LowPRS_rMDD_male_ave];
e1 = [LowPRS_CTL_male_SE LowPRS_cMDD_male_SE LowPRS_rMDD_male_SE];
errorbar(groups,y1,e1,'-o','MarkerSize',10, 'LineWidth',1);
hold on
y2 = [HighPRS_CTL_male_ave HighPRS_cMDD_male_ave HighPRS_rMDD_male_ave];
e2 = [HighPRS_CTL_male_SE HighPRS_cMDD_male_SE HighPRS_rMDD_male_SE];
errorbar(groups,y2,e2,'-o','MarkerSize',10, 'LineWidth',1);
legend('Male Low PRS','Male High PRS')
grid

pause;
close all;
clear datmat;
end
