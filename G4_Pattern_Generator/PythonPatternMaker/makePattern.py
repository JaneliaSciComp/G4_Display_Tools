import numpy as np
import struct
import os
import json
import re

def pack_uint16_le(val):
    """Pack unsigned 16-bit int as little-endian bytes."""
    return struct.pack('<H', val)  # '<H' = little-endian unsigned short

def make_framevector_gs16(framein, stretch):
    """
    Python version of make_framevector_gs16.
    
    Parameters:
    - framein: 2D numpy array of shape (dataRow, dataCol)
    - stretch: optional int (0 or 1)
    
    Returns:
    - 1D numpy array of uint8
    """

    dataRow, dataCol = np.shape(framein)
    numSubpanel = 4
    subpanelMsgLength = 33
    idGrayScale16 = 1

    panelCol = dataCol // 16
    panelRow = dataRow // 16

    outputVectorLength = (panelCol * subpanelMsgLength + 1) * panelRow * numSubpanel
    convertedPatternData = np.zeros(outputVectorLength, dtype=np.uint8)
    stretch = int(stretch)

    n = 0
    for i in range(panelRow):
        for j in range(1, numSubpanel + 1):
            # row header
            convertedPatternData[n] = i + 1
            n += 1
            for k in range(subpanelMsgLength):
                for m in range(panelCol):
                    if k == 0:
                        convertedPatternData[n] = idGrayScale16 | (stretch << 1)
                        n += 1
                    else:
                        panelStartRowBeforeInvert = i * 16 + ((j - 1) % 2) * 8 + (k - 1) // 4
                        panelStartRow = panelStartRowBeforeInvert // 16 * 16 + 15 - (panelStartRowBeforeInvert % 16)
                        panelStartCol = m * 16 + (j // 3) * 8 + ((k - 1) % 4) * 2

                        tmp1 = int(framein[panelStartRow, panelStartCol])
                        tmp2 = int(framein[panelStartRow, panelStartCol + 1])

                        if not (0 <= tmp1 <= 15) or not (0 <= tmp2 <= 15):
                            raise ValueError("frame values must be >= 0 and <= 15")

                        convertedPatternData[n] = tmp1 | (tmp2 << 4)
                        n += 1

    convertedPatternData_conv = convertedPatternData.tolist()
    return convertedPatternData_conv

def make_pattern_vector_g4(pattern):
    Pats = pattern['Pats']  # shape: (PatR, PatC, NumPatsX, NumPatsY)
    stretch = pattern['stretch']
    gs_val = 16 if pattern['gs_val'] == 4 else 2

    PatR, PatC, NumPatsX, NumPatsY = Pats.shape
    RowN = PatR // 16
    ColN = PatC // 16

    # Construct header with little-endian 16-bit values
    header = (
        pack_uint16_le(NumPatsX) +
        pack_uint16_le(NumPatsY) +
        bytes([gs_val, RowN, ColN])
    )

    pat_vector = bytearray(header)

    for j in range(NumPatsY):
        for i in range(NumPatsX):
            frame = Pats[:, :, i, j]
            stretch_val = stretch[i, j]

            if gs_val == 16:
                stretch_val = min(stretch_val, 20)
            elif gs_val == 2:
                stretch_val = min(stretch_val, 107)
            else:
                raise ValueError("Invalid gs_val")

            # >>> Call your existing Python function <<<
            # Assumes make_framevector_gs16.py defines `make_framevector_gs16(frame, stretch)`
           #from make_framevector_gs16 import make_framevector_gs16
            frameOut = make_framevector_gs16(frame, stretch_val)

            # Make sure it's a NumPy array of uint8 before converting to bytes
            frameOut = np.asarray(frameOut, dtype=np.uint8)
            pat_vector.extend(frameOut.tobytes())

    return pat_vector

def get_pattern_id(save_dir):
    """
    Finds the next available 4-digit pattern ID in the given directory.
    Matches files named like 'pat####.pat', where #### is a 4-digit ID.

    Args:
        save_dir (str): The directory to scan for .pat files.

    Returns:
        int: The next available ID (starting from 1).
    """
    if not os.path.exists(save_dir):
        os.makedirs(save_dir)

    taken_ids = []

    for filename in os.listdir(save_dir):
        if filename.lower().endswith('.pat'):
            digits = re.findall(r'\d', filename)
            if len(digits) != 4:
                raise ValueError(f"File '{filename}' appears to have incorrect ID (should be exactly 4 digits)")
            id_str = ''.join(digits)
            taken_ids.append(int(id_str))

    if not taken_ids:
        return 1

    max_id = max(taken_ids)
    return max_id + 1

def save_pattern_g4(Pats, param, stretch, save_dir, filename):


    # Create pattern dict
    pattern = {
        'Pats': Pats,
        'x_num': Pats.shape[2],
        'y_num': Pats.shape[3],
        'gs_val': param['gs_val'],
        'stretch': stretch,
        'param': param,
    }
    # Generate binary pattern vector for hardware
    pattern['data'] = make_pattern_vector_g4(pattern)

    # Create save directory if needed
    os.makedirs(save_dir, exist_ok=True)

    # Format file names
    pattern_id = int(param['ID'])
    mat_basename = f"{pattern_id:04d}_{filename}_G4.npz"
    pat_basename = f"pat{pattern_id:04d}.pat"

    mat_path = os.path.join(save_dir, mat_basename)
    pat_path = os.path.join(save_dir, pat_basename)

    np.savez_compressed(mat_path,
                        Pats=pattern['Pats'],
                        x_num=pattern['x_num'],
                        y_num=pattern['y_num'],
                        gs_val=pattern['gs_val'],
                        stretch=pattern['stretch'],
                        param=json.dumps(pattern['param']),
                        data=np.array(pattern['data'], dtype=np.uint8))
    
    print(f"Saved: {mat_path}")
    
     # Save .pat binary file
    with open(pat_path, 'wb') as f:
        f.write(pattern['data'])

    print(f"Saved: {pat_path}")


# Example usage:
if __name__ == "__main__":

    # THIS IS THE SCRIPT THAT CALLS ABOVE FUNCTIONS. Use this script to make the
    # 3d array and set the values of the parameters stored in the pattern. 

    # Dimensions of pattern
    rows = 64 #48 for 3 row arena, 64 for 4 row arena
    cols = 192
    frames = 24

    ##### THIS FOLLOWING CODE IS ONLY FOR ONE PARTICULAR PATTERN. 
    # CAN CALL FUNCTION INSTEAD TO CREATE YOUR OWN ARRAY

    # Create the base pattern for one row of a single frame
    pattern_row = []
    for i in range(cols // 12):
        val = 15 if i % 2 == 0 else 0
        pattern_row.extend([val] * 12)
    pattern_row = np.array(pattern_row, dtype=np.uint8)

    # Initialize the full array
    pattern_array_3d = np.zeros((rows, cols, frames), dtype=np.uint8)

    # Create each frame by circularly shifting the previous frame
    for f in range(frames):
        shifted_row = np.roll(pattern_row, f)
        pattern_array_3d[:, :, f] = np.tile(shifted_row, (rows, 1))

    # Expand to 4D by adding a singleton dimension, since 4D is not yet implemented
    pattern_array = np.expand_dims(pattern_array_3d, axis=-1)  # shape: (64, 192, 24, 1)  
    stretch = np.ones((24,1),dtype=np.uint8)  

    ########

    Pats = pattern_array
    save_dir = r"C:\Users\taylo\OneDrive\Desktop"
    ID = get_pattern_id(save_dir)
    patName = '4RowSqGrate'
    
    param = {
        'gs_val': 4,
        'arena_pitch': 0,
        'ID': ID,
        'px_rng': 0
    }

    save_pattern_g4(Pats, param, stretch, save_dir, patName)
