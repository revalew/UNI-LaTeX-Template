clc
clear all
close all

%% path for images

% img of the birb
Istr_gt_1 = '../img/GT_sRGB/IMG_015_srgb.png';
Istr_cfa_1 = "../img/CFA_sRGB/IMG_015_srgb_CFA.png";

% img of the ceramic dog
Istr_gt_2 = '../img/GT_sRGB/IMG_7073_srgb.png';
Istr_cfa_2 = '../img/CFA_sRGB/IMG_7073_srgb_CFA.png';

% img of the markers
% Istr_gt_2 = '../img/GT_sRGB/cienkopisy_srgb.png';
% Istr_cfa_2 = '../img/CFA_sRGB/cienkopisy_srgb_CFA.png';

%% ZAD 1:
% [I1, Inn1, Ib1] = call(Istr_cfa_1, Istr_gt_1);
% [I2, Inn2, Ib2] = call(Istr_cfa_2, Istr_gt_2);


%% ZAD 2:
resultsPresentationZad2(Istr_cfa_1, Istr_gt_1, Istr_cfa_2, Istr_gt_2);

% show nearest-neighbor interpolation result
% figure(3);
% imshow(Inn1);

% figure(4);
% imshow(Ib1);

% figure(5);
% imshow(Inn2);

% figure(6);
% imshow(Ib2);

% plotName = strsplit(Istr_cfa_2, "/");
% plotName = plotName(end);
% plotName{1}

function [I, IGT, IBGGR] = dmsc(Istr_cfa, Istr_gt)
    %get image to demosaic
    I = imread(Istr_cfa);
    
    IGT = imread(Istr_gt);
    
    %use demosaic 
    IGBRG = demosaic(I, 'gbrg');
    IGRBG = demosaic(I, 'grbg');
    IBGGR = demosaic(I, 'bggr');
    IRGGB = demosaic(I, 'rggb');

    %results in one figure, 2 rows, 3 columns
    figure();
        subplot(2, 3, 1);
            % imshow(I);
            imshow(I(90:240, 150:260, :));
            xlabel('Obraz surowy');
        
        subplot(2, 3, 4);
            % imshow(IGT);
            imshow(IGT(90:240, 150:260, :));
            xlabel('Obraz wzorcowy');
        
        subplot(2, 3, 2);
            % imshow(IGBRG);
            imshow(IGBRG(90:240, 150:260, :));
            xlabel('Obraz w ukladzie gbrg');
        
        subplot(2, 3, 3);
            % imshow(IGRBG);
            imshow(IGRBG(90:240, 150:260, :));
            xlabel('Obraz w ukladzie grbg');
        
        subplot(2, 3, 5);
            % imshow(IBGGR);
            imshow(IBGGR(90:240, 150:260, :));
            xlabel('Obraz w ukladzie bggr');
        
        subplot(2, 3, 6);
            % imshow(IRGGB);
            imshow(IRGGB(90:240, 150:260, :));
            xlabel('Obraz w ukladzie rggb');
        
        sgtitle('Identyfikacja ukladu matrycy Bayera');

    set(gcf, 'PaperUnits', 'centimeters');
    y_width = 9;
    x_width = 15;
    set(gcf, 'PaperPosition', [0 0 x_width y_width]);
    plotName = strsplit(Istr_cfa, "/");
    plotName = plotName(end);
    saveas(gcf, "../img/POROWNANIE_" + plotName{1});
end

function [R, G, B] = split(Istr_cfa)
    %function to split grayscale image that is cfa coded into 
    %correct 3 different channels, as we know that:
    %[B, G; G R] 
    I = imread(Istr_cfa);
    [row, col] = size(I);
    R = zeros(row, col);
    G = zeros(row, col);
    B = zeros(row, col);
    for i=1:2:row
        for j=1:2:col
            square = I(i:i+1, j:j+1);
            B(i, j) = square(1, 1);
            G(i, j+1) = square(1, 2);
            G(i+1, j) = square(2, 1);
            R(i+1, j+1) = square(2, 2);
        end
    end

