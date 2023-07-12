function SimulatedAnnealing()
    nCities = 100;
    initialTemperature = 100;
    endTemperature = 0;

    cities = rand(nCities, 2) * 10; % 设置2维坐标的初始城市位置

    figure % 创建新的绘图窗口
    plot(cities(:, 1), cities(:, 2), "b--o"); % 绘制初始路线
    title('Initial route')

    state = OptimiseRoute(cities, initialTemperature, endTemperature); % 调用优化函数

    figure % 创建新的绘图窗口
    plot(cities(state, 1), cities(state, 2), "r--o"); % 绘制1-opt优化后的路线
    title('1-opt Optimized route')
    
    state2opt = TwoOptOptimize(state, cities); % 使用2-opt优化算法得到初始路线
    
    figure % 创建新的绘图窗口
    plot(cities(state2opt, 1), cities(state2opt, 2), "g--o"); % 绘制2-opt优化后的路线
    title('2-opt Optimized route')
end

function [state] = OptimiseRoute(cities, initialTemperature, endTemperature)
    nCities = size(cities, 1);
    state = [1:nCities]'; % 使用编号作为初始的访问顺序
    currentEnergy = CalculateEnergy(state, cities); % 计算初始情况下的能量
    disp('Initial route length: ');
    disp(currentEnergy);

    T = initialTemperature;

    for k = 1:5000 % 运行5000次的优化算法循环
        stateCandidate = GenerateStateCandidate(state); % 创建新的城市访问顺序
        candidateEnergy = CalculateEnergy(stateCandidate, cities); % 计算新顺序的能量

        if (candidateEnergy < currentEnergy) % 如果新顺序具有更低的能量
            state = stateCandidate; % 将其设为当前顺序
            currentEnergy = candidateEnergy;
        else
            p = GetTransitionProbability(candidateEnergy - currentEnergy, T); % 否则，计算转移概率
            if (IsTransition(p)) % 如果以一定概率进行转移
                state = stateCandidate; % 接受新顺序
                currentEnergy = candidateEnergy;
            end
        end

        T = DecreaseTemperature(initialTemperature, k);

        if (T <= endTemperature) % 退出条件
            break;
        end
    end

    disp('Final route length after 1-opt optimization: ');
    disp(currentEnergy);
end

function [state2opt] = TwoOptOptimize(state, cities)
    state2opt = TwoOpt(state, cities); % 使用2-opt优化算法得到初始路线
    
    for k = 1:500 % 运行500次的2-opt优化算法
        state2opt = TwoOpt(state2opt, cities);
    end
    
    disp('Final route length after 2-opt optimization: ');
    disp(CalculateEnergy(state2opt, cities));
end

function [state] = TwoOpt(state, cities)
    improved = true;
    energy = CalculateEnergy(state, cities);

    while improved
        improved = false;
        
        for i = 1:length(state) - 2
            for j = i + 2:length(state) - 1
                newState = TwoOptSwap(state, i, j);

                newEnergy = CalculateEnergy(newState, cities);
                
                if newEnergy < energy
                    state = newState;
                    energy = newEnergy;
                    improved = true;
                end
            end
        end
    end
end

function [newState] = TwoOptSwap(state, i, j)
    newState = state;
    newState(i+1:j) = flip(state(i+1:j));
end

% 剩下的函数保持不变
function [E] = CalculateEnergy(sequence, cities)
    n = size(sequence, 1);
    E = 0;

    for i = 1:n - 1
        E = E + Metric(cities(sequence(i), :), cities(sequence(i + 1), :));
    end

    E = E + Metric(cities(sequence(end), :), cities(sequence(1), :));
end

function [distance] = Metric(A, B)
    distance = sqrt(sum((A - B).^2));
end

function [T] = DecreaseTemperature(initialTemperature, k)
    T = initialTemperature * 0.1 / k;
end

function [P] = GetTransitionProbability(dE, T)
    P = exp(-dE / T);
end

function [a] = IsTransition(probability)
    if (rand(1) <= probability)
        a = 1;
    else
        a = 0;
    end
end

function [seq] = GenerateStateCandidate(seq)
    n = size(seq, 1);
    i = randi(n);
    j = randi(n);

    % 交换两个城市
    [seq(i), seq(j)] = deal(seq(j), seq(i));
end