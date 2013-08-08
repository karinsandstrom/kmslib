;+
; NAME: 
; 	kms_conv_image
;
; PURPOSE: 
; 	Convolves an image or a cube with a kernel, keeps track of 
; 	important details in headers.
;
; INPUTS:
; 	file: fits file containing image or cube to convolve
; 	kernel_file: fits file containing kernel
; 	out_file: name for output fits image or cube
;
; KEYWORDS:
; 	
; OUTPUTS:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; 	Written by Karin (7 Aug 2013)
; 	Attempting to be responsible & version control with GIT
;
;
; To Do:
; 	- needs error checking on unc image convolution
; 	- figure out what is up with /no_pad in convolve
; 	- better NaN replacement, nearest neighbor?
; 	- possibility to rebin image instead of kernel? 
; 		maybe important if image is undersampled
;-

pro kms_conv_image,$
	file=file,$
	unc_file=unc_file,$
	kernel_file=kernel_file,$
	out_file=out_file,$
	outunc_file=outunc_file,$
	silent=silent

	on_error,0

	; check that file, kernel_file and out_file have all been set
	if keyword_set(file) eq 0 or keyword_set(kernel_file) eq 0 or $
		keyword_set(out_file) eq 0 then $
			message,'Must set file, kernel_file and out_file!'

	; check that if unc_file is set that outunc_file is also set
	if keyword_set(unc_file) and (keyword_set(outunc_file) eq 0) then $
		message,'Need to name output uncertainty file.'
	
	; check that the input files actually point to files
	if file_test(file) eq 0 then message,'Input file not found!'
	if file_test(kernel_file) eq 0 then message,'Kernel file not found!'
	if keyword_set(unc_file) then BEGIN
		if file_test(unc_file) eq 0 then $
			message,'Uncertainty file not found!'
	endif

	; read in the files
	fits_read,file,im,hdr
	fits_read,kernel_file,kernel,kerhdr
	if keyword_set(unc_file) then fits_read,unc_file,uncim,unchdr

	; figure out dimensions of the images
	imsize = size(im,/dimen)
	kersize = size(kernel,/dimen)

	; get astrometry info
	extast,hdr,ast_info
	
	if (n_elements(ast_info) eq 0) then message,'No astrometry in image!'

	getrot,hdr,angle,cdelt
	orig_cdelt = cdelt

	; here in karl's program there is derotation
	; for now I am going to ignore this
	
	; check if cdelts are equal, if not need more code
	if (abs(cdelt[0]) NE abs(cdelt[1])) then $
		message,'Need to match cdelts in image, code more!'

	; calculate image pixel scale
	image_scale = abs(cdelt)*3600.0

	if (n_elements(silent) EQ 0) then $
		print,'Image scale [arcsec] = ', image_scale

	; normalize the kernel
	kernel = kernel/total(kernel)
	
	; get the kernel pixel scale
	ker_scale = fxpar(kerhdr,'PIXSCALE',count=count)
	if count eq 0 then ker_scale = fxpar(kerhdr,'SECPIX',count=count)
	if count eq 0 then ker_scale = abs(fxpar(kerhdr,'CD1_1',count=count)*3600.0)
	if count eq 0 then ker_scale = abs(fxpar(kerhdr,'CDELT1',count=count)*3600.0)
	if count eq 0 then message,'No pixel scale found in kernel image.'

	if keyword_set(silent) eq 0 then $
		print,'Kernel scale [arcsec] = ',ker_scale

	; copy header to output hdr
	outhdr = hdr
	if keyword_set(unc_file) then outunchdr = unchdr

	; match pixel scales between image and kernel
	new_kernel = matchpixscale(kernel,ker_scale[0],image_scale[0])

	; make sure new kernel is centered
	ensure_psf_centered,new_kernel

	; make sure new kernel is normalized
	new_kernel = new_kernel/total(new_kernel)

	; locate NaNs and fill in 
	outim = im
	naninds = where(finite(outim) eq 0,nanct,complement=okinds)
	if nanct gt 0 then outim[naninds] = 0d
	
	if keyword_set(unc_file) then begin
		outuncim = uncim
		unaninds = where(finite(outuncim) eq 0,unanct,complement=uokinds)
		if unanct gt 0 then outuncim[unaninds] = 0d
	endif

	; do the convolution
	if n_elements(imsize) gt 2 then BEGIN

		for i=0,imsize[2]-1 do BEGIN
			slice = outim[*,*,i]
			outslice = convolve(slice,new_kernel,/no_pad)
			outim[*,*,i] = outslice

			if keyword_set(unc_file) then BEGIN
				uslice = (outuncim[*,*,i])^2.
				outuslice = convolve(uslice,new_kernel,/no_pad)
				outuncim[*,*,i] = sqrt(outuslice)
			endif
		endfor
	
	endif else BEGIN
		
		outim = convolve(outim,new_kernel,/no_pad)
		outuncim = sqrt(convolve(outuncim^2.,new_kernel,/no_pad))
	
	endelse

	; put the NaNs back in
	if nanct gt 0 then outim[naninds] = !values.f_nan
	if keyword_set(unc_file) then BEGIN
		if unanct gt 0 then outuncim[unaninds] = !values.f_nan
	endif

	; add comment to hdr
	sxaddpar,outhdr,'COMMENT','Convolved with kms_conv_image.'
	sxaddpar,outunchdr,'COMMENT','Convolved with kms_conv_image.'

	; write output file
	writefits,out_file,outim,outhdr
	if keyword_set(unc_file) then BEGIN
		writefits,outunc_file,outuncim,outunchdr
	endif

end

