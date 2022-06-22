# Draw elements
# José María Lahoz-Bengoechea (jmlahoz@ucm.es)
# Version 2022-06-22

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
# Do not click on the picture window before you save the figure,
# since it cannot be selected manually at the proper margins.

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

endeditor

beginPause: "Draw elements..."
boolean: "erase_first", 1
real: "figure_width", 7
natural: "font_size", 14
optionMenu: "write_name_at_top", 1
option: "no"
option: "far"
option: "near"
comment: "Customized name (else, default window title):"
text: "customized_name", ""
boolean: "draw_spectrogram", 1
boolean: "draw_formants", 0
optionMenu: "formant_legend", 2
option: "none"
option: "left"
option: "only dotted lines"
option: "left & dotted lines"
boolean: "draw_pitch", 0
optionMenu: "pitch_legend", 4
option: "none"
option: "left"
option: "left & dotted lines"
option: "right"
if data_type$ = "TextGrid"
boolean: "draw_textgrid", 1
boolean: "draw_tier_names", 1
endif
comment: ""
boolean: "draw_window_times", 1
boolean: "draw_selection_hairs", 0
boolean: "draw_selection_times", 0
clicked = endPause: "OK", 1

@getws

if erase_first
Erase all
endif

Font size... 'font_size'
font_size2 = font_size*(6/7)

Select inner viewport: 0.5, 0.5+figure_width, 0.5, 2.5

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
Axes... 0 1 0 1
Black
Text special... 0 left -0.01 top Times 'font_size2' 0 'w_ini:3'
Text special... 1 right -0.01 top Times 'font_size2' 0 'w_end:3'
Text special... 0.5 centre -0.01 top Times 'font_size2' 0 Time (s)
endif

if draw_selection_hairs
Axes... 'w_ini' 'w_end' 0 1
Black
Line width... 0.5
Dotted line
Draw line... 'sel_ini' 0 'sel_ini' 1
Draw line... 'sel_end' 0 'sel_end' 1
Solid line
endif

if draw_selection_times
Axes... 'w_ini' 'w_end' 0 1
Black
Text special... 'sel_ini' centre -0.01 top Times 'font_size2' 0 'sel_ini:3'
Text special... 'sel_end' centre -0.01 top Times 'font_size2' 0 'sel_end:3'
if draw_window_times != 1
Text special... 'w_mid' centre -0.01 top Times 'font_size2' 0 Time (s)
endif
endif

if (draw_spectrogram || draw_formants) and formant_legend != 1
Axes... 0 1 0 1
if formant_legend = 2 or formant_legend = 4
Text special... -0.01 right 0 half Times 'font_size2' 0 'spectro_floor'
Text special... -0.01 right 1 half Times 'font_size2' 0 'spectro_ceiling'
Text special... -0.025 right 0.725 half Times 'font_size2' 90 Spectrum (Hz)
endif
if formant_legend = 3 or formant_legend = 4
nkhz = floor('spectro_ceiling'/1000)
heightperkhz = 1/nkhz
Marks left every... 1 heightperkhz no no yes
Magenta
for ikhz from 1 to nkhz-1
khz$ = string$(ikhz)+"kHz"
Text special... 0.01 left ikhz*heightperkhz bottom Times 'font_size2' 0 'khz$'
endfor
Black
endif
endif

if draw_pitch and pitch_legend != 1
Axes... 0 1 0 1
if pitch_legend = 2 or pitch_legend = 3
Text special... -0.01 right 0 half Times 'font_size2' 0 'pitch_floor'
Text special... -0.01 right 1 half Times 'font_size2' 0 'pitch_ceiling'
Text special... -0.025 right 0.65 half Times 'font_size2' 90 Pitch (Hz)
if pitch_legend = 3
Axes... 0 1 'pitch_floor' 'pitch_ceiling'
Marks left every... 1 50 no no yes
pitch_bottom = (ceiling(pitch_floor/50))*50
if pitch_bottom = pitch_floor
pitch_bottom = pitch_bottom+50
endif
pitch_top = (floor(pitch_ceiling/50))*50
if pitch_top = pitch_ceiling
pitch_top = pitch_top-50
endif
Blue
for ipitchline from pitch_bottom/50 to pitch_top/50
pitch$ = string$((ipitchline*50))+" Hz"
Text special... 0.01 left ipitchline*50 bottom Times 'font_size2' 0 'pitch$'
endfor
Black
Axes... 0 1 0 1
endif
elsif pitch_legend = 4
Text special... 1.01 left 0 half Times 'font_size2' 0 'pitch_floor'
Text special... 1.01 left 1 half Times 'font_size2' 0 'pitch_ceiling'
Text special... 1.025 left 0.65 half Times 'font_size2' 270 Pitch (Hz)
endif
endif

if data_type$ = "TextGrid"
if draw_textgrid
@selobj: 0, 1
ntier = Get number of tiers
tg_bottom = 3 + ((2/3)*'ntier')
# The factor (2/3) yields a fairly constant height for tiers regardless the number of tiers.
# The space between the sound and the TextGrid is also the same height as one tier.
Select inner viewport: 0.5, 0.5+figure_width, 0.5, tg_bottom
Black
Line width... 1
editor 'data_type$' 'data_name$'
Draw visible TextGrid... no no no no no
endeditor
endif
endif

if data_type$ = "TextGrid"
if draw_tier_names and draw_textgrid
Select inner viewport: 0.5, 0.5+figure_width, 2.5, tg_bottom
Axes... 0 1 0 1
@selobj: 0, 1
for itier from 1 to ntier
tier_name$ = Get tier name... 'ntier'-'itier'+1
Text special... 1.01 left ((2*'itier'-1)/(2*'ntier'+2)) half Times 'font_size2' 0 'tier_name$'
# Given the axes, the range 0-1 encompasses all tiers and the space between the sound and the TextGrid,
# so each tier height = 1/(ntier+1).
# The bottommost tier label is at half the first tier height: (1/(ntier+1))/2 = 1/(2*ntier+2).
# Each increment is (itier-1)*(1/(ntier+1)) = (itier-1)/(ntier+1) = 2*(itier-1)/2*(ntier+1) = (2*itier-2)/(2*ntier+2).
# If we add the starting point plus the increment, (1 + 2*itier-2))/(2*ntier+2) = (2*itier-1)/(2*ntier+2).
endfor
Select inner viewport: 0.5, 0.5+figure_width, 0.5, tg_bottom
endif
endif

@restorews

