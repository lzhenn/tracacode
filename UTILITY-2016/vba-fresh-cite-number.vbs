
Sub refresh_cite_number()
'
' Macro: Refresh all citing number in plain-texted word doc
'                       
'                           Zhenning Li
'                           20160607
    Dim nSpace As integer
    nSpace = 2
    Selection.Find.ClearFormatting
    Selection.Find.Replacement.ClearFormatting
    With Selection.Find.Replacement.Font
        .Superscript = True
        .Subscript = False
    End With
    With Selection.Find
        .Text = "[0-9]{1,}"
        .Replacement.Text = "1"
        .Forward = True
        .Wrap = wdFindContinue
        .Format = True
        .MatchCase = False
        .MatchWholeWord = False
        .MatchByte = False
        .MatchAllWordForms = False
        .MatchSoundsLike = False
        .MatchWildcards = True
    End With
    Selection.Find.Execute

    Selection.MoveRight Unit:=wdCharacter, Count:=2, Extend:=wdExtend

    With Selection
        .Find.Replacement.Text = Trim(Str(Val(.Text) + 1))
        .Find.Execute Replace:=wdReplaceOne
    End With
    Selection.MoveRight Unit:=wdCharacter, Count:=2, Extend:=wdExtend
    Selection.Find.Execute
End Sub
