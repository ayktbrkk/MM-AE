# Shader Expert Skill - GLSL/Godot Shading Language Optimizasyonu

Bu skill, Godot 4 shader'larını yazmak ve optimize etmek için kullanılır.

## Godot 4 Shader Yapısı

### Shader Türleri
```glsl
// CanvasItem shader (2D)
shader_type canvas_item;

// Spatial shader (3D)
shader_type spatial;

// Particle shader
shader_type particles;
```

### Render Modları
```glsl
// 2D için önerilen
render_mode blend_mix, unshaded;

// Performans için
render_mode blend_mix, unshaded, lights_omit;
```

### Mobile için Optimizasyon İpuçları

1. **Düşük hassasiyet kullan**
```glsl
// Yüksek performans için mediump tercih et
uniform vec4 u_color : source_color;
varying vec2 v_uv;
varying mediump float v_alpha;
```

2. **Zaman tabanlı animasyonları sınırla**
```glsl
// TIME kullanımı mobile'da maliyetli, sınırlı kullan
float wave = sin(uv.x * 10.0 + TIME * 2.0) * 0.1;
```

3. **Doku okumalarını minimize et**
```glsl
// texture() çağrılarını azalt
// ❌ Çok fazla texture okuması
float r = texture(TEXTURE, uv).r;
float g = texture(TEXTURE, uv + vec2(0.01, 0.0)).g;

// ✅ Tek texture okuması
vec4 tex = texture(TEXTURE, uv);
```

### MMAE Projesi İçin Shader Şablonları

#### Kağıt Diorama Gölgelendirme
```glsl
shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform float u_paper_depth := 0.0;
uniform vec4 u_shadow_color := vec4(0.0, 0.0, 0.0, 0.15);
uniform vec4 u_edge_color := vec4(0.2, 0.15, 0.1, 0.3);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float edge_distance = 1.0 - abs(UV.x - 0.5) * 2.0;
    float shadow = smoothstep(0.1, 0.0, edge_distance) * u_paper_depth;
    COLOR = mix(tex, u_shadow_color, shadow);
    COLOR.rgb = mix(COLOR.rgb, u_edge_color.rgb, u_edge_color.a * (1.0 - edge_distance));
}
```

#### Yumuşak Geçiş (Fade)
```glsl
shader_type canvas_item;
render_mode blend_mix, unshaded;

uniform float u_fade_amount := 0.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    COLOR = tex;
    COLOR.a *= 1.0 - u_fade_amount;
}
```

### Adımlar

1. **Shader türünü belirle** - canvas_item / spatial / particles
2. **Render mode seç** - mobile için blend_mix, unshaded tercih et
3. **Uniform'ları tanımla** - @export ile Godot'tan erişilebilir yap
4. **Fragment işlemlerini yaz** - (veya vertex)
5. **Test et** - Mobile performansı kontrol et
