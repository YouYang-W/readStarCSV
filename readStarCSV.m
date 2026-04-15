function T = readStarCSV(filename)
%READSTARCSV 读取 STAR-CCM+ 输出的 .csv 文件为 table
%
%   T = readStarCSV(filename)
%
%   输入：
%       filename - .csv 文件完整路径
%
%   输出：
%       T - table，自动清理列名中的特殊字符

    opts = detectImportOptions(filename);
    opts.ExtraColumnsRule = 'ignore';
    opts.VariableNamingRule = 'preserve';
    
    T = readtable(filename, opts);
    
    varNames = T.Properties.VariableNames;
    newNames = cell(size(varNames));
    for i = 1:numel(varNames)
        name = varNames{i};
        if contains(name, ':')
            parts = strsplit(name, ':');
            name = parts{end};
        end
        name = strtrim(name);
        name = lower(name);
        name = strrep(name, ' ', '_');
        name = strrep(name, '-', '_');
        name = strrep(name, '(', '');
        name = strrep(name, ')', '');
        name = strrep(name, '/', '_');
        if isempty(name) || ~isletter(name(1))
            name = ['col_' num2str(i)];
        end
        newNames{i} = name;
    end
    T.Properties.VariableNames = newNames;

    fprintf('✅ 成功读取CSV文件!!：%s\n', filename);
end