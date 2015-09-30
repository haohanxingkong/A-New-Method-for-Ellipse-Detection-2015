function PODExperiments(en,N)
%% Experiments for 'A New Method for Ellipse Detection' by Nelson et al. (2015)
%
% PODExperiments(en,N)
%
% Details   This function contains all the experiments implemented for
%           the paper 'A New Method for Ellipse Detection' by Carl J.
%           Nelson, Philip T. G. Jackson and Boguslaw Obara in 2015.
% Inputs    en - Experiment number, between 1 and 6
%           N - number or repeat trials (only reqiured for certain
%           experiments; default is 1)
% Outputs   N/A - all experiments save their data to file
%
% Examples:
% PODExperiments(4), runs the experiments used to create Figure 7
% PODExperiments(2,10), runs the experiments used to create Figure 6b ten times
%
% Copyright 2015 Carl J. Nelson, Durham University, UK
%
% License   See included <a href="./LICENSE/">file</a> or visit
%           <a href="https://github.com/ChasNelson1990/...
%              A-New-Method-for-Ellipse-Detection-2015/">The GitHub
%              Repository</a>
%
% See also POD2, PODH, ELLIPTICALHOUGH, ELLIPSESFROMTRIANGLES, ACCURACYMAPSCRIPTS

%% Set-Up
profile -memory
switch en
%% Experiment 1 - Change of image size, set kernel size range (binary image)
    case 1
        % Inputs
        if nargin==1; N = 1; end;
        % Create File for Results
        headers = {'N','m',...
            'POD:time','POD:memory','POD:Jaccard',...
            'PODH:time','PODH:memory','PODH:Jaccard',...
            'Hough:time','Hough:memory','Hough:Jaccard',...
            'EFT:time','EFT:memory','EFT:Jaccard'};
        headers = strjoin(headers,',');
        fid = fopen('experiment1.dat','w');
        fprintf(fid,'%s\r\n',headers); fclose(fid);
        % Set-Up
        major=randi(27,1)+3; minor=randi(major-3,1)+3;
        rot=randi(180,1); ms = [64,128,256,512,1024];
        for m=1:length(ms)
            % Data
            data = cell(N,14);
            data(:,2) = cellstr(num2str(repmat(ms(m),N,1)));
            % Create Image
            bw = ellipse2(ms(m),[ceil((ms(m)+1)/2),ceil((ms(m)+1)/2)],major,minor,rot);
            for rn=1:N
                % Data
                data{rn,1} = num2str(rn);
                % Run POD
                profile on, results = pod2 (bw,(2*15)+1);
                stats = profile('info');
                funct = find(cellfun(@(x)isequal(x,'pod2'),{stats.FunctionTable.FunctionName}));
                time = stats.FunctionTable(funct).TotalTime;
                memory = stats.FunctionTable(funct).TotalMemAllocated;
                data{rn,3} = num2str(time); data{rn,4} = num2str(memory);
                profile off, clear stats funct time memory
                % POD Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,size(results,1));
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3); clear o results;
                data{rn,5} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                clear bwo
                % Run PODH
                profile on, results = podh (bw,(2*15)+1);
                stats = profile('info');
                funct = find(cellfun(@(x)isequal(x,'podh'),{stats.FunctionTable.FunctionName}));
                time = stats.FunctionTable(funct).TotalTime;
                memory = stats.FunctionTable(funct).TotalMemAllocated;
                data{rn,6} = num2str(time); data{rn,7} = num2str(memory);
                profile off, clear stats funct time memory
                % PODH Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,size(results,1));
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3); clear o results
                data{rn,8} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                clear bwo
                % Run Hough
                profile on, edges = edge(bw,'canny');
                results = ellipticalHough(edges,(2*15)+1);
                stats = profile('info');
                funct = find(cellfun(@(x)isequal(x,'ellipticalHough'),{stats.FunctionTable.FunctionName}));
                time = stats.FunctionTable(funct).TotalTime;
                memory = stats.FunctionTable(funct).TotalMemAllocated;
                data{rn,9} = num2str(time); data{rn,10} = num2str(memory);
                profile off, clear stats funct time memory edges
                % Hough Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,size(results,1));
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3); clear o results
                data{rn,11} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                clear bwo
                % Run Ellipses From Triangles (EFT)
                profile on, edges = edge(bw,'canny');
                results = ellipsesFromTriangles(edges,(2*15)+1);
                stats = profile('info');
                funct = find(cellfun(@(x)isequal(x,'ellipsesFromTriangles'),{stats.FunctionTable.FunctionName}));
                time = stats.FunctionTable(funct).TotalTime;
                memory = stats.FunctionTable(funct).TotalMemAllocated;
                data{rn,12} = num2str(time); data{rn,13} = num2str(memory);
                profile off, clear stats funct time memory edges
                % EFT Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,size(results,1));
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3); clear o results
                data{rn,14} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                clear bwo
            end
            % Append Data to File
            fid = fopen('experiment1.dat','a+');
            for o=1:N
                dato = strjoin(data(o,:),',');
                fprintf(fid,'%s\r\n',dato);
            end
            fclose(fid); clear data dato fid bw
        end
