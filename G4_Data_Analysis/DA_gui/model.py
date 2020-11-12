import scipy as sp 
import numpy as np
import scipy.io as spio
from tkinter import filedialog


class model():

    def __init__(self, mat_filepath=0):
        self.default_filepath = 'default_DA_settings.mat'
        self.daKeys = None

        if mat_filepath == 0:
            mat_filepath = self.default_filepath

        self.filepath = mat_filepath
        da = loadmat(self.filepath)
        self.get_keys()
        self.generate_submodels(da)
        

        

    def get_filepath(self):
        file = filedialog.askopenfilename(initialdir = "/", title = "Select a file")
        self.filepath.set(file)

    def generate_submodels(self, da):
        self.gen_settings = general_model(self, da['gen_settings'])
        self.exp_settings = exp_model(self, da['exp_settings'])
        self.hist_settings = hist_model(self, da['histogram_plot_settings'], self.da['histogram_annotation_settings'], self.da['CL_hist_plot_settings'])
        self.ts_settings = timeseries_model(self, da['timeseries_plot_settings'])
        self.tc_settings = tc_model(self, da['TC_plot_settings'])
        self.mp_settings = mp_model(self, da['MP_plot_settings'])
        self.pos_settings = pos_model(self, da['pos_plot_settings'])
        self.save_settings = save_model(self, da['save_settings'])
        self.comp_settings = comp_model(self, da['comp_settings'])
    
    def get_keys(self):
        
        daKeys = list(self.da.keys())
        nonKeys = []

        for i, key in enumerate(daKeys):
            if key[0] == "_":
                nonKeys.append(i)

        for n in reversed(nonKeys):
            daKeys.pop(n)

        self.daKeys = daKeys


    def open_file(self, filepath):
        
        file = filedialog.askopenfilename(initialdir = "/", title = "Select a file")
        self.filepath.set(file)

    
    def create_default_model(self):
        data = self.default_data

class general_model():

    def __init__(self, parent):
        gen_data = parent.da['gen_settings']


        print(gen_data['legend_fontSize'])

class exp_model():

    def __init__(self, parent, controller, exp_data):

        print(exp_data['trial_options'])

class hist_model():

    def __init__(self, parent, controller, hist_data, hist_ann, hist_CL):

        print(hist_data['inter_in_degrees'])
        print(hist_ann['font_size'])
        print(hist_CL['CL_datatypes'])

class timeseries_model():

    def __init__(self, parent, controller, ts_data):

        print(ts_data['show_individual_flies'])

class tc_model():

    def __init__(self, parent, controller, tc_data):

        print(tc_data['plot_both_directions'])

class mp_model():

    def __init__(self, parent, controller, mp_data):

        print(mp_data['plot_MandP'])

class pos_model():

    def __init__(self, parent, controller, pos_data):

        print(pos_data['plot_pos_averaged'])

class save_model():

    def __init__(self, parent, controller, save_data):

        print(save_data['show_individual_flies'])

class comp_model():

    def __init__(self, parent, controller, comp_data):

        print(comp_data['plot_order'])

# Credit to jpapon on stackoverflow for these three functions
def loadmat(filename):
    # '''
    # this function should be called instead of direct spio.loadmat
    # as it cures the problem of not properly recovering python dictionaries
    # from mat files. It calls the function check keys to cure all entries
    # which are still mat-objects
    # '''
    data = spio.loadmat(filename, struct_as_record=False, squeeze_me=True)
    return _check_keys(data)


def _check_keys(dict):
    # '''
    # checks if entries in dictionary are mat-objects. If yes
    # todict is called to change them to nested dictionaries
    # '''
    for key in dict:
        if isinstance(dict[key], spio.matlab.mio5_params.mat_struct):
            dict[key] = _todict(dict[key])
    return dict        

def _todict(matobj):
    # '''
    # A recursive function which constructs from matobjects nested dictionaries
    # '''
    dict = {}
    for strg in matobj._fieldnames:
        elem = matobj.__dict__[strg]
        if isinstance(elem, spio.matlab.mio5_params.mat_struct):
            dict[strg] = _todict(elem)
        else:
            dict[strg] = elem
    return dict