#!/bin/bash

kullanici_giris() {
#deneme sayisi ve giris hakkinda bilgiler tanımlanır
    local giris=false
    local deneme_sayisi=0
    local max_deneme=3
    local kilitli_hesaplar="kilitli_hesaplar.txt"
 #Kullanıcı giriş yaparken maximum deneme sayısına ulaşana kadar veya giriş yapana kadar döngü devam eder
    while [ "$giris" = false ] && [ $deneme_sayisi -lt $max_deneme ]; do
        # Zenity üzerinden kullanıcıdan giriş bilgileri alınır
        KULLANICI=$(zenity --forms --title="Giriş Yap" \
            --text="Kullanıcı adı ve şifrenizi giriniz:" \
            --add-entry="Kullanıcı Adı" \
            --add-password="Şifre")

        # Kullanıcı giriş ekranını kapatırsa işlemi iptal edilir
        if [ $? -ne 0 ]; then
            zenity --info --text="Giriş işlemi iptal edildi."
            exit 1
        fi

        # Kullanıcı adı ve şifre doğruluk kontrolü yapılması için ayrıştırılır
        kullanici_adi=$(echo "$KULLANICI" | awk -F'|' '{print $1}')
        sifre=$(echo "$KULLANICI" | awk -F'|' '{print $2}')

        # Şifreyi MD5 hash formatına dönüştürür
        md5_sifre=$(echo -n "$sifre" | md5sum | awk '{print $1}')

        # Kilitli hesap kontrolü
        if grep -q "^$kullanici_adi$" "$kilitli_hesaplar"; then
            zenity --error --text="Bu hesap kilitlenmiştir. Yöneticiyle iletişime geçiniz."
            exit 1
        fi

        # Kullanıcı adı ve şifre kontrolü burada yapılır
        if grep -q "^.*,${kullanici_adi},.*,${md5_sifre}$" kullanici.csv; then
            ROL=$(awk -F',' -v user="$kullanici_adi" -v pass="$md5_sifre" '$2 == user && $4 == pass {print $3}' kullanici.csv)
            
            # Eğer ROL alınamazsa hata ver
            if [[ -z "$ROL" ]]; then
                zenity --error --text="Bir hata oluştu. Rol bilgisi alınamadı. Kullanıcı: $kullanici_adi"
                exit 1
            fi

            zenity --info --text="Giriş başarılı! Rolünüz: $ROL"
            giris=true
            return 0
        else
            # Kullanıcı adı doğru ama şifre yanlışsa uyarı verilir
            if grep -q "^.*,${kullanici_adi},.*," kullanici.csv; then
                deneme_sayisi=$((deneme_sayisi + 1))
                zenity --error --text="Hatalı şifre. Kalan deneme: $((max_deneme - deneme_sayisi))"
            else
                # Kullanıcı adı yanlış
                deneme_sayisi=$((deneme_sayisi + 1))
                zenity --error --text="Kullanıcı adı bulunamadı. Kalan deneme: $((max_deneme - deneme_sayisi))"
            fi
        fi
    done

    # Maksimum deneme sayısına ulaşıldığında hesap kilitlenir ve kitili hesaplar klasörüne kaydedilir.
    if [ $deneme_sayisi -ge $max_deneme ]; then
        echo "$kullanici_adi" >> "$kilitli_hesaplar"
        zenity --error --text="Hesabınız kilitlenmiştir. Yönetici ile iletişime geçiniz."
        exit 1
    fi

    return 1
}



