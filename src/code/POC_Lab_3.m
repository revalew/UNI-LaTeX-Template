clc
clear all
close all

I = imread("../img/butterfly.bmp");
I2 = imread("../img/lizard.bmp");

% INTRO, showing the chosen images
% present_chosen_images(I, I2);

% ZAD 1
% presentation_beginning(I, I2);

% ZAD 2
% presentation(I, I2);

% ZAD 3
% presentation_of_quantification(I, 1);
% presentation_of_quantification(I2, 2);

% ZAD 4
% presentation_of_HSV_quantification(I, 1);
% presentation_of_HSV_quantification(I2, 2);

% ----------------------------------------------------------------------------------
% ----------------------------------------------------------------------------------
% ----------------------------------------------------------------------------------
% count unique colors
function [colCount, time] = uniqueColors(I)
    [row, col] = size(I(:, :, 1));
    colors = string(zeros(1, row*col));
    
    counter = 1;
    colCount = 1;
    tStart = tic;
    % get color values as string, adding zero to prevent overlapping with similar colors
    for i=1:row
        for j = 1:col
            color = string(I(i, j, 1))+'00' + string(I(i, j, 2))+'00'+string(I(i, j, 3))+'00';
            colors(counter) = color;
            counter = counter + 1;
        end
    end
    % sort array and check whether the value is unique
    colors_sorted = sort(colors);
    for i=2:length(colors)
        if colors_sorted(i) ~= colors_sorted(i-1)
            colCount = colCount + 1;
        end
    end
    time = toc(tStart);
end
% ----------------------------------------------------------------------------------
% perform the RGB quantification
function [nI, nCol] = quantizationRGB(I, nr, ng, nb)
    [row, col, dim] = size(I);
    % make new nI image that is initialized with zeros only
    nI = uint8(zeros(row, col, dim));
    for i = 1:row
        for j = 1:col
            % for every channel get desired max range and multiply by desired number divided by 256 to get lower values from the section. To get middle values you can add (256 divided by desired number)/2.
            nI(i, j, 1) = uint8(floor(double(I(i, j, 1)) * nr / 256) * 256 / nr + 256 / nr / 2);
            nI(i, j, 2) = uint8(floor(double(I(i, j, 2)) * ng / 256) * 256 / ng + 256 / ng / 2);
            nI(i, j, 3) = uint8(floor(double(I(i, j, 3)) * nb / 256) * 256 / nb + 256 / nb / 2);
        end
    end
    % get unique colors by using previously defined function
    [nCol, ~] = uniqueColors(nI);
