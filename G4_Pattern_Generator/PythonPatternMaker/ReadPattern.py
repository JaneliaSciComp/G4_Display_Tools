import numpy as np
import json
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider

def inspect_npz_file(npz_path):
    """
    Load and display contents of a G4 .npz pattern file.

    Args:
        npz_path (str): Path to the .npz file.
    """
    data = np.load(npz_path, allow_pickle=True)

    print(f"\nContents of: {npz_path}\n{'=' * 50}")

    for key in data:
        val = data[key]

        if key == 'param':
            try:
                val = json.loads(val)  # Try to parse JSON string
                print(f"\n{key} (parsed JSON):")
                for subkey, subval in val.items():
                    print(f"  {subkey}: {subval}")
            except Exception:
                print(f"\n{key} (raw): {val}")
        elif isinstance(val, np.ndarray):
            print(f"\n{key}:")
            print(f"  shape: {val.shape}")
            print(f"  dtype: {val.dtype}")
            if val.size < 100:
                print(f"  values: {val}")
            else:
                print(f"  [array too large to display values]")
        else:
            print(f"\n{key}: {val}")

def view_pattern_frames(Pats, y_index=0):
    """
    Visualizes the Pats array as a series of grayscale images.
    
    Args:
        Pats (ndarray): 4D array (rows, cols, x_frames, y_frames)
        y_index (int): Which y-frame to visualize (defaults to 0)
    """
    if Pats.ndim != 4:
        raise ValueError("Expected a 4D array (rows, cols, x_frames, y_frames)")

    rows, cols, x_frames, y_frames = Pats.shape

    if not (0 <= y_index < y_frames):
        raise IndexError(f"y_index out of range (0 to {y_frames - 1})")

    fig, ax = plt.subplots()
    plt.subplots_adjust(bottom=0.2)

    # Initial image
    img = ax.imshow(Pats[:, :, 0, y_index], cmap='gray', vmin=0, vmax=Pats.max())
    ax.set_title(f'Frame 0 / {x_frames - 1} (y_index = {y_index})')
    ax.axis('off')

    # Slider setup
    ax_slider = plt.axes([0.2, 0.05, 0.6, 0.03])
    slider = Slider(ax_slider, 'Frame', 0, x_frames - 1, valinit=0, valstep=1)

    def update(val):
        frame = int(slider.val)
        img.set_data(Pats[:, :, frame, y_index])
        ax.set_title(f'Frame {frame} / {x_frames - 1} (y_index = {y_index})')
        fig.canvas.draw_idle()

    slider.on_changed(update)
    plt.show()

if __name__ == "__main__":

    filepath = r"C:\Users\taylo\OneDrive\Desktop\0001_4RowSqGrate_G4.npz"
    inspect_npz_file(filepath)

    data = np.load(filepath, allow_pickle=True)
    Pats = data['Pats']
    view_pattern_frames(Pats)