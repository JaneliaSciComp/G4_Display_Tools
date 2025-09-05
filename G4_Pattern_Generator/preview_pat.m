function preview_pat(filename)
    [frames, meta] = load_pat(filename);

    nframes = meta.frames;
    rows = meta.rows;
    cols = meta.cols;
    vmax = meta.vmax;

    % Create figure and show first frame
    fig = figure('Name', 'PAT Preview', 'NumberTitle', 'off');
    ax = axes('Parent', fig);
    im = imagesc(frames(:,:,1), [0 vmax]);
    colormap(ax, gray);
    axis(ax, 'image', 'off');
    title(ax, sprintf('%s\nFrame 1 / %d', filename, nframes));
    
    % Add slider
    sld = uicontrol('Style', 'slider', ...
        'Min', 0, 'Max', nframes-1, ...
        'Value', 0, 'SliderStep', [1/(double(nframes)-1) , 10/(double(nframes)-1)], ...
        'Units', 'normalized', ...
        'Position', [0.2 0.05 0.6 0.05]);

    % Update callback
    sld.Callback = @(src,~) updateFrame(round(src.Value)+1, im, frames, ax, filename, nframes);

end
function updateFrame(idx, im, frames, ax, filename, nframes)
    set(im, 'CData', frames(:,:,idx));
    title(ax, sprintf('%s\nFrame %d / %d', filename, idx, nframes));
    drawnow;
end

function [frames, meta] = load_pat(path)
    [NumPatsX, NumPatsY, gs_val, RowN, ColN, raw] = read_header_and_raw(path);
    disp(['RowN = ' num2str(RowN) ', ColN = ' num2str(ColN)])
    
    rows = RowN * 16;
    cols = ColN * 16;
    disp(['rows = ' num2str(rows) ', cols = ' num2str(cols)])
    num_frames = NumPatsX * NumPatsY;
    fsize = frame_size_bytes(RowN, ColN);

    expected = double(fsize) * double(num_frames);
    if numel(raw) < expected
        error('File too short: got %d, expected %d', numel(raw), expected);
    end

    frames = zeros(rows, cols, num_frames, 'uint8');
    for i = 1:num_frames
        vec = raw((double(i)-1)*fsize+1 : double(i)*fsize);
        img = decode_framevector_gs16(vec, rows, cols);
        frames(:,:,i) = img;
    end

    if gs_val == 4 || gs_val == 16
        vmax = 15;
    else
        vmax = 1;
    end

    meta = struct('frames', num_frames, 'rows', rows, 'cols', cols, 'vmax', vmax);
end

function [NumPatsX, NumPatsY, gs_val, RowN, ColN, raw] = read_header_and_raw(path)
    fid = fopen(path, 'rb');
    if fid < 0
        error('Could not open file %s', path);
    end

    header = fread(fid, 7, 'uint8=>uint8');
    if numel(header) < 7
        error('File too short to contain header.');
    end

    % struct.unpack("<HHBBB", header)  → little-endian: 2 ushorts, 3 bytes
    NumPatsX = typecast(uint8(header(1:2)), 'uint16');
    NumPatsY = typecast(uint8(header(3:4)), 'uint16');
    gs_val   = header(5);
    RowN     = header(6);
    ColN     = header(7);

    raw = fread(fid, inf, '*uint8');
    fclose(fid);
end

function fsize = frame_size_bytes(RowN, ColN)
    numSubpanel = 4;
    subpanelMsgLength = 33;
    RowN = double(RowN);
    ColN = double(ColN);
    fsize = double((ColN * subpanelMsgLength + 1) * RowN * numSubpanel);
end

function img = decode_framevector_gs16(framevec, rows, cols)
    numSubpanel = 4;
    subpanelMsgLength = 33;
    % idGrayScale16 = 1;  (unused, same as Python)

    panelCol = cols / 16;
    panelRow = rows / 16;

    img = zeros(rows, cols, 'uint8');

    n = 1;
    for i = 0:panelRow-1
        for j = 1:numSubpanel
            row_header = framevec(n); %#ok<NASGU> % not used further
            n = n + 1;
            for k = 0:subpanelMsgLength-1
                for m = 0:panelCol-1
                    if k == 0
                        % Command byte
                        cmd = framevec(n); %#ok<NASGU>
                        n = n + 1;
                    else
                        byte = framevec(n);
                        n = n + 1;

                        tmp1 = bitand(byte, 15);
                        tmp2 = bitand(bitshift(byte, -4), 15);

                        panelStartRowBeforeInvert = double(i*16 + mod(j-1,2)*8 + floor((k-1)/4));
                        panelStartRow = floor(panelStartRowBeforeInvert/16)*16 + 15 - mod(panelStartRowBeforeInvert,16);
                        panelStartCol = m*16 + floor(j/3)*8 + mod(k-1,4)*2;
                        
                        if panelStartRow >= 0 && panelStartRow < rows
                            img(panelStartRow+1, panelStartCol+1) = tmp1;
                            img(panelStartRow+1, panelStartCol+2) = tmp2;
                        end

                    end
                end
            end
        end
    end
end
