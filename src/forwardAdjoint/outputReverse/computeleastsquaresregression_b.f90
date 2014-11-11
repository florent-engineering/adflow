   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.10 (r5363) -  9 Sep 2014 09:53
   !
   !  Differentiation of computeleastsquaresregression in reverse (adjoint) mode (with options i4 dr8 r8 noISIZE):
   !   gradient     of useful results: m y b
   !   with respect to varying inputs: y
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          computeLeastSquaresRegression.f90               *
   !      * Author:        C.A.(Sandy) Mader                               *
   !      * Starting date: 10-14-2009                                      *
   !      * Last modified: 10-14-2009                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE COMPUTELEASTSQUARESREGRESSION_B(y, yb, x, npts, m, mb, b, bb)
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Computes the slope of best fit for a set of x,y data of length *
   !      * npts                                                           *
   !      *                                                                *
   !      ******************************************************************
   !
   USE PRECISION
   IMPLICIT NONE
   !Subroutine arguments 
   INTEGER(kind=inttype) :: npts
   REAL(kind=realtype), DIMENSION(npts) :: x, y
   REAL(kind=realtype), DIMENSION(npts) :: yb
   REAL(kind=realtype) :: m, b
   REAL(kind=realtype) :: mb, bb
   !local variables
   REAL(kind=realtype) :: sumx, sumy, sumx2, sumxy
   REAL(kind=realtype) :: sumyb, sumxyb
   INTEGER(kind=inttype) :: i
   REAL(kind=realtype) :: tempb0
   REAL(kind=realtype) :: tempb
   !begin execution
   sumx = 0.0
   sumx2 = 0.0
   DO i=1,npts
   sumx = sumx + x(i)
   sumx2 = sumx2 + x(i)*x(i)
   END DO
   tempb0 = mb/(npts*sumx2-sumx**2)
   tempb = bb/(npts*sumx2-sumx**2)
   sumyb = sumx2*tempb - sumx*tempb0
   sumxyb = npts*tempb0 - sumx*tempb
   DO i=npts,1,-1
   yb(i) = yb(i) + sumyb + x(i)*sumxyb
   END DO
   END SUBROUTINE COMPUTELEASTSQUARESREGRESSION_B