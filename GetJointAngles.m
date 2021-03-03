function angles = GetJointAngles(pfn,afn,params,phase,x,velocity)
% this function computes joint angles for a given phase (0 or 1), cycle position
% (0 <= x <= 1), and velocity parameters

%% find joint angle functions for walking in place:
    j = fieldnames(pfn); % array of joint names
    angles = zeros(length(j),1); % initialize joint angles at zero
    for i = 1:length(j)
        % for each joint, set parameters based on phase
        if phase % if robot is in 'phase', use 'phase' parameters for each joint
           a = pfn.(j{i}).offset;
           b = pfn.(j{i}).scale;
           c = pfn.(j{i}).in_offset;
           d = pfn.(j{i}).in_scale;
        else % if robot is in 'antiphase', use 'antiphase' parameters for each joint
           a = afn.(j{i}).offset;
           b = afn.(j{i}).scale;
           c = afn.(j{i}).in_offset;
           d = afn.(j{i}).in_scale;
        end
        % compute desired position for joint 'i', 
        % based on parameters (a,b,c,d) and cycle position x:
        angles(i) = a + b*sin(c + d*x); 
    end
    % modify joint angle function (for walking) to move with desired velocity:
    vx = velocity(1)*params.vx_scale; % for stepping forward/backward (forward-facing)
    vy = velocity(2)*params.vy_scale; % for stepping sideways, left/right (forward-facing)
    vt = velocity(3)*params.vt_scale; % for stepping so as to change body orientation

    % compute terms to add to 'stepping-in-place' desired joint angles to
    % achieve nonzero body velocity during gait
    dx = (2*x - 1)*vx;
    dy1 = x*vy;
    dy2 = (1 - x)*vy;
    dt1 = x*vt;
    dt2 = (1 - x)*vt;
    
    if phase
       % add 'dx' term to sagittal joints for forward/backward gait
       angles(5) = angles(5) + dx; % left sagittal hip
       angles(6) = angles(6) + dx; % left sagittal ankle
       angles(8) = angles(8) + dx; % right sagittal ankle
       angles(9) = angles(9) + dx; % right sagittal ankle
        
       % for left/right (forward-facing) gait
       if vy >= 0
          % add/subtract 'dy1' term to/from frontal joints 
          angles(2) = angles(2) - dy1; % left frontal hip
          angles(1) = angles(1) - dy1; % left frontal ankle
          angles(4) = angles(4) + dy1; % right frontal hip
          angles(3) = angles(3) + dy1; % right frontal ankle          
       else
          % add/subtract 'dy2' term to/from frontal joints  
          angles(2) = angles(2) + dy2;
          angles(1) = angles(1) + dy2;
          angles(4) = angles(4) - dy2;
          angles(3) = angles(3) - dy2;   
       end
       
       % set transverse hip angles to positive/negative 'dt1' or 'dt2'
       % based on desired turn direction
       if vt >= 0 
          angles(11) = -dt1;
          angles(12) = dt1;
       else
          angles(11) = dt2;
          angles(12) = -dt2;  
       end
       
    else % antiphase computations:
       angles(5) = angles(5) - dx;
       angles(6) = angles(6) - dx;
       angles(8) = angles(8) - dx;
       angles(9) = angles(9) - dx; 
       
       if vy >= 0
          angles(2) = angles(2) - dy2;
          angles(1) = angles(1) - dy2;
          angles(4) = angles(4) + dy2;
          angles(3) = angles(3) + dy2;           
       else
          angles(2) = angles(2) + dy1;
          angles(1) = angles(1) + dy1;
          angles(4) = angles(4) - dy1;
          angles(3) = angles(3) - dy1;   
       end

       if vt >= 0 
          angles(11) = -dt2;
          angles(12) = dt2;
       else
          angles(11) = dt1;
          angles(12) = -dt1;  
       end
    end
end