csv_kontrol() {

    if [ -f depo.csv ]; then
        # İlk satırda doğru başlık var mı kontrol et
        ilk_satir=$(head -n 1 depo.csv)
        #basliklar düzeltilir
        if [ "$ilk_satir" != "urun_id,urun_adi,stok_miktari,fiyat,kategori" ]; then
            echo "Başlıklar yanlış olmuş. Düzeltmeler yapılıyor."
            sed -i '1s/.*/urun_id,urun_adi,stok_miktari,fiyat,kategori/' depo.csv
        fi
    else
        # Dosya yoksa oluştur
        echo "depo.csv bulunamadı. Yeni bir dosya oluşturuluyor..."
        echo "urun_id,urun_adi,stok_miktari,fiyat,kategori" > depo.csv
    fi
    #dosyaların var olup olmadığı kontrol edilir. Yoksa oluşturulur
    for file in depo.csv kullanici.csv log.csv; do
        if [ ! -f "$file" ]; then
            echo "CSV dosyası bulunamadı: $file. Yeni bir dosya oluşturuluyor..."
            touch "$file"
            # İlk satır başlık eklemek için:
            case $file in
                "depo.csv") echo "urun_id,urun_adi,stok_miktari,fiyat,kategori" > $file ;;
                "kullanici.csv") echo "kullanici_id,ad,email,rol,sifre" > $file ;;
                "log.csv") echo "tarih,saat,kullanici,aksiyon" > $file ;;
            esac
        fi
    done
}
# CSV dosyalarını kontrol ediyoruz
csv_kontrol

ana_menu() {
    # Ana menü sürekli açık kalır
    while true; do
        # Kullanıcı rolüne göre menü seçenekleri belirlenir
        if [ "$ROL" = "yönetici" ]; then
            # Yöneticiye tüm seçenekler sunulur
            CHOICE=$(zenity --list --title="Ana Menü (Yönetici)" --column="Seçenekler" \
                "Ürün Ekle" \
                "Ürün Güncelle" \
                "Ürün Sil" \
                "Ürün Listele" \
                "Rapor Al" \
                "Şifre Sıfırla" \
                "Kilitli Hesabı Aç" \
                "Hesapları Kontrol Et" \
                "Kullanıcı Yönetimi" \
                "Program Yönetimi" \
                "Çıkış")
        elif [ "$ROL" = "kullanıcı" ]; then
            # Kullanıcıya tüm seçenekler gösterilir fakat yapabildiği işlemler sınırlıdır
            CHOICE=$(zenity --list --title="Ana Menü (Kullanıcı)" --column="Seçenekler" \
                "Ürün Ekle" \
                "Ürün Güncelle" \
                "Ürün Sil" \
                "Ürün Listele" \
                "Rapor Al" \
                "Şifre Sıfırla" \
                "Kilitli Hesabı Aç" \
                "Hesapları Kontrol Et" \
                "Kullanıcı Yönetimi" \
                "Program Yönetimi" \
                "Çıkış")

            # Seçimlere göre işlemleri kontrol et
            case $CHOICE in
                "Çıkış")
                    cikis ;; 
                "Ürün Listele") 
                    urun_listele ;;  # Kullanıcı bu işlemi yapabilir
                "Rapor Al") 
                    rapor_al ;;  # Kullanıcı bu işlemi yapabilir
                *)
                    # Kullanıcının yetkisi olmayan işlemler için hata mesajı gösterilir
                    zenity --error --text="Bu işlem için yetkiniz yok!"
                    ;;
            esac
            continue  # Kullanıcı menüyü kapattığında döngüye devam et
        else
            # Eğer ROL bilinmiyorsa hata gösterilir
            zenity --error --text="Bir hata oluştu. Rol bilgisi bulunamadı."
            exit 1
        fi

        # Zenity iptal veya kapatma durumunu kontrol edin
        if [ -z "$CHOICE" ]; then
            zenity --error --text="Hiçbir seçim yapılmadı. Lütfen tekrar deneyin."
            continue
        fi

        # Seçimlere göre işlem yapılır
        case $CHOICE in
            "Ürün Ekle") 
                if [ "$ROL" != "yönetici" ]; then
                    zenity --error --text="Bu işlem için yetkiniz yok!"
                    continue
                fi
                urun_ekle ;;
            "Ürün Güncelle")
                if [ "$ROL" != "yönetici" ]; then
                    zenity --error --text="Bu işlem için yetkiniz yok!"
                    continue
                fi
                urun_guncelle ;;
            "Ürün Sil") 
                if [ "$ROL" != "yönetici" ]; then
                    zenity --error --text="Bu işlem için yetkiniz yok!"
                    continue
                fi
                urun_sil ;;
            "Ürün Listele") urun_listele ;;
            "Rapor Al") rapor_al ;;
            "Şifre Sıfırla") sifre_sifirla ;;
            "Kilitli Hesabı Aç") hesap_ac ;;
            "Hesapları Kontrol Et") hesap_kontrol ;;
            "Program Yönetimi") program_yonetimi ;;
            "Kullanıcı Yönetimi") 
                if [ "$ROL" != "yönetici" ]; then
                    zenity --error --text="Bu işlem için yetkiniz yok!"
                    continue
                fi
                kullanici_yonetimi ;;
            "Çıkış") 
                zenity --question --text="Programdan çıkmak istediğinizden emin misiniz?"
                if [ $? -eq 0 ]; then
                    exit 0
                fi
                ;;
            *)
                zenity --error --text="Geçersiz seçim. Lütfen tekrar deneyin."
                ;;
        esac
    done
}


