function values = atgetfieldvalues(ring,varargin)
%ATGETFIELDVALUES - retrieves the field values AT cell array of elements
%
%  VALUES = atgetfieldvalues(RING,'field') extracts the values of
%  the field 'field' in all the elements of RING
%
%  VALUES = atgetfieldvalues(RING,INDEX,'field') extracts the values of
%  the field 'field' in the elements of RING selected by INDEX
%
%  if RING{I}.FIELD is a numeric scalar
%    VALUES is a length(INDEX) x 1 array
%  otherwise
%    VALUES is a length(INDEX) x 1 cell array
%
%  More generally atgetfieldvalues(RING,INDEX,subs1,subs2,...) will call
%   getfield(RING{I},subs1,subs2,...) for I in INDEX
%
%  INPUTS
%  1. ring    - Lattice structure
%  OPTIONAL
%  1. Index   - Index of position in the ring structure
%  2. 'field' - fieldaname
%  3. subs1, subs2 - extra parameter to access the field
%
%  EXAMPLES
%  1. V=atgetfieldvalues(RING,1:10,'PolynomB') is a 10x1  cell array
%    such that V{I}=RING{I}.PolynomB for I=1:10
%
%  2. V=atgetfieldvalues(RING(1:10),'PolynomB',{1,2}) is a 10x1 array
%     such that V(I)=RING{I},PolynomB(1,2)
%
% See Also atsetfieldvalues atgetcells, getcellstruct, findcells

if islogical(varargin{1}) || isnumeric(varargin{1})
    values=atgetfield(ring(varargin{1}),varargin{2:end});
else
    values=atgetfield(ring,varargin{:});
end

    function values = atgetfield(line,varargin)
        [values,isnumscal,isok]=cellfun(@scan,line(:),'UniformOutput',false);
        isok=cat(1,isok{:});
        if all(cat(1,isnumscal{isok}))
            values(~isok)={NaN};
            values=cat(1,values{:});
        end
        
        function [val,isnumscal,isok]=scan(el)
            try
                val=getfield(el,varargin{:});
                isnumscal=isnumeric(val) && isscalar(val);
                isok=true;
            catch
                val=[];
                isnumscal=false;
                isok=false;
            end
        end
    end

end
