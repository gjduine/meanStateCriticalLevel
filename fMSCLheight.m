function [zMeanStateHgt]=fMSCLheight(frHgt,hgt_st,V,z)
% function to compute the Mean State Critical Level (MSCL) from vertical 
% profiles of wind
% a MSCL is defined at the the level where the winds 
% perpendicular to mountain range drops to zero
% So, these winds need to be orientated on an axis perpendicular to the mountain 
% range downstream  of the vertical profile to be able to find a MSCL 
% e.g., 
% for a west-east oriented mountain range located south of the vertical profile, the
% northerly winds should drop to zero. The actual elevation of the MSCL is 
% then found by vertical interpolation between the adjacent levels
%
% the function checks for negative winds at a ridgelevel height and then
% looks upwards where the negative wind turns positive. This means that the
% MSCL height has been passed, and so the next step is an interpolation
% between the two levels (above and below the MSCL heights) to find the
% actual height. 
% 
% Gert-Jan Duine, ERI UC Santa Barbara, duine@eri.ucsb.edu
% v1: September 2024
% 
% output: 
% zMeanStateHgt      : MSCL height in m MSL (or other height units, user-defined)
%
% input:
% frHgt [m MSL]      : the elevation of the downstream mountain relative to
% the terrain elevation of the vertical profile elevation
% hgt_st [m MSL]     : terrain elevation of the vertical profile location
% V [wind speed unit]: wind compoment perpendicular to mountain range
% z [m]              : height coordinates of the vertical profiles

dimT=size(V,2); % time dimension
zMeanStateHgt=NaN(1,dimT); % if no MSCL height, there will be a NaN

for t=1:size(V,2) % for each time step, execute the following to find MSCL height

    iFr=find(z(:,t)>frHgt,1,'first'); % index relative to see at what level the ridgelevel is reached. because z is time-dependent, we do this in time loop.
    % variables related to MSCL from here
    
    if all(V(:,t)>0) 	% if all values are positive (i.e., south-winds for SYM), forget the profile
        allPos(t)=NaN; % this is a dummy for now
    elseif all(V(:,t)<0) % if all negative, could check for forward or backward shear
        allNeg(t)=NaN; % this is a dummy for now
        
    elseif (V(iFr+1,t)<0) % check whether a 'ridgelevel' is negative, then ...
        zInd(t)=find(V(:,t)>0,1,'first'); % check what indice (model level) V becomes postive

        if zInd(t)<iFr % exception for levels lower than ridgelevel --> need to make this to froude level???
            if all(V(iFr+1:end,t)>0) % do again a check for all model levels positive or negative
                allPos(t)=NaN;
                zInd(t)=NaN;
                zMeanStateHgt(t)=NaN;
            elseif all(V(iFr+1:end,t)<0)
                allNeg(t)=NaN;
                zInd(t)=NaN;
                zMeanStateHgt(t)=NaN;
            else
                zInd(t)=find(V(iFr+1:end,t)>0,1,'first')+iFr; % 
            end
        end

        if ~isnan(zInd(t)) % interpolation procedure
            % then linearly interpolate the zInd to the real level above sea level
            zMeanStateHgt(t)=( (0-V(zInd(t)-1,t))./(V(zInd(t),t)-V(zInd(t)-1,t)) ...
                .* (z(zInd(t),t)-z(zInd(t)-1,t)) + z(zInd(t)-1,t) ) +hgt_st;
        end
    end
end