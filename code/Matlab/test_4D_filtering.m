clear all
clc
close all

%---------------------------------------------------------------------------------------------------------------------
% README
% If you run this code in Windows, your graphics driver might stop working
% for large volumes / large filter sizes. This is not a bug in my code but is due to the
% fact that the Nvidia driver thinks that something is wrong if the GPU
% takes more than 2 seconds to complete a task. This link solved my problem
% https://forums.geforce.com/default/topic/503962/tdr-fix-here-for-nvidia-driver-crashing-randomly-in-firefox/
%---------------------------------------------------------------------------------------------------------------------

mex Filtering4D.cpp -lcudart -lcufft -lFilteringCUDA -IC:/Program' Files'/NVIDIA' GPU Computing Toolkit'/CUDA/v5.0/include -LC:/Program' Files'/NVIDIA' GPU Computing Toolkit'/CUDA/v5.0/lib/x64 -LC:/users/wande/Documents/Visual' Studio 2010'/Projects/Filtering/x64/Release/ -IC:/users/wande/Documents/Visual' Studio 2010'/Projects/Filtering/

filter_size = 5;
filter = randn(filter_size,filter_size,filter_size,filter_size);
filter = filter/sum(abs(filter(:)));
%volumes = randn(128,128,128,32);
volumes = randn(129,129,129,33);

tic
filter_response_cpu = convn(volumes,filter,'same');
toc

[filter_response_gpu_shared, filter_response_gpu_shared_unrolled, time_shared, time_shared_unrolled, time_fft]  = Filtering4D(volumes,filter,0);

imagesc([filter_response_cpu(:,:,round(size(volumes,3)/2),round(size(volumes,4)/2)) filter_response_gpu_shared(:,:,round(size(volumes,3)/2),round(size(volumes,4)/2)) filter_response_gpu_shared_unrolled(:,:,round(size(volumes,3)/2),round(size(volumes,4)/2)) ])

shared_tot = sum(abs(filter_response_cpu(:) - filter_response_gpu_shared(:)))
shared_max = max(abs(filter_response_cpu(:) - filter_response_gpu_shared(:)))

shared_unrolled_tot = sum(abs(filter_response_cpu(:) - filter_response_gpu_shared_unrolled(:)))
shared_unrolled_max = max(abs(filter_response_cpu(:) - filter_response_gpu_shared_unrolled(:)))


time_shared
time_shared_unrolled
time_fft