end

function [Inn, Rnn, Gnn, Bnn] = nearest_neighbor(I, R, G, B)
    [row, col] = size(I);
    %create copies of RGB channels
    Rnn = zeros(row, col);
    Gnn = zeros(row, col);
    Bnn = zeros(row, col);
    %create interpolated RGB channels in for loop
    for i = 1:2:row
        for j = 1:2:col
            Rnn(i:i+1, j:j+1) = R(i+1, j+1);
            Bnn(i:i+1, j:j+1) = B(i, j);
            Gnn(i, j:j+1) = double(G(i, j+1) + G(i+1, j))/2;
            Gnn(i+1, j:j+1) = double(G(i, j+1) + G(i+1, j))/2;
            Gnn(i, j:j+1) = G(i, j+1);
            Gnn(i+1, j:j+1) = G(i+1, j);
        end
    end
    %conversion to uint8
    Rnn = uint8(Rnn);
    Gnn = uint8(Gnn);
    Bnn = uint8(Bnn);
    %merge channels into rgb image
    Inn = cat(3, Rnn, Gnn, Bnn);
end

function [Ib, Rbc, Gbc, Bbc] = bilinear(I, R, G, B)
    [row, col] = size(I);

    [Inn, Rnn, Gnn, Bnn] = nearest_neighbor(I, R, G,B);
    Rb = zeros(row, col);
    Gb = zeros(row, col);
    Bb = zeros(row, col);
    %to interpolate we will use seperate loops for every channel
    %first we will interpolate red channel, using squares 3x3 
    %and assigning red values to new Rb channel
    %to fill empty pixels, move backwards to use previously generated
    %values 
    for i = 2:2:row
        for j = 2:2:col
            if (i+3 <= 288 && j+2 <= 432)
            redSquare = R(i:i+2, j:j+2);
            Rc = (R(i, j)+R(i, j+2)+R(i+2, j)+R(i+2, j+2))/4;
            Rs = (R(i+2, j+2)+R(i+2, j))/2;
            Rb(i, j) = redSquare(1, 1);
            Rb(i, j+2) = redSquare(1, 3);
            Rb(i+2, j) = redSquare(3, 1);
            Rb(i+2, j+2) = redSquare(3, 3);
            Rb(i+1, j+1) = Rc;
            Rb(i+2, j+1) = Rs;
            if (j -1 > 0)
            Rb(i+1, j) = (Rb(i, j-1)+Rb(i+2, j-1)+Rb(i, j+1)+Rb(i+2, j+1))/4;
            end
            end
            
        end
    end
    %for loop for green channel
    %green and blue channels are realized in the simillar manner as the
    %blue channel
    for i = 1:2:row
        for j = 1:2:col
            if (i+2 <= 288 && j+2 <= 432) 
            greenSquare = G(i:i+2, j:j+2);
            Gi = (G(i, j+1)+G(i+1, j)+G(i+2, j+1)+G(i+1, j+2))/4;
            Gb(i, j+1) = greenSquare(1, 2);
            Gb(i+1, j) = greenSquare(2, 1);
            Gb(i+1, j+2) = greenSquare(2, 3);
            Gb(i+2, j+1) = greenSquare(3, 2);
            Gb(i+1, j+1) = Gi;
            end
            if (j~=1) && (i+3 <= 288 && j+2 <= 432) 
            greenSquare = G(i:i+2, j:j+2);
            Gi = (G(i+1, j)+G(i+2, j+1)+G(i+3, j)+G(i+2, j-1))/4;
            Gb(i+2, j) = Gi;
            end
        end
    end

    for i = 1:2:row
        for j = 1:2:col
            if (i+2 <= 288 && j+3 <= 432)
            blueSquare = B(i:i+2, j:j+2);
            Bc = (B(i, j)+B(i, j+2)+B(i+2, j)+B(i+2, j+2))/4;
            Bs = (B(i+2, j)+B(i+2, j+2))/2;
            Bb(i, j) = blueSquare(1,1);
            Bb(i, j+2) = blueSquare(1, 3);
            Bb(i+2, j) = blueSquare(3, 1);
            Bb(i+2, j+2) = blueSquare(3, 3);
            Bb(i+1, j+1) = Bc;
            Bb(i+2, j+1) = Bs;
            if (j -1 > 0)
            Bb(i+1, j) = (Bb(i, j-1)+Bb(i+2, j-1)+Bb(i, j+1)+Bb(i+2, j+1))/4;
            end
            end
        end
    end
    %convert to uint8 and create rgb image Ib from created channels

   
