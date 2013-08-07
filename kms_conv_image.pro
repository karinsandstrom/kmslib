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
;-

pro kms_conv_image,$
	file=file,$
	kernel_file=kernel_file,$
	out_file=out_file

	on_error,0

	; check that file, kernel_file and out_file have all been set
	if keyword_set(file) eq 0 or keyword_set(kernel_file) eq 0 or $
		keyword_set(out_file) eq 0 then $
			message,'Must set file, kernel_file and out_file!'
	
	; check that the input files actually point to files
	if file_test(file) eq 0 then message,'Input file not found!'
	if file_test(kernel_file) eq 0 then message,'Kernel file not found!'

	; read in the files
	fits_read,file,im,hdr
	fits_read,kernel_file,kernel,kerhdr

	stop
end

