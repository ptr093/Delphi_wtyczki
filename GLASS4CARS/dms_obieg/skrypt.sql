CREATE TABLE XXX_DMS_POLE_RODZAJ (
    ID_POLE_RODZAJ  INTEGER NOT NULL,
    OPIS            VARCHAR(128) NOT NULL
);

ALTER TABLE XXX_DMS_POLE_RODZAJ 
ADD CONSTRAINT PK_XXX_DMS_POLE_RODZAJ 
PRIMARY KEY (ID_POLE_RODZAJ);

INSERT INTO XXX_DMS_POLE_RODZAJ (ID_POLE_RODZAJ, OPIS) VALUES (1, 'Atrybut');
INSERT INTO XXX_DMS_POLE_RODZAJ (ID_POLE_RODZAJ, OPIS) VALUES (2, 'Dane do przelewu');
INSERT INTO XXX_DMS_POLE_RODZAJ (ID_POLE_RODZAJ, OPIS) VALUES (3, 'Zaakceptowano do przelewu');
INSERT INTO XXX_DMS_POLE_RODZAJ (ID_POLE_RODZAJ, OPIS) VALUES (4, 'Kategoria kosztowa');
INSERT INTO XXX_DMS_POLE_RODZAJ (ID_POLE_RODZAJ, OPIS) VALUES (5, 'Słownik na pozycji');

CREATE TABLE XXX_DMS_POLE_SLOWNIK (
    ID_POLE_SLOWNIK  INTEGER NOT NULL,
    NAZWA            VARCHAR(64) NOT NULL,
    ID_POLE_RODZAJ   INTEGER NOT NULL
);

ALTER TABLE XXX_DMS_POLE_SLOWNIK 
ADD CONSTRAINT PK_XXX_DMS_POLE_SLOWNIK 
PRIMARY KEY (ID_POLE_SLOWNIK);

ALTER TABLE XXX_DMS_POLE_SLOWNIK 
ADD CONSTRAINT FK_XXX_DMS_POLE_SLOWNIK_1 
FOREIGN KEY (ID_POLE_RODZAJ) REFERENCES XXX_DMS_POLE_RODZAJ (ID_POLE_RODZAJ);

INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (1, 'Opis', 1);
INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (2, 'Dokumentacja', 1);
INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (3, 'Data dokumentu', 1);
INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (4, 'Data wpływu', 1);
INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (5, 'Data księgowa', 1);
INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (6, 'Kontrahent', 1);
INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (7, 'Miejsce zakupu', 1);
INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (8, 'Termin płatności', 1);
INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (9, 'Kwota netto', 1);
INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (10, 'Kwota brutto', 1);
INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (11, 'Waluta', 1);
INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (12, 'Nr. Dok. zew.', 1);
INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (13, 'Przedstawiciel handl.', 1);
INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (14, 'Zlecenie', 1);
INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (15, 'Jednostka org.', 1);
INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (16, 'Pracownik', 1);
INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (10001, 'Dane do przelewu', 2);
INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (10002, 'Zaakceptowano do przelewu', 3);
INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (10003, 'Kategoria kosztowa', 4);
INSERT INTO XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK, NAZWA, ID_POLE_RODZAJ) VALUES (10004, 'Słownik na pozycji', 5);

CREATE SEQUENCE XXX_GEN_DMS_ETAPAKCEPT_POLE;
ALTER SEQUENCE XXX_GEN_DMS_ETAPAKCEPT_POLE RESTART WITH 0;

CREATE TABLE XXX_DMS_ETAPAKCEPT_POLE (
    ID_ETAPAKCEPT_POLE  INTEGER NOT NULL,
    ID_ETAPAKCEPT       INTEGER NOT NULL,
    ID_POLE_SLOWNIK     INTEGER NOT NULL,
    WYMAGANY            SMALLINT NOT NULL,
    BLOKOWANY           SMALLINT NOT NULL,
    ID_ANALITYKA        INTEGER
);

