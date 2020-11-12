import tkinter as tk
from tkinter import ttk
from tkinter import colorchooser
import buttons.buttonClasses as bn
import numpy as np
import layouts.layoutClasses as lo


LARGE_FONT = ("Verdana", 12)
ROW_SIZE = 50
COL_SIZE = 50

class genTab(tk.Frame):
    
    def __init__(self, parent, controller):

        tab = ttk.Frame(parent)
        parent.add(tab, text="General Settings")

        #The three major label frames making up this tab
        flags_frame = ttk.LabelFrame(tab, height = ROW_SIZE*8, width = COL_SIZE*6, 
        text = "Analysis Type", borderwidth=10)
        flags_frame.grid(row=0, column=0, rowspan = 8, columnspan = 12, padx = 10, pady = 10, 
        sticky="NW")

        gen_frame = ttk.LabelFrame(tab, height = ROW_SIZE*6, width = COL_SIZE*12, 
        text = "General Settings", borderwidth=10)
        gen_frame.grid(row=8, column = 0, rowspan = 6, columnspan=12, padx = 10, pady = 10, 
        sticky="NW")

        grouping_fields_frame = ttk.LabelFrame(tab, height = ROW_SIZE, width = COL_SIZE*12, 
        text="Group flies by fields:", borderwidth=10)
        grouping_fields_frame.grid(row=0, column=12, columnspan=12, padx = 10, pady = 20, sticky="W")

        all_groups_frame = ttk.LabelFrame(tab, height = ROW_SIZE*4, width = COL_SIZE*12,
        text="Include all groups", borderwidth=10)
        all_groups_frame.grid(row=1, column=12, rowspan=5, columnspan=12, padx=10, pady=20, sticky="W")

        grouping_values_frame = ttk.LabelFrame(tab, height = ROW_SIZE, width = COL_SIZE*12,
        text="Field values to include:", borderwidth=10)
        grouping_values_frame.grid(row=7, rowspan=6, column=12, columnspan=12, padx=10, pady=20, sticky="W")

        save_file_button = ttk.Button(tab, text="Save Settings File")
        run_analysis_button = ttk.Button(tab, text="Run Analysis Now")

        save_file_button.grid(row=13, column=19, sticky="E")
        run_analysis_button.grid(row=13, column=20, sticky="E")

        #starting row and column positions for each item in the frame
        flags_row = 0
        flags_col = 0
        group_row = 0
        group_col = 0
        gen_row = 0
        gen_col = 0

# STUFF INSIDE THE ANALYSIS TYPE FRAME

        # Button group for group analysis or single fly analysis
        self.group = tk.BooleanVar()
        self.group.set(True)
        groupBtn = ttk.Radiobutton(flags_frame, text="Group of flies", variable=self.group, value=True, 
        command=lambda: controller.update_gui())
        groupBtn.grid(row=0, column=0, padx = 10, pady = 10, sticky = "W")
        singleBtn = ttk.Radiobutton(flags_frame, text="Single fly", variable=self.group, value=False, 
        command=lambda: controller.update_gui())
        singleBtn.grid(row=0, column=1, padx = 10, pady = 10, sticky="W")

        # List of options for type of analysis

        self.basicHist = tk.BooleanVar()
        self.basicHist.set(False)
        self.clHist = tk.BooleanVar()
        self.clHist.set(False)
        self.tsPlot = tk.BooleanVar()
        self.tsPlot.set(False)
        self.tcPlot = tk.BooleanVar()
        self.tcPlot.set(False)
        self.posPlot = tk.BooleanVar()
        self.posPlot.set(False)
        self.mpPlot = tk.BooleanVar()
        self.mpPlot.set(False)
        self.compPlot = tk.BooleanVar()
        self.compPlot.set(False)
        
        # Group of checkboxes to choose types of analysis
        basicHistBtn = ttk.Checkbutton(flags_frame, text="Basic Histograms", variable = self.basicHist,  command=lambda: controller.display_variable(self.basicHist))
        basicHistBtn.grid(row=1, column=0, padx=5, pady=5, sticky="W")
        clHistBtn = ttk.Checkbutton(flags_frame, text="Closed-Loop Histograms", variable = self.clHist,  command=lambda: controller.display_variable(self.clHist))
        clHistBtn.grid(row=2, column=0, padx=5, pady=5, sticky="W")
        tsPlotBtn = ttk.Checkbutton(flags_frame, text="Timeseries Plots", variable = self.tsPlot,  command=lambda: controller.display_variable(self.tsPlot))
        tsPlotBtn.grid(row=3, column=0, padx=5, pady=5, sticky="W")
        tcPlotBtn = ttk.Checkbutton(flags_frame, text="Tuning Curves", variable = self.tcPlot,  command=lambda: controller.display_variable(self.tcPlot))
        tcPlotBtn.grid(row=4, column=0, padx=5, pady=5, sticky="W")
        posPlotBtn = ttk.Checkbutton(flags_frame, text="Position Series", variable = self.posPlot,  command=lambda: controller.display_variable(self.posPlot))
        posPlotBtn.grid(row=5, column=0, padx=5, pady=5, sticky="W")
        mpPlotBtn = ttk.Checkbutton(flags_frame, text="Motion and Position Functions", variable = self.mpPlot,  command=lambda: controller.display_variable(self.mpPlot))
        mpPlotBtn.grid(row=6, column=0, padx=5, pady=5, sticky="W")
        compPlotBtn = ttk.Checkbutton(flags_frame, text="Comparison Plot", variable = self.compPlot,  command=lambda: controller.display_variable(self.compPlot))
        compPlotBtn.grid(row=7, column=0, padx=5, pady=5, sticky="W")

        
# STUFF INSIDE THE GENERAL SETTINGS FRAME

       
        # Items inside the general settings frame

        #Variables set in this section
        self.protocol_path = tk.StringVar()
        self.save_path = tk.StringVar()
        self.save_filename = tk.StringVar()
        self.processed_filename = tk.StringVar()
        self.name_of_analysis  = tk.StringVar()
        self.plot_unnormalized = tk.BooleanVar()
        self.pretrial = tk.BooleanVar()
        self.intertrial = tk.BooleanVar()
        self.posttrial = tk.BooleanVar()
        
        

        #create all labels and objects in this frame iteratively so they're easy to move around
        self.pretrial.set(True)
        self.intertrial.set(True)
        self.posttrial.set(True)
        pretrial_check = ttk.Checkbutton(gen_frame, text="Pretrial?", variable=self.pretrial)
        intertrial_check = ttk.Checkbutton(gen_frame, text="Intertrial?", variable=self.intertrial)
        posttrial_check = ttk.Checkbutton(gen_frame, text="Posttrial?", variable=self.posttrial)

        pretrial_check.grid(row=gen_row, column=gen_col, columnspan=2, sticky="W")
        intertrial_check.grid(row=gen_row, column=gen_col+2, columnspan=2, sticky="W")
        posttrial_check.grid(row=gen_row, column=gen_col + 4, columnspan=2, sticky="W")

        gen_row = gen_row + 1
        
        ttk.Label(gen_frame, text="Name of Analysis").grid(row=gen_row, column=gen_col, columnspan=2, sticky="W")
        analysisNameBox = ttk.Entry(gen_frame, textvariable=self.name_of_analysis)
        analysisNameBox.grid(row=gen_row, column=gen_col+2, columnspan=2, sticky="W")

        gen_row  = gen_row + 1

        ttk.Label(gen_frame, text="Path to protocol: ").grid(row=gen_row, column=gen_col, columnspan=2, sticky="W")
        self.protocol_browse = bn.browseFile(gen_frame, self, gen_row, gen_col + 2)

        gen_row = gen_row + 1

        ttk.Label(gen_frame, text="Settings Save Path: ").grid(row=gen_row, column=gen_col, columnspan=2, sticky="W")
        self.save_browse = bn.browseFile(gen_frame, self, gen_row, gen_col + 2)

        gen_row = gen_row + 1

        ttk.Label(gen_frame, text="Settings Save Filename: ").grid(row=gen_row, column=gen_col, columnspan=2, sticky="W")
        saveFnTextBox = ttk.Entry(gen_frame, textvariable=self.save_filename)
        saveFnTextBox.grid(row=gen_row, column=gen_col + 2, columnspan=2, sticky="W")

        gen_row = gen_row + 1

        ttk.Label(gen_frame, text="Processed File Name: ").grid(row=gen_row, column=gen_col, columnspan=2, sticky="W")
        processedBox = ttk.Entry(gen_frame, textvariable=self.processed_filename)
        processedBox.grid(row=gen_row, column=gen_col + 2, columnspan=2, sticky="W")

        gen_row = gen_row + 1

        unnormBox = ttk.Checkbutton(gen_frame, text="Plot unnormalized data?", variable=self.plot_unnormalized)
        unnormBox.grid(row=gen_row, column=gen_col, columnspan=2, sticky="W")

        #Save settings button

        # saveBtn = ttk.Button(tab, text="Save Settings File", command=self.update_variables)
        # saveBtn.grid(row=13, column=19, columnspan=2, sticky="E")

