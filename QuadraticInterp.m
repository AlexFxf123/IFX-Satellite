function interpOffset = QuadraticInterp(data_in, detIdxAlongDop_in)

data_in = abs(data_in);
centerCells = data_in(detIdxAlongDop_in);
m=length(data_in);
IdxLeft=detIdxAlongDop_in-1;
IdxLeft(IdxLeft<1) = IdxLeft(IdxLeft<1)+m;
leftCells = data_in(IdxLeft);
IdxRight=detIdxAlongDop_in+1;
IdxRight(IdxRight>m) = IdxRight(IdxRight>m)-m;
rightCells=data_in(IdxRight);
interpOffset=-0.5*(rightCells-leftCells)./(leftCells-2*centerCells+rightCells);

end
