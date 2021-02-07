CREATE TABLE aktif (
    nim            VARCHAR2(9 CHAR) NOT NULL,
    tanggal_mulai  DATE
);

ALTER TABLE aktif ADD CONSTRAINT aktif_pk PRIMARY KEY ( nim );

CREATE TABLE cuti (
    nim              VARCHAR2(9 CHAR) NOT NULL,
    tanggal_mulai    DATE,
    tanggal_selesai  DATE
);

ALTER TABLE cuti ADD CONSTRAINT cuti_pk PRIMARY KEY ( nim );

CREATE TABLE dropout (
    nim    VARCHAR2(9 CHAR) NOT NULL,
    no_sk  VARCHAR2(15 CHAR),
    sebab  VARCHAR2(30 CHAR)
);

ALTER TABLE dropout ADD CONSTRAINT dropout_pk PRIMARY KEY ( nim );

CREATE TABLE log_cuti (
    mahasiswa_nim    VARCHAR2(9 CHAR),
    tanggal_mulai    DATE NOT NULL,
    tanggal_selesai  DATE
);

ALTER TABLE log_cuti ADD CONSTRAINT log_cuti_pk PRIMARY KEY ( tanggal_mulai );

CREATE TABLE lulus (
    nim        VARCHAR2(9 CHAR) NOT NULL,
    no_sk      VARCHAR2(15 CHAR),
    no_ijazah  VARCHAR2(15 CHAR)
);

ALTER TABLE lulus ADD CONSTRAINT lulus_pk PRIMARY KEY ( nim );

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

ALTER TABLE dropout
    ADD CONSTRAINT dropout_mahasiswa_fk FOREIGN KEY ( nim )
        REFERENCES mahasiswa ( nim );

ALTER TABLE log_cuti
    ADD CONSTRAINT log_cuti_mahasiswa_fk FOREIGN KEY ( mahasiswa_nim )
        REFERENCES mahasiswa ( nim );

ALTER TABLE lulus
    ADD CONSTRAINT lulus_mahasiswa_fk FOREIGN KEY ( nim )
        REFERENCES mahasiswa ( nim );

CREATE OR REPLACE TRIGGER update_status
    AFTER UPDATE OF status ON mahasiswa
    FOR EACH ROW
DECLARE
    mulai_cuti DATE;
    selesai_cuti DATE;
BEGIN
    IF (((:OlD.status = 'Cuti') AND (:NEW.status = 'Lulus')) or (:OLD.status = 'Dropout') or (:OLD.status = 'Lulus')) THEN
        RAISE_APPLICATION_ERROR(-20101,'Status gagal diubah');
    END IF;

    EXECUTE IMMEDIATE 'INSERT INTO ' || :NEW.status || '(nim) VALUES (' || :NEW.nim || ')';

    IF ((:OLD.status = 'Aktif') AND (:NEW.status = 'Cuti')) THEN
        UPDATE cuti SET tanggal_mulai = SYSDATE WHERE nim = :NEW.nim;
    ELSIF ((:OLD.status = 'Cuti') AND (:NEW.status = 'Aktif')) THEN
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
    END IF;

    EXECUTE IMMEDIATE 'DELETE FROM ' || :OLD.status || ' WHERE nim = ' || :OLD.nim;
END;
