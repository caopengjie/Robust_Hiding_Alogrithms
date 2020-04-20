function [ dct_value_2 ] = re_compress_inner( jpeg_input, fileOutput)
%RE_COMPRESS_INNER 此处显示有关此函数的摘要
%   此处显示详细说明
    %load the JPEG_Toobox
    addpath(fullfile('..','JPEG_Toolbox'));
    img_spatial = imread(jpeg_input);
    quality = 85; %设置重压缩质量因子
    imwrite(img_spatial,fileOutput,'quality',quality);
    img_jpeg = jpeg_read(fileOutput);
    dct_value_2 = img_jpeg.coef_arrays{1};
end