%     Rb = nntob(Rb, Rnn);
%     Gb = nntob(Gb, Gnn);
%     Rb = nntob(Bb, Bnn);
    % disp(Bnn);
    Rb = uint8(Rb);
    Gb = uint8(Gb);
    Bb = uint8(Bb);

    Rbc = nntob(Rb, Rnn);
    Gbc = nntob(Gb, Gnn);
    Bbc = nntob(Bb, Bnn);
    Ib = cat(3, Rbc, Gbc, Bbc);
%     Ib = nntob(Ib, Inn);
    
end

function Mbc = nntob(Mb, Mnn)
    [row, col] = size(Mb);
    %disp([row, col]);
    Mb(1:3,1:col) = Mnn(1:3, 1:col);
    %disp(Mb(1:3,1:col));
    Mb(row-1:row,1:col) = Mnn(row-1:row,1:col);
    Mb(1:row,1:2) = Mnn(1:row,1:2);
    Mb(1:row,col-1:col) = Mnn(1:row,col-1:col);
    Mbc = Mb;

end

function [I,IGT, Inn, Ib, IBGGR] = call(Istr_cfa, Istr_gt) 
    [I, IGT, IBGGR] = dmsc(Istr_cfa, Istr_gt);
    [R, G, B] = split(Istr_cfa);
    [Inn, Rnn, Gnn, Bnn] = nearest_neighbor(I, R, G, B);
    [Ib, Rb, Gb, Bb] = bilinear(I, R, G, B);
    [Ib2, Rb2, Gb2, Bb2] = biliniowa(I, R, G, B);
end

