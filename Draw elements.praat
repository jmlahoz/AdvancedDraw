# Draw elements
# José María Lahoz-Bengoechea (jmlahoz@ucm.es)
# Version 2022-06-19

# LICENSE
# (C) 2022 José María Lahoz-Bengoechea
# This file is part of the plugin_AdvancedDraw.
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License
# as published by the Free Software Foundation
# either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY, without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# For more details, you can find the GNU General Public License here:
# http://www.gnu.org/licenses/gpl-3.0.en.html
# This file runs on Praat, a software developed by Paul Boersma
# and David Weenink at University of Amsterdam.


# This script draws spectrogram, formants, pitch and/or intensity,
# as well as the selection within the window and the TextGrid with its tier names.

# This is an Editor script.

include utils.praat

@getinfo: 0

w_ini = extractNumber(editorinfo$,"Window start: ")
w_end = extractNumber(editorinfo$,"Window end: ")
w_mid = (w_ini + w_end) / 2
sel_ini = extractNumber(editorinfo$,"Selection start: ")
sel_end = extractNumber(editorinfo$,"Selection end: ")

spectro_floor = extractNumber(editorinfo$,"Spectrogram view from: ")
spectro_ceiling = extractNumber(editorinfo$,"Spectrogram view to: ")
pitch_floor = extractNumber(editorinfo$,"Pitch floor: ")
pitch_ceiling = extractNumber(editorinfo$,"Pitch ceiling: ")
intensity_floor = extractNumber(editorinfo$,"Intensity view from: ")
intensity_ceiling = extractNumber(editorinfo$,"Intensity view to: ")

endeditor

beginPause: "Draw elements..."
boolean: "erase_first", 1
optionMenu: "write_name_at_top", 1
option: "no"
option: "far"
option: "near"
comment: "Customized name (else, default window title):"
text: "customized_name", ""
boolean: "draw_spectrogram", 1
boolean: "draw_formants", 0
optionMenu: "formant_legend", 1
option: "none"
option: "left"
option: "only dotted lines"
option: "left & dotted lines"
boolean: "draw_pitch", 0
optionMenu: "pitch_legend", 1
option: "none"
option: "left"
option: "left & dotted lines"
option: "right"
boolean: "draw_intensity", 0
optionMenu: "intensity_legend", 1
option: "none"
option: "left"
option: "left & dotted lines"
option: "right"
if data_type$ = "TextGrid"
boolean: "draw_textgrid", 1
boolean: "draw_tier_names", 1
endif
comment: ""
boolean: "draw_window_times", 0
boolean: "draw_selection_hairs", 0
boolean: "draw_selection_times", 0
clicked = endPause: "OK", 1

if data_type$ = "TextGrid"
if draw_textgrid
beginPause: "Set figure size..."
comment: "Set the size of the spectrogram / the melody curve."
comment: "The TextGrid (if any) will be automatically added below."
comment: "Range is given in inches."
real: "left_horizontal_range", 0
real: "right_horizontal_range", 8
real: "left_vertical_range", 0
real: "right_vertical_range", 3
clicked2 = endPause: "OK", 1
endif
endif

@getws

if erase_first
Erase all
endif

Font size... 14

if data_type$ = "TextGrid"
if draw_textgrid
Select outer viewport: left_horizontal_range, right_horizontal_range, left_vertical_range, right_vertical_range
endif
endif

if draw_spectrogram
Black
Line width... 1
editor 'data_type$' 'data_name$'
Paint visible spectrogram... no no no no no
endeditor
endif

if draw_formants
Red
Line width... 1
editor 'data_type$' 'data_name$'
Draw visible formant contour... no no no no no
endeditor
endif

if draw_pitch
Cyan
Line width... 2
editor 'data_type$' 'data_name$'
Draw visible pitch contour... no no no no no no
endeditor
endif

if draw_intensity
Yellow
Line width... 2
editor 'data_type$' 'data_name$'
Draw visible intensity contour... no no no no no
endeditor
endif

Black
Line width... 0.5
Draw inner box

if write_name_at_top != 1
if customized_name$ = ""
customized_name$ = data_name$
customized_name$ = replace$(customized_name$,"_"," ",0)
endif
if write_name_at_top = 2
Text top... yes 'customized_name$'
elsif write_name_at_top = 3
Text top... no 'customized_name$'
endif
endif

if draw_window_times
Axes... 'w_ini' 'w_end' 0 5000
Black
Text special... 'w_ini' left -250 half Times 12 0 'w_ini:3'
Text special... 'w_end' right -250 half Times 12 0 'w_end:3'
Text special... 'w_mid' centre -800 half Times 12 0 Time (s)
endif

if draw_selection_hairs
Axes... 'w_ini' 'w_end' 0 5000
Black
Line width... 0.5
Dotted line
Draw line... 'sel_ini' 0 'sel_ini' 5000
Draw line... 'sel_end' 0 'sel_end' 5000
Solid line
endif

