# Kullanıcı bilgilerini tanımlayın
KULLANICI_ID="10"
KULLANICI_ADI="talhahoca"
ROL="yönetici"
SIFRE="talhahoca"

# Şifreyi MD5 hash formatına çevir
MD5_SIFRE=$(echo -n "$SIFRE" | md5sum | awk '{print $1}')

# Kullanıcıyı kullanici.csv dosyasına ekle
echo "$KULLANICI_ID,$KULLANICI_ADI,$ROL,$MD5_SIFRE" >> kullanici.csv

# Bilgiyi kontrol edin
echo "Kullanıcı $KULLANICI_ADI başarıyla eklendi!"
