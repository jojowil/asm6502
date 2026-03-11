30 rem set clock
40 input "am or pm (one letter)";ap$
50 if ap$<>"a" and ap$<>"p" then 40
60 ap=0:if ap$="p"then ap=128
70 input "hours  (0-12):   ";h
80 if h<0 or h>12 then 70
90 h1%=h/10:h2=h-h1%*10:h3=h1%*16+h2+ap
100 poke 56331,h3
110 input "minutes(0-59): ";m
120 if m<0 or m>59 then 110
130 m1%=m/10:m2=m-m1%*10:m3=m1%*16+m2
140 poke 56330,m3
150 input "seconds(0-59): ";s
160 if s<0 or m>59 then 150
170 s1%=s/10:s2=s-s1%*10:s3=s1%*16+s2
180 poke 56329,s3
190 rem start clock
200 poke 56328,0