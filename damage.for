
      SUBROUTINE RNGDAM(TRHO,TPSI,TCPSI,TSPSI,JJ9,ROU,PSBOU,XOU,YOU,ASTR
     1  ,PSP,PSDA1,PSDA2,PSIM,INPSM,IKD1,IKD2,NARRP,NUM,IKK,IRNG,IWRAP,
     2                IJ,ISTOP,NDTAB,DELPS,XF,XR,YS,NMSG1,IPRTX)
C      SIMULATION MODEL OF AUTOMOBILE COLLISIONS -SMAC
      DIMENSION  TRHO(1),TPSI(1),TCPSI(1),TSPSI(1),JJ9(1)
C            ABOVE ARE CALLED FROM PROPER BEGINNING IN DOUBLE-DIMENSION
C            ARRAYS, SUCH AS TRHOB(1,1) OR TRHOB(1,2) FOR TRHOB(361,2)
      DIMENSION  ROU(1),PSBOU(1),XOU(1),YOU(1),ASTR(1),PSIM(1),INPSM(1)
      DIMENSION PSP(1),PSDA1(1),PSDA2(1)
      DIMENSION  IKD1(1),IKD2(1),NARRP(1)
      DATA  TWOPI/6.2831853072/,PIO4/0.7853981634/,PIO6/0.5235987756/
      DATA  PIO12/0.2617993878/
      DATA STAR,BLNK/1H*,1H /
C     SAMPLE CALL
C               CALL  RNGDAM(TRHOB(1,1),TPSIB(1,1),TCPSIB(1,1),
C    1     TSPSIB(1,1),J9(1,1),R1OU,PSB1OU,X1OU,Y1OU,ASTR1,PSP1,PSD11,
C    2     PSD21,PSIM1,INPSM1,IKD11,IKD21,NARRP1,NUM1,IK1,IRNG1,IWRAP1,
C    3                IJ,ISTOP,NDTAB,DELPSI,XF1,XR1,YS1,NMSG, IPRTX)
C
C          SUBROUTINE RNGDAM SAVES THE DAMAGE LOCATIONS, DETERMINES THE
C          RANGE OF DAMAGE AND MIDPOINT OF RANGE (UP TO TEN RANGES)
C          AND MATCHES THE MIDPOINT WITH A DAMAGE INDEX 'N' FROM NARRP
C        NMSG1  DATA SET FOR DAMAGE TABLES (FT02) SET IN SUB CNSTNT,
C        RESET IN MAIN PROG AT END OF RUN TO USE FT06
C        IPRTX EQ 2 AT END OF RUN
C        RNGDAM IS CALLED WITH IPRTX EQ 1 WHEN MOVIE NE 0
C        TO PREPARE DAMAGE TABLES FOR WRITING ON TAPE AT EACH TIME POINT
C
      DO  5 K=1,NDTAB
      ASTR(K) = BLNK
      ROU(K)  = 0.0
      PSBOU(K) =0.0
      XOU(K)   =0.0
    5 YOU(K)   =0.0
      IKK = 0
      IK=0
      IWRAP = 0
      IRNG = 0
      ISAVE= 0
C          IJ =1 OR 2, VEHICLE IDENTIFICATION
C           IKK IS THE NUMBER OF DAMAGE POINTS IN ARRAYS ROU,PSBOU,XOU,
C           YOU, AND ASTR
C           ARRAY IKD1 SAVES THE INDEX OF DAMAGE POINTS WHICH BEGIN
C           RANGES OF DAMAGE.  NUMBER OF ENTRIES IS IRNG.
C           ARRAY IKD2 SAVES THE INDEX OF DAMAGE POINTS WHICH END
C           THESE RANGES OF DAMAGE , NUMBER OF ENTRIES IS IRNG.
C           IWRAP INDICATE THAT ONE RANGE PASSES THROUGH FROM 4TH TO 1ST
C             QUADRANT.
C           ISAVE IS SIGNAL THAT A POSSIBLE RANGE HAS BEGUN.
C           FOR VEHICLE DAMAGE INDEX COL 6 AND 7 USE ORIGINAL ENDPOINTS.
C           FOR VEHICLE DAMAGE INDEX COL 3 AND 4 USE ADJUSTED ENDPOINTS.
C           SUBROUTINE ADJEND  COMPUTES ADJUSTED ENDPOINTS
      DO 22 K= 1,NDTAB
      RHTEST = TRHO(K)
      IF(RHTEST) 15,10,10
   10 IK = IK + 1
      IF(ISAVE) 12,11,12
   11 ISAVE = 1
      IRNG = IRNG + 1
      IKD1(IRNG) = IK
   12 ROU(IK) = RHTEST
      PSBOU(IK) = TPSI(K)
      XOU(IK)   = RHTEST * TCPSI(K)
      YOU(IK)   = RHTEST * TSPSI(K)
      IF(JJ9(K)) 13, 22,22
   13 ASTR(IK) = STAR
      GO TO 22
   15 IF(ISAVE) 16,22,16
   16 ISAVE = 0
      IKD2(IRNG) = IK
   22 CONTINUE
      IKK = IK
      IF(IKD2(IRNG)) 24,23,24
   23 IKD2(IRNG) = IKK
   24 IF(PSBOU(IKD1(1)) ) 30,25,30
   25 TTTPSE =PSBOU(IKD2(IRNG))
      TTT = TWOPI - TTTPSE
      IF(ABS(TTT-DELPS) -0.25*DELPS) 26,26,30
   26 IKD1 (1)  =  IKD1(IRNG)
      IKD2 (IRNG) = IKD2(1)
      IWRAP = 1
      IRNG = IRNG - 1
      IF(IRNG -1) 27,30,30
   27 IRNG = 1
