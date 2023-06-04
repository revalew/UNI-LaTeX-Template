% ----------------------------------------------------------------------------------
%               SAVE THE VALUE OF THE VARIABLE TO THE FILE
% ----------------------------------------------------------------------------------
% SAVE the values for easy LaTeX input
fileID = fopen('./variables/zad_2_part_1/original_k1_' + string(number) + '.txt','w');
fprintf(fileID, '%.4f', k1);
fclose(fileID);

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