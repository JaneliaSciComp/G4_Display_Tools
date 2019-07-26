//This is a mex function to convert the frame matrix to a vector for G4 panels
//Currently we don't support RC. 
//The grayscale we support is 1 and 4.
//Jinyang Liu 
//Howard Hughes Medical Institute
//Usage of the mex function
//           frameout = make_frame_vector_g4(framein);
//
//framein is a input frame matrix
//frameout is the output vector

#include "mex.h"
#include "matrix.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    //declare variables   
    double *patternData; 
    char  * convertedPatternData;
    const mwSize *dataDims;      
    int dataRow, dataCol, dataDimNum; 
    int i, j, k, m, n, p, panelCol, panelRow;
    
    const mwSize *dims;
    int panelStartCol, panelStartRowBeforeInvert, panelStartRow;
    int tmp1,tmp2,outputVectorLength;      
	const int numSubpanel = 4;
	const int subpanelMsgLength = 9;
	const int idGrayScale2 = 0;
    int stretch;
        
    if(nrhs == 1) {
        stretch = 0;
    } else if(nrhs==2) {
        stretch = (int)mxGetScalar(prhs[1]);
    //} else{
    //    mexErrMsgIdAndTxt( "MATLAB:make_framevector_gs2", "Too many input arguments.");
    }
    
    
    //associate inputs   
    patternData = mxGetPr(prhs[0]);         
    
    //figure out dimensions   
    dataDims = mxGetDimensions(prhs[0]);   
    dataDimNum = mxGetNumberOfDimensions(prhs[0]);   
    
    dataRow = (int)dataDims[0];
    dataCol = (int)dataDims[1];
    //mexPrintf("dataRow %d, dataCol is %d\n", dataRow, dataCol);  

    //calculate output array
    panelCol = dataCol/16;
    panelRow = dataRow/16;
    
    outputVectorLength = (panelCol*subpanelMsgLength + 1)*panelRow*numSubpanel;
    
    //associate outputs 
    plhs[0] = mxCreateNumericMatrix(1,outputVectorLength,mxUINT8_CLASS,mxREAL);
    convertedPatternData = (char *)mxGetPr(plhs[0]);
    
	n=0;
    //i:row
    for(i = 0; i < panelRow; ++i)
    {
        //i:numSubpanel
        for (j=1; j<=numSubpanel; ++j)
        {				
			convertedPatternData[n] = i+1;
			++n;
            for (k=0; k<subpanelMsgLength; ++k)
            {
				for(m=0; m<panelCol; ++m){
					if (k== 0) {
                        convertedPatternData[n] = idGrayScale2|(stretch<<1);
						++n;
						}
					else{
						panelStartRowBeforeInvert = i*16 + (j-1)%2*8 + k-1;
						//added the following line for the unInvertPanels function in Matlab
						panelStartRow = panelStartRowBeforeInvert/16*16 + 15 - panelStartRowBeforeInvert%16;
						panelStartCol = m*16 + (j/3)*8;
						//mexPrintf("panelStartRow %d, panelStartCol is %d\n", panelStartRow, panelStartCol); 
						tmp1=0;
						for(p=0; p<8; ++p)
						{
							tmp2 = (int)patternData[(panelStartCol+p)*dataRow + panelStartRow];						
							if (tmp2<0||tmp2>1)
							{
								mexPrintf("frame values must between bigger than 0 and less than 2\n");
								return;
							}

							tmp1 = tmp1|tmp2<<p;
						}

						convertedPatternData[n]= tmp1;
						//mexPrintf("panelStartRow %d, panelStartCol is %d\n", panelStartRow, panelStartCol); 
						//mexPrintf("tmp1 %d, tmp2 is %d\n", tmp1, tmp2); 
						//mexPrintf("output is %d\n", convertedPatternData[n]); 
						++n;
						}

					}
			}
			
		}
    }	
 
    return; 
}