C
C             TEMPORARY PRINT
   30 WRITE(NMSG1,628)
  628 FORMAT(42H0 FOLLOWING MESSAGE FROM SUBROUTINE RNGDAM)
      WRITE(NMSG1 ,629) IJ,IJ,IJ,IRNG,IWRAP,(I,IKD1(I),IKD2(I),I=1,IRNG)
  629 FORMAT(9H  VEH.NO.,I2,       7X,2H I,11X,4HIKD1,I1,3H(I),5X,4HIKD2
     1      ,I1,3H(I),6H,IRNG=,I3,5X,7H IWRAP=,I3/(16X,I4,12X,I4,9X,I4))
      IF(IPRTX .LT. 2) RETURN
      JJ=1
      CALL ADJEND(PSBOU, XOU, YOU, ASTR, PSP, PSDA1,XF, XR, YS, IKD1,
     1            IRNG,JJ,IJ)
      JJ=2
      CALL ADJEND(PSBOU, XOU, YOU, ASTR, PSP, PSDA2,XF, XR, YS, IKD2,
     1            IRNG,JJ,IJ)
      IB = 1
      IF(IWRAP) 31,35,31
   31 IF(PSDA1(1) - PIO6) 310,310,311
  310 WRITE(6,6310) PSBOU(IKD1(1)),PSDA1(1),IRNG
 6310 FORMAT(66H0 IN SUBROUTINE RNGDAM,WRAP-AROUND,ORIGINAL BEG PT OF FI
     1RST RANGE=,E13.5, 12H,  ADJ. PT =,E13.5/16H NO WRAP,  IRNG=,I3,
     3  16H LOSES ONE RANGE)
      GO TO 35
C
C  31 PSIM(1) = 0.5*((PSBOU(IKD1(1))- TWOPI) + PSBOU(IKD2(1)))
  311 PSIM(1) = 0.5*((PSDA1(1) - TWOPI) + PSDA2(1))
      IF(PSIM(1) -PIO12) 32,32,33
   32 PSIM(1) = PSIM(1) + TWOPI
   33 IF (IRNG-1) 45,45,34
   34 IB=2
   35 DO 40 I = IB,IRNG
   40 PSIM(I) = 0.5*( PSDA1(I) + PSDA2(I))
C          NUM=0 FROM SUBROUTINE SAVMAX WHEN NO ACCEL .GE. 1.0 G,
C          THEN NARRP AND INPSM NOT EVALUATED
   45 IF(NUM) 46,66,46
   46 DO 65 J= 1,IRNG
      CRIT = 0.0
      PSIMT = PSIM(J)
C                PIO12 RAD = 15 DEG
   48 CRIT = CRIT + PIO12
      IMATCH = 0
      DO 60 I= 1,NUM
      PSTRY = PIO6*FLOAT(NARRP(I))
      TEST = PSIMT - PSTRY
   54 IF( ABS(TEST) - CRIT) 55,55,60
   55 IMATCH = I
      GO TO 64
   60 CONTINUE
      IF(CRIT - PIO4)        48,48,62
C     IF(CRIT -(PIO4-0.0001))48,48,62
   62 ISTOP = 30
      WRITE(6,628)
      WRITE(6,662) ISTOP,IJ,NUM,J,PSIMT,IRNG,PSTRY,TEST,CRIT,
     1             (NARRP(III),III=1,NUM)
  662 FORMAT(8H0 ISTOP=,I3, 26H  NO MATCH FOR VEHICLE NO.,I2,
     1 10H FROM NUM=,I3, 16H VALUES IN NARRP/
     2 10H  AT PSIM(,I3,2H)=, E13.5,11H FROM IRNG=,I3,21H RANGES,  NARRP
     3*PIO6=,E13.5, 7H, TEST=,E13.5, 7H, CRIT=,E13.5 /
     454H USE FIRST VALUE OF NARRP(TESTED AS NARRP*PIO6),NARRP=, 10I4)
      IMATCH = 1
   64 INPSM(J) = IMATCH
C           ARRAY INPSM STORES INDEX OF MATCH FROM NARRP ARRAY
C                      AND IS ITSELF INDEXED TO CORRESPOND TO PSIM ARRAY
   65 CONTINUE
   66 IF(PSIM(1) - TWOPI) 68,67,67
   67 PSIM(1) = PSIM(1) - TWOPI
   68 RETURN
      END
      SUBROUTINE ADJEND(PSBOU,XOU,YOU,ASTR,PSP,PSDD,XF,XR,YS,IKD,IRNG,
     1                   JJ,IJ)