%% Experiment 2 - Change of kernel size (max), set image size (binary image)
    case 2
        % Inputs
        if nargin==1; disp('Running only once'); N = 1; end;
        % Create File for Results
        headers = {'N','k',...
            'POD:time','POD:memory','POD:Jaccard',...
            'PODH:time','PODH:memory','PODH:Jaccard',...
            'Hough:time','Hough:memory','Hough:Jaccard',...
            'EFT:time','EFT:memory','EFT:Jaccard'};
        headers = strjoin(headers,',');
        fid = fopen('experiment2.dat','w');
        fprintf(fid,'%s\r\n',headers); fclose(fid);
        % Set-Up
        ks = 15:5:65;
        for k=1:length(ks)
            % Set-Up
            major=randi(7,1)+7; minor=randi(major-1,1)+1;
            rot=randi(180,1);
            % Create Image
            bw = ellipse2(256,[ceil((256+1)/2),ceil((256+1)/2)],major,minor,rot);
            % Data
            data = cell(N,14);
            data(:,2) = cellstr(num2str(repmat(ks(k),N,1)));
            for rn=1:N
                % Data
                data{rn,1} = num2str(rn);
                % Run POD
                profile on, results = pod2 (bw,ks(k));
                stats = profile('info');
                funct = find(cellfun(@(x)isequal(x,'pod2'),{stats.FunctionTable.FunctionName}));
                time = stats.FunctionTable(funct).TotalTime;
                memory = stats.FunctionTable(funct).TotalMemAllocated;
                data{rn,3} = num2str(time); data{rn,4} = num2str(memory);
                profile off, clear stats funct time memory
                % POD Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,size(results,1));
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3); clear o results;
                data{rn,5} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                clear bwo
                % Run PODH
                profile on, results = podh (bw,ks(k));
                stats = profile('info');
                funct = find(cellfun(@(x)isequal(x,'podh'),{stats.FunctionTable.FunctionName}));
                time = stats.FunctionTable(funct).TotalTime;
                memory = stats.FunctionTable(funct).TotalMemAllocated;
                data{rn,6} = num2str(time); data{rn,7} = num2str(memory);
                profile off, clear stats funct time memory
                % PODH Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,size(results,1));
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3); clear o results
                data{rn,8} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                clear bwo
                % Run Hough
                profile on, edges = edge(bw,'canny');
                results = ellipticalHough(edges,ks(k));
                stats = profile('info');
                funct = find(cellfun(@(x)isequal(x,'ellipticalHough'),{stats.FunctionTable.FunctionName}));
                time = stats.FunctionTable(funct).TotalTime;
                memory = stats.FunctionTable(funct).TotalMemAllocated;
                data{rn,9} = num2str(time); data{rn,10} = num2str(memory);
                profile off, clear stats funct time memory edges
                % Hough Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,size(results,1));
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3); clear o results
                data{rn,11} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                clear bwo
                % Run Ellipses From Triangles (EFT)
                profile on, edges = edge(bw,'canny');
                results = ellipsesFromTriangles(edges,ks(k));
                stats = profile('info');
                funct = find(cellfun(@(x)isequal(x,'ellipsesFromTriangles'),{stats.FunctionTable.FunctionName}));
                time = stats.FunctionTable(funct).TotalTime;
                memory = stats.FunctionTable(funct).TotalMemAllocated;
                data{rn,12} = num2str(time); data{rn,13} = num2str(memory);
                profile off, clear stats funct time memory edges
                % EFT Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,size(results,1));
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3); clear o results
                data{rn,14} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                clear bwo
            end
            % Append Data to File
            fid = fopen('experiment2.dat','a+');
            for o=1:N
                dato = strjoin(data(o,:),',');
                fprintf(fid,'%s\r\n',dato);
            end
            fclose(fid); clear data dato fid bw
        end
