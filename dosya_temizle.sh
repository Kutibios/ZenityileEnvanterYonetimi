cat /dev/null > depo.csv

dosya_temizle() {
sed -i '1s/.*/urun_id,urun_adi,stok_miktari,fiyat,kategori/' depo.csv

    echo "urun_id,urun_adi,stok_miktari,fiyat,kategori" > depo.csv
    echo "depo.csv dosyası temizlendi ve başlıklar eklendi."
}
