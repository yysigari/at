/* 
   track.cc
   tracking routines for exact Hamiltonian from Forest / PTC / Tracy-3
   James Rowland 2010
*/

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "track.h"

#define TPSA_MODE

#ifdef AT_MODE
#undef TPSA_MODE
#endif

#ifdef TPSA_MODE
#include <adolc/adolc.h>
#endif

#undef DEBUG_MODE

#ifdef DEBUG_MODE
#define Log(x) printf x
#else
#define Log(x)
#endif

/* Forest-Ruth 4th order coefficients
   could also use 6th order Yoshida */

#define INT_ORDER 4

/*

Generated by:

#!/usr/bin/env python
c1 = c4 = 1.0/(2.0*(2.0-2.0**(1.0/3.0)))
c2 = c3 = (1-2**(1.0/3.0))/(2.0*(2.0-2.0**(1.0/3.0)))
d1 = d3 = 1.0/(2.0-2.0**(1.0/3.0))
d2 = -(2**(1.0/3.0)/(2.0-2.0**(1.0/3.0)))
d4 = 0
print "double c[] = {% .17f, % .17f, % .17f, % .17f};" % (c1, c2, c3, c4)
print "double d[] = {% .17f, % .17f, % .17f, % .17f};" % (d1, d2, d3, d4)

*/

double c[] = { 0.67560359597982889, -0.17560359597982883, -0.17560359597982883,  0.67560359597982889};
double d[] = { 1.35120719195965777, -1.70241438391931532,  1.35120719195965777,  0.00000000000000000};

/* phase space indices */

enum
{
    x_ = 0,
    px_,
    y_,
    py_,
    delta_,
    ct_
};

template<typename T> void multipole_fringe(element * e,
    T * x, double L, double * F, int nF, int edge)
{
    // PTC multipole_fringer
    // Forest 13.29
    // not re-derived and checked
    // note this is the sum over n of Forest 13.29
    // one for each multipole component
    
    T I, U, V, DU, DV, DUX, DVX, DUY, DVY, 
        FX, FY, FX_X, FX_Y, FY_X, FY_Y, 
        RX, IX, DRX, DIX;
    
    if(edge == 0)
    {
        I = 1;
    }
    else
    {
        I = -1;
    }
    
    FX = 0;
    FY = 0;
    FX_X = 0;
    FX_Y = 0;
    FY_X = 0;
    FY_Y = 0;
    
    RX = 1.0;
    IX = 0.0;
    
    // invariant is (j is the index, i is the complex unit)
    // RX+IXi = (x + iy)^j
    for(int n = 0; n < nF; n++)
    {
        
        double B = F[2 * n];
        double A = F[2 * n + 1];
        
        int j = n + 1;
        
        DRX = RX;
        DIX = IX;

        // complex muls

        RX = DRX * x[x_] - DIX * x[y_];
        IX = DRX * x[y_] + DIX * x[x_];
        
        if(j == 1 && e->type == dipole)
        {
            U  =         - A * IX;
            V  =         + A * RX;
            DU =         - A * DIX;
            DV =         + A * DRX;
        }
        else
        {
            U  = B * RX  - A * IX;
            V  = B * IX  + A * RX;
            DU = B * DRX - A * DIX;
            DV = B * DIX + A * DRX;
        }

        T f1 = -I / 4.0 / (j + 1);

        U  = U  * f1;
        V  = V  * f1;
        DU = DU * f1;
        DV = DV * f1;

        DUX =  j * DU;
        DVX =  j * DV;
        DUY = -j * DV;
        DVY =  j * DU;

        double nf = 1.0 * (j + 2) / j;
        
        FX += U * x[x_] + nf * V * x[y_];
        FY += U * x[y_] - nf * V * x[x_];

        FX_X += DUX * x[x_] + U      + nf * x[y_] * DVX;
        FX_Y += DUY * x[x_] + nf * V + nf * x[y_] * DVY;

        FY_X += DUX * x[y_] - nf * V - nf * x[x_] * DVX;
        FY_Y += DUY * x[y_] + U      - nf * x[x_] * DVY;

    }

    T DEL = 1.0 / (1 + x[delta_]);

    // solve 2x2 matrix equation

    T A = 1 -FX_X * DEL;
    T B =   -FY_X * DEL;
    T D = 1 -FY_Y * DEL;
    T C =   -FX_Y * DEL;

    x[x_] = x[x_] - FX * DEL;
    x[y_] = x[y_] - FY * DEL;

    T pxf = (D * x[px_] - B * x[py_]) / (A * D - B * C);
    T pyf = (A * x[py_] - C * x[px_]) / (A * D - B * C);
    x[py_]      = pyf;
    x[px_]      = pxf;
    x[ct_]      = x[ct_] - (x[px_] * FX + x[py_] * FY) * DEL * DEL;
}

