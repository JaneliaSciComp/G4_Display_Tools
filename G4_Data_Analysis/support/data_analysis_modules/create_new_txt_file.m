function create_new_txt_file(filepath)

    fid = fopen(filepath, 'wt');
    
    fprintf(fid,'\n');
   
    
    fclose(fid);


end
