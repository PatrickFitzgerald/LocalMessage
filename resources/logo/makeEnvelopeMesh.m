function [V_,F_,C_] = makeEnvelopeMesh(paperThickness,contentsThickness,height,length,flapProportion,meshDetail,jitterScale)
	
	% Some shorthands
	Tp = paperThickness;
	Tc = contentsThickness;
	H = height;
	L = length;
	N = meshDetail;
	
	% Storage
	global V F C
	V = nan(0,3);
	F = nan(0,3);
	C = nan(0,3);
	
	hsv = [0.116658156330941   0.011573031036346;... % hue: mu, stdev 
		   0.309571015497010   0.037524568545566;... % saturation: mu, stdev
		   0.774478030505829   0.029509105525550];   % value: mu, stdev
	
	% Prep bookkeeping
	rIn = Tc / 2;
	rOut = rIn + Tp;
	rPaper = Tp/2; % radius of paper alone
	
	% Front and back flat faces
	Hflat = H - 2*rOut;
	Lflat = L - 2*rOut;
	includeWithJitter([ [-1;-1;1;1]*Lflat/2, [-1;1;1;-1]*Hflat/2, +ones(4,1)*(Tc/2+Tp)],  4*N^2, jitterScale,hsv)
	includeWithJitter([ [-1;-1;1;1]*Lflat/2, [-1;1;1;-1]*Hflat/2, -ones(4,1)*(Tc/2+Tp)],  4*N^2, jitterScale,hsv)
	
	% rounded bottom edges
	angle_rad = linspace(pi/2,-pi/2,N*2+1);
	z = sin(angle_rad) * rOut;
	q = cos(angle_rad) * rOut; % how far outside the flat region we are (perpendicular)
	x = +Lflat/2 + q; % will be +/-
	y = -Hflat/2 - q;
	for ind = 1:2*N
		include([...
			[-x(ind+1);-x(ind+0);+x(ind+0);+x(ind+1)],...
			[ y(ind+1); y(ind+0); y(ind+0); y(ind+1)],...
			[ z(ind+1); z(ind+0); z(ind+0); z(ind+1)]...
		],hsv)
	end
	
	% rounded left edges
	angle_rad = linspace(pi/2,-pi/2,N*2+1);
	z = sin(angle_rad) * rOut;
	q = cos(angle_rad) * rOut; % how far outside the flat region we are (perpendicular)
	x = -Lflat/2 - q;
	y = +Hflat/2 + q; % will be +/-
	for ind = 1:2*N
		include([...
			[ x(ind+1); x(ind+0); x(ind+0); x(ind+1)],...
			[+y(ind+1);+y(ind+0);-y(ind+0);-y(ind+1)],...
			[ z(ind+1); z(ind+0); z(ind+0); z(ind+1)]...
		],hsv)
	end
	
	% rounded right edges
	angle_rad = linspace(pi/2,-pi/2,N*2+1);
	z = sin(angle_rad) * rOut;
	q = cos(angle_rad) * rOut; % how far outside the flat region we are (perpendicular)
	x = +Lflat/2 + q;
	y = +Hflat/2 + q; % will be +/-
	for ind = 1:2*N
		include([...
			[ x(ind+1); x(ind+0); x(ind+0); x(ind+1)],...
			[+y(ind+1);+y(ind+0);-y(ind+0);-y(ind+1)],...
			[ z(ind+1); z(ind+0); z(ind+0); z(ind+1)]...
		],hsv)
	end
	
	% rounded back half of top bend
	angle_rad = linspace(0,-pi/2,N+1);
	z = sin(angle_rad) * rOut;
	q = cos(angle_rad) * rOut; % how far outside the flat region we are (perpendicular)
	x = +Lflat/2 + q; % will be +/-
	y = +Hflat/2 + q;
	for ind = 1:N
		include([...
			[-x(ind+1);-x(ind+0);+x(ind+0);+x(ind+1)],...
			[ y(ind+1); y(ind+0); y(ind+0); y(ind+1)],...
			[ z(ind+1); z(ind+0); z(ind+0); z(ind+1)]...
		],hsv)
	end
	
	% top flat bit, middle of bend
	include([[-1;-1;1;1]*L/2,ones(4,1)*H/2,[0;1;1;0]*Tp],hsv)
	
	% rounded front half of top bend
	angle_rad = linspace(pi/2,0,N+1);
	z = sin(angle_rad) * rOut + Tp;
	q = cos(angle_rad) * rOut; % how far outside the flat region we are (perpendicular)
	x = +Lflat/2 + q; % will be +/-
	y = +Hflat/2 + q;
	for ind = 1:N
		include([...
			[-x(ind+1);-x(ind+0);+x(ind+0);+x(ind+1)],...
			[ y(ind+1); y(ind+0); y(ind+0); y(ind+1)],...
			[ z(ind+1); z(ind+0); z(ind+0); z(ind+1)]...
		],hsv)
	end
	
	% Front lip
	includeWithJitter([[-1;0;1]*Lflat/2,[0.5;0.5-flapProportion;0.5]*Hflat,ones(3,1)*(Tc/2+Tp*2)],  N^2, jitterScale,hsv)
	
	% Front lip rounded edge
	angle_rad = linspace(pi/2,-pi/2,N*2+1);
	z = sin(angle_rad) * rPaper - rPaper + Tc/2+Tp*2;
	q = cos(angle_rad) * rPaper; % how far outside the flat region we are (perpendicular)
	xC = zeros(size(angle_rad)); % x center
	yC = (0.5-flapProportion)*Hflat - sqrt(2) * q;
	xR = Lflat/2 * ones(size(angle_rad)); % will be +/-
	yR = Hflat/2 - sqrt(2) * q;
	for ind = 1:2*N
		if ind > 2*0.1*N % Color the bottom darker
			hsvTemp = hsv .* [1,1;1,1;0.2,0.2];
		else
			hsvTemp = hsv;
		end
		
		include([... % left
			[-xR(ind+1);-xR(ind+0); xC(ind+0); xC(ind+1)],...
			[ yR(ind+1); yR(ind+0); yC(ind+0); yC(ind+1)],...
			[  z(ind+1);  z(ind+0);  z(ind+0);  z(ind+1)]...
		],hsvTemp)
		include([... % right
			[ xC(ind+1); xC(ind+0); xR(ind+0); xR(ind+1)],...
			[ yC(ind+1); yC(ind+0); yR(ind+0); yR(ind+1)],...
			[  z(ind+1);  z(ind+0);  z(ind+0);  z(ind+1)]...
		],hsvTemp)
	end
	
	
	
	
	% Unique to condense vertices down
	[V_,~,b] = unique(V,'rows');
	F_ = b(F);
	C_ = C;
	
