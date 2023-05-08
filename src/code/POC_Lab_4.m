clc
clear all
close all

% B&W - ZAD 1
I1 = imread("../img/lenna_512x512.bmp");
I2 = imread("../img/mandrill_512x512.bmp");

% COLOR - ZAD 2
I3 = imread("../img/lena_color_512x512.bmp");
I4 = imread("../img/baboon_512x512.bmp");

% ZAD 1 + PSNR ZAD 3
binarizationPresentation(I1, I2);

% ZAD 2 + PSNR ZAD 3
ditheringPresentation(I3, "Lena", 1);
ditheringPresentation(I4, "O3", 2);

% ----------------------------------------------------------
% short function to return results
% ----------------------------------------------------------
function otsuI = otsuBinarization(I)
    level = graythresh(I);
    otsuI = imbinarize(I, level);
end
% ----------------------------------------------------------
% funtion to binarize image using Floyd-Steinberg algorithm
% ----------------------------------------------------------
function ditherBinI = ditherBinarization(I)
    I = double(I);
    % instead of using 255 as maxlevel and 255/2 as level we will use accordingly max item in original image as maxlevel and said maxlevel divided by 2 as level
    maxlevel = max(I, [], 'all');
    level = maxlevel/2;
    [row, col] = size(I);
    ditherBinI = zeros(row, col);
    % error array is deliberatly declared as bigger than image - this is because i and j may go out of range. Using bigger array will eliminate this problem, as we won't use extreme rows and columns
    errArr = zeros(row+2, col+2);
    for i=1:row
        for j=1:col
            if (level > (I(i, j) + errArr(i+1, j+1)))
                ditherBinI(i, j) = 0;
                e = I(i, j) + errArr(i+1, j+1);
            else
                ditherBinI(i, j) = 255;
                e = I(i, j) + errArr(i+1, j+1) - maxlevel;
            end
            errArr(i+1, j+2) = errArr(i+1, j+2) + 7/16*e;
            errArr(i+2, j) = errArr(i+2, j) + 3/16*e;
            errArr(i+2, j+1) = errArr(i+2, j+1) + 5/16*e;
            errArr(i+2, j+2) = errArr(i+2, j+2) + 1/16*e;
        end
    end
end
% ----------------------------------------------------------
% quantization with dithering will be implemented in the simillar manner as binarization, but instead of using fixed values for black and white we will use getNewValue() function that finds nearest color using quantization. Whole function uses 3 double nested for loops for every color channel, error propagation is realized similarly as in the binarization case, but in case of quantization series of if statements are used
% ----------------------------------------------------------
function [ditherI] = ditherFS(qI, nr, ng, nb)
    % qI = quantizationRGB(I, nr, ng, nb);
    qI = double(qI);
    [row, col, ~] = size(qI);
    % red loop
    for i=1:row
        for j=1:col
            oldPixel = qI(i, j, 1);
            newPixel = getNewValue(oldPixel, nr);
            qI(i, j, 1) = newPixel;
            e = oldPixel - newPixel;
            if j < col
                qI(i, j+1, 1) = qI(i, j+1, 1) + e*7/16;
            end
            if i < row
                qI(i+1, j, 1) = qI(i+1, j, 1) + e*5/16;
                if j > 1
                    qI(i+1, j-1, 1) = qI(i+1, j-1, 1) + e*3/16;
                end
                if j < col
                    qI(i+1, j+1, 1) = qI(i+1, j+1, 1) + e*1/16;
                end
            end
        end
    end
    % green loop
    for i=1:row
        for j=1:col
            oldPixel = qI(i, j, 2);
            newPixel = getNewValue(oldPixel, ng);
            qI(i, j, 2) = newPixel;
            e = oldPixel - newPixel;
            if j < col
                qI(i, j+1, 2) = qI(i, j+1, 2) + e*7/16;
            end
            if i < row
                qI(i+1, j, 2) = qI(i+1, j, 2) + e*5/16;
                if j > 1
                    qI(i+1, j-1, 2) = qI(i+1, j-1, 2) + e*3/16;
                end
                if j < col
                    qI(i+1, j+1, 2) = qI(i+1, j+1, 2) + e*1/16;
                end
            end
        end
    end
    % blue loop
    for i=1:row
        for j=1:col
            oldPixel = qI(i, j, 3);
            newPixel = getNewValue(oldPixel, nb);
            qI(i, j, 3) = newPixel;
            e = oldPixel - newPixel;
            if j < col
                qI(i, j+1, 3) = qI(i, j+1, 3) + e*7/16;
            end
            if i < row
                qI(i+1, j, 3) = qI(i+1, j, 3) + e*5/16;
                if j > 1
                    qI(i+1, j-1, 3) = qI(i+1, j-1, 3) + e*3/16;
                end
                if j < col
                    qI(i+1, j+1, 3) = qI(i+1, j+1, 3) + e*1/16;
                end
            end
        end
    end
    % convert the dithered img to uint8
    ditherI = uint8(qI);