if draw_selection_times
Axes... 'w_ini' 'w_end' 0 5000
Black
Text special... 'sel_ini' centre -250 half Times 12 0 'sel_ini:3'
Text special... 'sel_end' centre -250 half Times 12 0 'sel_end:3'
if draw_window_times != 1
Text special... 'w_mid' centre -800 half Times 12 0 Time (s)
endif
endif

if (draw_spectrogram || draw_formants) and formant_legend != 1
Axes... 'w_ini' 'w_end' 'spectro_floor' 'spectro_ceiling'
if formant_legend = 2 or formant_legend = 4
One mark left... 'spectro_floor' yes no no
One mark left... 'spectro_ceiling' yes no no
Axes... 0.58 5.41 2.11 0.38
Text special... -0.07 left 0.25 half Times 12 0 Spectrum (Hz)
Axes... 'w_ini' 'w_end' 'spectro_floor' 'spectro_ceiling'
endif
if formant_legend = 3 or formant_legend = 4
Marks left every... 1 1000 no no yes
Axes... 0.58 5.41 'spectro_floor' 'spectro_ceiling'
Magenta
Text special... 0.60 left 1000 bottom Times 12 0 1kHz
Text special... 0.60 left 2000 bottom Times 12 0 2kHz
Text special... 0.60 left 3000 bottom Times 12 0 3kHz
Text special... 0.60 left 4000 bottom Times 12 0 4kHz
Black
Axes... 'w_ini' 'w_end' 'spectro_floor' 'spectro_ceiling'
endif
endif

if draw_pitch and pitch_legend != 1
Axes... 'w_ini' 'w_end' 'pitch_floor' 'pitch_ceiling'
if pitch_legend = 2 or pitch_legend = 3
One mark left... 'pitch_floor' yes no no 
One mark left... 'pitch_ceiling' yes no no 
Axes... 0.58 5.41 2.11 0.38
Text special... 0.05 left 0.25 half Times 12 0 Pitch (Hz)
Axes... 'w_ini' 'w_end' 'pitch_floor' 'pitch_ceiling'
if pitch_legend = 3
Marks left every... 1 50 no no yes
endif
elsif pitch_legend = 4
One mark right... 'pitch_floor' yes no no 
One mark right... 'pitch_ceiling' yes no no 
Axes... 0.58 5.41 2.11 0.38
Text special... 5.97 right 0.25 half Times 12 0 Pitch (Hz)
Axes... 'w_ini' 'w_end' 'pitch_floor' 'pitch_ceiling'
endif
endif

if draw_intensity and intensity_legend != 1
Axes... 'w_ini' 'w_end' 'intensity_floor' 'intensity_ceiling'
if intensity_legend = 2 or intensity_legend = 3
One mark left... 'intensity_floor' yes no no 
One mark left... 'intensity_ceiling' yes no no 
Axes... 0.58 5.41 2.11 0.38
Text special... 0.09 left 0.25 half Times 12 0 Intensity (dB)
Axes... 'w_ini' 'w_end' 'intensity_floor' 'intensity_ceiling'
if intensity_legend = 3
Marks left every... 1 10 no no yes
endif
elsif intensity_legend = 4
One mark right... 'intensity_floor' yes no no 
One mark right... 'intensity_ceiling' yes no no 
Axes... 0.58 5.41 2.11 0.38
Text special... 5.97 right 0.25 half Times 12 0 Intensity (dB)
Axes... 'w_ini' 'w_end' 'intensity_floor' 'intensity_ceiling'
endif
endif

if data_type$ = "TextGrid"
if draw_textgrid
@selobj: 0, 1
ntier = Get number of tiers
outer_inch = 'right_vertical_range' + (0.5*'ntier') + 'right_vertical_range'/3
Select outer viewport: left_horizontal_range, right_horizontal_range, left_vertical_range, outer_inch
Black
Line width... 1
editor 'data_type$' 'data_name$'
Draw visible TextGrid... no no no no no
endeditor
endif
endif

if data_type$ = "TextGrid"
if draw_tier_names and draw_textgrid
Select outer viewport: left_horizontal_range, right_horizontal_range, right_vertical_range-0.5, outer_inch
Axes... 0 1 0 1
# tier_width = (('outer_inch' - 3/8) - 2.25)/'ntier'
@selobj: 0, 1
for itier from 1 to ntier
tier_name$ = Get tier name... 'ntier'-'itier'+1
Text special... 1.01 left ((1/ntier)*(itier-1)+(1/(2*ntier))) half Times 10 0 'tier_name$'
# Text special... 5.45 left (2.25+('tier_width'/2)+(('itier'-1)*'tier_width')) half Times 8 0 'tier_name$'
endfor
Select outer viewport: 'left_horizontal_range', 'right_horizontal_range', 'left_vertical_range', 'outer_inch'
endif
endif

@restorews