cikis() {
    # Kullanıcıdan çıkış için onay alınır
    zenity --question --title="Çıkış Onayı" --text="Programdan çıkmak istediğinizden emin misiniz?"
    #bu işlem çıkış yani programı kapatma işlemidir
    # Eğer kullanıcı çıkışı onaylamazsa, geri dönülür
    if [ $? -ne 0 ]; then
        zenity --info --text="Çıkış işlemi iptal edildi."
        return
    fi

    # Çıkışı onaylayan kullanıcı için program sonlandırılır
    zenity --info --text="Programdan çıkılıyor."
    exit 0
}
sifre_sifirla() {
    #kullanıcı adı alınarak işlem başlar
    kullanici_adi=$(zenity --entry --title="Şifre Sıfırlama" \
        --text="Şifresini sıfırlamak istediğiniz kullanıcı adını giriniz:")
    #iptal etme
    if [ $? -ne 0 ]; then
        zenity --info --text="Şifre sıfırlama işlemi iptal edildi."
        return
    fi
    #girdiyi boş bırakma durumunda
    if [[ -z "$kullanici_adi" ]]; then
        zenity --error --text="Kullanıcı adı boş bırakılamaz!"
        return
    fi

    # Kullanıcı adı CSV dosyasında aranır
    satir=$(grep -i ",$kullanici_adi," kullanici.csv)

    if [[ -z "$satir" ]]; then
        #kullanıcı bulunamazsa hata mesajı gönderilir
        zenity --error --text="Kullanıcı bulunamadı: $kullanici_adi"
        return
    fi

    # Yeni şifre oluşturulur
    yeni_sifre=$(zenity --password --title="Yeni Şifre Belirleme" --text="Yeni şifreyi giriniz:")

    if [ $? -ne 0 ]; then
        zenity --info --text="Şifre sıfırlama işlemi iptal edildi."
        return
    fi
    #yeni şifre girilmezse hata verir
    if [[ -z "$yeni_sifre" ]]; then
        zenity --error --text="Şifre boş bırakılamaz!"
        return
    fi

    # Güncellenmiş satır oluşturulur
    yeni_satir=$(echo "$satir" | awk -F',' -v yeni_sifre="$yeni_sifre" 'BEGIN{OFS=","} {$4=yeni_sifre; print $0}')

    # Eski satır güncellenmiş satır ile değiştirilir
    sed -i "/$satir/c\\$yeni_satir" kullanici.csv

    zenity --info --text="Şifre başarıyla sıfırlandı: $kullanici_adi"
}

hesap_kontrol() {
#kilitli hesaplar bir değişkene işlem yapmak için atanır
local kilitli_hesaplar="kilitli_hesaplar.txt"

    # Kilitli hesaplar dosyası kontrol edilir.Dosya yoksa uyarı ekranı gelir.
    if [ ! -f "$kilitli_hesaplar" ] || [ ! -s "$kilitli_hesaplar" ]; then
        zenity --info --text="Kilitli hesap bulunmamaktadır."
        return
    fi

    # Kilitli hesaplar listelenir.
    zenity --list --title="Kilitli Hesaplar" --column="Kullanıcı Adı" $(cat "$kilitli_hesaplar")
}