# STUFF INSIDE THE GROUPING FRAMES

        self.groupDDs = []
        self.groupEntries = []
        self.groupFields = []
        self.groupValues = []
        self.ddCount = 1
        self.groupCount = 1
        self.controlString = tk.StringVar()
        self.controlString.set('')
        self.groupLabelEntries = []
        self.groupLabels = []

        self.group_all = tk.BooleanVar()
        self.group_all.set(True)

        self.control_group = tk.StringVar()

        self.single_group = tk.BooleanVar()
        self.single_group.set(False)

        self.groupDDs.append( bn.addGroupField(grouping_fields_frame, self, group_row, group_col, self.ddCount) )
        self.groupFields.append( self.groupDDs[0].value.get() )

        self.group_allBtn = ttk.Checkbutton(all_groups_frame, text="Analyize all groups?", variable = self.group_all, 
        command=lambda: self.update_all_groups())
        self.group_allBtn.grid(row=group_row, column=group_col, padx=5, pady=5, sticky="W")

        ttk.Label(all_groups_frame, text="Control Value:").grid(row=group_row, column=group_col+1,  sticky="W")
        self.control_entry = ttk.Entry(all_groups_frame, textvariable=self.controlString)

        self.control_entry.grid(row=group_row, column=group_col+2, sticky="W")

        group_row =  group_row + 1
        self.add_labelBtn = ttk.Button(all_groups_frame, text="Add Group Label", command=lambda: self.add_group_label(all_groups_frame))
        self.add_labelBtn.grid(row=group_row, column=group_col, sticky="W")
        self.remove_labelBtn = ttk.Button(all_groups_frame, text="Remove Group Label", command=lambda: self.remove_group_label())
        self.remove_labelBtn.grid(row=group_row, column=group_col+1, sticky="W")

        self.groupEntries.append( bn.addGroup(grouping_values_frame, self, group_row, group_col, self.groupCount) )
        self.groupEntries[0].textBoxes[0].config(state='disabled')
        self.groupEntries[0].addGroupBtn.config(state='disabled')
        self.groupEntries[0].removeGroupBtn.config(state='disabled')
        self.groupEntries[0].addValBtn.config(state='disabled')
        self.groupEntries[0].removeValBtn.config(state='disabled')
        self.groupEntries[0].controlBtn.config(state='disabled')
        self.groupEntries[0].labelEntry.config(state='disabled')


    def add_group_field(self, parent, row, col):
        self.groupDDs[self.ddCount-1].add_button.grid_remove()
        self.groupDDs[self.ddCount-1].remove_button.grid_remove()
        self.ddCount = self.ddCount + 1
        self.groupDDs.append( bn.addGroupField(parent, self, row, col, self.ddCount))
        self.groupFields.append( self.groupDDs[self.ddCount-1].value.get() )

    def remove_group_field(self):
        self.groupDDs[self.ddCount-1].remove_button.grid_forget()
        self.groupDDs[self.ddCount-1].add_button.grid_forget()
        self.groupDDs[self.ddCount-1].gt_dropdown.grid_forget()
        deleted_obj = self.groupDDs.pop()
        deleted_val = self.groupFields.pop()
        self.ddCount = self.ddCount - 1
        self.groupDDs[self.ddCount-1].add_button.grid()
        self.groupDDs[self.ddCount-1].remove_button.grid()


    def add_group(self, parent, row, col):
        self.groupEntries[self.groupCount-1].addGroupBtn.grid_remove()
        self.groupEntries[self.groupCount-1].removeGroupBtn.grid_remove()
        num_vals = self.groupEntries[self.groupCount-1].values_count
        print(num_vals)
        self.groupCount = self.groupCount + 1
        self.groupEntries.append( bn.addGroup(parent, self, row, col, self.groupCount) )
        if num_vals > 1:
            for val in range(1,num_vals):
                self.groupEntries[self.groupCount-1].add_value()
        

    def remove_group(self):
        print(self.groupCount)
        if self.groupCount > 1:
            self.groupEntries[self.groupCount-1].addGroupBtn.grid_forget()
            self.groupEntries[self.groupCount-1].removeGroupBtn.grid_forget()
            self.groupEntries[self.groupCount-1].addValBtn.grid_forget()
            self.groupEntries[self.groupCount-1].removeValBtn.grid_forget()
            self.groupEntries[self.groupCount-1].controlBtn.grid_forget()
            self.groupEntries[self.groupCount-1].labelLabel.grid_forget()
            self.groupEntries[self.groupCount-1].labelEntry.grid_forget()
            for tb in self.groupEntries[self.groupCount-1].textBoxes:
                tb.grid_forget()
            deleted_entry  = self.groupEntries.pop()
            self.groupCount = self.groupCount - 1
            self.groupEntries[self.groupCount-1].addGroupBtn.grid()
            self.groupEntries[self.groupCount-1].removeGroupBtn.grid()
 
        

    def update_all_groups(self):
        
        if self.group_all.get() == False:
            
            self.groupEntries[0].textBoxes[0].config(state='enabled')
            self.groupEntries[0].addGroupBtn.config(state='enabled')
            self.groupEntries[0].removeGroupBtn.config(state='enabled')
            self.groupEntries[0].addValBtn.config(state='enabled')
            self.groupEntries[0].removeValBtn.config(state='enabled')
            self.groupEntries[0].controlBtn.config(state='enabled')
            self.groupEntries[0].labelEntry.config(state='enabled')
            self.control_entry.config(state='disabled')

            if len(self.groupLabelEntries) > 0:
                for e in self.groupLabelEntries:
                    e.grid_forget()
                
            self.groupLabelEntries = []
            self.groupLabels = []
            self.add_labelBtn.grid(row=1, column=0)
            self.remove_labelBtn.grid(row=1, column=1)
            self.add_labelBtn.config(state='disabled')
            self.remove_labelBtn.config(state='disabled')

        else: 
            
            if self.groupCount > 1:
                newList = []
                newList.append(self.groupEntries[0])

                for g in range(1,len(self.groupEntries)):

                    self.remove_group()

                self.groupEntries = newList
                if len(self.groupEntries[0].textBoxes) > 1:
                    for t in range(1, len(self.groupEntries[0].textBoxes)):
                        
                        self.groupEntries[0].remove_value()
                
            self.groupEntries[0].addGroupBtn.grid()
            self.groupEntries[0].removeGroupBtn.grid()
            self.groupEntries[0].textBoxes[0].config(state='disabled')
            self.groupEntries[0].addGroupBtn.config(state='disabled')
            self.groupEntries[0].removeGroupBtn.config(state='disabled')
            self.groupEntries[0].addValBtn.config(state='disabled')
            self.groupEntries[0].removeValBtn.config(state='disabled')
            self.groupEntries[0].controlBtn.config(state='disabled')
            self.groupEntries[0].labelEntry.config(state='disabled')
            self.control_entry.config(state='enabled')
            self.add_labelBtn.config(state='enabled')
            self.remove_labelBtn.config(state='enabled')
            

    def update_variables(self):
        self.protocol_path.set(self.protocol_browse.filename.get())
        print(self.protocol_path.get())
        self.save_path.set(self.save_browse.filename.get())
        print(self.save_path.get())
        print(self.save_filename.get())
        for f in self.grouping_Frame.groupFields:
            self.group_values.append(f.group_value.get())
            self.group_fields.append(f.groupFields)
        print(self.group_values)

    def add_group_label(self, parent):
        num_labels = len(self.groupLabelEntries)
        row=1
        col=num_labels

        self.groupLabels.append('')    
        self.groupLabelEntries.append( ttk.Entry(parent,  textvariable=self.groupLabels[num_labels]) )
        self.groupLabelEntries[num_labels].grid(row=row, column=col)
        self.add_labelBtn.grid(row=row, column=col+1)
        self.remove_labelBtn.grid(row=row, column=col+2)

    def remove_group_label(self):
        deletedEntry = self.groupLabelEntries.pop()
        deletedEntry.grid_forget()
        deletedLabel = self.groupLabels.pop()
        num_labels = len(self.groupLabels)
        if num_labels != 0:
            self.add_labelBtn.grid(row=1, column=num_labels+1)
            self.remove_labelBtn.grid(row=1, column=num_labels+2)
        else:
            self.add_labelBtn.grid(row=1, column=0)
            self.remove_labelBtn.grid(row=1, column=1)


