% make file that provides anti-depressant medication status for each
% subject

% first step is to pull endorsed UKB-coded medications from tabular data
% awk -F '\t' '{print $1,$8472,$8473,$8474,$8475,$8476,$8477,$8478,$8479,$8480,$8481,$8482,$8483,$8484,$8485,$8486,$8487,$8488,$8489,$8490,$8491,$8492,$8493,$8494,$8495,$8496,$8497,$8498,$8499,$8500,$8501,$8502,$8503,$8504,$8505,$8506,$8507,$8508,$8509,$8510,$8511,$8512,$8513,$8514,$8515,$8516,$8517,$8518,$8519}' ukb44344.txt > Meds_IA.txt

% then go to WHO site for Anatomical Therapeutic Chemical (ATC)
% Classification of antidepressant drugs: https://www.whocc.no/atc_ddd_index/?code=N06A
% (five different subtypes)

% then match anti-depressants to UKB medication codes presented at https://biobank.ctsu.ox.ac.uk/crystal/coding.cgi?id=4&nl=1
% the following array comprises UKB medication codes that match ATC anti-depressants

UKB_ADs = [1140879624; 1140879630; 1140879620; 1140867756; 1140867726; 1140867938; 1140867948; 1140879616; 1140867940; 1140867942; 1140867818; 1140879632; 1141168396; 1140867640; 1140867720; 1140856074; 1140909806; 1140867774; ...
    1140879552; 1140879540; 1140921600; 1140867888; 1140867878; 1140879544; 1141180212; 1140867856; 1140910504; 1140867850; 1140910704; 1140867850; 1140910704; 1140867914; 1140867944; 1140910820; 1140856174; 1140867920; ...
    1140867960; 1140879556; 1140879634; 1140917460; 1140879688; 1141152732; 1141176854; 1140916282; 1141151978; 1141200564; 1140867876; 1140916288; 1201];
UKB_ADs = UKB_ADs';

% open Meds_IA.txt
fileID = fopen('Meds_IA.txt');
MEDcell = textscan(fileID,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f','HeaderLines',1,'Delimiter',' ');
fclose(fileID);
MedMat = cell2mat(MEDcell);

loopdim = length(MedMat);
for i = 1:loopdim;
    MedCovMat(i,1) = MedMat(i,1);
    submeds = MedMat(i,:);
    submeds = submeds(~isnan(submeds));
    inter = intersect(UKB_ADs, submeds);
    if length(inter)>=1
        MedCovMat(i,2) = 1;
    else
        MedCovMat(i,2) = 0;
    end
end

dlmwrite('EID_Med.txt', MedCovMat,'delimiter','\t','precision',10);

    

