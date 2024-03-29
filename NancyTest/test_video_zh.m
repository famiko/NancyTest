function answer = test_video(char_distance,text_speed, video_gen_name, audio_flag)
tic;
%-----------参数列表----------------------------
raw_video_root_path = 'C:\Users\dbfan\Desktop\';                                                           %设置原始视频根路径
raw_video_account = 2;                                                             %设置视频数目
video_gen_path = ['C:\Users\dbfan\Desktop\', video_gen_name, '.mp4'];                                      %生成视频路径
video_question_path = ['C:\Users\dbfan\Documents\Visual Studio 2017\Projects\NancyTest\NancyTest\video_questions\','1','.mp3'];
raw_chars = char([50:57,65:78,80:90,97:107,109:110,112:122]);                       %ASCII码,2-9,A-N,P-Z,a-k,m-n,p-z,去掉了0,O,o,1,l
str_gen_max = 7;                                                                   %生成字符串最大长度
str_gen_min = 4;                                                                    %生成字符串最短长度
answer_min = 3;                                                                     %答案最短长度
if(audio_flag > 0)
    raw_video_path = getRawVideoPath(-1, raw_video_root_path, raw_video_account);
else
    raw_video_path = getRawVideoPath(2, raw_video_root_path, raw_video_account);
end
str_gen = getString(-1, str_gen_max, str_gen_min, raw_chars);
videoProcess(video_question_path, raw_video_path, video_gen_path, str_gen, text_speed, audio_flag);
answer = str_gen;
toc;
%[answer, index_array] = getAnswer(str_gen, answer_min);
end

%-----------得到答案字符串和索引矩阵----------------------------
function [answer, index_array] = getAnswer(str, min)
index_array = randperm(length(str), min + ceil(rand()*(length(str)-min)));
index_array = sort(index_array);
answer = '';
for i = 1:length(index_array)
    answer = [answer str(index_array(i))];
end
end
%-----------得到待插入字符串----------------------------
function str = getString(n, max, min, chars)
if n <= 0
    count = ceil(rand()*(max - min)) + min;
else
    count = n;
end
str = zeros(1,count);
for i = 1:count
    str(i) = native2unicode([176 + randi(39) 161 + randi(93)]);
end
str = char(str);
end

%-----------得到原始视频路径----------------------------
function path = getRawVideoPath(n, root_path, video_account)
if n > 0
    path = [root_path, int2str(n), '.mp4'];
else
    path = [root_path, int2str(ceil(rand()*video_account)), '.mp4'];
end
end

%--------------视频帧处理-------------------------------------------
function videoProcess(video_question_path, raw_video_path, video_gen_path, str, text_speed, audio_flag)
%--------------获取视频的基本信息-----------------------------------
video_reader = VideoReader(raw_video_path);
video_fps = video_reader.FrameRate;      %帧率
video_frames = video_reader.NumberOfFrames;   %帧数   
video_width = video_reader.Width;            %帧宽
video_height = video_reader.Height;           %帧高
[font_size, position] = getInsertTextMeta(str, video_width, video_height, video_frames, video_fps);
color = randi(255, 1, 3);
persistent fonts;
if isempty(fonts)
    fonts = {'Microsoft YaHei'};
end
font = randsample(fonts, 1);
proportion = video_width/video_frames;

vw = VideoWriter(video_gen_path);%VideoWriter(video_gen_path,'MPEG-4');  %mp4格式，avc(h264)编码方式

vw.FrameRate = video_fps;
open(vw);
for i = 1:video_frames
    image = read(video_reader,i);
    %image = imnoise(image,'speckle',rand(1)/10); %每一帧图像加椒盐噪声
     %imshow(image);
     %设置添加的文本各种属性：位置，大小，颜色
     position(1) = position(1) - text_speed*proportion;
     image = insertText(image, position, str, 'FontSize',font_size,'BoxOpacity',0, 'TextColor', color, 'Font', font{1});
     writeVideo(vw,uint8(image));
    
     
end
close(vw);
end

function [font_size, positon] = getInsertTextMeta(str, video_width, video_height, video_frames, video_fps)
    font_size = 175 + randi(25);
    positon = [video_width  -video_height/4 + randi(video_height/2)];
end