function [ dct_value_2 ] = re_compress_inner( jpeg_input, fileOutput)
%RE_COMPRESS_INNER �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    %load the JPEG_Toobox
    addpath(fullfile('..','JPEG_Toolbox'));
    img_spatial = imread(jpeg_input);
    quality = 85; %������ѹ����������
    imwrite(img_spatial,fileOutput,'quality',quality);
    img_jpeg = jpeg_read(fileOutput);
    dct_value_2 = img_jpeg.coef_arrays{1};
end