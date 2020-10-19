! author  : zjwang, sypeng
! date    : modefied by sypeng @ 10/16/2020
! aim     : draw band structure for vasp 
! version : v0.0.1
program main
     implicit none

! constant parameters
     integer,  parameter :: dp = kind(1.0d0)
     integer,  parameter :: mytmp = 1000,myout=547,mylen=548,mygnu=666, mydat=411
     real(dp), parameter :: pi=3.141592653589793d0 

     character(len=20)   :: fst
     character(len=20)   :: string
     character(len=5)    :: tmps
! loop index over row and column
     integer :: i
     integer :: j

     integer :: irow
     integer :: jcol

     integer :: nrow
     integer :: ncol

     integer  :: itmp
     integer  :: ityp
     integer  :: kmesh,ISPIN
     real(dp) :: kval, Efermi,a,pa(3),pb(3),pc(3),pra(3),prb(3),prc(3)
     real(dp) :: tmp1, tmp2, tmp3, tmp4
     real(dp) :: ktmp1, ktmp2, ktmp3, ktmp4
     real(dp) :: volumn,t

     real(dp), allocatable :: kdata(:)

     real(dp), allocatable :: k_len(:)
     real(dp), allocatable :: d_len(:)

     real(dp), allocatable :: fdata(:,:, :)

     Efermi=0.0d0
     open( mytmp, file="EFERMI", status="old" )
         read(mytmp, *) Efermi 
         read(mytmp, *) ISPIN
     close(mytmp)

     open( mylen, file="CONTCAR",status="old")
     read(mylen,*); read(mylen,*)   
     read(mylen,*)  pa 
     read(mylen,*)  pb 
     read(mylen,*)  pc 
     pa=  pa; pb=  pb; pc=  pc
     write(*,*) ' Primitive Cell '
     write(*,'(A8,3(F15.8,2X))') 'pa_xyz=',pa
     write(*,'(A8,3(F15.8,2X))') 'pb_xyz=',pb
     write(*,'(A8,3(F15.8,2X))') 'pc_xyz=',pc

     volumn =  pa(1)*(pb(2)*pc(3)-pb(3)*pc(2)) &
             + pa(2)*(pb(3)*pc(1)-pb(1)*pc(3)) &
             + pa(3)*(pb(1)*pc(2)-pb(2)*pc(1))

     t=2.0d0*pi/volumn
     
     pra(1)=t*(pb(2)*pc(3)-pb(3)*pc(2))
     pra(2)=t*(pb(3)*pc(1)-pb(1)*pc(3))
     pra(3)=t*(pb(1)*pc(2)-pb(2)*pc(1))
     
     prb(1)=t*(pc(2)*pa(3)-pc(3)*pa(2))
     prb(2)=t*(pc(3)*pa(1)-pc(1)*pa(3))
     prb(3)=t*(pc(1)*pa(2)-pc(2)*pa(1))
     
     prc(1)=t*(pa(2)*pb(3)-pa(3)*pb(2))
     prc(2)=t*(pa(3)*pb(1)-pa(1)*pb(3))
     prc(3)=t*(pa(1)*pb(2)-pa(2)*pb(1))
 
 ! Cartesian Coordinate System for Primitive Riciprocal Cell 
     write(*,*) ' Primitive Riciprocal Cell '
     write(*,'(A9,3(F15.8,2X))') 'pra_xyz=',pra
     write(*,'(A9,3(F15.8,2X))') 'prb_xyz=',prb
     write(*,'(A9,3(F15.8,2X))') 'prc_xyz=',prc
     close(mylen)



     open( mytmp, file="EIGENVAL", status="old" )
     open( myout, file='vasp_band.xmgr')


  !  open( mygnu, file='vasp_band.gnu')
  !  write(mygnu,*)"set key left Left"
  !  write(mygnu,*)"set ylabel 'E-Ef/(ev)'"
  !  write(mygnu,*)"set xlabel 'High symmetry Kpath'"
  !  write(mygnu,*)"set output 'vasp_band.png'"
  !  write(mygnu,*)'set style data dots'
  !  write(mygnu,*)'set xrange [0: 3.20783]'
  !  write(mygnu,*)'set yrange [ -5.43155 :  4.85734]'
  !  write(mygnu,*)''
  !  write(mygnu,*)''
  !  write(mygnu,*)''
  !  write(mygnu,*)''


     ! read "EIGENVAL" 
     do irow=1,5
         read(mytmp, *)
     enddo

     read(mytmp, *) itmp, ncol,nrow
     allocate( kdata(ncol) )
     allocate( k_len(ncol) )
     allocate( fdata(ISPIN,nrow, ncol) )

     kmesh = 0; kval = 0.0d0; kdata = 0.0d0; fdata = 0.0d0

     do jcol=1, ncol ! k-points
         read(mytmp, *)
         read(mytmp, *) tmp1, tmp2, tmp3, tmp4
         kval = kval + 0.1d0
         if (jcol .eq. 1) then
             kval=kval - 0.1d0
             kdata(jcol) = kval
         else if((abs(tmp1-ktmp1).lt. 0.5d-12).and.(abs(tmp2-ktmp2).lt.0.5d-12).and.(abs(tmp3-ktmp3).lt. 0.5d-12)) then
             kval=kval - 0.1d0
             kdata(jcol) = kval
         else if(jcol.eq. ncol) then
             kdata(jcol) = kval
         else 
             kdata(jcol) = kval
         endif 
         ktmp1=tmp1; ktmp2=tmp2; ktmp3=tmp3
         do irow=1,nrow ! band
             read(mytmp, *) tmps, fdata(:,irow, jcol)
         enddo
     enddo
     close(mytmp)

     open( mylen, file="KPOINTS" )
         read(mylen, *) 
         read(mylen, *) kmesh
         read(mylen, *) 
         read(mylen, *) 
         ityp=ncol/kmesh
         print*, 'Nk=',ityp

     open( mytmp, file="EFERMI",  access="append") 
         write(mytmp,"(I1,6X,A4)") ityp, ": NK"
     close(mytmp)

     allocate( d_len(0:ityp) )
     d_len=0.0d0
     do i=1,ityp
         read(mylen, *) pa 
         read(mylen, *) pb 
         pb=pb-pa 
         pc=pb(1)*pra+pb(2)*prb+pb(3)*prc
         d_len(i)=d_len(i-1)+dsqrt(pc(1)**2+pc(2)**2+pc(3)**2)
     enddo
     close(mylen)

     print*, 'k_len:',d_len(:)
     open( mytmp, file="k_len.dat" )
     write(mytmp,"(10F10.5)")  d_len
     close(mytmp)

     print*, 'kmesh=',kmesh

     open( mytmp, file="EIGENVAL", status="old" )
     do irow=1,5
         read(mytmp, *)
     enddo
     read(mytmp, *) 
     k_len=kdata
     do jcol=1,ncol
         if(ityp .ne. 0) then
             kval=k_len(jcol)-k_len((jcol-1)/kmesh*kmesh+1) ! calculate the distance between every k point and the first point of that interval 
                                                            ! notice : (jcol-1)/kmesh*kmesh != jcol-1
             kdata(jcol)=(d_len((jcol-1)/kmesh+1)-d_len((jcol-1)/kmesh))*kval/(k_len((jcol-1)/kmesh*kmesh+kmesh) &
	              -k_len((jcol-1)/kmesh*kmesh+1))+d_len((jcol-1)/kmesh)
         endif
     enddo

     do jcol=1,ncol
         read(mytmp, *)
         read(mytmp, *) tmp1, tmp2, tmp3, tmp4
         if (jcol .eq. 1) then
             write (myout,'(2f17.10)') kdata(1),-20.0
             write (myout,'(2f17.10)') kdata(1),20.0
         else if((abs(tmp1-ktmp1).lt. 0.5d-12).and.(abs(tmp2-ktmp2).lt.0.5d-12).and.(abs(tmp3-ktmp3).lt. 0.5d-12)) then
             write(myout, *) "&"
             write(myout, *) "&"
             write (myout,'(2f17.10)') kdata(jcol),-20.0
             write (myout,'(2f17.10)') kdata(jcol),20.0
         else if(jcol.eq. ncol) then
             write(myout, *) "&"
             write(myout, *) "&"
             write (myout,'(2f17.10)') kdata(jcol),-20.0
             write (myout,'(2f17.10)') kdata(jcol),20.0
         else 
         endif 
         ktmp1=tmp1
         ktmp2=tmp2
         ktmp3=tmp3
         do irow=1,nrow
             read(mytmp, *) tmps, fdata(:,irow, jcol)
         enddo
     enddo
     close(mytmp)