hesap_ac() {
    local kilitli_hesaplar="kilitli_hesaplar.txt"
     #kilitli hesap dosyası incelenir
    if [ ! -f "$kilitli_hesaplar" ] || [ ! -s "$kilitli_hesaplar" ]; then
        zenity --info --text="Kilitli hesap bulunmamaktadır."
        return
    fi

    # Kilitli hesapları görüntüle
    hesap=$(zenity --list --title="Kilitli Hesaplar" \
        --column="Kullanıcı Adı" $(cat "$kilitli_hesaplar"))

    if [ -z "$hesap" ]; then
        zenity --info --text="Kilitli hesap seçilmedi."
        return
    fi

    # Hesap kilitli hesaplar listesinden silinir ve tekrar girilebili hale gelir.
    sed -i "/^$hesap$/d" "$kilitli_hesaplar"
    zenity --info --text="Hesap başarıyla açıldı: $hesap"
    echo "$(date +%Y-%m-%d),$(date +%H:%M:%S),$hesap,Hesap açıldı" >> log.csv
}

urun_ekle() {
    #Ürünün bilgileri alınır.
    VALUES=$(zenity --forms --title="Ürün Ekle" \
        --text="Yeni ürün bilgilerini giriniz." \
        --add-entry="Ürün Adı" \
        --add-entry="Stok Miktarı" \
        --add-entry="Fiyat" \
        --add-entry="Kategori")
     #bilgiler listelenir
    if [ $? -eq 0 ]; then
        urun_adi=$(echo $VALUES | awk -F'|' '{print $1}')
        stok=$(echo $VALUES | awk -F'|' '{print $2}')
        fiyat=$(echo $VALUES | awk -F'|' '{print $3}')
        kategori=$(echo $VALUES | awk -F'|' '{print $4}')
        
        # Ürünün stok ve fiyat bilgileri doğrulanır (belli kurallar dahilinde)
        #1. kural
        if [[ ! $stok =~ ^[0-9]+$ || ! $fiyat =~ ^[0-9]+$ ]]; then
            zenity --error --text="Stok miktarı ve fiyat yalnızca pozitif sayı olmalıdır (0 dahil)."
            echo "$(date +%Y-%m-%d),$(date +%H:%M:%S),$USER,Hatalı giriş: stok veya fiyat pozitif değil." >> log.csv
            return 1
        fi
        #2. kural
        if [[ "$urun_adi" =~ \  || "$kategori" =~ \  ]]; then
            zenity --error --text="Ürün adı ve kategori boşluk içeremez."
            echo "$(date +%Y-%m-%d),$(date +%H:%M:%S),$USER,Hatalı giriş: Ürün adı veya kategori boşluk içeriyor." >> log.csv
            return 1
        fi
        #3. kural
        if grep -q ",$urun_adi," depo.csv; then
            zenity --error --text="Bu ürün adıyla başka bir kayıt bulunmaktadır. Lütfen farklı bir ad giriniz."
            echo "$(date +%Y-%m-%d),$(date +%H:%M:%S),$USER,Hatalı giriş: Aynı ürün adı bulundu." >> log.csv
            return 1
        fi

        # İlerleme çubuğu görselleşmiş hali
        (
            echo "10"; sleep 1
            echo "# Ürün bilgileri doğrulanıyor..."; sleep 1
            echo "50"; sleep 1
            echo "# Ürün ekleniyor..."; sleep 1
            echo "100"; sleep 1
        ) | zenity --progress --title="Ürün Ekleme" --text="İşlem yapılıyor..." --percentage=0 --auto-close
        
        # Ürün ekleme işlemi yapılır ve UNIQUE ID adresi de burada oluşturlur.
        yeni_id=$(($(tail -n +2 depo.csv | awk -F, '{print $1}' | sort -n | tail -1) + 1))
        echo "$yeni_id,$urun_adi,$stok,$fiyat,$kategori" >> depo.csv
        zenity --info --text="Ürün başarıyla eklendi. Ürün ID: $yeni_id"
    else
        zenity --error --text="Ürün ekleme işlemi iptal edildi."
    fi
}

