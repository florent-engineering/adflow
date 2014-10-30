   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.10 (r5363) -  9 Sep 2014 09:53
   !
   !  Differentiation of bceddynowall in forward (tangent) mode (with options i4 dr8 r8):
   !   variations   of useful results: *rev
   !   with respect to varying inputs: *rev
   !   Plus diff mem management of: rev:in bcdata:in
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          bcEddyNoWall.f90                                *
   !      * Author:        Georgi Kalitzin, Edwin van der Weide            *
   !      * Starting date: 06-11-2003                                      *
   !      * Last modified: 04-11-2005                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE BCEDDYNOWALL_D(nn)
   !
   !      ******************************************************************
   !      *                                                                *
   !      * bcEddyNoWall sets the eddy viscosity in the halo cells of      *
   !      * subface nn of the block given in blockPointers. The boundary   *
   !      * condition on the subface can be anything but a viscous wall.   *
   !      * A homogeneous neumann condition is applied, which means that   *
   !      * the eddy viscosity is simply copied from the interior cell.    *
   !      *                                                                *
   !      ******************************************************************
   !
   USE BLOCKPOINTERS_D
   USE BCTYPES
   IMPLICIT NONE
   !
   !      Subroutine arguments.
   !
   INTEGER(kind=inttype), INTENT(IN) :: nn
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: i, j
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rev1, rev2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rev1d, rev2d
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Determine the face id on which the subface is located and
   ! set the pointers rev1 and rev2 accordingly.
   SELECT CASE  (bcfaceid(nn)) 
   CASE (imin) 
   rev1d => revd(1, 1:, 1:)
   rev1 => rev(1, 1:, 1:)
   rev2d => revd(2, 1:, 1:)
   rev2 => rev(2, 1:, 1:)
   CASE (imax) 
   rev1d => revd(ie, 1:, 1:)
   rev1 => rev(ie, 1:, 1:)
   rev2d => revd(il, 1:, 1:)
   rev2 => rev(il, 1:, 1:)
   CASE (jmin) 
   rev1d => revd(1:, 1, 1:)
   rev1 => rev(1:, 1, 1:)
   rev2d => revd(1:, 2, 1:)
   rev2 => rev(1:, 2, 1:)
   CASE (jmax) 
   rev1d => revd(1:, je, 1:)
   rev1 => rev(1:, je, 1:)
   rev2d => revd(1:, jl, 1:)
   rev2 => rev(1:, jl, 1:)
   CASE (kmin) 
   rev1d => revd(1:, 1:, 1)
   rev1 => rev(1:, 1:, 1)
   rev2d => revd(1:, 1:, 2)
   rev2 => rev(1:, 1:, 2)
   CASE (kmax) 
   rev1d => revd(1:, 1:, ke)
   rev1 => rev(1:, 1:, ke)
   rev2d => revd(1:, 1:, kl)
   rev2 => rev(1:, 1:, kl)
   END SELECT
   ! Loop over the faces of the subface and set the eddy
   ! viscosity in the halo cells.
   DO j=bcdata(nn)%jcbeg,bcdata(nn)%jcend
   DO i=bcdata(nn)%icbeg,bcdata(nn)%icend
   rev1d(i, j) = rev2d(i, j)
   rev1(i, j) = rev2(i, j)
   END DO
   END DO
   END SUBROUTINE BCEDDYNOWALL_D
