function create_pdf_report(output, folderpath, plot_type_order, norm_order)


    ordered_files = order_pdfs(plot_type_order, norm_order, folderpath);
    
    for file = 1:length(ordered_files)
        if ~strcmp(ordered_files{file}(end-3:end),'.pdf')
            ordered_files(file) = [];
            disp("File number " + num2str(file) + "removed because it was not a .pdf");
        end
    end
    
    for file2 = 1:length(ordered_files)
        ordered_files{file2} = fullfile(folderpath, ordered_files{file2});
    end
    
    append_pdfs(output, ordered_files{:});
        

end