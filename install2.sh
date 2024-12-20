WIDTH=78
HEIGHT=20

# Exit codes.
SUCCESS=0
FAILURE=1
PACKAGES_NOT_AVAILABLE=2

X11VNC_install(){
apt install x11vnc -y
x11vnc -storepasswd 12345678 /etc/x11vnc.pass
#получаем IP-адрес  клиента
ip=`hostname -I | awk ' {print substr($1, 1)}'`
cat > /etc/systemd/system/x11vnc.service <<X-service
[Unit]
Description=x11vnc
After=multi-user.target
[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -env FD_KDM=1 -auth guess -listen $ip -noipv6 -rfbport 5900 -rfbauth /etc/x11vnc.pass -notruecolor -ultrafilexfer -shared -dontdisconnect -many -noxrecord -noxfixes -noxdamage -nodpms -loop -o /var/log/x11vnc.log
[Install]
WantedBy=multi-user.target
X-service
systemctl daemon-reload
systemctl enable x11vnc.service
systemctl start x11vnc.service

}

operation_success(){
clear
TERM=ansi whiptail --backtitle "" --title "Успех!" --infobox "Операция выполнена успешно!" 15 60
sleep 2
clear
}


exact_time(){
apt install chrony -y
systemctl enable chrony
systemctl start chrony
install_snapper
}

install_CryptoPro(){
#предусмотреть загрузку через git

tar -xzf linux-amd64_deb.tgz
cd linux-amd64_deb
./uninstall.sh
apt autoremove -y
./install_gui.sh
#Options
/opt/cprocsp/sbin/amd64/cpconfig -ini '\config\parameters\Crypto-Pro Enhanced RSA and AES CSP' -add long ControlKeyTimeValidity 0x00
/opt/cprocsp/sbin/amd64/cpconfig -ini '\config\parameters\Crypto-Pro Enhanced RSA and AES CSP' -add long KeyTimeValidityControlMode 0x00
/opt/cprocsp/sbin/amd64/cpconfig -ini '\config\parameters\Crypto-Pro HSM CSP' -add long ControlKeyTimeValidity 0x00
/opt/cprocsp/sbin/amd64/cpconfig -ini '\config\parameters\Crypto-Pro HSM CSP' -add long KeyTimeValidityControlMode 0x00
/opt/cprocsp/sbin/amd64/cpconfig -ini '\config\parameters\Crypto-Pro GOST R 34.10-2012 HSM CSP' -add long ControlKeyTimeValidity 0x00
/opt/cprocsp/sbin/amd64/cpconfig -ini '\config\parameters\Crypto-Pro GOST R 34.10-2012 HSM CSP' -add long KeyTimeValidityControlMode 0x00
/opt/cprocsp/sbin/amd64/cpconfig -ini '\config\parameters\Crypto-Pro GOST R 34.10-2012 Strong HSM CSP' -add long ControlKeyTimeValidity 0x00
/opt/cprocsp/sbin/amd64/cpconfig -ini '\config\parameters\Crypto-Pro GOST R 34.10-2012 Strong HSM CSP' -add long KeyTimeValidityControlMode 0x00
/opt/cprocsp/sbin/amd64/cpconfig -ini '\config\parameters\Crypto-Pro GOST R 34.10-2012 KC1 CSP' -add long ControlKeyTimeValidity 0x00
/opt/cprocsp/sbin/amd64/cpconfig -ini '\config\parameters\Crypto-Pro GOST R 34.10-2012 KC1 CSP' -add long KeyTimeValidityControlMode 0x00
/opt/cprocsp/sbin/amd64/cpconfig -ini '\config\cades\trustedsites' -add multistring "TruestedSites" "https://zakupki.gov.ru" "https://lk.zakupki.gov.ru" "https://www.cryptopro.ru"
/opt/cprocsp/sbin/amd64/cpconfig -ini '\config\parameters\' -add long ControlKeyTimeValidity 0x00
/opt/cprocsp/sbin/amd64/cpconfig -ini '\config\parameters\' -add long KeyTimeValidityControlMode 0x00
cd ..
rm -rf linux-amd64_deb

#Устанавливаем плагин Cades

tar -xzf cades_linux_amd64.tar.gz
cd cades_linux_amd64
dpkg -i *.deb
cd ..
rm -rf cades_linux_amd64


#установливаем сертификаты
wget -qO- --no-check-certificate "https://roskazna.gov.ru/upload/iblock/992/Sertifikat-udostoveryayushchego-tsentra-Federalnogo-kaznacheystva-2023.CER"|/opt/cprocsp/bin/amd64/certmgr -inst -store mRoot -stdin
wget -qO- --no-check-certificate "https://roskazna.gov.ru/upload/iblock/f5e/Kornevoy-sertifikat-GUTS-2022.CER"|/opt/cprocsp/bin/amd64/certmgr -inst -store mRoot -stdin
wget -qO- --no-check-certificate "https://roskazna.gov.ru/upload/iblock/1af/Kaznacheystvo-Rossii.CER"| /opt/cprocsp/bin/amd64/certmgr -inst -store mca -stdin
wget -qO- --no-check-certificate "https://roskazna.gov.ru/upload/iblock/7e3/guts_2012.cer"| /opt/cprocsp/bin/amd64/certmgr -inst -store mRoot -stdin
wget -qO- --no-check-certificate "https://roskazna.gov.ru/upload/iblock/c8c/UTS-FK_2021.CER"| /opt/cprocsp/bin/amd64/certmgr -inst -store mca -stdin
wget -qO- --no-check-certificate "https://roskazna.gov.ru/upload/iblock/024/uts-fk_2020.cer"| /opt/cprocsp/bin/amd64/certmgr -inst -store mca -stdin
wget -qO- --no-check-certificate "https://roskazna.gov.ru/upload/iblock/acb/fk_2012.cer"| /opt/cprocsp/bin/amd64/certmgr -inst -store mca -stdin
wget -qO- --no-check-certificate "http://rostelecom.ru/cdp/guc_gost12.crl"| /opt/cprocsp/bin/amd64/certmgr -inst -crl -stdin
wget -qO- --no-check-certificate "http://rostelecom.ru/cdp/guc.crl"| /opt/cprocsp/bin/amd64/certmgr -inst -crl -stdin

wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/ucfk_2021.crl"| /opt/cprocsp/bin/amd64/certmgr -inst -crl -stdin
wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/ucfk_2020.crl"| /opt/cprocsp/bin/amd64/certmgr -inst -crl -stdin
wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/ucfk_gost12.crl"| /opt/cprocsp/bin/amd64/certmgr -inst -crl -stdin
wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/ucfk.crl"| /opt/cprocsp/bin/amd64/certmgr -inst -crl -stdin
wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/ucfk_2022.crl"| /opt/cprocsp/bin/amd64/certmgr -inst -crl -stdin
wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/ucfk_2022_1.1.crl"| /opt/cprocsp/bin/amd64/certmgr -inst -crl -stdin
wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/ucfk_2023.crl"| /opt/cprocsp/bin/amd64/certmgr -inst -crl -stdin
wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/ucfk_2024.crl"| /opt/cprocsp/bin/amd64/certmgr -inst -crl -stdin

wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/%D0%9A%D0%BE%D1%80%D0%BD%D0%B5%D0%B2%D0%BE%D0%B9%20%D1%81%D0%B5%D1%80%D1%82%D0%B8%D1%84%D0%B8%D0%BA%D0%B0%D1%82%20%D0%93%D0%A3%D0%A6%202021.cer"|/opt/cprocsp/bin/amd64/certmgr -inst -store mRoot -stdin
wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/%D0%9A%D0%BE%D1%80%D0%BD%D0%B5%D0%B2%D0%BE%D0%B9%20%D1%81%D0%B5%D1%80%D1%82%D0%B8%D1%84%D0%B8%D0%BA%D0%B0%D1%82%20%D0%93%D0%A3%D0%A6%202022.cer"|/opt/cprocsp/bin/amd64/certmgr -inst -store mRoot -stdin
wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/%D0%9A%D0%BE%D1%80%D0%BD%D0%B5%D0%B2%D0%BE%D0%B9%20%D1%81%D0%B5%D1%80%D1%82%D0%B8%D1%84%D0%B8%D0%BA%D0%B0%D1%82%20%D0%93%D0%A3%D0%A6.crt"|/opt/cprocsp/bin/amd64/certmgr -inst -store mRoot -stdin
wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/%D0%9A%D0%BE%D1%80%D0%BD%D0%B5%D0%B2%D0%BE%D0%B9%20%D1%81%D0%B5%D1%80%D1%82%D0%B8%D1%84%D0%B8%D0%BA%D0%B0%D1%82%20%D0%93%D0%A3%D0%A6%20%D0%93%D0%9E%D0%A1%D0%A2%202012.crt"|/opt/cprocsp/bin/amd64/certmgr -inst -store mRoot -stdin

wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/%D0%9F%D0%BE%D0%B4%D1%87%D0%B8%D0%BD%D0%B5%D0%BD%D0%BD%D1%8B%D0%B9%20%D1%81%D0%B5%D1%80%D1%82%D0%B8%D1%84%D0%B8%D0%BA%D0%B0%D1%82%20%D0%A3%D0%A6%20%D0%A4%D0%9A%20%D0%BE%D1%82%2004.07.2017.crt"| /opt/cprocsp/bin/amd64/certmgr -inst -store mca -stdin
wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/%D0%9F%D0%BE%D0%B4%D1%87%D0%B8%D0%BD%D0%B5%D0%BD%D0%BD%D1%8B%D0%B9%20%D1%81%D0%B5%D1%80%D1%82%D0%B8%D1%84%D0%B8%D0%BA%D0%B0%D1%82%20%D0%A3%D0%A6%20%D0%A4%D0%9A%20%D0%93%D0%9E%D0%A1%D0%A2%202012.crt"| /opt/cprocsp/bin/amd64/certmgr -inst -store mca -stdin
wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/%D0%9F%D0%BE%D0%B4%D1%87%D0%B8%D0%BD%D0%B5%D0%BD%D0%BD%D1%8B%D0%B9%20%D1%81%D0%B5%D1%80%D1%82%D0%B8%D1%84%D0%B8%D0%BA%D0%B0%D1%82%20%D0%A3%D0%A6%20%D0%A4%D0%9A%20%D0%BE%D1%82%2005.02.2020.crt"| /opt/cprocsp/bin/amd64/certmgr -inst -store mca -stdin
wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/ucfk_2021.crt"| /opt/cprocsp/bin/amd64/certmgr -inst -store mca -stdin
wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/ucfk_2022.crt"| /opt/cprocsp/bin/amd64/certmgr -inst -store mca -stdin
wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/ucfk_2022_1.1.crt"| /opt/cprocsp/bin/amd64/certmgr -inst -store mca -stdin
wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/ucfk_2023.crt"| /opt/cprocsp/bin/amd64/certmgr -inst -store mca -stdin
wget -qO- --no-check-certificate "http://crl.roskazna.ru/crl/ucfk_2024.crt"| /opt/cprocsp/bin/amd64/certmgr -inst -store mca -stdin




wget -qO- --no-check-certificate "https://adm44.ru/i/u/uc_korn_sert.cer"| /opt/cprocsp/bin/amd64/certmgr -inst -store mRoot -stdin
wget -qO- --no-check-certificate "https://adm44.ru/i/u/ca_ako.cer"| /opt/cprocsp/bin/amd64/certmgr -inst -store mRoot -stdin
wget -qO- --no-check-certificate "https://adm44.ru/i/u/cert-44.cer"| /opt/cprocsp/bin/amd64/certmgr -inst -store mRoot -stdin
wget -qO- --no-check-certificate "https://adm44.ru/i/u/%D0%A3%D0%A6%20%D0%90%D0%9A%D0%9E.cer"| /opt/cprocsp/bin/amd64/certmgr -inst -store mRoot -stdin
wget -qO- --no-check-certificate "https://adm44.ru/i/cert/262BF15DDCDC3BE3ECB0.crl"| /opt/cprocsp/bin/amd64/certmgr -inst -store mca -crl -stdin 
wget -qO- --no-check-certificate "https://adm44.ru/i/cert/D19AD678765F765838D4.crl"| /opt/cprocsp/bin/amd64/certmgr -inst -store mca -crl -stdin
wget -qO- --no-check-certificate "https://adm44.ru/i/cert/revock_03_2024.crl"| /opt/cprocsp/bin/amd64/certmgr -inst -store mca -crl -stdin
wget -qO- --no-check-certificate "https://adm44.ru/i/cert/revock_2.crl"| /opt/cprocsp/bin/amd64/certmgr -inst -store mca -crl -stdin
# Новый сертификат https://www.gosuslugi.ru/crt
wget -qO- --no-check-certificate "https://gu-st.ru/content/Other/doc/russian_trusted_root_ca.cer"|/opt/cprocsp/bin/amd64/certmgr -inst -store mRoot -stdin
wget -qO- --no-check-certificate "https://gu-st.ru/content/Other/doc/russian_trusted_sub_ca.cer"|/opt/cprocsp/bin/amd64/certmgr -inst -stdin
}

install_Gosuslugi(){
wget -c "https://ds-plugin.gosuslugi.ru/plugin/upload/assets/distrib/IFCPlugin-x86_64.deb"
dpkg -i IFCPlugin-x86_64.deb
#Options
/opt/cprocsp/sbin/amd64/cpconfig -ini '\config\PKCS11\slot17' -add string "ProvGOST" "Crypto-Pro GOST R 34.10-2012 Cryptographic Service Provider"
/opt/cprocsp/sbin/amd64/cpconfig -ini '\config\PKCS11\slot17' -add string "Firefox" "1"
/opt/cprocsp/sbin/amd64/cpconfig -ini '\config\PKCS11\slot17' -add string "Chromium" "1"
/opt/cprocsp/sbin/amd64/cpconfig -ini '\config\PKCS11\slot17' -add string "Reader" ""
wget -c https://www.cryptopro.ru/sites/default/files/public/faq/ifcx64.cfg
rm /etc/ifc.cfg && cp ifcx64.cfg /etc/ifc.cfg
/opt/cprocsp/bin/amd64/csptestf -absorb -certs -autoprov

}

install_DrWeb(){
wget https://192.168.10.248:9081/install/unix/workstation/drweb-11.1.4-av-linux-amd64.run --no-check-certificate -P antivir/
wget https://192.168.10.248:9081/install/unix/workstation/drwcsd-certificate.pem --no-check-certificate -P antivir/
cd antivir
chmod +x drweb-11.1.4-av-linux-amd64.run
./drweb-11.1.4-av-linux-amd64.run -- --non-interactive
cd ..

}


system_update(){
#полное обновление системы
apt update 
}

installing_the_required_packages(){
system_update

#Добавляем репозитории debian
apt install debian-archive-keyring
cat > /etc/apt/sources.list <<X-service
deb https://download.astralinux.ru/astra/stable/1.8_x86-64/repository-main/ 1.8_x86-64 main contrib non-free non-free-firmware
deb https://download.astralinux.ru/astra/stable/1.8_x86-64/repository-extended/ 1.8_x86-64 main contrib non-free non-free-firmware

deb http://deb.debian.org/debian bookworm main non-free-firmware
deb-src http://deb.debian.org/debian bookworm main non-free-firmware
deb http://deb.debian.org/debian-security/ bookworm-security main non-free-firmware
deb-src http://deb.debian.org/debian-security/ bookworm-security main non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main non-free-firmware
deb-src http://deb.debian.org/debian bookworm-updates main non-free-firmware

X-service

apt update

#Включаем btrfs
sed -i "s/\/home\s*btrfs\s*defaults/\/home btrfs autodefrag,noatime,space_cache=v2,compress-force=zstd:3,discard=async/g" etc/fstab
mount -a
btrfs quota enable /home
apt install btrfs-compsize

#Включить TRIM, если в системе установлен SSD
ssd=`cat /sys/block/sda/queue/rotational`
if [$ssd=0]; then
    cp /usr/share/doc/util-linux/examples/fstrim.service /etc/systemd/system 
    cp /usr/share/doc/util-linux/examples/fstrim.timer /etc/systemd/system 
    systemctl enable fstrim.timer
    sed -i 's/issue_discards = 0/issue_discards = 1/' /etc/lvm/lvm.conf
fi

#драйвера для принтера и сканера Samsung
wget -c https://archive.org/download/uld_V1.00.39_01.17.tar/uld_V1.00.39_01.17.tar.gz
tar -xzf uld_V1.00.39_01.17.tar.gz
cd uld 
./install.sh
cd ..
restart_service

# установка пакетов, необходимых для работы
apt install screen htop smartmontools nfs-common rsync util-linux printer-driver-gutenprint printer-driver-splix printer-driver-cups-pdf xrdp simple-scan -y
}


restart_service(){
systemctl enable smartd 
/lib/systemd/systemd-sysv-install disable rsync
}


remove_unnecessary_packages(){
#здесь в список можно добавить пакеты, которые не нужны в системе
apt remove qbittorrent blender jag -y
# автоочистка
apt autoremove -y
system_update
}

install15(){
installing_the_required_packages
remove_unnecessary_packages
exact_time
install_DrWeb
X11VNC_install
}   

install_snapper(){
apt install snapper
snapper -c home create-config /home
snapper -c home create
}

install_rudesktop(){
wget https://rudesktop.ru/download/rudesktop-astra-amd64.deb -P rudesktop/
cd rudesktop
dpkg -i rudesktop-astra-amd64.deb
cd ..

}


full_menu(){
OPTION=$(whiptail --title  "Настройка клиента Astra Linux CE" --menu  "Выберите пункт:" "${HEIGHT}" "${WIDTH}" 9 \
"1" "Установка требуемых пакетов\Обновление системы" \
"2" "Удаление нетребуемых пакетов\Обновление системы" \
"3" "Настройка точного времени" \
"4" "Настройка сервиса X11VNC" \
"5" "Установка антивируса Dr.Web" \
"6" "Автоматическая установка пунктов 1-5" \
"7" "Установка RuDesktop" \
"8" "Установка и\или обновление КриптоПроCSP+Cades" \
"9" "Установка и\или обновление плагина Госуслуги" 3>&1 1>&2 2>&3)
 
exitstatus=$?
if [ $exitstatus = 0 ];  then
     echo "Вы выбрали:" $OPTION
else
     echo "Вы выбрали Cancel."
fi

case $OPTION in
   "1") installing_the_required_packages;operation_success;full_menu;;
   "2") remove_unnecessary_packages;operation_success;full_menu;;
   "3") exact_time;operation_success;full_menu;;
   "4") X11VNC_install;operation_success;full_menu;;
   "5") install_DrWeb;operation_success;full_menu;;
   "6") install15;operation_success;full_menu;;
   "7") install_rudesktop;operation_success;full_menu;;
   "8") install_CryptoPro;operation_success;full_menu;;
   "9") install_Gosuslugi;operation_success;full_menu;;
esac    

clear
}


main_menu() {
    whiptail --title "Настройка клиента Astra Linux CE" \
        --yesno "Быстрая настройка нескольких пунктов Astra Linux
        
Этот скрипт позволяет: 
* выполнить обновление системы
* добавить/удалить необходимые пакеты
* установить сервис точного времени
* удаленный доступ к АРМ X11VNC
* установить и/или обновить КриптоПроCSP
* обновление плагинов для браузера
* установка антивируса DrWeb


Нажмите Next для вызова меню или Exit, если хотите выйти из скрипта  " \
        --yes-button "Next" --no-button "Exit" \
        "${HEIGHT}" "${WIDTH}" 
    if [ "$?" -ne "${SUCCESS}" ] ; then
        exit "${SUCCESS}"
    fi
    full_menu
}

main() {
    if [ "$(id -u)" -ne 0 ] ; then
        echo "Ошибка, скрипт должен запускаться с правами администратора"
        exit "${FAILURE}"
    fi
   main_menu
}

main "$@"