urun_listele() {
    # CSV dosyasını kontrol edilir.
    if [ ! -f depo.csv ] || [ ! -s depo.csv ]; then
        zenity --info --text="Envanterde ürün bulunmamaktadır."
        return
    fi

    # Başlık ekle ve CSV dosyasını biçimlendir
    {
        #ürünlerin başlık isimleri belirtilir.
        printf "%-5s %-15s %-10s %-10s\n" "ID" "Ürün Adı" "Stok" "Fiyat"
        printf "%-5s %-15s %-10s %-10s\n" "-----" "---------------" "----------" "----------"
        awk -F',' 'NR>1 {printf "%-5s %-15s %-10s %-10s\n", $1, $2, $3, $4}' depo.csv
    } > envanter.txt

    # metin olarak gösteriliyor
    zenity --text-info --title="Envanter Listesi" --filename=envanter.txt --width=600 --height=400

    # Geçici dosyayı siler
    rm -f envanter.txt
}

urun_guncelle() {
    # Kullanıcıdan güncellemek istediği ürünün adı alınır
    urun_adi=$(zenity --entry --title="Ürün Güncelle" \
        --text="Güncellemek istediğiniz ürünün adını giriniz:")

    # Kullanıcı iptal ederse işlemi sonlandır
    if [ $? -ne 0 ]; then
        zenity --info --text="Ürün güncelleme işlemi iptal edildi."
        return
    fi

    # Bir şey yazmadan güncelleme işlemi olursa hata verir.
    if [[ -z "$urun_adi" ]]; then
        zenity --error --text="Ürün adı boş bırakılamaz!"
        return
    fi

    # CSV dosyasında ürün aranır bulunursa devam edilir
    satir=$(grep -i ",$urun_adi," depo.csv)

    # Ürün bulunamazsa hata mesajı gösterilir
    if [[ -z "$satir" ]]; then
        zenity --error --text="Ürün bulunamadı: $urun_adi"
        return
    fi

    # Ürün bilgileri ayrıştırılır
    urun_id=$(echo "$satir" | awk -F',' '{print $1}')
    mevcut_stok=$(echo "$satir" | awk -F',' '{print $3}')
    mevcut_fiyat=$(echo "$satir" | awk -F',' '{print $4}')

    # Kullanıcıdan yeni stok ve fiyat bilgisi istenir (zenity yardımıyla)
    VALUES=$(zenity --forms --title="Ürün Güncelle" \
        --text="Ürün bilgilerini güncelleyiniz (Boş bırakırsanız değer değişmez):" \
        --add-entry="Yeni Stok Miktarı (Mevcut: $mevcut_stok)" \
        --add-entry="Yeni Birim Fiyatı (Mevcut: $mevcut_fiyat)")

    if [ $? -ne 0 ]; then
        zenity --info --text="Ürün güncelleme işlemi iptal edildi."
        return
    fi

    yeni_stok=$(echo "$VALUES" | awk -F'|' '{print $1}')
    yeni_fiyat=$(echo "$VALUES" | awk -F'|' '{print $2}')

    # Boş değerler için mevcut değerler korunur
    if [[ -z "$yeni_stok" ]]; then
        yeni_stok="$mevcut_stok"
    fi

    if [[ -z "$yeni_fiyat" ]]; then
        yeni_fiyat="$mevcut_fiyat"
    fi

    # Güncellenmiş veriler yazdırılır
    yeni_satir="$urun_id,$urun_adi,$yeni_stok,$yeni_fiyat"

    # Eski satır güncellenmiş satır ile değiştirilir
    sed -i "/$satir/c\\$yeni_satir" depo.csv

    #( Güncelleme başarı mesajı)
    zenity --info --text="Ürün başarıyla güncellendi: $urun_adi\nYeni Stok: $yeni_stok\nYeni Fiyat: $yeni_fiyat"
}

urun_sil() {
    # Kullanıcının silmek istediği ürünün adı alınır.
    urun_adi=$(zenity --entry --title="Ürün Sil" \
        --text="Silmek istediğiniz ürünün adını giriniz:")

    # Kullanıcı iptal ederse işlemi sonlanır.
    if [ $? -ne 0 ]; then
        zenity --info --text="Ürün silme işlemi iptal edildi."
        return
    fi

    # Boş giriş yapılırsa hata mesajı
    if [[ -z "$urun_adi" ]]; then
        zenity --error --text="Ürün adı boş bırakılamaz!"
        return
    fi

    # CSV dosyasında ürün aranır
    satir=$(grep -i ",$urun_adi," depo.csv)

    # Ürün bulunamazsa hata mesajı gösterilir
    if [[ -z "$satir" ]]; then
        zenity --error --text="Ürün bulunamadı: $urun_adi"
        return
    fi

    # Silme işlemi tekrar onayı 
    zenity --question --text="Ürünü silmek istediğinizden emin misiniz?\n\nÜrün: $urun_adi"
    if [ $? -ne 0 ]; then
        zenity --info --text="Ürün silme işlemi iptal edildi."
        return
    fi

    # Ürün satırını CSV dosyasından silme işlemi
    sed -i "/$satir/d" depo.csv

    # ürün silinirse olumlu mesaj gönderilir
    zenity --info --text="Ürün başarıyla silindi: $urun_adi"
}

