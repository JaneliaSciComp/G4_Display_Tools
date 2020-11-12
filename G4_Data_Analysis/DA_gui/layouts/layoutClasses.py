import tkinter as tk
from tkinter import ttk

LARGE_FONT = ("Verdana", 12)
ROW_SIZE = 50
COL_SIZE = 50


class layoutTS(tk.Frame):


    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        label = tk.Label(self, text="Timeseries Layout", font=LARGE_FONT)
        label.grid(row=10, column=10, sticky="nsew")

class layoutTC(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        label = tk.Label(self, text="Tuning Curves Layout", font=LARGE_FONT)
        label.grid(row=10, column=10, sticky="nsew")


class layoutCL(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        label = tk.Label(self, text="Closed Loop Layout", font=LARGE_FONT)
        label.grid(row=10, column=10, sticky="nsew")         
