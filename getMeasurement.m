clc
clear all
close all

tic

Transfection = {'si','control'};%Factor 1
AcidWash     = {'acid','Noacid'};%Factor 2
Primaquine   = {'prima','Noprima'};%Factor 3
PulseChase   = {'0','30'};%Factor 4

FolderName = dir;
isDir =[FolderName.isdir];
FolderName = {FolderName.name};
FolderName = FolderName(isDir);
idxKill = ismember(FolderName,{'.','..'});
FolderName(idxKill) = [];
Integrin = table();
for idxTransfection = 1:length(Transfection)
    for idxAcidWash = 1:length(AcidWash)
        for idxPrimaquine = 1:length(Primaquine)
            for idxPulseChase = 1:length(PulseChase)
                
                FolderName = [Transfection{idxTransfection} ' ' AcidWash{idxAcidWash} ' ' Primaquine{idxPrimaquine} ' ' PulseChase{idxPulseChase}];
                FileNames = dir([FolderName filesep '*.xls']);
                FileNames = {FileNames.name};
                
                if ~isempty(FileNames)
                    
                    INTENSITY = zeros(length(FileNames),1);                    
                    for idxXlsF=1:length(FileNames)
                        [~,~,raw] = xlsread([FolderName filesep FileNames{idxXlsF}]);
                        data = cell2table(raw(3:end,:));
                        data.Properties.VariableNames = raw(2,:);
                        INTENSITY(idxXlsF) = data{ismember(data.Variable,'Intensity Mean')&ismember(data.Channel,'2'),'Mean'};
                    end
                    TRANSFECTION = repmat(Transfection(idxTransfection),[length(FileNames) 1]);
                    ACIDWASH     = repmat(AcidWash(idxAcidWash),[length(FileNames) 1]);
                    PRIMAQUINE   = repmat(Primaquine(idxPrimaquine),[length(FileNames) 1]);
                    PULSECHASE   = repmat(PulseChase(idxPulseChase),[length(FileNames) 1]);
                    Integrin = [Integrin ; table(INTENSITY,TRANSFECTION,ACIDWASH,PRIMAQUINE,PULSECHASE)];                    
                end
            end
        end
    end        
end
toc


% 2-ways ANOVA; Factor 1 is TRANSFECTION, Factor 2 is PRIMAQUINE
[p,tbl,stats,terms] = anovan(Integrin.INTENSITY,{Integrin.TRANSFECTION,Integrin.PRIMAQUINE},'model','interaction','varnames',{'TRANSFECTION','PRIMAQUINE'});
results = multcompare(stats,'Dimension',[1 2]);






% 
% %%
% Integrin = cell(1,length(folder));
% Lbl      = cell(1,length(folder));
% for idxFactor = 1:length(folder)
%     filenames = dir([folder{idxFactor} filesep '*.xls']);
%     filenames = {filenames.name};
%     val = zeros(length(filenames),1);
%     lbl = repmat(folder(idxFactor),[length(filenames) 1]);
%     for idxXlsF=1:length(filenames)
%         [~,~,raw] = xlsread([folder{idxFactor} filesep filenames{idxXlsF}]);
%         data = cell2table(raw(3:end,:));
%         data.Properties.VariableNames = raw(2,:);
%         val(idxXlsF) = data{ismember(data.Variable,'Intensity Mean')&ismember(data.Channel,'2'),'Mean'};
%     end
%     Integrin{idxFactor} = val;
%     Lbl{idxFactor} = lbl;
% end
% toc
% 
% Integrin = cat(1,Integrin{:});
% Condition = cat(1,Lbl{:});
% 
% Measures = table(Integrin,Condition)
% 
% 
% 
% %% 
% figure
% cmap = lines(2);
% boxplot(Integrin,Lbl)
% % hold on
% % for idxFactor = 1:length(folder)
% %     idx = ismember(Lbl,folder{idxFactor});
% %     line(idxFactor*ones(sum(idx),1)+0.2*(rand(sum(idx),1)-0.5),Integrin(idx),'LineStyle','none','Marker','o','MarkerEdgeColor',[0.2 0.2 0.2],'MarkerFaceColor',cmap(idxFactor,:))    
% % end
% % p = ranksum(Integrin(ismember(Lbl,folder{1})) ,Integrin(ismember(Lbl,folder{2})));
% % % [h,p] = ttest(Integrin(ismember(Lbl,folder{1})) ,Integrin(ismember(Lbl,folder{2})));
% % hold off
% % ylabel('Integrin mean fluorescence (-)')
% % title(['p = ' num2str(p)])