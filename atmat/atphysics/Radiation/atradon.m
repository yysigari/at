function [ring,radelemIndex,cavitiesIndex,energy]=atradon(ring1,varargin)
%ATRADON switches RF and radiation on
%
%  [RING2,RADINDEX,CAVINDEX,ENERGY] = ATRADON(RING,CAVIPASS,BENDPASS,QUADPASS)
%    Changes passmethods to get RF cavity acceleration and radiation
%    damping. ATRADON also sets the "Energy" field on the modified elements,
%    looking for the machine energy in:
%       1) 1st 'RingParam' element
%       2) 1st 'RFCavity' element
%       3) field "E0" of the global variable "GLOBVAL"
%
%  INPUTS
%  1. RING	     initial AT structure
%  2. CAVIPASS   pass method for cavities (default CavityPass)
%                '' makes no change,
%  3. BENDPASS   pass method for bending magnets. Special values:
%                '' makes no change,
%                'auto' will substitute 'Pass' with 'RadPass' in any method
%                (default: 'auto')
%  4. QUADPASS   pass method for quadrupoles
%                '' makes no change,
%                'auto' will substitute 'Pass' with 'RadPass' in any method
%                (default: '')
%  5. SEXTUPASS   pass method for sextupoles
%                '' makes no change,
%                'auto' will substitute 'Pass' with 'RadPass' in any method
%                (default: '')
%  6. OCTUPASS   pass method for octupoles
%                '' makes no change,
%                'auto' will substitute 'Pass' with 'RadPass' in any method
%                (default: '')
%
%  OUPUTS
%  1. RING2     - Output ring
%  2. RADINDEX  - Indices of elements with radiation
%  3. CAVINDEX  - Indices of cavities
%  4. Energy    - Ring energy
%
%  See also ATRADOFF, ATCAVITYON, ATCAVITYOFF

[cavipass, bendpass, quadpass, sextupass, octupass]=parseargs({'CavityPass','auto','', '', ''},varargin);

ring = ring1;

% getenergy
energy=atenergy(ring);

%CAVITY business
if ~isempty(cavipass)
    cavitiesIndex=atgetcells(ring,'Frequency');
    if any(cavitiesIndex)
        ring(cavitiesIndex)=changepass(ring(cavitiesIndex),cavipass,energy);
    end
else
    cavitiesIndex=false(size(ring));
end

%BEND business
if ~isempty(bendpass)
    isdipole=@(elem,bangle) bangle~=0;
    dipoles=atgetcells(ring,'BendingAngle',isdipole);
    if any(dipoles) > 0
        ring(dipoles)=changepass(ring(dipoles),bendpass,energy);
    end
else
    dipoles=false(size(ring));
end

%QUADRUPOLE business
if ~isempty(quadpass)
    isquadrupole=@(elem,polyb) length(polyb) >= 2 && polyb(2)~=0;
    quadrupoles=atgetcells(ring,'PolynomB',isquadrupole) & ~dipoles;
    if any(quadrupoles) > 0
        ring(quadrupoles)=changepass(ring(quadrupoles),quadpass,energy);
    end
else
    quadrupoles=false(size(ring));
end

%SEXTUPOLE business
if ~isempty(sextupass)
    issextupole=@(elem,polyb) length(polyb) >= 3 && polyb(3)~=0;
    sextupoles=atgetcells(ring,'PolynomB',issextupole) & ~dipoles & ~quadrupoles;
    if any(sextupoles) > 0
        ring(sextupoles)=changepass(ring(sextupoles),sextupass,energy);
    end
else
    sextupoles=false(size(ring));
end

%OCTUPOLE business
if ~isempty(octupass)
    isoctupole=@(elem,polyb) length(polyb) >= 4 && polyb(4)~=0;
    octupoles=atgetcells(ring,'PolynomB',isoctupole) & ~dipoles & ~quadrupoles & ~sextupoles;
    if any(octupoles) > 0
        ring(octupoles)=changepass(ring(octupoles),octupass,energy);
    end
else
    octupoles=false(size(ring));
end

radelemIndex=dipoles|quadrupoles|sextupoles|octupoles;

if any(cavitiesIndex)
    atdisplay(1,['Cavities located at position ' num2str(find(cavitiesIndex)')]);
else
    atdisplay(1,'No cavity');
end
atdisplay(1,[num2str(sum(radelemIndex)) ' elements switched to include radiation']);

    function newline=changepass(line,newpass,nrj)
    if strcmp(newpass,'auto')
        passlist=atgetfieldvalues(line,'PassMethod');
        ok=cellfun(@(psm) isempty(strfind(psm,'RadPass')),passlist);
        passlist(ok)=strrep(passlist(ok),'Pass','RadPass');
    else
        passlist=repmat({newpass},size(line));
    end
    newline=cellfun(@newelem,line,passlist,'UniformOutput',false);

        function elem=newelem(elem,newpass)
            elem.PassMethod=newpass;
            elem.Energy=nrj;
        end
    end

end
