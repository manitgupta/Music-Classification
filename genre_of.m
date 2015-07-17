function ans = genre_of(mfcc_cells,songname,k)
x = create_mfcc(songname,20,200,15,0.020);
inp_cov = cov(x);
for i = 1:15
    inp_mu(i)=0;
    for j = 1:200
        inp_mu(i) = inp_mu(i) + x(j,i);
    end;
    inp_mu(i) = inp_mu(i)/200;
end;
%col 1 = index in mfcc_cells
%col 2 = distance from input song
%initially set to infinity
k_nearest=inf(k,2);
%size of data set
sz = size(mfcc_cells, 1);
for i = 1:sz
    %find maximum dist in current k-nearest neighbours
    curr_max_index = 1;
    curr_max_dist = k_nearest(1,2);
    for j= 1:k
        if(k_nearest(j,2) > curr_max_dist)
            curr_max_index = j;
            curr_max_dist = k_nearest(j,2);
        end
    end
    %dist of input from ith song from training data
    curr_dist = KL_distance(mfcc_cells{i,1},mfcc_cells{i,2},inp_mu,inp_cov);
    if(curr_dist < curr_max_dist)
        %replace song at curr_max with ith song
        k_nearest(curr_max_index,1) = i;
        k_nearest(curr_max_index,2) = curr_dist;
    end
end
%col 1: jazz
%col 2: classical
%col 3: pop
%col 4: metal
genre_count = zeros(1,4);
%get genre counts from k_nearest
for i = 1:k
    curr_index = k_nearest(i,1);
    curr_genre = mfcc_cells{curr_index,3};
    if(strcmp(curr_genre,'jazz'))
        genre_count(1,1) = genre_count(1,1) + 1;
    elseif(strcmp(curr_genre,'classical'))
            genre_count(1,2) = genre_count(1,2) + 1;
    elseif(strcmp(curr_genre,'pop'))
        genre_count(1,3) = genre_count(1,3) + 1;
        %curr_index
    else
        genre_count(1,4) = genre_count(1,4) + 1;
    end
end
%find which genre is most common
max_count = max(genre_count(1,:));
if(genre_count(1,1) == max_count)
    ans = 'jazz'
elseif(genre_count(1,2) == max_count)
    ans = 'classical'
elseif(genre_count(1,3) == max_count)
    ans = 'pop'
else
    ans = 'metal'
end
end