function resultsPresentationZad2(Istr_cfa_1, Istr_gt_1, Istr_cfa_2, Istr_gt_2)
    [I1 ,IGT1,Inn1, Ib1, IBGGR1] = call(Istr_cfa_1, Istr_gt_1);
    [I2 ,IGT2,Inn2, Ib2, IBGGR2] = call(Istr_cfa_2, Istr_gt_2);
    PSNR1NN = psnr(Inn1, IGT1);
    PSNR2NN = psnr(Inn2, IGT2);
    PSNR1B = psnr(Ib1, IGT1);
    PSNR2B = psnr(Ib2, IGT2);
    PSNRGBBR1 = psnr(IBGGR1, IGT1);
    PSNRGBBR2 = psnr(IBGGR2, IGT2);
    figure();
        subplot(2, 3, 1);
            imshow(I1);
            xlabel('Obraz surowy 1');
        
        subplot(2, 3, 2);
            imshow(Inn1);
            xlabel('NN 1, PSNR='+string(PSNR1NN));
        
        subplot(2, 3, 3);
            imshow(IGT1);
            xlabel('GT 1');
        
        subplot(2, 3, 4);
            imshow(I2);
            xlabel('Obraz surowy 2');
            
        subplot(2, 3, 5);
            imshow(Inn2);
            xlabel('NN 2, PSNR='+string(PSNR2NN));
        
        subplot(2, 3, 6);
            imshow(IGT2);
            xlabel('GT 2');
    sgtitle('Nearest neighbour interpolation');
    set(gcf, 'PaperUnits', 'centimeters');
    y_width = 9;
    x_width = 15;
    set(gcf, 'PaperPosition', [0 0 x_width y_width]);
    % plotName = strsplit(Istr_cfa_1, "/");
    % plotName = plotName(end);
    saveas(gcf, "../img/POROWNANIE_NearestNeighbour.png");

    %zadanie 3
    figure();
        subplot(2, 3, 1);
            imshow(I1);
            xlabel('Obraz surowy 1');

        subplot(2, 3, 2);
            imshow(Ib1);
            xlabel('Biliniowa 1, PSNR='+string(PSNR1B));

        subplot(2, 3, 3);
            imshow(IGT1);
            xlabel('GT 1');

        subplot(2, 3, 4);
            imshow(I2);
            xlabel('Obraz surowy 2');

        subplot(2, 3, 5);
            imshow(Ib2);
            xlabel('Biliniowa 2, PSNR='+string(PSNR2B));

        subplot(2, 3, 6);
            imshow(IGT2);
            xlabel('GT 2');
    sgtitle('Bilinear interpolation');
    set(gcf, 'PaperUnits', 'centimeters');
    y_width = 9;
    x_width = 15;
    set(gcf, 'PaperPosition', [0 0 x_width y_width]);
    % plotName = strsplit(Istr_cfa_1, "/");
    % plotName = plotName(end);
    saveas(gcf, "../img/POROWNANIE_Bilinear.png");

    %zadanie 5
    figure();
        subplot(2, 5, 1);
            imshow(I1);
            xlabel('Obraz surowy 1');
        
        subplot(2, 5, 2);
            imshow(IGT1);
            xlabel('GT1');
        
        subplot(2, 5, 3);
            imshow(IBGGR1);
            xlabel('Demosaic 1, PSNR='+string(PSNRGBBR1));
        
        subplot(2, 5, 4);
            imshow(Inn1);
            xlabel('NN 1, PSNR='+string(PSNR1NN));
        
        subplot(2, 5, 5);
            imshow(Ib1);
            xlabel('Biliniowa 1, PSNR='+string(PSNR1B));
        
        subplot(2, 5, 6);
            imshow(I2);
            xlabel('Obraz surowy 2');
        
        subplot(2, 5, 7);
            imshow(IGT2);
            xlabel('GT2');
        
        subplot(2, 5, 8);
            imshow(IBGGR2);
            xlabel('Demosaic 2, PSNR='+string(PSNRGBBR2));
        
        subplot(2, 5, 9);
            imshow(Inn2);
            xlabel('NN 2, PSNR='+string(PSNR2NN));
        
        subplot(2, 5, 10);
            imshow(Ib2);
            xlabel('Biliniowa 2, PSNR='+string(PSNR2B));

    sgtitle('ALL Comparison');
    set(gcf, 'PaperUnits', 'centimeters');
    y_width = 12;
    x_width = 25;
    set(gcf, 'PaperPosition', [0 0 x_width y_width]);
    % plotName = strsplit(Istr_cfa_1, "/");
    % plotName = plotName(end);
    saveas(gcf, "../img/POROWNANIE_ALL.png");
end

function [Ib,R,G,B] = biliniowa(I,R,G,B)
[row, col] = size(I);
for j = 1:1:row
for i = 2:1:col-1
if(mod(j,2) == 1 && mod(i,2) == 0)
B(j,i) = (B(j,i-1) + B(j,i+1))/2;
end
if(mod(j,2) == 0 && mod(i,2) == 1)
R(j,i) = (R(j,i-1) + R(j,i+1))/2;
end
end
end
for j = 2:1:row-1
for i = 2:1:col-1
if(mod(j,2) == 1)
R(j,i) = (R(j-1,i-1)+R(j-1,i+1)+R(j+1,i-1)+R(j+1,i+1))/4;
end
if((mod(j,2) == 0) )
B(j,i) = (B(j-1,i-1)+B(j-1,i+1)+B(j+1,i-1)+B(j+1,i+1))/4;
end
if((mod(j,2) == 0 && mod(i,2) == 0) || (mod(j,2) == 1 && mod(i,2) == 1))
G(j,i) = (G(j,i-1)+G(j,i+1)+G(j+1,i)+G(j-1,i))/4;
end
end
end
R = uint8(R);
G = uint8(G);
B = uint8(B);
Ib = cat(3,R,G,B);
end

