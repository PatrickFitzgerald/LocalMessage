paperThickness = 0.03*10;
contentsThickness = 0.05*10;
height = 5;
length = 8;
flapProportion = 0.7;
meshDetail = 100;
jitterScale = paperThickness * 0.05;

% paperColor = [198,180,134]/255;

[V,F,C] = makeEnvelopeMesh(paperThickness,contentsThickness,height,length,flapProportion,meshDetail,jitterScale);

clf
% patch('Vertices',V,'Faces',F,'FaceColor','r','FaceAlpha',0.3);
patch('Vertices',V,'Faces',F,'FaceColor','flat','EdgeColor','none',...
	'FaceLighting','flat','DiffuseStrength',1,...
	'SpecularStrength',0.05,'SpecularExponent',300,...
	'FaceVertexCData',C);
daspect([1,1,1])
axis vis3d
set(gca,'Visible','off')
rotate3d('on')

light('Position',[rand(1,2),4],'Color',[1,1,1],'Style','local')