template<typename T> T pow2(T x)
{
    return x * x;
}

/* this is the z momentum */
template<typename T> T get_pz(T * x)
{
    return sqrt(pow2(1 + x[delta_]) - pow2(x[px_]) - pow2(x[py_]));
}

/* Forest 10.26, layout rotation
   phi: angle [rad]
*/
template <typename T> void Yrot(double phi, T * x)
{
    T c, s;
    c = cos(phi);
    s = sin(phi);
    T x1[6] = {x[0], x[1], x[2], x[3], x[4], x[5]};
    T ps = get_pz(x); 
    T p = c*ps - s*x1[px_];
    x[x_] = x1[x_]*ps/p;
    x[px_] = s*ps + c*x1[px_];
    x[y_] += x1[x_]*x1[py_]*s/p;
    x[ct_] += (1.0+x1[delta_])*x1[x_]*s/p;
}

/* Forest 10.23, exact drift
   L: length [m]
*/
template<typename T> void exact_drift(T * x, double L)
{
    T u = L / get_pz(x);
    x[x_] += x[px_] * u;
    x[y_] += x[py_] * u;
    x[ct_] += u * (1.0 + x[delta_]);
}

/* Forest-Ruth 4th order integrator
   x      : phase space (inout)
   L      : length
   F      : multipole coefficients
   nf     : length of F
   slices : number of integration steps
*/

template<typename T> void fr4(T * x, double L, double * F, int nF, int slices)
{
    double ds = L / slices;
    T psi = (1 + x[delta_]);
    int max_order = nF - 1;
    int s, n, i;

    for(s = 0; s < slices; s++)
    {
        for(n = 0; n < INT_ORDER; n++)
        {
            exact_drift(x, c[n] * ds);
            
            /* multipole summation with horner's rule
               
            scaled field = sum_n (b_n+ia_n) (x+iy)^n
            
            */

            /* 
               C99 complex numbers don't work in C++
               forget the C++ complex class 
               complex double f = F[max_order];
               complex double z = x[x_] + x[y_] * I;
            */
            
            T fr = F[2 * max_order];
            T fi = F[2 * max_order + 1];
            
            for(i = max_order - 1; i >= 0; i--)
            {
                /*
                  complex multiplication
                  f = f * z + F[i];
                */
                T temp1 = fr * x[x_] - fi * x[y_];
                T temp2 = fr * x[y_] + fi * x[x_];
                fr = temp1 + F[2 * i];
                fi = temp2 + F[2 * i + 1];
            }

            x[px_] -= d[n] * ds *  fr;
            x[py_] -= d[n] * ds * -fi;

        }
    }

}

/* bend fringe */

/* add these definitions to match Mathematica output */

#define ArcTan atan
#define Power pow

template <typename T> T Sec(T x)
{
    return 1.0 / cos(x);
}