rapor_al() {
    #hangi rapor türü alınacağı seçilir
    CHOICE=$(zenity --list --title="Rapor Al" --column="Raporlar" \
        "Stokta Azalan Ürünler" \
        "En Yüksek Stok Miktarına Sahip Ürünler")
    #eşik değerine göre veriler gösterilir (stok miktarı < eşik değer)
    case $CHOICE in
        "Stokta Azalan Ürünler")
            ESIK=$(zenity --entry --title="Eşik Değeri" --text="Eşik değeri giriniz:")
            awk -F, -v esik="$ESIK" '$3 < esik {print $0}' depo.csv | zenity --text-info --title="Stokta Azalan Ürünler"
            ;;
        "En Yüksek Stok Miktarına Sahip Ürünler")
            ESIK=$(zenity --entry --title="Eşik Değeri" --text="Eşik değeri giriniz:")
            awk -F, -v esik="$ESIK" '$3 > esik {print $0}' depo.csv | zenity --text-info --title="En Yüksek Stok Miktarına Sahip Ürünler"
            ;;
        *) zenity --error --text="Geçersiz seçim." ;;
    esac
}

hata_kaydet() {
    local hata_no=$(($(wc -l < log.csv) + 1))  # Hata numarasını belirlenir
    local tarih=$(date +%Y-%m-%d) #tarih
    local saat=$(date +%H:%M:%S) #saat
    local kullanici=$1 #hatayı yapan kullanıcı
    local hata_mesaji=$2 #hata mesajı
    local urun_bilgisi=${3:-"Yok"}  # Ürün bilgisi gösterilir, yoksa Yok yazılır
    
    #en son hata bütünü log.csv dosyasına kaydedilir.
    echo "$hata_no,$tarih,$saat,$kullanici,$hata_mesaji,$urun_bilgisi" >> log.csv
}

