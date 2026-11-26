CREATE TABLE IF NOT EXISTS sinh_vien (
    id SERIAL PRIMARY KEY,
    ma_sinh_vien VARCHAR(20) UNIQUE NOT NULL,
    ho_ten VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    ngay_tao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO sinh_vien (ma_sinh_vien, ho_ten, email)
VALUES
    ('SV001', 'Sinh vien mau 1', 'sv001@example.com'),
    ('SV002', 'Sinh vien mau 2', 'sv002@example.com'),
    ('SV003', 'Sinh vien mau 3', 'sv003@example.com')
ON CONFLICT (ma_sinh_vien) DO NOTHING;