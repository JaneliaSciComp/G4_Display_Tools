# preview_pat_exact.py
import struct
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider

# ------------------------------------------------------------------
# Helpers for header
# ------------------------------------------------------------------
def read_header_and_raw(path):
    with open(path, "rb") as f:
        header = f.read(7)
        if len(header) < 7:
            raise ValueError("File too short to contain header.")
        NumPatsX, NumPatsY, gs_val, RowN, ColN = struct.unpack("<HHBBB", header)
        raw = np.frombuffer(f.read(), dtype=np.uint8)
    return NumPatsX, NumPatsY, gs_val, RowN, ColN, raw

def frame_size_bytes(RowN, ColN):
    """Matches make_framevector_gs16 in writer."""
    numSubpanel = 4
    subpanelMsgLength = 33
    return (ColN * subpanelMsgLength + 1) * RowN * numSubpanel

# ------------------------------------------------------------------
# Inverse of make_framevector_gs16
# ------------------------------------------------------------------
def decode_framevector_gs16(framevec, rows, cols):
    """
    Inverse of make_framevector_gs16.
    framevec: 1D np.uint8 array for a single frame
    rows, cols: full arena size
    Returns: 2D np.uint8 image of shape (rows, cols)
    """
    numSubpanel = 4
    subpanelMsgLength = 33
    idGrayScale16 = 1

    panelCol = cols // 16
    panelRow = rows // 16

    img = np.zeros((rows, cols), dtype=np.uint8)

    n = 0
    for i in range(panelRow):
        for j in range(1, numSubpanel + 1):
            row_header = framevec[n]  # not used in reconstruction
            n += 1
            for k in range(subpanelMsgLength):
                for m in range(panelCol):
                    if k == 0:
                        # command byte: idGrayScale16 | (stretch << 1)
                        cmd = framevec[n]
                        n += 1
                    else:
                        byte = framevec[n]
                        n += 1
                        tmp1 = byte & 0x0F
                        tmp2 = (byte >> 4) & 0x0F

                        panelStartRowBeforeInvert = i * 16 + ((j - 1) % 2) * 8 + (k - 1) // 4
                        panelStartRow = (
                            panelStartRowBeforeInvert // 16 * 16
                            + 15 - (panelStartRowBeforeInvert % 16)
                        )
                        panelStartCol = m * 16 + (j // 3) * 8 + ((k - 1) % 4) * 2

                        img[panelStartRow, panelStartCol] = tmp1
                        img[panelStartRow, panelStartCol + 1] = tmp2
    return img

# ------------------------------------------------------------------
# High-level load + decode
# ------------------------------------------------------------------
def load_pat(path):
    NumPatsX, NumPatsY, gs_val, RowN, ColN, raw = read_header_and_raw(path)
    rows = RowN * 16
    cols = ColN * 16
    num_frames = NumPatsX * NumPatsY
    fsize = frame_size_bytes(RowN, ColN)

    expected = fsize * num_frames
    if raw.size < expected:
        raise ValueError(f"File too short: got {raw.size}, expected {expected}")

    frames = []
    for i in range(num_frames):
        vec = raw[i*fsize:(i+1)*fsize]
        img = decode_framevector_gs16(vec, rows, cols)
        frames.append(img)

    frames = np.array(frames, dtype=np.uint8)

    vmax = 15 if gs_val in (4, 16) else 1
    return frames, dict(frames=num_frames, rows=rows, cols=cols, vmax=vmax)

# ------------------------------------------------------------------
# Preview with slider
# ------------------------------------------------------------------
def preview_pat(path):
    frames, meta = load_pat(path)
    nframes, rows, cols, vmax = meta["frames"], meta["rows"], meta["cols"], meta["vmax"]

    fig, ax = plt.subplots()
    plt.subplots_adjust(bottom=0.2)
    im = ax.imshow(frames[0], cmap="gray", vmin=0, vmax=vmax)
    title = ax.set_title(f"{path}\nFrame 0 / {nframes-1}")
    ax.set_xticks([]); ax.set_yticks([])

    axframe = plt.axes([0.2, 0.08, 0.6, 0.03])
    slider = Slider(axframe, "Frame", 0, nframes-1, valinit=0, valstep=1)

    def update(val):
        idx = int(slider.val)
        im.set_data(frames[idx])
        title.set_text(f"{path}\nFrame {idx} / {nframes-1}")
        fig.canvas.draw_idle()

    slider.on_changed(update)
    plt.show()

# ------------------------------------------------------------------
# VS Code entry point
# ------------------------------------------------------------------
if __name__ == "__main__":
    FILENAME = "pat0006.pat"   # change this to your file
    preview_pat(FILENAME)