class saveTab(ttk.Notebook):
    def __init__(self, parent, controller):

        tab = ttk.Frame(parent)
        parent.add(tab, text="Save Settings")

        # Frames
        file_frame = ttk.LabelFrame(tab, text="File settings")
        file_frame.grid(row=0, column=0, rowspan=5, columnspan=3, padx=10, pady=10, sticky="NW")

        report_frame = ttk.LabelFrame(tab, text="Paths and report settings")
        report_frame.grid(row=6, column=0, rowspan=5, columnspan=2, padx=10, pady=10, sticky="NW")

        # Initialize row/col values of first item in each frame.
        report_row = 0
        report_col = 0
        file_row = 0
        file_col = 0

        # Initialize variables

        self.protocol_path = tk.StringVar(value="")
        self.save_path = tk.StringVar(value="")
        self.report_path = tk.StringVar(value="")

        self.plot_type_order = []
        self.plot_type_order.append(tk.StringVar(value="hist"))
        self.plot_type_order.append(tk.StringVar(value="timeseries"))
        self.plot_type_order.append(tk.StringVar(value="TC"))
        self.plot_type_order.append(tk.StringVar(value="M"))
        self.plot_type_order.append(tk.StringVar(value="P"))
        self.plot_type_order.append(tk.StringVar(value="MeanPositionSeries"))
        self.plot_type_order.append(tk.StringVar(value="Comparison"))

        self.norm_order = []
        self.norm_order.append(tk.StringVar(value="unnormalized"))
        self.norm_order.append(tk.StringVar(value="normalized"))

        self.paperunits = tk.StringVar(value="inches")
        self.x_width = tk.IntVar(value=8)
        self.y_width = tk.IntVar(value=10)
        self.orientation = tk.StringVar(value="landscape")
        self.high_resolution = tk.IntVar(value=0)

        # Create file settings objects

        ttk.Label(file_frame, text="Path to the Protocol:").grid(row = file_row, column=file_col, sticky="W")
        self.protocol_browse = bn.browseFile(file_frame, self, file_row, file_col + 2)

        file_row = file_row + 1

        ttk.Label(file_frame, text="Where to save the results:").grid(row=file_row, column=file_col, sticky="W")
        self.save_browse = bn.browseFile(file_frame, self, file_row, file_col + 2)

        file_row = file_row + 1

        ttk.Label(file_frame, text="Path of final report:").grid(row=file_row, column=file_col, sticky="W")
        self.report_browse = bn.browseFile(file_frame, self, file_row, file_col + 2)

        file_row = file_row + 1

        ttk.Label(file_frame, text="Paper Units:").grid(row=file_row, column=file_col, sticky="W")
        self.paperunits_dd = ttk.Combobox(file_frame, width=18, textvariable=self.paperunits)
        self.paperunits_dd['values'] = ('inches', 'normalized', 'centimeters', 'points')
        self.paperunits_dd.grid(row=file_row, column = file_col + 2,  sticky="E")

        file_row = file_row + 1

        ttk.Label(file_frame, text="PDF Orientation:").grid(row = file_row, column=file_col, sticky="W")
        self.orientation_dd = ttk.Combobox(file_frame, width=18, textvariable=self.orientation)
        self.orientation_dd['values'] = ('landscape', 'portrait')
        self.orientation_dd.grid(row = file_row, column = file_col + 2, sticky="E")

        file_row = file_row + 1

        ttk.Label(file_frame, text = "Figure x width:").grid(row=file_row, column=file_col, sticky="W")
        self.x_width_dd = ttk.Combobox(file_frame, width=18, textvariable=self.x_width)
        self.x_width_dd['values'] = (4, 6, 8, 10, 12, 14)
        self.x_width_dd.grid(row=file_row, column = file_col + 2, sticky="E")

        file_row = file_row + 1

        ttk.Label(file_frame, text = "Figure y width:").grid(row=file_row, column=file_col, sticky="W")
        self.y_width_dd = ttk.Combobox(file_frame, width=18, textvariable=self.y_width)
        self.y_width_dd['values'] = (4, 6, 8, 10, 12, 14)
        self.y_width_dd.grid(row=file_row, column = file_col + 2, sticky="E")

        file_row = file_row + 1

        resolution_btn = ttk.Checkbutton(file_frame, text="High Resolution?", variable = self.high_resolution)
        resolution_btn.grid(row=file_row, column=file_col, sticky="W")

        # create report settings objects

        ttk.Label(report_frame, text="Order of plot types").grid(row=report_row, column=report_col, sticky="W")
        ttk.Label(report_frame, text="in PDF report:").grid(row=report_row + 1, column=report_col, sticky="W")
        self.plot_order_dd1 = ttk.Combobox(report_frame, width=18, textvariable=self.plot_type_order[0])
        self.plot_order_dd1['values'] = (self.plot_type_order[0].get(), self.plot_type_order[1].get(),self.plot_type_order[2].get(), self.plot_type_order[3].get(),self.plot_type_order[4].get(), self.plot_type_order[5].get(), self.plot_type_order[6].get())
        self.plot_order_dd1.grid(row=report_row, column=report_col+2, sticky="E")

        report_row = report_row + 1

        self.plot_order_dd2 = ttk.Combobox(report_frame, width=18, textvariable=self.plot_type_order[1])
        self.plot_order_dd2['values'] = (self.plot_type_order[0].get(), self.plot_type_order[1].get(),self.plot_type_order[2].get(), self.plot_type_order[3].get(),self.plot_type_order[4].get(), self.plot_type_order[5].get(), self.plot_type_order[6].get())
        self.plot_order_dd2.grid(row=report_row, column=report_col+2, sticky="E")

        report_row = report_row + 1

        self.plot_order_dd3 = ttk.Combobox(report_frame, width=18, textvariable=self.plot_type_order[2])
        self.plot_order_dd3['values'] = (self.plot_type_order[0].get(), self.plot_type_order[1].get(),self.plot_type_order[2].get(), self.plot_type_order[3].get(),self.plot_type_order[4].get(), self.plot_type_order[5].get(), self.plot_type_order[6].get())
        self.plot_order_dd3.grid(row=report_row, column=report_col+2, sticky="E")

        report_row = report_row + 1

        self.plot_order_dd4 = ttk.Combobox(report_frame, width=18, textvariable=self.plot_type_order[3])
        self.plot_order_dd4['values'] = (self.plot_type_order[0].get(), self.plot_type_order[1].get(),self.plot_type_order[2].get(), self.plot_type_order[3].get(),self.plot_type_order[4].get(), self.plot_type_order[5].get(), self.plot_type_order[6].get())
        self.plot_order_dd4.grid(row=report_row, column=report_col+2, sticky="E")

        report_row = report_row + 1

        self.plot_order_dd5 = ttk.Combobox(report_frame, width=18, textvariable=self.plot_type_order[4])
        self.plot_order_dd5['values'] = (self.plot_type_order[0].get(), self.plot_type_order[1].get(),self.plot_type_order[2].get(), self.plot_type_order[3].get(),self.plot_type_order[4].get(), self.plot_type_order[5].get(), self.plot_type_order[6].get())
        self.plot_order_dd5.grid(row=report_row, column=report_col+2, sticky="E")

        report_row = report_row + 1

        self.plot_order_dd6 = ttk.Combobox(report_frame, width=18, textvariable=self.plot_type_order[5])
        self.plot_order_dd6['values'] = (self.plot_type_order[0].get(), self.plot_type_order[1].get(),self.plot_type_order[2].get(), self.plot_type_order[3].get(),self.plot_type_order[4].get(), self.plot_type_order[5].get(), self.plot_type_order[6].get())
        self.plot_order_dd6.grid(row=report_row, column=report_col+2, sticky="E")

        report_row = report_row + 1

        self.plot_order_dd7 = ttk.Combobox(report_frame, width=18, textvariable=self.plot_type_order[6])
        self.plot_order_dd7['values'] = (self.plot_type_order[0].get(), self.plot_type_order[1].get(),self.plot_type_order[2].get(), self.plot_type_order[3].get(),self.plot_type_order[4].get(), self.plot_type_order[5].get(), self.plot_type_order[6].get())
        self.plot_order_dd7.grid(row=report_row, column=report_col+2, sticky="E")

        report_row = report_row + 1

        ttk.Label(report_frame, text="Order of normalized and").grid(row=report_row, column=report_col, sticky="W")
        ttk.Label(report_frame, text="unnormalized plots in PDF:").grid(row=report_row+1, column=report_col, sticky="W")
        self.norm_order_dd1 = ttk.Combobox(report_frame, width=18, textvariable=self.norm_order[0])
        self.norm_order_dd1['values'] = (self.norm_order[0].get(), self.norm_order[1].get())
        self.norm_order_dd1.grid(row=report_row, column=report_col+2, sticky="E")

        report_row = report_row + 1

        self.norm_order_dd2 = ttk.Combobox(report_frame, width=18, textvariable=self.norm_order[1])
        self.norm_order_dd2['values'] = (self.norm_order[0].get(), self.norm_order[1].get())
        self.norm_order_dd2.grid(row=report_row, column=report_col+2, sticky="E")

    def update_variables(self):

        self.protocol_path.set(self.protocol_browse.filename.get())
        self.save_path.set(self.save_browse.filename.get())
        self.report_path.set(self.report_browse.filename.get())

        # Create report settings objects


