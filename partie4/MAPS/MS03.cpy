       01  MAP03LI.
           02  FILLER PIC X(12).
           02  L-LOGINL    COMP  PIC  S9(4).
           02  L-LOGINF    PICTURE X.
           02  FILLER REDEFINES L-LOGINF.
             03 L-LOGINA    PICTURE X.
           02  FILLER   PICTURE X(1).
           02  L-LOGINI  PIC X(8).
           02  L-PASSWDL    COMP  PIC  S9(4).
           02  L-PASSWDF    PICTURE X.
           02  FILLER REDEFINES L-PASSWDF.
             03 L-PASSWDA    PICTURE X.
           02  FILLER   PICTURE X(1).
           02  L-PASSWDI  PIC X(8).
           02  L-MSGL    COMP  PIC  S9(4).
           02  L-MSGF    PICTURE X.
           02  FILLER REDEFINES L-MSGF.
             03 L-MSGA    PICTURE X.
           02  FILLER   PICTURE X(1).
           02  L-MSGI  PIC X(78).
       01  MAP03LO REDEFINES MAP03LI.
           02  FILLER PIC X(12).
           02  FILLER PICTURE X(3).
           02  L-LOGINC    PICTURE X.
           02  L-LOGINO  PIC X(8).
           02  FILLER PICTURE X(3).
           02  L-PASSWDC    PICTURE X.
           02  L-PASSWDO  PIC X(8).
           02  FILLER PICTURE X(3).
           02  L-MSGC    PICTURE X.
           02  L-MSGO  PIC X(78).
       01  MAP03PI.
           02  FILLER PIC X(12).
           02  I-PARTNOL    COMP  PIC  S9(4).
           02  I-PARTNOF    PICTURE X.
           02  FILLER REDEFINES I-PARTNOF.
             03 I-PARTNOA    PICTURE X.
           02  FILLER   PICTURE X(1).
           02  I-PARTNOI  PIC X(3).
           02  I-NAMEL    COMP  PIC  S9(4).
           02  I-NAMEF    PICTURE X.
           02  FILLER REDEFINES I-NAMEF.
             03 I-NAMEA    PICTURE X.
           02  FILLER   PICTURE X(1).
           02  I-NAMEI  PIC X(20).
           02  I-COLORL    COMP  PIC  S9(4).
           02  I-COLORF    PICTURE X.
           02  FILLER REDEFINES I-COLORF.
             03 I-COLORA    PICTURE X.
           02  FILLER   PICTURE X(1).
           02  I-COLORI  PIC X(10).
           02  I-WEIGHTL    COMP  PIC  S9(4).
           02  I-WEIGHTF    PICTURE X.
           02  FILLER REDEFINES I-WEIGHTF.
             03 I-WEIGHTA    PICTURE X.
           02  FILLER   PICTURE X(1).
           02  I-WEIGHTI  PIC X(3).
           02  I-CITYL    COMP  PIC  S9(4).
           02  I-CITYF    PICTURE X.
           02  FILLER REDEFINES I-CITYF.
             03 I-CITYA    PICTURE X.
           02  FILLER   PICTURE X(1).
           02  I-CITYI  PIC X(15).
           02  I-MSGL    COMP  PIC  S9(4).
           02  I-MSGF    PICTURE X.
           02  FILLER REDEFINES I-MSGF.
             03 I-MSGA    PICTURE X.
           02  FILLER   PICTURE X(1).
           02  I-MSGI  PIC X(78).
       01  MAP03PO REDEFINES MAP03PI.
           02  FILLER PIC X(12).
           02  FILLER PICTURE X(3).
           02  I-PARTNOC    PICTURE X.
           02  I-PARTNOO  PIC X(3).
           02  FILLER PICTURE X(3).
           02  I-NAMEC    PICTURE X.
           02  I-NAMEO  PIC X(20).
           02  FILLER PICTURE X(3).
           02  I-COLORC    PICTURE X.
           02  I-COLORO  PIC X(10).
           02  FILLER PICTURE X(3).
           02  I-WEIGHTC    PICTURE X.
           02  I-WEIGHTO  PIC X(3).
           02  FILLER PICTURE X(3).
           02  I-CITYC    PICTURE X.
           02  I-CITYO  PIC X(15).
           02  FILLER PICTURE X(3).
           02  I-MSGC    PICTURE X.
           02  I-MSGO  PIC X(78).
