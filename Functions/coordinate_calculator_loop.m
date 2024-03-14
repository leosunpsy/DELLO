function coordinates_matrix = coordinate_calculator_loop(a,b,c,x,y,z,n)
% This function is used for generate the coordinate matrix for each
% contact, a b c are the tip coordinate of each electrode
% x y z are the entry coordinate, you can pick a out skull point on 
% the same electrode, in bioimmage suite, you may use the value of i j k.
% n is the number of contact on each electrode
% 1 unit = 1mm
% diameter of the depth electrode: 0.8mm
% contact length 2mm
% space between 2 contacts 1.5mm
% space btween two contacts center: 3.5mm /3.5 unit

% calcute the coordinates of all contacts on a single electrode 
% using an automated method
shaft_distance = 3.5;
target_pos = [a, b, c];
entry_pos = [x, y, z];
ori = entry_pos - target_pos;
ori = ori/norm(ori);

coordinates_matrix = zeros(n, 3);
for i = 1:n
    coordinates_matrix(i,:) = target_pos + (i-1) * ori * shaft_distance;
end

%%write the coordinates in string format
% L = fprintf(strcat(num2str(a),32,num2str(b),32,num2str(c)));
