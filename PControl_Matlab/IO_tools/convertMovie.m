function convertMovie

    N = 16*5;
    M = 16*12;
    K = 16*6;

    vid = VideoReader('tennis.mp4');
    frames = read(vid,[500 1000]);

    ctlr = PanelsController();
    sizeFrames = size(frames);
    numFrames = sizeFrames(4);

    movieFrames = [];

    cnt  = 1; 
    for i = 1:1:numFrames
        rgbFrame = frames(:,:,:,i);
        grayFrame = rgb2gray(rgbFrame);
        grayFrameRz = imresize(grayFrame,[N, K]);
        grayFrameRzScal = 15*double(grayFrameRz)/255;
        grayFrameRzScal = uint8(grayFrameRzScal);
        movieFrames(:,:,cnt) = grayFrameRzScal;

        panelsFrame = zeros(N,M);
        panelsFrame(:,1:K) = grayFrameRzScal;
        movieCmd(cnt).msg = ctlr.getFrameCmd16(panelsFrame);

        imshow(grayFrameRz);
        hold on 
        pause(0.01)
        cnt = cnt + 1;
    end
    save('movieFrames.mat', 'movieFrames');
    save('movieCmd.mat',  'movieCmd');

end
