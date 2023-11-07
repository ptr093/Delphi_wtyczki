create or alter procedure XXX_POZ_ADD (
    AID_NAGL integer,
    AID_MAGAZYN integer,
    AID_KARTOTEKA integer,
    AILOSC numeric(18,4),
    ACENA numeric(18,4),
    ABONIF1POZ numeric(18,4),
    ACENAUZG numeric(18,4),
    ALP integer,
    ASTRONAPOZ integer,
    AID_WALUTA integer,
    AKURS numeric(18,4),
    ARODZCALCWAL integer,
    ACENA_JAKOBRUTTO smallint,
    AWYSTAWREZERWACJEWGKONF smallint,
    AODB_PROCCLA numeric(18,4),
    ACENA_PRZEPISZ smallint,
    ABONIFJESTPOZWAR numeric(18,4))
returns (
    AID_POZ integer)
as
declare variable AID_STAWKAVAT integer;
declare variable AID_DEFCENY integer;
declare variable A1 integer;
declare variable ASTZERODLAWYB smallint;
declare variable AILWOPAKZB numeric(18,4);
declare variable APROGOPAKZB numeric(18,4);
declare variable AID_DEFOPAKDEF integer;
declare variable AZAOKRILOSC integer;
declare variable AILOSCZB numeric(18,4);
declare variable ARESZTAZB numeric(18,4);
declare variable AZAOKRCENY integer;
declare variable ABONIFJESTPOZ numeric(18,4);
declare variable ACENANETTO numeric(18,4);
declare variable ACENABRUTTO numeric(18,4);
declare variable ACENAWENETTO numeric(18,4);
declare variable ACENAWEBRUTTO numeric(18,4);
declare variable AWARTBONIFNETTO numeric(18,4);
declare variable AWARTBONIFBRUTTO numeric(18,4);
declare variable AWARTWENETTO numeric(18,4);
declare variable AWARTWEBRUTTO numeric(18,4);
declare variable AWARTNETTO numeric(18,4);
declare variable AWARTVAT numeric(18,4);
declare variable AWARTBRUTTO numeric(18,4);
declare variable AID_GRUPADOK integer;
declare variable ATERMINDOST timestamp;
declare variable ADATADOK timestamp;
declare variable ACENAZAKKART numeric(18,4);
declare variable ACENAKART numeric(18,4);
declare variable AWARTKART numeric(18,4);
declare variable AWARTZYSKUTOW numeric(18,4);
declare variable APROCMARZY numeric(18,4);
declare variable APROCNARZUTU numeric(18,4);
declare variable AID_POZ_KART integer;
declare variable WWYSTAWREZAUTO integer;
declare variable APROCCLAP numeric(18,4);
declare variable ACENANETTO_WAL numeric(18,4);
declare variable ACENABRUTTO_WAL numeric(18,4);
declare variable ACENAWENETTO_WAL numeric(18,4);
declare variable ACENAWEBRUTTO_WAL numeric(18,4);
declare variable AWARTBONIFNETTO_WAL numeric(18,4);
declare variable AWARTBONIFBRUTTO_WAL numeric(18,4);
declare variable AWARTWENETTO_WAL numeric(18,4);
declare variable AWARTWEBRUTTO_WAL numeric(18,4);
declare variable AWARTNETTO_WAL numeric(18,4);
declare variable AWARTVAT_WAL numeric(18,4);
declare variable AWARTBRUTTO_WAL numeric(18,4);
declare variable AKROTNOSC integer;
declare variable AID_RODZAJKART integer;
declare variable WKONTRAHZAGRANICZNYVAT0 smallint;
declare variable AID_NAGLZR integer;
declare variable AID_POZZR integer;
declare variable AID_NAGLZP integer;
declare variable AID_POZZP integer;
declare variable AID_NAGLZAMWSP integer;
declare variable WPRZEPISZ_CENE smallint;
declare variable WID_KRAJ_STAWKAVAT integer;
declare variable CENA numeric(18,4);
BEGIN
    if (AODB_PROCCLA = 0)
        then AODB_PROCCLA = null;
    if (ACENA_JAKOBRUTTO <> 1)
        then ACENA_JAKOBRUTTO = 0;

    SELECT Wartosc FROM Konffirmy WHERE NumerParam=160
    INTO aZaokrIlosc;

    SELECT W.KROTNOSC
    FROM WALUTA W
    WHERE W.ID_WALUTA = :AID_WALUTA
    INTO :AKROTNOSC;

    SELECT N.id_grupadok, K.stzerodlawyb, N.id_defceny,
           N.maxzaokrceny, ND.termindost , N.DataDok, msc.ID_KRAJ
    FROM Nagl N
    LEFT OUTER JOIN NaglDost ND ON ND.Id_Nagl=N.Id_Nagl
    LEFT OUTER JOIN Kontrah K ON K.Id_Kontrah=N.Id_Kontrah
    LEFT OUTER JOIN miejscesprzedazy msc ON msc.ID_MIEJSCESPRZEDAZY=n.ID_MIEJSCESPRZEDAZY
    WHERE N.Id_nagl=:aId_Nagl
    INTO :aId_GrupaDok, aStZeroDlaWyb, aID_DefCeny,
          aZaokrceny,  aTerminDost, :ADataDok, :WID_KRAJ_STAWKAVAT;

    if (WID_KRAJ_STAWKAVAT is null) then
      WID_KRAJ_STAWKAVAT = 1;

    SELECT K.stzerodlawyb, K.id_defopakdef, KC.cenazak, k.PROCCLA, k.ID_RODZAJKART
    FROM KARTOTEKA K
    join kartoteka_cenazak kc on (kc.id_kartoteka = k.id_kartoteka)
    WHERE K.Id_Kartoteka=:aId_Kartoteka
    INTO :a1, :aId_DefOpakDef, :ACENAZAKKART, :APROCCLAP, :AID_RODZAJKART;

    if (AODB_PROCCLA is not null) then
      APROCCLAP = AODB_PROCCLA;

    execute procedure GETSTAWKAVATFORKART_KR(:aid_kartoteka, :ADataDok, :WID_KRAJ_STAWKAVAT)
      returning_values :aid_stawkavat;


    EXECUTE PROCEDURE KONTRAH_ZAGRANICZNY_VAT0(aId_Nagl) RETURNING_VALUES wKontrahZagranicznyVat0;
    IF ((a1=1 AND aStZeroDlaWyb=1) OR (wKontrahZagranicznyVat0 = 1)) THEN
      aId_StawkaVat=3; /*STVAT_ID_ZERO; */
    IF (aId_DefOpakDef IS NULL) THEN BEGIN
      aILWOPAKZB = 0;
      aPROGOPAKZB = 0;
      aILOSCZB=0;
      aRESZTAZB=ailosc;
    END ELSE BEGIN
      EXECUTE PROCEDURE GET_DANE_OPAK (:aId_DefOpakDef, :aId_Kartoteka)
      RETURNING_VALUES ( aILWOPAKZB, aPROGOPAKZB , a1);

      EXECUTE PROCEDURE OblIloscOpakZb (aIlosc, aILWOPAKZB , aPROGOPAKZB , aZaokrIlosc)
      RETURNING_VALUES (aILOSCZB, aRESZTAZB);
    END

    -- ustawiam by po staremu tez dzialalo
    if (ACENA_PRZEPISZ is null)
        then WPRZEPISZ_CENE = ACENAUZG;
        else WPRZEPISZ_CENE = ACENA_PRZEPISZ;

    IF (WPRZEPISZ_CENE=0) THEN /* jesli nie uzgodniono ceny to wez z cennika */
      EXECUTE PROCEDURE GET_WARTOSC_CENYKART (aId_DefCeny, aId_Kartoteka, AID_MAGAZYN)
      RETURNING_VALUES (aCenaWeNetto,aCenaWeBrutto,a1,aZaokrCeny);
    ELSE BEGIN  /* jesli uzgodniona te obicz brutto bo zawsze podawana na wejsciu jest netto */
        if (ACENA_JAKOBRUTTO = 1) then
          EXECUTE PROCEDURE OblWWWVatZaokr(2,aCena,aCena,aZaokrCeny,aId_StawkaVat)
          RETURNING_VALUES(aCenaWeNetto,a1,aCenaWeBrutto);
        else
          EXECUTE PROCEDURE OblWWWVatZaokr(1,aCena,aCena,aZaokrCeny,aId_StawkaVat)
          RETURNING_VALUES(aCenaWeNetto,a1,aCenaWeBrutto);
    END

    EXECUTE PROCEDURE POZ_WYLICZ_DEF(aIlosc, aCenaWeNetto, aCenaWeBrutto, 0, aBonif1POZ, aId_StawkaVAT,aZaokrCeny,aId_Nagl)
    RETURNING_VALUES  ( ACENAWENETTO , ACENAWEBRUTTO , ACENANETTO , ACENABRUTTO , AWARTBONIFNETTO ,
                        AWARTBONIFBRUTTO , AWARTWENETTO , AWARTWEBRUTTO ,  AWARTNETTO ,  AWARTVAT ,
                        AWARTBRUTTO ,  aBONIFJESTPOZ  );

    aId_POZ=GEN_ID(GEN_POZ,1);

    AID_POZ_KART = NULL;
    SELECT MIN(PK.ID_POZ_KART)
    FROM POZ_KART pk
    JOIN Kartoteka K ON PK.Id_Kartoteka=K.Id_Kartoteka
    LEFT OUTER JOIN JM J ON (K.Id_Jm = J.Id_Jm)
    WHERE
      K.Id_Kartoteka = :aId_Kartoteka AND
      PK.KART_NAZWASKR = COALESCE(K.NAZWASKR,'') AND
      PK.KART_NAZWADL = COALESCE(K.NAZWADL,'') AND
      PK.KART_SWW = COALESCE(K.SWW,'') AND
      PK.KART_PKWIU = COALESCE(K.PKWIU,'') AND
      PK.JM = COALESCE(J.JM,'')
    INTO AID_POZ_KART;

    IF (:AID_POZ_KART IS NULL) THEN BEGIN
      AID_POZ_KART = GEN_ID(GEN_POZ_KART,1);
      INSERT INTO POZ_KART (ID_POZ_KART, ID_KARTOTEKA, KART_NAZWASKR,
        KART_NAZWADL, KART_SWW, KART_PKWIU,JM)
      SELECT  :AID_POZ_KART, :AID_KARTOTEKA,  K.NazwaSkr,
              K.NazwaDl,  K.Sww, K.Pkwiu, J.Jm
      FROM  Kartoteka K
       LEFT OUTER JOIN JM J ON (K.Id_Jm = J.Id_Jm)
      WHERE K.Id_Kartoteka=:aId_Kartoteka;
    END

    IF (AID_WALUTA <> 1) THEN BEGIN
            IF (ARodzCalcWal = 0) THEN BEGIN /* odebrane kwoty przelicz na pln */
                ACENANETTO_WAL = ACENANETTO;
                ACENABRUTTO_WAL = ACENABRUTTO;
                ACENAWENETTO_WAL = ACENAWENETTO;
                ACENAWEBRUTTO_WAL = ACENAWEBRUTTO;
                AWARTBONIFNETTO_WAL = AWARTBONIFNETTO;
                AWARTBONIFBRUTTO_WAL = AWARTBONIFBRUTTO;
                AWARTWENETTO_WAL = AWARTWENETTO;
                AWARTWEBRUTTO_WAL = AWARTWEBRUTTO;
                AWARTNETTO_WAL = AWARTNETTO;
                AWARTVAT_WAL = AWARTVAT;
                AWARTBRUTTO_WAL = AWARTBRUTTO;

                ACENANETTO = Dziel(:ACENANETTO * :AKURS, :AKROTNOSC, :AZAOKRCENY);
                ACENABRUTTO = Dziel(:ACENABRUTTO * :AKURS, :AKROTNOSC, :AZAOKRCENY);
                ACENAWENETTO = Dziel(:ACENAWENETTO * :AKURS, :AKROTNOSC, :AZAOKRCENY);
                ACENAWEBRUTTO = Dziel(:ACENAWEBRUTTO * :AKURS, :AKROTNOSC, :AZAOKRCENY);
                AWARTBONIFNETTO = Dziel(:AWARTBONIFNETTO * :AKURS, :AKROTNOSC, :AZAOKRCENY);
                AWARTBONIFBRUTTO = Dziel(:AWARTBONIFBRUTTO * :AKURS, :AKROTNOSC, :AZAOKRCENY);
                AWARTWENETTO = Dziel(:AWARTWENETTO * :AKURS, :AKROTNOSC, :AZAOKRCENY);
                AWARTWEBRUTTO = Dziel(:AWARTWEBRUTTO * :AKURS, :AKROTNOSC, :AZAOKRCENY);
                AWARTNETTO = Dziel(:AWARTNETTO * :AKURS, :AKROTNOSC, :AZAOKRCENY);
                AWARTVAT = Dziel(:AWARTVAT * :AKURS, :AKROTNOSC, :AZAOKRCENY);
                AWARTBRUTTO = Dziel(:AWARTBRUTTO * :AKURS, :AKROTNOSC, :AZAOKRCENY);
            END ELSE BEGIN /* odebrane kwoty przelicz na waluta */
                ACENANETTO_WAL = Dziel(:ACENANETTO * :AKROTNOSC, :AKURS, :AZAOKRCENY);
                ACENABRUTTO_WAL = Dziel(:ACENABRUTTO * :AKROTNOSC, :AKURS, :AZAOKRCENY);
                ACENAWENETTO_WAL = Dziel(:ACENAWENETTO * :AKROTNOSC, :AKURS, :AZAOKRCENY);
                ACENAWEBRUTTO_WAL = Dziel(:ACENAWEBRUTTO * :AKROTNOSC, :AKURS, :AZAOKRCENY);
                AWARTBONIFNETTO_WAL = Dziel(:AWARTBONIFNETTO * :AKROTNOSC, :AKURS, :AZAOKRCENY);
                AWARTBONIFBRUTTO_WAL = Dziel(:AWARTBONIFBRUTTO * :AKROTNOSC, :AKURS, :AZAOKRCENY);
                AWARTWENETTO_WAL = Dziel(:AWARTWENETTO * :AKROTNOSC, :AKURS, :AZAOKRCENY);
                AWARTWEBRUTTO_WAL = Dziel(:AWARTWEBRUTTO * :AKROTNOSC, :AKURS, :AZAOKRCENY);
                AWARTNETTO_WAL = Dziel(:AWARTNETTO * :AKROTNOSC, :AKURS, :AZAOKRCENY);
                AWARTVAT_WAL = Dziel(:AWARTVAT * :AKROTNOSC, :AKURS, :AZAOKRCENY);
                AWARTBRUTTO_WAL = Dziel(:AWARTBRUTTO * :AKROTNOSC, :AKURS, :AZAOKRCENY);
            END
    END

    IF (AID_GRUPADOK IN (80, 150)) THEN BEGIN
      ACENAKART = ACENAZAKKART;
      AWARTKART = ZaokrW(aIlosc * ACENAKART);
      AWARTZYSKUTOW = AWARTNETTO - AWARTKART;
      APROCMARZY = Dziel(AWartZyskuTOW * 100, AWARTNETTO, 2);
      APROCNARZUTU = Dziel(AWartZyskuTOW * 100, AWARTKART, 2);
    END ELSE BEGIN
      ACENAKART = 0;
      AWARTKART = 0;
      AWARTZYSKUTOW = 0;
      APROCMARZY = 0;
      APROCNARZUTU = 0;
    END


    select k.cenazak  from kartoteka k where
    k.id_kartoteka =  :  AID_KARTOTEKA
    into :cena;

    aWartBrutto= nullif(:AILOSC * cena,0);
    awartnetto= nullif(:AILOSC * cena,0);
    aWartWeBrutto= nullif(:AILOSC * cena,0);
    aWartWeNetto= nullif(:AILOSC * cena,0);
    awartkart=  nullif(:AILOSC * cena,0);
    acenakart =cena;
        INSERT INTO POZ
      (       Id_Nagl,          Id_POZ,           ilosc,            Lp,           StronaPoz,
              Id_Kartoteka,     Id_Magazyn,       KierunekMag,
              Id_STAWKAVat,
              cenawenetto,      cenawebrutto,     CenaNetto,        CenaBrutto,
              bonif1poz,        bonifjestpoz,
              cenauzgzam,
              Id_RodzajKart,    ID_POZ_KART,
              Id_DefOpak,       ilwopakzb,        PROGOPAKZB,
              ilosczb,          resztazb,
              WartWeNetto,      WartWeBrutto,     WartBonifNetto,   WartBonifBrutto,
              wartnetto,        WartVat,          WartBrutto,
              cenakart,         wartkart,         wartzyskutow,
              procmarzy,        procnarzutu,      zaokrceny

      )
    VALUES (  :aId_Nagl,        :aId_POZ,         :aIlosc,          :aLp,         :aStronaPoz,
              :aid_kartoteka,   :aId_Magazyn,     0,
              coalesce(:aId_StawkaVat,0),
              coalesce(:aCenaWeNetto,0),    coalesce(:aCenaWeBrutto,0),   COALESCE(:aCenaNetto,0),     COALESCE(:aCenaBrutto,0),
              coalesce(:aBonif1POZ,0),      :abonifjestpozwar,
             coalesce( :aCenaUzg,0),
            coalesce (:AID_RODZAJKART,0),  coalesce(:AID_POZ_KART,0),
              coalesce(:aID_DEFOPAKDEF,0), coalesce( :aILWOPAKZB,0),     coalesce( :aPROGOPAKZB,0),
              coalesce(:aIloscZb,0),        coalesce(:aresztaZb,0),
             coalesce( :aWartWeNetto,0),   coalesce( :aWartWeBrutto,0),   COALESCE(:aWartBonifNetto,0), COALESCE(:aWartBonifBrutto,0),
             coalesce( :awartnetto,0),     coalesce( :aWartVat,0),        coalesce(:aWartBrutto,0),
              coalesce(:acenakart,0),      coalesce( :awartkart,0),       coalesce(:awartzyskutow,0),
             coalesce( :aprocmarzy,0),      coalesce(:aprocnarzutu,0),    coalesce(:aZaokrceny,0));



  IF (AID_WALUTA <> 1) THEN BEGIN
    INSERT INTO POZIMPEXP(ID_POZ            , PROCCLAP          , WARTCLAP,
                          CENAWENETTOWAL    , CENAWEBRUTTOWAL   , WARTWENETTOWAL,
                          WARTWEBRUTTOWAL   , CENANETTOWAL      , CENABRUTTOWAL,
                          WARTNETTOWAL      , WARTBRUTTOWAL     , WARTVATWAL,
                          WARTBONIFNETTOWAL , WARTBONIFBRUTTOWAL, ID_STAWKAVAT,
                          ID_RODZAJKART)
    VALUES               (:AID_POZ         , :APROCCLAP         , ZAOKR(:APROCCLAP/100,2),
                          :ACENAWENETTO_WAL, :ACENAWEBRUTTO_WAL , :AWARTWENETTO_WAL,
                          :AWARTWEBRUTTO_WAL,:ACENANETTO_WAL    , :ACENABRUTTO_WAL,
                          :AWARTNETTO_WAL   ,:AWARTBRUTTO_WAL   , :AWARTVAT_WAL,
                          :AWARTBONIFNETTO_WAL,:AWARTBONIFBRUTTO_WAL, :AID_STAWKAVAT,
                          :AID_RODZAJKART);

  END



  IF (:aId_GrupaDok IN (70,72,80,82,150)) THEN BEGIN
    select zws.id_naglzamwsp from naglzamwsp zws where zws.id_nagl = :aid_nagl into :aid_naglzamwsp;
    INSERT INTO POZZAMWSP (ID_POZ,    TERMINDOST,   ILZAM,    id_naglzamwsp)  /* ilpotw uzupelnia triggery*/
                   VALUES (:aId_POZ,  :aTerminDost, :aIlosc,  :aid_naglzamwsp);
  END

  IF (:aId_GrupaDok IN (70,72)) THEN BEGIN
    INSERT INTO POZZAM (ID_POZ,     ILPOTWZAMD )
                VALUES (:aId_POZ,   :aIlosc);
    -- dodanie pozzp
    if (AID_RODZAJKART = 1) then begin -- sprawdzenie czy kartoteka jest towarowa
        SELECT NZP.id_naglzp FROM NaglZP NZP WHERE NZP.Id_Nagl=:aId_Nagl
        INTO :aId_NaglZP;

        aId_PozZP=GEN_ID(gen_pozzp, 1);

        INSERT INTO POZZP (ID_POZZP, ID_NAGLZP,     ID_MAGAZYN,   ID_KARTOTEKA,   ID_POZ,   TERMIN,       ILOSC )
                   VALUES (:aID_POZZP, :aID_NAGLZP, :aID_MAGAZYN, :aID_KARTOTEKA, :aID_POZ, :aTERMINDOST, :aILOSC);
    end
  END

  IF (:aId_GrupaDok IN (80,82)) THEN BEGIN

    INSERT INTO POZZAMODB (ID_POZ) VALUES (:aID_POZ); -- aby tylko istnial

    if (AID_RODZAJKART = 1) then begin -- sprawdzenie czy kartoteka jest towarowa
      -- dodanie PozZR
      SELECT NZR.id_naglzr FROM NaglZR NZR WHERE NZR.Id_Nagl=:aId_Nagl
      INTO :aId_NaglZR;

      aId_PozZR=GEN_ID(gen_pozzr, 1);
      INSERT INTO POZZR (ID_POZZR,   ID_NAGLZR,     ID_MAGAZYN,   ID_KARTOTEKA,   ID_POZ,   TERMIN,      ILOSC  )
                 VALUES (:aId_PozZR, :aID_NAGLZR,   :aID_MAGAZYN, :aID_KARTOTEKA, :aID_POZ, :aTerminDost, :aILOSC );

      if (AWystawRezerwacjeWgKonf = 1) then begin -- sprawdzenie czy analizować konfiguracje
        EXECUTE PROCEDURE KONFFIRMY_GET_PARAM(1050, 1) RETURNING_VALUES(wWystawRezAuto); -- Obsługa rezerwacji stanu magazynowego

        -- Wystawienie automatycznych rezerwacji
        if (wWystawRezAuto = 1) then begin
          if (:aId_GrupaDok = 80) then
            EXECUTE PROCEDURE KONFFIRMY_GET_PARAM(253, 0) RETURNING_VALUES(wWystawRezAuto); -- czy wystawić auto. rezerwacje stanu dla ZamOdb
          else
            EXECUTE PROCEDURE KONFFIRMY_GET_PARAM(262, 0) RETURNING_VALUES(wWystawRezAuto); -- czy wystawić auto. rezerwacje stanu dla ZamWew
        end

        IF (wWystawRezAuto = 1) THEN
          EXECUTE PROCEDURE ADD_REZ(:aID_MAGAZYN, :aID_KARTOTEKA, :aID_POZZR, null, :aIlosc);
      end
    end
  END

  EXECUTE PROCEDURE WystcechPOZ_ADD_ALL (aId_Poz ,0);
END