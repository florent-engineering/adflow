   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.10 (r5363) -  9 Sep 2014 09:53
   !
   !  Differentiation of xhalo_block in forward (tangent) mode (with options i4 dr8 r8):
   !   variations   of useful results: *x
   !   with respect to varying inputs: *x
   !   Plus diff mem management of: x:in bcdata:in
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          xhalo.f90                                       *
   !      * Author:        Edwin van der Weide,C.A.(Sandy) Mader            *
   !      * Starting date: 02-23-2003                                      *
   !      * Last modified: 08-12-2009                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE XHALO_BLOCK_D()
   !
   !      ******************************************************************
   !      *                                                                *
   !      * xhalo determines the coordinates of the nodal halo's.          *
   !      * First it sets all halo coordinates by simple extrapolation,    *
   !      * then the symmetry planes are treated (also the unit normal of  *
   !      * symmetry planes are determined) and finally an exchange is     *
   !      * made for the internal halo's.                                  *
   !      *                                                                *
   !      ******************************************************************
   !
   USE BLOCKPOINTERS_D
   USE BCTYPES
   USE COMMUNICATION
   USE INPUTTIMESPECTRAL
   USE DIFFSIZES
   !  Hint: ISIZE1OFDrfbcdata should be the size of dimension 1 of array *bcdata
   IMPLICIT NONE
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: mm, i, j, k
   INTEGER(kind=inttype) :: ibeg, iend, jbeg, jend, iimax, jjmax
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: x0, x1, x2
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: x0d, x1d, x2d
   LOGICAL :: err
   REAL(kind=realtype) :: length, dot
   REAL(kind=realtype) :: lengthd, dotd
   LOGICAL :: imininternal, jmininternal, kmininternal
   LOGICAL :: imaxinternal, jmaxinternal, kmaxinternal
   REAL(kind=realtype), DIMENSION(3) :: v1, v2, norm
   REAL(kind=realtype), DIMENSION(3) :: v1d, v2d, normd
   INTRINSIC SQRT
   REAL(kind=realtype) :: arg1
   REAL(kind=realtype) :: arg1d
   INTEGER :: ii1
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   !
   !          **************************************************************
   !          *                                                            *
   !          * Extrapolation of the coordinates. First extrapolation in   *
   !          * i-direction, without halo's, followed by extrapolation in  *
   !          * j-direction, with i-halo's and finally extrapolation in    *
   !          * k-direction, with both i- and j-halo's. In this way also   *
   !          * the indirect halo's get a value, albeit a bit arbitrary.   *
   !          *                                                            *
   !          **************************************************************
   !
   imininternal = .false.
   jmininternal = .false.
   kmininternal = .false.
   imaxinternal = .false.
   jmaxinternal = .false.
   kmaxinternal = .false.
   ! Loop over all the subfaces to determine which ones do NOT need to be extrapolated.
   loopsubface:DO mm=1,nsubface
   IF (bctype(mm) .EQ. b2bmatch) THEN
   SELECT CASE  (bcfaceid(mm)) 
   CASE (imin) 
   imininternal = .true.
   CASE (imax) 
   imaxinternal = .true.
   CASE (jmin) 
   jmininternal = .true.
   CASE (jmax) 
   jmaxinternal = .true.
   CASE (kmin) 
   kmininternal = .true.
   CASE (kmax) 
   kmaxinternal = .true.
   END SELECT
   END IF
   END DO loopsubface
   ! Re-loop back over and see if any subface that is NOT B2BMatch is
   ! on the same logical face as a Block2Block. We cannot deal with
   ! properly so will print an error and quit
   err = .false.
   loopsubface2:DO mm=1,nsubface
   IF (bctype(mm) .NE. b2bmatch) THEN
   SELECT CASE  (bcfaceid(mm)) 
   CASE (imin) 
   IF (imininternal) err = .true.
   CASE (imax) 
   IF (imaxinternal) err = .true.
   CASE (jmin) 
   IF (jmininternal) err = .true.
   CASE (jmax) 
   IF (jmaxinternal) err = .true.
   CASE (kmin) 
   IF (kmininternal) err = .true.
   CASE (kmax) 
   IF (kmaxinternal) err = .true.
   END SELECT
   END IF
   END DO loopsubface2
   IF (err) THEN
   PRINT*, &
   &   'Detected a block-to-block boundary condition on the same face'
   PRINT*, 'as another boundary condition. This is not supported.'
   STOP
   ELSE
   ! Extrapolation in i-direction.
   DO k=1,kl
   DO j=1,jl
   IF (.NOT.imininternal) THEN
   xd(0, j, k, 1) = two*xd(1, j, k, 1) - xd(2, j, k, 1)
   x(0, j, k, 1) = two*x(1, j, k, 1) - x(2, j, k, 1)
   xd(0, j, k, 2) = two*xd(1, j, k, 2) - xd(2, j, k, 2)
   x(0, j, k, 2) = two*x(1, j, k, 2) - x(2, j, k, 2)
   xd(0, j, k, 3) = two*xd(1, j, k, 3) - xd(2, j, k, 3)
   x(0, j, k, 3) = two*x(1, j, k, 3) - x(2, j, k, 3)
   END IF
   IF (.NOT.imaxinternal) THEN
   xd(ie, j, k, 1) = two*xd(il, j, k, 1) - xd(nx, j, k, 1)
   x(ie, j, k, 1) = two*x(il, j, k, 1) - x(nx, j, k, 1)
   xd(ie, j, k, 2) = two*xd(il, j, k, 2) - xd(nx, j, k, 2)
   x(ie, j, k, 2) = two*x(il, j, k, 2) - x(nx, j, k, 2)
   xd(ie, j, k, 3) = two*xd(il, j, k, 3) - xd(nx, j, k, 3)
   x(ie, j, k, 3) = two*x(il, j, k, 3) - x(nx, j, k, 3)
   END IF
   END DO
   END DO
   ! Extrapolation in j-direction.
   DO k=1,kl
   DO i=0,ie
   IF (.NOT.jmininternal) THEN
   xd(i, 0, k, 1) = two*xd(i, 1, k, 1) - xd(i, 2, k, 1)
   x(i, 0, k, 1) = two*x(i, 1, k, 1) - x(i, 2, k, 1)
   xd(i, 0, k, 2) = two*xd(i, 1, k, 2) - xd(i, 2, k, 2)
   x(i, 0, k, 2) = two*x(i, 1, k, 2) - x(i, 2, k, 2)
   xd(i, 0, k, 3) = two*xd(i, 1, k, 3) - xd(i, 2, k, 3)
   x(i, 0, k, 3) = two*x(i, 1, k, 3) - x(i, 2, k, 3)
   END IF
   IF (.NOT.jmaxinternal) THEN
   xd(i, je, k, 1) = two*xd(i, jl, k, 1) - xd(i, ny, k, 1)
   x(i, je, k, 1) = two*x(i, jl, k, 1) - x(i, ny, k, 1)
   xd(i, je, k, 2) = two*xd(i, jl, k, 2) - xd(i, ny, k, 2)
   x(i, je, k, 2) = two*x(i, jl, k, 2) - x(i, ny, k, 2)
   xd(i, je, k, 3) = two*xd(i, jl, k, 3) - xd(i, ny, k, 3)
   x(i, je, k, 3) = two*x(i, jl, k, 3) - x(i, ny, k, 3)
   END IF
   END DO
   END DO
   ! Extrapolation in k-direction.
   DO j=0,je
   DO i=0,ie
   IF (.NOT.kmininternal) THEN
   xd(i, j, 0, 1) = two*xd(i, j, 1, 1) - xd(i, j, 2, 1)
   x(i, j, 0, 1) = two*x(i, j, 1, 1) - x(i, j, 2, 1)
   xd(i, j, 0, 2) = two*xd(i, j, 1, 2) - xd(i, j, 2, 2)
   x(i, j, 0, 2) = two*x(i, j, 1, 2) - x(i, j, 2, 2)
   xd(i, j, 0, 3) = two*xd(i, j, 1, 3) - xd(i, j, 2, 3)
   x(i, j, 0, 3) = two*x(i, j, 1, 3) - x(i, j, 2, 3)
   END IF
   IF (.NOT.kmaxinternal) THEN
   xd(i, j, ke, 1) = two*xd(i, j, kl, 1) - xd(i, j, nz, 1)
   x(i, j, ke, 1) = two*x(i, j, kl, 1) - x(i, j, nz, 1)
   xd(i, j, ke, 2) = two*xd(i, j, kl, 2) - xd(i, j, nz, 2)
   x(i, j, ke, 2) = two*x(i, j, kl, 2) - x(i, j, nz, 2)
   xd(i, j, ke, 3) = two*xd(i, j, kl, 3) - xd(i, j, nz, 3)
   x(i, j, ke, 3) = two*x(i, j, kl, 3) - x(i, j, nz, 3)
   END IF
   END DO
   END DO
   DO ii1=1,ISIZE1OFDrfbcdata
   bcdatad(ii1)%symnorm = 0.0_8
   END DO
   v1d = 0.0_8
   v2d = 0.0_8
   normd = 0.0_8
   !
   !          **************************************************************
   !          *                                                            *
   !          * Mirror the halo coordinates adjacent to the symmetry       *
   !          * planes                                                     *
   !          *                                                            *
   !          **************************************************************
   !
   ! Loop over boundary subfaces.
   loopbocos:DO mm=1,nbocos
   ! The actual correction of the coordinates only takes
   ! place for symmetry planes.
   IF (bctype(mm) .EQ. symm) THEN
   ! Set some variables, depending on the block face on
   ! which the subface is located.
   SELECT CASE  (bcfaceid(mm)) 
   CASE (imin) 
   ibeg = jnbeg(mm)
   iend = jnend(mm)
   iimax = jl
   jbeg = knbeg(mm)
   jend = knend(mm)
   jjmax = kl
   x0d => xd(0, :, :, :)
   x0 => x(0, :, :, :)
   x1d => xd(1, :, :, :)
   x1 => x(1, :, :, :)
   x2d => xd(2, :, :, :)
   x2 => x(2, :, :, :)
   CASE (imax) 
   ibeg = jnbeg(mm)
   iend = jnend(mm)
   iimax = jl
   jbeg = knbeg(mm)
   jend = knend(mm)
   jjmax = kl
   x0d => xd(ie, :, :, :)
   x0 => x(ie, :, :, :)
   x1d => xd(il, :, :, :)
   x1 => x(il, :, :, :)
   x2d => xd(nx, :, :, :)
   x2 => x(nx, :, :, :)
   CASE (jmin) 
   ibeg = inbeg(mm)
   iend = inend(mm)
   iimax = il
   jbeg = knbeg(mm)
   jend = knend(mm)
   jjmax = kl
   x0d => xd(:, 0, :, :)
   x0 => x(:, 0, :, :)
   x1d => xd(:, 1, :, :)
   x1 => x(:, 1, :, :)
   x2d => xd(:, 2, :, :)
   x2 => x(:, 2, :, :)
   CASE (jmax) 
   ibeg = inbeg(mm)
   iend = inend(mm)
   iimax = il
   jbeg = knbeg(mm)
   jend = knend(mm)
   jjmax = kl
   x0d => xd(:, je, :, :)
   x0 => x(:, je, :, :)
   x1d => xd(:, jl, :, :)
   x1 => x(:, jl, :, :)
   x2d => xd(:, ny, :, :)
   x2 => x(:, ny, :, :)
   CASE (kmin) 
   ibeg = inbeg(mm)
   iend = inend(mm)
   iimax = il
   jbeg = jnbeg(mm)
   jend = jnend(mm)
   jjmax = jl
   x0d => xd(:, :, 0, :)
   x0 => x(:, :, 0, :)
   x1d => xd(:, :, 1, :)
   x1 => x(:, :, 1, :)
   x2d => xd(:, :, 2, :)
   x2 => x(:, :, 2, :)
   CASE (kmax) 
   ibeg = inbeg(mm)
   iend = inend(mm)
   iimax = il
   jbeg = jnbeg(mm)
   jend = jnend(mm)
   jjmax = jl
   x0d => xd(:, :, ke, :)
   x0 => x(:, :, ke, :)
   x1d => xd(:, :, kl, :)
   x1 => x(:, :, kl, :)
   x2d => xd(:, :, nz, :)
   x2 => x(:, :, nz, :)
   END SELECT
   IF (.NOT.bcdata(mm)%symnormset) THEN
   ! This code technically should not run. symNormSet should
   ! already be set from the regular Xhao on the
   ! first call.
   ! Determine the vector from the lower left corner to
   ! the upper right corner. Due to the usage of pointers an
   ! offset of +1 must be used, because the original array x
   ! start at 0.
   v1d(1) = x1d(iimax+1, jjmax+1, 1) - x1d(1+1, 1+1, 1)
   v1(1) = x1(iimax+1, jjmax+1, 1) - x1(1+1, 1+1, 1)
   v1d(2) = x1d(iimax+1, jjmax+1, 2) - x1d(1+1, 1+1, 2)
   v1(2) = x1(iimax+1, jjmax+1, 2) - x1(1+1, 1+1, 2)
   v1d(3) = x1d(iimax+1, jjmax+1, 3) - x1d(1+1, 1+1, 3)
   v1(3) = x1(iimax+1, jjmax+1, 3) - x1(1+1, 1+1, 3)
   ! And the vector from the upper left corner to the
   ! lower right corner.
   v2d(1) = x1d(iimax+1, 1+1, 1) - x1d(1+1, jjmax+1, 1)
   v2(1) = x1(iimax+1, 1+1, 1) - x1(1+1, jjmax+1, 1)
   v2d(2) = x1d(iimax+1, 1+1, 2) - x1d(1+1, jjmax+1, 2)
   v2(2) = x1(iimax+1, 1+1, 2) - x1(1+1, jjmax+1, 2)
   v2d(3) = x1d(iimax+1, 1+1, 3) - x1d(1+1, jjmax+1, 3)
   v2(3) = x1(iimax+1, 1+1, 3) - x1(1+1, jjmax+1, 3)
   ! Determine the normal of the face by taking the cross
   ! product of v1 and v2 and add it to norm.
   normd(1) = v1d(2)*v2(3) + v1(2)*v2d(3) - v1d(3)*v2(2) - v1(3)*&
   &           v2d(2)
   norm(1) = v1(2)*v2(3) - v1(3)*v2(2)
   normd(2) = v1d(3)*v2(1) + v1(3)*v2d(1) - v1d(1)*v2(3) - v1(1)*&
   &           v2d(3)
   norm(2) = v1(3)*v2(1) - v1(1)*v2(3)
   normd(3) = v1d(1)*v2(2) + v1(1)*v2d(2) - v1d(2)*v2(1) - v1(2)*&
   &           v2d(1)
   norm(3) = v1(1)*v2(2) - v1(2)*v2(1)
   bcdatad(mm)%symnorm(1) = normd(1)
   bcdata(mm)%symnorm(1) = norm(1)
   bcdatad(mm)%symnorm(2) = normd(2)
   bcdata(mm)%symnorm(2) = norm(2)
   bcdatad(mm)%symnorm(3) = normd(3)
   bcdata(mm)%symnorm(3) = norm(3)
   ELSE
   ! Copy out the saved symNorm
   normd(1) = bcdatad(mm)%symnorm(1)
   norm(1) = bcdata(mm)%symnorm(1)
   normd(2) = bcdatad(mm)%symnorm(2)
   norm(2) = bcdata(mm)%symnorm(2)
   normd(3) = bcdatad(mm)%symnorm(3)
   norm(3) = bcdata(mm)%symnorm(3)
   END IF
   ! Compute the length of the normal and test if this is
   ! larger than eps. If this is the case this means that
   ! it is a nonsingular subface and the coordinates are
   ! corrected.
   arg1d = 2*norm(1)*normd(1) + 2*norm(2)*normd(2) + 2*norm(3)*&
   &         normd(3)
   arg1 = norm(1)**2 + norm(2)**2 + norm(3)**2
   IF (arg1 .EQ. 0.0_8) THEN
   lengthd = 0.0_8
   ELSE
   lengthd = arg1d/(2.0*SQRT(arg1))
   END IF
   length = SQRT(arg1)
   IF (length .GT. eps) THEN
   ! Compute the unit normal of the subface.
   normd(1) = (normd(1)*length-norm(1)*lengthd)/length**2
   norm(1) = norm(1)/length
   normd(2) = (normd(2)*length-norm(2)*lengthd)/length**2
   norm(2) = norm(2)/length
   normd(3) = (normd(3)*length-norm(3)*lengthd)/length**2
   norm(3) = norm(3)/length
   ! Add an overlap to the symmetry subface if the
   ! boundaries coincide with the block boundaries.
   ! This way the indirect halo's are treated properly.
   IF (ibeg .EQ. 1) ibeg = 0
   IF (iend .EQ. iimax) iend = iimax + 1
   IF (jbeg .EQ. 1) jbeg = 0
   IF (jend .EQ. jjmax) jend = jjmax + 1
   ! Loop over the nodes of the subface and set the
   ! corresponding halo coordinates.
   DO j=jbeg,jend
   DO i=ibeg,iend
   ! Determine the vector from the internal node to the
   ! node on the face. Again an offset of +1 must be
   ! used, due to the usage of pointers.
   v1d(1) = x1d(i+1, j+1, 1) - x2d(i+1, j+1, 1)
   v1(1) = x1(i+1, j+1, 1) - x2(i+1, j+1, 1)
   v1d(2) = x1d(i+1, j+1, 2) - x2d(i+1, j+1, 2)
   v1(2) = x1(i+1, j+1, 2) - x2(i+1, j+1, 2)
   v1d(3) = x1d(i+1, j+1, 3) - x2d(i+1, j+1, 3)
   v1(3) = x1(i+1, j+1, 3) - x2(i+1, j+1, 3)
   ! Determine two times the normal component of this
   ! vector; this vector must be added to the
   ! coordinates of the internal node to obtain the
   ! halo coordinates. Again the offset of +1.
   dotd = two*(v1d(1)*norm(1)+v1(1)*normd(1)+v1d(2)*norm(2)+&
   &               v1(2)*normd(2)+v1d(3)*norm(3)+v1(3)*normd(3))
   dot = two*(v1(1)*norm(1)+v1(2)*norm(2)+v1(3)*norm(3))
   x0d(i+1, j+1, 1) = x2d(i+1, j+1, 1) + dotd*norm(1) + dot*&
   &               normd(1)
   x0(i+1, j+1, 1) = x2(i+1, j+1, 1) + dot*norm(1)
   x0d(i+1, j+1, 2) = x2d(i+1, j+1, 2) + dotd*norm(2) + dot*&
   &               normd(2)
   x0(i+1, j+1, 2) = x2(i+1, j+1, 2) + dot*norm(2)
   x0d(i+1, j+1, 3) = x2d(i+1, j+1, 3) + dotd*norm(3) + dot*&
   &               normd(3)
   x0(i+1, j+1, 3) = x2(i+1, j+1, 3) + dot*norm(3)
   END DO
   END DO
   END IF
   END IF
   END DO loopbocos
   END IF
   END SUBROUTINE XHALO_BLOCK_D
