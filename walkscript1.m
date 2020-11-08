% This is a sample script for communicating with a ROS master node via
% MATLAB. This script was originally written to communicate with a PC running a
% simulation of the DARwiN-OP robot in Gazebo using ROS. 

% The simulation comes from 
% https://www.generationrobots.com/en/content/83-carry-out-simulations-and-make-your-darwin-op-walk-with-gazebo-and-ros

% Before running the script, launch Gazebo and ensure that the ROS topics
% referenced below (e.g., /darwin/imu) are available, by opening a terminal
% and typing 'rostopic list'. Also, be sure to click the 'Play' button in 
% Gazebo, so that the simulator is running, before running this script. 

%****NOTE: you must change the line below to the IP address for YOUR ROS master!****
ipaddress = 'http://10.4.155.40:11311'; % IP address of ROS master

% --- Start MATLAB Global Node  
try % try to print list of ROS nodes
    rosnode list
    clc
catch exp   % if error from rosnode list, initialize ROS global node from MATLAB
    rosinit(ipaddress)  % only if error: rosinit
    pause(5)
end
% MATLAB global node initialized

%% Create ROS publishers and message structures

% Publisher to command velocity ROS topic
walk = rospublisher('/darwin/cmd_vel','geometry_msgs/Twist'); 

% Publishers to ROS topics for left, right upper arm joint commands
Larm = rospublisher('/darwin/j_high_arm_l_position_controller/command','std_msgs/Float64'); 
Rarm = rospublisher('/darwin/j_high_arm_r_position_controller/command','std_msgs/Float64');

% Create ROS messages to publishers
Ldown = rosmessage(Larm);
Rdown = rosmessage(Rarm);
Ldown2 = rosmessage(Larm);
Rdown2 = rosmessage(Rarm);

fore = rosmessage(walk);
left = rosmessage(walk);
right = rosmessage(walk);
back = rosmessage(walk);
stop = rosmessage(walk);

%% Add message info to already-created message structures:

% move upper arm joint to 0.5 radian
Ldown.Data = 0.5;
Rdown.Data = 0.5;

% move upper arm joint to 0.8 radian
Ldown2.Data = 0.8;
Rdown2.Data = 0.8;

% forward walk:
fore.Linear.X = 1; fore.Linear.Y = 0; fore.Linear.Z = 0; 
fore.Angular.X = 0; fore.Angular.Y = 0; fore.Angular.Z = 0;

% backward walk:
back.Linear.X = -1; back.Linear.Y = 0; back.Linear.Z = 0; 
back.Angular.X = 0; back.Angular.Y = 0; back.Angular.Z = 0;

% come to stop:
stop.Linear.X = 0; stop.Linear.Y = 0; stop.Linear.Z = 0; 
stop.Angular.X = 0; stop.Angular.Y = 0; stop.Angular.Z = 0;


%% Send messages (i.e., motion commands) with pauses between

% move arms to 0.5 radian during two-second period, then to 0.8 radian
% during another two-second period (arms move synchronously)
send(Larm,Ldown);
send(Rarm,Rdown);
pause(2) 
send(Larm,Ldown2);
send(Rarm,Rdown2);
pause(2)

% walk forward for ten seconds
send(walk,fore)
pause(10);

% stop for three seconds
send(walk,stop);
pause(3);

% shut down ROS node
rosshutdown
