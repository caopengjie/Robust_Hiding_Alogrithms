clc;
%% pgm to jpg
bmps = dir('F:\Test\Data\BossBase\BossBase_bmp\image_cover_1000\*.bmp');
num_bmps = length(bmps);
for i = 1:num_bmps
    bmp_file = fullfile('F:\Test\Data\BossBase\BossBase_bmp\image_cover_1000\',bmps(i).name);
    bmp = imread(bmp_file);
    % get the filename
    [path, name, ext] = fileparts(bmp_file);
    filename = strcat(name,'.jpg');
    jpg_file = fullfile('F:\Test\Data\BossBase\BossBase_jpg_95\',filename);
    % write the file
    imwrite(bmp ,jpg_file, 'quality',95);
end