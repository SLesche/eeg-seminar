% Aufgaben:
% Aufgabe 1: Beschreibung eines trial-Ablaufs
        % Ein Fixationskreuz wird präsentiert, (S31/S32)
        % dann beginnt das ISI, (S41/42)
        % dann wird der Zielreiz präsentiert, (S51/52)
        % darauf antwortet die Person, (S150/160, S250/255)
        % dann wird der Beginn des ITI markiert, (S91/92)
        % hierauf folgt wieder die Präsentation des Fixationskreuzes
        % (S31/32)
% Aufgabe 2: siehe Skript
% Aufgabe 3: preprocessing Statistiken (siehe Ende des Skripts)
    % Im mittel entfernte Kanäle: 1.75
    % entfernte IC: 4.1
    % enfernte Daten: 35.29%
    % N epochen: 110.65
    % Bewertung: Mittlere Statistiken sehen alle passabel aus. Allerdings
    % scheinen VPn 7, 9, und 13-15 >50% ihrer Datenpunkt entfernt bekommen
    % haben. VP 14 behält nur 31 Epochen in ihrem Datensatz, was zu sehr
    % verrauschten EKPs führen kann. Die Anzahl der entfernten Kanäle
    % beträgt stets zwischen 0-3, dies kann ausreichend kompensiert werden.
    % Bei VP 7 wurden allerdings 5 Kanäle entfernt, je nach Lage diese
    % Kanäle kann dies problematisch sein.
% Aufgabe 4:
    % GA - siehe Skript
    % Latenzen und Amplitude, siehe Skript oder grand_average_peak(lat).txt
    % Basierend auf diesem Subset der VP scheint sich die Verarbeitung
    % nicht zu unterscheiden. Die Latenzen und Amplituden sowie die
    % Verläufe der beiden GA-bins (siehe Aufgabe 5) deuten nicht auf große
    % Unterschiede hin
% Aufgabe 5:
    % siehe Skript (unten)


% preprocessing allgemeines Skript zur Aufbereitung von EEG Daten 

clear all

[filepath, ~, ~] = fileparts(mfilename('fullpath'));
nSubjects = 20;
PATH_MAIN =  filepath; % Pfad in dem die Rohdaten liegen 
PATH_RAW_DATA = [filepath, 'data_coding_task/']; % Pfad in dem Ergebnisse gespeichert werden 

cd(PATH_MAIN)%wir ändern das working directory in unseren main Ordner

% Skript um Ordner zu erstellen 

mkdir(fullfile(PATH_MAIN,  'autocleaned'))
mkdir(fullfile(PATH_MAIN,  'icweights'))
mkdir(fullfile(PATH_MAIN, 'icset'))
mkdir(fullfile(PATH_MAIN, 'erp'))

PATH_AUTOCLEANED = [PATH_MAIN,  'autocleaned/'];
PATH_ICWEIGHTS = [PATH_MAIN,  'icweights/'];
PATH_ICSET = [PATH_MAIN,  'icset/'];