ALTER TABLE XXX_DMS_ETAPAKCEPT_POLE 
ADD CONSTRAINT PK_XXX_DMS_ETAPAKCEPT_POLE 
PRIMARY KEY (ID_ETAPAKCEPT_POLE);

ALTER TABLE XXX_DMS_ETAPAKCEPT_POLE 
ADD CONSTRAINT FK_XXX_DMS_ETAPAKCEPT_POLE_1 
FOREIGN KEY (ID_POLE_SLOWNIK) REFERENCES XXX_DMS_POLE_SLOWNIK (ID_POLE_SLOWNIK);

ALTER TABLE XXX_DMS_ETAPAKCEPT_POLE 
ADD CONSTRAINT UNQ1_XXX_DMS_ETAPAKCEPT_POLE 
UNIQUE (ID_ETAPAKCEPT, ID_POLE_SLOWNIK, ID_ANALITYKA);

CREATE OR ALTER procedure XXX_DMS_SPR_POZ_SLOWNIK (
    id_sekdok integer)
returns (
    id_poz integer,
    lp integer,
    indeks varchar(40),
    nazwaskr varchar(35),
    nazwadl varchar(360),
    opis varchar(64),
    id_analityka integer,
    analityka varchar(50))
AS
declare variable id_sciezkaakcept integer;
declare variable nazwa varchar(50);
declare variable id_etapakcept integer;
declare variable ilosc integer;
begin
  id_sciezkaakcept = null;

  select srd.id_sciezkaakcept
  from sekdok sd
  join sekrodzajdok srd on sd.id_sekrodzajdok = srd.id_sekrodzajdok
  where sd.id_sekdok = :id_sekdok
  into :id_sciezkaakcept;

  if (:id_sciezkaakcept is null) then exit;

  select ea.nazwa
  from sekdok sd
  join etapakcept ea on sd.id_sciezkaakcept = ea.id_sciezkaakcept and ea.inicjator = 0 and ea.aktualny = 1
  where sd.id_sekdok = :id_sekdok
  into :nazwa;

  id_etapakcept = null;

  select first 1 ea.id_etapakcept
  from etapakcept ea
  where ea.id_sciezkaakcept = :id_sciezkaakcept
  and ea.nazwa = :nazwa
  order by ea.lp
  into :id_etapakcept;

  if (:id_etapakcept is null) then exit;

  for
  select p.id_poz
  from wyst_nagl_sekdok_dlapoz wnsp
  join poz p on wnsp.id_nagl = p.id_nagl
  where wnsp.id_sekdok = :id_sekdok
  order by p.id_poz
  into :id_poz
  do
  begin
    for
    select xep.id_analityka
    from xxx_dms_etapakcept_pole xep
    join xxx_dms_pole_slownik xps on xep.id_pole_slownik = xps.id_pole_slownik
    where xep.id_etapakcept = :id_etapakcept
    and xep.wymagany = 1
    and xps.id_pole_rodzaj = 5
    order by xep.id_etapakcept_pole
    into :id_analityka
    do
    begin
      select count(ps.id_poz_slownik)
      from poz_slownik ps
      join typpozycji_analityka ta on ps.id_typpozycji_analityka = ta.id_typpozycji_analityka
      where ps.id_poz = :id_poz
      and ta.id_analityka = :id_analityka
      into :ilosc;

      if (:ilosc = 0) then
      begin
        select p.lp, k.indeks, k.nazwaskr, k.nazwadl
        from poz p
        join kartoteka k on p.id_kartoteka = k.id_kartoteka
        where p.id_poz = :id_poz
        into :lp, :indeks, :nazwaskr, :nazwadl;
        
        select xps.nazwa
        from xxx_dms_pole_slownik xps
        where xps.id_pole_slownik = 10004
        into :opis;
        
        select a.nazwa
        from analityka a
        where a.id_analityka = :id_analityka
        into :analityka;

        suspend;
      end
    end
  end
end;

CREATE OR ALTER procedure XXX_DMS_SPR_WYM_PAR (
    ID_SEKDOK integer)
returns (
    WYNIK varchar(1024))
