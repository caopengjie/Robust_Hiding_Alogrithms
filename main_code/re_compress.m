function [dct_value_2,fileOutpue] = re_compress(jpeg_input, img_name, times)
    %load the JPEG_Toobox
    addpath(fullfile('..','JPEG_Toolbox'));
    %recompress img file dir
    re_compress_file_dir = 'D:\test_data\compress\';
    fileOutpue = strcat(re_compress_file_dir,times, '_',img_name);
    img_spatial = imread(jpeg_input);
    quality = 85; %设置重压缩质量因子
    imwrite(img_spatial,fileOutpue,'quality',quality);
    img_jpeg = jpeg_read(fileOutpue);
    dct_value_2 = img_jpeg.coef_arrays{1};
end