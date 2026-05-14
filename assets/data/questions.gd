extends RefCounted

const _ui_text := preload("res://scripts/ui_text.gd")
const _LOCALIZABLE_FIELDS := [
	"chapter",
	"unit",
	"location",
	"speaker",
	"story",
	"option_a",
	"option_b",
	"retry",
	"info",
]

## =============================================
## BANDIRMA YOLCULUĞU — Hikaye Olayları Veritabanı
## =============================================
## Tüm hikaye akışı, karar mekanikleri ve diyaloglar bu dosyada toplanır.
## 
## Kullanım:
## - `{hero}` placeholder'ı runtime'da oyuncu adı (Arda/Eda) ile değiştirilir
## - `mood` alanı diyalog arkaplanı/atmosferini belirler
## - `kind: "story"` → sıralı diyalog, `kind: "decision"` → A/B karar kartı
## - Her karar `correct` alanıyla hangi seçeneğin doğru olduğunu belirtir
## - `retry` yanlış cevap sonrası, `info` doğru cevap sonrası bilgi kartında gösterilir
##
## Bölüm Yapısı:
##   Giriş     → Sınav Gecesi, Bandırma Vapuru
##   Bölüm 1   → Samsun (19 Mayıs 1919)
##   Bölüm 2   → Havza (28 Mayıs 1919)
##   Bölüm 3   → Amasya (22 Haziran 1919)
##   Bölüm 4   → Erzurum Kongresi (23 Temmuz 1919)
##   Bölüm 5   → Sivas Kongresi (4 Eylül 1919)
##   Bölüm 6   → Ankara & Meclis (23 Nisan 1920)
##   Bölüm 7   → Sakarya & Büyük Taarruz (1921-1922)
##   Final     → Cumhuriyet (29 Ekim 1923)
## =============================================

const GAME_TITLE := "Bandırma Yolculuğu"

