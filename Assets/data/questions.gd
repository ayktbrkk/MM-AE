extends RefCounted

const GAME_TITLE := "Bandırma Yolculuğu"

const EVENTS := [
	{
		"kind": "story",
		"chapter": "Giriş: Sınav Gecesi",
		"unit": "Hazırlık",
		"location": "Öğrenci Odası",
		"mood": "room",
		"speaker": "Anlatıcı",
		"story": "{hero}, yarınki tarih sınavına çalışmak yerine tabletinde oyun oynar. Masasının üzerindeki kitabın kapağı arada gözüne ilişir. İçten içe çalışması gerektiğini bilir ama oyunun başından kalkamaz.",
		"info": "Bu bölüm oyunun eğitim kurgusunu başlatır: sınava çalışmayan öğrenci, tarihsel kararların içine düşerek öğrenir."
	},
	{
		"kind": "story",
		"chapter": "Giriş: Sınav Gecesi",
		"unit": "Hazırlık",
		"location": "Öğrenci Odası",
		"mood": "room",
		"speaker": "{hero}",
		"story": "Saat ilerler. {hero} yatağına uzanır, ışığı kapatacakken kitabıyla göz göze gelir. Okuma lambasını yakar ve sorumlu olduğu üniteleri hızlıca okumaya başlar. Satırlar bulanıklaşır, gözleri kapanır.",
		"info": "Kitaptaki üniteler birazdan oyun bölümlerine dönüşecek."
	},
	{
		"kind": "story",
		"chapter": "Giriş: Bandırma Vapuru",
		"unit": "Milli Mücadeleye Hazırlık",
		"location": "Bandırma Vapuru Kamarası",
		"mood": "ship",
		"speaker": "Anlatıcı",
		"story": "{hero} gözlerini açtığında dalga sesleri duyar. Küçük bir kamaradadır. Yatağın başında ona tam uyan bir asker üniforması asılıdır. Aynaya baktığında hâlâ kendisidir, ama artık tarih kitabının içindedir.",
		"info": "Oyuncu tarihsel bir kişinin yerine geçmez; tarihsel durumun sorumluluğunu taşıyan öğrenci karakter olarak karar verir."
	},
	{
		"kind": "decision",
		"chapter": "Bölüm 1: Samsun'a Çıkış",
		"unit": "Milli Mücadele Başlıyor",
		"location": "Bandırma Vapuru Güvertesi",
		"mood": "ship",
		"speaker": "Güvertedeki Öğrenci Asker",
		"story": "Gemi limana yaklaşırken güvertedeki herkes endişelidir. Birileri hızlıca halka seslenmeyi önerir. {hero}, ilk kararını vermek zorundadır.",
		"option_a": "Karaya çıkar çıkmaz plansızca herkese seslen.",
		"option_b": "Önce durumu gözlemle ve güvenilir kişilerle bağlantı kur.",
		"correct": "b",
		"retry": "İlk adım önemli ama plansız bir çıkış hem görevi hem insanları riske atabilir.",
		"info": "Samsun'a çıkış, Milli Mücadele'nin başlangıcıdır. Doğru karar, önce durumu anlamak ve örgütlü hareket etmektir."
	},
	{
		"kind": "decision",
		"chapter": "Bölüm 1: Samsun'a Çıkış",
		"unit": "Havza Genelgesi",
		"location": "Havza Yolu",
		"mood": "road",
		"speaker": "{hero}",
		"story": "Ülkede işgallere karşı tepki vardır ama herkes dağınık davranmaktadır. {hero}, halkın sesini nasıl duyuracağını düşünür.",
		"option_a": "Milleti bilinçli ve düzenli protestolara çağır.",
		"option_b": "Kimseyi uyarmadan tek başına hareket et.",
		"correct": "a",
		"retry": "Tek başına hareket etmek hızlı görünür ama milli mücadele halkın bilinçli katılımıyla güçlenir.",
		"info": "Havza Genelgesi, işgallere karşı milli bilinci uyandırmayı ve protestoları örgütlü hale getirmeyi amaçladı."
	},
	{
		"kind": "decision",
		"chapter": "Bölüm 2: Amasya Genelgesi",
		"unit": "Bağımsızlık Düşüncesi",
		"location": "Amasya",
		"mood": "city",
		"speaker": "Anlatıcı",
		"story": "Sorun büyüktür: vatanın bütünlüğü tehlikededir. {hero}, çözümün kimden geleceğini açıklayan en doğru fikri seçmelidir.",
		"option_a": "Milletin bağımsızlığını yine milletin azmi ve kararı kurtarır.",
		"option_b": "Her şeyi başkalarının kararına bırakalım.",
		"correct": "a",
		"retry": "Bu yolculuğun temel fikri dışarıdan beklemek değil, milletin kendi iradesidir.",
		"info": "Amasya Genelgesi, Milli Mücadele'nin amaç ve yöntemini ortaya koyan dönüm noktalarından biridir."
	},
	{
		"kind": "decision",
		"chapter": "Bölüm 3: Kongreler",
		"unit": "Erzurum ve Sivas Kongreleri",
		"location": "Kongre Salonu",
		"mood": "hall",
		"speaker": "Kongredeki Temsilci",
		"story": "Farklı şehirlerden gelen temsilciler aynı masadadır. Herkesin ortak bir karar çevresinde birleşmesi gerekir.",
		"option_a": "Yerel direnişleri birbirinden ayrı tut.",
		"option_b": "Milli cemiyetleri tek amaç etrafında birleştir.",
		"correct": "b",
		"retry": "Ayrı ayrı çabalar değerli olsa da ortak hedef olmadan mücadele zayıf kalır.",
		"info": "Kongreler, milli güçleri ortak hedefler çevresinde toplamaya yardım etti. Birlik fikri mücadelenin temelidir."
	},
	{
		"kind": "decision",
		"chapter": "Bölüm 4: Ankara'ya Yol",
		"unit": "Temsil Heyeti ve Meclis",
		"location": "Ankara Yolu",
		"mood": "road",
		"speaker": "{hero}",
		"story": "Mücadeleyi sürdürebilmek için güvenli ve stratejik bir merkez gerekir. {hero}, sonraki durağı seçer.",
		"option_a": "Ankara'ya gidip çalışmaları oradan yürüt.",
		"option_b": "Rastgele bir şehir seç ve bekle.",
		"correct": "a",
		"retry": "Merkez seçimi rastgele yapılamaz; ulaşım, güvenlik ve haberleşme düşünülmelidir.",
		"info": "Ankara, Milli Mücadele'nin yönetim merkezi haline geldi ve Meclis'in açılışına giden sürecin kalbi oldu."
	}
]
