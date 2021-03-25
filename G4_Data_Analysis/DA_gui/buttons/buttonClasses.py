import tkinter as tk
from tkinter import ttk
from tkinter import filedialog


BTN_FONT = ("Verdana", 10)
ROW_SIZE = 50
COL_SIZE = 50

class browseFile(tk.Frame):

    def __init__(self, parent, controller, row, col):

        self.filename = tk.StringVar()
        self.textBox = ttk.Entry(parent, textvariable=self.filename)
        btn = ttk.Button(parent, text="Browse", command=lambda: self.browse_file(controller))
        self.textBox.grid(row=row, column=col, columnspan=2, sticky="E")
        btn.grid(row=row, column=col+2, sticky="W")

    def browse_file(self, controller):

        file = filedialog.askopenfilename(initialdir = "/", title = "Select a file")
        self.filename.set(file)
        controller.update_variables()

class addGroup(tk.Frame):

    def __init__(self, parent, controller, row, col, num):
        self.parent = parent
        self.controller = controller
        self.row = row
        self.col = col
        self.group_count = num
        self.values_count = 1
        self.textBoxes = []
        self.group_values = []
        self.control = tk.BooleanVar()
        self.control.set(False)
        self.label = tk.StringVar()
        self.label.set('')

        self.group_values.append('')
        self.textBoxes.append( ttk.Entry(parent, textvariable=self.group_values[0]) )
        
        self.addGroupBtn = ttk.Button(parent, text="Add group", command=lambda: controller.add_group(parent, row+1, col))
        self.removeGroupBtn = ttk.Button(parent, text="Remove group", command=lambda: controller.remove_group())
        
        self.addValBtn = ttk.Button(parent, text="Add value", command=lambda: self.add_value())
        self.removeValBtn = ttk.Button(parent, text="Remove value", command=lambda: self.remove_value())
        self.controlBtn = ttk.Checkbutton(parent, text="Control", variable=self.control)
        self.labelLabel = ttk.Label(parent, text="Label:")
        self.labelEntry = ttk.Entry(parent, textvariable=self.label)

        self.textBoxes[0].grid(row=row, column=col, sticky="W")
        self.addGroupBtn.grid(row=row+1, column=col, sticky="W")
        self.removeGroupBtn.grid(row=row+2, column=col, sticky="W")
        self.addValBtn.grid(row=row, column=col+1, sticky="W")
        self.removeValBtn.grid(row=row, column=col+2, sticky="W")
        self.controlBtn.grid(row=row, column=col+3, sticky="W")
        self.labelLabel.grid(row=row, column=col+4, sticky="W")
        self.labelEntry.grid(row=row, column=col+5, sticky="W")

    def add_value(self):
        print("adding value")
        self.values_count = self.values_count + 1
        self.group_values.append('')
        self.textBoxes.append( ttk.Entry(self.parent, textvariable=self.group_values[self.values_count-1]) )
        self.addValBtn.grid(row=self.row, column=self.col+self.values_count, sticky="W")
        self.removeValBtn.grid(row=self.row, column=self.col + self.values_count + 1, sticky="W")
        self.controlBtn.grid(row=self.row, column=self.col + self.values_count + 2, sticky="W")
        self.textBoxes[self.values_count-1].grid(row=self.row, column=self.col+self.values_count-1, sticky="W")
        self.labelLabel.grid(row=self.row, column=self.col + self.values_count + 3, sticky="W")
        self.labelEntry.grid(row=self.row, column=self.col + self.values_count + 4, sticky="W")

    def remove_value(self):
        if self.values_count > 1:
            deleted_val = self.group_values.pop()
            deleted_box = self.textBoxes.pop()
            deleted_box.grid_forget()
            self.values_count = self.values_count - 1
            self.addValBtn.grid(row=self.row, column=self.col+self.values_count, sticky="W")
            self.removeValBtn.grid(row=self.row, column=self.col + self.values_count + 1, sticky="W")
            self.controlBtn.grid(row=self.row, column=self.col + self.values_count + 2, sticky="W")
            self.textBoxes[self.values_count-1].grid(row=self.row, column=self.col + self.values_count -1, sticky="W")
            self.labelLabel.grid(row=self.row, column=self.col + self.values_count + 3, sticky="W")
            self.labelEntry.grid(row=self.row, column=self.col + self.values_count + 4, sticky="W")



class addGroupField(tk.Frame):

    def __init__(self, parent, controller, row, col, num):
        
        self.groupOptions = {'Genotype', 'Experimenter', 'Date', 'Sex', 'Age'}
        self.value = tk.StringVar()
        self.value.set('Genotype')
        self.count = num

        self.gt_dropdown = ttk.OptionMenu(parent, self.value, *self.groupOptions)
        self.add_button = ttk.Button(parent, text="Add",  command=lambda: controller.add_group_field(parent, row, col+1))
        self.remove_button = ttk.Button(parent, text="Remove", command=lambda: controller.remove_group_field())

        self.gt_dropdown.grid(row=row, column=col, sticky="W")
        self.add_button.grid(row=row, column=col+1, sticky="W")
        self.remove_button.grid(row=row, column=col+2, sticky="W")


class ColorGroup(tk.Frame):

    def __init__(self, parent, controller, row, col):

        self.color = [None]*3
        self.color = [tk.StringVar(value="0"), tk.StringVar(value="0"), tk.StringVar(value="0")]
        self.entry_width = 3
        self.color_preview = ttk.Label(parent, text="Color:").grid(row=row, column=col, sticky="W")

        ttk.Entry(parent, textvariable=self.color[0], width=entry_width).grid(row=row, column=col+1, sticky="W")
        ttk.Entry(parent, textvariable=self.color[1], width=entry_width).grid(row=row, column=col+2, sticky="W")
        ttk.Entry(parent, textvariable=self.color[2], width=entry_width).grid(row=row, column=col+3, sticky="W")
        ttk.Button(parent, text="Add color", command=lambda: controller.add_new_color()).grid(row=row, column=col+5, sticky="W")

    def update_color(self, new_color):

        for c in range(0, len(new_color)):
            self.color[c].set(str(new_color[c]))

    def update_label_color(self, label, color):
        int_color = [None]*3

        for c in range(0,len(color)):
            int_color[c] = int(color[c].get())
        color_hex = self.convert_rgb_to_hex(int_color)
        label.config(foreground=color_hex)

    def convert_rgb_to_hex(self, rgb):
        hexColor = "#"
        for c in range(0, len(rgb)):
            if rgb[c] == 0:
                hexColor =  hexColor +  hex(rgb[c])
            else: 
                hexColor = hexColor + hex(rgb[c]).lstrip("0x")
        hexColor = hexColor.replace("x","")
        return(hexColor)


    




        
        



