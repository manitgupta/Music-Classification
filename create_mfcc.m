function MFCC_coeff = create_mfcc(song_file_name, COUNT_BINS, COUNT_FRAMES, COUNT_COEFF, STEP_TIME)

% song_file_name is a string specifying a .mp3 or .au audio file.
% MFCC_MATRIX is a matrix of order of No. of Frames X Number of Mel
% Cofficients.
% COUNT_FRAMES is how many frames (20 ms samples) of the song to use.
% COUNT_BINS is how many mel frequency bins to map each frame spectrum to.
% COUNT_COEFF is how many mel coefficients to keep (COUNT_COEFF <= COUNT_BINS).
% STEP_TIME is the frequency after which frame is captured.
%
NUM_SEC = 10;  % take a full 10-second sample (then split into 20ms frames)

format = song_file_name(end-1:end);

if (strcmp(format, 'au'))
    slength = auread(song_file_name, 'size');
    offset = floor(slength(1,1)/3);
    [~, fs] = auread(song_file_name, 1);
    [s, fs] = auread(song_file_name, [offset offset+fs*NUM_SEC]);
elseif (strcmp(format, 'p3'))
    slength = mp3read(song_file_name, 'size');
    offset = floor(slength(1,1)/3);
    [~, fs] = mp3read(song_file_name, [offset offset+1]);
    [s, fs] = mp3read(song_file_name, [offset offset+fs*NUM_SEC]);
else 
    error('Wrong filename input. Use a .mp3 or .au audio file');
end

fft_len = 512;              % length of fft
frame_time = 0.020;         % # seconds/frame
frame_len = floor(fs*frame_time);  % # samples/frame
% STEP_TIME = 0.010;          % # seconds/frame step
step_len = floor(fs*STEP_TIME);    % # samples/frame step

MFCC_coeff = zeros(COUNT_FRAMES, COUNT_COEFF);

window = hamming(frame_len);
stop = 1+floor(fft_len/2);  

[x, ~] = size(s);
begin = floor(x/2);

for i = 1:COUNT_FRAMES
    first = begin + (i-1)*step_len + 1;
    last = begin + (i-1)*step_len + frame_len;
    f = s(first:last);
    heightF = size(f, 1);
    widthF = size(f, 2);
    if (heightF > widthF)
        f = f.*window;
    else
        f = f'.*window;
    end
    f = fft(f, frame_len);
    mel_bins = mel_scale(COUNT_BINS, fft_len, fs);
    f = abs(f(1:stop)).^2; 
    m = log10(mel_bins*f);
    m = dct(m);          % dim(m): COUNT_BINS x 1
    m = m(1:COUNT_COEFF);
    MFCC_coeff(i, :) = m'; 
end
end
