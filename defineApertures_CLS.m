function RING = defineApertures_CLS(RING)
	
	% Define physical aparture % % % % % % % % % % % % % % % % % % % % % %
	apVal = 0.005;   % Radius of aparture (general)
	apCavVal = 0.003;   % Radius of aparture in bends 
	% => just to have something difffent somewhere

	% Find all elements which have not 'IdentityPass'
	ordAll = setdiff(1:length(RING),findcells(RING,'PassMethod','IdentityPass'));

	ordCav = SCgetOrds(RING,'CAV');

	% Set large elliptical apertures in lattice structure
	RING = setcellstruct(RING,'EApertures'  ,ordAll,	num2cell(repmat( [apVal apVal], length(ordAll),1) ,2)  ,1     ,1:2);

	% Set small elliptical apertures in BEND magnets
	RING = setcellstruct(RING,'EApertures'  ,ordCav,	 [apCavVal apCavVal]  ,1     ,1:2);


end
