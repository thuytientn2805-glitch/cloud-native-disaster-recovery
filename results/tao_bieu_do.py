"""Tạo bảng Markdown và biểu đồ SVG từ CSV kết quả bằng Python chuẩn."""
import csv
from pathlib import Path

folder = Path(__file__).resolve().parent
with (folder / "tong-hop-kiem-thu.csv").open(encoding="utf-8-sig", newline="") as source:
    rows = list(csv.DictReader(source))

table = ["| Lần | Phục hồi PostgreSQL (giây) | Số bản ghi |",
         "| ---: | ---: | ---: |"]
values = [float(row["thoi_gian_phuc_hoi_postgresql_giay"]) for row in rows]
scale = 180 / max(values)
width = max(610, 95 + len(rows) * 135)
svg = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="320" viewBox="0 0 {width} 320">',
       '<rect width="100%" height="100%" fill="white"/>',
       '<g font-family="sans-serif" fill="#13304d">',
       '<text x="24" y="28" font-size="20">Thời gian phục hồi PostgreSQL (giây)</text>',
       '<line x1="55" y1="240" x2="570" y2="240" stroke="#13304d"/>']
for index, (row, value) in enumerate(zip(rows, values)):
    run = int(row["lan_kiem_thu"])
    count = int(row["so_ban_ghi_sau_phuc_hoi"])
    table.append(f"| {run} | {value:.2f} | {count} |")
    x = 80 + index * 135
    height = value * scale
    y = 240 - height
    svg.append(f'<rect x="{x}" y="{y}" width="70" height="{height}" fill="#347baa"/>')
    svg.append(f'<text x="{x}" y="{y - 8}">{value:.2f} s</text>')
    svg.append(f'<text x="{x}" y="263">Lần {run}</text>')
svg.append(f'<text x="24" y="302" font-size="14">Giả lập mất dữ liệu bảng trong lab, {len(rows)} lần chạy.</text>')
svg.append("</g></svg>")
(folder / "bang-ket-qua.md").write_text("\n".join(table) + "\n", encoding="utf-8")
(folder / "bieu-do-phuc-hoi.svg").write_text("\n".join(svg) + "\n", encoding="utf-8")
