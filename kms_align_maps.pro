
;+
; NAME: 
; 	kms_align_maps
;
; PURPOSE: 
; 	This program takes as input a reference fits file and another fits
; 	files and aligns the file to the reference file using hastrom, it then writes
; 	new fits files with the aligned map
;
; INPUTS:
; 	reffile: fits file to align to
; 	infile: fits file to align
; 	outfile: name of output file
;
; KEYWORDS:
;	cube: if set each slice of the cube is aligned
;
; OUTPUTS:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; 	Pillaged from existing code by Karin (16 Aug 2013)
; 	Attempting to be responsible & version control with GIT
;
; To Do:
; 	- error checking
; 	- error check cubes!
; 	- potential keywords
;	- uncertainty option?
;	- list of files
;
;-

pro kms_align_maps,$
	reffile=reffile,$
	infile=infile,$
	outfile=outfile,$
	cube=cube

	refmap = readfits(reffile,refhdr)
	
	map = readfits(infile,hdr)

	if keyword_set(cube) then BEGIN
		refsize = size(refmap,/dimen)
		cubesize = size(map,/dimen)
		newmap = dblarr(refsize[0],refsize[1],cubesize[2])

		; create a 2d hdr for hastrom
		refhdr2d = hdr3to2(refhdr)
		hdr2d = hdr3to2(hdr)

		for i=0,cubesize[2]-1 do BEGIN
			hastrom,map[*,*,i],hdr2d,newslice,newhdr,refhdr2d,$
				missing=sqrt(-1d),interp=2,ngrid=10,degree=2

			newmap[*,*,i] = newslice
		endfor

		sxaddpar,newhdr,'NAXIS3',cubesize[2]
		sxaddpar,newhdr,'NAXIS',3

	endif else BEGIN
		hastrom,map,hdr,newmap,newhdr,refhdr,missing=sqrt(-1.),interp=2,ngrid=10,degree=2
	endelse

	writefits,outfile,newmap,newhdr
	
END
