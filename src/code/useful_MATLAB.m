% ----------------------------------------------------------------------------------
%               CREATE A DIRECTORY IF IT DOES NOT EXIST
% ----------------------------------------------------------------------------------
global imgDir % Also add this inside the functions so that it can be accessed from there
imgDir = './img/';
if ~exist(imgDir, 'dir')
    mkdir(imgDir);
end

% ----------------------------------------------------------------------------------
%               SAVE THE VALUE OF THE VARIABLE TO THE FILE
% ----------------------------------------------------------------------------------
% SAVE the values for easy LaTeX input
fileID = fopen('./variables/zad_2_part_1/original_k1_' + string(number) + '.txt','w');
fprintf(fileID, '%.4f', k1);
fclose(fileID);

% ----------------------------------------------------------------------------------
%               READ THE VALUE OF THE VARIABLE FROM THE FILE
% ----------------------------------------------------------------------------------
% SAVE the values for easy LaTeX input
fileID = fopen(string(varDir) + string(activationFunc{i}) + '.txt', 'r');
noOfNeurons(i) = fscanf(fileID, '%d');
fclose(fileID);


% ----------------------------------------------------------------------------------
%               LINK ThE AXES TO ZOOM ON ALL SUBPLOTS SIMULTANEOUSLY
% ----------------------------------------------------------------------------------
f = figure('Position', get(0, 'Screensize') - [0 0 60 80]); % Open the figure in "fullscreen" 60 -> width; 80 -> height
        ax(1) = subplot (1, 3, 1);
            imshow(I);
            xlabel("Obraz oryginalny");
        ax(2) = subplot(1, 3, 2);
            imshow(threshI);
            xlabel(["Analiza histogramu"; "Wartość progu: " + num2str(desiredThresh) ]);
        ax(3) = subplot(1, 3, 3);
            imshow(otsuI);
            xlabel(["Metoda Otsu"; "Wartość progu: " + num2str(otsuThresh)]);
        linkaxes(ax)


% ----------------------------------------------------------------------------------
%               EXAMPLE OF THE LABEL FORMATTING WITH MULTIPLE LINES AND REDUCED FONT SIZE
% ----------------------------------------------------------------------------------
figure()
    subplot(1, 5, 1)
    imshow(I1);
    xlabel(['k1 = ' + string(k1) + ', k2 = ' +  string(k2) + ', k3 = ' + string(k3) + ', k4 = ' + string(k4); 'min = ' + string(omin) + ', max = ' + string(omax)], 'FontSize', 10, 'FontUnits', 'points', 'Interpreter', 'none');

% ----------------------------------------------------------------------------------
%               SAVE THE CURRENT FIGURE ON A SPECIFICALLY SIZED CANVAS
%               AND TURN OFF ITS VISIBILITY SO IT WILL NOT BE DISPLAYED WHEN THE CODE IS RUN
% ----------------------------------------------------------------------------------
% save the entire subplot
set(gcf, 'PaperUnits', 'centimeters');
y_width = 15;
x_width = 35;
set(gcf, 'PaperPosition', [0 0 x_width y_width]);
set(gcf, 'visible', 'off');
saveas(gcf, "../img/zad_2_part_1_" + string(number), "png");

% ----------------------------------------------------------------------------------
%               gcf EXPLANATION
% ----------------------------------------------------------------------------------
% The code `set(gcf, 'PaperPosition', [0 0 x_width y_width]);` is used in MATLAB to set the dimensions of a figure when it's printed or saved as an image file such as PDF, PNG or JPG.

% Here's what each parameter means:

% - `gcf` stands for "get current figure" and refers to the currently active figure window.
% - `'PaperPosition'` is a property that specifies the size and location of the printable area on the page.
% - `[0 0 x_width y_width]` is a vector that defines the position and size of the printable area in points (1 point equals 1/72 inch). The first two elements of the vector are the coordinates of the lower-left corner of the page, which are set to (0, 0) for this code to ensure that the figure is aligned with the margins of the page. The last two elements of the vector define the width and height of the printable area in points, which are determined by the variables `x_width` and `y_width`.

% Therefore, this code sets the position and size of the printable area of the currently active figure window to be consistent with the values of `x_width` and `y_width`, which can then be used to print or save the figure with the desired dimensions.


% ----------------------------------------------------------------------------------
%               SAVE THE CURRENT FIGURE AND DO NOT DISPLAY IT
% ----------------------------------------------------------------------------------
% save individual images
figure()
    imshow(I)
    set(gcf, 'visible', 'off');
    saveas(gcf, "../img/zad_2_part_1/Ox_" + string(number), "png");

% ----------------------------------------------------------------------------------
%               SAVE THE CURRENT FIGURE WITH THE NAME BASED ON THE FILE PATH NAME
% ----------------------------------------------------------------------------------
I1 = "../img/CFA_sRGB/IMG_015_srgb_CFA.png";
plotName = strsplit(I1, "/");
plotName = plotName(end);
saveas(gcf, "../img/POROWNANIE_" + plotName{1});

% ----------------------------------------------------------------------------------
%               SAVE THE MATRIX TO A FILE
% ----------------------------------------------------------------------------------
kernel = [-1 -1 -1; -1 8 -1; -1 -1 -1];
writematrix(kernel,'./variables/kernel/kernel_size.txt','Delimiter','tab')


% ----------------------------------------------------------------------------------
%               DISPLAY THE FIGURE IN FULLSCREEN AND SAVE IT
% ----------------------------------------------------------------------------------
f = figure('Position', get(0, 'Screensize')); % Open the figure in "fullscreen"
f = figure('Position', get(0, 'Screensize') - [0 0 60 80]); % Open the figure in "fullscreen" 60 -> width; 80 -> height
    plot(noOfNeurons, ElearnMean, 'LineWidth', 2);
    set(gca, "FontSize", 15);
    hold on
    testResult = plot(noOfNeurons, EtestMean,'LineWidth', 2);
    hold off
    legend('Zbiór uczący', 'Zbiór testowy');
    xlabel('Liczba neuronów');
    ylabel('Średni MSE');
    grid on
    title("MSE - " + string(activationFunc))

    % add the datatip at minimum
    minIndex = find(EtestMean == min(EtestMean));
    datatip(testResult, noOfNeurons(minIndex), EtestMean(minIndex));

    saveas(f, string(imgDir) + "MSE_" + string(activationFunc) + ".png");

    
% ----------------------------------------------------------------------------------
%               COMPOSE A LEGEND FORM AN ARRAY OF STRINFGS
% ----------------------------------------------------------------------------------
activationFunc = {'tansig', 'logsig', 'purelin'};
plotLegend = ['Prawdziwa funkcja', 'Model neuronowy ' + string(activationFunc)];
legend(plotLegend)
% legend('Prawdziwa funkcja', 'Model neuronowy ' + string(activationFunc{1}), 'Model neuronowy ' + string(activationFunc{2}), 'Model neuronowy ' + string(activationFunc{3}));