# Draw harmonics & envelope
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


# This script draws a spectral slice at cursor (or at midpoint if a portion is selected).
# Harmonics and envelope can be drawn. Additionally, some relevant harmonics can be highlighted with an arrow.

# This is an Editor script.

include utils.praat

form Draw harmonics & envelope...
choice sex 1
button male
button female
boolean erase_first no
boolean draw_harmonics yes
boolean draw_envelope yes
boolean display_f0 no
boolean mark_h1 no
boolean mark_h2 no
boolean mark_h4 no
boolean mark_h2k no
boolean mark_a1 no
boolean mark_a2 no
boolean mark_a3 no
comment It is not necessary to indicate the segment identity (eg. i) and whether or not it is next to a nasal,
comment but it may help to calculate formant values in some problematic cases.
word segment_id 
optionmenu nasal_context 1
option no
option yes
endform

if nasal_context = 1
nasalctxt$ = "no"
else
nasalctxt$ = "yes"
endif

@parsex: 'sex', 1

ini = Get start of selection
end = Get end of selection
t = (ini+end)/2

@getinfo: 0
endeditor
@getws
editor 'data_type$' 'data_name$'
@getinfo: 1

##{ Create object for harmonics (spectral slice)
spectrogram_from = extractNumber (editorinfo$, "Spectrogram view from: ")
spectrogram_to = extractNumber (editorinfo$, "Spectrogram view to: ")
spectrogram_window = extractNumber (editorinfo$, "Spectrogram window length: ")
dynamic_range = extractNumber (editorinfo$, "Spectrogram dynamic range: ")
Spectrogram settings... 0 5000 0.030 35
slice_harmonics = View spectral slice
Spectrogram settings... 'spectrogram_from' 'spectrogram_to' 'spectrogram_window' 'dynamic_range'
##}

endeditor

##{ Create object for envelope (lpc)
if draw_envelope = 1
select 'slice_harmonics'
lpc = noprogress LPC smoothing... 30 120
endif
##}


if display_f0 | mark_h1 | mark_h2 | mark_h4 | mark_h2k | mark_a1 | mark_a2 | mark_a3

##{ Create pitch-related objects for further calculations
@selobj: 1, 0
pitch = noprogress To Pitch... 0 'pitch_floor' 'pitch_ceiling'
f0 = Get value at time... t Hertz Linear
@selobj: 1, 0
pulses = noprogress To PointProcess (periodic, cc)... 'pitch_floor' 'pitch_ceiling'
##}

##{ Get formant values and bandwidths
@selobj: 1, 0
@toaltfn
select fn
f1 = Get value at time... 1 t hertz Linear
f2 = Get value at time... 2 t hertz Linear
f3 = Get value at time... 3 t hertz Linear
if segment_id$ = "" and nasalctxt$ = "no"
b1 = Get bandwidth at time... 1 t hertz Linear
b2 = Get bandwidth at time... 2 t hertz Linear
b3 = Get bandwidth at time... 3 t hertz Linear
else
@resetfnflags
@fn_check: 'f1', 1, 't', segment_id$, nasalctxt$, ""
f1 = fn_check.resultfn
b1 = fn_check.resultbn
@fn_check: 'f2', 2, 't', segment_id$, nasalctxt$, ""
f2 = fn_check.resultfn
b2 = fn_check.resultbn
@fn_check: 'f3', 3, 't', segment_id$, nasalctxt$, "'f2'"
f3 = fn_check.resultfn
b3 = fn_check.resultbn
@resetfnflags
endif
##}

##{ Get amplitude and frequency of relevant harmonics
@selobj: 1, 0
fs = Get sampling frequency
@spectral_analysis: t, f0, f1, b1, f2, b2, f3, b3
h1 = spectral_analysis.h1
h2 = spectral_analysis.h2
h4 = spectral_analysis.h4
h2k = spectral_analysis.h2k
fh1 = spectral_analysis.fh1
fh2 = spectral_analysis.fh2
fh4 = spectral_analysis.fh4
fh2k = spectral_analysis.fh2k
a1 = spectral_analysis.a1
a2 = spectral_analysis.a2
a3 = spectral_analysis.a3
ff1 = spectral_analysis.ff1
ff2 = spectral_analysis.ff2
ff3 = spectral_analysis.ff3
##}

