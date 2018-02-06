function hamming_weight = hamming_weight_cal(bin_string)
bin_string_length = length(bin_string); % measure the length of binary string
if(bin_string_length ~= 1024) % String length should be 1024
    disp('INFO: The length of the Input bin_string is not 1024'); % Print off that string length is not 1024
end 
hamming_weight = 0; % Initialize the value of hamming_weight to be zero 
for i=1:bin_string_length
    if(bin_string(i)==1)
        hamming_weight = hamming_weight+1; % increment the hamming weight function
    end
end
end