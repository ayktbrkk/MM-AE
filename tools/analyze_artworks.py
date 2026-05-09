from PIL import Image
import os

artworks_dir = r'c:\Users\Aykut\Documents\Godot\mmae\artworks'
files = ['ilk sahne.png', 'mm-ae-independence-war.png', 'sahne 1.png']

for fname in files:
    path = os.path.join(artworks_dir, fname)
    if not os.path.exists(path):
        print(f"!!! DOSYA BULUNAMADI: {path}")
        continue
    
    img = Image.open(path).convert('RGB')
    w, h = img.size
    print(f'')
    print(f'{"="*60}')
    print(f'  DOSYA: {fname}')
    print(f'{"="*60}')
    print(f'  Boyut: {w} x {h} px')
    print(f'  Cozunurluk: {w*h/1e6:.1f} MP')
    print(f'  En-Boy Orani: {w/h:.3f} (portrait: {w<h}, landscape: {w>h})')
    print(f'  Dosya Boyutu: {os.path.getsize(path)/1024:.0f} KB')
    
    # Quantize ile dominant renkler
    small = img.resize((64, 64))
    pal = small.quantize(colors=6)
    palette = pal.getpalette()[:6*3]
    colors = [(palette[i], palette[i+1], palette[i+2]) for i in range(0, 6*3, 3)]
    
    # Renklerin piksel sayilarini hesapla
    color_counts = {}
    for py in range(pal.height):
        for px in range(pal.width):
            idx = pal.getpixel((px, py))
            c = colors[idx]
            color_counts[c] = color_counts.get(c, 0) + 1
    
    sorted_colors = sorted(color_counts.items(), key=lambda x: -x[1])
    print(f'')
    print(f'  DOMINANT RENKLER (en cok 6):')
    for c, count in sorted_colors[:6]:
        pct = count / (pal.width * pal.height) * 100
        print(f'    #{c[0]:02x}{c[1]:02x}{c[2]:02x}  RGB({c[0]},{c[1]},{c[2]})  --- {pct:.0f}%')
    
    # 9 bolge ortalama renk analizi
    regions = {
        'ust-sol':      (0, 0, w//3, h//3),
        'ust-orta':     (w//3, 0, 2*w//3, h//3),
        'ust-sag':      (2*w//3, 0, w, h//3),
        'orta-sol':     (0, h//3, w//3, 2*h//3),
        'merkez':       (w//3, h//3, 2*w//3, 2*h//3),
        'orta-sag':     (2*w//3, h//3, w, 2*h//3),
        'alt-sol':      (0, 2*h//3, w//3, h),
        'alt-orta':     (w//3, 2*h//3, 2*w//3, h),
        'alt-sag':      (2*w//3, 2*h//3, w, h),
    }
    print(f'')
    print(f'  BOLGESEL ORTALAMA RENKLER:')
    for rname, (x1,y1,x2,y2) in regions.items():
        crop = img.crop((x1,y1,x2,y2)).resize((1,1))
        avg = crop.getpixel((0,0))
        print(f'    {rname}: #{avg[0]:02x}{avg[1]:02x}{avg[2]:02x}')
    
    # HSV analizi
    hsv_img = img.convert('HSV')
    pixels = list(hsv_img.getdata())
    n = len(pixels)
    
    # Ton dagilimi (0-180 arasi HSV'de)
    hue_buckets = {'kirmizi(0-15)':0, 'turuncu(16-30)':0, 'sari(31-50)':0, 
                   'yesil(51-85)':0, 'turkuaz(86-110)':0, 'mavi(111-140)':0,
                   'mor(141-165)':0, 'pembe(166-180)':0}
    for p in pixels:
        h = p[0]
        if h <= 15: hue_buckets['kirmizi(0-15)'] += 1
        elif h <= 30: hue_buckets['turuncu(16-30)'] += 1
        elif h <= 50: hue_buckets['sari(31-50)'] += 1
        elif h <= 85: hue_buckets['yesil(51-85)'] += 1
        elif h <= 110: hue_buckets['turkuaz(86-110)'] += 1
        elif h <= 140: hue_buckets['mavi(111-140)'] += 1
        elif h <= 165: hue_buckets['mor(141-165)'] += 1
        else: hue_buckets['pembe(166-180)'] += 1
    
    avg_s = sum(p[1] for p in pixels) / n
    avg_v = sum(p[2] for p in pixels) / n
    
    print(f'')
    print(f'  HSV ANALIZI:')
    print(f'    Ort. Doygunluk: {avg_s/2.55:.0f}%')
    print(f'    Ort. Parlaklik: {avg_v/2.55:.0f}%')
    print(f'    Ton Dagilimi:')
    for bucket, count in sorted(hue_buckets.items(), key=lambda x: -x[1]):
        pct = count / n * 100
        if pct > 1:
            print(f'      {bucket}: {pct:.0f}%')
    
    # Renk paleti karsilastirmasi (VISUAL_DESIGN_SYSTEM.md ile)
    print(f'')
    print(f'  TASARIM SISTEMI RENKLERI ILE KARSILASTIRMA:')
    design_colors = {
        'Deep Navy (#20344F)': (0x20, 0x34, 0x4F),
        'Ocean Slate (#355D78)': (0x35, 0x5D, 0x78),
        'Muted Teal (#5D8F92)': (0x5D, 0x8F, 0x92),
        'Sunset Gold (#F2BE63)': (0xF2, 0xBE, 0x63),
        'Warm Apricot (#E89863)': (0xE8, 0x98, 0x63),
        'Cream Paper (#F5E8D3)': (0xF5, 0xE8, 0xD3),
        'Weathered Walnut (#7A5A42)': (0x7A, 0x5A, 0x42),
        'Story Ink (#2B2730)': (0x2B, 0x27, 0x30),
    }
    for cname, dc in design_colors.items():
        # Find closest dominant color
        min_dist = float('inf')
        closest = None
        for c, _ in sorted_colors:
            dist = ((c[0]-dc[0])**2 + (c[1]-dc[1])**2 + (c[2]-dc[2])**2)**0.5
            if dist < min_dist:
                min_dist = dist
                closest = c
        match = 'ESLESIYOR' if min_dist < 60 else 'yakın' if min_dist < 100 else 'uzak'
        print(f'    {cname}: en yakin #{closest[0]:02x}{closest[1]:02x}{closest[2]:02x} (mesafe:{min_dist:.0f}) [{match}]')

print(f'')
print(f'{"="*60}')
print(f'  ANALIZ TAMAMLANDI')
print(f'{"="*60}')