##{ Clean workspace (so far)
select pitch
plus pulses
plus fn
plus altfn
Remove
##}

endif

##{ Draw figure

if erase_first = 1
Erase all
endif

Font size... 14

##{ Draw harmonics and envelope
Line width... 2

if draw_harmonics = 1
Black
# Blue
select slice_harmonics
Draw... 0 5000 0 80 no
endif
if draw_envelope = 1
Black
# Red
select lpc
Draw... 0 5000 0 80 no
endif

Line width... 1
##}

##{ Draw axes and titles
Line width... 1
Black
Draw inner box
Text left... yes Intensidad (dB)
Text bottom... yes Frecuencia (kHz)
# Text left... yes Intensity (dB)
# Text bottom... yes Frequency (kHz)
Marks left every... 1 20 yes yes no
One mark bottom... 0 no yes no 0
One mark bottom... 1000 no yes no 1
One mark bottom... 2000 no yes no 2
One mark bottom... 3000 no yes no 3
One mark bottom... 4000 no yes no 4
One mark bottom... 5000 no yes no 5
##}

##{ Mark f0 with line
if display_f0
One mark bottom... 'fh1:0' no no yes 
f0$ = "f_0 = 'fh1:0' Hz"
xcoord = 'fh1' + 20
Text special... 'xcoord' right 78 top Times 10 90 'f0$'
endif
##}

##{ Mark harmonics with arrows
Arrow size... 0.6

if mark_h1
Draw arrow... 'fh1' 'h1'+1 'fh1' 'h1'-4
if mark_a1 = 1 & fh1 = ff1
Text... 'fh1'-150 Left 'h1'+3 Half H1=A1
else
Text... 'fh1' Centre 'h1'+3 Half H1
endif
endif

if mark_h2
Draw arrow... 'fh2' 'h2'+1 'fh2' 'h2'-4
if mark_a1 = 1 & fh2 = ff1
Text... 'fh2'-150 Left 'h2'+3 Half H2=A1
else
Text... 'fh2' Centre 'h2'+3 Half H2
endif
endif

if mark_h4
Draw arrow... 'fh4' 'h4'+1 'fh4' 'h4'-4
if mark_a1 = 1 & fh4 = ff1
Text... 'fh4'-150 Left 'h4'+3 Half H4=A1
elsif mark_a2 = 1 & fh4 = ff2
Text... 'fh4'-150 Left 'h4'+3 Half H4=A2
else
Text... 'fh4' Centre 'h4'+3 Half H4
endif
endif

if mark_h2k
Draw arrow... 'fh2k' 'h2k'+1 'fh2k' 'h2k'-4
if mark_a2 = 1 & fh2k = ff2
Text... 'fh2k'-150 Left 'h2k'+3 Half H2K=A2
elsif mark_a3 = 1 & fh2k = ff3
Text... 'fh2k'-150 Left 'h2k'+3 Half H2K=A3
else
Text... 'fh2k' Centre 'h2k'+3 Half H2K
endif
endif

if mark_a1 = 1
if (mark_h1 != 1 | fh1 != ff1) & (mark_h2 != 1 | fh2 != ff1) & (mark_h4 != 1 | fh4 != ff1)
Draw arrow... 'ff1' 'a1'+1 'ff1' 'a1'-4
Text... 'ff1' Centre 'a1'+3 Half A1
endif
endif

if mark_a2 = 1
if (mark_h4 != 1 | fh4 != ff2) & (mark_h2k != 1 | fh2k != ff2)
Draw arrow... 'ff2' 'a2'+1 'ff2' 'a2'-4
Text... 'ff2' Centre 'a2'+3 Half A2
endif
endif

if mark_a3 = 1
if (mark_h2k != 1 | fh2k != ff3)
Draw arrow... 'ff3' 'a3'+1 'ff3' 'a3'-4
Text... 'ff3' Centre 'a3'+3 Half A3
endif
endif

##}

##}

##{ Clean and restore workspace
select socopy
plus slice_harmonics
nocheck plus lpc
Remove

@restorews
##}