%% Experiment 3 - Different numbers of objects (non-overlapping)
    case 3
        % Inputs
        if nargin==1; N = 1; end
        % Create File for Results
        headers = {'N','number',...
            'POD:n','POD:time','POD:memory','POD:Jaccard',...
            'PODH:n','PODH:time','PODH:memory','PODH:Jaccard',...
            'Hough: n','Hough:time','Hough:memory','Hough:Jaccard',...
            'EFT:n','EFT:time','EFT:memory','EFT:Jaccard'};
        headers = strjoin(headers,',');
        fid = fopen('experiment3.dat','w');
        fprintf(fid,'%s\r\n',headers);
        fclose(fid);
        for l=1:200;
            % Create Figure
            bw = zeros(256,256,l);
            xposs = cell(l,1); yposs = cell(l,1); majors = cell(l,1);
            for o=1:l
                major=randi(11,1)+3; minor=randi(major-3,1)+3; rot=randi(180,1);
                xpos = randi(226)+15; ypos = randi(226)+15;
                if o>1
                    overlapping = true;
                    while overlapping
                        overlapping = false;
                        for ps=2:o
                            distmap = zeros(256,256);
                            distmap(xposs{ps},yposs{ps})=1;
                            distmap = bwdist(distmap);
                            if distmap(xpos,ypos)<=(major+majors{ps})
                                xpos = randi(226)+15; ypos = randi(226)+15;
                                overlapping = true;
                                break
                            end
                        end
                    end
                end
                clear overlapping ps distmap
                bw(:,:,o) = ellipse2(256,[xpos,ypos],major,minor,rot);
                xposs{o} = xpos; yposs{o} = ypos; majors{o} = major;
            end
            bw = max(bw,[],3);
            clear o major minor rot xpos ypos xposs yposs majors
            % Data
            data = cell(N,18);
            data(:,2) = cellstr(num2str(repmat(l,N,1)));
            for rn=1:N
                % Data
                data{rn,1} = num2str(rn);
                % Run POD
                profile on, results = pod2 (bw,(2*7)+1);
                stats = profile('info');
                funct = find(cellfun(@(x)isequal(x,'pod2'),{stats.FunctionTable.FunctionName}));
                time = stats.FunctionTable(funct).TotalTime;
                memory = stats.FunctionTable(funct).TotalMemAllocated;
                data{rn,3} = num2str(size(results,1));
                data{rn,4} = num2str(time); data{rn,5} = num2str(memory);
                profile off, clear stats funct time memory
                % POD Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,size(results,1));
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3); clear o results;
                data{rn,6} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                clear bwo
                % Run PODH
                profile on, results = podh (bw,(2*7)+1);
                stats = profile('info');
                funct = find(cellfun(@(x)isequal(x,'podh'),{stats.FunctionTable.FunctionName}));
                time = stats.FunctionTable(funct).TotalTime;
                memory = stats.FunctionTable(funct).TotalMemAllocated;
                data{rn,7} = num2str(size(results,1));
                data{rn,8} = num2str(time); data{rn,9} = num2str(memory);
                profile off, clear stats funct time memory
                % PODH Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,size(results,1));
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3); clear o results
                data{rn,10} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                clear bwo
                % Run Hough
                profile on, edges = edge(bw,'canny');
                results = ellipticalHough(edges,(2*7)+1);
                stats = profile('info');
                funct = find(cellfun(@(x)isequal(x,'ellipticalHough'),{stats.FunctionTable.FunctionName}));
                time = stats.FunctionTable(funct).TotalTime;
                memory = stats.FunctionTable(funct).TotalMemAllocated;
                data{rn,11} = num2str(size(results,1));
                data{rn,12} = num2str(time); data{rn,13} = num2str(memory);
                profile off, clear stats funct time memory edges
                % Hough Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,size(results,1));
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3); clear o results
                data{rn,14} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                clear bwo
                % Run Ellipses From Triangles (EFT)
                profile on, edges = edge(bw,'canny');
                results = ellipsesFromTriangles(edges,(2*7)+1);
                stats = profile('info');
                funct = find(cellfun(@(x)isequal(x,'ellipsesFromTriangles'),{stats.FunctionTable.FunctionName}));
                time = stats.FunctionTable(funct).TotalTime;
                memory = stats.FunctionTable(funct).TotalMemAllocated;
                data{rn,15} = num2str(size(results,1));
                data{rn,16} = num2str(time); data{rn,17} = num2str(memory);
                profile off, clear stats funct time memory edges
                % EFT Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,size(results,1));
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3); clear o results
                data{rn,18} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                clear bwo
            end
            % Append Data to File
            fid = fopen('experiment3.dat','a+');
            for o=1:N
                dato = strjoin(data(o,:),',');
                fprintf(fid,'%s\r\n',dato);
            end
            fclose(fid);
            clear data dato fid
        end
