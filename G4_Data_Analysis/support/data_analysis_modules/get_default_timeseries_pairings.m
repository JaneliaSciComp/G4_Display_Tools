function pairs = get_default_timeseries_pairings(exp_settings)

    process_sets_path = exp_settings.path_to_processing_settings;
    proc_settings = load(process_sets_path);
    pairs = proc_settings.settings.condition_pairs;
    

end