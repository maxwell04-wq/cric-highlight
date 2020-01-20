% Frame Extraction
Wickets_actual = [72 172 178 224 243];
Sixes_actual = [33 225 288];
Fours_actual = [92 255 262 275 339];

obj = VideoReader('vid1.mp4');
numFrames = floor(obj.FrameRate*obj.Duration); %Read the Total number of frames and displyed in     command window 
ST='.jpg';
i=1;

for x = 1:numFrames         %  extracting the frames from video
  rgb = readFrame(obj);
  if rem(x-1, 20)==0        % downsampling
    % Localize words
    imwrite(rgb, strcat(num2str(i),'.jpg'));
    % Grayscale
    gray = 0.2989 * rgb(:,:,1) + 0.5870 * rgb(:,:,2) + 0.1140 * rgb(:,:,3);
    imwrite(gray, strcat('Ig_',num2str(i),'.jpg'));
    BW = im2bw(gray);
   se = strel('rectangle', [25 27]);
    Opening
    I_morph = imopen(BW, se);
    imwrite(I_morph, strcat('Im_',num2str(i),'.jpg'));
    Subtraction
    is = BW-I_morph;
    imwrite(is,  strcat('Is_',num2str(i),'.jpg'));
    Thinning
    I_th = bwmorph(is, 'thin', 2);
    imwrite(I_th,  strcat('It_',num2str(i),'.jpg'));
    Dilation
    BW1 = imdilate(I_th,strel('square',2));
    imwrite(BW1,  strcat('Id_',num2str(i),'.jpg'))
     i=i+1;
   end
 end

%ocr
Scount=zeros(1, floor(numFrames/20)-1);
Wcount=zeros(1, floor(numFrames/20)-1);
roi = [170 662 90 39];

for x=1:floor(numFrames/20-1)
    I = imread(strcat('Ig_', num2str(x),'.jpg'));
    results = ocr(I, roi);
    text = regexp(results.Text,'\d\.?\d*','match');
    score=''; wicket='';
    a = size(text);
    if a(2)>=2
            score = char(text{1});
            wicket = char(text{2});
            Scount(x) = str2double(score);
            Wcount(x) = str2double(wicket);
    else 
        if x~=1 
            Scount(x) = Scount(x-1);
            Wcount(x) = Wcount(x-1);
        end
    end
end

wIndex=[];
for x=2:floor(numFrames/20-1)
    if Wcount(x)-Wcount(x-1)== 1
        wIndex=[wIndex x];
    end
end

fIndex=[];
for x=2:floor(numFrames/20-1)
    if Scount(x)-Scount(x-1)== 4
        fIndex=[fIndex x];
    end
end

sIndex=[];
for x=2:floor(numFrames/20-1)
    if Scount(x)-Scount(x-1)==6
        sIndex=[sIndex x];
    end
end

% Accuracy
wAccuracy =0;

for k = 1:length(wIndex)
    wAccuracy = wAccuracy+~isempty(find(Wickets_actual==wIndex(k)));
end

w_acc = wAccuracy*100/length(Wickets_actual)

sAccuracy =0;

for k = 1:length(sIndex)
    sAccuracy = sAccuracy+~isempty(find(Sixes_actual==sIndex(k)));
end

s_acc = sAccuracy*100/length(Sixes_actual)

fAccuracy =0;

for k = 1:length(fIndex)
    fAccuracy = fAccuracy+~isempty(find(Fours_actual==fIndex(k)));
end

f_acc = fAccuracy*100/length(Fours_actual)
    
event = input('What do you want to watch (fours, sixes, wickets)?', 's');

 if strcmp(event, 'fours')
% Key Event Detection (four)
   threshold=4;
    for x=fIndex
       endTime = x;
       startTime = x-floor(obj.FrameRate*5/10);
       if startTime<=0
            startTime=1;
       end

       vidHeight = 600; %// obj.Height;
       vidWidth = 720; %// obj.Width;

           %// Preallocate movie structure.
            temp(1:numFrames) = struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),'colormap',[]);
            mov = temp(1:endTime-startTime) ;
            indx =1;
            %// Read one frame at a time.
            for k = startTime :endTime
                     IMG = imread(strcat(num2str(k), '.jpg'));
                %// IMG = some_operation(IMG);
                     mov(indx).cdata = imresize(IMG,[vidHeight vidWidth]);
                     indx =indx +1;
             end    
            % // Size a figure based on the video's width and height.
            hf = figure;
            set(hf, 'position', [150 150 vidWidth vidHeight])

            %// Play back the movie once at the video's frame rate.
            movie(hf, mov, 1, obj.FrameRate/10);
       end
end

if strcmp(event, 'sixes')
% Key Event Detection (six)
    threshold=6;
    for x=sIndex
       endTime = x;
       startTime = x-floor(obj.FrameRate*5/10);
       if startTime<=0
            startTime=1;
       end

       vidHeight = 600; %// obj.Height;
       vidWidth = 720; %// obj.Width;

           %// Preallocate movie structure.
            temp(1:numFrames) = struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),'colormap',[]);
            mov = temp(1:endTime-startTime) ;
            indx =1;
            %// Read one frame at a time.
            for k = startTime :endTime
                     IMG = imread(strcat(num2str(k), '.jpg'));
                %// IMG = some_operation(IMG);
                     mov(indx).cdata = imresize(IMG,[vidHeight vidWidth]);
                     indx =indx +1;
             end    
            % // Size a figure based on the video's width and height.
            hf = figure;
            set(hf, 'position', [150 150 vidWidth vidHeight])

            %// Play back the movie once at the video's frame rate.
            movie(hf, mov, 1, obj.FrameRate/10);
       end
end

%Wicket Detection
if strcmp(event, 'wickets')
    for x=wIndex
           endTime = x;
           startTime = x-floor(obj.FrameRate*5);
           if startTime<=0
               startTime=1;
           end

           vidHeight = 500; %// xyloObj.Height;
            vidWidth = 620; %// xyloObj.Width;

           %// Preallocate movie structure.
            temp(1:numFrames) = struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),'colormap',[]);
            mov = temp(1:endTime-startTime) ;
            indx =1;
            %// Read one frame at a time.
            for k = startTime:endTime
                     IMG = imread(strcat(num2str(k), '.jpg'));
                %// IMG = some_operation(IMG);
                     mov(indx).cdata = imresize(IMG,[vidHeight vidWidth]);
                     indx =indx +1;
            end    
            % // Size a figure based on the video's width and height.
            hf = figure;
            set(hf, 'position', [150 150 vidWidth vidHeight])

            %// Play back the movie once at the video's frame rate.
            movie(hf, mov, 1, obj.FrameRate/10);
      end  
end
