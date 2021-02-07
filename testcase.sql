INSERT INTO mahasiswa VALUES('191524000', 'Muntu', 'Rumah', 'Aktif');
SELECT * FROM mahasiswa;

INSERT INTO aktif VALUES('191524000', SYSDATE);
SELECT * FROM aktif;

UPDATE mahasiswa SET status = 'Cuti' WHERE nim = '191524000';
SELECT * FROM cuti;

UPDATE mahasiswa SET status = 'Aktif' WHERE nim = '191524000';
SELECT * FROM log_cuti;
