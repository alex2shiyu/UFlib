!> Reads a vasp poscar from file
subroutine readfromfile(p,filename,verbosity)
    !> the crystal structure
    class(lo_crystalstructure), intent(out) :: p
    !> filename to be read
    character(len=*), intent(in) :: filename
    !> verbosity
    integer, intent(in), optional :: verbosity

    real(flyt), dimension(:,:), allocatable :: r, noncollmagmom, alloy_concentrations
    real(flyt), dimension(:), allocatable :: collmagmom
    real(flyt), dimension(3,3) :: m
    integer, dimension(:,:), allocatable :: alloy_components
    integer, dimension(:), allocatable :: atomic_number,alloy_componentcounter
    integer :: n_elem,verb
    character(len=1000), dimension(:), allocatable :: symbols
    character(len=1000) :: header
    logical, dimension(:), allocatable :: cmatom 
    logical :: seldyn,alloy,collmag,noncollmag

    if ( present(verbosity) ) then
        verb=verbosity
    else
        verb=0
    endif

    ! Since this is fortran, I have to dummy open the file and count some stuff first.
    ! the only thing this should do is get the number of different elements, and check 
    ! if selective dynamics are used.
    dummyopen: block
        integer, parameter :: max_n_elements=20000
        integer :: u,i,j,k
        character(len=10*max_n_elements) :: trams
        !
        u=open_file('in',trim(filename))
            read(u,*) trams
            read(u,*) trams
            read(u,*) trams
            read(u,*) trams
            read(u,*) trams
            read(u,*) trams
            read(u,'(A)') trams
            j=0
            i=0
            ! figure out how many specified elements there are, this is surprisingly robust.
            do
                if ( j > max_n_elements ) exit
                j=j+1
                if ( trams(j:j) .ne. ' ' ) then
                   i=i+1
                   do k=1,max_n_elements
                        if ( trams(j+1:j+1) .eq. ' ' ) exit
                        if ( trams(j+1:j+1) .ne. ' ' ) j=j+1
                        if ( k .eq. max_n_elements ) then
                            write(*,*) 'more than '//tochar(max_n_elements)//' different elements in the structure? really?'
                            stop
                        endif
                   enddo
                endif
            enddo
            n_elem=i
            ! perhaps it is a POSCAR with selective dynamics 
            ! I will ignore that, but it's nice if it does not crash
            read(u,*) trams
            seldyn=.false.
            if ( trams(1:1) .eq. 's' .or. trams(1:1) .eq. 'S' ) seldyn=.true.
        close(u)
    end block dummyopen

    ! Then we open the file for reals this time, and get stuff
    readstuff: block
        real(flyt) :: latpar_or_volume,f0
        real(flyt), dimension(3,3) :: im
        real(flyt), dimension(3) :: v
        integer, dimension(max_n_components) :: di
        integer, dimension(n_elem) :: elemcount
        integer :: i,j,k,l,u,na,ii,jj
        character(len=1) :: trams
        character(len=10), dimension(max_n_components) :: dvsp
        character(len=10) :: dumsp
        character(len=2000) :: dumstr
        logical :: cartesian 
        
        u=open_file('in',trim(filename))
            ! the header
            read(u,*) header 
            read(u,*) latpar_or_volume
            read(u,*) m(:,1)
            read(u,*) m(:,2)
            read(u,*) m(:,3)
            lo_allocate(symbols(n_elem))
            read(u,*) symbols
            read(u,*) elemcount
            read(u,*) trams
            ! Figure out if input is in fractional or cartesian coordinates.
            if ( trams .eq. 'C' .or. trams .eq. 'c' ) then
                cartesian=.true.
            elseif ( trams .eq. 'D' .or. trams .eq. 'd' ) then
                cartesian=.false.
            else
                write(*,*) 'Specify either Cartesian or direct coordinates in '//trim(filename)
                stop
            endif
            ! Maybe skip a line
            if ( seldyn ) read(u,*) trams

            ! Now we parsed the header, some small figuring out to do, such as how the input was
            ! specified and that stuff.
            alloy=.false.
            do i=1,n_elem
                if ( symbols(i)(1:5) .eq. 'alloy' .or. symbols(i)(1:5) .eq. 'Alloy' .or. symbols(i)(1:5) .eq. 'ALLOY' ) then
                    symbols(i)='ALLOY'
                    alloy=.true.
                endif
            enddo
            collmag=.false.
            do i=1,n_elem
                if ( symbols(i)(1:2) .eq. 'CM' ) then
                    symbols(i)='CM'
                    collmag=.true.
                endif
            enddo
            noncollmag=.false.
            do i=1,n_elem
                if ( symbols(i)(1:3) .eq. 'NCM' ) then
                    symbols(i)='NCM'
                    noncollmag=.true.
                endif
            enddo
            
            if ( alloy .and. collmag ) then
                write(*,*) 'I will bother with combined alloy and magnetic stuff on a rainy day. Very rainy day.'
                stop
            endif
            
            na=sum(elemcount)
            ! figure out if I have lattice parameter or volume
            if ( latpar_or_volume .gt. 0.0_flyt ) then
                m=m*latpar_or_volume
            else
                f0=( abs(latpar_or_volume)/abs(lo_determ(m)) )**(1.0_flyt/3.0_flyt)
                m=m*f0
            endif
            im=lo_invert3x3matrix( m )

            ! Some temporary space for all possible variants of things I want to read in
            lo_allocate(r(3,na))
            lo_allocate(atomic_number(na))
            lo_allocate(collmagmom(na))
            lo_allocate(cmatom(na))
            lo_allocate(noncollmagmom(3,na))
            lo_allocate(alloy_concentrations(max_n_components,na))
            lo_allocate(alloy_components(max_n_components,na))
            lo_allocate(alloy_componentcounter(na))

            r=0.0_flyt
            atomic_number=0
            collmagmom=0.0_flyt
            noncollmagmom=0.0_flyt
            cmatom=.false.
            alloy_concentrations=0.0_flyt
            alloy_components=0
            alloy_componentcounter=0

            ! The basic stuff has been figured out now, read the actual positions and stuff
            if ( alloy ) then
                l=0
                do i=1,n_elem
                do j=1,elemcount(i)
                    l=l+1
                    if ( trim(symbols(i)) .eq. 'ALLOY' ) then
                        read(u,'(A)') dumstr ! fetch this line to a buffer
                        read(dumstr,*) v,k
                        ! Quick sanity test
                        if ( k .le. 1 ) then
                            write(*,*) 'ERROR: it makes no sense to have an alloy with one component'
                            stop
                        endif
                
                        ! Not the most elegant solution, but it works.
                        select case(k)
                            case(2)
                                read(dumstr,*) v,alloy_componentcounter(l),&
                                               dvsp(1),alloy_concentrations(1,l),&
                                               dvsp(2),alloy_concentrations(2,l)
                            case(3)
                                read(dumstr,*) v,alloy_componentcounter(l),&
                                               dvsp(1),alloy_concentrations(1,l),&
                                               dvsp(2),alloy_concentrations(2,l),&
                                               dvsp(3),alloy_concentrations(3,l)
                            case(4)
                                read(dumstr,*) v,alloy_componentcounter(l),&
                                               dvsp(1),alloy_concentrations(1,l),&
                                               dvsp(2),alloy_concentrations(2,l),&
                                               dvsp(3),alloy_concentrations(3,l),&
                                               dvsp(4),alloy_concentrations(4,l)
                            case(5)
                                read(dumstr,*) v,alloy_componentcounter(l),&
                                               dvsp(1),alloy_concentrations(1,l),&
                                               dvsp(2),alloy_concentrations(2,l),&
                                               dvsp(3),alloy_concentrations(3,l),&
                                               dvsp(4),alloy_concentrations(4,l),&
                                               dvsp(5),alloy_concentrations(5,l)
                            case(6)
                                read(dumstr,*) v,alloy_componentcounter(l),&
                                               dvsp(1),alloy_concentrations(1,l),&
                                               dvsp(2),alloy_concentrations(2,l),&
                                               dvsp(3),alloy_concentrations(3,l),&
                                               dvsp(4),alloy_concentrations(4,l),&
                                               dvsp(5),alloy_concentrations(5,l),&
                                               dvsp(6),alloy_concentrations(6,l)
                            case default
                                write(*,*) 'I have not bothered with input for more than six components.'
                        end select

                        ! transform component labels to atomic numbers
                        do k=1,alloy_componentcounter(l)
                            alloy_components(k,l)=symbol_to_z( trim(adjustl(dvsp(k))) )
                        enddo
                        ! Some sanity checks right away, the components have to be unique
                        do ii=1,alloy_componentcounter(l)
                            do jj=ii+1,alloy_componentcounter(l)
                                if ( alloy_components(ii,l) .eq. alloy_components(jj,l) ) then
                                    write(*,*) 'ERROR: You can not alloy something with itself'
                                    stop
                                endif
                            enddo
                        enddo
                        ! concentrations have to add up to 1
                        if ( abs(sum(alloy_concentrations(1:alloy_componentcounter(l),l))-1.0_flyt) .gt. lo_tol ) then
                            write(*,*) 'ERROR: Alloy components have to add up to 1'
                            stop
                        endif
                        ! Sort components by atomic number
                        k=alloy_componentcounter(l)
                        di=0
                        call qsort(alloy_components(1:k,l),di(1:k))
                        alloy_concentrations(1:k,l)=alloy_concentrations(di(1:k),l)
                        ! Make sure the concentrations add up to 1
                        alloy_concentrations(1:k,l)=lo_chop( alloy_concentrations(1:k,l)/sum(alloy_concentrations(1:k,l)) ,lo_tol )
                    else
                        ! no need to bother, just read normally
                        read(u,*) v
                        atomic_number(l)=symbol_to_z( trim(adjustl(symbols(i))) )
                        alloy_componentcounter(l)=1
                        alloy_concentrations(1,l)=1.0_flyt
                        alloy_components(1,l)=symbol_to_z( trim(adjustl(symbols(i))) )
                    endif
                    ! fix cartesian stuff right away
                    if ( cartesian ) then
                        v=matmul(im,v)
                    endif
                    ! make sure the fractional coordinates really are that.
                    r(:,l)=lo_clean_fractional_coordinates(v)
                enddo
                enddo
            elseif ( collmag ) then
                ! Now there are some sort of magnetic moments specified.
                cmatom=.false.
                collmagmom=0.0_flyt
                l=0
                do i=1,n_elem
                do j=1,elemcount(i)
                    l=l+1
                    if ( trim(symbols(i)) .eq. 'CM' ) then
                        ! reading a DLM atom
                        read(u,*) v,dumsp,collmagmom(l)
                        cmatom(l)=.true.
                        atomic_number(l)=symbol_to_z(trim(dumsp))
                    else
                        read(u,*) v
                        atomic_number(l)=symbol_to_z( trim(adjustl(symbols(i))) )
                    endif
                    ! fix cartesian stuff right away
                    if ( cartesian ) then
                        v=matmul(im,v)
                    endif
                    ! make sure the fractional coordinates really are that.
                    r(:,l)=lo_clean_fractional_coordinates(v)
                enddo
                enddo
            elseif ( noncollmag ) then
                ! Non-collinear magnetic moments specified!
                cmatom=.false.
                noncollmagmom=0.0_flyt
                l=0
                do i=1,n_elem
                do j=1,elemcount(i)
                    l=l+1
                    if ( trim(symbols(i)) .eq. 'NCM' ) then
                        ! reading an atom with non-collinear moment
                        read(u,*) v,dumsp,noncollmagmom(:,l)
                        cmatom(l)=.true.
                        atomic_number(l)=symbol_to_z(trim(dumsp))
                    else
                        read(u,*) v
                        atomic_number(l)=symbol_to_z( trim(adjustl(symbols(i))) )
                    endif
                    ! fix cartesian stuff right away
                    if ( cartesian ) then
                        v=matmul(im,v)
                    endif
                    ! make sure the fractional coordinates really are that.
                    r(:,l)=lo_clean_fractional_coordinates(v)
                enddo
                enddo
            else
                ! Not an alloy or dlm, easy.
                ! get the atomic number
                l=0
                do i=1,n_elem
                do j=1,elemcount(i)
                    l=l+1
                    atomic_number(l)=symbol_to_z( trim(adjustl(symbols(i))) )
                enddo
                enddo
                ! now read the positions
                do i=1,na
                    read(u,*) v
                    ! fix cartesian stuff right away
                    if ( cartesian ) then
                        v=matmul(im,v)
                    endif
                    ! make sure the fractional coordinates really are that.
                    r(:,i)=lo_clean_fractional_coordinates(v)
                enddo
            endif
        close(u)
        ! Maybe say that this was mildly successful
        if ( verb .gt. 0 ) then
            write(*,*) 'Parsed POSCAR header, found '//tochar(sum(elemcount))//' atoms.'
        endif
    end block readstuff

    ! Do the real parsing, with all the classification and stuff.
    call p%generate(m,r,atomic_number,enhet=1,verbosity=verb,collmag=collmag,cmatom=cmatom,collmagmom=collmagmom,&
                    noncollmag=noncollmag,noncollmagmom=noncollmagmom,alloy=alloy,&
                    alloy_componentcounter=alloy_componentcounter,alloy_components=alloy_components,&
                    alloy_concentrations=alloy_concentrations)

    ! And some cleanup
    lo_deallocate(symbols)
    lo_deallocate(r)
    lo_deallocate(atomic_number)
    lo_deallocate(cmatom)
    lo_deallocate(collmagmom)
    lo_deallocate(noncollmagmom)