%% Experiment 4 - Clustered and Overlapping Objects
    case 4
        % Create File for Results
        headers = {'distx','disty',...
            'POD:n','POD:Jaccard',...
            'PODH:n','PODH:Jaccard',...
            'Hough:n','Hough:Jaccard',...
            'EFT:n','EFT:Jaccard'};
        headers = strjoin(headers,',');
        fid = fopen('experiment4.dat','w');
        fprintf(fid,'%s\r\n',headers);
        fclose(fid);
        distmax = 105;
        distmin = -105;
        major=round(30); minor=round(20);
        xpos = 128; ypos = 128;
        parfor l=distmin:distmax
            for k=distmin:distmax
                % Create Figure
                sepx = (major+minor) * l/100;
                sepy = (major+minor) * k/100;
                idx1 = ellipse2(256,[xpos,ypos],major,minor,0);
                idx2 = ellipse2(256,[xpos+sepx,ypos+sepy],major,minor,90);
                bw = max(idx1,idx2);
                % Data
                data = cell(1,10);
                data{1} = num2str(l);
                data{2} = num2str(k);
                % Data
                % Run POD
                results = pod2 (bw,[10,40],1,90);
                data{3} = num2str(size(results,1));
                % POD Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,size(results,1));
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3);
                data{4} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                % Run PODH
                results = podh (bw,[10,40],1,90);
                data{5} = num2str(size(results,1));
                % PODH Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,size(results,1));
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3);
                data{6} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                % Run Hough
                edges = edge(bw,'canny');
                results = ellipticalHough(edges,[10,40]);
                data{7}= num2str(size(results,1));
                % Hough Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,size(results,1));
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3);
                data{8} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                % Run Ellipses From Triangles (EFT)
                edges = edge(bw,'canny');
                results = ellipsesFromTriangles(edges,[10,40]);
                data{9}= num2str(size(results,1));
                % EFT Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,size(results,1));
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3);
                data{10} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                % Append Data to File
                fid = fopen('experiment4.dat','a+');
                data = strjoin(data,',');
                fprintf(fid,'%s\r\n',data);
                fclose(fid);
            end
        end
%% Experiment 5 - Accuracy over lengths and rotations
    case 5
        % Data File Set-Up
        headers = {'X','Y','Major','Minor','Rotation',...
            'POD:n','POD:Jaccard',...
            'PODH:n','PODH:Jaccard',...
            'Hough:n','Hough:Jaccard',...
            'EFT:n','EFT:Jaccard'};
        headers = strjoin(headers,','); fid = fopen('experiment5.dat','w');
        fprintf(fid,'%s\r\n',headers); fclose(fid);
        major = 30;%Only use one major axis value for accuracy maps
        parfor rot=0:179
            %for major=3:30
                for minor=3:major
                    % Data Set-Up
                    data = cell(1,13);
                    data{1} = num2str(ceil((64+1)/2));
                    data{2} = num2str(ceil((64+1)/2));
                    data{3} = num2str(major);
                    data{4} = num2str(minor);
                    data{5} = num2str(rot);
                    % Create Image
                    bw = ellipse2(64,[ceil((64+1)/2),ceil((64+1)/2)],major,minor,rot);
                    % Run POD
                    results = pod2 (bw);
                    l = size(results,1); data{6} = num2str(l);
                    % POD Jaccard
                    bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,l);
                    for o=1:l
                        bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                    end
                    bwo = max(bwo,[],3);
                    data{7} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                    % Run PODH
                    results = podh (bw);
                    l = size(results,1); data{8} = num2str(l);
                    % PODH Jaccard
                    bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,l);
                    for o=1:l
                        bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                    end
                    bwo = max(bwo,[],3);
                    data{9} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                    % Run Hough
                    edges = edge(bw,'canny'); results = ellipticalHough(edges);
                    l = size(results,1); data{10} = num2str(l);
                    % Hough Jaccard
                    bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,l);
                    for o=1:l
                        bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                    end
                    bwo = max(bwo,[],3);
                    data{11} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                    % Run Ellipses From Triangles (EFT)
                    try
                        results = ellipsesFromTriangles(edges);
                        l = size(results,1);
                    catch
                        l=0;
                    end
                    data{12} = num2str(l);
                    if l~=0
                        % EFT Jaccard
                        bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,l);
                        for o=1:l
                            bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                        end
                        bwo = max(bwo,[],3);
                        data{13} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                    else
                        data{13} = num2str(1);
                    end
                    % Append Data to File
                    fid = fopen('experiment5.dat','a+');
                    data = strjoin(data,',');
                    fprintf(fid,'%s\r\n',data);
                    fclose(fid);
                end
            %end
        end
