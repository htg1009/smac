/*** this is SMACposvel.c ***/

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define MAXLINE 80     /* Maximum line length */
#define NUMREC  31     /* SMAC file number of records */
#define INCHES_PER_METER  39.37

void writeSMAC();

/* Input variables for vehicles 1-2 position/velocity */
double v1x;    /* x position - meters */
double v1y;    /* y position - meters */
double v1vlo;  /* long velocity - m/sec */
double v1vla;  /* lat velocity - m/sec */
double v2x;    /* x position - meters */
double v2y;    /* y position - meters */
double v2vlo;  /* long velocity - m/sec */
double v2vla;  /* lat velocity - m/sec */

/* Output variables used for EDSMAC input file data */
double ev1x;    /* x position - inches */
double ev1y;    /* y position - inches */
double ev1vlo;  /* long velocity - i/sec */
double ev1vla;  /* lat velocity - i/sec */
double ev2x;    /* x position - inches */
double ev2y;    /* y position - inches */
double ev2vlo;  /* long velocity - i/sec */
double ev2vla;  /* lat velocity - i/sec */
  
char aline[NUMREC][MAXLINE];          /* Lines of input file */
char input[MAXLINE];          /* Input from user */

int main(int argc,char *argv[])
{
   /* Obtain position/velocity data from user */
   printf("Vehicle 1 x position(meters)\n");
   gets(input);
   v1x = atof(input);
   printf("Vehicle 1 y position(meters)\n");
   gets(input);
   v1y = atof(input);
   printf("Vehicle 1 long velocity(meters/sec)\n");
   gets(input);
   v1vlo = atof(input);
   printf("Vehicle 1 lat velocity(meters/sec)\n");
   gets(input);
   v1vla = atof(input);
   printf("Vehicle 2 x position(meters)\n");
   gets(input);
   v2x = atof(input);
   printf("Vehicle 2 y position(meters)\n");
   gets(input);
   v2y = atof(input);
   printf("Vehicle 2 long velocity(meters/sec)\n");
   gets(input);
   v2vlo = atof(input);
   printf("Vehicle 2 lat velocity(meters/sec)\n");
   gets(input);
   v2vla = atof(input);
   
   /* Write position/velocity data in EDSMAC input file */
   writeSMAC();
}
void writeSMAC()
{
   int i;           /* Index for EDSMAC input file records */
   FILE *fpout;
   int v1ind = 2;   /* EDSMAC input file record for veh 1 */
   int v2ind = 3;   /* EDSMAC input file record for veh 2 */
                    /* position/velocity data is in records 2-3 */
   
   ev1x = v1x * INCHES_PER_METER;
   ev1y = v1y * INCHES_PER_METER;
   ev1vlo = v1vlo * INCHES_PER_METER;
   ev1vla = v1vla * INCHES_PER_METER;
   ev2x = v2x * INCHES_PER_METER;
   ev2y = v2y * INCHES_PER_METER;
   ev2vlo = v2vlo * INCHES_PER_METER;
   ev2vla = v2vla * INCHES_PER_METER;
   
   fpout = fopen("INPUT.DAT", "r");  /* Open file for SMAC data */
   
   for (i = 0; i < NUMREC; i++)
      fgets(aline[i], MAXLINE, fpout);
   fclose(fpout);
   
   fpout = fopen("INPUT.DAT", "w");  /* Open file for SMAC data rewrite */
   
   fputs(aline[0], fpout);
   fputs(aline[1], fpout);
   fputs(aline[2], fpout);
   /* v1ind + 1 = 3 since the count is from 0 */
   sprintf(aline[3],"%5.1f  %5.1f    %3.1f     %3.1f     %5.1f %5.1f                             %1d\n", ev1x, ev1y, .0, .0, ev1vlo, ev1vla, v1ind);
   fputs(aline[3], fpout);
   /* v2ind + 1 = 4 since the count is from 0 */
   sprintf(aline[4],"%5.1f  %5.1f    %3.1f     %3.1f     %5.1f %5.1f                             %1d\n", ev2x, ev2y, .0, .0, ev2vlo, ev2vla, v2ind);
   fputs(aline[4], fpout);
   for (i = 5; i < NUMREC; i++)
      fputs(aline[i], fpout);
   fclose(fpout);
}
