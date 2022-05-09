Sub Macro_change_fig_title()
'   This Word Macro serve as the tool to change the figure title number
'when you insert a plot into the manuscript.
'
'   Example:
'   Fig. 4  --> Fig. 5
'   Fig. 11 --> Fig. 12
'
'   Your need to set c_start and c_end variables

    Dim c_start As Integer
    Dim c_end As Integer
    
    'Start point
    c_start = 4

    'End point
    c_end = 11
    
    
    For i = c_start To c_end
        j = (c_start + c_end) - i
        
        
'Fig
        Selection.Find.ClearFormatting
        Selection.Find.Replacement.ClearFormatting
        With Selection.Find
            .Text = "Fig. " & Trim(Str(j))
            .Replacement.Text = "Fig. " & Trim(Str(j + 1))
            .Forward = True
            .Wrap = wdFindContinue
            .Format = False
            .MatchCase = False
            .MatchWholeWord = False
            .MatchByte = True
            .MatchWildcards = False
            .MatchSoundsLike = False
            .MatchAllWordForms = False
        End With
        Selection.Find.Execute Replace:=wdReplaceAll
 'Figs
        Selection.Find.ClearFormatting
        Selection.Find.Replacement.ClearFormatting
        With Selection.Find
            .Text = "Figs. " & Trim(Str(j))
            .Replacement.Text = "Figs. " & Trim(Str(j + 1))
            .Forward = True
            .Wrap = wdFindContinue
            .Format = False
            .MatchCase = False
            .MatchWholeWord = False
            .MatchByte = True
            .MatchWildcards = False
            .MatchSoundsLike = False
            .MatchAllWordForms = False
        End With
        Selection.Find.Execute Replace:=wdReplaceAll

'Figure
        Selection.Find.ClearFormatting
        Selection.Find.Replacement.ClearFormatting
        With Selection.Find
            .Text = "Figure " & Trim(Str(j))
            .Replacement.Text = "Figure " & Trim(Str(j + 1))
            .Forward = True
            .Wrap = wdFindContinue
            .Format = False
            .MatchCase = False
            .MatchWholeWord = False
            .MatchByte = True
            .MatchWildcards = False
            .MatchSoundsLike = False
            .MatchAllWordForms = False
        End With
        Selection.Find.Execute Replace:=wdReplaceAll
'Figures
        Selection.Find.ClearFormatting
        Selection.Find.Replacement.ClearFormatting
        With Selection.Find
            .Text = "Figures " & Trim(Str(j))
            .Replacement.Text = "Figures " & Trim(Str(j + 1))
            .Forward = True
            .Wrap = wdFindContinue
            .Format = False
            .MatchCase = False
            .MatchWholeWord = False
            .MatchByte = True
            .MatchWildcards = False
            .MatchSoundsLike = False
            .MatchAllWordForms = False
        End With
        Selection.Find.Execute Replace:=wdReplaceAll

    Next i
End Sub

