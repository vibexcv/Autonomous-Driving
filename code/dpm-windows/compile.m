FLAG_32 = false

if FLAG_32
    mex -DMX_COMPAT_32 -O resize.cc
    mex -DMX_COMPAT_32 -O dt.cc
    mex -DMX_COMPAT_32 -O features.cc
    mex -DMX_COMPAT_32 -O getdetections.cc
    mex -DMX_COMPAT_32 -O fconv.cc
else
    mex -O resize.cc
    mex -O dt.cc
    mex -O features.cc
    mex -O getdetections.cc
    mex -O fconv.cc
end

% use one of the following depending on your setup
% 0 is fastest, 3 is slowest 

% 0) multithreaded convolution using SSE
% mex -O fconvsse.cc -o fconv

% 1) multithreaded convolution using blas
%    WARNING: the blas version does not work with matlab >= 2010b 
%    and Intel CPUs
% mex -O fconvblasMT.cc -lmwblas -o fconv

% 2) mulththreaded convolution without blas
% mex -O fconvMT.cc -o fconv

% 3) convolution using blas
% mex -O fconvblas.cc -lmwblas -o fconv

% 4) basic convolution, very compatible
% mex -O fconv.cc -o fconv