end
% ----------------------------------------------------------
% function that finds nearest color using quantization
% ----------------------------------------------------------
function [newVal] = getNewValue(oldVal, nc)
    newVal = uint8(floor(double(oldVal)*nc/256)*(256/nc)+(256/nc/2));
end
% ----------------------------------------------------------
% ZAD 1
% ----------------------------------------------------------
function binarizationPresentation(I1, I2)

    % Otsu's method
    otsuI1 = otsuBinarization(I1);
    otsuI2 = otsuBinarization(I2);
    % PSNR
    otsuI1PSNR = psnr(im2uint8(otsuI1), I1);
    otsuI2PSNR = psnr(im2uint8(otsuI2), I2);
    % SAVE the values for easy LaTeX input
        fileID = fopen('./variables/otsuI1PSNR.txt','w');
        fprintf(fileID, '%.4f', otsuI1PSNR);
        fclose(fileID);
        % save("otsuI2PSNR.txt", "otsuI2PSNR", "-ascii");
        fileID = fopen('./variables/otsuI2PSNR.txt','w');
        fprintf(fileID, '%.4f', otsuI2PSNR);
        fclose(fileID);

    % Dithering FS - custom script
    fsI1 = ditherBinarization(I1);
    fsI2 = ditherBinarization(I2);
    % PSNR
    fsI1PSNR = psnr(im2uint8(fsI1), I1);
    fsI2PSNR = psnr(im2uint8(fsI2), I2);
    % SAVE the values for easy LaTeX input
        fileID = fopen('./variables/fsI1PSNR.txt','w');
        fprintf(fileID, '%.4f', fsI1PSNR);
        fclose(fileID);
        fileID = fopen('./variables/fsI2PSNR.txt','w');
        fprintf(fileID, '%.4f', fsI2PSNR);
        fclose(fileID);
    
    % Dithering FS - MATLAB built-in method
    fsmI1 = dither(I1);
    fsmI2 = dither(I2);
    % PSNR
    fsmI1PSNR = psnr(im2uint8(fsmI1), I1);
    fsmI2PSNR = psnr(im2uint8(fsmI2), I2);
    % SAVE the values for easy LaTeX input
        fileID = fopen('./variables/fsmI1PSNR.txt','w');
        fprintf(fileID, '%.4f', fsmI1PSNR);
        fclose(fileID);
        fileID = fopen('./variables/fsmI2PSNR.txt','w');
        fprintf(fileID, '%.4f', fsmI2PSNR);
        fclose(fileID);

    % plot the figure - 1x4 plot for each image
    figure()
        % Lenna
        subplot(1, 4, 1)
        imshow(I1);
        xlabel('Lena z 256 poziomami szarości', 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(1, 4, 2)
        imshow(otsuI1);
        xlabel(['Wynik binaryzacji metodą Otsu'; 'PSNR = ' + string(otsuI1PSNR)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(1, 4, 3)
        imshow(fsI1(200:380, 200:380, :));
        xlabel(['Wynik Ditheringu metodą FS - własny skrypt'; 'PSNR = ' + string(fsI1PSNR)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(1, 4, 4)
        imshow(fsmI1(200:380, 200:380, :));
        xlabel(['Wynik Ditheringu metodą FS - inna aplikacja'; 'PSNR = ' + string(fsmI1PSNR)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');
        
        set(gcf, 'PaperUnits', 'centimeters');
        y_width = 10;
        x_width = 35;
        set(gcf, 'PaperPosition', [0 0 x_width y_width]);
        % % plotName = strsplit(I1, "/");
        % % plotName = plotName(end);
        % % saveas(gcf, "../img/wybrane_obrazy" + plotName{1});
        set(gcf, 'visible', 'off');
        saveas(gcf, "../img/zad_1_1", "png");

    figure()
        % Monke
        subplot(1, 4, 1)
        imshow(I2);
        xlabel('Własny obraz z 256 poziomami szarości', 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(1, 4, 2)
        imshow(otsuI2);
        xlabel(['Wynik binaryzacji metodą Otsu'; 'PSNR = ' + string(otsuI2PSNR)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(1, 4, 3)
        imshow(fsI2(1:400, 1:400, :));
        xlabel(['Wynik Ditheringu metodą FS - własny skrypt'; 'PSNR = ' + string(fsI2PSNR)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(1, 4, 4)
        imshow(fsmI2(1:400, 1:400, :));
        xlabel(['Wynik Ditheringu metodą FS - inna aplikacja'; 'PSNR = ' + string(fsmI2PSNR)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        % sgtitle("Selected images")

        set(gcf, 'PaperUnits', 'centimeters');
        y_width = 10;
        x_width = 35;
        set(gcf, 'PaperPosition', [0 0 x_width y_width]);
        set(gcf, 'visible', 'off');
        saveas(gcf, "../img/zad_1_2", "png");
end
% ----------------------------------------------------------
% ZAD 2
% ----------------------------------------------------------
function ditheringPresentation(I, name, number)
    
    if number == 1
        [dm16I, cmap16] = imread("../img/lena_d16.bmp");
        dm16I = ind2rgb(dm16I, cmap16);
        [dm256I, cmap256] = imread("../img/lena_d256.bmp");
        dm256I = ind2rgb(dm256I, cmap256);
    else
        [dm16I, cmap16] = imread("../img/baboon_d16.bmp");
        dm16I = ind2rgb(dm16I, cmap16);
        [dm256I, cmap256] = imread("../img/baboon_d256.bmp");
        dm256I = ind2rgb(dm256I, cmap256);
    end

    % 16 colors quantization
    % nd16I = quantizationRGB(I, 4, 2, 2);
    [nd16I, map16] = rgb2ind(I, 16, 'nodither');
    % PSNR
    nd16IRGB = ind2rgb(nd16I, map16); 
    nd16IPSNR = psnr(im2uint8(nd16IRGB), I);
    % SAVE the values for easy LaTeX input
        fileID = fopen('./variables/nd16IPSNR_' + string(number) + '.txt','w');
        fprintf(fileID, '%.4f', nd16IPSNR);
        fclose(fileID);
    
    % 16 colors quantization + Dithering
    d16I = ditherFS(I, 4, 2, 2);
    % PSNR
    d16IPSNR = psnr(im2uint8(d16I), I);
    dm16IPSNR = psnr(im2uint8(dm16I), I);
    % dm16IPSNR = psnr(repmat(im2uint8(dm16I),[1,1,3]), I);
    % SAVE the values for easy LaTeX input
        fileID = fopen('./variables/d16IPSNR_' + string(number) + '.txt','w');
        fprintf(fileID, '%.4f', d16IPSNR);
        fclose(fileID);
        fileID = fopen('./variables/dm16IPSNR_' + string(number) + '.txt','w');
        fprintf(fileID, '%.4f', dm16IPSNR);
        fclose(fileID);
    
    
    % 256 colors quantization
    % nd256I = quantizationRGB(I, 8, 8, 4);
    [nd256I, map256] = rgb2ind(I, 256, 'nodither');
    % PSNR
    nd256IRGB = ind2rgb(nd256I, map256);
    nd256IPSNR = psnr(im2uint8(nd256IRGB), I);
    % SAVE the values for easy LaTeX input
        fileID = fopen('./variables/nd256IPSNR_' + string(number) + '.txt','w');
        fprintf(fileID, '%.4f', nd256IPSNR);
        fclose(fileID);
    
    % 256 colors quantization + Dithering
    d256I = ditherFS(I, 8, 8, 4);
    % PSNR
    d256IPSNR = psnr(im2uint8(d256I), I);
    dm256IPSNR = psnr(im2uint8(dm256I), I);
    % dm256IPSNR = psnr(repmat(im2uint8(dm256I),[1,1,3]), I);
    % SAVE the values for easy LaTeX input
        fileID = fopen('./variables/d256IPSNR_' + string(number) + '.txt','w');
        fprintf(fileID, '%.4f', d256IPSNR);
        fclose(fileID);
        fileID = fopen('./variables/dm256IPSNR_' + string(number) + '.txt','w');
        fprintf(fileID, '%.4f', dm256IPSNR);
        fclose(fileID);

    figure()
        subplot(2, 4, 1)
        imshow(I);
        xlabel([string(name) + ' "true color"'], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(2, 4, 2)
        imshow(nd16I, map16);
        xlabel(['Kwantyzacja na 16 barw bez ditheringu'; 'PSNR = ' + string(nd16IPSNR)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(2, 4, 3)
        imshow(d16I);
        xlabel(['Wynik Ditheringu metodą FS - własny skrypt'; 'PSNR = ' + string(d16IPSNR)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(2, 4, 4)
        imshow(dm16I);
        xlabel(['Wynik Ditheringu metodą FS - inna aplikacja'; 'PSNR = ' + string(dm16IPSNR)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(2, 4, 6)
        imshow(nd256I, map256);
        xlabel(['Kwantyzacja na 256 barw bez ditheringu'; 'PSNR = ' + string(nd256IPSNR)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(2, 4, 7)
        imshow(d256I);
        xlabel(['Wynik Ditheringu metodą FS - własny skrypt'; 'PSNR = ' + string(d256IPSNR)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

        subplot(2, 4, 8)
        imshow(dm256I);
        xlabel(['Wynik Ditheringu metodą FS - inna aplikacja'; 'PSNR = ' + string(dm256IPSNR)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

    set(gcf, 'PaperUnits', 'centimeters');
    y_width = 15;
    x_width = 35;
    set(gcf, 'PaperPosition', [0 0 x_width y_width]);
    set(gcf, 'visible', 'off');
    saveas(gcf, "../img/zad_2_" + string(number), "png");
end
% ----------------------------------------------------------
% method from previous lab
% ----------------------------------------------------------
function [nI] = quantizationRGB(I, nr, ng, nb)
    [row, col, dim] = size(I);
    % make new nI image that at first is zeros only
    nI = uint8(zeros(row, col, dim));
    for i = 1:row
        for j = 1:col
            % for every channel get desired max range and multiply by desired number divided by 256 to get lower values from the section. To get middle values you can add (256 divided by desired number)/2.
            nI(i, j, 1) = uint8(floor(double(I(i, j, 1))*nr/256)*256/nr+256/nr/2);
            nI(i, j, 2) = uint8(floor(double(I(i, j, 2))*ng/256)*256/ng+256/ng/2);
            nI(i, j, 3) = uint8(floor(double(I(i, j, 3))*nb/256)*256/nb+256/nb/2);
        end
    end
end