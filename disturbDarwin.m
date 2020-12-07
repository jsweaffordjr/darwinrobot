function output = disturbDarwin(disturb,disturbmsg,bodypart,forceX,forceY,forceZ,duration)
% this function applies a disturbing force to the Darwin robot in Gazebo simulation

% inputs: 
% if bodypart equals 1: disturbance applied to COM of head, 
% otherwise: disturbance applied to COM of torso
% forceX: disturbing force component acting in direction parallel to world X-axis
% forceY: disturbing force component acting in direction parallel to world Y-axis
% forceZ: disturbing force component acting in direction parallel to world Z-axis
% duration: in seconds, assuming force doesn't act longer than one second

% the following lines should have been executed when simulation began: 
% disturb = rossvcclient('/gazebo/apply_body_wrench');
% disturbmsg = rosmessage(disturb);
% disturbmsg.ReferenceFrame = 'world';
% disturbmsg.ReferencePoint.X = 0; disturbmsg.ReferencePoint.Y = 0; disturbmsg.ReferencePoint.Z = 0;
% disturbmsg.Wrench.Force.X = 0.0; disturbmsg.Wrench.Force.Y = 0.0; disturbmsg.Wrench.Force.Z = 0.0;
% disturbmsg.Wrench.Torque.X = 0.0; disturbmsg.Wrench.Torque.Y = 0.0; disturbmsg.Wrench.Torque.Z = 0.0;
% disturbmsg.StartTime.Sec = 0; disturbmsg.StartTime.Nsec = 0;
% disturbmsg.Duration.Sec = 0; disturbmsg.Duration.Nsec = 0;

% so, variables for ROS client and message ('disturb', 'disturbmsg') should already be in Workspace

% assign name of desired robot link to which disturbing force will be applied
if bodypart == 1
    disturbmsg.BodyName = 'darwin::MP_HEAD';
else
    disturbmsg.BodyName = 'darwin::base_link';
end

% update disturbing force components (assuming disturbing torque = 0)
disturbmsg.Wrench.Force.X = forceX; 
disturbmsg.Wrench.Force.Y = forceY; 
disturbmsg.Wrench.Force.Z = forceZ;

% determine duration of application of disturbing force
if duration >= 1
    disturbmsg.Duration.Sec = 1;
    disturbmsg.Duration.Nsec = 0;
else
    disturbmsg.Duration.Sec = 0;
    disturbmsg.Duration.Nsec = round((1e9)*duration);
end

% request disturbing force to be applied as described by inputs
answer = call(disturb,disturbmsg,'Timeout',3);
output = answer.Success;

end

