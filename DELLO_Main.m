%% TODO
% 1. Save the Eroded brain Mask OK
% 2. Sort the corr along x axis
% 3. Add slide bar click button OK
% 4. Make the axis yoked slide bars
% 5. Make Review board
% 6. Add get current corr to the left slide bar
% 7. Add type in current corr (kind of manual mode)
% 8. MNI coordinates
% 9. Review board slices % set(gca, 'XDir','reverse')  Left and right issue
% 10. Review board 3D MNI brain
%%
clear
cd('D:\DELLO_data\dengshengyang')
LocH = DELLO_loc;
LocH.getInput;
LocH.getPrep;
LocH.getThreshCT
LocH.getLocateAuto
% 
LocH.getWriteRes