C      SIMULATION MODEL OF AUTOMOBILE COLLISIONS -SMAC
C      FOR VEHICLE DAMAGE INDEX, COLUMNS 3 AND 4
C            JJ=1 FOR BEGINNING OF RANGE, JJ=2 FOR LAST POINT OF RANGE
C            IJ= 1 OR 2, VEHICLE IDENTIFICATION
C            CALL ADJEND FROM SUBROUTINE RNGDAM TWICE,ONCE FOR BEGINNING
C             AND ONCE FOR LAST POINTS.
C             SUBROUTINE RNGDAM IS ITSELF CALLED TWICE,ONCE PER VEHICLE.
C          SAMPLE CALL FOR BEGINNING OF ALL DAMAGE RANGES FOR VEHICLE 1
C     JJ=1
C     CALL ADJEND(PSBOU, XOU, YOU, ASTR, PSP, PSDA1,XF, XR, YS, IKD1,
C    1            IRNG,JJ,IJ)
C          SAMPLE CALL FOR LAST POINT OF ALL DAMAGE RANGES FOR VEHICLE 1
C     JJ=2
C     CALL ADJEND(PSBOU, XOU, YOU, ASTR, PSP, PSDA2,XF, XR, YS, IKD2,
C    1            IRNG,JJ,IJ)
      DIMENSION PSBOU(1),XOU(1),YOU(1),ASTR(1),PSP(1),PSDD(1),IKD(1)
      DATA TWOPI/6.2831853072/
      DATA RAD/0.0174532925/
      DATA NBEG/4H BEG/, NLAST/4HLAST/
      DATA STAR/1H*/
      DO 30 I = 1,IRNG
      II = IKD(I)
      PSD = PSBOU(II)
      IF( ASTR(II) - STAR) 11,12,11
   11 PSDD(I) = PSD
      GO TO 30
   12 IF(PSD - PSP(2)) 14,14,13
   13 IF(PSD - PSP(11)) 15,14,14
   14 PSDTEM = ATAN2(YOU(II), XF)
      GO TO 25
   15 IF(PSD - PSP(5)) 18,16,16
   16 IF(PSD - PSP(8)) 17,17,19
   17 PSDTEM = ATAN2(YOU(II),XR)
      GO TO 25
   18 YSSIDE = YS
      GO TO 20
   19 YSSIDE = - YS
   20 PSDTEM = ATAN2( YSSIDE,XOU(II))
   25 IF(PSDTEM) 26,27,27
   26 PSDTEM = TWOPI + PSDTEM
   27 PSDD(I)  = PSDTEM
   30 CONTINUE
      IF(JJ-1) 35,35,36
   35 NWORD = NBEG
      GO TO 37
   36 NWORD = NLAST
   37 WRITE(6,6038) IJ,NWORD,IRNG
 6038 FORMAT(32H0 MESSAGE FROM SUBROUTINE ADJEND / 2X,8H VEH.NO.,I2,2X,
     1 A4, 11H POINTS FOR , I3, 7H RANGES / 8X,1HI,4X,10H ORIG(DEG),4X,
     2 14H ADJUSTED(DEG) )
      DO 40 I=1,IRNG
      PSDP = PSBOU(IKD(I)) / RAD
      PSDPA = PSDD(I) /RAD
      WRITE(6,6040) I,PSDP,PSDPA
 6040 FORMAT(6X,I3,1X,E13.5,3X,E13.5)
   40 CONTINUE
      RETURN
      END
      SUBROUTINE DAMAGE(PSIM,IRNG ,PSP,PSBOU,XOU,YOU,ASTR,IKD1,IKD2,IKK,
     1                  EXTF,EXTR,EXTB,XF,XR,YS,NCOL3,NCOL4,NCOL6,NCOL7,
     2                  MMM,ISTOP,PSDA1,PSDA2,ARRPSI,INPSM,IJ)
C      SIMULATION MODEL OF AUTOMOBILE COLLISIONS -SMAC
      DIMENSION PSIM(1),PSP(1),PSBOU(1),XOU(1),YOU(1),ASTR(1),IKD1(1)
      DIMENSION  IKD2(1),EXTF(1),EXTR(1),EXTB(1),NCOL3(1),NCOL4(1)
      DIMENSION NCOL6(1),NCOL7(1), MMM(1),PSDA1(1),PSDA2(1)
      DIMENSION ARRPSI(1),INPSM(1)
C        ARRAY NCOL5 IS OMITTED FROM ARG. LIST.   ZEROED IN SUBR.CNSTNT
C             IJ IS VEHICLE  IDENTIFICATION NUMBER, FOR PRINTING
C
C     SAMPLE CALL
C     IJ = 1
C               CALL  DAMAGE(PSIM1,IRNG1,PSP1,PSB1OU,X1OU,Y1OU,ASTR1,
C    1          IKD11,IKD21,IK1,EXTF1,EXTR1,EXTB1,XF1,XR1,YS1,NCOL31,
C    2   NCOL41,NCOL61,NCOL71,MMM,ISTOP,PSD11,PSD21,ARRPS1,INPSM1,IJ)
C
      DATA  MF/1HF/,MR/1HR/,MB/1HB/,ML/1HL/
      DATA MY/1HY/,MD/1HD/, MC/1HC/, MZ/1HZ/, MP/1HP/, MS/1HS/,ME/1HE/
      DATA MN/1HN/,MW/1HW/
      DATA  TWOPI/6.2831853072/
      DATA PI/3.1415926536/
C
      DO  505 I= 1,IRNG
      INDAPS = 0
C
      YMNFUL = 0.0
      YMXFUL = 0.0
      XMNFUL = 0.0
      XMXFUL = 0.0
      IB=IKD1(I)
      IL = IKD2(I)
      IF(IB -IL) 230,505,232
C          DO NOT COMPUTE COLS 3,4,  6,7, FOR RANGES WHICH CONSIST OF A
C                 SINGLE POINT.       IB=IL
  230 IBB = IB
      ILB = IL
      IBE = 0
      ILE = 0
      GO TO 233
  232 IBB = 1
      ILB = IL
      IBE = IB
      ILE = IKK
  233 PSIMT = PSIM(I)
      PSD1 = PSDA1(I)
      PSD2 = PSDA2(I)
      IF(PSD1)241,243,240
  240 IF(PSD1-TWOPI)243,243,241
  241 ISTOP = 41
      GO TO 250
  243 IF(PSD2) 245,247,244
  244 IF(PSD2-TWOPI)247,247,245
  245 ISTOP = 42
      GO TO 250
  247 IF(PSIMT)249,310,248
  248 IF(PSIMT-TWOPI) 251,310,249
  249 ISTOP= 43
  250 WRITE(6,6250) ISTOP, I, PSD1, PSD2 ,PSIMT
 6250 FORMAT(8H0 ISTOP=,I3,5X,3H I=,I3, 5X,6H PSD1=,E13.5,5X,6H PSD2=
     1        E13.5,5X,7H PSIMT=,E13.5)
      GO TO 505
  251 IF(PSD1 - PSP(2)) 253,253,252
  252 IF(PSD1 - PSP(11)) 257,253,253
  253 IF(PSD2 - PSP(2))  255,255,254
  254 IF(PSD2 - PSP(11)) 266,255,255
  255 ICORTB = 0
      GO TO 310
  257 IF(PSD1 - PSP(5))  258,260,260
  258 IF(PSD2 - PSP(2))  266,266,2581
 2581 IF(PSD2 - PSP(5))  259,266,266
  259 ICORTB = 0
      GO TO 320
  260 IF(PSD1 - PSP(8))  261,261,263
  261 IF(PSD2 - PSP(5))  266,2611,2611
 2611 IF(PSD2 - PSP(8))  262,262,266
  262 ICORTB = 0
      GO TO 330
  263 IF(PSD2 - PSP(8)) 266,266,264
  264 IF(PSD2 - PSP(11)) 265,266,266
  265 ICORTB = 0
      GO TO 340
  266 ICORTB = 1
      PSTRY = ARRPSI(INPSM(I)) + PI
 2661 IF(PSTRY) 2662,2665,2663
 2662 PSTRY = PSTRY + TWOPI
      GO TO 2661
