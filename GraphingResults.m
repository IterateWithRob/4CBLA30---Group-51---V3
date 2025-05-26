u% Read data from results.txt
filename = 'results.txt';
fid = fopen(filename, 'r');
data = textscan(fid, 'StorrageSize: %f, losses: %f, Ebuy: %f, Esell: %f');
fclose(fid);

% Extract columns
StorageSize = data{1};
losses = data{2};
Ebuy = data{3};
Esell = data{4};

% Unique losses
unique_losses = unique(losses);

% Set up figure
figure;
colors = lines(length(unique_losses)); % distinct colors

% --- Subplot 1: Ebuy ---
subplot(2,1,1);
hold on;
for i = 1:length(unique_losses)
    idx = losses == unique_losses(i);
    plot(StorageSize(idx), Ebuy(idx), '-', 'DisplayName', sprintf('Loss %.1f', unique_losses(i)), 'Color', colors(i,:));
end
xlabel('Storage Size');
ylabel('Ebuy (Energy Purchased)');
title('Energy Purchased (Ebuy) vs Storage Size');
legend('Location', 'bestoutside');
grid on;
hold off;

% --- Subplot 2: Esell ---
subplot(2,1,2);
hold on;
for i = 1:length(unique_losses)
    idx = losses == unique_losses(i);
    plot(StorageSize(idx), Esell(idx), '-', 'DisplayName', sprintf('Loss %.1f', unique_losses(i)), 'Color', colors(i,:));
end
xlabel('Storage Size');
ylabel('Esell (Energy Sold)');
title('Energy Sold (Esell) vs Storage Size');
legend('Location', 'bestoutside');
grid on;
hold off;