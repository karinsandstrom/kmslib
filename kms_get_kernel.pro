function kms_get_kernel,startpsf,endpsf

	datadir='/Users/karin/Data'
	ker_index = kms_get_index(type='kernel')
	readcol,ker_index,startlist,endlist,filename,format='A,A,A'

	ok = where(startlist eq startpsf and endlist eq endpsf,ct)
	if ct gt 1 then stop
	if ct eq 0 then return,-1

	return,datadir+filename[ok]

end