preprostats= [];
eeglab
for i = 1 : nSubjects
    
    % Setting i to 1 in console
    subject = num2str(i); %Subject ID wird einmal als string abgespeichert
    preprostats(i,1) =i; %Informationen zu den preprocessing statistiken werden in einer separaten Datei abgespeichert 
   
    % Definition des datafile 
    datafile = ['data_' num2str(i) '.vhdr'];
    
    if isfile([PATH_RAW_DATA datafile]) == 1
        
        % Daten einlesen
        EEG =  pop_loadbv(PATH_RAW_DATA, datafile, [], []);

        % Remove irrelevant tasks
        for j = 1:length(EEG.event)
            if strcmp(EEG.event(j).type, 'S  2')
                idxStart = j;
            elseif strcmp(EEG.event(j).type, 'S  3')
                idxEnd = j;
            end
        end
          

        EEG = pop_select(EEG,'time', [EEG.event(idxStart).latency/1000  EEG.event(idxEnd).latency/1000]); % remove data

        % Save original channel locations
        EEG.chanlocs_original = EEG.chanlocs;
        
        impevents = {'S 51', 'S 52'};
        correvents = {'S150' 'S160'};
        
        % Als erstes müssen wir alle events finden
        % Wie sieht das stimidx file aus?
        stimidx = find(ismember({EEG.event.type}, impevents));
        rt = [];
        for e = 1 : length(stimidx)
            if ismember(EEG.event(stimidx(e)+1).type, correvents) && ... % ist die Resp korrekt
                    (EEG.event(stimidx(e)+1).latency - EEG.event(stimidx(e)).latency >= 150) %antizipatorische Reaktionstendenzen
                % Experimentarbedingung 
                if strcmp(EEG.event(stimidx(e)).type,'S 51')
                    EEG.event(stimidx(e)).Condition = 'Congruent';
                    EEG.event(stimidx(e)).Cond_Factor =1;
                elseif strcmp(EEG.event(stimidx(e)).type,'S 52')
                    EEG.event(stimidx(e)).Condition = 'Incongruent';
                    EEG.event(stimidx(e)).Cond_Factor =2;
                end
                EEG.event(stimidx(e)).type = 'stim';
                EEG.event(stimidx(e)).RT = EEG.event(stimidx(e)+1).latency - EEG.event(stimidx(e)).latency;
            end
        end
        
        
        % hier erstellen wir einen neuen Datensatz 
        ICA = EEG;
        % Resample
        EEG = pop_resample(EEG, 250);
        ICA = pop_resample(ICA, 100);
        
        % High-pass filter data
        
        % IIR Butterworth filter
        % EEG = pop_basicfilter(EEG, [1 : EEG.nbchan], 'Cutoff', [0.1, 8], 'Design', 'butter', 'Filter', 'bandpass', 'Order', 4, 'RemoveDC', 'on', 'Boundary', 'boundary');
        % ICA = pop_basicfilter(ICA, [1 : EEG.nbchan], 'Cutoff', [1, 8], 'Design', 'butter', 'Filter', 'bandpass', 'Order', 4, 'RemoveDC', 'on', 'Boundary', 'boundary');
        
        % zero-phase Hamming window FIR-filter (recommended for power analyses)
         EEG = pop_eegfiltnew(EEG, 'locutoff', 0.1,'hicutoff', 16, 'plotfreqz',0);
         ICA = pop_eegfiltnew(ICA, 'locutoff', 1,'hicutoff', 16, 'plotfreqz',0);
         % Hier werden 16Hz low-pass und geeignete high-pass Filter für die
         % Datensätze verwendet. High-pass Filter für ICA sollte etwas
         % größer sein

        % Bad channel detection & data cleaning Original
        
       % EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );
       % ICA = pop_clean_rawdata(ICA, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );
        
        %Informationen zur Anzahl gelöschter Kanäle
        %Wie viele Kanäle wurden gelöscht?
        %Wie hat sich nbchan geändert?