end subroutine

!> Writes a structure to file or stdout. Use 'stdout' as the filename if you want to write it to screen.
subroutine writetofile(p,filename,output_format,write_velocities,transformationmatrix)
    !> crystal structure
    class(lo_crystalstructure), intent(in) :: p
    !> the filename
    character(len=*), intent(in) :: filename
    !> what format to write in
    integer, intent(in) :: output_format
    !> if velocities should be written. Default false.
    logical, intent(in), optional :: write_velocities
    !> the structure might have the need to get transformed. If so, how was it transformed?
    real(flyt), dimension(3,3), intent(out), optional :: transformationmatrix

    ! Just pass it on the the appropriate routine
    select case(output_format)
        case(1) ! VASP
            call writetofile_vasp(p,filename,write_velocities)
        case(2) ! Abinit
            call writetofile_abinit(p,filename,write_velocities)
        case(3) ! LAMMPS
            call writetofile_lammps(p,filename,write_velocities,transformationmatrix)
        case(4) ! FHI Aims
            call writetofile_aims(p,filename,write_velocities)
        case(8) ! Quantum Espresso
            call writetofile_qe(p,filename,write_velocities)
        case default
            write(*,*) 'Unknown output format'
            stop
    end select
   
    contains
    ! The code-specific versions
    subroutine writetofile_vasp(p,filename,write_velocities)
        !> crystal structure
        class(lo_crystalstructure), intent(in) :: p
        !> the filename
        character(len=*), intent(in) :: filename
        !> if velocities should be written. Default false.
        logical, intent(in), optional :: write_velocities

        ! local
        integer :: u, i,j,jj
        real(flyt) :: latpar
        character(len=1000) :: opf
        character(len=1000) :: dum
        character(len=4000) :: dum1

