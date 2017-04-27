
;+
;
; NAME: 
; 		my_multiplotps
;
; INPUTS:
; 		nx: number of plots x direction
; 		ny: number of plots y direction
; 		leftm: left margin fractional
; 		rightm: right margin fractional
; 		topm: top margin fractional
; 		botm: bottom margin fractional
; 		xgap, ygap: gap inbetween plots
; 		szinch: size of plot in inches
; 		aspectxy: aspect ratio
;
;  OUTPUTS:
;  		xszinch, yszinch: xy dimensions
;  		posarr = position of plot 
;
;
;
;-

pro my_multiplotpos,$
	nx=nx,$
	ny=ny,$
	leftm=leftm,$
	rightm=rightm,$
	topm=topm,$
	botm=botm,$
	xspc=xspc,$
	yspc=yspc,$
	xgap=xgap,$
	ygap=ygap,$
	szinch=szinch,$
	aspectxy=aspectxy,$
	xszinch=xszinch,$
	yszinch=yszinch,$
	posarr=posarr

	; aspectxy is ratio of xsize to ysize, if not set defaults to square
	if keyword_set(aspectxy) eq 0 then aspectxy=1.

	; calculate xspc and yspc
	xspc = (1.0-leftm-rightm)/(nx + (nx-1.)*xgap)
	yspc = (1.0-botm-topm)/(ny + (ny-1.)*ygap)

	; make array to hold output
	posarr = dblarr(nx,ny,4)

	; loop to fill it in
	for i=0,nx-1 do BEGIN
		for j=0,ny-1 do BEGIN

			x0 = leftm + xspc*i + xgap*xspc*i
			x1 = leftm + xspc*(i+1.) + xgap*xspc*i

;			y0 = botm + yspc*j + ygap*yspc*j
;			y1 = botm + yspc*(j+1.) + ygap*yspc*j

			y1 = 1. - topm - yspc*j - ygap*yspc*j
			y0 = 1. - topm - yspc*(j+1.) - ygap*yspc*j

			posarr[i,j,*] = [x0,y0,x1,y1]
		endfor
	endfor

	xszinch = szinch
	yszinch = (xszinch/aspectxy)*xspc/yspc

end
