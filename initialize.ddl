CREATE TABLE aktif (
    nim            VARCHAR2(9 CHAR) NOT NULL,
    tanggal_mulai  DATE NOT NULL
);

ALTER TABLE aktif ADD CONSTRAINT aktif_pk PRIMARY KEY ( nim );

CREATE TABLE cuti (
    nim              VARCHAR2(9 CHAR) NOT NULL,
    tanggal_mulai    DATE NOT NULL,
    tanggal_selesai  DATE
);

ALTER TABLE cuti ADD CONSTRAINT cuti_pk PRIMARY KEY ( nim );

CREATE TABLE log_cuti (
    mahasiswa_nim    VARCHAR2(9 CHAR),
    tanggal_mulai    DATE NOT NULL,
    tanggal_selesai  DATE NOT NULL
);

ALTER TABLE log_cuti ADD CONSTRAINT log_cuti_pk PRIMARY KEY ( tanggal_mulai );

CREATE TABLE mahasiswa (
    nim     VARCHAR2(9 CHAR) NOT NULL,
    nama    VARCHAR2(30 CHAR) NOT NULL,
    alamat  VARCHAR2(50 CHAR),
    status  VARCHAR2(10 CHAR) NOT NULL
);

ALTER TABLE mahasiswa ADD CONSTRAINT mahasiswa_pk PRIMARY KEY ( nim );

ALTER TABLE aktif
    ADD CONSTRAINT aktif_mahasiswa_fk FOREIGN KEY ( nim )
        REFERENCES mahasiswa ( nim );

ALTER TABLE cuti
    ADD CONSTRAINT cuti_mahasiswa_fk FOREIGN KEY ( nim )
        REFERENCES mahasiswa ( nim );

ALTER TABLE log_cuti
    ADD CONSTRAINT log_cuti_mahasiswa_fk FOREIGN KEY ( mahasiswa_nim )
        REFERENCES mahasiswa ( nim );

CREATE OR REPLACE TRIGGER update_status
    AFTER UPDATE OF status ON mahasiswa
    FOR EACH ROW
DECLARE
    mulai_cuti DATE;
    selesai_cuti DATE;
BEGIN
    IF ((:OLD.status = 'Aktif') AND (:NEW.status = 'Cuti')) THEN
        INSERT INTO cuti(nim, tanggal_mulai) VALUES(:NEW.nim, SYSDATE);

        DELETE FROM aktif WHERE nim = :OLD.nim;
    ELSIF ((:OLD.status = 'Cuti') AND (:NEW.status = 'Aktif')) THEN
        INSERT INTO aktif VALUES (:NEW.nim, SYSDATE);

        SELECT
            tanggal_mulai, tanggal_selesai
        INTO
            mulai_cuti, selesai_cuti
        FROM cuti
        WHERE
            nim = :OLD.nim;

        IF (selesai_cuti IS NULL) THEN
            selesai_cuti := SYSDATE;
        END IF;

        INSERT INTO log_cuti VALUES (:OLD.nim, mulai_cuti, selesai_cuti);

        DELETE FROM cuti WHERE nim = :OLD.nim;
    END IF;
END;