const EVENTS := [
	# =============================================
	# BÖLÜM 0: GİRİŞ — SINAV GECESİ
	# =============================================
	# Oyuncu, tarih sınavına çalışmayan bir öğrenci olarak
	# odasında oyun oynarken kitabın kapağını görür.
	# =============================================
	{
		"kind": "story",
		"chapter_key": "story.event.000.chapter",
		"chapter": "Giriş: Sınav Gecesi",
		"unit_key": "story.event.000.unit",
		"unit": "Hazırlık",
		"location_key": "story.event.000.location",
		"location": "Öğrenci Odası",
		"mood": "room",
		"speaker_key": "story.event.000.speaker",
		"speaker": "Anlatıcı",
		"story_key": "story.event.000.story",
		"story": "{hero}, yarınki tarih sınavına çalışmak yerine tabletinde oyun oynar. Masasının üzerindeki kitabın kapağı arada gözüne ilişir. İçten içe çalışması gerektiğini bilir ama oyunun başından kalkamaz.",
		"info_key": "story.event.000.info",
		"info": "Bu bölüm oyunun eğitim kurgusunu başlatır: sınava çalışmayan öğrenci, tarihsel kararların içine düşerek öğrenir."
	},
	{
		"kind": "story",
		"chapter_key": "story.event.001.chapter",
		"chapter": "Giriş: Sınav Gecesi",
		"unit_key": "story.event.001.unit",
		"unit": "Hazırlık",
		"location_key": "story.event.001.location",
		"location": "Öğrenci Odası",
		"mood": "room",
		"speaker_key": "story.event.001.speaker",
		"speaker": "{hero}",
		"story_key": "story.event.001.story",
		"story": "Saat ilerler. {hero} yatağına uzanır, ışığı kapatacakken kitabıyla göz göze gelir. Okuma lambasını yakar ve sorumlu olduğu üniteleri hızlıca okumaya başlar. Satırlar bulanıklaşır, gözleri kapanır.",
		"info_key": "story.event.001.info",
		"info": "Kitaptaki üniteler birazdan oyun bölümlerine dönüşecek."
	},
	{
		"kind": "story",
		"chapter_key": "story.event.002.chapter",
		"chapter": "Giriş: Bandırma Vapuru",
		"unit_key": "story.event.002.unit",
		"unit": "Milli Mücadeleye Hazırlık",
		"location_key": "story.event.002.location",
		"location": "Bandırma Vapuru Kamarası",
		"mood": "ship",
		"speaker_key": "story.event.002.speaker",
		"speaker": "Anlatıcı",
		"story_key": "story.event.002.story",
		"story": "{hero} gözlerini açtığında dalga sesleri duyar. Küçük bir kamaradadır. Yatağın başında ona tam uyan bir asker üniforması asılıdır. Aynaya baktığında hâlâ kendisidir, ama artık tarih kitabının içindedir.",
		"info_key": "story.event.002.info",
		"info": "Oyuncu tarihsel bir kişinin yerine geçmez; tarihsel durumun sorumluluğunu taşıyan öğrenci karakter olarak karar verir."
	},

	# =============================================
	# BÖLÜM 1: SAMSUN — MİLLİ MÜCADELE BAŞLIYOR
	# =============================================
	# Tarih: 19 Mayıs 1919
	# Mustafa Kemal Paşa, Bandırma Vapuru ile Samsun'a çıkar.
	# İşgal altındaki vatanı kurtarmak için ilk adım atılır.
	# =============================================
	{
		"kind": "story",
		"chapter_key": "story.event.003.chapter",
		"chapter": "Bölüm 1: Samsun'a Çıkış",
		"unit_key": "story.event.003.unit",
		"unit": "19 Mayıs 1919",
		"location_key": "story.event.003.location",
		"location": "Samsun Limanı",
		"mood": "arrival",
		"speaker_key": "story.event.003.speaker",
		"speaker": "Anlatıcı",
		"story_key": "story.event.003.story",
		"story": "Gemi Samsun açıklarına yanaşır. {hero} güverteye çıktığında, Karadeniz'in mavi suları ve yeşil yamaçlarla kaplı bir şehir görür. Ama her şey göründüğü kadar huzurlu değildir. Şehirde yabancı askerler vardır, halk endişeli ve tedirgindir.",
		"info_key": "story.event.003.info",
		"info": "19 Mayıs 1919'da Mustafa Kemal Paşa, 9. Ordu Müfettişi olarak Samsun'a çıktı. Bu tarih, Milli Mücadele'nin fiilen başladığı gün olarak kabul edilir."
	},
	{
		"kind": "story",
		"chapter_key": "story.event.004.chapter",
		"chapter": "Bölüm 1: Samsun'a Çıkış",
		"unit_key": "story.event.004.unit",
		"unit": "İlk Adım",
		"location_key": "story.event.004.location",
		"location": "Samsun Limanı",
		"mood": "arrival",
		"speaker_key": "story.event.004.speaker",
		"speaker": "Güvertedeki Subay",
		"story_key": "story.event.004.story",
		"story": "\"Hoş geldin, yolcu!\" der gülümseyerek. \"Burası Samsun. Vatanın kurtuluş yolculuğu burada başlıyor. Etrafına iyi bak. Görecek çok şey var.\" Subay, {hero}'nun omzuna hafifçe vurur ve görevinin önemini hissettirir.",
		"info_key": "story.event.004.info",
		"info": "Mustafa Kemal Paşa, Samsun'a çıktığında önce şehrin durumunu gözlemledi. İşgallerin halk üzerindeki etkisini yerinde görmek istiyordu."
	},
	{
		"kind": "decision",
		"chapter_key": "story.event.005.chapter",
		"chapter": "Bölüm 1: Samsun'a Çıkış",
		"unit_key": "story.event.005.unit",
		"unit": "İlk Karar",
		"location_key": "story.event.005.location",
		"location": "Bandırma Vapuru Güvertesi",
		"mood": "ship",
		"speaker_key": "story.event.005.speaker",
		"speaker": "Güvertedeki Öğrenci Asker",
		"story_key": "story.event.005.story",
		"story": "Gemi limana yaklaşırken güvertedeki herkes endişelidir. Birileri hızlıca halka seslenmeyi önerir. {hero}, ilk kararını vermek zorundadır. Ne yapmalı?",
		"option_a_key": "story.event.005.option_a",
		"option_a": "Karaya çıkar çıkmaz plansızca herkese seslen.",
		"option_b_key": "story.event.005.option_b",
		"option_b": "Önce durumu gözlemle ve güvenilir kişilerle bağlantı kur.",
		"correct": "b",
		"retry_key": "story.event.005.retry",
		"retry": "İlk adım önemli ama plansız bir çıkış hem görevi hem insanları riske atabilir. Önce durumu anlamak, sonra harekete geçmek gerekir.",
		"info_key": "story.event.005.info",
		"info": "Samsun'a çıkış, Milli Mücadele'nin başlangıcıdır. Mustafa Kemal Paşa, önce şehrin durumunu gözlemlemiş, güvenilir kişilerle temas kurmuş ve örgütlü hareket etmiştir."
	},
	{
		"kind": "decision",
		"chapter_key": "story.event.006.chapter",
		"chapter": "Bölüm 1: Samsun'a Çıkış",
		"unit_key": "story.event.006.unit",
		"unit": "İlk Temas",
		"location_key": "story.event.006.location",
		"location": "Samsun Şehir Merkezi",
		"mood": "city",
		"speaker_key": "story.event.006.speaker",
		"speaker": "{hero}",
		"story_key": "story.event.006.story",
		"story": "{hero} şehirde dolaşırken bir kahvehanede toplanan ileri gelenlerle karşılaşır. Kimisi çekingen, kimisi cesurdur. {hero}, Milli Mücadele fikrini ilk kime açmalıdır?",
		"option_a_key": "story.event.006.option_a",
		"option_a": "Güvendiğin birkaç kişiyle özel olarak konuş.",
		"option_b_key": "story.event.006.option_b",
		"option_b": "Kahvehanedeki herkese açıkça seslen.",
		"correct": "a",
		"retry_key": "story.event.006.retry",
		"retry": "Herkesin içinde konuşmak cesurca olabilir ama düşman casusları da dinliyor olabilir. Önce güvenilir bir çekirdek oluşturmak daha akıllıca.",
		"info_key": "story.event.006.info",
		"info": "Mustafa Kemal Paşa, Samsun'da önce güvendiği kişilerle görüştü. Haberleşme ve örgütlenme, gizlilik içinde yürütülmesi gereken hassas süreçlerdi."
	},

	# =============================================
	# BÖLÜM 2: HAVZA — MİLLİ BİLİNÇ UYANIYOR
	# =============================================
	# Tarih: 28 Mayıs 1919
	# Havza Genelgesi yayınlanır. İşgallere karşı
	# milli bilinç uyandırma çağrısı yapılır.
	# =============================================
	{
		"kind": "story",
		"chapter": "Bölüm 2: Havza Genelgesi",
		"unit": "Havza'ya Varış",
		"location": "Havza Yolu",
		"mood": "road",
		"speaker": "Anlatıcı",
		"story": "Samsun'dan ayrılan {hero}, Havza'ya doğru yola çıkar. Yol boyunca köylüler, çiftçiler ve esnafla karşılaşır. Herkes aynı şeyi söyler: \"İşgaller canımızı yakıyor, ama ne yapacağımızı bilmiyoruz.\" Halkın bir yol göstericiye ihtiyacı vardır.",
		"info": "Mustafa Kemal Paşa, Samsun'dan Havza'ya geçerek halkın nabzını tuttu. Havza, Milli Mücadele'nin örgütlenme sürecinde önemli bir duraktı."
	},
	{
		"kind": "decision",
		"chapter": "Bölüm 2: Havza Genelgesi",
		"unit": "Havza Genelgesi",
		"location": "Havza",
		"mood": "road",
		"speaker": "{hero}",
		"story": "Ülkede işgallere karşı tepki vardır ama herkes dağınık davranmaktadır. {hero}, halkın sesini nasıl duyuracağını düşünür. Mitingler mi düzenlenmeli, yoksa sessiz kalınıp beklenmeli mi?",
		"option_a": "Milleti bilinçli ve düzenli protestolara çağır.",
		"option_b": "Kimseyi uyarmadan tek başına hareket et.",
		"correct": "a",
		"retry": "Tek başına hareket etmek hızlı görünür ama milli mücadele halkın bilinçli katılımıyla güçlenir. Örgütlü protesto, işgallere karşı durmanın en etkili yoludur.",
		"info": "Havza Genelgesi, işgallere karşı milli bilinci uyandırmayı ve protestoları örgütlü hale getirmeyi amaçladı. 28 Mayıs 1919'da yayınlanan genelge, halkı işgaller karşısında tepki göstermeye çağırdı."
	},
	{
		"kind": "decision",
		"chapter": "Bölüm 2: Havza Genelgesi",
		"unit": "Haberleşme Ağı",
		"location": "Havza Telgrafhanesi",
		"mood": "city",
		"speaker": "Telgrafçı",
		"story": "Havza'da telgrafhanenin önünde uzun bir kuyruk vardır. Herkes haberleşmek, birbirine destek olmak ister. Ama düşman da telgraf hatlarını dinlemektedir. {hero}, haberleşme için hangi yöntemi seçmeli?",
		"option_a": "Telgrafla her iletişimi açık yap, hızlı olsun.",
		"option_b": "Güvenilir ulaklarla ve şifreli mesajlarla haberleş.",
		"correct": "b",
		"retry": "Telgraf hızlıdır ama düşman da aynı hatları dinliyor olabilir. Güvenilir ulaklar yavaş ama emniyetlidir. Milli Mücadele'de haberleşme güvenliği hayati önem taşır.",
		"info": "Mustafa Kemal Paşa, Havza'da telgraf ve ulak sistemini kullanarak bir haberleşme ağı kurdu. Bu ağ, Anadolu'daki tüm direniş gruplarının koordinasyonunu sağladı."
	},

	# =============================================
	# BÖLÜM 3: AMASYA — BAĞIMSIZLIK KARARI
	# =============================================
	# Tarih: 22 Haziran 1919
	# Amasya Genelgesi yayınlanır. "Milletin bağımsızlığını
	# yine milletin azim ve kararı kurtaracaktır."
	# =============================================
	{
		"kind": "story",
		"chapter": "Bölüm 3: Amasya Genelgesi",
		"unit": "Amasya'ya Varış",
		"location": "Amasya",
		"mood": "city",
		"speaker": "Anlatıcı",
		"story": "{hero}, Havza'dan sonra Amasya'ya ulaşır. Burası daha sessiz, daha düşünceli bir yerdir. Yeşilırmak boyunca uzanan evler, tarihi taş köprüler ve gökyüzüne uzanan minareler... Ama {hero}'nun aklı bir karar vermekle meşguldür: Vatan nasıl kurtulacak?",
		"info": "Amasya, Milli Mücadele'nin en kritik kararlarından birine ev sahipliği yaptı. Burada alınan kararlar, bağımsızlık mücadelesinin yol haritasını belirledi."
	},
	{
		"kind": "decision",
		"chapter": "Bölüm 3: Amasya Genelgesi",
		"unit": "Bağımsızlık Düşüncesi",
		"location": "Amasya",
		"mood": "city",
		"speaker": "Anlatıcı",
		"story": "Sorun büyüktür: vatanın bütünlüğü tehlikededir. {hero}, çözümün kimden geleceğini açıklayan en doğru fikri seçmelidir. Millet kendi kaderini tayin edebilir mi, yoksa başkalarının yardımını mı beklemeli?",
		"option_a": "Milletin bağımsızlığını yine milletin azmi ve kararı kurtarır.",
		"option_b": "Her şeyi başkalarının kararına bırakalım.",
		"correct": "a",
		"retry": "Bu yolculuğun temel fikri dışarıdan beklemek değil, milletin kendi iradesidir. Hiçbir dış güç, milletin bağımsızlığını onun kadar isteyemez.",
		"info": "Amasya Genelgesi, Milli Mücadele'nin amaç ve yöntemini ortaya koyan dönüm noktasıdır. \"Milletin bağımsızlığını yine milletin azim ve kararı kurtaracaktır\" sözü, mücadelenin temel felsefesini belirler."
	},
	{
		"kind": "story",
		"chapter": "Bölüm 3: Amasya Genelgesi",
		"unit": "Amasya Kararları",
		"location": "Amasya",
		"mood": "city",
		"speaker": "{hero}",
		"story": "Amasya'da alınan kararlar bir bir açıklanır: Vatan bir bütündür, parçalanamaz. İstanbul Hükümeti görevini yapamaz hale gelmiştir. Milletin iradesini temsil edecek bir kurul toplanmalıdır. {hero}, bu kararların her birini bir bilgi yıldızı olarak toplar.",
		"info": "Amasya Genelgesi'nin üç ana maddesi: 1) Vatanın bütünlüğü tehlikededir. 2) İstanbul Hükümeti görevini yapamamaktadır. 3) Milletin bağımsızlığını milletin azim ve kararı kurtaracaktır."
	},
	{
		"kind": "decision",
		"chapter": "Bölüm 3: Amasya Genelgesi",
		"unit": "Kongre Hazırlığı",
		"location": "Amasya",
		"mood": "city",
		"speaker": "Temsilci Adayı",
		"story": "Bir kongre toplanmasına karar verilir. Ama her şehirden kimler katılmalıdır? Bazıları sadece paşaları, bazıları halktan kişileri önerir. {hero}, kongreye katılacak temsilcilerin nasıl seçileceğine karar vermelidir.",
		"option_a": "Her ilden halkın güvendiği seçilmiş temsilciler katılsın.",
		"option_b": "Sadece asker ve paşalar karar versin, halk karışmasın.",
		"correct": "a",
		"retry": "Milli Mücadele, sadece askerlerin değil, tüm milletin katılımıyla başarıya ulaşabilir. Halkın temsil edilmesi, alınan kararların meşruiyetini güçlendirir.",
		"info": "Erzurum ve Sivas Kongreleri'ne farklı illerden, farklı meslek gruplarından temsilciler katıldı. Bu, Milli Mücadele'nin gerçekten milli bir hareket olmasını sağladı."
	},

	# =============================================
	# BÖLÜM 4: ERZURUM KONGRESİ
	# =============================================
	# Tarih: 23 Temmuz - 7 Ağustos 1919
	# Doğu Anadolu'nun temsilcileri bir araya gelir.
	# İlk büyük kongre: milli sınırlar, manda ve himaye reddi.
	# =============================================
	{
		"kind": "story",
		"chapter": "Bölüm 4: Erzurum Kongresi",
		"unit": "Doğu'nun Sesi",
		"location": "Erzurum Kongre Binası",
		"mood": "hall",
		"speaker": "Anlatıcı",
		"story": "Erzurum, Doğu Anadolu'nun en büyük şehridir. {hero}, kongre binasına girdiğinde farklı şehirlerden gelen temsilcileri görür. Herkesin yüzünde aynı ifade vardır: kararlılık. Bu kongre, Milli Mücadele'nin ilk büyük buluşmasıdır.",
		"info": "Erzurum Kongresi, 23 Temmuz - 7 Ağustos 1919 tarihleri arasında toplandı. 54 delege, Doğu vilayetlerini temsil etmek üzere bir araya geldi."
	},
	{
		"kind": "decision",
		"chapter": "Bölüm 4: Erzurum Kongresi",
		"unit": "Manda ve Himaye",
		"location": "Erzurum Kongre Binası",
		"mood": "hall",
		"speaker": "Kongredeki Temsilci",
		"story": "Tartışmalar kızışır. Bazı temsilciler, güçlü bir devletin himayesine girmeyi önerir. \"Tek başımıza yapamayız, bir büyük devletin koruması altına girelim\" derler. {hero} bu fikre katılmalı mıdır?",
		"option_a": "Tam bağımsızlık! Ne manda ne himaye kabul edilemez.",
		"option_b": "Bir süreliğine bir devletin himayesine girelim, sonra bakarız.",
		"correct": "a",
		"retry": "Bir devletin himayesine girmek, bağımsızlıktan vazgeçmek demektir. Milli Mücadele'nin hedefi tam bağımsızlıktır. Ne manda ne himaye kabul edilemez.",
		"info": "Erzurum Kongresi'nde alınan en önemli kararlardan biri, manda ve himayenin reddedilmesidir. Kongre, tam bağımsızlık ilkesini benimsemiştir."
	},
	{
		"kind": "story",
		"chapter": "Bölüm 4: Erzurum Kongresi",
		"unit": "İlk Temsil Heyeti",
		"location": "Erzurum Kongre Binası",
		"mood": "hall",
		"speaker": "Anlatıcı",
		"story": "Erzurum Kongresi'nin en önemli sonucu, Temsil Heyeti'nin kurulmasıdır. Mustafa Kemal Paşa başkan seçilir. Artık milletin sesini duyuracak, kararları alacak bir kurul vardır. {hero}, bu tarihi ana tanıklık eder.",
		"info": "Erzurum Kongresi'nde seçilen Temsil Heyeti, Milli Mücadele'nin yürütme organı haline geldi. Mustafa Kemal Paşa, Temsil Heyeti Başkanı seçildi."
	},

	# =============================================
	# BÖLÜM 5: SİVAS KONGRESİ
	# =============================================
	# Tarih: 4-11 Eylül 1919
	# Tüm milli cemiyetler tek çatı altında birleşir.
	# Vatanın bütünlüğü ve bağımsızlık kararı pekişir.
	# =============================================
	{
		"kind": "story",
		"chapter": "Bölüm 5: Sivas Kongresi",
		"unit": "Birlik Zamanı",
		"location": "Sivas Kongre Binası",
		"mood": "hall",
		"speaker": "Anlatıcı",
		"story": "Sivas, Anadolu'nun ortasında bir kavşak gibidir. {hero} buraya geldiğinde, her taraftan delegelerin akın ettiğini görür. Artık sadece Doğu değil, tüm vatan temsil edilecektir. Bu kongre, herkesi birleştirecek kararların alınacağı yerdir.",
		"info": "Sivas Kongresi, 4-11 Eylül 1919 tarihleri arasında toplandı. Ülkenin dört bir yanından gelen delegeler, milli iradeyi temsil etmek üzere bir araya geldi."
	},
	{
		"kind": "decision",
		"chapter": "Bölüm 5: Sivas Kongresi",
		"unit": "Birlik Kararı",
		"location": "Sivas Kongre Binası",
		"mood": "hall",
		"speaker": "Kongredeki Temsilci",
		"story": "Farklı şehirlerden gelen temsilciler aynı masadadır. Herkesin ortak bir karar çevresinde birleşmesi gerekir. Bazı cemiyetler kendi bölgelerinde bağımsız kalmak ister. {hero}, bu dağınık güçleri nasıl birleştirmeli?",
		"option_a": "Yerel direnişleri birbirinden ayrı tut, her bölge kendi başına hareket etsin.",
		"option_b": "Milli cemiyetleri tek amaç etrafında birleştir: Anadolu ve Rumeli Müdafaa-i Hukuk.",
		"correct": "b",
		"retry": "Ayrı ayrı çabalar değerli olsa da ortak hedef olmadan mücadele zayıf kalır. Birlikten kuvvet doğar. Tüm cemiyetler tek çatı altında toplanmalıdır.",
		"info": "Sivas Kongresi'nde tüm milli cemiyetler 'Anadolu ve Rumeli Müdafaa-i Hukuk Cemiyeti' çatısı altında birleştirildi. Bu birlik, mücadelenin en önemli güç kaynağı oldu."
	},
	{
		"kind": "story",
		"chapter": "Bölüm 5: Sivas Kongresi",
		"unit": "Temsil Heyeti",
		"location": "Sivas Kongre Binası",
		"mood": "hall",
		"speaker": "{hero}",
		"story": "Sivas Kongresi sona erer. Temsil Heyeti artık tüm vatanı temsil etmektedir. {hero}, kongre binasından çıkarken gökyüzünde dalgalanan bayrağı görür. \"Bu daha başlangıç,\" diye fısıldar içinden. \"Önümüzde uzun bir yol var.\"",
		"info": "Sivas Kongresi'nden sonra Temsil Heyeti, İstanbul Hükümeti ile resmi yazışmalara başladı. Artık Milli Mücadele, ulusal ve uluslararası alanda tanınan bir hareketti."
	},

	# =============================================
	# BÖLÜM 6: ANKARA — MECLİS VE İRADE
	# =============================================
	# Tarih: 27 Aralık 1919 / 23 Nisan 1920
	# Temsil Heyeti Ankara'ya yerleşir.
	# Büyük Millet Meclisi açılır.
	# =============================================
	{
		"kind": "story",
		"chapter": "Bölüm 6: Ankara'ya Yol",
		"unit": "Temsil Heyeti ve Meclis",
		"location": "Ankara Yolu",
		"mood": "road",
		"speaker": "Anlatıcı",
		"story": "Sivas'tan sonra sıra Ankara'ya gelir. Temsil Heyeti, çalışmalarını nereden yürüteceğine karar vermelidir. {hero}, yolculuk boyunca Anadolu bozkırını, köyleri, kasabaları görür. Her yer aynı umudu taşır: kurtuluş.",
		"info": "Mustafa Kemal Paşa ve Temsil Heyeti, 27 Aralık 1919'da Ankara'ya geldi. Ankara, ulaşım ve haberleşme açısından stratejik konumuyla Milli Mücadele'nin merkezi oldu."
	},
	{
		"kind": "decision",
		"chapter": "Bölüm 6: Ankara'ya Yol",
		"unit": "Merkez Seçimi",
		"location": "Ankara Yolu",
		"mood": "road",
		"speaker": "{hero}",
		"story": "Mücadeleyi sürdürebilmek için güvenli ve stratejik bir merkez gerekir. Herkes farklı bir şehir önermektedir. {hero}, bu kritik seçimi yapmak zorundadır.",
		"option_a": "Ankara'ya gidip çalışmaları oradan yürüt.",
		"option_b": "Rastgele bir şehir seç ve bekle.",
		"correct": "a",
		"retry": "Merkez seçimi rastgele yapılamaz; ulaşım, güvenlik ve haberleşme düşünülmelidir. Ankara, demiryolu bağlantısı ve güvenli konumuyla en doğru seçimdir.",
		"info": "Ankara, Milli Mücadele'nin yönetim merkezi haline geldi. Şehir, hem İstanbul'a yakınlığı hem de Anadolu'nun ortasında olması nedeniyle stratejik öneme sahipti."
	},
	{
		"kind": "story",
		"chapter": "Bölüm 6: Ankara'ya Yol",
		"unit": "Meclis'in Açılışı",
		"location": "Ankara - Meclis Binası",
		"mood": "hall",
		"speaker": "Anlatıcı",
		"story": "23 Nisan 1920... {hero}, Ankara'da tarihi bir güne tanıklık eder. Büyük Millet Meclisi açılmaktadır. Her ilden seçilmiş vekiller, milletin iradesini temsil etmek üzere toplanmıştır. {hero}, bu büyük günde Meclis binasının önünde durur ve içeri giren vekilleri izler.",
		"info": "23 Nisan 1920'de Büyük Millet Meclisi açıldı. Meclis, hem yasama hem yürütme yetkilerini üstlenerek Milli Mücadele'yi yönetti. Bu tarih, aynı zamanda Ulusal Egemenlik ve Çocuk Bayramı olarak kutlanır."
	},
	{
		"kind": "decision",
		"chapter": "Bölüm 6: Ankara'ya Yol",
		"unit": "Meclis'in Gücü",
		"location": "Ankara - Meclis Binası",
		"mood": "hall",
		"speaker": "Meclis Vekili",
		"story": "Meclis açılmıştır ama herkes farklı fikirdedir. Kimi hemen savaş ilan edilmesini, kimi beklenmesini ister. {hero}, Meclis'in nasıl karar alması gerektiği konusunda fikrini söylemelidir.",
		"option_a": "Meclis'te her fikir tartışılsın ama son kararı millet adına seçilenler versin.",
		"option_b": "Herkes istediği gibi hareket etsin, kimse kimseye karışmasın.",
		"correct": "a",
		"retry": "Dağınık hareket etmek, mücadeleyi zayıflatır. Meclis, milletin iradesini temsil eder ve kararlar ortak akılla alınmalıdır.",
		"info": "Büyük Millet Meclisi, açılışından itibaren milli iradenin en yüksek temsil organı oldu. Meclis'te alınan kararlar, ordunun sevk ve idaresinden yasaların yapılmasına kadar her alanda belirleyiciydi."
	},

	# =============================================
	# BÖLÜM 7: SAKARYA & BÜYÜK TAARRUZ
	# =============================================
	# Tarih: 23 Ağustos - 13 Eylül 1921 (Sakarya)
	#        26 Ağustos - 9 Eylül 1922 (Büyük Taarruz)
	# Sakarya Meydan Muharebesi ve Büyük Taarruz ile
	# vatan düşman işgalinden kurtarılır.
	# =============================================
	{
		"kind": "story",
		"chapter": "Bölüm 7: Sakarya ve Büyük Taarruz",
		"unit": "Sakarya Öncesi",
		"location": "Cephe Karargahı",
		"mood": "war",
		"speaker": "Anlatıcı",
		"story": "Yıl 1921... Düşman orduları Ankara'ya doğru ilerlemektedir. {hero}, cephe karargahında çalışan genç bir gönüllüdür. Herkes gergindir. Sakarya Nehri'nin doğusunda büyük bir savaş yaklaşmaktadır. Mustafa Kemal Paşa, \"Hatt-ı müdafaa yoktur, sath-ı müdafaa vardır. O satıh bütün vatandır!\" emrini verir.",
		"info": "Sakarya Meydan Muharebesi, 23 Ağustos - 13 Eylül 1921 tarihleri arasında 22 gün sürdü. Mustafa Kemal Paşa, bu savaşta Başkomutan olarak bizzat cepheyi yönetti."
	},
	{
		"kind": "decision",
		"chapter": "Bölüm 7: Sakarya ve Büyük Taarruz",
		"unit": "Savunma Stratejisi",
		"location": "Sakarya Cephesi",
		"mood": "war",
		"speaker": "Cephedeki Subay",
		"story": "Düşman sayıca üstündür ve ağır silahları vardır. Subay, {hero}'ya dönüp \"Ne yapmalıyız?\" diye sorar. Bazıları geri çekilmeyi, bazıları olduğu yerde savaşmayı önerir. {hero} ne yapılması gerektiğini düşünür.",
		"option_a": "Geri çekilme! Vatanın her karış toprağı savunulmalı, herkes elinden geleni yapmalı.",
		"option_b": "Çok zor durumdayız, teslim olup barış isteyelim.",
		"correct": "a",
		"retry": "Zor durumda teslim olmak, tüm mücadeleyi anlamsız kılar. Vatan savunmasında herkes üzerine düşeni yapmalı, asla pes etmemelidir.",
		"info": "Sakarya Meydan Muharebesi, Türk ordusunun savunma zaferidir. Mustafa Kemal Paşa'nın 'Hatt-ı müdafaa yoktur, sath-ı müdafaa vardır' sözü, topyekün savunma anlayışını ifade eder."
	},
	{
		"kind": "story",
		"chapter": "Bölüm 7: Sakarya ve Büyük Taarruz",
		"unit": "Büyük Taarruz",
		"location": "Dumlupınar",
		"mood": "war",
		"speaker": "Anlatıcı",
		"story": "26 Ağustos 1922 sabahı... {hero}, şafak vakti top sesleriyle uyanır. Büyük Taarruz başlamıştır! Günlerce süren hazırlık, artık meyvesini vermektedir. Türk ordusu, düşmanı Dumlupınar'da kuşatır. {hero}, zaferin habercisi olan bu büyük anı izler.",
		"info": "Büyük Taarruz, 26 Ağustos 1922'de başladı. 30 Ağustos'ta Dumlupınar Meydan Muharebesi kazanıldı. 9 Eylül'de İzmir kurtarıldı. Vatan, düşman işgalinden temizlendi."
	},
	{
		"kind": "decision",
		"chapter": "Bölüm 7: Sakarya ve Büyük Taarruz",
		"unit": "Zafer Sonrası",
		"location": "İzmir",
		"mood": "arrival",
		"speaker": "{hero}",
		"story": "Savaş sona ermiştir. {hero}, İzmir sokaklarında yürürken insanların sevinç gözyaşlarına tanık olur. Şimdi sıra kalıcı barışı kurmaya gelmiştir. {hero}, zaferden sonra en doğru yolun ne olduğunu düşünür.",
		"option_a": "Barış antlaşması yap, cumhuriyeti ilan et ve yeni bir ülke inşa et.",
		"option_b": "Zafer yeter, her şey eskisi gibi devam etsin.",
		"correct": "a",
		"retry": "Zafer kazanılmıştır ama kalıcı barış ve düzen için yeni bir yönetim şekli gereklidir. Eskisi gibi devam etmek, kazanılan zaferi anlamsız kılabilir.",
		"info": "Zaferden sonra 24 Temmuz 1923'te Lozan Antlaşması imzalandı. 29 Ekim 1923'te Cumhuriyet ilan edildi. Böylece Milli Mücadele, tam bağımsız bir devletle taçlandı."
	},

	# =============================================
	# FİNAL: CUMHURİYET'E GİDEN YOL
	# =============================================
	# Tarih: 29 Ekim 1923
	# Cumhuriyet ilan edilir. Egemenlik kayıtsız şartsız
	# milletindir. Oyunun duygusal ve eğitimsel kapanışı.
	# =============================================
	{
		"kind": "story",
		"chapter": "Final: Cumhuriyet",
		"unit": "Yeni Devlet",
		"location": "Ankara - Meclis Binası",
		"mood": "hall",
		"speaker": "Anlatıcı",
		"story": "29 Ekim 1923... {hero}, Ankara'da Meclis'in önünde beklemektedir. İçeride tarihi bir karar alınır: Cumhuriyet ilan edilmiştir. Artık yönetim şekli değişmiş, egemenlik kayıtsız şartsız millete geçmiştir. {hero}, gökyüzünde dalgalanan bayrağı ve gülümseyen insanları izler.",
		"info": "29 Ekim 1923'te Cumhuriyet ilan edildi. Mustafa Kemal Atatürk, Türkiye Cumhuriyeti'nin ilk Cumhurbaşkanı seçildi. Egemenlik artık kayıtsız şartsız milletindir."
	},
	{
		"kind": "decision",
		"chapter": "Final: Cumhuriyet",
		"unit": "Gelecek Vizyonu",
		"location": "Ankara - Meclis Binası",
		"mood": "hall",
		"speaker": "{hero}",
		"story": "Rüyanın sonuna gelinmiştir. {hero}, önünde uzanan bir yol görür: eğitim, bilim, sanat, kalkınma... Atatürk'ün \"En büyük eserim\" dediği Cumhuriyet, artık gençlerin omuzlarındadır. {hero} bu büyük yolculuktan ne öğrenmiştir?",
		"option_a": "Bağımsızlığın, birliğin ve millet iradesinin önemini öğrendim. Şimdi sıra bende!",
		"option_b": "Tarih sadece geçmişte kalan bir hikaye, benimle ilgisi yok.",
		"correct": "a",
		"retry": "Tarih sadece geçmiş değildir. Bugün sahip olduğumuz bağımsızlık, o günkü kararlar sayesinde kazanıldı. Herkes üzerine düşeni yapmalıdır.",
		"info": "Cumhuriyet, \"en büyük eser\" olarak gençlere emanet edilmiştir. Atatürk'ün \"Benim naçiz vücudum elbet bir gün toprak olacaktır, fakat Türkiye Cumhuriyeti ilelebet payidar kalacaktır\" sözü, bu mirasın önemini anlatır."
	},
	{
		"kind": "story",
		"chapter": "Final: Uyanış",
		"unit": "Sınav Sabahı",
		"location": "Öğrenci Odası",
		"mood": "room",
		"speaker": "Anlatıcı",
		"story": "Güneş ışınları perdenin arasından sızar. {hero}, gözlerini yavaşça açar. Masada duran kitap, rüyada gördüğü tüm yerleri anlatmaktadır. {hero} gülümser. Tarih sınavına artık hazırdır. Çünkü tarih, sadece okunacak bir şey değil; hissedilecek ve anlaşılacak bir yolculuktur.",
		"info": "Oyun, öğrencinin tarihsel empati kurarak öğrenmesini amaçlar. {hero} artık sadece ezberlemiş değil, anlamıştır."
	}
]


static func localized_event(event_index: int, hero_name: String = "") -> Dictionary:
	if event_index < 0 or event_index >= EVENTS.size():
		return {}
	return localized_event_data(EVENTS[event_index], hero_name, event_index)


static func localized_event_data(event_data: Dictionary, hero_name: String = "", event_index: int = -1) -> Dictionary:
	var resolved := event_data.duplicate(true)
	for field_name in _LOCALIZABLE_FIELDS:
		var fallback := String(resolved.get(field_name, ""))
		var key_name := "%s_key" % field_name
		var translation_key := ""
		if resolved.has(key_name):
			translation_key = String(resolved.get(key_name, ""))
		elif event_index >= 0 and not fallback.is_empty():
			translation_key = event_text_key(event_index, field_name)
		if not translation_key.is_empty():
			resolved[field_name] = _ui_text.text(translation_key, fallback)
		elif not fallback.is_empty():
			resolved[field_name] = fallback
		if not hero_name.is_empty() and resolved.get(field_name, null) is String:
			resolved[field_name] = String(resolved[field_name]).replace("{hero}", hero_name)
	return resolved


static func event_text_key(event_index: int, field_name: String) -> String:
	return "story.event.%03d.%s" % [event_index, field_name]
