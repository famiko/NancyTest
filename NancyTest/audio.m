
function y=mix_word(s1, y)
r=randsrc(1,1,[1,2,3,4,5,6]);
%random noise
filepath_r='C:\Users\dbfan\Documents\Visual Studio 2017\Projects\NancyTest\NancyTest\audio_noise\';
filepath_r=strcat(filepath_r,int2str(r));
filepath_r=strcat(filepath_r,'.wav');

% get audio source
filepath_s1='C:\Users\dbfan\Documents\Visual Studio 2017\Projects\NancyTest\NancyTest\audio_files\';
filepath_s1=strcat(filepath_s1,s1);
filepath_s1=strcat(filepath_s1,'.mp3');


[x,fs]=audioread(filepath_r);
x = x/3;


[after1,Fs1]=mixvoice(filepath_s1);
% mix audio and noise
after1=after1(:);
x=x(1:length(after1));
x=x(:);
after2=after1+x;

after2 = after2 * 2;
after2=awgn(after2,15); % add gause noise
a=randsrc(1,1,[1.25,1.5,1.75,2]);
after2=resample(after2,fs,a*fs/1.5); % 重采样
after2=after2/max(abs(after2(:)));
%sound(after2, Fs1)
audiowrite(['C:\Users\dbfan\Documents\Visual Studio 2017\Projects\NancyTest\NancyTest\audio_gen\',y,'.wav'],after2,Fs1);

y=1;



function [s_syn,Fs]=mixvoice(filepath)

    % 定义常数
    FL = 80;                % 帧长
    WL = 240;               % 窗长
    P = 10;                 % 预测系数个数
    [temp, Fs]=audioread(filepath);%temp表示声音数据 Fs表示频率
    handles.y=temp;
    handles.Fs=Fs;
    s = handles.y;
    %s(:,1)=[];  %让第一列为空
    s = s(logical(s));
    s = s/max(s);
    L = length(s);          % 读入语音长度
    FN = floor(L/FL)-2;     % 计算帧数
    % 预测和重建滤波器
    exc = zeros(L,1);       % 激励信号（预测误差）
    zi_pre = zeros(P,1);    % 预测滤波器的状态
    % 合成滤波器
    exc_syn = zeros(L,1);   % 合成的激励信号（脉冲串）
    s_syn = zeros(L,1);     % 合成语音
    zi_syn = zeros(P,1);

    hw = hamming(WL);       % 汉明窗
    for n = 3:FN

        % 计算预测系数（不需要掌握）
        s_w = s(n*FL-WL+1:n*FL).*hw;    %汉明窗加权后的语音
        [A E] = lpc(s_w, P);            %用线性预测法计算P个预测系数
                                        % A是预测系数，E会被用来计算合成激励的能量
        s_f = s((n-1)*FL+1:n*FL);       % 本帧语音，下面就要对它做处理
        

        %用filter函数s_f计算激励，保持滤波器状态
        [exc_1, zi_pre] = filter(A, 1, s_f, zi_pre);
        exc((n-1)*FL+1:n*FL) = exc_1;
        %只有在得到exc后才会计算正确
        s_Pitch = exc(n*FL-222:n*FL);
        PT = findpitch(s_Pitch);    % 计算基音周期PT（不要求掌握）
        G = sqrt(E*PT);           % 计算合成激励的能量G（不要求掌握）
        
        %生成合成激励，并用激励和filter函数产生合成语音
        if n==3
              sta=0;
         end
              while sta <= FL
                     exc_syn((n-1)*FL+sta) = G;
                     sta = sta + PT;
              end
               sta = sta - FL;             
      
          [s_syn((n-1)*FL+1:n*FL),zf] = filter(1,A,exc_syn((n-1)*FL+1:n*FL),zi_syn);
          zi_syn = zf;
    end      
return

% 计算一段语音的基音周期
function PT = findpitch(s)
[B, A] = butter(5, 700/4000);
s = filter(B,A,s);
R = zeros(143,1);
for k=1:143
    R(k) = s(144:223)'*s(144-k:223-k);
end
[R1,T1] = max(R(80:143));
T1 = T1 + 79;
R1 = R1/(norm(s(144-T1:223-T1))+1);
[R2,T2] = max(R(40:79));
T2 = T2 + 39;
R2 = R2/(norm(s(144-T2:223-T2))+1);
[R3,T3] = max(R(20:39));
T3 = T3 + 19;
R3 = R3/(norm(s(144-T3:223-T3))+1);
Top = T1;
Rop = R1;
if R2 >= 0.85*Rop
    Rop = R2;
    Top = T2;
end
if R3 > 0.85*Rop
    Rop = R3;
    Top = T3;
end
PT = Top;
return

