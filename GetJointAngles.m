function angles = GetJointAngles(pfn,afn,params,phase,x,velocity)
% this function computes joint angles for a given phase, cycle position
% (0 <= x <= 1), and velocity parameters

    % find joint angle functions for walking in place:
    j = fieldnames(pfn);
    angles = zeros(length(j),1);
    for i = 1:length(j)
        if phase
           a = pfn.(j{i}).offset;
           b = pfn.(j{i}).scale;
           c = pfn.(j{i}).in_offset;
           d = pfn.(j{i}).in_scale;
        else
           a = afn.(j{i}).offset;
           b = afn.(j{i}).scale;
           c = afn.(j{i}).in_offset;
           d = afn.(j{i}).in_scale;
        end
        angles(i) = a + b*sin(c + d*x);
    end
    % modify joint angle function for walking to move with desired velocity:
    vx = velocity(1)*params.vx_scale;
    vy = velocity(2)*params.vy_scale;
    vt = velocity(3)*params.vt_scale;

    dx = (2*x - 1)*vx;
    dy1 = x*vy;
    dy2 = (1 - x)*vy;
    dt1 = x*vt;
    dt2 = (1 - x)*vt;
    
    if phase
       angles(5) = angles(5) + dx;
       angles(6) = angles(6) + dx;
       angles(8) = angles(8) + dx;
       angles(9) = angles(9) + dx;
       
       if vy >= 0
          angles(2) = angles(2) - dy1;
          angles(1) = angles(1) - dy1;
          angles(4) = angles(4) + dy1;
          angles(3) = angles(3) + dy1;           
       else
          angles(2) = angles(2) + dy2;
          angles(1) = angles(1) + dy2;
          angles(4) = angles(4) - dy2;
          angles(3) = angles(3) - dy2;   
       end
       
       if vt >= 0 
          angles(11) = -dt1;
          angles(12) = dt1;
       else
          angles(11) = dt2;
          angles(12) = -dt2;  
       end
       
    else
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