!@TODO MAKE SURE SPECIES ARE IN THE CORRECT ORDER

        ! Write to a file, or stdout.
        if ( filename .eq. 'stdout' ) then
            u=0
        else
            u=open_file('out',trim(filename))
        endif

        write(u,*) trim(p%info%title)
        ! Print header with lattice parameter and lattice vectors
        opf="(1X,3(F20.14,' '))"
        if ( p%info%unitcell_lattice_parameter .gt. 0.0_flyt ) then
            latpar=p%info%unitcell_lattice_parameter
            write(u,"(2X,F20.12)") latpar*lo_bohr_to_A
            write(u,opf) lo_chop(p%latticevectors(:,1)/latpar,lo_sqtol)
            write(u,opf) lo_chop(p%latticevectors(:,2)/latpar,lo_sqtol)
            write(u,opf) lo_chop(p%latticevectors(:,3)/latpar,lo_sqtol)
        else
            latpar=1.0_flyt
            write(u,"(2X,F20.12)") latpar
            write(u,opf) lo_chop(p%latticevectors(:,1)*lo_bohr_to_A,lo_sqtol)
            write(u,opf) lo_chop(p%latticevectors(:,2)*lo_bohr_to_A,lo_sqtol)
            write(u,opf) lo_chop(p%latticevectors(:,3)*lo_bohr_to_A,lo_sqtol)
        endif

        dum=" "
        if ( p%info%alloy ) then
            do i=1,p%nelements
                if ( p%alloyspecies(i)%n .gt. 1 ) then
                    dum=trim(dum)//" ALLOY"
                else
                    dum=trim(dum)//" "//trim(p%atomic_symbol(i))
                endif
            enddo
        else
            do i=1,p%nelements
                dum=trim(dum)//" "//trim(p%atomic_symbol(i))
            enddo
        endif
        write(u,*) trim(dum)
        write(u,*) tochar(p%element_counter)
        write(u,*) 'Direct coordinates'
        if ( p%info%alloy ) then
            !! a bit fiddly to write nice alloy output, but ok
            do i=1,p%na
                jj=p%species(i)
                
                if ( p%alloyspecies(jj)%n .eq. 1 ) then
                    j=ceiling(log10(p%na*1.0_flyt+0.1_flyt))+1
                    opf="(1X,3(F18.14,' '),' site'I"//tochar(j)//",' species',I2,': ',A2)"
                    write(u,opf) p%r(:,i),i,p%species(i),p%atomic_symbol(p%species(i))
                else
                    dum1=""
                    do j=1,3
                        dum1=trim(dum1)//"   "//tochar(p%r(j,i),14)
                    enddo
                    dum1(1:499)=dum1(2:500)
                    dum1=trim(dum1)//" "//tochar(p%alloyspecies(jj)%n)
                    do j=1,p%alloyspecies(jj)%n
                        dum1=trim(dum1)//" "//trim(p%alloyspecies(jj)%atomic_symbol(j))
                        dum1=trim(dum1)//" "//tochar(p%alloyspecies(jj)%concentration(j),12)
                    enddo
                    write(u,"(1X,A)") trim(dum1)
                endif
            enddo
        elseif ( p%info%collmag ) then
            j=ceiling(log10(p%na*1.0_flyt+0.1_flyt))+1
            opf="(1X,3(F18.14,' '),' site'I"//tochar(j)//",' magmom: ',F8.4)"
            do i=1,p%na
                write(u,opf) p%r(:,i),i,p%mag%collinear_moment(i) 
            enddo
        elseif ( p%info%noncollmag ) then
            j=ceiling(log10(p%na*1.0_flyt+0.1_flyt))+1
            opf="(1X,3(F18.14,' '),' site'I"//tochar(j)//",' magmom: ',3(1X,F8.4))"
            do i=1,p%na
                write(u,opf) p%r(:,i),i,p%mag%noncollinear_moment(:,i) 
            enddo
        else
            j=ceiling(log10(p%na*1.0_flyt+0.1_flyt))+1
            opf="(1X,3(F18.14,' '),' site'I"//tochar(j)//",' species',I2,': ',A2)"
            do i=1,p%na
                write(u,opf) p%r(:,i),i,p%species(i),p%atomic_symbol(p%species(i))
            enddo
        endif
        
        ! Maybe write the velocities
        if ( present(write_velocities) ) then
        if ( write_velocities ) then
            write(u,*) ' '
            do i=1,p%na
                write(u,*) p%v(:,i)*lo_velocity_au_to_Afs
            enddo
        endif
        endif
        
        if ( filename .ne. 'stdout' ) close(u)
    end subroutine

    subroutine writetofile_lammps(p,filename,write_velocities,transformationmatrix)
        !> crystal structure
        class(lo_crystalstructure), intent(in) :: p
        !> filename
        character(len=*), intent(in) :: filename
        !> should be written. Default false.
        logical, intent(in), optional :: write_velocities
        !> optionally, return the magical transformation matrix
        real(flyt), dimension(3,3), intent(out), optional :: transformationmatrix
        !
        real(flyt), dimension(3,3) :: tm,basis
        real(flyt) :: a,b,c,al,be,gm
        real(flyt) :: ax,bx,cx,by,cy,cz
        logical :: writevel
        integer :: i,u
        
        if ( present(write_velocities) ) then
            writevel=write_velocities
        else
            writevel=.false.
        endif

        ! Get the lattice parameter thingy
        call lo_get_axis_angles(p%latticevectors,a,b,c,al,be,gm)
        
        ax=a
        bx=lo_chop(b*cos(gm),lo_sqtol)
        by=sqrt(b**2-bx**2)
        cx=lo_chop( c*cos(be) ,lo_sqtol)
        cy=lo_chop( ( dot_product(p%latticevectors(2,:),p%latticevectors(3,:))-bx*cx )/by ,lo_sqtol)
        cz=lo_chop( sqrt(c**2-cx**2-cy**2) , lo_sqtol )

        ! Convert to Angstrom
        ax=ax*lo_bohr_to_A
        bx=bx*lo_bohr_to_A
        by=by*lo_bohr_to_A
        cx=cx*lo_bohr_to_A
        cy=cy*lo_bohr_to_A
        cz=cz*lo_bohr_to_A
        
        basis=0.0_flyt
        basis(:,1)=[ ax , 0.0_flyt, 0.0_flyt]
        basis(:,2)=[ bx, by, 0.0_flyt] 
        basis(:,3)=[ cx, cy, cz ]
        basis=lo_chop(basis,lo_sqtol)
        
        ! Return the coordinate transformation to what LAMMPS likes.
        if ( present(transformationmatrix) ) then
            transformationmatrix=matmul(basis,p%inv_latticevectors)
        endif
    
        ! figure out how to convert stuff
        tm=matmul(basis,p%inv_latticevectors)
        
        ! and print it
        u=open_file('out',trim(filename))
            write(u,*) '# Something'
            write(u,*) tochar(p%na),' atoms'
            write(u,*) tochar(maxval(p%species)),' atom types'
            write(u,*) '0',ax,'xlo xhi '
            write(u,*) '0',by,'ylo yhi '
            write(u,*) '0',cz,'zlo zhi '
            write(u,*) bx,cx,cy,'xy xz yz'
            write(u,*) 'Atoms'
            write(u,*) ''
            do i=1,p%na
                write(u,*) i,p%species(i),lo_chop(matmul(basis,p%r(:,i)),lo_sqtol)
            enddo
        close(u)

        if ( writevel ) then
            write(*,*) 'Have not fixed velocity output for LAMMMPS yet'
        endif
    end subroutine

    !> Writes a structure to abinit output file or stdout 
    subroutine writetofile_abinit(p,filename,write_velocities)
        !> crystal structure
        class(lo_crystalstructure), intent(in) :: p
        !> filename
        character(len=*), intent(in) :: filename
        !> should be written. Default false.
        logical, intent(in), optional :: write_velocities
        ! local
        integer :: i
        !
        real(flyt) :: latpar
        character(len=1000) :: opf
        character(len=10000) :: dum
        integer :: u,l

        ! file or stdout 
        if ( filename .eq. 'stdout' ) then
            u=0
        else
            u=open_file('out',filename)
        endif
        ! It is quite neat to figure a 'lattice parameter' of sorts.
        if ( p%info%unitcell_lattice_parameter .gt. 0.0_flyt ) then
            latpar=p%info%unitcell_lattice_parameter
        else
            latpar=1.0_flyt
        endif
    
        write(u,*) "#"
        write(u,*) "# you still need to fill in converged values for ecut, tolerance, k-points, MD mode, etc..."
        write(u,*) "# header string ", trim(adjustl(p%info%title))
        write(u,*) "# e.g. :"
        write(u,*) "# ngkpt 1 1 1    shiftk 0 0 0"
        write(u,*) "# ecut 20"
        write(u,*) "# toldfe 1.e-12"
        write(u,*) "acell 3*",tochar(latpar,12)
        write(u,*) "rprim "
        write(u,*) lo_choplarge(p%latticevectors(:,1)/latpar,lo_sqtol) 
        write(u,*) lo_choplarge(p%latticevectors(:,2)/latpar,lo_sqtol) 
        write(u,*) lo_choplarge(p%latticevectors(:,3)/latpar,lo_sqtol) 
        dum="znucl "
        do i=1,p%nelements
            dum=trim(dum)//' '//tochar(symbol_to_z(p%atomic_symbol(i)))
        enddo
        write(u,*) trim(dum)
        write(u,*) "natom ",tochar(p%na)
        write(u,*) "ntypat ",tochar(p%nelements)
        dum="typat "
        l=0 ! this is a counter so that the lines don't get silly long
        do i=1,p%na
            l=l+1
            dum=trim(dum)//' '//tochar(p%species(i))
            if ( l .gt. 45 ) then
                dum=trim(dum)//""
                write(u,*) trim(dum)
                dum=" "
                l=0
            endif
        enddo
        write(u,*) trim(dum)
        write(u,*) 'xred'
        if ( p%info%alloy ) then
            write(u,*) " Alloys in abinit output format are not coded yet"
            stop
    !        ! a bit fiddly to write nice alloy output, but ok
    !        do i=1,p%na
    !            if ( p%alloyatom(i)%n .eq. 0 ) then
    !                write(u,op2) p%r(:,i),i,p%species(i),p%atomic_symbol(p%species(i))
    !            else
    !                dum1=""
    !                do j=1,3
    !                    dum1=trim(dum1)//" "//trim(flyt2char(p%r(j,i),opf="(F18.12)"))
    !                enddo
    !                dum1(1:499)=dum1(2:500)
    !                dum1=trim(dum1)//" "//trim(int2char(p%alloyatom(i)%n))
    !                do j=1,p%alloyatom(i)%n
    !                    dum1=trim(dum1)//" "//trim(p%alloyatom(i)%atomic_symbol(j))
    !                    dum1=trim(dum1)//" "//trim(adjustl(flyt2char(p%alloyatom(i)%conc(j),i=12)))
    !                enddo
    !                write(u,"(1X,A)") trim(dum1)
    !            endif
    !        enddo
        else
            opf="(1X,3(F18.12,' '),'# site:',I5,' species:',I2,' ',A2)"
            do i=1,p%na
                write(u,opf) lo_chop(p%r(:,i),lo_sqtol),i,p%species(i),p%atomic_symbol(p%species(i))
            enddo
        endif
        
        ! Maybe write the velocities
        if ( present(write_velocities) ) then
        if ( write_velocities ) then
            write(u,*) 'vel'
            do i=1,p%na
                write(u,*) p%v(:,i) ! * lo_bohr / (lo_hbar_ev / lo_Hartree / lo_fs2s) 
            enddo
        endif
        endif
        
        if ( filename .ne. 'stdout' ) close(u)
    end subroutine 

    !> Writes a structure in AIMS format 
    subroutine writetofile_aims(p,filename,write_velocities)
        !> crystal structure
        class(lo_crystalstructure), intent(in) :: p
        !> filename
        character(len=*), intent(in) :: filename
        !> should be written. Default false.
        logical, intent(in), optional :: write_velocities
        ! local
        integer :: i
        !
        logical :: vel
        integer :: u

        if ( present(write_velocities) ) then
            vel=write_velocities
        else
            vel=.false.
        endif

        ! file or stdout 
        if ( filename .eq. 'stdout' ) then
            u=0
        else
            u=open_file('out',filename)
        endif
    
        ! Write velocities in A/ps = A/fc * 1e3
        write(u,*) "# kommentar"
        write(u,"(1X,'lattice_vector',3(1X,E19.12))") p%latticevectors(:,1)*lo_bohr_to_A 
        write(u,"(1X,'lattice_vector',3(1X,E19.12))") p%latticevectors(:,2)*lo_bohr_to_A 
        write(u,"(1X,'lattice_vector',3(1X,E19.12))") p%latticevectors(:,3)*lo_bohr_to_A 
        do i=1,p%na
            write(u,"(1X,'atom_frac',3(1X,E19.12),1X,A)") p%r(:,i),trim(p%atomic_symbol( p%species(i) ))
            if ( vel ) write(u,"(1X,'velocity',3(1X,E19.12))") p%v(:,i)*lo_velocity_au_to_Afs*1E3_flyt
        enddo
        
        if ( filename .ne. 'stdout' ) close(u)
    end subroutine 

    !> Writes a structure in Quantum Espresso format
    subroutine writetofile_qe(p, filename, write_velocities)
        use konstanter, only: lo_emu_to_amu
        !> crystal structure
        class(lo_crystalstructure), intent(in) :: p
        !> the filename
        character(len=*), intent(in) :: filename
        !> if velocities should be written. Default false.
        logical, intent(in), optional :: write_velocities
        
        ! local
        integer :: u, i
        real(flyt) :: latpar, mass
        character(len=1000) :: opf, symbol
   
        ! It is quite neat to figure a 'lattice parameter' of sorts.
        if ( p%info%unitcell_lattice_parameter .gt. 0.0_flyt ) then
            latpar=p%info%unitcell_lattice_parameter
        else
            latpar=1.0_flyt
        endif

        ! Write to a file, or stdout.
        if ( filename .eq. 'stdout' ) then
            u=0
        else
            u=open_file('out',trim(filename))
        endif
         
       !write(u,*) '# '//trim(p%info%title)
       !write(u,'(a)') "&SYSTEM"
       !write(u,'(2x, a)') "ibrav = 0"
       !write(u,'(2x, a12, F20.12)') "celldm(1) = ", latpar
       !write(u,'(2x, a)') 'nat = '//tochar(p%na)
       !write(u,'(2x, a)') 'ntyp = '//tochar(p%nelements)
       !write(u,'(a)') "/"
       !opf="(2X,3(F20.14,1x))"
       !write(u,'(a)') "CELL_PARAMETERS {alat}"
       !write(u,opf) lo_chop(p%latticevectors(:,1)/latpar,lo_sqtol)
       !write(u,opf) lo_chop(p%latticevectors(:,2)/latpar,lo_sqtol)
       !write(u,opf) lo_chop(p%latticevectors(:,3)/latpar,lo_sqtol)        
       !opf="(2X, a2, 2x, F20.14, 2x, a9)"
       !write(u,'(a)') "ATOMIC_SPECIES"
       !do i=1, p%nelements
       !    symbol = p%atomic_symbol(i)
       !    ! assume atoms belong to the same species have the same mass
       !    mass = p%mass(sum( p%element_counter(1:i) )) * lo_emu_to_amu
       !    write(u,opf) trim(symbol), mass, trim(symbol)//"_PSEUDO"
       !enddo
        write(u,'(a)') "ATOMIC_POSITIONS {crystal}"
        do i=1, p%na
            opf="(a2, 2x, 3(F18.14, 1x))"
            write(u,opf) p%atomic_symbol(p%species(i)), p%r(:,i)
        enddo  

        if ( filename .ne. 'stdout' ) close(u)
    end subroutine 