AS
declare variable id_sekrodzajdok integer;
declare variable id_sciezkaakcept integer;
declare variable akcja_wystaw_przelew smallint;
declare variable etap_nazwa varchar(50);
declare variable id_etapakcept integer;
declare variable id_kontrah integer;
declare variable id_miejscezakupu integer;
declare variable id_pracownik integer;
declare variable id_waluta integer;
declare variable nr_dok_zew varchar(50);
declare variable data_dok timestamp;
declare variable termin_platnosci timestamp;
declare variable kwota_brutto numeric(18,4);
declare variable opis blob sub_type text;
declare variable zaakcept_do_przel smallint;
declare variable kwota_przelew numeric(18,4);
declare variable kontobankowe varchar(50);
declare variable data_wplywu timestamp;
declare variable termin_platnosci_od smallint;
declare variable kwota_netto numeric(18,4);
declare variable id_jednorg integer;
declare variable id_akwizytor integer;
declare variable id_zlec integer;
declare variable data_ksiegowania timestamp;
declare variable id_pole_slownik integer;
declare variable pole_slownik_nazwa varchar(64);
declare variable id_sekdokatr integer;
declare variable ilosc integer;
begin
  id_sekrodzajdok = null;

  select sd.id_sekrodzajdok
  from sekdok sd
  where sd.id_sekdok = :id_sekdok
  into :id_sekrodzajdok;

  if (:id_sekrodzajdok is null) then exit;

  id_sciezkaakcept = null;
  akcja_wystaw_przelew = null;

  select srd.id_sciezkaakcept, srd.akcja_wystaw_przelew
  from sekdok sd
  join sekrodzajdok srd on sd.id_sekrodzajdok = srd.id_sekrodzajdok
  where sd.id_sekdok = :id_sekdok
  into :id_sciezkaakcept, :akcja_wystaw_przelew;

  if ((:id_sciezkaakcept is null) or (:akcja_wystaw_przelew is null)) then exit;

  select ea.nazwa
  from sekdok sd
  join etapakcept ea on sd.id_sciezkaakcept = ea.id_sciezkaakcept and ea.inicjator = 0 and ea.aktualny = 1
  where sd.id_sekdok = :id_sekdok
  into :etap_nazwa;

  id_etapakcept = null;

  select first 1 ea.id_etapakcept
  from etapakcept ea
  where ea.id_sciezkaakcept = :id_sciezkaakcept
  and ea.nazwa = :etap_nazwa
  order by ea.lp
  into :id_etapakcept;

  if (:id_etapakcept is null) then exit;

  select id_kontrah, id_miejscezakupu, id_pracownik, id_waluta, nr_dok_zew, data_dok, termin_platnosci, kwota_brutto,
         opis, zaakcept_do_przel, kwota_przelew, kontobankowe, data_wplywu, termin_platnosci_od, kwota_netto, id_jednorg,
         id_akwizytor, id_zlec, data_ksiegowania
  from sekdok
  where id_sekdok = :id_sekdok
  into :id_kontrah, :id_miejscezakupu, :id_pracownik, :id_waluta, :nr_dok_zew, :data_dok, :termin_platnosci,
       :kwota_brutto, :opis, :zaakcept_do_przel, :kwota_przelew, :kontobankowe, :data_wplywu, :termin_platnosci_od,
       :kwota_netto, :id_jednorg, :id_akwizytor, :id_zlec, :data_ksiegowania;

  for
  select xep.id_pole_slownik, xps.nazwa, sda.id_sekdokatr
  from xxx_dms_etapakcept_pole xep
  join xxx_dms_pole_slownik xps on xep.id_pole_slownik = xps.id_pole_slownik
  left join sekdokatr sda on xep.id_pole_slownik = sda.atr and sda.id_sekrodzajdok = :id_sekrodzajdok
  where xep.id_etapakcept = :id_etapakcept
  and xep.wymagany = 1
  order by xep.id_etapakcept_pole
  into :id_pole_slownik, :pole_slownik_nazwa, :id_sekdokatr
  do
  begin
    if (:id_pole_slownik = 1) then
      if (:id_sekdokatr is not null) then
        if ((:opis is null) or (char_length(trim(:opis)) = 0)) then
        begin
          wynik = :pole_slownik_nazwa;
          suspend;
        end

    if (:id_pole_slownik = 2) then
    begin
      select count(wdz.id_doddokumzew)
      from wystsekdokdokumzew wdz
      where wdz.id_sekdok = :id_sekdok
      into :ilosc;

      if (:ilosc = 0) then
      begin
        wynik = :pole_slownik_nazwa;
        suspend;
      end
    end

    if (:id_pole_slownik = 3) then
      if (:id_sekdokatr is not null) then
        if (:data_dok is null) then
        begin
          wynik = :pole_slownik_nazwa;
          suspend;
        end

    if (:id_pole_slownik = 4) then
      if (:id_sekdokatr is not null) then
        if (:data_wplywu is null) then
        begin
          wynik = :pole_slownik_nazwa;
          suspend;
        end

    if (:id_pole_slownik = 5) then
      if (:id_sekdokatr is not null) then
        if (:data_ksiegowania is null) then
        begin
          wynik = :pole_slownik_nazwa;
          suspend;
        end

    if (:id_pole_slownik = 6) then
      if (:id_sekdokatr is not null) then
        if (:id_kontrah is null) then
        begin
          wynik = :pole_slownik_nazwa;
          suspend;
        end

    if (:id_pole_slownik = 7) then
      if (:id_sekdokatr is not null) then
        if (:id_miejscezakupu is null) then
        begin
          wynik = :pole_slownik_nazwa;
          suspend;
        end

    if (:id_pole_slownik = 8) then
      if (:id_sekdokatr is not null) then
      begin
        if (:termin_platnosci_od = 0) then
          if ((:data_dok is null) or (:termin_platnosci is null)) then
          begin
            wynik = :pole_slownik_nazwa;
            suspend;
          end

        if (:termin_platnosci_od = 1) then
          if ((:data_wplywu is null) or (:termin_platnosci is null)) then
          begin
            wynik = :pole_slownik_nazwa;
            suspend;
          end
      end

    if (:id_pole_slownik = 9) then
      if (:id_sekdokatr is not null) then
        if ((:kwota_netto is null) or (:kwota_netto < 0)) then
        begin
          wynik = :pole_slownik_nazwa;
          suspend;
        end

    if (:id_pole_slownik = 10) then
      if (:id_sekdokatr is not null) then
        if ((:kwota_brutto is null) or (:kwota_brutto < 0)) then
        begin
          wynik = :pole_slownik_nazwa;
          suspend;
        end

    if (:id_pole_slownik = 11) then
      if (:id_sekdokatr is not null) then
        if (:id_waluta is null) then
        begin
          wynik = :pole_slownik_nazwa;
          suspend;
        end

    if (:id_pole_slownik = 12) then
      if (:id_sekdokatr is not null) then
        if ((:nr_dok_zew is null) or (char_length(trim(:nr_dok_zew)) = 0)) then
        begin
          wynik = :pole_slownik_nazwa;
          suspend;
        end

    if (:id_pole_slownik = 13) then
      if (:id_sekdokatr is not null) then
        if (:id_akwizytor is null) then
        begin
          wynik = :pole_slownik_nazwa;
          suspend;
        end

    if (:id_pole_slownik = 14) then
      if (:id_sekdokatr is not null) then
        if (:id_zlec is null) then
        begin
          wynik = :pole_slownik_nazwa;
          suspend;
        end

    if (:id_pole_slownik = 15) then
      if (:id_sekdokatr is not null) then
        if (:id_jednorg is null) then
        begin
          wynik = :pole_slownik_nazwa;
          suspend;
        end

    if (:id_pole_slownik = 16) then
      if (:id_sekdokatr is not null) then
        if (:id_pracownik is null) then
        begin
          wynik = :pole_slownik_nazwa;
          suspend;
        end

    if (:id_pole_slownik = 10001) then
      if (:akcja_wystaw_przelew > 0) then
        if ((:kontobankowe is null) or (char_length(trim(:kontobankowe)) = 0)
          or (:kwota_przelew is null) or (:kwota_przelew <= 0)) then
        begin
          wynik = :pole_slownik_nazwa;
          suspend;
        end

    if (:id_pole_slownik = 10002) then
      if (:akcja_wystaw_przelew > 0) then
        if ((:zaakcept_do_przel is null) or (:zaakcept_do_przel = 0)) then
        begin
          wynik = :pole_slownik_nazwa;
          suspend;
        end

    if (:id_pole_slownik = 10003) then
    begin
      select count(p.id_poz)
      from wyst_nagl_sekdok_dlapoz wnsp
      join poz p on wnsp.id_nagl = p.id_nagl
      where wnsp.id_sekdok = :id_sekdok
      into :ilosc;

      if (:ilosc = 0) then
      begin
        wynik = :pole_slownik_nazwa;
        suspend;
      end
    end
  end

  for
  select 'Pozycja: Lp: ' || lp || ', Identyfikator: ' || nazwaskr || ', ' || opis || ': ' || analityka
  from xxx_dms_spr_poz_slownik(:id_sekdok)
  order by lp
  into :wynik
  do
    suspend;
