%{
mdl = 'EST';
in = Simulink.SimulationInput('EST')

out = sim(in)
%}
delete 'results.txt';

for i =1:2:100
    %% variables that can be changed 
    StorrageSize = i
    for k = 50:10:100
        efficiency = 1 - k/100;
        file_name='ChanginVars.txt';
        file_id=fopen(file_name,'w');
        fprintf(file_id,'StorrageSize %f\nefficiency %f\n', StorrageSize, efficiency);
        fclose(file_id);
    
        %% solving moddel
        ModelName='EST';
        open_system(ModelName);
        results =sim(ModelName);
    end
end