C
 2663 IF(PSTRY-TWOPI) 2665,2665,2664
 2664 PSTRY = PSTRY - TWOPI
      GO TO 2663
 2665 PSCRIT = PSIMT - PSTRY
 2670 IF(PSCRIT + PI) 2671,2671,2672
 2671 PFLIP =  TWOPI
      GO TO 2674
 2672 IF(PSCRIT - PI) 2675,2673,2673
 2673 PFLIP = - TWOPI
 2674 PSCRIT = PSCRIT + PFLIP
      GO TO 2670
 2675 PSTEST=PSD2 - PSIMT
 2680 IF(PSTEST + PI) 2681,2681,2682
 2681 PFLIP =  TWOPI
      GO TO 2684
 2682 IF(PSTEST - PI) 2685,2683,2683
 2683 PFLIP = - TWOPI
 2684 PSTEST = PSTEST + PFLIP
      GO TO 2680
 2685 IF(ABS(PSCRIT) - ABS(PSTEST)) 2695,272,272
 2695 IF(ABS(PSCRIT) - 0.242) 272,272,2700
 2700 IF(PSTRY - PSP(2))  2704,2704,2701
 2701 IF(PSTRY - PSP(11)) 2702,2704,2704
 2702 IF(PSTRY - PSP( 5)) 2706,2703,2703
 2703 IF(PSTRY - PSP( 8)) 2708,2708,2710
 2704 IF( PSIMT - PSP( 2)) 310,310,2705
 2705 IF( PSIMT - PSP(11)) 2712,310,310
 2706 IF( PSIMT - PSP( 2)) 2713,2713,2707
 2707 IF( PSIMT - PSP( 5))  320,2713,2713
 2708 IF( PSIMT - PSP( 5)) 2714,2709,2709
 2709 IF( PSIMT - PSP( 8))  330,  330,2714
 2710 IF( PSIMT - PSP(11)) 2711,2715,2715
 2711 IF( PSIMT - PSP( 8)) 2715,2715,340
C       SET INDAPS
 2712 INDAPS = SIGN(1.1,PSCRIT)
      GO TO 310
 2713 INDAPS = SIGN(1.1,PSCRIT)
      GO TO 320
 2714 INDAPS = SIGN(1.1,PSCRIT)
      GO TO 330
 2715 INDAPS = SIGN(1.1,PSCRIT)
      GO TO 340
  272 IF(PSIMT - PSP( 2)) 276,276,273
  273 IF(PSIMT - PSP(11)) 274,277,277
  274 IF(PSIMT - PSP( 5)) 320,275,275
  275 IF(PSIMT - PSP( 8)) 278,278,340
  276 MXMN = -1
      CALL FULSRC( YOU, YMNFUL,IBB,ILB,IBE,ILE,MXMN)
      CALL FULSRC( XOU, XMNFUL,IBB,ILB,IBE,ILE,MXMN)
      IF((YS-YMNFUL) - (XF-XMNFUL)) 2792,310,310
  277 MXMN = + 1
      CALL FULSRC( YOU, YMXFUL,IBB,ILB,IBE,ILE,MXMN)
      MXMN = - 1
      CALL FULSRC( XOU, XMNFUL,IBB,ILB,IBE,ILE,MXMN)
      IF((YS+YMXFUL) - (XF-XMNFUL)) 2793,310,310
  278 IF(PSIMT - PI) 279,330,2791
  279 MXMN = - 1
      CALL FULSRC( YOU, YMNFUL,IBB,ILB,IBE,ILE,MXMN)
      MXMN = + 1
      CALL FULSRC( XOU, XMXFUL,IBB,ILB,IBE,ILE,MXMN)
      IF((YS-YMNFUL) - (XMXFUL-XR)) 2794,330,330
 2791 MXMN = + 1
      CALL FULSRC( YOU, YMXFUL,IBB,ILB,IBE,ILE,MXMN)
      CALL FULSRC( XOU, XMXFUL,IBB,ILB,IBE,ILE,MXMN)
      IF((YS+YMXFUL) - (XMXFUL-XR)) 2795,330,330
 2792 INDAPS= -1
      GO TO 320
 2793 INDAPS= +1
      GO TO 340
 2794 INDAPS= +1
      GO TO 320
 2795 INDAPS= -1
      GO TO 340