%       if isfield(EEG.etc ,'clean_channel_mask')
%            preprostats(i,2) =  sum(EEG.etc.clean_channel_mask==0);
%         else
%             preprostats(i,2) = 0;
%         end
%         if isfield(ICA.etc ,'clean_channel_mask')
%             preprostats(i,3) =  sum(ICA.etc.clean_channel_mask==0);
%         else
%             preprostats(i,3) = 0;
%         end
        
        % Bad channel detection & data cleaning Alternative
        % -------------------------------------------------
        
        EEG_clean = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','off','WindowCriterionTolerances','off' );
        ICA_clean = pop_clean_rawdata(ICA, 'FlatlineCriterion',5,'ChannelCriterion',0.8,'LineNoiseCriterion',4,'Highpass','off','BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','off','WindowCriterionTolerances','off' );
        
       
        % Augenkanäle werden hier nun beibehalten
        
        if isfield(EEG_clean.etc, 'clean_channel_mask')
            rejected_channels_EEG = find(~EEG_clean.etc.clean_channel_mask);
            % Wenn Channel 33 oder 34 (EOG) bei den rejected channels dabei sind,
            % sollen diese wieder entfernt werden
            if ismember(33, rejected_channels_EEG)
                rejected_channels_EEG(rejected_channels_EEG == 33) = [];
            end
            if ismember(34, rejected_channels_EEG)
                rejected_channels_EEG(rejected_channels_EEG == 34) = [];
            end
            preprostats(i,2) = length(rejected_channels_EEG);
            % jetzt können Kanäle entfernt werden
            EEG = pop_select(EEG, 'nochannel',rejected_channels_EEG);
        else
            % Wenn gar kein Kanal entfernt wird, speichern wir die
            % Information entsprechend ab
            preprostats(i,2) = 0;
        end
        
        if isfield(ICA_clean.etc, 'clean_channel_mask')
            rejected_channels_ICA = find(~ICA_clean.etc.clean_channel_mask);
            
            if ismember(33, rejected_channels_ICA)
                rejected_channels_ICA(rejected_channels_ICA == 33) = [];
            end
            if ismember(34, rejected_channels_ICA)
                rejected_channels_ICA(rejected_channels_ICA == 34) = [];
            end
            preprostats(i,3) = length(rejected_channels_ICA);
            ICA = pop_select(ICA, 'nochannel',rejected_channels_ICA);
        else
            preprostats(i,3) = 0;
        end

        EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );
        ICA = pop_clean_rawdata(ICA, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','off','BurstCriterion',20,'WindowCriterion',0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );

       %---------------------------------------------------------------------
       
        % Information zur Anzahl der gelöchten Datenpunkte speichern
        preprostats(i,4) =  sum(EEG.etc.clean_sample_mask==0)/length(EEG.etc.clean_sample_mask)*100;
        preprostats(i,5) =  sum(ICA.etc.clean_sample_mask==0)/length(ICA.etc.clean_sample_mask)*100;
        
        
        %interpolation der geschlöschten Kanäle
        EEG = pop_interp(EEG,  EEG.chanlocs_original, 'spherical');
        ICA = pop_interp(ICA,  ICA.chanlocs_original, 'spherical');
        
        % Re-referenzierung der Daten
        
        % Zunächst wird die online referenz wieder hinzugefügt
        EEG = pop_chanedit(EEG, 'append',EEG.nbchan,'changefield',{EEG.nbchan+1 'labels' 'Cz'},'changefield',{EEG.nbchan+1 'sph_theta' '0'},'changefield',{EEG.nbchan+1 'sph_phi' '90'},'changefield',{EEG.nbchan+1 'sph_radius' '85'},'convert',{'sph2all'});
        EEG = pop_chanedit(EEG, 'setref',{'1:34' 'Cz'});
        
        
        ICA = pop_chanedit(ICA, 'append',ICA.nbchan,'changefield',{ICA.nbchan+1 'labels' 'Cz'},'changefield',{ICA.nbchan+1 'sph_theta' '0'},'changefield',{ICA.nbchan+1 'sph_phi' '90'},'changefield',{ICA.nbchan+1 'sph_radius' '85'},'convert',{'sph2all'});
        ICA = pop_chanedit(ICA, 'setref',{'1:34' 'Cz'});
        
        %average reference
        EEG = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'sph_radius',{85},'sph_theta',{0},'sph_phi',{90},'theta',{0},'radius',{0},'X',{5.2047e-15},'Y',{0},'Z',{85},'type',{''},'ref',{'Cz'},'urchan',{[]},'datachan',{0},'sph_theta_besa',{0},'sph_phi_besa',{90}));
        ICA = pop_reref( ICA, [],'refloc',struct('labels',{'Cz'},'sph_radius',{85},'sph_theta',{0},'sph_phi',{90},'theta',{0},'radius',{0},'X',{5.2047e-15},'Y',{0},'Z',{85},'type',{''},'ref',{'Cz'},'urchan',{[]},'datachan',{0},'sph_theta_besa',{0},'sph_phi_besa',{90}));
        
        %Referenz zu den linked mastoids
        %EEG = pop_reref( EEG, [27 31] ,'refloc',struct('labels',{'Cz'},'sph_radius',{85},'sph_theta',{0},'sph_phi',{90},'theta',{0},'radius',{0},'X',{5.2047e-15},'Y',{0},'Z',{85},'type',{''},'ref',{'Cz'},'urchan',{[]},'datachan',{0},'sph_theta_besa',{0},'sph_phi_besa',{90}));
        %ICA = pop_reref( ICA, [27 31] ,'refloc',struct('labels',{'Cz'},'sph_radius',{85},'sph_theta',{0},'sph_phi',{90},'theta',{0},'radius',{0},'X',{5.2047e-15},'Y',{0},'Z',{85},'type',{''},'ref',{'Cz'},'urchan',{[]},'datachan',{0},'sph_theta_besa',{0},'sph_phi_besa',{90}));
        
        % check data rank
        dataRank = sum(eig(cov(double(ICA.data'))) > 1E-6); % 1E-6 follows pop_runica() line 531, changed from 1E-7.
        
        % Epoch Data
        % note: whether it's sensible to epoch the data before the ICA depends
        % on the number of data points. Generally, ICA decomposition works
        % better on continous data. However, if the amount of data point after
        % epoching is still sufficient ([number of channels^2] x 30) epoching before
        % ICA is recommended since it will increase stationarity
        % Also: Removing the epoch baseline is not recommended for ICA because
        % it introduces random offsets in each channel, something ICA cannot model
        % or compensate for. (source: eeglab tutorials)
        
        EEG = pop_epoch(EEG, {'stim'}, [-0.2, 1.0], 'epochinfo', 'yes');
        ICA = pop_epoch(ICA, {'stim'}, [0, 1.0], 'epochinfo', 'yes');
        
        preprostats(i,6) = EEG.event(end).epoch;
        preprostats(i,7) = ICA.event(end).epoch;
        
        %Das ICA Data set wird zwischengespeichert
        ICA = pop_saveset(ICA, 'filename', [subject '_ic_set.set'], 'filepath', PATH_ICSET, 'check', 'on', 'savemode', 'twofiles');
                
        ICA = pop_runica(ICA, 'extended', 1, 'interupt', 'on', 'pca', dataRank);
        ICA = pop_saveset(ICA, 'filename', [subject '_weights.set'], 'filepath', PATH_ICWEIGHTS, 'check', 'on', 'savemode', 'twofiles');
        
        % Run IClabel on data set
        ICA = iclabel(ICA, 'default');
        ICA.ICout_IClabel = find(ICA.etc.ic_classification.ICLabel.classifications(:, 1) < 0.5);
        
        
        % Übertragung der IC weights auf die weniger stark highpass gefilterten Daten (EEG) (mit 0.1 Hz)
        EEG.icachansind = ICA.icachansind;
        EEG.icaweights =ICA.icaweights;
        EEG.icasphere = ICA.icasphere;
        EEG.icawinv =  ICA.icawinv;
        EEG.ICout_IClabel = ICA.ICout_IClabel;
        
        % Berechnung IC activation matrix
        EEG = eeg_checkset(EEG, 'ica');
        
        % Entfernung der IC Komponenten 
        EEG = pop_subcomp(EEG, EEG.ICout_IClabel);
        preprostats(i, 8) = length(EEG.ICout_IClabel);
        EEG = pop_saveset(EEG, 'filename', [subject '_autocleaned.set'], 'filepath', PATH_AUTOCLEANED, 'check', 'on', 'savemode', 'twofiles');
        
        % Speicherung der preprocessing Statistiken
        writematrix(preprostats, [PATH_AUTOCLEANED 'preprostats.csv'])
    end
end



% =================================== PART2: ERP ===================================

% Add new paths for ERP and LRP
nSubjects=20;




PATH_ERP = fullfile(PATH_MAIN, 'erp/');

for i=1:nSubjects
    % Daten einlesen
    subject = num2str(i);
    
    datafile=[subject '_autocleaned.set'];
    
    if isfile([PATH_AUTOCLEANED datafile]) == 1
        
        EEG = pop_loadset('filename', datafile, 'filepath', PATH_AUTOCLEANED, 'loadmode', 'all');
        
        % Rekodierung der event types für ERPlab
        for j = 1:length(EEG.event)
            if strcmp(EEG.event(j).type, 'stim') && strcmp(EEG.event(j).Condition, 'Congruent')
                EEG.event(j).type = 1;
            elseif strcmp(EEG.event(j).type, 'stim') && strcmp(EEG.event(j).Condition, 'Incongruent')
                EEG.event(j).type = 2;
            end
        end
        
        % Response marker entfernen
        EEG = eeg_checkset(EEG, 'eventconsistency');
        
        % Daten wieder kontinueierlich machen
        EEG = pop_epoch2continuous(EEG,'Warning','off');
        
        % EventList für ERPLab
        EEG  = pop_creabasiceventlist(EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' } );
        
        % Bins für die verschiedenen Bedingungen
        EEG  = pop_binlister(EEG , 'BDF', [PATH_MAIN 'binlister.txt'], 'IndexEL',  1, 'SendEL2', 'Workspace&EEG', 'UpdateEEG', 'on', 'Voutput', 'EEG' );
        
        EEG.setname = [num2str(i) '_bin'];
        
        % Daten epochieren
        EEG = pop_epochbin( EEG , [-200.0  1000.0],  [ -200 0]);
        EEG.setname = [[num2str(i) '_'] '_bin_epoch'];
        
        % Berechnung der EKPs für die verschiedenen Bins (Bedingungen)
        ERP = pop_averager( EEG , 'Criterion', 'all', 'ExcludeBoundary', 'off', 'SEM', 'on' );
        ERP.erpname = 'bin_average';
        
        %Filter ERP
        %ERP = pop_filterp( ERP,[1: ERP.nchan] , 'Cutoff',8, 'Design', 'butter', 'Filter', 'lowpass', 'Order',2 );
        
        % Finales Erp set speichern
        ERP = pop_savemyerp(ERP, 'erpname', ERP.erpname, 'filename', ['flanker_' num2str(i) '.erp'], 'filepath', PATH_ERP);
    end
end

% plotting grand average
[ERP ALLERP] = pop_loaderp( 'filename', {'flanker_1.erp', 'flanker_2.erp', 'flanker_3.erp', 'flanker_4.erp', 'flanker_5.erp', 'flanker_6.erp',...
 'flanker_7.erp', 'flanker_8.erp', 'flanker_9.erp', 'flanker_10.erp', 'flanker_11.erp', 'flanker_12.erp', 'flanker_13.erp', 'flanker_14.erp',...
 'flanker_15.erp', 'flanker_16.erp', 'flanker_17.erp', 'flanker_18.erp', 'flanker_19.erp', 'flanker_20.erp'}, 'filepath',...
 PATH_ERP );

erp_ga = pop_gaverager(ALLERP , 'DQ_flag', 1, 'Erpsets', [1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20],...
 'ExcludeNullBin', 'on', 'SEM', 'on' );
erp_ga = pop_savemyerp(erp_ga, 'erpname', 'grand_average_flanker', 'filename',...
 'grand_average_flanker.erp', 'filepath', PATH_ERP, 'Warning', 'on');

erp_ga = pop_loaderp('erp/grand_average_flanker.erp');

plot(erp_ga(1).times, erp_ga(1).bindata(11,:,1) )%define electrode and bin to plot 
hold on
plot(erp_ga(1).times, erp_ga(1).bindata(11,:,2), '--' )%define electrode and bin to plot 
axis([-200 800 -5 9]) % Achsen entsprechend des Signals anpassen 
set(gca, 'YDir','reverse') % Hier wird einmal die Achse gedreht -> Negativierung oben 

%weitere Feinheiten verändern
hold on
ax = gca;
ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
set(gca,'TickDir','in'); 
ax.XRuler.TickLabelGapOffset = -20;    
Ylm=ylim;                          
Xlm=xlim;  
Xlb=0.90*Xlm(2);
Ylb=0.90*Ylm(1);
xlabel('ms','Position',[Xlb 1]); 
ylabel('µV','Position',[-100 Ylb]); 
legend('Congruent','Incongruent', 'Location', 'southeast')
box off
hold off

% Get the peak latency and amplitude of the grand average
p3_values = calc_p3_values(erp_ga);
% Rows are bins, first column is latency, second is amplitude
% Bin1: Latency = 420ms, Amplitude = 4.6637mV
% Bin2: Latency = 424ms, Amplitude = 4.3653mV

% Accessing preprostats for checking
mean_removed_channels_eeg = mean(preprostats(:, 2));
mean_removed_ic = mean(preprostats(:, 8));
mean_removed_data_eeg = mean(preprostats(:, 4));
mean_epoch_eeg = mean(preprostats(:, 6));

