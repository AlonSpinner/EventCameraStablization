function sign=randSign(sz)
if nargin<1, sz=1; end
sign=2*(double(rand(sz)>0.5)-0.5);
end