renderSize = 256;
range = 10.245704621680851;

randc = @(varargin) (rand(varargin{:})-0.5)*2;

%% Setup Scene
fig = figure(...
	'DockControls','off',...
	'MenuBar','none',...
	'ToolBar','none',...
	'Position',[20,20,renderSize,renderSize]);
lookAt = [0.439595202235296,0.418548224382941,0.214556237970882]; % reference
az = 53.022518023091635;
el = -32.725744423969715;
lookFrom = lookAt - range*[cosd(az)*cosd(el),sind(az)*cosd(el),sind(el)];
lookAt = (lookAt - lookFrom) * rotz(-0.15) + lookFrom; % reassign, swinging it a bit
% fov = 7.044638696467704; % reference
fov = 8.0;
ax = axes('Parent',fig,...
	'Position',[0,0,1,1],...
	'Visible','off',...
	'Clipping','off',...
	'Projection','perspective',...
	'NextPlot','add');
detail = 100;
Z = membrane(1,detail);
Z = Z / max(Z(:));
width = 1.6;
surface(linspace(0,1,detail*2+1),linspace(0,1,detail*2+1),Z*0.888511126870776,...
	'EdgeColor','none',...
	'FaceColor',[0.9 0.2 0.2],...
	'FaceLighting','phong',...
	'SpecularStrength',1,...
	'SpecularExponent',7,...
	'parent',ax);
L1 = light('Position',[0.540595721631051,2.287938841300871,0.157529413499904],'Color',[0,0.8,0.8],'parent',ax,'Style','local');
plot3(L1.Position(1),L1.Position(2),L1.Position(3),'o','Parent',ax)
L2 = light('Position',[0.500310649013020,-1.068692401670806,0.398003746407270],'Color',[0.8,0.8,0],'parent',ax);
L3 = light('Position',[0.995551513751788,1.980629365934202,0.537818916897372],'Color',[0,0.8,0.8],'parent',ax,'Style','local');
axis(ax,[0,1,0,1,0,1]);
axis vis3d
rotate3d('on')

daspect(ax,[1,1,1])
set(ax,'CameraPosition',lookFrom,'CameraTarget',lookAt,'CameraUpVector',[0,0,1],'CameraViewAngle',fov)



paperThickness = 0.05;
contentsThickness = 0.02;
height = 5;
length = 8;
flapProportion = 0.5;
meshDetail = 100;
jitterScale = paperThickness * 0.02;
overallScale = 0.05;

% paperColor = [198,180,134]/255;
paperColor = [1,1,1]*0.9;

[V,F,C] = makeEnvelopeMesh(paperThickness,contentsThickness,height,length,flapProportion,meshDetail,jitterScale);

envelope = hgtransform('Parent',ax);
patch('Vertices',V*overallScale,'Faces',F,'FaceColor','flat','EdgeColor','none',...
	'FaceLighting','flat','DiffuseStrength',0.8,...
	'SpecularStrength',0.025,'SpecularExponent',300,...
	'AmbientStrength',0.8,...
	'FaceVertexCData',C,...
	'Parent',envelope);

%% Simulation

controlPoints = [
%   t,    x,       y,       z,    scale,    R,   P,    Y
	0.00, -0.5050, +0.5085, +0.00, 0.2, -4000,  -4,  -30;
	0.50, +0.3969, -0.0239, +0.15, 0.3, -1500, -20,   +0;
	0.85, +0.8929, +0.0452, +0.22, 0.5,  -400, -30,  +40;
	1.15, +1.0413, +0.4454, +0.30, 0.8,  +200, -32, +100;
	1.45, +0.8366, +0.8054, +0.40, 1.0,  +400, -25, +160;
	1.75, +0.5528, +0.9010, +0.50, 1.3,  +580, -20, +180;
	2.00, +0.1885, +0.6092, +0.70, 1.7,  +685, -17, +160;
];

interpX = griddedInterpolant(controlPoints(:,1),controlPoints(:,2),'spline');
interpY = griddedInterpolant(controlPoints(:,1),controlPoints(:,3),'spline');
interpZ = griddedInterpolant(controlPoints(:,1),controlPoints(:,4),'spline');
interPosition = @(t) [interpX(t);interpY(t);interpZ(t)];

interpScale = griddedInterpolant(controlPoints(:,1),controlPoints(:,5),'spline');

interpRoll  = griddedInterpolant(controlPoints(:,1),controlPoints(:,6),'spline');
interpPitch = griddedInterpolant(controlPoints(:,1),controlPoints(:,7),'spline');
interpYaw   = griddedInterpolant(controlPoints(:,1),controlPoints(:,8),'spline');

oversample = 10;
doRecord = false;
if doRecord
	frames = nan(renderSize,renderSize,3,oversample*2*60+1);
	frameInd = 1;
end
% for t = controlPoints(3,1)
for t = 0:1/60/oversample:2
	
	rotation = rotz(interpYaw(t)) * roty(interpPitch(t)) * rotx(interpRoll(t)) * rotz(180);
	rotation = interpScale(t) * rotation;
	envelope.Matrix(1:3,4) = interPosition(t);
	envelope.Matrix(1:3,1:3) = rotation;
	drawnow;
	
	if doRecord
		frameData = getframe(fig);
		frames(:,:,:,frameInd) = double(frameData.cdata);
		frameInd = frameInd + 1;
	end
	
end

%%
if doRecord
	
	figure;
	image(uint8(max(frames,[],4)))
	
end

return
%%
close all

%%
commandwindow
