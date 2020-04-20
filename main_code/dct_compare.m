%%compare the diff between dct
clc;

%load the JPEG_Toobox
addpath(fullfile('..','JPEG_Toolbox'));

%load the jpeg cover
cover_path = 'times_9_53.jpg';
%img name
img_name = 'times_9_53.jpg';

%store the num of diff dct
dct_diff_nums = zeros(1, 20);

%store the initial dct_value
cover_img_jpeg = jpeg_read(cover_path);
dct_value_pre = cover_img_jpeg.coef_arrays{1};

%re_compress the jpeg 
for i = 1:20
     times = num2str(i);
     [dct_value_post, fileOutput] = re_compress(cover_path,img_name,times);
     dct_diff = dct_value_post - dct_value_pre;
     dct_diff_nums(1, i) = sum(sum(dct_diff~=0));
     dct_value_pre = dct_value_post;
     cover_path = fileOutput
end


