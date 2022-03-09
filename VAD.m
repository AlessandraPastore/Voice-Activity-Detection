for tr=1:5
   
    % open file
    in = strcat("inputaudio",int2str(tr),".data");
    out = strcat("outputVAD",int2str(tr),".txt");

    fin = fopen(in,'r');
    fout = fopen(out,'w');
    
  
    
    % read file
    y = fread(fin,inf,'int8');
    


    % set audio proprerty
    Fs = 8000;  %frequenza di banda
    T = 1/Fs;  %periodo di campinamento
    
    
    L = length(y);  
    t = 0:T:(L*T)-T;    %tenmpo totale
    
%       plot(t,y)
        
    n = 160;

    %n. pacchetti
    np = floor(L/n);    %arrotondamento per difetto

    % array for result n. pacchetti di zeri
    wafc = zeros(np,1);    %(Weighend Average Frequency Component - wafc)
    mdfc = zeros(np,1);    %(Most Dominant Frequency Component- MDFC)
    en = zeros(np,1);      % enager Energy
    res = zeros(np,1);  
    sgn = sign(y);          %segno valori dell'audio
    
    sfm = zeros(np,1);

    threshold = 0;
    minen = 100;
    minM = 200;
    minA = 100;
    maxS = 0;
    silence_count = 0;

    for i=3:np      %da 3 al n.pacchetti tot
        s = 0;

        % short term energy 
        for j=1:n
            m = (i-2)*n+j;
            e = (y(m)^2)/n;
            s = s + e;
        end
        
%           if  i < np-1  %se non siamo al penultimo possiamo fare fft
                
                
                
        % ftt sui 2 precedenti
        % gestione da matlab sito

        X = y(n*(i-3)+1:n*(i));
        L = length(X);
        Y = fft(X);


        P2 = abs(Y/L);
        P1 = P2(1:L/2+1);
        P1(2:end-1) = 2*P1(2:end-1);    
        f = Fs*(0:(L/2))/L ;

%             plot(f,P1);


        %spectral flatness
        spectrum = P1.^2;
        amean = sum(spectrum) / length(spectrum);
        gmean = exp(sum(log(spectrum)) / length(spectrum));

        sp = gmean / amean;


        %%media ponderata e max frequency

%             sum1 = dot(f, P1);
%             sum2 = sum(f); 
%             
% 
%             mean = sum1/sum2;                   %media ponderata

        v = max(P1());                      %frequenza dominante
            
            
%          end
                
        
        % uso i primi 80ms per settare i threshold e i minimi in quanto
        % saranno di silenzio
        if i <= 3 
            
            minen = min(minen, s);
            threshold = max(threshold, s); 
            if(minen ~= 0)
                threshold = threshold * log10(minen);
            end
            
            
            minM = min(minM, v);
%             minA = min(minA, mean);
             maxS = max(maxS, sp);
            
            
            
        else
            en(i) = s - minen > threshold;              %1 o 0 se supera il threshold
%             wafc(i) = mean-minA >= 0.7;                
            mdfc(i) = v-minM >= 0.6;
            sfm(i) = sp+maxS <= 0.6;
            
   
             count = en(i) + mdfc (i) + sfm(i);


            res(i) = count > 1;
            % wrien to file
            fprintf(fout,int2str(res(i)));
            
%             vector = zeros(3,1);
%             vector(2) = 1;
%             if res(i-2:i) == vector
%                 res(i-1) = 0;
%             end
            
            %updaen del min e del threshold per l'energia
            if res(i) == 0
                minen = min(minen,(silence_count * minen + en(i)) / (silence_count + 1));
                silence_count = silence_count + 1;
                if(minen ~= 0)
                    threshold = threshold * log10(minen);
                end
            end

        end
        
    end 
    
    figure
    nexttile
    plot(t,y)
    hold on
    
    x2 = 1:numel(res);
    x2 = x2.*(t(end)/numel(res));
    
    plot(x2, res*100);
    
        
%     player = audioplayer(resulty,Fs);
%     play(player);
    
end    