end

function include(faceVerts,hsv) % Turns all to triangles
	
	global V F C 
	
	sizeVold = size(V,1);
	sizeVadd = size(faceVerts,1);
	appendInds = sizeVold + (1:sizeVadd);
	V(appendInds,:) = faceVerts;
	
	numTriangles = sizeVadd-2;
	F(end+(1:numTriangles),:) = appendInds( [ones(numTriangles,1),(1:numTriangles)'+1,(1:numTriangles)'+2]);
	% appendInds(1,2,3)
	% appendInds(1,3,4)
	% appendInds(1,4,5)
	% etc
	
	C(end+(1:numTriangles),:) = makeColors(hsv,numTriangles);
	
end

function C = makeColors(hsv,num)
	
	H = hsv(1,1) + hsv(1,2) * rand(num,1);
	S = hsv(2,1) + hsv(2,2) * rand(num,1);
	V = hsv(3,1) + hsv(3,2) * rand(num,1);
	
	C = hsv2rgb(bound01(cat(2,H,S,V)));
	
end

function vals = bound01(vals)
	vals = max(min(vals,1),0);
end

function includeWithJitter(faceVerts,N,jitterScale,hsv)
	
	global V F C
	
	numTriangles = size(faceVerts,1)-2;
	individualN = max(ceil(sqrt(N / numTriangles)),2);
	[uPoints,vPoints] = ndgrid(linspace(0,1,individualN+1));
	
	microFacetList = nan(0,3);
	for addTerm = 0:individualN+1:(individualN+1)*(individualN-1)
		microFacetList = cat(1,microFacetList,...
			bsxfun(@plus,[1,2,individualN+2],(0:individualN-1)') + addTerm,...
			bsxfun(@plus,[individualN+2,individualN+3,2],(0:individualN-1)') + addTerm );
	end
	wPoints = 1-uPoints-vPoints;
	keep = wPoints >= -1e5*eps() ;
	R = [uPoints(keep),vPoints(keep),wPoints(keep)];
	microFacetList = microFacetList(all(keep(microFacetList),2),:);
	temp = cumsum(keep(:));
	microFacetList = temp(microFacetList);
	
	p1 = faceVerts(1,:);
	allPoints = nan(0,3);
	allScales = nan(0,1);
	allFacets = nan(0,3);
	for triangleInd = 1:numTriangles
		p2 = faceVerts(triangleInd+1,:);
		p3 = faceVerts(triangleInd+2,:);
		densePoints = R * [p1;p2;p3];
		doJitter = (R(:,3)~=0); % Not on far edge
		if triangleInd == 1 % first
			doJitter = bsxfun(@times,doJitter,(R(:,1)~=0)); % and not on left edge
		end
		if triangleInd == numTriangles % last
			doJitter = bsxfun(@times,doJitter,(R(:,2)~=0)); % and not on right edge
		end
		lastSize = size(allPoints,1);
		allPoints = cat(1,allPoints,densePoints);
		allScales = cat(1,allScales,doJitter);
		allFacets = cat(1,allFacets,microFacetList + lastSize);
	end
	
	% Make all points unique
	[allPoints,a,b] = unique(allPoints,'rows');
	allFacets = b(allFacets);
	allScales = allScales(a);
	
	normalVector = cross(p2-p1,p3-p1); % Should all be the same, use the last p1,p2,p3
	normalVector = normalVector / norm(normalVector);
	
	jitteredPoints = allPoints + bsxfun(@times,normalVector,allScales .* jitterScale .* randn(size(allScales)));
	
	
	
	% add to list
	
	sizeVold = size(V,1);
	sizeVadd = size(jitteredPoints,1);
	appendInds = sizeVold + (1:sizeVadd);
	V(appendInds,:) = jitteredPoints;
	numFacets = size(allFacets,1);
	F(end+(1:numFacets),:) = allFacets + sizeVold;
	
	C(end+(1:numFacets),:) = makeColors(hsv,numFacets);
	
end