class histTab(tk.Frame):
    def __init__(self, parent, controller):

        tab = ttk.Frame(parent)
        parent.add(tab, text="Histograms")

        # Frames

        plot_frame = ttk.LabelFrame(tab, text="Basic Histogram Settings")
        plot_frame.grid(row=0, column=0,  columnspan=6, padx=10, pady=10, sticky="NW")
        plot_row = 0
        plot_col = 0

        cl_frame = ttk.LabelFrame(tab, text="Closed Loop Histogram Settings")
        cl_frame.grid(row=10, column=0, columnspan=6, padx=10, pady=10, sticky="NW")
        cl_row = 0
        cl_col = 0

        layout_frame = ttk.LabelFrame(tab, text="Closed-loop Figure Layout")
        layout_frame.grid(row=0, column=7, padx=10, pady=10, sticky="NW")
        layout_row = 0
        layout_col = 0

        fig1_frame = ttk.LabelFrame(layout_frame, text="Figure 1")
        fig1_frame.grid(row=0, column=0, padx=10, pady=10, sticky="NW")
        fig1_row = 0 
        fig1_col = 0


        # Initialize variables

        self.inter_in_degrees = tk.IntVar(value=1)

        self.textbox_pos = []
        self.textbox_pos.append(tk.DoubleVar(value=0.3))
        self.textbox_pos.append(tk.DoubleVar(value=0.0001))
        self.textbox_pos.append(tk.DoubleVar(value=0.7))
        self.textbox_pos.append(tk.DoubleVar(value=0.027))

        self.font_size = tk.IntVar(value=10)
        self.font_name = tk.StringVar(value="Arial")
        self.line_style = tk.StringVar(value="-")
        self.line_width = tk.IntVar(value=1)

        self.edge_color = []
        self.edge_color.append(tk.IntVar(value=1))
        self.edge_color.append(tk.IntVar(value=1))
        self.edge_color.append(tk.IntVar(value=1))

        self.background_color = []
        self.background_color.append(tk.IntVar(value=1))
        self.background_color.append(tk.IntVar(value=1))
        self.background_color.append(tk.IntVar(value=1))

        self.hist_color = []
        self.hist_color.append(tk.IntVar(value=0))
        self.hist_color.append(tk.IntVar(value=0))
        self.hist_color.append(tk.IntVar(value=0))

        self.interpreter = tk.StringVar(value="none")
        self.annotation_text = tk.StringVar(value="")

        self.cl_ylimits = []
        self.cl_ylimits.append([tk.IntVar(value=0), tk.IntVar(value=100)])
        self.cl_ylimits.append([tk.IntVar(value=-6), tk.IntVar(value=6)])
        self.cl_ylimits.append([tk.IntVar(value=2), tk.IntVar(value=10)])

        self.cl_axis_labels = []
        self.cl_axis_labels.append(tk.StringVar(value=""))
        self.cl_axis_labels.append(tk.StringVar(value=""))

        self.FP_datatype = tk.IntVar(value=1)
        self.lmr_datatype = tk.IntVar(value=0)
        self.lpr_datatype = tk.IntVar(value=0)

        self.conditions = []
        self.conditions.append([])
        self.conditions[0].append([])
        self.conditions[0][0].append(tk.IntVar(value=1))

        # Plot Frame objects

        degrees_btn = ttk.Checkbutton(plot_frame, text="Intertrial in degrees?", variable = self.inter_in_degrees)
        degrees_btn.grid(row=plot_row, column=plot_col, sticky="W")

        plot_row = plot_row + 1

        ttk.Label(plot_frame, text="Font Size:").grid(row=plot_row, column=plot_col, sticky="W")
        ttk.Entry(plot_frame, textvariable=self.font_size, width=5).grid(row=plot_row, column=plot_col+1, sticky="E")

        plot_row = plot_row + 1

        ttk.Label(plot_frame, text="Font Name:").grid(row=plot_row, column=plot_col, sticky="W")
        ttk.Entry(plot_frame, textvariable=self.font_name, width=5).grid(row=plot_row, column=plot_col+1, sticky="E")

        plot_row = plot_row + 1

        ttk.Label(plot_frame, text="Line Style:").grid(row=plot_row, column=plot_col, sticky="W")
        ttk.Entry(plot_frame, textvariable=self.line_style, width=5).grid(row=plot_row, column=plot_col+1, sticky="E")

        plot_row = plot_row + 1

        ttk.Label(plot_frame, text="Line Width:").grid(row=plot_row, column=plot_col, sticky="W")
        ttk.Entry(plot_frame, textvariable=self.line_width, width=5).grid(row=plot_row, column=plot_col+1, sticky="E")

        plot_row = plot_row + 1

        ttk.Label(plot_frame, text="Background Color:").grid(row=plot_row, column=plot_col, sticky="W")
        self.background_entries = []
        self.background_entries.append(ttk.Entry(plot_frame, textvariable=self.background_color[0], width=5))
        self.background_entries.append(ttk.Entry(plot_frame, textvariable=self.background_color[1], width=5))
        self.background_entries.append(ttk.Entry(plot_frame, textvariable=self.background_color[2], width=5))

        self.background_entries[0].grid(row=plot_row, column=plot_col+1, sticky="E")
        self.background_entries[1].grid(row=plot_row, column=plot_col+2, sticky="E")
        self.background_entries[2].grid(row=plot_row, column=plot_col+3, sticky="E")

        plot_row = plot_row + 1

        ttk.Label(plot_frame, text="Histogram Color:").grid(row=plot_row, column=plot_col, sticky="W")
        self.hist_entries = []
        self.hist_entries.append(ttk.Entry(plot_frame, textvariable=self.hist_color[0], width=5))
        self.hist_entries.append(ttk.Entry(plot_frame, textvariable=self.hist_color[1], width=5))
        self.hist_entries.append(ttk.Entry(plot_frame, textvariable=self.hist_color[2], width=5))

        self.hist_entries[0].grid(row=plot_row, column=plot_col+1, sticky="E")
        self.hist_entries[1].grid(row=plot_row, column=plot_col+2, sticky="E")
        self.hist_entries[2].grid(row=plot_row, column=plot_col+3, sticky="E")

        plot_row = plot_row + 1
       
        ttk.Label(plot_frame, text="Edge Color:").grid(row=plot_row, column=plot_col, sticky="W")
        self.edge_entries = []
        self.edge_entries.append(ttk.Entry(plot_frame, textvariable=self.edge_color[0], width=5))
        self.edge_entries.append(ttk.Entry(plot_frame, textvariable=self.edge_color[1], width=5))
        self.edge_entries.append(ttk.Entry(plot_frame, textvariable=self.edge_color[2], width=5))

        self.edge_entries[0].grid(row=plot_row, column=plot_col + 1, sticky="E")
        self.edge_entries[1].grid(row=plot_row, column=plot_col+2, sticky="E")
        self.edge_entries[2].grid(row=plot_row, column=plot_col+3, sticky="E")

        plot_row = plot_row + 1

        ttk.Label(plot_frame, text="Textbox Position:").grid(row=plot_row, column=plot_col, sticky="W")
        self.textbox_entries = []
        self.textbox_entries.append(ttk.Entry(plot_frame, textvariable=self.textbox_pos[0], width=5))
        self.textbox_entries.append(ttk.Entry(plot_frame, textvariable=self.textbox_pos[1], width=5))
        self.textbox_entries.append(ttk.Entry(plot_frame, textvariable=self.textbox_pos[2], width=5))
        self.textbox_entries.append(ttk.Entry(plot_frame, textvariable=self.textbox_pos[3], width=5))

        self.textbox_entries[0].grid(row=plot_row, column=plot_col + 1, sticky="E")
        self.textbox_entries[1].grid(row=plot_row, column=plot_col+2, sticky="E")
        self.textbox_entries[2].grid(row=plot_row, column=plot_col+3, sticky="E")
        self.textbox_entries[3].grid(row=plot_row, column=plot_col+4, sticky="E")

        plot_row = plot_row + 1

        #Closed loop frame objects

        ttk.Label(cl_frame, text="Datatypes for which to ").grid(row=cl_row, column=cl_col, sticky="W")

        cl_row = cl_row + 1
        
        ttk.Label(cl_frame, text="plot closed-loop histograms:").grid(row=cl_row, column=cl_col, sticky="W")

        FP_btn = ttk.Checkbutton(cl_frame, text="Frame Position", variable = self.FP_datatype)
        FP_btn.grid(row=cl_row, column=cl_col+1, sticky="W")

        cl_row = cl_row + 1

        lmr_btn = ttk.Checkbutton(cl_frame, text="Left minus Right", variable = self.lmr_datatype)
        lmr_btn.grid(row=cl_row, column=cl_col+1, sticky="W")

        cl_row = cl_row + 1

        lpr_btn = ttk.Checkbutton(cl_frame, text="Left plus Right", variable = self.lpr_datatype)
        lpr_btn.grid(row=cl_row, column=cl_col+1, sticky="W")

        cl_row = cl_row + 1

        ttk.Label(cl_frame, text="X axis label:").grid(row = cl_row, column = cl_col, sticky="W")
        self.axis_label_entries = []
        self.axis_label_entries.append(ttk.Entry(cl_frame, textvariable=self.cl_axis_labels[0],width=10))
        self.axis_label_entries.append(ttk.Entry(cl_frame, textvariable=self.cl_axis_labels[1],width=10))

        self.axis_label_entries[0].grid(row=cl_row, column=cl_col +1, sticky="W")
        cl_row = cl_row + 1

        ttk.Label(cl_frame, text="Y axis label:").grid(row = cl_row, column = cl_col, sticky="W")
        self.axis_label_entries[1].grid(row=cl_row, column = cl_col + 1, sticky="W")

        cl_row = cl_row + 1

        ttk.Label(cl_frame, text="Frame Position y limits:").grid(row=cl_row, column=cl_col, sticky="W")
        self.ylim_FP_entries = []
        self.ylim_FP_entries.append(ttk.Entry(cl_frame, textvariable=self.cl_ylimits[0][0], width=10))
        self.ylim_FP_entries.append(ttk.Entry(cl_frame, textvariable=self.cl_ylimits[0][1], width=10))


        self.ylim_FP_entries[0].grid(row=cl_row, column=cl_col + 1, sticky="W")
        self.ylim_FP_entries[1].grid(row=cl_row, column=cl_col+2, sticky="W")

        cl_row = cl_row + 1

        ttk.Label(cl_frame, text="LmR y limits:").grid(row=cl_row, column=cl_col, sticky="W")
        self.ylim_lmr_entries = []
        self.ylim_lmr_entries.append(ttk.Entry(cl_frame, textvariable=self.cl_ylimits[1][0], width=10))
        self.ylim_lmr_entries.append(ttk.Entry(cl_frame, textvariable=self.cl_ylimits[1][1], width=10))

        self.ylim_lmr_entries[0].grid(row=cl_row, column=cl_col+1, sticky="W")
        self.ylim_lmr_entries[1].grid(row=cl_row, column=cl_col+2, sticky="W")

        cl_row = cl_row + 1

        ttk.Label(cl_frame, text="LpR y limits:").grid(row=cl_row, column=cl_col, sticky="W")
        self.ylim_lpr_entries = []
        self.ylim_lpr_entries.append(ttk.Entry(cl_frame, textvariable=self.cl_ylimits[2][0], width=10))
        self.ylim_lpr_entries.append(ttk.Entry(cl_frame, textvariable=self.cl_ylimits[2][1], width=10))

        self.ylim_lpr_entries[0].grid(row=cl_row, column=cl_col + 1, sticky="W")
        self.ylim_lpr_entries[1].grid(row=cl_row, column=cl_col + 2, sticky="W")

        #Layout frame objects

        self.CLlayout = lo.layoutCL

        # ttk.Entry(fig1_frame, textvariable=self.conditions[0][0][0], width=3).grid(row=fig1_row, column=fig1_col, sticky="W")
        # ttk.Button(fig1_frame, text="Add Column").grid(row=fig1_row, column=fig1_col+1, sticky="W")
        # ttk.Button(fig1_frame, text="Add Row").grid(row=fig1_row + 1, column=fig1_col, sticky="W")
        # ttk.Button(layout_frame, text="Add Figure").grid(row=layout_row+1, column=layout_col, sticky="W")

    def add_datatype(self, newdt):
        self.cl_datatypes.append(tk.StringVar(value=newdt))

    def remove_datatype(self, dt):
        self.cl_datatypes.remove(dt)



