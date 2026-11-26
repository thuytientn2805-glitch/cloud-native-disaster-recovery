import os
import time
from flask import Flask, jsonify, request
import psycopg2
from psycopg2.extras import RealDictCursor

app = Flask(__name__)

TEN_UNG_DUNG = os.getenv("TEN_UNG_DUNG", "Ung dung Cloud Native")
MOI_TRUONG = os.getenv("MOI_TRUONG", "thu-nghiem")


def ket_noi_co_so_du_lieu():
    return psycopg2.connect(
        host=os.getenv("DB_HOST", "localhost"),
        port=os.getenv("DB_PORT", "5432"),
        dbname=os.getenv("DB_NAME", "cloud_native_db"),
        user=os.getenv("DB_USER", "dr_user"),
        password=os.environ["DB_PASSWORD"],
        connect_timeout=5
    )


@app.get("/")
def trang_chu():
    return jsonify({
        "ung_dung": TEN_UNG_DUNG,
        "moi_truong": MOI_TRUONG,
        "trang_thai": "dang_hoat_dong",
        "api": ["/health", "/students", "/students/count"]
    })


@app.get("/health")
def kiem_tra():
    try:
        with ket_noi_co_so_du_lieu() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT 1")
        return jsonify({"app": "OK", "database": "OK"}), 200
    except psycopg2.Error:
        return jsonify({"app": "OK", "database": "ERROR"}), 503


@app.get("/students")
def danh_sach_sinh_vien():
    try:
        with ket_noi_co_so_du_lieu() as conn:
            with conn.cursor(cursor_factory=RealDictCursor) as cur:
                cur.execute("""
                    SELECT id, ma_sinh_vien, ho_ten, email
                    FROM sinh_vien
                    ORDER BY id
                """)
                rows = cur.fetchall()
        return jsonify({
            "so_luong": len(rows),
            "danh_sach": rows
        })
    except psycopg2.Error:
        return jsonify({"loi": "Khong doc duoc du lieu"}), 500


@app.get("/students/count")
def dem_sinh_vien():
    try:
        with ket_noi_co_so_du_lieu() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT COUNT(*) FROM sinh_vien")
                count = cur.fetchone()[0]
        return jsonify({"so_ban_ghi": count})
    except psycopg2.Error:
        return jsonify({"loi": "Khong dem duoc du lieu"}), 500


@app.post("/students")
def them_sinh_vien():
    # API chi danh cho moi truong thu nghiem.
    # Khong cong khai ra Internet khi chua co xac thuc.
    if MOI_TRUONG != "thu-nghiem":
        return jsonify({"loi": "Chi cho phep thu nghiem"}), 403

    data = request.get_json(silent=True) or {}
    ma = data.get("ma_sinh_vien")
    ten = data.get("ho_ten")
    email = data.get("email")

    if not all(isinstance(x, str) and x.strip()
               for x in [ma, ten, email]):
        return jsonify({"loi": "Thieu du lieu hop le"}), 400

    try:
        with ket_noi_co_so_du_lieu() as conn:
            with conn.cursor() as cur:
                cur.execute("""
                    INSERT INTO sinh_vien
                        (ma_sinh_vien, ho_ten, email)
                    VALUES (%s, %s, %s)
                    RETURNING id
                """, (ma, ten, email))
                new_id = cur.fetchone()[0]
        return jsonify({"id": new_id, "ma_sinh_vien": ma}), 201
    except psycopg2.IntegrityError:
        return jsonify({"loi": "Ma sinh vien da ton tai"}), 409
    except psycopg2.Error:
        return jsonify({"loi": "Khong ghi duoc du lieu"}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)