! export data
     open( mydat, file='vasp_band.dat')
     do irow=1,nrow
         write(myout, *) "&"
         do jcol=1,ncol
             write(myout, '(2f17.10)') kdata(jcol), fdata(1,irow, jcol)-Efermi
             write(mydat, '(2(f17.10,2x))') kdata(jcol), fdata(1,irow, jcol)-Efermi
         enddo
         write(mydat, *)' '
     enddo
     close(myout); close(mydat)




     open(myout, file='band.agr')
     write(myout, *) "#    k       ene"
     do irow=1,nrow
         write(myout, *) "@ autoscale onread none"
         write(fst,*) irow ; fst=adjustl(fst)
         string="@ target g0.s"//trim(fst)
         write(myout, *) string
         write(myout, *) "@ type xy"
         write(myout, *) 
         write(myout, "(A13,I3)")  "# bandindex:",irow
         do jcol=1,ncol
             write(myout, '(2f17.10)') kdata(jcol), fdata(1,irow, jcol)-Efermi
         enddo
         write(myout, *) "&"
     enddo
     close(myout)

    
     if( ISPIN == 2)  then
     open( myout, file='vasp_band_dn.xmgr')
     open( mydat, file='vasp_band_dn.dat')
     do irow=1,nrow
         write(myout, *) "&"
         do jcol=1,ncol
             write(myout, '(2f17.10)') kdata(jcol), fdata(2,irow, jcol)-Efermi
             write(mydat, '(2(f17.10,2x))') kdata(jcol), fdata(2,irow, jcol)-Efermi
         enddo
         write(mydat,*) ' '
     enddo
     close(myout); close(mydat)

                open(myout, file='band_dn.agr')
                !write(myout, *) "#    k       ene"
                do irow=1,nrow
                    write(myout, *) "@ autoscale onread none"
                     write(fst,*) irow+nrow ; fst=adjustl(fst)
                     string="@ target g0.s"//trim(fst)
                    write(myout, *) string
                    write(myout, *) "@ type xy"
                    write(myout, *) 
                    write(myout, "(A13,I3)")  "# bandindex:",irow
                    do jcol=1,ncol
                        write(myout, '(2f17.10)') kdata(jcol), fdata(2,irow, jcol)-Efermi
                    enddo
                    write(myout, *) "&"
                enddo
                close(myout)
     endif

     open(myout, file='ek_nxy.dat')
         do jcol=1,ncol
             write(myout, '(10000f17.10)') kdata(jcol), fdata(:,:, jcol)-Efermi
         enddo
     close(myout)
     
!    close(mygnu)

     stop
end program main
