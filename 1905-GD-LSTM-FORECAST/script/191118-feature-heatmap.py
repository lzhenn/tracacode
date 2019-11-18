#! /usr/bin/env python
#  Deal with 59287 station data 
#   
#               L_Zealot
#               Jul 17, 2019
#               Guangzhou, GD
#

import os
import json
import numpy as np
import pandas as pd
import datetime

import matplotlib
import matplotlib.pyplot as plt
# sphinx_gallery_thumbnail_number = 2

#-------------------------------------
# Function Definition Part
#-------------------------------------

def heatmap(data, row_labels, col_labels, ax=None,
            cbar_kw={}, cbarlabel="", **kwargs):
    """
    Create a heatmap from a numpy array and two lists of labels.

    Parameters
    ----------
    data
        A 2D numpy array of shape (N, M).
    row_labels
        A list or array of length N with the labels for the rows.
    col_labels
        A list or array of length M with the labels for the columns.
    ax
        A `matplotlib.axes.Axes` instance to which the heatmap is plotted.  If
        not provided, use current axes or create a new one.  Optional.
    cbar_kw
        A dictionary with arguments to `matplotlib.Figure.colorbar`.  Optional.
    cbarlabel
        The label for the colorbar.  Optional.
    **kwargs
        All other arguments are forwarded to `imshow`.
    """

    if not ax:
        ax = plt.gca()

    # Plot the heatmap
    im = ax.imshow(data, **kwargs)



    
    # Create colorbar
    cbar = ax.figure.colorbar(im, ax=ax, **cbar_kw)
    cbar.ax.set_ylabel(cbarlabel, rotation=-90, va="bottom", fontsize=20)
    cbar.ax.tick_params(labelsize=20)
    # We want to show all ticks...
    ax.set_xticks(np.arange(data.shape[1]))
    ax.set_yticks(np.arange(data.shape[0]))
    # ... and label them with the respective list entries.
    ax.set_xticklabels(col_labels, fontsize=12)
    ax.set_yticklabels(row_labels, fontsize=12)

    # Let the horizontal axes labeling appear on top.
    ax.tick_params(top=True, bottom=False,
                   labeltop=True, labelbottom=False)

    # Rotate the tick labels and set their alignment.
    plt.setp(ax.get_xticklabels(), rotation=-60, ha="right",
             rotation_mode="anchor")

    # Turn spines off and create white grid.
    for edge, spine in ax.spines.items():
        spine.set_visible(False)

    ax.set_xticks(np.arange(data.shape[1]+1)-.5, minor=True)
    ax.set_yticks(np.arange(data.shape[0]+1)-.5, minor=True)
    ax.grid(which="minor", color="w", linestyle='-', linewidth=3)
    ax.tick_params(which="minor", bottom=False, left=False)

    return im, cbar

# def

def annotate_heatmap(im, data=None, valfmt="{x:.2f}",
                     textcolors=["black", "white"],
                     threshold=None, **textkw):
    """
    A function to annotate a heatmap.

    Parameters
    ----------
    im
        The AxesImage to be labeled.
    data
        Data used to annotate.  If None, the image's data is used.  Optional.
    valfmt
        The format of the annotations inside the heatmap.  This should either
        use the string format method, e.g. "$ {x:.2f}", or be a
        `matplotlib.ticker.Formatter`.  Optional.
    textcolors
        A list or array of two color specifications.  The first is used for
        values below a threshold, the second for those above.  Optional.
    threshold
        Value in data units according to which the colors from textcolors are
        applied.  If None (the default) uses the middle of the colormap as
        separation.  Optional.
    **kwargs
        All other arguments are forwarded to each call to `text` used to create
        the text labels.
    """

    if not isinstance(data, (list, np.ndarray)):
        data = im.get_array()

    # Normalize the threshold to the images color range.
    if threshold is not None:
        threshold = im.norm(threshold)
    else:
        threshold = im.norm(data.max())/2.

    # Set default alignment to center, but allow it to be
    # overwritten by textkw.
    kw = dict(horizontalalignment="center",
              verticalalignment="center")
    kw.update(textkw)

    # Get the formatter in case a string is supplied
    if isinstance(valfmt, str):
        valfmt = matplotlib.ticker.StrMethodFormatter(valfmt)

    # Loop over the data and create a `Text` for each "pixel".
    # Change the text's color depending on the data.
    texts = []
    for i in range(data.shape[0]):
        for j in range(data.shape[1]):
            kw.update(color=textcolors[int(im.norm(data[i, j]) > threshold)])
            text = im.axes.text(j, i, valfmt(data[i, j], None), **kw)
            texts.append(text)

    return texts





def main():

#----------------------------------------------------
# User Defined Part
#----------------------------------------------------

    # Result Input File
    result_in_file='../testdata/result_08-16.json'

#----------------------------------------------------
# Main function
#----------------------------------------------------
    
    with open(result_in_file) as f:
        result_dic=json.load(f)
    
    features=[]
    stas=[]
    nsta=0

    features=['Y_lag'+str(itm) for itm in range(1,25)]
    for idx, itm in result_dic.items():
        try:
            features=list(set(itm['w_name']).union(set(features)))
            stas.append(idx)
            nsta=nsta+1

        except:
            continue # one station with empty return
    features=['Y_lag'+str(itm) for itm in range(1,25)]
    features.append('NINO_lag21')
    features.append('NINO_lag24')
   #features.sort()
    print(features)
    #exit()
    nfea=len(features)

    print(features)
    print(stas)
    
    data=np.zeros((nfea, nsta))


    # fill in the heatmap array
    ista=0
    for idx, itm in result_dic.items():
        try: 
            names=itm['w_name']
            wgts=itm['w']
            for (iname,iwgt) in zip(names,wgts):
               ipos=features.index(iname)
               data[ipos,ista]=iwgt
            ista=ista+1
        except:
            continue
    data=abs(data)
    print(data)

    fig, ax = plt.subplots()

    im, cbar = heatmap(data, features, stas, ax=ax,
                   cmap="YlGn", cbarlabel="weight squre")
    
    #texts = annotate_heatmap(im, valfmt="{x:.4f}")

    fig.tight_layout()
    plt.show() 


if __name__ == "__main__":
    main()


