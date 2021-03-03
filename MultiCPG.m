function [pfn,afn,params] = MultiCPG(prevparams)
% this function creates structures containing phase, antiphase function parameters to
% produce multiple CPGs for various joints for a walker stepping in place
    
    if ~isempty(prevparams) % if parameters are provided,
        % they will be used as default parameters
        swing_scale = prevparams.swing_scale;
        step_scale = prevparams.step_scale;
        step_offset = prevparams.step_offset;
        ankle_offset = prevparams.ankle_offset;
        vx_scale = prevparams.vx_scale;
        vy_scale = prevparams.vy_scale;
        vt_scale = prevparams.vt_scale;
    else % otherwise, the following are default parameters
        swing_scale = 0;
        step_scale = 0.3;
        step_offset = 0.55;
        ankle_offset = 0;
        vx_scale = 0.5;
        vy_scale = 0.5;
        vt_scale = 0.7;
    end
    
    % output 'params' contains the parameters set above
    params.swing_scale = swing_scale;
    params.step_scale = step_scale;
    params.step_offset = step_offset;
    params.ankle_offset = ankle_offset;
    params.vx_scale = vx_scale;
    params.vy_scale = vy_scale;
    params.vt_scale = vt_scale;
    
    % generate CPGs, based on code from tutorial at:
    % https://www.generationrobots.com/en/content/83-carry-out-simulations-and-make-your-darwin-op-walk-with-gazebo-and-ros
    f1 = SingleCPG([],-swing_scale,[],pi);
    f2 = MirrorSingleCPG(f1);
    f3 = SingleCPG(step_offset,step_scale,[],pi);
    f33 = MirrorSingleCPG(f3);
    f33.offset = f33.offset + ankle_offset;
    f4 = MirrorSingleCPG(f3);
    f4.offset = 2*f4.offset;
    f4.scale = 2*f4.scale;
    f5 = f3; 
    f5.in_scale = 2*f5.in_scale;
    f5.scale = 0;
    f6 = MirrorSingleCPG(f3);
    f6.in_scale = 2*f6.in_scale;
    f6.scale = f5.scale;
    f6.offset = f6.offset + ankle_offset;
    f7 = f4;
    f7.scale = 0;
    f8 = SingleCPG(0,0,0,0);
    
    % sine generation structures for 'phase'
    pfn.Lankle2 = f1; % left frontal ankle
    pfn.Lhip1 = f1; % left frontal hip
    pfn.Rankle2 = MirrorSingleCPG(f2); % right frontal ankle
    pfn.Rhip1 = MirrorSingleCPG(f2); % right frontal hip
    pfn.Lhip2 = f3; % left sagittal hip
    pfn.Lankle1 = f33; % left sagittal ankle
    pfn.Lknee = f4; % left knee
    pfn.Rhip2 = MirrorSingleCPG(f5); % right sagittal hip
    pfn.Rankle1 = MirrorSingleCPG(f6); % right sagittal ankle
    pfn.Rknee = MirrorSingleCPG(f7); % right knee
    
    % sine generation structures for 'antiphase'
    afn.Lankle2 = f2; % mirror of right frontal ankle in 'phase'
    afn.Lhip1 = f2; % mirror of right frontal hip in 'phase'
    afn.Rankle2 = MirrorSingleCPG(f1); % mirror of left frontal ankle in 'phase'
    afn.Rhip1 = MirrorSingleCPG(f1); % mirror of left frontal hip in 'phase'
    afn.Lhip2 = f5; % mirror of right sagittal hip in 'phase'
    afn.Lankle1 = f6; % mirror of right sagittal ankle in 'phase'
    afn.Lknee = f7; % mirror of right knee in 'phase'
    afn.Rhip2 = MirrorSingleCPG(f3); % mirror of left sagittal hip in 'phase'
    afn.Rankle1 = MirrorSingleCPG(f33); % mirror of left sagittal hip in 'phase'
    afn.Rknee = MirrorSingleCPG(f4); % mirror of left knee in 'phase'

    pfn.Lhip3 = f8; % left transverse hip (phase)
    afn.Lhip3 = MirrorSingleCPG(f8); % left transverse hip (antiphase)
    pfn.Rhip3 = f8; % right transverse hip (phase)
    afn.Rhip3 = MirrorSingleCPG(f8); % right transverse hip (antiphase)
end

function waveparams = SingleCPG(offset,scale,in_offset,in_scale)
% this subfunction creates a structure containing parameters
% sine function-based CPG.
% sine function: theta = a + b*sin(c + d*x)
% where a = offset, b = scale, c = in_offset, d = in_scale

    % set 'offset' parameter to zero, if no offset is given
    if ~isempty(offset)
        waveparams.offset = offset;
    else
        waveparams.offset = 0;
    end

    % set 'scale' parameter to one, if no scale is given
    if ~isempty(scale)
        waveparams.scale = scale;
    else
        waveparams.scale = 1;
    end

    % set 'in_offset' parameter to zero, if no in_offset is given
    if ~isempty(in_offset)
        waveparams.in_offset = in_offset;
    else
        waveparams.in_offset = 0;
    end

    % set 'in_scale' parameter to one, if no in_scale is given
    if ~isempty(in_scale)
        waveparams.in_scale = in_scale;
    else
        waveparams.in_scale = 1;
    end


end

function waveparams = MirrorSingleCPG(f1)
% this subfunction creates a structure of a mirror CPG of the
% CPG represented by the inputted parameters

    % mirroring is implemented by multiplying 'offset' and 'scale' by -1
    waveparams.offset = -f1.offset;
    waveparams.scale = -f1.scale;
    waveparams.in_offset = f1.in_offset;
    waveparams.in_scale = f1.in_scale;

end
