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

        self.generate_model()

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

        self.model = ml.model(filepath)


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


