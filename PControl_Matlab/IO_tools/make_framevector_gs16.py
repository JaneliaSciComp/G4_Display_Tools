import numpy as np

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

convertedPatternData_conv = make_framevector_gs16(framein, stretch)