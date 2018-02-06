clc
clear all
fclose all
bin_string_length = 1024; % assign the value to the bin_string_length
bin_string=zeros(1, bin_string_length); % initialize the bit string with all zeros
text_file_ID = fopen('hamming_weight_test_vectors.txt','w+');
for i = 0:((2^31)-1)
    bin_string = de2bi(i,bin_string_length);
    hamming_weight = hamming_weight_cal(bin_string);
    %disp(['The Hamming weight of ',num2str(i),' is ',num2str(hamming_weight)]);
    fprintf(text_file_ID, '%d\n',i);
end
fclose(text_file_ID);