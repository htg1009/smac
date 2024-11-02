/*** this is hwydata.c ***/

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAXLINE 80     /* Maximum line length */
#define MAXINPUT 5000  /* Maximum no. of input lines */
#define NUMVEH 2       /* Number of vehicles */
#define TRAJREC 29     /* Record number of INPUT.DAT trajectory data */
#define INCHES_PER_METER 39.37
#define PI 3.14159

void readSimInput();
void writeHwyFile(char *outputf);

/* Input variables for EDSMAC simulation data */
double time[MAXINPUT]; /* simulation time */
double x[NUMVEH][MAXINPUT];    /* x position */
double y[NUMVEH][MAXINPUT];    /* y position */
double h[NUMVEH][MAXINPUT];    /* heading */
double v[NUMVEH][MAXINPUT];    /* velocity */
double a[NUMVEH][MAXINPUT];    /* acceleration */
  
char aline[MAXLINE];          /* Line of input file */
int simtimes;                 /* Number of sim times */
int itraj;                    /* Trajectory flag(0 or 1) */
double xcir;                  /* longitudinal distance for arc center */
double ycir;                  /* lateral distance for arc center */
double rwyrad;                /* Radius of arc */

int main(int argc,char *argv[])
{
   /* Read simulation data from EDSMAC */
   readSimInput();
   /* Write simulation/snapshot data in Carmma hwy file format */
   writeHwyFile(argv[1]);
}
void readSimInput()
{
   /* Read trajectory data from EDSMAC input file */
   /* Read Simulation Input */
   int i = 0;
   FILE *fpeds;
   FILE *fpinp1, *fpinp2;  

   if(!(fpeds = fopen("INPUT.DAT","r"))){
      printf("Can't open file INPUT.DAT\n");
      exit(0);
   }
   if(!(fpinp1 = fopen("VEH1.DAT","r"))){
      printf("Can't open file VEH1.DAT\n");
      exit(0);
   }
   if(!(fpinp2 = fopen("VEH2.DAT","r"))){
      printf("Can't open file VEH2.DAT\n");
      exit(0);
   }
   
   /* Obtain edsmac trajectory data */
   for (i = 0; i < TRAJREC; i++)
      fgets(aline,MAXLINE,fpeds);
   sscanf(aline,"%d %lf %lf %lf", &itraj,&xcir,&ycir,&rwyrad);
   xcir = xcir / INCHES_PER_METER;
   ycir = ycir / INCHES_PER_METER;
   rwyrad = rwyrad / INCHES_PER_METER;
  
   /* Obtain edsmac simulation data */
   while (fgets(aline,MAXLINE,fpinp1)!=NULL) {
      sscanf(aline,"%lf %*s %lf %lf %lf %lf %lf", &time[i],&x[0][i],&y[0][i],&h[0][i],&v[0][i],&a[0][i]);
      fgets(aline,MAXLINE,fpinp2);
      sscanf(aline,"%*s %*s %lf %lf %lf %lf %lf", &x[1][i],&y[1][i],&h[1][i],&v[1][i],&a[1][i]);
      i++;
   }
   simtimes = i;   /* Number of sim times */
   fclose(fpeds);
   fclose(fpinp1); fclose(fpinp2);
}
void writeHwyFile(char *outputf)
{
   /* Write sim/snapshot data in Carmma hwy file */
   int i = 0;    /* Snapshot index */
   double tdelta = .1; /* time granularity for animation */
   double lasttime;    /* last time snapshot data was produced */
   double yoffset=3.5; /* y offset to put vehicle in middle of lane(Carmma) */
   int numlanes = 1;   /* number of lanes in Carmma */
   int version  = 1;   /* data version */
   int hwylength = 300;/* highway length */
  
   FILE *fpout;
   fpout = fopen(outputf, "w");  /* Open file for Carmma scenario data */
   lasttime = -tdelta;           /* Enables snapshot creation for t=0 */
   fprintf(fpout,"All-Snapshots");
   for (i = 0; i < simtimes; i++)
   {
     /* write snapshot data for each tdelta sec */
     if (time[i] >= lasttime + tdelta)
     {
      lasttime = time[i];
      fprintf(fpout,"%8.4f", time[i]);
     }
   }
   fprintf(fpout,"\n");
   fprintf(fpout,"NumLanes %d\n", numlanes);
   fprintf(fpout,"Data-Version %d\n", version);
   fprintf(fpout,"HighwayLength %d\n", hwylength);
   fprintf(fpout,"Trajectory %d %6.1f %6.1f %6.1f\n",itraj,xcir,ycir,rwyrad);
   
   lasttime = -tdelta;           /* Enables snapshot creation for t=0 */
   for (i = 0; i < simtimes; i++)
   {
     /* write snapshot data for each tdelta sec */
     if (time[i] >= lasttime + tdelta)
     {
      lasttime = time[i];
      fprintf(fpout,"Snapshot %8.4f\n", time[i]);
      fprintf(fpout,"SnapTags  {Car1 Car2}\n");
      fprintf(fpout,"CarPosition Car1\n");
      fprintf(fpout,"CarInformation Car1 %8.2f %8.2f %8.2f %3.5f\n", x[0][i], y[0][i]+yoffset, v[0][i], h[0][i]*PI/180.);
      fprintf(fpout,"CarPosition Car2\n");
      fprintf(fpout,"CarInformation Car2 %8.2f %8.2f %8.2f %3.5f\n", x[1][i], y[1][i]+yoffset, v[1][i], h[1][i]*PI/180.);
      }
   }
   fclose(fpout);
}