C
  310 NCOL3(I) = MF
      WRITE(6,6310) IJ,I,IRNG,IBB,ILB,IBE,ILE,PSD1,PSD2,PSIM(I),PSIMT,
     1 NCOL3(I),ICORTB,INDAPS
 6310 FORMAT(32H0 MESSAGE FROM SUBROUTINE DAMAGE/
     1 2X,7HVEH.NO.,I2,5X, 9H RANGE I=,I2,3H OF,I3,7H RANGES,
     2 12X,4HIBB=,I4,6H, ILB=,I4,2X,5H IBE=,I4,6H, ILE=,I4/
     3 2X,5HPSD1=,E13.5,7H, PSD2=,E13.5,10H, PSIM(I)=,E13.5,
     4 13H, USED PSIMT=,E13.5,5X,10H NCOL3(I)=,A1 ,2X, 9H, ICORTB=,I2/
     5 2X, 8H INDAPS=,I2)
      IF(INDAPS) 311,3100,350
 3100 IF(PSD1  - PSP(1)) 312,3101,3101
 3101 IF(PSD1  - PSP(12))3102,312,312
 3102 IF(PSD1  - PSP( 9))3103,311,311
 3103 NCOL4(I) = MR
      IF(ICORTB) 412,421,412
  311 IF(PSD2  - PSP(1)) 3112,3110,3110
 3110 IF(PSD2  - PSP(12))3114,3114,3112
 3112 NCOL4(I) = MY
      IF(ICORTB) 411,421,411
 3114 IF(PSD2  - PSP(11))3117,3117,3115
 3115 NCOL4(I) = ML
      IF(ICORTB) 414,421,414
 3117 IF(PSD2  - PSP(4)) 3118,3118,3119
 3118 NCOL4(I) = MD
      IF(ICORTB) 411,421,411
 3119 ISTOP = 44
      GO TO 250
  312 IF(PSD2 - PSP(1))  3122,3122,3120
 3120 IF(PSD2 - PSP(12)) 3124,3124,3122
 3122 NCOL4(I) = MC
      IF(ICORTB) 411,421,411
 3124 IF(PSD2 - PSP(4)) 3125,3125,3126
 3125 NCOL4(I) = MZ
      IF(ICORTB) 411,421,411
 3126 ISTOP = 45
      GO TO 250
  320 NCOL3(I) = MR
      WRITE(6,6310) IJ,I,IRNG,IBB,ILB,IBE,ILE,PSD1,PSD2,PSIM(I),PSIMT,
     1 NCOL3(I),ICORTB,INDAPS
      IF(INDAPS) 321,3200,360
 3200 IF(PSD1 - TWOPI) 3202,3201,3201
 3201 ISTOP = 46
      GO TO 250
 3202 IF(PSD1 - PSP(10)) 3203,321,321
 3203 IF(PSD1 - PSP(3)) 321 ,3204,3204
 3204 IF(PSD1 - PSP(4)) 322 , 3205,3205
 3205 NCOL4(I) = MB
      IF(ICORTB) 413,422,413
  321 IF(PSD2 - PSP(2)) 3210,3210,3212
 3210 ISTOP = 47
      GO TO 250
 3212 IF(PSD2 - PSP(3)) 3213,3213,3215
 3213 NCOL4(I) = MF
      IF(ICORTB) 411,422,411
 3215 IF(PSD2 - PSP(4)) 3216,3216,3217
 3216 NCOL4(I) = MY
      IF(ICORTB) 412,422,412
 3217 NCOL4(I) = MD
      IF(ICORTB) 412,422,412
  322 IF(PSD2 - PSP(3)) 3220,3220,3221
 3220 ISTOP = 49
      GO TO 250
 3221 IF(PSD2 - PSP(4)) 3222,3222,3223
 3222 NCOL4(I) = MP
      IF(ICORTB) 412,422,412
 3223 NCOL4(I) = MZ
      IF(ICORTB) 412,422,412
  330 NCOL3(I) = MB
      WRITE(6,6310) IJ,I,IRNG,IBB,ILB,IBE,ILE,PSD1,PSD2,PSIM(I),PSIMT,
     1 NCOL3(I),ICORTB,INDAPS
      IF(INDAPS) 331,3300,370
 3300 IF(PSD1 - PSP(3)) 3301,3302,3302
 3301 ISTOP = 51
      GO TO 250
 3302 IF(PSD1 - PSP(6)) 331 ,3303,3303
 3303 IF(PSD1 - PSP(7)) 332,  3304,3304
 3304 NCOL4(I) = ML
      IF(ICORTB) 414,423,414
  331 IF(PSD2 - PSP(5)) 3310,3310,3311
 3310 ISTOP = 52
      GO TO 250
 3311 IF(PSD2 - PSP(6)) 3312,3312,3313
 3312 NCOL4(I) = MR
      IF(ICORTB) 412,423,412
 3313 IF(PSD2 - PSP(7)) 3314,3314,3315
 3314 NCOL4(I) = MZ
      IF(ICORTB) 413,423,413
 3315 NCOL4(I) = MD
      IF(ICORTB) 413,423,413
  332 IF(PSD2 - PSP(6)) 3320,3320,3321
 3320 ISTOP = 54
      GO TO 250
 3321 IF(PSD2 - PSP(7)) 3322,3322,3323
 3322 NCOL4(I) = MC
      IF(ICORTB) 413,423,413
 3323 NCOL4(I) = MY
      IF(ICORTB) 413,423,413
  340 NCOL3(I) = ML
      WRITE(6,6310) IJ,I,IRNG,IBB,ILB,IBE,ILE,PSD1,PSD2,PSIM(I),PSIMT,
     1 NCOL3(I),ICORTB,INDAPS
      IF(INDAPS) 341,3400,380
 3400 IF(PSD1 - PSP(4)) 3401,3402,3402
 3401 ISTOP = 56
      GO TO 250
 3402 IF(PSD1 - PSP(9)) 341,3403,3403
 3403 IF(PSD1 - PSP(10)) 342,3404,3404
 3404 NCOL4(I) = MF
      IF(ICORTB) 411,424,411
  341 IF(PSD2 -PSP(3)) 3410,3411,3411
 3410 NCOL4(I) = MD
      IF(ICORTB) 414,424,414
 3411 IF(PSD2 - PSP(8)) 3412,3412,3413
 3412 ISTOP = 57
      GO TO 250
 3413 IF(PSD2 - PSP(9)) 3414,3414,3415
 3414 NCOL4(I) = MB
      IF(ICORTB) 413,424,413
 3415 IF(PSD2 - PSP(10)) 3416,3416,3417
 3416 NCOL4(I) = MZ
      IF(ICORTB) 414,424,414
 3417 NCOL4(I) = MD
      IF(ICORTB) 414,424,414
  342 IF(PSD2 - PSP(3)) 3420,3421,3421
 3420 NCOL4(I) = MY
      IF(ICORTB) 414,424,414
 3421 IF(PSD2 - PSP(9)) 3422,3422,3423
 3422 ISTOP = 59
      GO TO 250
 3423 IF(PSD2 - PSP(10)) 3424,3424, 3425
 3424 NCOL4(I) = MP
      IF(ICORTB) 414,424,414
 3425 NCOL4(I) = MY
      IF(ICORTB) 414,424,414
