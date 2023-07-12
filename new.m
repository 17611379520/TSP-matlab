
function SimulatedAnnealing()
    nCities = 100;  % 城市数量
    initialTemperature = 100;  % 初始温度
    endTemperature = 0;  % 结束温度
    
    cities = rand(nCities, 2) * 10; % 随机生成城市的坐标，范围在[0, 10]之间
    figure  
    plot(cities(:, 1), cities(:, 2), "b--o");  % 画出初始路径
    title('Initial route')
    
    state = OptimiseRoute(cities, initialTemperature, endTemperature);  % 调用优化函数
    
    figure
    plot(cities(state, 1), cities(state, 2), "r--o");  % 画出最优路径
    title('Optimized route')
end


function state = OptimiseRoute(cities, initialTemperature, endTemperature)
    nCities = size(cities, 1);  % 城市数量
    state = randperm(nCities)';  % 随机初始化城市访问顺序
    currentEnergy = CalculateEnergy(state, cities);  % 计算初始状态的能量（路径长度）
    disp('Initial route length: ');
    disp(currentEnergy);
    T = initialTemperature;

    for k = 1:100000  % 主循环
        stateCandidate = GenerateStateCandidate(state);  % 生成一个新的城市访问顺序
        candidateEnergy = CalculateEnergy(stateCandidate, cities);  % 计算新顺序的能量

        if(candidateEnergy < currentEnergy)  % 如果新顺序的能量更低
            state = stateCandidate;  % 接受新顺序
            currentEnergy = candidateEnergy;
        else
            p = GetTransitionProbability(candidateEnergy - currentEnergy, T);  % 否则，根据概率决定是否接受新顺序
            if (IsTransition(p))
                state = stateCandidate;
                currentEnergy = candidateEnergy;
            end
        end
        
        T = DecreaseTemperature(initialTemperature, k);  % 降低温度
        
        if(T <= endTemperature)  % 退出条件
            break;
        end
    end

    disp('Final route length: ');
    disp(currentEnergy);
end


function currentEnergy = CalculateEnergy(state, cities)
    nCities = size(cities, 1);
    currentEnergy = 0;

    for i = 1:nCities-1
        currentCity = state(i);
        nextCity = state(i+1);
        currentEnergy = currentEnergy + Metric(cities(currentCity,:), cities(nextCity,:));
    end
    % add distance between finish and start to return to initial point
    currentEnergy = currentEnergy + Metric(cities(state(end),:), cities(state(1),:));
end

function distance = Metric(A, B) % calculate distance between 2 points
    distance = norm(A - B);
end

function T = DecreaseTemperature(initialTemperature, k)
    T = initialTemperature * 0.1 / k; 
end

function P = GetTransitionProbability(dE, T)
    P = exp(-dE / T);
end

function stateCandidate = GenerateStateCandidate(state)
    nCities = numel(state);
    i = randi(nCities);
    j = randi(nCities);
    while i == j
        j = randi(nCities);
    end
    
    if i > j
        temp = i;
        i = j;
        j = temp;
    end
    
    stateCandidate = state;
    stateCandidate(i:j) = flip(state(i:j));
end

function a = IsTransition(probability)
    a = (rand(1) <= probability);
end