%% Experiment 6 - Change SNR (binary)
    case 6
        % Inputs
        if nargin==1; N = 1; end
        % Create File for Results
        headers = {'N','SNR-Theoretical','SNR-Real',...
            'POD:Jaccard','POD:Time',...
            'PODH:Jaccard','PODH:Time',...
            'Hough:Jaccard','Hough:Time',...
            'EFT:Jaccard','EFT:Time'};
        headers = strjoin(headers,',');
        fid = fopen('experiment6.dat','w');
        fprintf(fid,'%s\r\n',headers);
        fclose(fid);
        clear headers fid
        % Set-Up
        major=randi(20,1)+10; minor=randi(major-10,1)+10;
        rot=randi(180,1); m=128; k=35;
        for snr=34:-1:0
            % Data
            data = cell(N,11);
            data(:,2) = cellstr(num2str(repmat(snr,N,1)));
            % Create Image
            bw = ellipse2(m,[ceil((m+1)/2),ceil((m+1)/2)],major,minor,rot);
            for rn = 1:N
                % Apply Noise
                noise = (10^(-(snr-5)/20) * (randn(size(bw))));
                bw1 = bw+noise;
                bw1 = imadjust(bw1);
                [x,y] = ndgrid(1:30,1:30);
                RMS_noise = sqrt(mean(var(bw1(x,y))));
                actualSNR = 20 * log10(1/RMS_noise);
                % Blur (to remove noise)
                bw1 = imgaussfilt(bw1,3);
                % Data
                data{rn,1} = num2str(rn);
                data{rn,3} = num2str(actualSNR);
                % Run POD
                tic; results = pod2 (bw1,[5,k],1,1);
                data{rn,5} = num2str(toc);
                % POD Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,size(results,1));
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3);
                data{rn,4} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                % Run PODH
                tic; results = podh (bw1,[5,k],1,1);
                data{rn,7} = num2str(toc);
                % PODH Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,size(results,1));
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3);
                data{rn,6} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                % Run Hough
                tic; edges = edge(bw1,'canny');
                results = ellipticalHough (edges,[5,k]);
                data{rn,9} = num2str(toc);
                clear edges
                % Hough Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,size(results,1));
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3);
                data{rn,8} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
                % Run Ellipses From Triangles (EFT)
                tic; edges = edge(bw1,'canny');
                results = ellipsesFromTriangles(edges);
                data{11} = num2str(toc);
                clear edges
                % EFT Jaccard
                bwo = zeros(size(bw)); bwo = repmat(bwo,1,1,l);
                for o=1:size(results,1)
                    bwo(:,:,o) = ellipse2(size(bw),[results(o,1),results(o,2)],results(o,3),results(o,4),results(o,5));
                end
                bwo = max(bwo,[],3);
                data{10} = num2str(sum(sum(imabsdiff(bw,bwo)))/sum(bw(:)|bwo(:)));
            end
            % Append Data to File
            fid = fopen('experiment6.dat','a+');
            for o=1:N
                dato = strjoin(data(o,:),',');
                fprintf(fid,'%s\r\n',dato);
            end
            fclose(fid);
        end
end
end