template<typename T> void bend_fringe(T * x, double irho, double gK)
{

    T dpx, dpy, dd, b0, px, py, pz, g, K, d, phi, xp, yp, yf, xf, lf, pyf;
    
    b0 = irho;

    /* gK always multiplied together so put everything in g and set K to one */

    K = 1.0;
    g = gK;

    pz = get_pz(x);
    px = x[px_];
    py = x[py_];
    d  = x[delta_];
    xp = px / pz;
    yp = py / pz;

    phi = -b0 * tan( b0 * g * K * (1 +    pow2(xp)*(2 + pow2(yp)))*pz - atan(xp / (1 + pow2(yp))));

    /* these are the partial derivatives of phi with respect to px, py and delta
       total horror from Mathematica. This could benefit from some mini-TPSA */

    dpx = -((b0*(Power(px,2)*Power(pz,4)*(Power(py,2) - Power(pz,2)) - Power(pz,6)*(Power(py,2) + Power(pz,2)) + 
                 b0*g*K*px*(Power(pz,2)*Power(Power(py,2) + Power(pz,2),2)*(2*Power(py,2) + 3*Power(pz,2)) + Power(px,4)*(3*Power(py,2)*Power(pz,2) + 2*Power(pz,4)) + 
                            Power(px,2)*(3*Power(py,6) + 8*Power(py,4)*Power(pz,2) + 9*Power(py,2)*Power(pz,4) + 5*Power(pz,6))))*
             Power(Sec((b0*g*K*(Power(pz,4) + Power(px,2)*(Power(py,2) + 2*Power(pz,2))))/Power(pz,3) - ArcTan((px*pz)/(Power(py,2) + Power(pz,2)))),2))/
            (Power(pz,5)*(Power(py,4) + Power(px,2)*Power(pz,2) + 2*Power(py,2)*Power(pz,2) + Power(pz,4))));


    dpy = -((b0*py*(px*Power(pz,4)*(Power(py,2) + Power(pz,2)) + b0*g*K*(-(Power(pz,4)*Power(Power(py,2) + Power(pz,2),2)) + 
                                                                         Power(px,4)*(3*Power(py,2)*Power(pz,2) + 4*Power(pz,4)) + 
                                                                         Power(px,2)*(3*Power(py,6) + 10*Power(py,4)*Power(pz,2) + 11*Power(py,2)*Power(pz,4) + 3*Power(pz,6))))*
             Power(Sec((b0*g*K*(Power(pz,4) + Power(px,2)*(Power(py,2) + 2*Power(pz,2))))/Power(pz,3) - ArcTan((px*pz)/(Power(py,2) + Power(pz,2)))),2))/
            (Power(pz,5)*(Power(py,4) + Power(px,2)*Power(pz,2) + 2*Power(py,2)*Power(pz,2) + Power(pz,4))));
         
    dd = (b0*(1 + d)*(px*Power(pz,4)*(Power(py,2) - Power(pz,2)) + b0*g*K*
                      (-(Power(pz,4)*Power(Power(py,2) + Power(pz,2),2)) + Power(px,4)*(3*Power(py,2)*Power(pz,2) + 2*Power(pz,4)) + 
                       Power(px,2)*(3*Power(py,6) + 8*Power(py,4)*Power(pz,2) + 7*Power(py,2)*Power(pz,4) + Power(pz,6))))*
          Power(Sec((b0*g*K*(Power(pz,4) + Power(px,2)*(Power(py,2) + 2*Power(pz,2))))/Power(pz,3) - ArcTan((px*pz)/(Power(py,2) + Power(pz,2)))),2))/
        (Power(pz,5)*(Power(py,4) + Power(px,2)*Power(pz,2) + 2*Power(py,2)*Power(pz,2) + Power(pz,4)));

    /* solve quadratic equation in yf (Forest fringe_part_I.pdf) */

    yf = (2 * x[y_]) / (1 + sqrt(1 - 2 * dpy * x[y_]));
    xf = x[x_] + 0.5 * dpx * pow2(yf);
    lf = x[ct_] - 0.5 * dd * pow2(yf);
    pyf = py - phi * yf;
    
    x[y_]  = yf;
    x[x_]  = xf;
    x[py_] = pyf;
    x[ct_] = lf;
    
}

template <typename T> void bend(element * e, T * x, double L, double phi, double gK, 
                                double * F, int nF, int slices)
{
    double irho = phi / L;
    /* convert arc length to rectangular length */
    double LR = 2 / irho * sin(phi / 2.0);
    Yrot(phi / 2, x);
    bend_fringe(x, F[0], gK);
    if(e->do_multipole_fringe)
    {
        multipole_fringe(e, x, LR, e->F, e->nF, 0);
    }
    fr4(x, LR, F, nF, slices);
    if(e->do_multipole_fringe)
    {
        multipole_fringe(e, x, LR, e->F, e->nF, 1);
    }
    bend_fringe(x, -F[0], gK);
    Yrot(phi / 2, x);
}