C
  350 IF(PSD1 - PSP(1)) 352,351,351
  351 IF(PSD1 - PSP(12)) 353,352,352
  352 NCOL4(I) = MZ
      GO TO 421
  353 IF(PSD1 - PSP(11)) 355,354,354
  354 NCOL4(I) = MD
      GO TO 421
  355 NCOL4(I) = MR
      GO TO 412
C
  360 IF(PSD1 - PSP(3)) 362,361,361
  361 IF(PSD1 - PSP(4)) 363,364,364
  362 NCOL4(I) = MD
      GO TO 422
  363 NCOL4(I) = MZ
      GO TO 422
  364 NCOL4(I) = MB
      GO TO 413
C
  370 IF(PSD1 -PSP(6)) 372,371,371
  371 IF(PSD1 - PSP(7)) 373,374,374
  372 NCOL4(I) = MD
      GO TO 423
  373 NCOL4(I) = MY
      GO TO 423
  374 NCOL4(I) = ML
      GO TO 414
C
  380 IF(PSD1 - PSP(9)) 382,381,381
  381 IF(PSD1 - PSP(10)) 383,384,384
  382 NCOL4(I) = MD
      GO TO 424
  383 NCOL4(I) = MY
      GO TO 424
  384 NCOL4(I) = MF
      GO TO 411
C
C
  411 IF(NCOL4(I) - MF) 420,4110,420
 4110 NCOLF = 1
      MXMN = -1
      CALL CORSRC (PSBOU,XOU,PSP(2),PSP(11),XMN,IBB,ILB,IBE,ILE,
     1             NCOLF,MXMN)
      DIS = XF -XMN
      GO TO 415
  412 IF(NCOL4(I) - MR) 420,4120,420
 4120 NCOLF = 0
      MXMN = -1
      CALL CORSRC (PSBOU,YOU,PSP(2),PSP( 5),YMN,IBB,ILB,IBE,ILE,
     1             NCOLF,MXMN)
      DIS = YS - YMN
      GO TO 415
  413 IF(NCOL4(I) - MB) 420,4130,420
 4130 NCOLF = 0
      MXMN =  1
      CALL CORSRC (PSBOU,XOU,PSP(5),PSP( 8),XMX,IBB,ILB,IBE,ILE,
     1             NCOLF,MXMN)
      DIS = XMX - XR
      GO TO 415
  414 IF(NCOL4(I) - ML) 420,4140,420
 4140 NCOLF = 0
      MXMN =  1
      CALL CORSRC (PSBOU,YOU,PSP(8),PSP(11),YMX,IBB,ILB,IBE,ILE,
     1             NCOLF,MXMN)
      DIS = YS + YMX
  415 IF(DIS) 4150,4152,4152
 4150 ISTOP = 61
 4151 WRITE(6,6415) ISTOP,DIS
 6415 FORMAT(8H0 ISTOP=,I3,5X,5H DIS=,E13.5,5X,14H SHOULD BE POS  )
      GO TO 505
 4152 IF(DIS -4.5) 4153,4153,4154
 4153 NCOL6(I) = MS
      GO TO 500
 4154 IF(DIS - 16.5) 4155,4155,4156
 4155 NCOL6(I) = ME
      GO TO 500
 4156 NCOL6(I) = MW
      GO TO 500
C
  420 NCOL = NCOL3(I)
      IF(NCOL - MF) 4201,421,4201
 4201 IF(NCOL - MR) 4202,422,4202
 4202 IF(NCOL - MB) 4203,423,4203
 4203 IF(NCOL - ML) 4204,424,4204
 4204 ISTOP = 67
      WRITE(6,6506) ISTOP,I,NCOL
      GO TO 505
  421 DIS = YOU(IL) - YOU(IB)
      GO TO 425
  422 DIS = XOU(IB) - XOU(IL)
      GO TO 425
  423 DIS = YOU(IB) - YOU(IL)
      GO TO 425
  424 DIS = XOU(IL) - XOU(IB)
  425 IF (DIS) 4250,4252,4252
 4250 ISTOP = 62
      GO TO 4151
 4252 IF(DIS - 16.0) 4253,4253,4254
 4253 NCOL6(I) = MN
      GO TO 500
 4254 NCOL6(I) = MW
