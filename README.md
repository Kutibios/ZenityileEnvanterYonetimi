# ENVANTER YÖNETİM SİSTEMİ

## Basit, Etkili ve Kullanıcı Dostu Envanter Yönetimi

Bu sistem, işletmelerin veya bireysel kullanıcıların ürünlerini etkili bir şekilde yönetmesini sağlar. Yönetici ve kullanıcı olmak üzere iki farklı rol sunarak, yetkilendirilmiş işlemleri kolayca yapmanıza olanak tanır.

- **Yönetici olarak**, ürün ekleme, güncelleme, silme ve kullanıcı yönetimi gibi tüm işlemleri gerçekleştirebilirsiniz.
- **Kullanıcı olarak**, ürünleri görüntüleyebilir ve raporlar alabilirsiniz.

Karmaşık işlemleri kolaylaştıran, kullanıcı dostu bir arayüze sahip olan bu sistem, işletmenizin verimliliğini artırmayı hedefler. Kullanıcı giriş ekranından ürün raporlarına kadar her şey basit ve anlaşılır bir şekilde tasarlanmıştır.

Bu proje aşağıdaki dosya ve klasörlerden oluşmaktadır:

### 1. **`ana_menu.sh`**
-  Uygulamanın ana çalıştırma dosyasıdır. Kullanıcı girişinden başlayarak ana menüyü ve tüm işlemleri yönetir.
- **İçerdiği İşlevler:**
  - Kullanıcı girişi
  - Yönetici ve kullanıcı işlemleri
  - Ürün ekleme, silme, güncelleme
  - Kullanıcı yönetimi ve şifre sıfırlama
  - Program yönetimi (yedekleme ve hata kayıtlarını görüntüleme)
 
### 2. **`kullanici.csv`**
-  Sistemdeki kullanıcı bilgilerini saklar.
- **İçerik Formatı:**
  ```csv
  kullanici_id,kullanici_adi,rol,sifre
  1,admin,yönetici,5f4dcc3b5aa765d61d8327deb882cf99
  2,user1,kullanıcı,5f4dcc3b5aa765d61d8327deb882cf99

### **`depo.csv`**
-  Sistemde yer alan ürün bilgilerinin saklandığı dosyadır. Ürünlerle ilgili tüm işlemler (ekleme, güncelleme, silme) bu dosya üzerinden gerçekleştirilir.
- **Kullanımı:** 
  - Yeni ürünler eklendiğinde, ürün bilgileri bu dosyaya yazılır.
  - Ürün güncelleme işlemlerinde ilgili satır bu dosyada değiştirilir.
  - Ürün silindiğinde, ilgili ürün bu dosyadan kaldırılır.
- **İçerik Formatı:**
  ```csv
  urun_id,urun_adi,stok_miktari,fiyat,kategori
  1,Kalem,100,2.5,Kırtasiye
  2,Defter,200,5.0,Kırtasiye

### **`log.csv`** 
  - **log.csv**, sistemde gerçekleşen hataların ve önemli olayların kaydedildiği bir dosyadır. Özellikle hata tespiti ve geçmişteki olayları izlemek için kullanılır. 
  - Kullanıcıların hatalı giriş denemeleri, ürün işlemleri sırasında oluşan hatalar ve kilitli hesaplarla ilgili kayıtlar bu dosyada saklanır.
- **Kullanımı:**
  - Her hata veya önemli olay gerçekleştiğinde, ilgili bilgi bu dosyaya bir satır olarak eklenir.
  - Yönetici, "Hata Kayıtlarını Görüntüle" seçeneğiyle bu dosyanın içeriğini inceleyebilir.
  
- **İçerik Formatı:**
  ```csv
  hata_no,tarih,saat,kullanici,hata_mesaji,urun_bilgisi
  1,2024-12-29,15:45:10,user1,Hatalı şifre girildi,Yok
  2,2024-12-29,15:50:00,admin,Ürün güncelleme hatası,Kalem



## Kurulum ve Başlangıç

Bu bölümde, **Envanter Yönetim Sistemi**'ni çalıştırmak için gereken adımlar açıklanmıştır. Aşağıdaki adımları izleyerek uygulamayı sisteminizde kolayca çalıştırabilirsiniz.

### 1. Sistem Gereksinimleri
Uygulamanın çalışması için aşağıdaki yazılımların sisteminizde yüklü olması gerekmektedir:
- **Bash Shell** (Linux/Unix tabanlı sistemler için varsayılan)
- **Zenity** (Grafik kullanıcı arayüzü bileşenlerini göstermek için)
- **`md5sum`** komutu (şifreleme için)

#### Zenity Yükleme
-  Zenity yüklü değilse aşağıdaki komut ile yükleyebilirsiniz:
     ```bash
     sudo apt install zenity


#### Uygulama Dosyaların İndirme
- git clone https://github.com/Kutibios/ZenityileEnvanterYonetimi.git
- cd ZenityileEnvanterYonetimi

#### Çalıştırma İzni Verin
- chmod +x ana_menu.sh

### Uygulamayı Başlatın
- ./ana_menu.sh

## NOT 
Varsayılan yönetici kullanıcı adı ve şifresi:

    Kullanıcı Adı: root
    Şifre: 1234

    