template<typename T> void track_element(T * x, element * e)
{
    Log(("track element\n"));
    switch(e->type)
    {
    case drift:
        Log(("drift %f\n", e->L));
        exact_drift(x, e->L);
        x[ct_] -= e->L;
        break;
    case dipole:
        Log(("bend %f %f %f\n", e->L, e->phi, creal(e->F[0])));
        bend(e, x, e->L, e->phi, e->gK, e->F, e->nF, e->slices);
        x[ct_] -= e->L;
        break;
    case multipole:
        Log(("multipole %f %f\n", e->L, creal(e->F[1])));
        if(e->do_multipole_fringe)
        {
            multipole_fringe(e, x, e->L, e->F, e->nF, 0);
        }
        fr4(x, e->L, e->F, e->nF, e->slices);
        if(e->do_multipole_fringe)
        {
            multipole_fringe(e, x, e->L, e->F, e->nF, 1);
        }
        x[ct_] -= e->L;
        break;
    case marker:
        Log(("marker\n"));
        break;
    default:
        Log(("unknown element\n"));
        exit(1);
    }
}

template <typename T> void track_lattice_polymorphic(T * x, lattice * lat)
{
    Log(("track_lattice_polymorpic %d\n", lat->N));
    int n;
    for(n = 0; n < lat->N; n++)
    {
        track_element(x, lat->next + n);
        Log(("%e %e %e %e %e %e\n", x[0], x[1], x[2], x[3], x[4], x[5]));
    }
}

extern "C" long binomi2(int n, int k) {
    long double accum = 1;
    unsigned int i;

    if (k > n)
        return 0;

    if (k > n/2)
        k = n-k;

    for (i = 1; i <= k; i++)
         accum = accum * (n-k+i) / i;

    /* was missing the outer cast in the original
       possible bug? */
    return (long)((long) accum + 0.5);
}

extern "C" int address2( int d, int* im ) {
    int i,
    add = 0;

    for (i=0; i<d; i++)
        add += binomi2(im[i]+i,i+1);
    return add;
}

#ifdef TPSA_MODE

extern "C" void track_map(double * x, lattice * lat, double * map1)
{

    int i;
    /* input vector */
    adouble xp[6];
    double x0[6];
    /* tape tag */
    int tag = 1;
    /* number of dependent variables */
    int m = 6;
    /* number of independent variables */
    int n = 6;
    /* order of derivative */
    int d = 2;
    /* number of derivative directions */
    int p = n;
    /* size of map */
    int sz = 0;

    /* size is the binomial number */
    sz = binomi(p+d, d);
    
    /* start tracing arithmetic */
    trace_on(tag);
        
    for(i = 0; i < 6; i++) 
    { 
        /* save initial values */
        x0[i] = x[i];
        /* specify the input variables */
        xp[i] <<= x[i]; 
    }
        
    track_lattice_polymorphic(xp, lat);

    /* specify the output variables */
    for(i = 0; i < 6; i++) { xp[i] >>= x[i]; }

    /* finish the tracing tape */
    trace_off(tag);

    /* allocate outputs */
        
    double *S[n];
    double *tensor[m];
    
    double tensor_storage[m][sz];
    double S_storage[n][p];
    
    int j = 0;
    for(int i = 0; i < m; i++)
    {
        tensor[i] = map1 + j;
        j += sz;
    }

    for(int i = 0; i < n; i++)
    {
        S[i] = S_storage[i];
    }
        
    /* select full tensor of partial derivatives */
    for(int i = 0; i < n; ++i)
    {
        for(int j = 0; j < p; ++j)
            S[i][j] = 0.0;
        S[i][i] = 1.0;
    }

    /* run tape to build derivative tensor */
    tensor_eval(tag, m, n, d, p, x0, tensor, S);

}

#else

extern "C" void track_map(double * x, lattice * lat, double * map1)
{
    fprintf(stderr, "track_map is not available, rebuild with #define TPSA_MODE\n");
    exit(1);
}

#endif

extern "C" void track_lattice(double * x, lattice * lat, int turns)
{
    for(int n = 0; n < turns; n++)
    {
        track_lattice_polymorphic(x, lat);
    }
}