C
C
  500 NCOL = NCOL3(I)
      IF(NCOL - MF) 5002,5010,5002
 5002 IF(NCOL - MR) 5003,5020,5003
 5003 IF(NCOL - MB) 5004,5030,5004
 5004 IF(NCOL - ML) 5005,5040,5005
 5005 ISTOP = 63
 5006 WRITE(6,6506) ISTOP, I,NCOL
 6506 FORMAT(8H0 ISTOP=,I3,5X,6HNCOL3(,I3,2H)=,A1)
      GO TO 505
 5010 MXMN = -1
      NCOLF = 1
      CALL DEFMJ(PSBOU,XOU,ASTR,PSP(2),PSP(11),XMIN,IKK,IBB,ILB,IBE,ILE,
     1         INDAPS,NCOLF,MXMN)
      EXT = XF - XMIN
      IF(EXT - 0.0) 5011,5011,5013
 5011 ISTOP = 64
 5012 WRITE(6,6501) ISTOP,EXT
 6501 FORMAT(8H0 ISTOP=,I3,5X,4HEXT=,E13.5)
      GO TO 505
 5013 DO 5015 II = 2,9
      IF(EXT -EXTF(II)) 5014,5014,5015
 5014 NCOL7(I) = MMM(II-1)
      GO TO 505
 5015 CONTINUE
      NCOL7(I) = MMM(9)
      GO TO 505
 5020 MXMN = -1
      NCOLF = 0
      CALL DEFMJ(PSBOU,YOU,ASTR,PSP(2),PSP( 5),YMIN,IKK,IBB,ILB,IBE,ILE,
     1         INDAPS,NCOLF,MXMN)
      EXT = YS - YMIN
 5021 IF(EXT) 5022,5022,5023
 5022 ISTOP = 65
      GO TO 5012
 5023 DO 5025 II = 2,9
      IF(EXT - EXTR(II)) 5024,5024,5025
 5024 NCOL7(I) = MMM(II-1)
      GO TO 505
 5025 CONTINUE
      NCOL7(I) = MMM(9)
      GO TO 505
 5030 MXMN = 1
      NCOLF = 0
      CALL DEFMJ(PSBOU,XOU,ASTR,PSP(5),PSP( 8),XMAX,IKK,IBB,ILB,IBE,ILE,
     1         INDAPS,NCOLF,MXMN)
      EXT = XMAX - XR
      IF(EXT) 5031,5031,5032
 5031 ISTOP = 66
      GO TO 5012
 5032 DO 5035 II = 2,9
      IF(EXT - EXTB(II)) 5034,5034,5035
 5034 NCOL7(I) = MMM(II-1)
      GO TO 505
 5035 CONTINUE
      NCOL7(I) = MMM(9)
      GO TO 505
 5040 MXMN = 1
      NCOLF = 0
      CALL DEFMJ(PSBOU,YOU,ASTR,PSP(8),PSP(11),YMAX,IKK,IBB,ILB,IBE,ILE,
     1         INDAPS,NCOLF,MXMN)
      EXT = YS + YMAX
      GO TO 5021
  505 CONTINUE
      RETURN
      END
      SUBROUTINE FULSRC( XXOU,XM,IBB,ILB,IBE,ILE,MXMN)
C      SIMULATION MODEL OF AUTOMOBILE COLLISIONS -SMAC
      DIMENSION XXOU(1)
C
C        SEARCHES FOR MAX  OR MIN OF X OR Y WITHIN THE APPROPRIATE RANGE
C                OF VEHICLE DAMAGE, RANGE NOT LIMITED NOR RESTRICTED
C
C          CHOOSES MAX IF MXMN = +1
C          CHOOSES MIN IF MXMN = -1
C           SAMPLE CALLS
C     MXMN = -1
C     CALL FULSRC( XOU, XMNFUL,IBB,ILB,IBE,ILE,MXMN)
C       XMNFUL IS THE MINIMUM X IN THIS RANGE
C     MXMN = +1
C     CALL FULSRC( YOU, YMXFUL,IBB,ILB,IBE,ILE,MXMN)
C       YMXFUL IS THE MAXIMUM Y IN THIS RANGE
C
      IB = IBB
      IL = ILB
      XMN = -1.E20
      IF(MXMN) 2,3,3
    2 XMN = 1.E20
      GO TO 15
    3 DO 8 II=IB,IL
      IF(XXOU(II) - XMN) 8,5,5
    5 XMN = XXOU(II)
    8 CONTINUE
      IF(IBE) 9,28,9
    9 IF(IB-IBE) 10,28,10
   10 IB = IBE
      IL = ILE
      GO TO 3
C
   15 DO 20 II= IB,IL
      IF(XXOU(II) - XMN) 17,17,20
   17 XMN = XXOU(II)
   20 CONTINUE
      IF(IBE) 21,28,21
   21 IF(IB-IBE) 22,28,22
   22 IB = IBE
      IL = ILE
      GO TO 15
   28 XM = XMN
      RETURN
      END
      SUBROUTINE CORSRC (PPSBOU,XXOU,PSPP1,PSPP2,XM,IBB,ILB,IBE,ILE,
     1                   NCOLF,MXMN)
C      SIMULATION MODEL OF AUTOMOBILE COLLISIONS -SMAC
      DIMENSION PPSBOU(1),XXOU(1)
C
C          CHOOSES MAX IF MXMN = +1
C          CHOOSES MIN IF MXMN = -1
C          SPECIAL LIMIT LOGIC FOR FRONT OF CAR, NCOLF =1
C          OTHER LIMIT LOGIC FOR ALL OTHER CASES, NCOLF=0
C          CALLING PROGRAM SETS NCOLF
C           SAMPLE CALLS
C     NCOLF = 1
C     MXMN = -1
C     CALL CORSRC (PSBOU,XOU,PSP(2),PSP(11),XMN,IBB,ILB,IBE,ILE,
C    1             NCOLF,MXMN)
C     DIS = XF - XMN
C     NCOLF = 0
C     MXMN =  1
C     CALL CORSRC (PSBOU,YOU,PSP(8),PSP(11),YMX,IBB,ILB,IBE,ILE,
C    1             NCOLF,MXMN)
C     DIS = YS + YMX
C
      IB = IBB
      IL = ILB
      XMN = -1.E20
      IF(MXMN) 2,3,3
    2 XMN = 1.E20
    3 DO 25 II = IB,IL
      PSBTT = PPSBOU(II)
      IF(NCOLF) 4,7,4
    4 IF(PSBTT-PSPP1) 10,10,5
    5 IF(PSBTT-PSPP2) 25,10,10
    7 IF(PSBTT - PSPP1) 25,8,8
    8 IF(PSBTT - PSPP2) 10,10,25
   10 IF(MXMN) 11,12,12
   11 IF(XXOU(II) - XMN) 20,20,25
   12 IF(XXOU(II) - XMN) 25,20,20
   20 XMN = XXOU(II)
   25 CONTINUE
      IF(IBE) 26,28,26
   26 IF (IB-IBE) 27,28,27
   27 IB=IBE
      IL = ILE
      GO TO 3
   28 XM = XMN
      RETURN
      END
      SUBROUTINE DEFMJ( PPSBOU,XXOU,ASTRO,PSPP1,PSPP2,XM,IKK,IBB,ILB,
     1         IBE,ILE,INDAPS,NCOLF,MXMN)