end subroutine 

!> Read isotope distribution from file
subroutine readisotopefromfile(p)
    !> crystal structure
    class(lo_crystalstructure), intent(inout) :: p
 
    integer :: i,j,u
    
    ! Make sure that it is not already allocated
    if ( allocated(p%isotope) ) then
        do i=1,p%na
            if ( allocated(p%isotope(i)%conc) ) lo_deallocate(p%isotope(i)%conc)
            if ( allocated(p%isotope(i)%mass) ) lo_deallocate(p%isotope(i)%mass)
        enddo
        lo_deallocate(p%isotope)
    endif
    
    lo_allocate(p%isotope(p%na))
    u=open_file('in','infile.isotopes')
        do i=1,p%na
            read(u,*) p%isotope(i)%n
            lo_allocate(p%isotope(i)%conc(p%isotope(i)%n))
            lo_allocate(p%isotope(i)%mass(p%isotope(i)%n))
            do j=1,p%isotope(i)%n
                read(u,*) p%isotope(i)%conc(j),p%isotope(i)%mass(j)
            enddo
            ! convert to atomic units
            p%isotope(i)%mass=p%isotope(i)%mass*lo_amu_to_emu
        enddo
    close(u)
    
    do i=1,p%na
        p%isotope(i)%conc=p%isotope(i)%conc/sum(p%isotope(i)%conc)
        p%isotope(i)%mean_mass=sum(p%isotope(i)%conc*p%isotope(i)%mass)
        p%mass(i)=p%isotope(i)%mean_mass
        p%invsqrtmass(i)=1.0_flyt/sqrt(p%mass(i))
        p%isotope(i)%disorderparameter=p%isotope(i)%massdisorderparameter()
    enddo
