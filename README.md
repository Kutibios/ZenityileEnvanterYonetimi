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

    
## Uygulama Kullanımı ve Ekran Görüntüleri

Bu bölümde, uygulamanın adım adım nasıl kullanılacağını ekran görüntüleriyle birlikte açıklıyoruz. Her bir görsel, uygulamanın farklı bir özelliğini ve kullanım şeklini göstermektedir.

### Giriş Ekranı

Uygulamayı başlattığınızda karşınıza bu giriş ekranı gelir. Burada:

- **Kullanıcı Adı**: Sisteme giriş yapmak için kullanıcı adınızı yazmanız gereken alan.
- **Şifre**: Sisteme giriş yapmak için şifrenizi yazmanız gereken alan.
- Giriş bilgilerinizi doğru bir şekilde girdikten sonra, ana menüye yönlendirilirsiniz. Eğer bilgileriniz hatalıysa, sistem size hata mesajı gösterir.



<div align="center">
  <img src="zenity/giris.png" alt="Giriş Ekranı" width="300">
</div>

### Giriş Başarılı Mesajı

Başarılı bir giriş yaptığınızda karşınıza bu bilgi mesajı gelir. Bu mesaj, sisteme başarılı bir şekilde giriş yaptığınızı ve hangi rolde olduğunuzu belirtir.

<div align="center">
  <img src="zenity/kullanicirol.png" alt="Giriş Başarılı Mesajı" width="300">
</div>

### Ana Menü

Giriş yaptıktan sonra, kullanıcı rolüne göre **Ana Menü** ekranı karşınıza gelir. Yönetici rolüyle giriş yaptığınızda, aşağıdaki seçeneklere erişebilirsiniz:

- **Ürün Ekle**: Yeni ürün eklemek için bu seçeneği kullanabilirsiniz.
- **Ürün Güncelle**: Mevcut bir ürünün bilgilerini güncelleyebilirsiniz.
- **Ürün Sil**: İlgili ürünü envanterden kaldırabilirsiniz.
- **Ürün Listele**: Sistemde kayıtlı olan tüm ürünleri listeleyebilirsiniz.
- **Rapor Al**: Stok durumu veya yüksek stok miktarına göre raporlar alabilirsiniz.
- **Şifre Sıfırla**: Kullanıcıların şifrelerini sıfırlamak için bu seçeneği kullanabilirsiniz.
- **Kilitli Hesabı Aç**: Üç kez hatalı şifre nedeniyle kilitlenen hesapları açabilirsiniz.
- **Hesapları Kontrol Et**: Kilitli hesapları listelemek ve kontrol etmek için kullanılır.
- **Kullanıcı Yönetimi**: Yeni kullanıcı ekleme, mevcut kullanıcıları güncelleme veya silme işlemleri yapılabilir.
- **Program Yönetimi**: Sisteme ait yedekleme, disk alanı görüntüleme ve hata kayıtlarını inceleme işlemleri için kullanılır.
- **Çıkış**: Programdan çıkış yapmak için bu seçeneği kullanabilirsiniz.


<div align="center">
  <img src="zenity/anamenu.png" alt="Ana Menü" width="300">
</div>

**Not:**
- Yönetici rolüne sahip kullanıcılar tüm bu seçeneklere erişebilir.
- Eğer "kullanıcı" rolünde giriş yapmışsanız, yalnızca **Ürün Listele** ve **Rapor Al** seçeneklerini kullanabilirsiniz. Diğer seçeneklere tıklarsanız "Bu işlem için yetkiniz yok" uyarısı alırsınız.

### Ürün Ekle

Bu ekran, sisteme yeni bir ürün eklemek için kullanılır. Yönetici olarak giriş yaptığınızda **Ana Menü** üzerinden **Ürün Ekle** seçeneğini seçerek bu ekrana ulaşabilirsiniz.

#### Form Alanları:
1. **Ürün Adı**: Eklemek istediğiniz ürünün adı. Örneğin, "elma".
2. **Stok Miktarı**: Ürünün başlangıç stok miktarı. Örneğin, "12".
3. **Fiyat**: Ürünün birim fiyatı. Örneğin, "5.78".
4. **Kategori**: Ürünün kategorisi. Örneğin, "meyve".



<div align="center">
  <img src="zenity/urunekle.png" alt="Ürün Ekle" width="300">
</div>

#### Notlar:
- Girdiğiniz bilgilerin doğru olduğundan emin olun. 
- **Ürün Adı** boşluk içeremez ve benzersiz olmalıdır (sistemde aynı isimde başka bir ürün bulunmamalıdır).
- Stok miktarı ve fiyat yalnızca pozitif sayı olmalıdır (0 dahil).
- Eğer yanlış veya eksik bilgi girilirse sistem uyarı verir ve ekleme işlemi tamamlanmaz.

Bu ekran sayesinde yeni ürünler hızlı ve kolay bir şekilde sisteme eklenebilir.
#### Ürün Eklendi Mesajı
<div align="center">
  <img src="zenity/eklemeonay.png" alt="Ekleme Onaylandı" width="300">
</div>