C      SIMULATION MODEL OF AUTOMOBILE COLLISIONS -SMAC
      DIMENSION PPSBOU(1),XXOU(1),ASTRO(1)
      DATA STAR/1H*/
C
C          CHOOSES MAX IF MXMN = +1
C          CHOOSES MIN IF MXMN = -1
C           CALLING PROGRAM SETS MXMN
C          SPECIAL LIMIT LOGIC FOR FRONT OF CAR, NCOLF =1
C          OTHER LIMIT LOGIC FOR ALL OTHER CASES, NCOLF=0
C          CALLING PROGRAM SETS NCOLF
C       SAMPLE CALL
C       NCOLF = 1
C     MXMN = -1
C     CALL DEFMJ(PSBOU,XOU,ASTR,PSP(2),PSP(11),XMIN,IKK,IBB,ILB,IBE,ILE,
C    1         INDAPS,NCOLF,MXMN)
C     NCOLF = 0
C     MXMN = -1
C     CALL DEFMJ(PSBOU,YOU,ASTR,PSP(2),PSP( 5),YMIN,IKK,IBB,ILB,IBE,ILE,
C    1         INDAPS,NCOLF,MXMN)
C
      IB = IBB
      IL = ILB
      XMN = -1.E20
      IF(MXMN) 2,3,3
    2 XMN = 1.E20
    3 DO 25 II = IB,IL
      IF(INDAPS) 4,10,4
    4 PSBTT = PPSBOU(II)
      IF(NCOLF) 5,7,5
    5 IF(PSBTT-PSPP1) 10,10,6
    6 IF(PSBTT-PSPP2) 25,10,10
    7 IF(PSBTT - PSPP1) 25,8,8
    8 IF(PSBTT - PSPP2) 10,10,25
   10 IF(ASTRO(II) - STAR) 17,11,17
   11 IIB = II - 1
      IF(IIB) 12,12,13
   12 IIB = 1
   13 IF(ASTRO(IIB) - STAR) 14,17,14
   14 IIL = II + 1
      IF(IIL - IKK) 16,16,15
   15 IIL = IKK
   16 IF(ASTRO(IIL) - STAR) 25,17,25
   17 IF(MXMN) 18,19,19
   18 IF(XXOU(II) - XMN) 20,20,25
   19 IF(XXOU(II) - XMN) 25,20,20
   20 XMN = XXOU(II)
   25 CONTINUE
      IF(IBE) 26,28,26
   26 IF (IB-IBE) 27,28,27
   27 IB=IBE
      IL = ILE
      GO TO 3
   28 XM = XMN
      RETURN
      END
      SUBROUTINE NCOLDV(NARRPS,ARRDV ,MMM,NUM ,JN,ISTOPP,NCOL1P,NCOL2P,
     1                  DVSUMM)
C      SIMULATION MODEL OF AUTOMOBILE COLLISIONS - SMAC
C      COMPUTES NCOL1,NCOL2 - THE FIRST TWO COLUMNS OF VDI
C      SUMS DELTA V IF SEVERAL CLOCK DIRECTIONS(NARRPS) SEEM TO OCCUR
C      WITHIN ONE RANGE OF DAMAGE.
C
C      SAMPLE CALL FROM SUBROUTINE OUT2
C     JNCOL = INPSM1(I)
C     CALL NCOLDV(NARRP1,ARRDV1,MMM,NUM1,JNCOL,ISTOPP,NCOL1,NCOL2,DVSUM)
C
      DIMENSION NARRPS(1),ARRDV(1),MMM(1)
      DATA MZERO/1H0/,M1/1H1/
      ISTOPP = 0
      DVSUMM = ARRDV(JN)
      NCOL = NARRPS(JN)
      NCOL1P = MZERO
      IF(NCOL-9) 66,66,65
   65 NCOL1P = M1
      NCOL = NCOL - 10
   66 IF(NCOL) 67,69,70
   67 ISTOPP = 1
      GO TO 95
   69 NCOL2P = MZERO
      GO TO 80
   70 DO 72 J = 1,9
      IF(NCOL - J) 72,71,72
   71 NCOL2P = MMM(J)
      GO TO 80
   72 CONTINUE
   80 IF(NUM-1) 95,95,81
   81 NCOL = NARRPS(JN)
      NCOLP = NCOL+1
      IF(NCOLP - 12) 83,83,82
   82 NCOLP = 1
   83 NCOLM = NCOL-1
      IF(NCOLM) 84,84,85
   84 NCOLM = 12
   85 DO 90 J = 1,NUM
      IF( J-JN) 86,90,86
   86 NTRY = NARRPS(J)
      IF (NTRY - NCOL) 87,89,87
   87 IF (NTRY - NCOLP) 88,89,88
   88 IF(NTRY - NCOLM) 90,89,90
   89 DVSUMM = DVSUMM + ARRDV(J)
   90 CONTINUE
   95 RETURN
      END