class tsTab(tk.Frame):
    def __init__(self, parent, controller):

        tab = ttk.Frame(parent)
        parent.add(tab, text="Timeseries")
        
        


class tcTab(tk.Frame):

    def __init__(self, parent, controller):
        tab = ttk.Frame(parent)
        parent.add(tab, text="Tuning Curves")

class mpTab(tk.Frame):

    def __init__(self, parent, controller):
        tab = ttk.Frame(parent)
        parent.add(tab, text="Position and Motion")

class compTab(tk.Frame):

    def __init__(self, parent, controller):
        tab = ttk.Frame(parent)
        parent.add(tab, text="Comparison")

class appTab(tk.Frame):

    def __init__(self, parent, controller):

        tab = ttk.Frame(parent)
        parent.add(tab, text="Plot Appearance")

         #Frames

        fonts_frame = ttk.LabelFrame(tab, text="Font Sizes")
        fonts_frame.grid(row=0, column=0, rowspan=7, columnspan=2, padx=10, pady=10, sticky="NW")

        colors_frame = ttk.LabelFrame(tab, text="Colors")
        colors_frame.grid(row=7, column=0, rowspan=12, columnspan=6, padx=10, pady=20, sticky="W")

        lines_frame = ttk.LabelFrame(tab, text="Line widths")
        lines_frame.grid(row=0, column=2, rowspan=12, columnspan=2, padx=10, pady=10, sticky="N")

        text_frame = ttk.LabelFrame(tab, text="Tips:")
        text_frame.grid(row=0, column=4, rowspan=12, columnspan=6, padx=50, pady=10, sticky="N")

         #initialize placement of objects in each frame
        fonts_row = 0
        fonts_col = 0
        colors_row =  0
        colors_col = 0
        lines_row = 0
        lines_col = 0
        text_row = 0
        text_col = 0

         #initialize font variables

        self.figTitle_fontSize = tk.IntVar(value=12)
        self.subtitle_fontSize = tk.IntVar(value=8)
        self.legend_fontSize = tk.IntVar(value=6)
        self.yLabel_fontSize = tk.IntVar(value=6)
        self.xLabel_fontSize = tk.IntVar(value=6)
        self.axis_num_fontSize = tk.IntVar(value=6)
        self.axis_label_fontSize = tk.IntVar(value=6)

         #initialize color and line variables

        self.fly_colors = []

        self.fly_colors.append([tk.IntVar(value=134), tk.IntVar(value=134), tk.IntVar(value=134)])
        self.fly_colors.append([tk.IntVar(value=146), tk.IntVar(value=146), tk.IntVar(value=146)])
        self.fly_colors.append([tk.IntVar(value=158), tk.IntVar(value=158), tk.IntVar(value=158)])
        self.fly_colors.append([tk.IntVar(value=170), tk.IntVar(value=170), tk.IntVar(value=170)])
        self.fly_colors.append([tk.IntVar(value=182), tk.IntVar(value=182), tk.IntVar(value=182)])
        self.fly_colors.append([tk.IntVar(value=194), tk.IntVar(value=194), tk.IntVar(value=194)])
        self.fly_colors.append([tk.IntVar(value=206), tk.IntVar(value=206), tk.IntVar(value=206)])
        self.fly_colors.append([tk.IntVar(value=218), tk.IntVar(value=218), tk.IntVar(value=218)])
        self.fly_colors.append([tk.IntVar(value=230), tk.IntVar(value=230), tk.IntVar(value=230)])
        self.fly_colors.append([tk.IntVar(value=242), tk.IntVar(value=242), tk.IntVar(value=242)])


        self.rep_colors = []

        self.rep_colors.append([tk.IntVar(value=128), tk.IntVar(value=128), tk.IntVar(value=128)])
        self.rep_colors.append([tk.IntVar(value=255), tk.IntVar(value=128), tk.IntVar(value=128)])
        self.rep_colors.append([tk.IntVar(value=64), tk.IntVar(value=192), tk.IntVar(value=64)])
        self.rep_colors.append([tk.IntVar(value=128), tk.IntVar(value=128),tk.IntVar(value=1)])
        self.rep_colors.append([tk.IntVar(value=1),tk.IntVar(value=192),tk.IntVar(value=64)])
        self.rep_colors.append([tk.IntVar(value=192), tk.IntVar(value=128), tk.IntVar(value=1)])
        self.rep_colors.append([tk.IntVar(value=128),tk.IntVar(value=1),tk.IntVar(value=128)])
        self.rep_colors.append([tk.IntVar(value=128),tk.IntVar(value=1), tk.IntVar(value=1)])
        self.rep_colors.append([tk.IntVar(value=1), tk.IntVar(value=128), tk.IntVar(value=1)])
        self.rep_colors.append([tk.IntVar(value=1), tk.IntVar(value=1), tk.IntVar(value=128)])

        self.mean_colors = []

        self.mean_colors.append([tk.IntVar(value=0), tk.IntVar(value=0), tk.IntVar(value=0)])
        self.mean_colors.append([tk.IntVar(value=255), tk.IntVar(value=0), tk.IntVar(value=0)])
        self.mean_colors.append([tk.IntVar(value=0), tk.IntVar(value=128), tk.IntVar(value=0)])
        self.mean_colors.append([tk.IntVar(value=0), tk.IntVar(value=0), tk.IntVar(value=255)])
        self.mean_colors.append([tk.IntVar(value=255), tk.IntVar(value=128), tk.IntVar(value=0)])
        self.mean_colors.append([tk.IntVar(value=192), tk.IntVar(value=0), tk.IntVar(value=255)])
        self.mean_colors.append([tk.IntVar(value=0),tk.IntVar(value=255),tk.IntVar(value=0)])
        self.mean_colors.append([tk.IntVar(value=0), tk.IntVar(value=255), tk.IntVar(value=255)])
        self.mean_colors.append([tk.IntVar(value=255), tk.IntVar(value=0),tk.IntVar(value=255)])
        self.mean_colors.append([tk.IntVar(value=255), tk.IntVar(value=255), tk.IntVar(value=0)])

        self.control_color = [tk.IntVar(value=0), tk.IntVar(value=0), tk.IntVar(value=0)]

        self.edgeColor = tk.StringVar(value="None")
        self.patch_alpha = tk.DoubleVar(value=0.3)
        self.fly_lineWidth = tk.DoubleVar(value=0.05)
        self.rep_lineWidth = tk.DoubleVar(value=0.05)
        self.mean_lineWidth = tk.DoubleVar(value=1.0)

        self.fly_colors_count = 10
        self.mean_colors_count = 10
        self.rep_colors_count = 10

        self.fly_colors_labels = []
        self.mean_colors_labels = []
        self.rep_colors_labels = []

         #create font objects

        ttk.Label(fonts_frame, text="Figure Title Font Size:").grid(row=fonts_row, column=fonts_col, sticky="E")
        ttk.Entry(fonts_frame, textvariable=self.figTitle_fontSize, width=3).grid(row=fonts_row, column=fonts_col+1, sticky="W")
        fonts_row = fonts_row + 1

        ttk.Label(fonts_frame, text="Subtitle Font Size:").grid(row=fonts_row, column=fonts_col, sticky="E")
        ttk.Entry(fonts_frame, textvariable=self.subtitle_fontSize, width=3).grid(row=fonts_row, column=fonts_col+1, sticky="W")
        fonts_row = fonts_row + 1

        ttk.Label(fonts_frame, text="Legend Font Size:").grid(row=fonts_row, column=fonts_col, sticky="E")
        ttk.Entry(fonts_frame, textvariable=self.legend_fontSize, width=3).grid(row=fonts_row, column=fonts_col+1, sticky="W")
        fonts_row = fonts_row + 1

        ttk.Label(fonts_frame, text="Y Label Font Size:").grid(row=fonts_row, column=fonts_col, sticky="E")
        ttk.Entry(fonts_frame, textvariable=self.yLabel_fontSize, width=3).grid(row=fonts_row, column=fonts_col+1, sticky="W")
        fonts_row = fonts_row + 1

        ttk.Label(fonts_frame, text="X Label Font Size:").grid(row=fonts_row, column=fonts_col, sticky="E")
        ttk.Entry(fonts_frame, textvariable=self.xLabel_fontSize, width=3).grid(row=fonts_row, column=fonts_col+1, sticky="W")
        fonts_row = fonts_row + 1

        ttk.Label(fonts_frame, text="Axis Numbers Font Size:").grid(row=fonts_row, column=fonts_col, sticky="E")
        ttk.Entry(fonts_frame, textvariable=self.axis_num_fontSize, width=3).grid(row=fonts_row, column=fonts_col+1, sticky="W")
        fonts_row = fonts_row + 1

        ttk.Label(fonts_frame, text="Axis Labels Font Size:").grid(row=fonts_row, column=fonts_col, sticky="E")
        ttk.Entry(fonts_frame, textvariable=self.axis_label_fontSize, width=3).grid(row=fonts_row, column=fonts_col+1, sticky="W")
        fonts_row = fonts_row + 1

        # create color objects

        #control color

        ttk.Label(colors_frame, text="Control Color:").grid(row=colors_row, column=colors_col, sticky="W")
        self.control_label = ttk.Label(colors_frame, text="Color")
        self.update_label_color(self.control_label, self.control_color)
        self.control_label.grid(row=colors_row, column=colors_col+1, padx=10, sticky="W")
        #ttk.Button(colors_frame, text="Change Control Color", command=lambda: self.pick_control_color()).grid(row=colors_row, column=colors_col+2, padx=10, sticky="W")

        ttk.Entry(colors_frame, textvariable=self.control_color[0], width=3).grid(row=colors_row, column=colors_col+2, sticky="W")
        ttk.Entry(colors_frame, textvariable=self.control_color[1], width=3).grid(row=colors_row, column=colors_col+3, sticky="W")
        ttk.Entry(colors_frame, textvariable=self.control_color[2], width=3).grid(row=colors_row, column=colors_col+4, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.control_label, self.control_color)).grid(row=colors_row, column=colors_col+5, padx=10, sticky="W")

        colors_row = colors_row + 1
        
        # Mean colors

        ttk.Label(colors_frame, text="Mean Colors:").grid(row=colors_row, column=colors_col, sticky="W")

        for mean in range(0,self.mean_colors_count):
            colors_row_mean = colors_row + (mean)
            self.mean_colors_labels.append(ttk.Label(colors_frame, text="Color"))
            self.update_label_color(self.mean_colors_labels[mean], self.mean_colors[mean])
            self.mean_colors_labels[mean].grid(row=colors_row_mean, column=colors_col+1, padx=10, sticky="W")
            ttk.Entry(colors_frame, textvariable=self.mean_colors[mean][0], width=3).grid(row=colors_row_mean, column=colors_col+2, sticky="W")
            ttk.Entry(colors_frame, textvariable=self.mean_colors[mean][1], width=3).grid(row=colors_row_mean, column=colors_col+3, sticky="W")
            ttk.Entry(colors_frame, textvariable=self.mean_colors[mean][2], width=3).grid(row=colors_row_mean, column=colors_col+4, sticky="W")
        
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.mean_colors_labels[0], self.mean_colors[0])).grid(row=colors_row, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.mean_colors_labels[1], self.mean_colors[1])).grid(row=colors_row+1, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.mean_colors_labels[2], self.mean_colors[2])).grid(row=colors_row+2, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.mean_colors_labels[3], self.mean_colors[3])).grid(row=colors_row+3, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.mean_colors_labels[4], self.mean_colors[4])).grid(row=colors_row+4, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.mean_colors_labels[5], self.mean_colors[5])).grid(row=colors_row+5, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.mean_colors_labels[6], self.mean_colors[6])).grid(row=colors_row+6, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.mean_colors_labels[7], self.mean_colors[7])).grid(row=colors_row+7, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.mean_colors_labels[8], self.mean_colors[8])).grid(row=colors_row+8, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.mean_colors_labels[9], self.mean_colors[9])).grid(row=colors_row+9, column=colors_col+5, padx=10, sticky="W")

        colors_col = colors_col + 6

        # Fly Colors
        colors_row = colors_row - 1
        ttk.Label(colors_frame, text="Fly Colors:").grid(row=colors_row, column=colors_col, sticky="W")

        for fly in range(0, self.fly_colors_count):
            colors_row_fly = colors_row + (fly)
            self.fly_colors_labels.append(ttk.Label(colors_frame, text="Color"))
            self.update_label_color(self.fly_colors_labels[fly], self.fly_colors[fly])
            self.fly_colors_labels[fly].grid(row=colors_row_fly, column=colors_col+1, padx=10, sticky="W")
            ttk.Entry(colors_frame, textvariable=self.fly_colors[fly][0], width=3).grid(row=colors_row_fly, column=colors_col+2, sticky="W")
            ttk.Entry(colors_frame, textvariable=self.fly_colors[fly][1], width=3).grid(row=colors_row_fly, column=colors_col+3, sticky="W")
            ttk.Entry(colors_frame, textvariable=self.fly_colors[fly][2], width=3).grid(row=colors_row_fly, column=colors_col+4, sticky="W")
            
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.fly_colors_labels[0], self.fly_colors[0])).grid(row=colors_row, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.fly_colors_labels[1], self.fly_colors[1])).grid(row=colors_row+1, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.fly_colors_labels[2], self.fly_colors[2])).grid(row=colors_row+2, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.fly_colors_labels[3], self.fly_colors[3])).grid(row=colors_row+3, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.fly_colors_labels[4], self.fly_colors[4])).grid(row=colors_row+4, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.fly_colors_labels[5], self.fly_colors[5])).grid(row=colors_row+5, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.fly_colors_labels[6], self.fly_colors[6])).grid(row=colors_row+6, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.fly_colors_labels[7], self.fly_colors[7])).grid(row=colors_row+7, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.fly_colors_labels[8], self.fly_colors[8])).grid(row=colors_row+8, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.fly_colors_labels[9], self.fly_colors[9])).grid(row=colors_row+9, column=colors_col+5, padx=10, sticky="W")

        colors_col = colors_col + 6

        # Rep Colors

        ttk.Label(colors_frame, text="Rep Colors:").grid(row=colors_row, column=colors_col, sticky="W")

        for rep in range(0, self.rep_colors_count):
            colors_row_rep = colors_row + rep
            self.rep_colors_labels.append(ttk.Label(colors_frame, text="Color"))
            self.update_label_color(self.rep_colors_labels[rep], self.rep_colors[rep])
            self.rep_colors_labels[rep].grid(row=colors_row_rep, column=colors_col+1, padx=10, sticky="W")
            ttk.Entry(colors_frame, textvariable=self.rep_colors[rep][0], width=3).grid(row=colors_row_rep, column=colors_col+2, sticky="W")
            ttk.Entry(colors_frame, textvariable=self.rep_colors[rep][1], width=3).grid(row=colors_row_rep, column=colors_col+3, sticky="W")
            ttk.Entry(colors_frame, textvariable=self.rep_colors[rep][2], width=3).grid(row=colors_row_rep, column=colors_col+4, sticky="W")

        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.rep_colors_labels[0], self.rep_colors[0])).grid(row=colors_row, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.rep_colors_labels[1], self.rep_colors[1])).grid(row=colors_row+1, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.rep_colors_labels[2], self.rep_colors[2])).grid(row=colors_row+2, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.rep_colors_labels[3], self.rep_colors[3])).grid(row=colors_row+3, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.rep_colors_labels[4], self.rep_colors[4])).grid(row=colors_row+4, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.rep_colors_labels[5], self.rep_colors[5])).grid(row=colors_row+5, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.rep_colors_labels[6], self.rep_colors[6])).grid(row=colors_row+6, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.rep_colors_labels[7], self.rep_colors[7])).grid(row=colors_row+7, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.rep_colors_labels[8], self.rep_colors[8])).grid(row=colors_row+8, column=colors_col+5, padx=10, sticky="W")
        ttk.Button(colors_frame, text="Update", command=lambda: self.update_label_color(self.rep_colors_labels[9], self.rep_colors[9])).grid(row=colors_row+9, column=colors_col+5, padx=10, sticky="W")

        # Create other general appearance settings

        ttk.Label(lines_frame, text="Edge Color:").grid(row=lines_row, column=lines_col, sticky="E")
        ttk.Entry(lines_frame, textvariable=self.edgeColor, width=5).grid(row=lines_row, column=lines_col+1, sticky="W")
        lines_row = lines_row + 1

        ttk.Label(lines_frame, text="Patch Alpha:").grid(row=lines_row, column=lines_col, sticky="E")
        ttk.Entry(lines_frame, textvariable=self.patch_alpha, width=5).grid(row=lines_row, column=lines_col+1, sticky="W")
        lines_row = lines_row + 1

        ttk.Label(lines_frame, text="Line width of individual flies:").grid(row=lines_row, column=lines_col, sticky="E")
        ttk.Entry(lines_frame, textvariable=self.fly_lineWidth, width=5).grid(row=lines_row, column=lines_col+1, sticky="W")
        lines_row = lines_row + 1

        ttk.Label(lines_frame, text="Line width of individual repetitions:").grid(row=lines_row, column=lines_col, sticky="E")
        ttk.Entry(lines_frame, textvariable=self.rep_lineWidth, width=5).grid(row=lines_row, column=lines_col+1, sticky="W")
        lines_row = lines_row + 1

        ttk.Label(lines_frame, text="Line width of mean fly data:").grid(row=lines_row, column=lines_col, sticky="E")
        ttk.Entry(lines_frame, textvariable=self.mean_lineWidth, width=5).grid(row=lines_row, column=lines_col+1, sticky="W")
        lines_row = lines_row + 1

        # Create a text key explaining fields that are not self-explanatory

        ttk.Label(text_frame, anchor="center", text = "Colors refer to the color of a line in a line plot. Colors are implemented in order from top to bottom,").grid(row=text_row, column=text_col, sticky="W")
        text_row = text_row + 1
        ttk.Label(text_frame, anchor="center", text = "so if a plot only has four lines, they will be of the first four colors.").grid(row=text_row, column=text_col, sticky="W")
        text_row = text_row + 1
        ttk.Label(text_frame, anchor="center", text = " - Mean Colors refers to the color of lines representing averages of multiple flies.").grid(row=text_row, column=text_col, sticky="W")
        text_row = text_row + 1
        ttk.Label(text_frame, anchor="center", text = " - Fly Colors refers to the color of lines representing a single fly averaged over is repetitions.").grid(row=text_row, column=text_col, sticky="W")
        text_row = text_row + 1
        ttk.Label(text_frame, anchor="center", text = " - Rep Colors refers to the color of lines representing a single repetition of a single fly.").grid(row=text_row, column=text_col, sticky="W")
        text_row = text_row + 1
        ttk.Label(text_frame, anchor="center", text = "").grid(row = text_row, column=text_col, sticky = "W")
        text_row = text_row + 1
        ttk.Label(text_frame, anchor="center", text = "Where enabled, plot lines have the standard deviation area around them colored in, which is called a patch.").grid(row = text_row, column=text_col, sticky = "W")
        text_row = text_row + 1
        ttk.Label(text_frame, anchor="center", text = " - Patch Alpha refers to how transparent this area is from 0(transparent) to 1").grid(row = text_row, column=text_col, sticky = "W")
        text_row = text_row + 1
        ttk.Label(text_frame, anchor="center", text = " - Edge Color is for if you want the edge of the patch to be a different color than the rest.").grid(row = text_row, column=text_col, sticky = "W")
        text_row = text_row + 1
        ttk.Label(text_frame, anchor="center", text = "   - Use word colors recoginzed by matlab like 'blue' or 'red'.").grid(row = text_row, column=text_col, sticky = "W")
        text_row = text_row + 1



    def update_label_color(self, label_handle, color):
        hex_color = self.rgb_to_hex(color)
        label_handle.configure(foreground=hex_color)

    def rgb_to_hex(self, rgb):
        red = rgb[0].get()
        green = rgb[1].get()
        blue = rgb[2].get()

        return '#%02x%02x%02x' % (red, green, blue)

        

    # def pick_control_color(self):
    #     self.control_color = colorchooser.askcolor()[1]
    #     self.control_label.config(foreground=self.control_color)

    

        

         