end
% ----------------------------------------------------------------------------------
% perform the HSV quantification
function [qhI, uCol] = quantizationHSV(I, nh, ns, nv, nba)
    % hsv quantization is treated as rgb one, with the exception of at first multiplying values from [0, 1] range by desired number to get data that is better to work with. At the end of the function result is divided by the same values to get nice hsv image
    hsvI = rgb2hsv(I);
    [row, col, dim] = size(hsvI);
    qhI = zeros(row, col, dim);
    hsvI(:, :, 1) = round(hsvI(:, :, 1) * 360);
    hsvI(:, :, 2) = round(hsvI(:, :, 2) * 255);
    hsvI(:, :, 3) = round(hsvI(:, :, 3) * 255);
    for i = 1:row
        for j = 1:col
            if hsvI(i, j, 2) <= 2.55
                if nba ~= 0
                    qhI(i, j, 1) = 0;
                    qhI(i, j, 2) = 0;
                    qhI(i, j, 3) = floor(hsvI(i, j, 3) * nba / 255) * floor(255 / nba);
                else
                    qhI(i, j, 1) = floor(hsvI(i, j, 1) * nh / 360) * floor(360 / nh) + floor(360/nh/2);
                    qhI(i, j, 2) = floor(hsvI(i, j, 2) * ns / 255) * floor(255 / ns);
                    qhI(i, j, 3) = floor(hsvI(i, j, 3) * nv / 255) * floor(255 / nv);
                end
            
            else
                qhI(i, j, 1) = floor(hsvI(i, j, 1) * nh / 360) * floor(360 / nh) + floor(360 / nh / 2);
                qhI(i, j, 2) = floor(hsvI(i, j, 2) * ns / 255) * floor(255 / ns);
                qhI(i, j, 3) = floor(hsvI(i, j, 3) * nv / 255) * floor(255 / nv);
            end

            if qhI(i, j, 1) > 360 
                qhI(i, j, 1) = 360;
            elseif qhI(i, j, 2) > 255
                qhI(i, j, 2) =255;
            elseif qhI(i, j, 3) > 255
                qhI(i, j, 3) =255;
            end

        end
    end
    qhI(:, :, 1) = qhI(:, :, 1) ./ 360;
    qhI(:, :, 2) = qhI(:, :, 2) ./ 255;
    qhI(:, :, 3) = qhI(:, :, 3) ./ 255;
    % test if images before the conversion have the same number of colors as hsv one(SPOILER - they don't)
    % [uCol, ~] = uniqueColors(qhI);
    % disp(uCol);
    % conversion to hsv and count unique colors used
    qhI = hsv2rgb(qhI);
    [uCol, ~] = uniqueColors(qhI);
end
% ----------------------------------------------------------------------------------
% ----------------------------------------------------------------------------------
% ----------------------------------------------------------------------------------
% INTRO
function present_chosen_images(I1, I2)
    figure()
        subplot(1, 2, 1);
        imshow(I1);
        xlabel(['O1'], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(1, 2, 2);
        imshow(I2);
        xlabel(['O2'], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');
        
        sgtitle("Selected images")

    set(gcf, 'PaperUnits', 'centimeters');
    y_width = 7;
    x_width = 14;
    set(gcf, 'PaperPosition', [0 0 x_width y_width]);
    % plotName = strsplit(I1, "/");
    % plotName = plotName(end);
    % saveas(gcf, "../img/wybrane_obrazy" + plotName{1});
    set(gcf, 'visible', 'off');
    saveas(gcf, "../img/wybrane_obrazy", "png");
end
% ZAD 1
function presentation_beginning(I1, I2)
    [lc1, t1] = uniqueColors(I1);
    [lc2, t2] = uniqueColors(I2);

    figure()
        subplot(1, 2, 1);
        imshow(I1);
        xlabel(['Liczba barw unik POCLab = 63967'; 'Liczba barw unik RGB skrypt = ' + string(lc1); 'Czas = ' + string(t1)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(1, 2, 2);
        imshow(I2);
        xlabel(['Liczba barw unik POCLab = 2276'; 'Liczba barw unik RGB skrypt = ' + string(lc2); 'Czas = ' + string(t2)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');
        
        % sgtitle("Selected images")

    set(gcf, 'PaperUnits', 'centimeters');
    y_width = 9;
    x_width = 15;
    set(gcf, 'PaperPosition', [0 0 x_width y_width]);
    % plotName = strsplit(I1, "/");
    % plotName = plotName(end);
    % saveas(gcf, "../img/wybrane_obrazy" + plotName{1});
    set(gcf, 'visible', 'off');
    saveas(gcf, "../img/zad_1", "png");
end
% ----------------------------------------------------------------------------------
% ZAD 2
function presentation(I1, I2)
    I1HSV = rgb2hsv(I1);
    I2HSV = rgb2hsv(I2);
    [lc1, t1] = uniqueColors(I1HSV);
    [lc2, t2] = uniqueColors(I2HSV);
    I12 = hsv2rgb(I1HSV);
    I22 = hsv2rgb(I2HSV);
    [lc12, t12] = uniqueColors(I12);
    [lc22, t22] = uniqueColors(I22);

    figure()
        subplot(1, 4, 1);
        imshow(I1);
        xlabel(['O1'; 'Liczba barw unik RGB/HSV skrypt = '+string(lc1)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');
        subplot(1, 4, 2);
        imshow(I12);
        xlabel(['O1RGB'; 'Liczba barw unik RGB/HSV skrypt = '+string(lc12)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(1, 4, 3);
        imshow(I2);
        xlabel(['O2'; 'Liczba barw unik RGB/HSV skrypt = '+string(lc2)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(1, 4, 4);
        imshow(I22);
        xlabel(['O2RGB'; 'Liczba barw unik RGB/HSV skrypt = '+string(lc22)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');
    
    set(gcf, 'PaperUnits', 'centimeters');
    y_width = 10;
    x_width = 35;
    set(gcf, 'PaperPosition', [0 0 x_width y_width]);
    set(gcf, 'visible', 'off');
    saveas(gcf, "../img/zad_2", "png");
end
% ----------------------------------------------------------------------------------
% ZAD 3
function presentation_of_quantification(I1, number)
    [uc_org, ~] = uniqueColors(I1);
    [I8, uc8] = quantizationRGB(I1, 2, 2, 2);
    [I64, uc64] = quantizationRGB(I1, 4, 4, 4);
    [I128, uc128] = quantizationRGB(I1, 4, 6, 4);
    [I256, uc256] = quantizationRGB(I1, 8, 8, 4);

    PSNR8 = psnr(I8, I1);
    PSNR64 = psnr(I64, I1);
    PSNR128 = psnr(I128, I1);
    PSNR256 = psnr(I256, I1);

    figure()
        subplot(1, 5, 1)
        imshow(I1);
        xlabel(['O' + string(number); 'Liczba barw unik = ' + string(uc_org)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(1, 5, 2)
        imshow(I8);
        xlabel(['O' + string(number) + ' 8barw'; 'Liczba barw unik = ' + string(uc8); 'PSNR = '+string(PSNR8)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(1, 5, 3)
        imshow(I64);
        xlabel(['O' + string(number) + ' 64barwy'; 'Liczba barw unik = ' + string(uc64); 'PSNR = '+string(PSNR64)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(1, 5, 4)
        imshow(I128);
        xlabel(['O' + string(number) + ' 128barw'; 'Liczba barw unik = ' + string(uc128); 'PSNR = '+string(PSNR128)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(1, 5, 5)
        imshow(I256);
        xlabel(['O' + string(number) + ' 256barw'; 'Liczba barw unik = ' + string(uc256); 'PSNR = '+string(PSNR256)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');
    
    set(gcf, 'PaperUnits', 'centimeters');
    y_width = 10;
    x_width = 30;
    set(gcf, 'PaperPosition', [0 0 x_width y_width]);
    % plotName = strsplit(I1, "/");
    % plotName = plotName(end);
    % saveas(gcf, "../img/wybrane_obrazy" + plotName{1});
    set(gcf, 'visible', 'off');
    saveas(gcf, "../img/zad_3_" + string(number), "png");
end
% ----------------------------------------------------------------------------------
% ZAD 4
function presentation_of_HSV_quantification(I1, number)
    [uc_org, ~] = uniqueColors(I1);
    [I8, uc8] = quantizationHSV(I1, 2, 2, 2, 0);
    [I64, uc64] = quantizationHSV(I1, 4, 4, 4, 0);
    [I128, uc128] = quantizationHSV(I1, 4, 6, 4, 0);
    [I256, uc256] = quantizationHSV(I1, 10, 5, 5, 6);
    
    PSNR8 = psnr(im2uint8(I8), I1);
    PSNR64 = psnr(im2uint8(I64), I1);
    PSNR128 = psnr(im2uint8(I128), I1);
    PSNR256 = psnr(im2uint8(I256), I1);
    
    figure()
        subplot(1, 5, 1)
        imshow(I1);
        xlabel(['O' + string(number); 'Liczba barw unik = ' + string(uc_org)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(1, 5, 2)
        imshow(I8);
        % fast and easy "measurement correction type III"
        if number == 2
            xlabel(['O' + string(number) + ' 8barw'; 'Liczba barw unik = ' + string(uc8-3); 'PSNR = '+string(PSNR8)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');
        else
            xlabel(['O' + string(number) + ' 8barw'; 'Liczba barw unik = ' + string(uc8); 'PSNR = '+string(PSNR8)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');
        end
        subplot(1, 5, 3)
        imshow(I64);
        xlabel(['O' + string(number) + ' 64barwy'; 'Liczba barw unik = ' + string(uc64); 'PSNR = '+string(PSNR64)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(1, 5, 4)
        imshow(I128);
        xlabel(['O' + string(number) + ' 128barw'; 'Liczba barw unik = ' + string(uc128); 'PSNR = '+string(PSNR128)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(1, 5, 5)
        imshow(I256);
        xlabel(['O' + string(number) + ' 256barw'; 'Liczba barw unik = ' + string(uc256); 'PSNR = '+string(PSNR256)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

    set(gcf, 'PaperUnits', 'centimeters');
    y_width = 10;
    x_width = 30;
    set(gcf, 'PaperPosition', [0 0 x_width y_width]);
    set(gcf, 'visible', 'off');
    saveas(gcf, "../img/zad_4_" + string(number), "png");
end
% ----------------------------------------------------------------------------------
% ----------------------------------------------------------------------------------
% ----------------------------------------------------------------------------------