end subroutine

!> write the Brillouin zone to HDF5
subroutine write_bz_to_hdf5(p,filename,input_id)
    !> the brillouin zone
    class(lo_crystalstructure), intent(in) :: p
    !> the filename
    character(len=*), intent(in) :: filename
    !> in case I want to write it as a part of another file
    integer(HID_T), intent(in), optional :: input_id
    
    integer(HID_T) :: active_id
    integer :: i
    character(len=1000) :: dum

    ! maybe create a new file
    if ( present(input_id) ) then
        ! now I assume hdf is open, and a file is open
        active_id=input_id
    else
        ! open a new file
        call h5open_f(lo_status)
        call h5fcreate_f(trim(filename), H5F_ACC_TRUNC_F, active_id, lo_status)
    endif

    ! some meta
    call lo_h5_store_attribute(p%bz%nnodes,active_id,'number_of_zone_nodes')
    call lo_h5_store_attribute(p%bz%nfaces,active_id,'number_of_zone_faces')
    ! store the nodes of the full zone
    call lo_h5_store_data(p%bz%r,active_id,'zone_nodes') !,enhet='1/A')
    ! and the faces. Not the prettiest way, but it does not really matter.
    do i=1,p%bz%nfaces
        dum='zone_face_'//tochar(i)
        call lo_h5_store_data(p%bz%face(i)%ind,active_id,trim(dum))
    enddo
    ! and store the wedge
    call lo_h5_store_attribute(p%irrw%nnodes,active_id,'number_of_wedge_nodes')
    call lo_h5_store_attribute(p%irrw%nfaces,active_id,'number_of_wedge_faces')
    ! store the nodes of the full zone
    call lo_h5_store_data(p%irrw%r,active_id,'wedge_nodes') !,enhet='1/A')
    ! and the faces. Not the prettiest way, but it does not really matter.
    do i=1,p%irrw%nfaces
        dum='wedge_face_'//tochar(i)
        call lo_h5_store_data(p%irrw%face(i)%ind,active_id,trim(dum))
    enddo
    ! also, the labels
    dum=''
    do i=1,p%irrw%nnodes
        dum=trim(dum)//' '//trim(adjustl(p%irrw%label(i)))
    enddo
    call lo_h5_store_attribute(trim(adjustl(dum)),active_id,'wedge_node_labels')
    
    ! maybe close
    if ( present(input_id) .eqv. .false. ) then
        call h5fclose_f(active_id, lo_status)
        call h5close_f(lo_status)
    endif
end subroutine

