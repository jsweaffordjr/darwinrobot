function [pfn,afn,params] = MultiCPG(prevparams)
% this function creates structures containing phase, antiphase function parameters to
% produce multiple CPGs for various joints for a walker stepping in place
    
    if ~isempty(prevparams)
        swing_scale = prevparams.swing_scale;
        step_scale = prevparams.step_scale;
        step_offset = prevparams.step_offset;
        ankle_offset = prevparams.ankle_offset;
        vx_scale = prevparams.vx_scale;
        vy_scale = prevparams.vy_scale;
        vt_scale = prevparams.vt_scale;
    else
        swing_scale = 0;
        step_scale = 0.3;
        step_offset = 0.55;
        ankle_offset = 0;
        vx_scale = 0.5;
        vy_scale = 0.5;
        vt_scale = 0.4;
    end
    
    params.swing_scale = swing_scale;
    params.step_scale = step_scale;
    params.step_offset = step_offset;
    params.ankle_offset = ankle_offset;
    params.vx_scale = vx_scale;
    params.vy_scale = vy_scale;
    params.vt_scale = vt_scale;
    
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
    
    pfn.Lankle2 = f1;
    pfn.Lhip1 = f1;
    pfn.Rankle2 = MirrorSingleCPG(f2);
    pfn.Rhip1 = MirrorSingleCPG(f2);
    pfn.Lhip2 = f3;
    pfn.Lankle1 = f33;
    pfn.Lknee = f4;
    pfn.Rhip2 = MirrorSingleCPG(f5);
    pfn.Rankle1 = MirrorSingleCPG(f6);
    pfn.Rknee = MirrorSingleCPG(f7);
    
    afn.Lankle2 = f2;
    afn.Lhip1 = f2;       
    afn.Rankle2 = MirrorSingleCPG(f1);
    afn.Rhip1 = MirrorSingleCPG(f1);
    afn.Lhip2 = f5;
    afn.Lankle1 = f6;  
    afn.Lknee = f7;
    afn.Rhip2 = MirrorSingleCPG(f3);
    afn.Rankle1 = MirrorSingleCPG(f33);
    afn.Rknee = MirrorSingleCPG(f4);

    pfn.Lhip3 = f8;
    afn.Lhip3 = MirrorSingleCPG(f8);
    pfn.Rhip3 = f8;
    afn.Rhip3 = MirrorSingleCPG(f8);
end

function waveparams = SingleCPG(offset,scale,in_offset,in_scale)
% this function creates a structure containing parameters for a sine wave
% to use for CPGs. 

    if ~isempty(offset)
        waveparams.offset = offset;
    else
        waveparams.offset = 0;
    end

    if ~isempty(scale)
        waveparams.scale = scale;
    else
        waveparams.scale = 1;
    end

    if ~isempty(in_offset)
        waveparams.in_offset = in_offset;
    else
        waveparams.in_offset = 0;
    end

    if ~isempty(in_scale)
        waveparams.in_scale = in_scale;
    else
        waveparams.in_scale = 1;
    end


end

function waveparams = MirrorSingleCPG(f1)
% this function creates a structure of a mirror CPG of the
% CPG represented by the inputted parameters

    waveparams.offset = -f1.offset;
    waveparams.scale = -f1.scale;
    waveparams.in_offset = f1.in_offset;
    waveparams.in_scale = f1.in_scale;

end
