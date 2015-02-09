;+
;
; NAME: 
;		kms_extract_gaussian_cube
;
; PURPOSE:
; 		This program extracts a spectrum from a cube using a 
; 		Gaussian beam.  
;
; INPUTS:
; 		cubefile - the filename of the cube from which to extract
; 			the spectrum
;		ra/dec - the position to extract the spectrum from the cube
;		fwhm - the fwhm of the desired beam in arcsec
;			*note the program does not check that this makes sense!
;		
; OPTIONAL INPUTS:
;		none
;		
; OUTPUTS:
;		outspec/outvel - the extracted spectrum & velocity axis
;		code - a flag that is set to -1 if the Gaussian 99% boundary
;			extends outside the coverage of the cube
;
; KEYWORDS:
; 		none
;
; OPTIONAL OUTPUTS:
; 		none
;
; DEPENDENCIES:
; 		- IDLAstro astrometry packages
;
; EXAMPLE:
;		
;		This example shows the process for extracting a spectrum
;		in a 30" beam from the HERACLES cube of NGC 3351.  The
;		HERACLES resolution is 13" so to calculate the needed psf
;		you do sqrt(30^2 - 13^2).
;
;		kms_extract_gaussian_cube,$
;			datadir='/Users/karin/Data/co/HERACLES/cubes/',$
;			cubefile='ngc3351_heracles_beta.hans.fits',$
;			ra=160.989831,dec=11.70356231,$
;			fwhm=sqrt(30.^2-13.^2.),$
;			code=c3351,outspec=sp3351,outvel=v3351
;
;
; MODIFICATION HISTORY:
;		Written a long time ago by Karin
;		Spiffed up and commented by Karin Feb 9, 2015
;
; To do:
; 	- I'm not totally sure the normalizing is correct.
; 	- needs better error catching
;-

pro kms_extract_gaussian_cube,$
	datadir=datadir,$
	cubefile=cubefile,$
	ra=ra,$
	dec=dec,$
	fwhm=fwhm,$ ; in arcsec
	code=code,$
	outspec=outspec,$
	outvel=outvel

	; read in the cube
	if keyword_set(datadir) then BEGIN
		cube = readfits(datadir+cubefile,cubehdr)
	endif else BEGIN
		cube = readfits(cubefile,cubehdr)
	endelse

	; get units of velocity/wavelength/frequency axis
	naxis3 = sxpar(cubehdr,'NAXIS3')
	crval3 = sxpar(cubehdr,'CRVAL3')/1d3
	cdelt3 = sxpar(cubehdr,'CDELT3')/1d3

	; generate a vector that has the velocity axis
	outvel = findgen(naxis3)*cdelt3 + crval3

	; find center of extraction region 
	; 	this converts an RA and Dec into pixel coordinates
	; 	using the cube header
	adxy,cubehdr,ra,dec,xcen,ycen

	; find FWHM of Gaussian in pixels
	; 	first get the pixel scale from getrot
	; 	then figure out the sigma of the Gaussian in pixels
	getrot,cubehdr,rot,cdelt
	cdelt = abs(cdelt[1])*3600. ; pixel size in arcsec
	res = fwhm/cdelt ; fwhm in pixels
	sig = res/sqrt(2.*alog(2.)) ; fwhm -> sigma for gaussian

	; determine if Gaussian fits inside cube boundaries
	range = sig*2.6d ; gets 99% of Gaussian weight
	xpbound = xcen + range
	ypbound = ycen + range
	xmbound = xcen - range
	ymbound = ycen - range

	naxis1 = sxpar(cubehdr,'NAXIS1')
	naxis2 = sxpar(cubehdr,'NAXIS2')
	naxis3 = sxpar(cubehdr,'NAXIS3')

	; set error code if gaussian extends beyond cube extent
	if xpbound gt naxis1-1 or ypbound gt naxis2-1 or xmbound lt 0 or $
		ymbound lt 0 then BEGIN
		code = -1
	endif else BEGIN
		code =1 
	endelse

	; make psf and get average spectrum and uncertainties
	xarr = rebin(dindgen(naxis1),naxis1,naxis2)
	yarr = rebin(reform(dindgen(naxis2),1,naxis2),naxis1,naxis2)

	; check to see if any NANs from edges of cubes
	dist = sqrt((xarr-xcen)^2. + (yarr-ycen)^2.)
	tot = total(cube,3)
	chunk = tot[where(dist lt range)]
	chunkok = where(finite(chunk) eq 0,ct)
	if ct ne 0 then code=-1

	; create gaussian weighting function
	; 	this makes an image the same x-y dimensions as the cube
	; 	with the center of the Gaussian at the requested RA/Dec
	; 	and a sigma calculated earlier
	a1 = 1./(sig*sqrt(2.*!dpi))
	xp = xarr-xcen
	yp = yarr-ycen
	u = (xp/sig)^2. + (yp/sig)^2.
	psf =  a1*exp(-u/2.d)

	; normalize the psf image to have a integral of 1
	psf = psf/total(psf)

	; rebin to three dimensions to match cube
	; 	this makes a "psf cube" where every slice is the same
	; 	Gaussian
	psfcube = rebin(psf,naxis1,naxis2,naxis3)
	
	; do the extraction of the spectrum weighted by the Gaussian
	; 	mutiply the cube by the psf cube and then total in the x-y directions
	; 	till you have a vector that is the length of the 3rd dimension
	; 	divide by the same thing but only for the psf cube -
	; 	this is just a weighted average
	outspec = total(total(psfcube*cube,2,/nan),1,/nan)/total(total(psfcube,2,/nan),1,/nan)

end