end;

CREATE OR ALTER procedure XXX_DMS_NASTEPNY_ETAP (
    ID_SEKDOK integer,
    ID_UZYTKOWNIKAKCEPT integer)
AS
declare variable r_id_uzytkownik integer;
declare variable id_sciezkaakcept integer;
declare variable id_etapakcept integer;
declare variable datetime timestamp;
declare variable id_sekdokhist integer;
begin
  r_id_uzytkownik = null;

  select r_id_uzytkownik
  from aktuser
  into :r_id_uzytkownik;

  if (:r_id_uzytkownik is null) then exit;

  if (:id_uzytkownikakcept is null) then exit;

  id_sciezkaakcept = null;

  select sd.id_sciezkaakcept
  from sekdok sd
  where sd.id_sekdok = :id_sekdok
  into :id_sciezkaakcept;

  if (:id_sciezkaakcept is null) then exit;

  id_etapakcept = null;

  select ea.id_etapakcept
  from etapakcept ea
  where ea.id_sciezkaakcept = :id_sciezkaakcept
  and ea.aktualny = 1
  into :id_etapakcept;

  if (:id_etapakcept is null) then exit;

  select current_timestamp
  from rdb$database
  into :datetime;

  select gen_id(gen_sekdokhist, 1)
  from rdb$database
  into :id_sekdokhist;

  insert into sekdokhist (id_sekdokhist, id_etapakcept, id_uzytkownik,
    czas, uwagi, aktualny_count, id_uzytkownikakcept, akceptacja)
  values (:id_sekdokhist, :id_etapakcept, :r_id_uzytkownik,
    :datetime, null, 1, :id_uzytkownikakcept, 1);

  id_etapakcept = null;

  select e.id_etapakcept
  from etapakcept e
  where ((e.id_sciezkaakcept = :id_sciezkaakcept)
    and (e.lp = (select lp + 1 from etapakcept where (aktualny = 1)
    and (id_sciezkaakcept = :id_sciezkaakcept))))
  into :id_etapakcept;

  if (:id_etapakcept is null) then
  begin
    select ea.id_etapakcept
    from etapakcept ea
    where ea.id_sciezkaakcept = :id_sciezkaakcept
    and ea.aktualny = 1
    into :id_etapakcept;

    update etapakcept
    set aktualny_count = 2
    where id_etapakcept = :id_etapakcept;

    update sekdok
    set status = 1
    where id_sekdok = :id_sekdok;
  end else
    update etapakcept
    set aktualny = 1,
        aktualny_count = 1
    where id_etapakcept = :id_etapakcept;
end;

CREATE trigger xxx_etapakcept_pole_ad for etapakcept
active after delete position 0
as
begin
  delete from xxx_dms_etapakcept_pole
  where id_etapakcept_pole = old.id_etapakcept;
end;