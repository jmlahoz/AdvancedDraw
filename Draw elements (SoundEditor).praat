form Draw...
boolean erase_first 0
optionmenu write_name_at_top: 1
option no
option far
option near
comment Customized name (else, default window title):
text customized_name 
boolean draw_spectrogram 1
boolean draw_formants 0
optionmenu formant_legend: 1
option none
option left
option only dotted lines
option left & dotted lines
boolean draw_pitch 0
optionmenu pitch_legend: 1
option none
option left
option left & dotted lines
option right
boolean draw_intensity 0
optionmenu intensity_legend: 1
option none
option left
option left & dotted lines
option right
boolean draw_window_times 0
boolean draw_selection_hairs 0
boolean draw_selection_times 0
endform

info$ = Editor info

data_type$ = extractLine$(info$,"Data type: ")
data_name$ = extractLine$(info$,"Data name: ")

w_start = extractNumber(info$,"Window start: ")
w_end = extractNumber(info$,"Window end: ")


spectro_floor = extractNumber(info$,"Spectrogram view from: ")
spectro_ceiling = extractNumber(info$,"Spectrogram view to: ")
pitch_floor = extractNumber(info$,"Pitch floor: ")
pitch_ceiling = extractNumber(info$,"Pitch ceiling: ")
intensity_floor = extractNumber(info$,"Intensity view from: ")
intensity_ceiling = extractNumber(info$,"Intensity view to: ")

endeditor

if erase_first
Erase all
endif

# Select outer viewport... 0 6 0 2.5

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
endif
if write_name_at_top = 2
Text top... yes 'customized_name$'
elsif write_name_at_top = 3
Text top... no 'customized_name$'
endif
endif

if draw_window_times
Axes... 'w_start' 'w_end' 0 5000
Black
Text special... 'w_start' left -250 half Times 8 0 'w_start:3'
Text special... 'w_end' right -250 half Times 8 0 'w_end:3'
endif

if draw_selection_hairs
sel_start = extractNumber(info$,"Selection start: ")
sel_end = extractNumber(info$,"Selection end: ")
Axes... 'w_start' 'w_end' 0 5000
Black
Line width... 0.5
Dotted line
Draw line... 'sel_start' 0 'sel_start' 5000
Draw line... 'sel_end' 0 'sel_end' 5000
Solid line
endif

if draw_selection_times
sel_start = extractNumber(info$,"Selection start: ")
sel_end = extractNumber(info$,"Selection end: ")
Axes... 'w_start' 'w_end' 0 5000
Black
Text special... 'sel_start' centre -250 half Times 8 0 'sel_start:3'
Text special... 'sel_end' centre -250 half Times 8 0 'sel_end:3'
endif

if (draw_spectrogram || draw_formants) and formant_legend != 1
Axes... 'w_start' 'w_end' 'spectro_floor' 'spectro_ceiling'
if formant_legend = 2 or formant_legend = 4
One mark left... 'spectro_floor' yes no no
One mark left... 'spectro_ceiling' yes no no
Axes... 0.58 5.41 2.11 0.38
Text special... 0.08 left 0.25 half Times 8 0 Spectrum (Hz)
Axes... 'w_start' 'w_end' 'spectro_floor' 'spectro_ceiling'
endif
if formant_legend = 3 or formant_legend = 4
Marks left every... 1 1000 no no yes
Axes... 0.58 5.41 'spectro_floor' 'spectro_ceiling'
Magenta
Text special... 0.60 left 1000 bottom Times 8 0 1kHz
Text special... 0.60 left 2000 bottom Times 8 0 2kHz
Text special... 0.60 left 3000 bottom Times 8 0 3kHz
Text special... 0.60 left 4000 bottom Times 8 0 4kHz
Black
Axes... 'w_start' 'w_end' 'spectro_floor' 'spectro_ceiling'
endif
endif

if draw_pitch and pitch_legend != 1
Axes... 'w_start' 'w_end' 'pitch_floor' 'pitch_ceiling'
if pitch_legend = 2 or pitch_legend = 3
One mark left... 'pitch_floor' yes no no 
One mark left... 'pitch_ceiling' yes no no 
Axes... 0.58 5.41 2.11 0.38
Text special... 0.05 left 0.25 half Times 8 0 Pitch (Hz)
Axes... 'w_start' 'w_end' 'pitch_floor' 'pitch_ceiling'
if pitch_legend = 3
Marks left every... 1 50 no no yes
endif
elsif pitch_legend = 4
One mark right... 'pitch_floor' yes no no 
One mark right... 'pitch_ceiling' yes no no 
Axes... 0.58 5.41 2.11 0.38
Text special... 5.97 right 0.25 half Times 8 0 Pitch (Hz)
Axes... 'w_start' 'w_end' 'pitch_floor' 'pitch_ceiling'
endif
endif

if draw_intensity and intensity_legend != 1
Axes... 'w_start' 'w_end' 'intensity_floor' 'intensity_ceiling'
if intensity_legend = 2 or intensity_legend = 3
One mark left... 'intensity_floor' yes no no 
One mark left... 'intensity_ceiling' yes no no 
Axes... 0.58 5.41 2.11 0.38
Text special... 0.09 left 0.25 half Times 8 0 Intensity (dB)
Axes... 'w_start' 'w_end' 'intensity_floor' 'intensity_ceiling'
if intensity_legend = 3
Marks left every... 1 10 no no yes
endif
elsif intensity_legend = 4
One mark right... 'intensity_floor' yes no no 
One mark right... 'intensity_ceiling' yes no no 
Axes... 0.58 5.41 2.11 0.38
Text special... 5.97 right 0.25 half Times 8 0 Intensity (dB)
Axes... 'w_start' 'w_end' 'intensity_floor' 'intensity_ceiling'
endif
endif

