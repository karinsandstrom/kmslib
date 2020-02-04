pro kms_read_all_draine

; program to read in all Draine models and store
; in structure

  draine_path = '/Users/karin/Projects/dlmodels/'
  filelist = 'dlfiles'

  readcol,draine_path+filelist,files,format='A'
  nfiles=n_elements(files)

  ; read in one file to set up structure
  readcol,files[0],skipline=2,grain_mod,format='I',numline=1
  readcol,files[0],skipline=3,a01,sig1,bc1,format='D,D,D',numline=1
  readcol,files[0],skipline=4,a02,sig2,bc2,format='D,D,D',numline=1
  readcol,files[0],skipline=5,umin,umax,beta,format='D,D,D',numline=1
  readcol,files[0],skipline=6,ubar,format='D',numline=1
  readcol,files[0],skipline=7,amin,amax,format='D,D',numline=1
  readcol,files[0],skipline=8,ptot,pcarb,psil,format='D,D,D',numline=1
  readcol,files[0],skipline=11,bandwl,nuPnu,jnutot,jnucarb,jnusil,bandname,$
    format='D,D,D,D,D,A',numline=56
  readcol,files[0],skipline=71,lam,nudpdnu,jnuspec,jnucarbspec,jnusilspec,$
    format='D,D,D,D,D'

  ; create structure to hold the results
  dlstructphot = {FILE:files[0],$
    GRAIN_MOD:0,$
    A_01_CM:0d,SIGMA_1:0d,B_C1:0d,$
    A_02_CM:0d,SIGMA_2:0d,B_C2:0d,$
    UMIN:0d,UMAX:0d,BETA:0d,UBAR:0d,$
    AMIN_CM:0d,AMAX_CM:0d,$
    PTOT:0d,PCARBTOT:0d,PSILTOT:0d,$
    BANDWL:bandwl,$
    NUPNU:nuPnu,$
    JNUTOT:jnutot,$
    JNUCARB:jnucarb,$
    JNUSIL:jnusil,$
    BANDNAME:bandname}

  dlstructspec = {FILE:files[0],$
    GRAIN_MOD:0,$
    A_01_CM:0d,SIGMA_1:0d,B_C1:0d,$
    A_02_CM:0d,SIGMA_2:0d,B_C2:0d,$
    UMIN:0d,UMAX:0d,BETA:0d,UBAR:0d,$
    AMIN_CM:0d,AMAX_CM:0d,$
    PTOT:0d,PCARBTOT:0d,PSILTOT:0d,$
    LAM:lam,$
    NUDPDNU:nudpdnu,$
    JNUSPEC:jnuspec,$
    JNUCARBSPEC:jnucarbspec,$
    JNUSILSPEC:jnusilspec}

  dlphot = replicate(dlstructphot,nfiles)
  dlspec = replicate(dlstructspec,nfiles)

  for i=0,nfiles-1 do BEGIN

    print,files[i]

    readcol,files[i],skipline=2,grain_mod,format='I',numline=1
    readcol,files[i],skipline=3,a01,sig1,bc1,format='D,D,D',numline=1
    readcol,files[i],skipline=4,a02,sig2,bc2,format='D,D,D',numline=1
    readcol,files[i],skipline=5,umin,umax,beta,format='D,D,D',numline=1
    readcol,files[i],skipline=6,ubar,format='D',numline=1
    readcol,files[i],skipline=7,amin,amax,format='D,D',numline=1
    readcol,files[i],skipline=8,ptot,pcarb,psil,format='D,D,D',numline=1
    readcol,files[i],skipline=11,bandwl,nuPnu,jnutot,jnucarb,jnusil,bandname,$
      format='D,D,D,D,D,A',numline=56
    readcol,files[i],skipline=71,lam,nudpdnu,jnuspec,jnucarbspec,jnusilspec,$
      format='D,D,D,D,D'

    dlphot[i].GRAIN_MOD = grain_mod
    dlphot[i].A_01_CM = a01
    dlphot[i].SIGMA_1 = sig1
    dlphot[i].B_C1 = bc1
    dlphot[i].A_02_CM = a02
    dlphot[i].SIGMA_2 = sig2
    dlphot[i].B_C2 = bc2
    dlphot[i].UMIN = umin
    dlphot[i].UMAX = umax
    dlphot[i].BETA = beta
    dlphot[i].UBAR = ubar
    dlphot[i].AMIN_CM = amin
    dlphot[i].AMAX_CM = amax
    dlphot[i].PTOT = ptot
    dlphot[i].PCARBTOT = pcarb
    dlphot[i].PSILTOT = psil
    dlphot[i].BANDWL = bandwl
    dlphot[i].NUPNU = nuPnu
    dlphot[i].JNUTOT = jnutot
    dlphot[i].JNUCARB = jnucarb
    dlphot[i].JNUSIL = jnusil
    dlphot[i].BANDNAME = bandname

    dlspec[i].GRAIN_MOD = grain_mod
    dlspec[i].A_01_CM = a01
    dlspec[i].SIGMA_1 = sig1
    dlspec[i].B_C1 = bc1
    dlspec[i].A_02_CM = a02
    dlspec[i].SIGMA_2 = sig2
    dlspec[i].B_C2 = bc2
    dlspec[i].UMIN = umin
    dlspec[i].UMAX = umax
    dlspec[i].BETA = beta
    dlspec[i].UBAR = ubar
    dlspec[i].AMIN_CM = amin
    dlspec[i].AMAX_CM = amax
    dlspec[i].PTOT = ptot
    dlspec[i].PCARBTOT = pcarb
    dlspec[i].PSILTOT = psil
    dlspec[i].LAM = lam
    dlspec[i].NUDPDNU = nudpdnu
    dlspec[i].JNUSPEC = jnuspec
    dlspec[i].JNUCARBSPEC = jnucarbspec
    dlspec[i].JNUSILSPEC = jnusilspec

  endfor

  save,file='dlphot.sav',dlphot
  save,file='dlspec.sav',dlspec

  stop

end
