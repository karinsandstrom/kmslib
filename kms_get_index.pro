;+
; NAME: 
; 	kms_get_index
;
; PURPOSE: 
;   Returns the path to the most recent index file for
;   a given datatype.
;
; INPUTS:
;
; OPTIONAL INPUTS:
;
; KEYWORDS:
; 	
; OUTPUTS:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; 	Written by Karin (30 June 2014)
; 	Attempting to be responsible & version control with GIT
;-

function kms_get_index,$
	type=type

	dir = '/Users/karin/Data/index'

	if type eq 'co' then list = file_search(dir,'index_co*')
	if type eq 'hi' then list = file_search(dir,'index_hi*')
	if type eq 'dust' then list = file_search(dir,'index_dust*')

	if n_elements(list) gt 1 then BEGIN

		bits = strsplit(list,'_-',/extract)
	
		date = dblarr(n_elements(list))
		for i=0,n_elements(list)-1 do BEGIN
			yr = bits[i,2]
			mn = bits[i,3]
			dy = bits[i,4]
			thisdate = julday(mn,dy,yr,0,0,0)
			date[i] = thisdate
		endfor

		junk = max(date,ind)
	
		file = list[ind]
	endif else BEGIN
		file = list
	endelse
	
	return,file

end
