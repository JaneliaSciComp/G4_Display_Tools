import tkinter as tk
from tkinter import ttk
import tabs.tabClasses as tc
import layouts.layoutClasses as lc
from tkinter import filedialog
import model as ml

class mainWindow(tk.Tk):

    def __init__(self, *args, **kwargs):

        tk.Tk.__init__(self, *args, **kwargs)

        tabControl = ttk.Notebook(self)
        
        self.title("Data Analysis Designer")

        self.frames = {}

        for F in (mainFrame, lc.layoutTS, lc.layoutTC, lc.layoutCL):
            frame = F(tabControl, self)
            self.frames[F] = frame  

        self.tabs = {}

        for T in (tc.genTab, tc.saveTab, tc.histTab, tc.tsTab, tc.tcTab, tc.mpTab, tc.compTab, tc.appTab):
            tab = T(tabControl, self)
            self.tabs[T] = tab

        tabControl.pack(expand=1, fill="both")

    def show_frame(self, cont):
        frame = self.frames[cont]
        frame.tkraise()

    def hide_frame(self, cont):
        frame = self.frames[cont]
        frame.hidden=0

    def display_variable(self, var):
        print(var.get())

    def update_gui(self):
        #disable and enable all appropriate widgets

        if self.tabs[tc.genTab].group.get() == False:
            self.tabs[tc.genTab].gt_dropdown.configure(state='disabled')
            self.tabs[tc.genTab].group_allBtn.configure(state='disabled')
            self.tabs[tc.genTab].groupType.set('')
            self.tabs[tc.genTab].group_all.set(False)
        else:
            self.tabs[tc.genTab].gt_dropdown.configure(state='normal')
            self.tabs[tc.genTab].group_allBtn.configure(state='normal')
            self.tabs[tc.genTab].groupType.set('Genotype')
            self.tabs[tc.genTab].group_all.set(True)

    
    def generate_model(self, filepath=0):

        self.model = ml.model(self, filepath)


        #single method that checks everything in the gui and disables/enables as needed? 
        #Or each object has its own call back that only disables/enables things dependent on it?
        #Depends on if there are any overlapping - do multiple gui objects disable the same thing? 
        


#    def update_analysis_type(self, var):

class mainFrame(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        #label = tk.Label(self, text="Start Page", font=LARGE_FONT)
        #label.grid(row=10, column=10, sticky="nsew")


app = mainWindow()
app.mainloop()


# #Establish window, window title, and tabbed set up
# root = tk.Tk()
# root.title("Data Analaysis Configuration")
# tabControl = ttk.Notebook(root)

# #Generate each tab
# tabGen = ttk.Frame(tabControl)
# tabSave = ttk.Frame(tabControl)
# tabHist = ttk.Frame(tabControl)
# tabCL = ttk.Frame(tabControl)
# tabTS = ttk.Frame(tabControl)
# tabTC = ttk.Frame(tabControl)
# tabPos = ttk.Frame(tabControl)
# tabComp = ttk.Frame(tabControl)
# tabPlot = ttk.Frame(tabControl)

# #Give each tab a label
# tabControl.add(tabGen, text='General Settings')
# tabControl.add(tabSave, text='Save Settings')
# tabControl.add(tabHist, text='Histograms')
# tabControl.add(tabCL, text='Closed Loop')
# tabControl.add(tabTS, text='Timeseries')
# tabControl.add(tabTC, text='Tuning Curves')
# tabControl.add(tabPos, text='Position Series')
# tabControl.add(tabComp, text='Comparison')
# tabControl.add(tabPlot, text='Plot Appearance')

# tabControl.pack(expand=1, fill="both")

# # ttk.Label(tabGen, text = "Main Settings").grid(column = 0, row = 0, padx = 30, pady = 30)
# # ttk.Label(tabSave, text = "Save Settings").grid(column = 0, row = 0, padx = 30, pady = 30)

# # Using grid, the window is broken up into rows and columns which you use to specify placement of objects.
# # I am setting standard width of each column and row to 50 px each, and using these variables when defining positions
# # This way if I need to spread things out or make them closer together, I can just change these variables and 
# # Everything will stay in the same place relative to everything else. 
# colwidth = 50
# rowwidth = 50

# #Create sub groups in general settings tab
# flags_frame = ttk.LabelFrame(tabGen, height = rowwidth*8, width = colwidth*6, text = "Analysis types")
# flags_frame.grid(row=0, column=0, rowspan = 8, columnspan = 6)

# file_info_frame = ttk.LabelFrame(tabGen, height = rowwidth*4, width = colwidth*10, text="File information")
# file_info_frame.grid(row=0, column=7, rowspan=4, columnspan =10)

# group_frame = ttk.LabelFrame(tabGen, height = rowwidth*4, width = colwidth*4, text = "Group Info")
# group_frame.grid(row=10, rowspan=4, columnspan=4)

# #Create objects in the Flags subgroup in general settings tab



# save_btn = ttk.Button(tabGen, text = "Save Data Analysis Settings")
# save_btn.grid(row=14, column = 17)

# # datatypes_frame = tk.LabelFrame(root, height = rowwidth*4, width = colwidth*8, text="Datatypes")
# # datatypes_frame.grid(row=4, column=5, rowspan=4, columnspan=8)

# # timeseries_frame = tk.LabelFrame(root, height = rowwidth*4, width = colwidth*6, text="Timeseries Options")
# # timeseries_frame.grid(row=9, column=5,rowspan=4, columnspan=6)

# # tc_frame = tk.LabelFrame(root, height = rowwidth*6, width = colwidth*6, text="Tuning Curve Options")
# # tc_frame.grid(row=9, column=11, rowspan=6, columnspan=6)


# root.mainloop()