kullanici_yonetimi() {
     #işlem seçenekleri gösterilir
    CHOICE=$(zenity --list --title="Kullanıcı Yönetimi" --column="Seçenekler" \
        "Yeni Kullanıcı Ekle" \
        "Kullanıcıları Listele" \
        "Kullanıcı Güncelle" \
        "Kullanıcı Silme")
    
    case $CHOICE in
        "Yeni Kullanıcı Ekle")
            # Mevcut en büyük ID bulunur. (UNIQUE olduğu için)
            if [ -s kullanici.csv ]; then
                # ID sütunundaki en büyük değeri bulur
                yeni_id=$(awk -F',' 'BEGIN {max=0} {if($1+0>max) max=$1} END {print max+1}' kullanici.csv)
            else
                # Eğer dosya boşsa ilk ID olarak 1 atanır.
                yeni_id=1
            fi

            # Kullanıcı bilgilerini alınır
            VALUES=$(zenity --forms --title="Yeni Kullanıcı Ekle" \
                            --add-entry="Ad" \
                            --add-entry="Rol" \
                            --add-password="Şifre")

            if [ $? -eq 0 ]; then
                ad=$(echo "$VALUES" | awk -F'|' '{print $1}')
                rol=$(echo "$VALUES" | awk -F'|' '{print $2}')
                sifre=$(echo "$VALUES" | awk -F'|' '{print $3}')

                # Şifreyi MD5 formatına çevirir
                md5_sifre=$(echo -n "$sifre" | md5sum | awk '{print $1}')

                # Kullanıcı bilgilerini CSV dosyasına eklenir
                echo "$yeni_id,$ad,$rol,$md5_sifre" >> kullanici.csv

                zenity --info --text="Kullanıcı başarıyla eklendi! ID: $yeni_id"
            else
                zenity --error --text="Kullanıcı ekleme işlemi iptal edildi."
            fi
            ;;
        "Kullanıcı Silme")
            # Kullanıcı listesini göster ve silinecek kullanıcıyı seçtir
            local kullanici_secilen=$(zenity --list --title="Kullanıcı Sil" \
                --column="Kullanıcı ID" --column="Kullanıcı Adı" --column="Rol" \
                $(awk -F',' '{print $1, $2, $3}' OFS=' ' kullanici.csv | tr ' ' '\n'))

            if [ -z "$kullanici_secilen" ]; then
                zenity --error --text="Hiçbir kullanıcı seçilmedi!"
                return
            fi

            # Kullanıcıyı doğrulanır ve onay verilir
            zenity --question --title="Kullanıcı Sil" --text="Seçilen kullanıcıyı silmek istediğinizden emin misiniz?\n\n$kullanici_secilen"
            if [ $? -ne 0 ]; then
                zenity --info --text="Kullanıcı silme işlemi iptal edildi."
                return
            fi

            # Silme işlemi burada gerçekleştirilir
            local kullanici_id=$(echo "$kullanici_secilen" | awk '{print $1}')
            grep -v "^$kullanici_id," kullanici.csv > temp.csv && mv temp.csv kullanici.csv

            zenity --info --text="Kullanıcı başarıyla silindi." ;;
        "Kullanıcıları Listele")
            zenity --text-info --title="Kullanıcı Listesi" \
                --filename=<(column -s, -t < kullanici.csv) \
                --width=600 --height=400
            ;;
        # Diğer işlemler için ek fonksiyonlar eklenebilir
        *) zenity --error --text="Geçersiz seçim." ;;
    esac
}
program_yonetimi() {
    #programda bu seçenek kapatılana kadar while döngüsüyle devam eder
    while true; do
        local secim=$(zenity --list --title="Program Yönetimi" --column="Seçenekler" \
            "Diskte Kapladığı Alan Gösterimi" \
            "Diske Yedek Alma" \
            "Hata Kayıtlarını Görüntüleme" \
            "Geri Dön")

        if [ -z "$secim" ]; then
            zenity --error --text="Hiçbir seçim yapılmadı. Lütfen tekrar deneyin!"
            continue
        fi
         #disk alanını gösteren yer
        case $secim in
            "Diskte Kapladığı Alan Gösterimi")
                #toplam_boyut seçeneği disk boyutunu tutar
                local toplam_boyut=$(du -ch depo.csv kullanici.csv log.csv 2>/dev/null | grep "total" | awk '{print $1}')
                zenity --info --title="Disk Alanı" --text="CSV dosyalarının toplam boyutu: $toplam_boyut"
                ;;
             #yedek alma seçeneği budur.
            "Diske Yedek Alma")
                local yedek_klasoru="yedekler"

                # Yedekleme klasörünü oluşturur
                mkdir -p "$yedek_klasoru"

                # CVV  dosyaları yedek klasörlere kopyalanır
                cp depo.csv kullanici.csv log.csv "$yedek_klasoru/" 2>/dev/null
                zenity --info --title="Yedekleme" --text="Dosyalar $yedek_klasoru klasörüne yedeklendi!"
                ;;
            #log errorlar görüntülenir
            "Hata Kayıtlarını Görüntüleme")
                #hata yoksa böyle bir kayıt yok çıktısı gösterilir
                if [ ! -s log.csv ]; then
                    zenity --error --text="Hata kaydı bulunmamaktadır!"
                else
                    zenity --text-info --title="Hata Kayıtları" --filename=<(column -t -s, log.csv)
                fi
                ;;
            "Geri Dön")
                break
                ;;
            *)
                zenity --error --text="Geçersiz seçim!"
                ;;
        esac
    done
}

# Programı çalıştırmak için menüyü çağırıyoruz bazı yerlerde kodun aralarında fonksiyonlar çağrılır.
kullanici_giris #giriş bilgileri alınır doğruysa ana menü açılır
ana_menu #kullanıcı rolüne bağlı işlemlerin gerçekleştirildiği ana menüdür
