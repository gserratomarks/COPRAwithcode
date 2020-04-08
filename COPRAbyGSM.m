%% COPRA without the GUI
% Updated 04/07/2020 by G. Serrato Marks, gserrato@mit.edu

%Background: if you're using MATLAB without the MATLAB GUI Layout
%toolbox, you have issues running the GUI, or if you just prefer to use code
%instead, you can work with COPRA directly with this m file.

%I adapted the following code from COPRA's built-in example_script.m. Note
%that I am not affiliated with the original COPRA authors.

%STEP O: Download COPRA from here: https://tocsy.pik-potsdam.de/copra.php
%If you use this code, make sure you cite Breitenbach et al., 2012.

%% Entering your data
%STEP 1: put your dates in order by depth (smallest depth to largest depth)
%in Excel or whatever program you use. 
% 3 columns: DEPTH, AGE, 2 SIG ERROR.
% Copy and paste the dates into matlab as 
%c = [paste data];
%in the command window.
% Note: It's easiest if you go through your dates carefully and remove any
% that have chemistry issues or are very dirty BEFORE you paste them in. In
% other words, you should be pasting nice, real dates that you trust. 


%STEP 2: Create a data structure called "d" that has all the dates.
%It's like a file cabinet that you will fill with everything you need to run COPRA. 
d.depth = c(:,1); %depth of the age (can be any unit as long as you're consistent)
d.age = c(:,2); %dates in years BP 
d.ageerror = c(:,3); %error on dates
d.ageerror=d.ageerror/2; % You gave it 2 sigma, but COPRA wants 1 sigma
d.id = 1:length(d.depth); %Tell COPRA how many dates you have

%fill in some metadata
d.samplename = 'samplename'; %name of sample you're working on
d.log = 'sample_date.log'; %name the log file
d.agename = 'yBP'; %unit of age
d.depthname = 'mm'; %unit of depth

%STEP 3: In Excel (or similar program) you need a list of depths
% where you have (or will have) proxy data, in order from smallest to
% largest. The proxy data goes in a second column. It can be fake, like all
% 1s, or it can be your real data. If you don't have proxy depths yet, you
% can make a file with fake depths from the top to the bottom every 1mm,
% for example. Note: if you have any missing data, type 'NaN' without
% quotes into that cell before you paste it.

%Paste your proxy depth + data as:
%proxies = [paste data];
%in the command window

d.d_prxy = proxies(:,1); %depth of proxy sample
d.v_prxy = proxies(:,2); %proxy data
d.proxyname = 'delta180'; %Tell COPRA what proxy it is
%  STEP 4: Put in fake (or real) layer count data. I have found that
% COPRA sometimes won't % % run unless you give it some kind of layer count
% data.
% Assuming you have fake data:
lc = ones(10,3); %create fake data
d.dlc.d_lc = lc(:,1); %fake depth
d.dlc.v_lc = lc(:,2); %fake value
d.dlc.e_lc = lc(:,3); %fake error

%If you have real data, paste the three columns in as DEPTH, LAYER NUM,
%ERROR IN DEPTH MEASUREMENT. lc = [paste data];, then run the three lines
%below lc = ones above. 

%Now COPRA has all the data it needs.
%This is a good time to save your script and your MATLAB workspace so that
%you don't have to copy and paste again if you lose your work. To save your
%workspace, right click on the workspace window (bottom left in the default
%setup) and click Save. Name it something like Samplename_date_copra.mat.
%in your MATLAB folder.
%% Check the dates
%Run this line, then follow the prompts in the Command Window. A plot of
%your dates will pop up automatically.
d = processages_cl(d);
%COPRA will give you some feedback about the dates. It might say that there
%are tractable or untractable reversals in your data. 
%If you have dates that don't work (see above warnings), I prefer to
%increase the errors rather than removing them, unless you know that
%there's a problem with the date. But in that case, you should not have
%included the date in STEP 1. Increase the errors until they appear to overlap
%within error.

%If you removed any dates, rerun this: 
d.id = 1:length(d.depth); %Tell COPRA how many dates you have

%% Run the MC Simulations
%Tell copra how many simulations to run. Start with a small number (10 -
%20) in case it runs very slowly. That suggests that your errors are too
%small, you need to remove a bad date, or there is some other problem. 

%NOTE: Once the MC simulations start, you won't be able to stop them
%without Force Quitting MATLAB and reloading your workspace, even if you
%try to end the modeling. That's why you should start with a small number
%of simulations. Once you know that it will run quickly (just a few
%seconds), you can increase the number. I usually run at least 1000.
d.M = 20; %how many simulations to run
%If you want to use layer counting, change the 0 --> 1. Otherwise, if
%you're using fake LC data, keep it as 0.
d.adinf = 0;

%Run this line to start the MC modeling (and remember the note above -
%start with only a few simulations!)
d = mcagemodels(d);
%Once the progress bar is full and COPRA returns the number of "reversed
%tries," it is done running. 

%% Plotting and extracting your models
%Get the median age model from all the simulations you ran:
avg=median(d.T_unc(:,3:end),2);%median age model
%This is your age-depth model result! If that's all you need, you can copy
%it by double clicking on the "avg" variable in your workspace and paste it
%into excel next to your list of depths.

%If you want to plot the age-depth model and/or get the 95% confidence
%bounds on your age model, continue to the next steps.

%AGE MODEL PLOT CODE

%We're going to make a plot with all the simulations COPRA generated, as
%well as the median age model and your original dates. It might take a few
%seconds to pop up if you ran 1000+ simulations. 
%NOTE: your dates will plot with increased error, if you increased it
%during the initial setup. If you want to plot them with their original
%error, uncomment and rerun this line:
%d.ageerror = 0.5.*c(:,3); %error on dates

figure(2);clf
for k=3:(d.M)
    plot(d.T_unc(:,k),d.d_prxy,'-','Color',[0 0 0]+((1/(d.M))*k));
    hold on
end
hold on
plot(avg,d.d_prxy,'-','LineWidth',2,'Color',[0.3922    0.5608    1.0]) %plot the median age model
plot(d.age, d.depth,'ok','MarkerSize',8,'MarkerFaceColor','k'); %plot your dates
plot((d.age+(2*d.ageerror)),d.depth,'o','MarkerSize',5,'MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor',[0.7 0.7 0/7])
plot((d.age-(2*d.ageerror)),d.depth,'o','MarkerSize',5,'MarkerFaceColor',[0.7 0.7 0.7], 'MarkerEdgeColor',[0.7 0.7 0/7])
set(gca,'FontSize',16)%make the font bigger so it looks nicer
%xlim([start, end]) %fill this in if you want to limit the plot
%ylim([start, end])
set(gca,'XDir','reverse') %make the axes plot in a reasonable way
set(gca,'YDir','reverse')
xlabel('Year BP') %or other unit of age
ylabel('Depth (mm)') %or other unit of depth


%% Model Extraction
%Now we are ready to look at and save the results of the age-depth
%modeling, including the 95% CI models.
allmodels = d.T_unc(:,3:end); %all the simulations generated
age95hi = mean(allmodels,2)+(2*std(allmodels,0,2)); %one column with the 95% CI - High boundary
age95lo=mean(allmodels,2)-(2*std(allmodels,0,2));%one column with the 95% CI - Low boundary
depths = d.d_prxy;
%HERE'S YOUR AGE-DEPTH MODEL:
%Structure: Depths, Median age model, 95% CI High bound, 95% CI Low bound
export = [depths,avg, age95hi, age95lo];
%Save this or copy it into your favorite spreadsheet program! 

%In case you want to plot the age model with the 95% CI bounds,and without
%all the other simulations you ran:

figure(3);clf
plot(avg,depths,'-','LineWidth',3,'Color',[0.3906    0.5820    0.9258])%plot median age model
hold on
plot(age95hi,depths,'--','Color',[0.1172    0.5625    1.0000])%plot bounds
plot(age95lo,depths,'--','Color',[0.1172    0.5625    1.0000])%plot bounds
plot(c(:,2),c(:,1),'.') %plot original dates
set(gca,'FontSize',30)
set(gca,'XDir','reverse')
set(gca,'YDir','reverse')
xlabel('Year BP')%or other unit
ylabel('Depth (mm)')%or other unit

%% Special cases:
%To come! 