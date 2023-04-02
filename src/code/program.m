function program(A, rola)
    [Nx,Ny] = size(A);
    %'maxmin'; %pierwszy maksymalizuje, drugi minimalizuje
    %'minmax'; %pierwszy minimalizuje, drugi maksymalizuje
    %--------------------------------------------------
    if rola == 'maxmin'
        A = A';
        [Nx,Ny] = size(A);
    end
    fprintf('\n')

    %gracz pierwszy 
    if rola == 'maxmin'
        fprintf('Gracz maksymalizujacy\n');
    else
        fprintf('Gracz minimalizujacy\n');
    end
    for i = 1:Nx
        Tab_max(i) = max(A(i,:));
    end
    S_D1 = min(Tab_max);
    fprintf('\tStrategie bezpieczne:');
    for i = 1:Nx
        if S_D1 == Tab_max(i)
            fprintf('\ti = %d', i);
        end
    end
    fprintf('\n')
    fprintf('\tPoziom bezpieczeñstwa:\t%d\n\n', S_D1);


    %gracz drugi
    if rola == 'maxmin'
        fprintf('Gracz minimalizujacy\n');
    else
        fprintf('Gracz maksymalizujacy\n');
    end
    for j = 1:Ny
        Tab_min(j) = min(A(:,j));
    end
    S_D2 = max(Tab_min);
    fprintf('\tStrategie bezpieczne:');
    for j = 1:Ny
        if S_D2 == Tab_min(j)
            fprintf('\tj = %d', j);
        end
    end
    fprintf('\n')
    fprintf('\tPoziom bezpieczenstwa:\t%d\n', S_D2);


    if S_D1 == S_D2
        fprintf('Punkt siodlowy istnieje. Poziom bezpiecze?stwa graczy to: %d\n', S_D2);
    end
    if S_D1 ~= S_D2
        fprintf('\n')
        fprintf('Punkt siodlowy nie istnieje.\n');
    end

end