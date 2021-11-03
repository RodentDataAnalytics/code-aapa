function p_formated = format_p_value(p)
    p_rounded = round(p, 4);
    if p_rounded == 0
        p_formated = regexprep(sprintf('%g', round(p, 2, 'significant')), ...
            '(e[+-])0(\d)', '$1$2');
    else
        p_formated = p_rounded;
    end
end

