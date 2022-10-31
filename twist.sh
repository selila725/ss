#! /bin/bash

## Twist Ver 0.5.6 beta* Written by Unbinilium https://github.com/Unbinilium/Twist
## Update Ver 1.0 will provide mptcp feature, this script will be rewrite and use standard commands

function shadowsocksconfig(){
    SSLOCAL="[\"[::0]\",\"0.0.0.0\"]"
    PORT="443"
    PASSWORD=""
    METHOD="xchacha20-ietf-poly1305"
    TIMEOUT="1800"
    OBFS="tls"
    OBFSHOST="mzstatic.com"
    OBFSURI="/"
    FASTOPEN="true"
    REUSEPORT="true"
    DNS1="8.8.8.8"
    DNS2="8.8.4.4"
    DNSv6a="2001:4860:4860::8888"
    DNSv6b="2001:4860:4860::8844"
    DSCP="EF"
    MODE="tcp_and_udp"
    MTU=""
    MPTCP="false"
    IPV6FIRST="false"
    SYSLOG="true"
    NODELAY="true"
    FWS="enable"
    BBR="enable"
}

function systemconfig(){
    libsodiumver=""
    mbedtlsver=""
    sslibevtag=""
    ssobfstag=""
    elrepover7="7.0-3"
    elrepover6="6-8"
    ETH=""
    PUBLICIP=""
    PUBLICIPv6=""
    IPREGEX="^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
}

function install_twist(){
    clear
    twistprint
    echo -e "#[\033[32;1m   A Light Script For You To Setup Shadowsocks-libev Server       \033[0m]#"
    echo -e "#[\033[32;1m              Twist Script Written By Unbinilium                  \033[0m]#"
    echo -e "#[\033[32;1m             Installation will Start in 5 Seconds                 \033[0m]#"
    twistprint banner
    echo ""
    sleep 5
    rootness
    selinuxdisable
    [ -d /etc/twist ] || mkdir -p /etc/twist
    twistlog "[TWIST Installing]"
    shadowsocksconfig
    systemconfig
    systemdetect
    dependenciesinstall
    tcpbbrenable
    sslibevinstall "install"
    sslibevconfigure
    firewallconfigure
    servicesstart
    servicesstatus
}

function update_twist(){
    clear
    twistprint
    echo -e "#[\033[32;1m                 Update Twist Shadowsocks-libev                   \033[0m]#"
    echo -e "#[\033[32;1m                 Update will Start in 5 Seconds                   \033[0m]#"
    twistprint banner
    echo ""
    sleep 5
    rootness
    twistlog "[TWIST Updating]"
    shadowsocksconfig
    systemconfig
    selinuxdisable
    systemdetect
    if [ "$twistinstalled" = "false" ]; then
        twistprint banner nofile
    else
        if [ -r /var/run/shadowsocks-libev.pid ]; then
            read pid < /var/run/shadowsocks-libev.pid
            [ -e /etc/twist/twistprotect ] && { echo -e "# \${date} Shadowsocks-libev Service Stopped Due To Update " >> /var/log/twist; rm -f /etc/twist/twistprotect; }
            kill -9 $pid
            rm -f /var/run/shadowsocks-libev.pid
        fi
    fi
    dependenciesinstall
    sslibevinstall "install"
    echo ""
    servicesstart
    sleep 2
    clear
    twistprint
    echo -e "#[\033[32;1m                      Twist Update Finished                       \033[0m]#"
    twistprint banner
    serverrestart "Update"
    echo ""
    exit 0
}

function uninstall_twist(){
    clear
    twistprint
    echo -e "#[\033[31;1m               Uninstall Twist Shadowsocks-libev                  \033[0m]#"
    echo -e "#[\033[31;1m               Uninstall will Start in 5 Seconds                  \033[0m]#"
    twistprint banner
    echo ""
    sleep 5
    rootness
    if ! grep -qs "Twist" /etc/sysctl.conf; then
        twistprint banner nofile
    else
        sed -i "/# Twist/d" /etc/sysctl.conf
        sed -i "/twistprotect/d" /etc/crontab
        if [ "$packagemanagertype" = "p" ]; then
            systemctl restart cronie.service
        else
            systemctl restart cron.service
        fi
        rm -f /root/twistprotect
        twist stop
        echo ""
        sleep 2
    fi
    sslibevinstall "uninstall"
    timemachine "restore" "/etc/twist/sysctl.conf" "/etc/sysctl.conf" && sysctl -e -p
    timemachine "restore" "/etc/twist/limits.conf" "/etc/security/limits.conf"
    timemachine "restore" "/etc/twist/login" "/etc/pam.d/login"
    timemachine "restore" "/etc/twist/resolv.conf" "/etc/resolv.conf"
    timemachine "restore" "/etc/twist/iptables.rules" "/etc/iptables.rules" && iptables-restore < /etc/iptables.rules
    timemachine "restore" "/etc/twist/ip6tables.rules" "/etc/ip6tables.rules" && ip6tables-restore < /etc/ip6tables.rules
    timemachine "restore" "/etc/twist/iptablesload" "/etc/network/if-pre-up.d/iptablesload"
    timemachine "restore" "/etc/twist/ip6tablesload" "/etc/network/if-pre-up.d/ip6tablesload"
    timemachine "restore" "/etc/twist/crontab" "/etc/crontab"
    timemachine "restore" "/etc/twist/rc.local" "/etc/rc.local"
    timemachine "restore" "/etc/twist/.htaccess" "/var/www/html/.htaccess"
    timemachine "restore" "/etc/twist/index.html" "/var/www/html/index.html"
    rm -f /usr/bin/twist /root/twistprotect /var/log/twist
    rm -fr /etc/twist /etc/shadowsocks-libev
    systemctl restart fail2ban apache2
    [ -e /var/www/html/index.html ] || systemctl stop apache2
    ldconfig
    clear
    twistprint
    echo -e "#[\033[32;1m                Twist Uninstallation Finished                     \033[0m]#"
    twistprint banner
    echo ""
    exit 1
}

function twistprint(){
    if [ -z "$1" ]; then
        echo "######################################################################"
        echo "#####################################################################"
        echo "       ###       ###         ###     ###      #########    #########"
        echo "       ###        ###    #  ###     ###      ##               ##"
        echo "       ###         ###  ## ###     ###      #########        ##"
        echo "       ###          ### ## ##     ###             ##        ##"
        echo "       ###           ### ###     ###      #########        ##"
        echo ""
    elif [ -z "$3" ]; then
        echo "######################################################################"
    else
        twistlog "Twist was not found on Your Server"
        echo -e "#[\033[31;1m              Twist was not found on Your Server!                 \033[0m]#"
        echo ""
        exit 1
    fi
}

function twistlog(){
    [ -e /var/log/twist ] || touch /var/log/twist
    echo "# ${date} ${1} " >> /var/log/twist
}

function kernelupdateerr(){
    BBR="disable"
    echo ""
    twistlog "${1}"
    echo -e "# [\033[31;1m${1}! \033[0m]"
    echo ""
    sleep 3
}

function dependenciesinstallerr(){
    echo ""
    twistlog "Cannot ${1} Dependencies"
    echo -e "# [\033[31;1mCannot ${1} Dependencies, Please check your network or errors displayed! \033[0m]"
    echo ""
    exit 1
}

function sslibevinstallerr(){
    rm -rf libsodium-${libsodiumver}.tar.gz libsodium-${libsodiumver} mbedtls-${mbedtlsver}-gpl.tgz mbedtls-${mbedtlsver} ${sslibevver}.tar.gz $sslibevver ${ssobfsver}.tar.gz $ssobfsver
    echo ""
    if [ -z "$2" ]; then
        twistlog "Cannot download ${1} source"
        echo -e "# [\033[31;1mCannot download ${1} source. Aborting! \033[0m]"
    else
        twistlog "Error ${1} failed to build"
        echo -e "# [\033[31;1mError ${1} failed to build. Aborting! \033[0m]"
    fi
    echo ""
    exit 1
}

function systemdetecterr(){
    twistlog "Twist could only run on Ubuntu, Debian, Raspbian, Arch Linux, CentOS, Red Hat or Fedora"
    echo -e "# [\033[31;1mTwist could only run on Ubuntu, Debian, Raspbian, Arch Linux, CentOS, Red Hat or Fedora. Aborating! \033[0m]"
    echo ""
    exit 1
}

function timemachine(){
    if [ "$1" = "backup" ]; then
        twistlog "Backing up ${2} to ${3}"
        if [ -e "$3" ]; then
            [ -e "$2" ] && cp -f "${2}" "${3}.old-${date}"
        else
            [ -e "$2" ] && { cp -f "${2}" "${3}"; cp -f "${2}" "${3}.old-${date}"; }
        fi
    else
        if [ -e "$2" ]; then
            twistlog "Restore ${3} from ${2}"
            cp -f "${2}" "${3}"
        else
            rm -f "${3}"
        fi
    fi
}

function serverrestart(){
    if [ "$serverrestart" = "true" ]; then
        twistlog "[TWIST Required Server Restart]"
        echo -e "# [\033[31;1mThe Server Requires Restart to Finish ${1}, Please Press Enter to Reboot! \033[0m]"
        read -p ""
        sleep 3
        reboot
    fi
}

function rootness(){
    if [ "$(id -u)" != 0 ]; then
        echo -e "# [\033[31;1mError:Twist must run by root. Please run Twist with root access! \033[0m]"
        echo ""
        exit 1
    fi
}

function selinuxdisable(){
    [ -z "$(which grep)" ] && { echo ""; echo -e "# [\033[31;1mTwist requires the basic dependencies\033[0m \033[32;1mgrep\033[0m, \033[31;1mPlease Install the Dependencies first. \033[0m]"; echo ""; exit 1; }
    if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        setenforce 0
    fi
}

function systemdetect(){
    if grep -Eqi "Ubuntu|Debian|Raspbian|Arch Linux" /etc/*-release || grep -Eqi "Ubuntu|Debian|Raspbian|Arch Linux" /proc/version; then
        systemtype="1"
    elif grep -Eqi "CentOS|Red Hat|Fedora" /etc/*-release || grep -Eqi "CentOS|Red Hat|Fedora" /proc/version; then
        systemtype="0"
    else
        systemdetecterr
    fi
    if [ ! -z "$(which apt)" ]; then
        packagemanagertype="a"
        webservername="apache2"
    elif [ ! -z "$(which yum)" ]; then
        packagemanagertype="y"
        webservername="httpd"
    elif [ ! -z "$(which pacman)" ]; then
        packagemanagertype="p"
        webservername="apache"
    else
        systemdetecterr
    fi
    if [ -f /proc/user_beancounters ]; then
        BBR="disable"
        if [ "$packagemanagertype" = "a" ]; then
            systemtype="1"
        elif [ "$packagemanagertype" = "y" ]; then
            systemtype="0"
        elif [ "$packagemanagertype" = "p" ]; then
            systemtype="1"
        fi
    fi
    if [ "$packagemanagertype" = "a" ]; then
        tries="0"
        while fuser /var/lib/apt/lists/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock; do
            [ "$tries" = "0" ] && { echo ""; echo -e "# [\033[31;1mTrying to lock the Administration Directory, another Process may using it. \033[0m]"; echo ""; }
            [ "$tries" = "20" ] && { rm -f /var/lib/apt/lists/lock; rm -f /var/cache/apt/archives/lock; rm -f /var/lib/dpkg/lock; }
            [ "$tries" = "21" ] && dpkg --configure -a
            [ "$tries" -ge "22" ] && { echo ""; echo -e "# [\033[31;1mUnable to lock the Administration Directory. \033[0m]"; echo ""; break; }
            tries=$((tries+1))
            sleep 3
        done
    fi
    if [ -z "$(which awk)" ] || [ -z "$(which route)" ] || [ -z "$(which ip)" ] || [ -z "$(which dig)" ] || [ -z "$(which curl)" ]; then
        if [ "$packagemanagertype" = "a" ]; then
            apt-get update || dependenciesinstallerr "Update"
            apt-get -yq install gawk curl net-tools dnsutils || dependenciesinstallerr "Install"
        elif [ "$packagemanagertype" = "y" ]; then
            yum -y update || dependenciesinstallerr "Update"
            yum -y install gawk curl net-tools bind-utils || dependenciesinstallerr "Install"
        else
            pacman -Syyu --noconfirm || dependenciesinstallerr "Update and Upgrade"
            pacman -Syu --noconfirm gawk curl net-tools || dependenciesinstallerr "Install"
        fi
        clear
    fi
    if ! grep -qs "Twist" /etc/sysctl.conf; then
        twistinstalled="false"
    fi
    kernelverheader="$(uname -r | grep -oE '[0-9]+\.[0-9]+')"
    kernelverheaderold="$kernelverheader"
    if [ $(echo ${kernelverheader} | awk -v ver=4.8 '{print($1>ver)? "1":"0"}') -eq "0" ]; then
        [ "$BBR" = "enable" ] && serverrestart="true"
    fi
    if [ -z "$ETH" ]; then
        ETH="$(route | grep '^default' | grep -o '[^ ]*$')"
        [ -z "$ETH" ] && ETH="$(ip -4 route list 0/0 | grep -Po '(?<=dev )(\S+)')"
        if [ ! "$(echo "$ETH" | xargs | awk '{print $2}')" = "" ]; then
            if [ ! "$(echo "$ETH" | xargs | awk '{print $1}')" = "$(echo "$ETH" | xargs | awk '{print $2}')" ]; then
                twistlog "More than 2 Default Network Interface detected"
                echo -e "# [\033[31;1mThere are more than 2 Default Network Interface. Please choose it manually! \033[0m]"
                echo ""
                ip link
                echo ""
                echo -e "Please Enter [\033[32;1mNetwork Interface Name\033[0m]:"
                read -p "Input Interface Name:" ETH
            else
                ETH="$(echo "$ETH" | xargs | awk '{print $1}')"
            fi
        else
            ETH="$(echo "$ETH" | xargs | awk '{print $1}')"
        fi
    fi
    ethstatus="$(cat /sys/class/net/${ETH}/operstate)"
    if [ -z "$ethstatus" ] || [ "$ethstatus" = "down" ]; then
        twistlog "The Network Interface:${ETH} is not available"
        echo -e "# [\033[31;1mNetwork Interface '${ETH}' is not available. Please try another Network Interface listed below! \033[0m]"
        echo ""
        ip link
        echo ""
        echo -e "Please Enter [\033[32;1mNetwork Interface Name\033[0m]:"
        read -p "Input Interface Name:" eth
     	if [ ! "$eth" = "" ]; then
            ethstatus="$(cat /sys/class/net/${eth}/operstate)"
            if [ -z "$ethstatus" ] || [ "$ethstatus" = "down" ]; then
                echo ""
                twistlog "The Network Interface:${eth} is not available"
                echo -e "# [\033[31;1mThe Network Interface:${eth} you entered is not available. Aborting! \033[0m]"
                echo ""
                exit 1
            else
                ETH="$eth"
                echo ""
                twistlog "Using the new Network Interface ${ETH}"
                echo -e "# [\033[33;1mNetwork Interface check passed, Using the new Interface\033[0m \033[32;1m${ETH} \033[0m]"
                echo ""
            fi
        fi
    fi
    [ -z "$PUBLICIP" ] && PUBLICIP="$(dig @resolver1.opendns.com -t A -4 myip.opendns.com +short)"
    if ! printf %s "$PUBLICIP" | grep -Eq "$IPREGEX"; then
        echo ""
        twistlog "Cannot detect a valid Public IP"
        echo -e "# [\033[31;1mCannot detect a valid Public IP. Please fill your Public IP address below! \033[0m]"
        read -p "Input Your Public IP:" publicip
        if ! printf %s "$publicip" | grep -Eq "$IPREGEX"; then
            echo ""
            twistlog "# The IP:${publicip} is not vailed"
            echo -e "# [\033[31;1mThe IP:${publicip} you entered is not vailed. Aborting! \033[0m]"
            echo ""
            exit 1
        else
            PUBLICIP="$publicip"
            echo ""
            twistlog "Using Public IP:${PUBLICIP}"
            echo -e "# [\033[32;1mYou are now using Public IP:${PUBLICIP} \033[0m]"
            echo ""
        fi
    fi
    DNS="${DNS1},${DNS2},${DNSv6a},${DNSv6b}"
    if [ -z "$(ip -6 addr show ${ETH})" ] || [ -z "$PUBLICIPv6" ]; then
        PUBLICIPv6="$(curl -s diagnostic.opendns.com/myip)"
        if [ -z "$PUBLICIPv6" ] || [ "$PUBLICIPv6" = "$PUBLICIP" ]; then
            SSLOCAL="\"0.0.0.0\""
            DNS="${DNS1},${DNS2}"
            IPV6ENABLE="false"
            IPV6FIRST="false"
        fi
     fi
     [ -z "$MTU" ] && MTU="$(cat /sys/class/net/${ETH}/mtu)"
     [ -z "$MTU" ] && MTU="1492"
}

function dependenciesinstall(){
    if [ "$packagemanagertype" = "a" ]; then
        apt-get -yq update || dependenciesinstallerr "Update"
        apt-get -yq upgrade || dependenciesinstallerr "Upgrade"
        apt-get -yq install wget gawk grep curl sed git gcc swig gettext autoconf automake make libtool perl cpio xmlto asciidoc cron fail2ban net-tools dnsutils rng-tools libc-ares-dev libev-dev openssl libssl-dev zlib1g-dev libpcre3-dev libevent-dev build-essential python-dev python-pip python-setuptools python-m2crypto
        [ "$?" != "0" ] && dependenciesinstallerr "Install"
        [ "$FWS" = "enable" ] && { apt-get -yq install apache2 || dependenciesinstallerr "Apache"; }
    elif [ "$packagemanagertype" = "y" ]; then
        yum -y update || dependenciesinstallerr "Update"
        yum -y upgrade || dependenciesinstallerr "Upgrade"
        [ -e /etc/yum.repos.d/epel.repo ] || { yum -y install epel-release yum-utils || { twistlog "Cannot add EPEL repository"; echo -e "# [\033[31;1mCannot add EPEL repository. Aborting! \033[0m]"; exit 1; }; }
        yum -y install wget gawk grep curl sed git gcc swig gettext-devel autoconf automake make libtool pcre-devel perl-devel cpio xmlto asciidoc vixie-cron crontabs fail2ban net-tools bind-utils rng-tools expat-devel openssl-devel zlib-devel libev-devel c-ares-devel python-devel python-setuptools python-pip
        [ "$?" != "0" ] && dependenciesinstallerr "Install"
        [ "$FWS" = "enable" ] && { yum -y install ${webservername} || dependenciesinstallerr "Apache"; }
    else
        pacman -Syyu --noconfirm || dependenciesinstallerr "Update and Upgrade"
        pacman -Syu --noconfirm wget gawk grep curl sed git gcc swig gettext autoconf automake make libtool pcre perl cpio xmlto asciidoc cronie fail2ban net-tools rng-tools openssl zlib c-ares libev python-devel python-setuptools python-pip python2-m2crypto
        [ "$?" != "0" ] && dependenciesinstallerr "Install"
        [ "$FWS" = "enable" ] && { pacman -Syu --noconfirm apache || dependenciesinstallerr "Apache"; }
    fi
    pip install -q qrcode || { echo ""; twistlog "Cannot Install QRCode"; echo -e "# [\033[31;1mCannot Install QRCode, You may unable to configure clients by QRCode! \033[0m]"; echo ""; sleep 3; }
}

function tcpbbrenable(){
    if [ "$BBR" = "enable" ]; then
        timemachine "backup" "/etc/sysctl.conf" "/etc/twist/sysctl.conf"
        if [ "$(printf '%s\n' ${kernelverheader} "4.8" | sort -V | head -n1)" != ${kernelverheader} ] || [ "$kernelupdated" = "true" ]; then
            if [ ! "$(sysctl net.ipv4.tcp_available_congestion_control | awk '{print $3}')" = "bbr" ]; then
                sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
                echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
            fi
        else
            echo "net.ipv4.tcp_congestion_control = hybla" >> /etc/sysctl.conf
            kernelupdate
        fi
    fi
}

function kernelupdate(){
    if [ "$packagemanagertype" = "a" ]; then
        KERNELURL="http://kernel.ubuntu.com/~kernel-ppa/mainline/"
        KERNELVER="$(wget -qO- ${KERNELURL} | awk -F'\"v' '/v[4-9]./{print $2}' | cut -d/ -f1 | grep -v -  | sort -V | tail -1)"
        [ -z "$KERNELVER" ] && kernelupdateerr "Cannot get the newest linux kernel verison, bbr disabled"
        if [ "$BBR" = "enable" ]; then
            case "$(dpkg --print-architecture)" in
                amd64)
                    KERNEL="$(wget -qO- ${KERNELURL}v${KERNELVER}/ | grep "linux-image" | grep "lowlatency" | awk -F'\">' '/amd64.deb/{print $2}' | cut -d'<' -f1 | head -1)"
                    ;;
                i386)
                    KERNEL="$(wget -qO- ${KERNELURL}v${KERNELVER}/ | grep "linux-image" | grep "lowlatency" | awk -F'\">' '/i386.deb/{print $2}' | cut -d'<' -f1 | head -1)"
                    ;;
                armhf)
                    KERNEL="$(wget -qO- ${KERNELURL}v${KERNELVER}/ | grep "linux-image" | grep "generic" | awk -F'\">' '/armhf.deb/{print $2}' | cut -d'<' -f1 | head -1)"
                    ;;
                arm64)
                    KERNEL="$(wget -qO- ${KERNELURL}v${KERNELVER}/ | grep "linux-image" | grep "generic" | awk -F'\">' '/arm64.deb/{print $2}' | cut -d'<' -f1 | head -1)"
                    ;;
                ppc64el)
                    KERNEL="$(wget -qO- ${KERNELURL}v${KERNELVER}/ | grep "linux-image" | grep "generic" | awk -F'\">' '/ppc64el.deb/{print $2}' | cut -d'<' -f1 | head -1)"
                    ;;
                s390x)
                    KERNEL="$(wget -qO- ${KERNELURL}v${KERNELVER}/ | grep "linux-image" | grep "generic" | awk -F'\">' '/s390x.deb/{print $2}' | cut -d'<' -f1 | head -1)"
                    ;;
                *)
                    kernelupdateerr "Cannot get the newest linux kernel verison, bbr disabled"
                    ;;
            esac
            [ "$BBR" = "enable" ] && wget -t 3 -T 30 -nv -O "$KERNEL" "${KERNELURL}v${KERNELVER}/${KERNEL}"
            [ "$BBR" = "enable" ] && { dpkg -i $KERNEL || kernelupdateerr "Cannot update linux kernel verison, bbr disabled"; }
            [ "$BBR" = "enable" ] && { dpkg -l | grep linux-image; rm -f $KERNEL; update-grub; }
        fi
    elif [ "$packagemanagertype" = "y" ]; then
        rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org || kernelupdateerr "Cannot get ELRepo key, you may unable to install ELRepo packages"
        if grep -qs "release 7" /etc/*-release; then
            rpm -Uvh "http://www.elrepo.org/elrepo-release-${elrepover7}.el7.elrepo.noarch.rpm" || kernelupdateerr "Cannot Install ELRepo repository. Aborting"
            [ "$BBR" = "enable" ] && { yum --enablerepo=elrepo-kernel -y install kernel-ml kernel-ml-devel || kernelupdateerr "Cannot update linux kernel verison, bbr disabled"; }
            [ "$BBR" = "enable" ] && grub2-set-default 0
        elif grep -qs "release 6" /etc/*-release; then
            rpm -Uvh "http://www.elrepo.org/elrepo-release-${elrepover6}.e16.elrepo.noarch.rpm" || kernelupdateerr "Cannot Install ELRepo repository. Aborting"
            [ "$BBR" = "enable" ] && { yum --enablerepo=elrepo-kernel -y install kernel-ml kernel-ml-devel || kernelupdateerr "Cannot update linux kernel verison, bbr disabled"; }
            [ "$BBR" = "enable" ] && sed -i 's/^default=.*/default=0/g' /boot/grub/grub.conf
        fi
    elif [ "$packagemanagertype" = "p" ]; then
        if grep -Eqi "IgnorePkg|IgnoreGroup" /etc/pacman.conf; then
            sed -i "/IgnorePkg/d;/IgnoreGroup/d" /etc/pacman.conf
        fi
        pacman -Syyu --noconfirm || kernelupdateerr "Cannot update linux kernel verison, bbr disabled"
    fi
    [ "$BBR" = "enable" ] && { kernelupdated="true"; serverrestart="true"; }
    kernelverheader="$(uname -r | grep -oE '[0-9]+\.[0-9]+')"
    tcpbbrenable
}

function sslibevinstall(){
    MAKECORES="$(grep -c ^processor /proc/cpuinfo)"
    [ -z "$MAKECORES" ] && MAKECORES="1"
	if [ "$1" = "install" ]; then
        [ -z "$libsodiumver" ] && libsodiumver="$(wget -qO- https://api.github.com/repos/jedisct1/libsodium/releases/latest | grep 'tag_name' | cut -d\" -f4 | cut -d'-' -f1)"
        wget -t 3 -T 30 -nv -O libsodium-${libsodiumver}.tar.gz https://github.com/jedisct1/libsodium/releases/download/${libsodiumver}-RELEASE/libsodium-${libsodiumver}.tar.gz
        [ "$?" != "0" ] && sslibevinstallerr "libsodium-${libsodiumver}"
        [ -d libsodium-${libsodiumver} ] && rm -rf libsodium-${libsodiumver}
        tar zxf libsodium-${libsodiumver}.tar.gz
        pushd libsodium-${libsodiumver}
        ./configure --prefix=/usr && make "-j$((MAKECORES+1))" && make install || sslibevinstallerr "libsodium-${libsodiumver}" err
        popd
        if ! ldconfig -p | grep -wq "/usr/lib"; then
            echo "/usr/lib" > /etc/ld.so.conf.d/lib.conf
        fi
        ldconfig
        [ -z "$mbedtlsver" ] && mbedtlsver="$(wget -qO- https://tls.mbed.org/download-archive | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | cut -d'.' -f1,2,3 | sort -V | tail -1)"
        wget -t 3 -T 30 -nv -O mbedtls-${mbedtlsver}-gpl.tgz https://tls.mbed.org/download/mbedtls-${mbedtlsver}-gpl.tgz
        [ "$?" != "0" ] && sslibevinstallerr "mbedtls-${mbedtlsver}"
        [ -d mbedtls-${mbedtlsver} ] && rm -rf mbedtls-${mbedtlsver}
        tar xf mbedtls-${mbedtlsver}-gpl.tgz
        pushd mbedtls-${mbedtlsver}
        make SHARED=1 CFLAGS=-fPIC "-j$((MAKECORES+1))" && make DESTDIR=/usr install || sslibevinstallerr "mbedtls-${mbedtlsver}" err
        popd
        ldconfig
        rm -rf libsodium-${libsodiumver}.tar.gz libsodium-${libsodiumver} mbedtls-${mbedtlsver}-gpl.tgz mbedtls-${mbedtlsver}
    fi
    [ -z "$sslibevtag" ] && sslibevtag="$(wget -qO- https://api.github.com/repos/shadowsocks/shadowsocks-libev/releases/latest | grep 'tag_name' | cut -d\" -f4)"
    sslibevver="shadowsocks-libev-$(echo ${sslibevtag} | sed -e 's/^[a-zA-Z]//g')"
    wget -t 3 -T 30 -nv -O ${sslibevver}.tar.gz https://github.com/shadowsocks/shadowsocks-libev/releases/download/${sslibevtag}/${sslibevver}.tar.gz
    [ "$?" != "0" ] && sslibevinstallerr "shadowsocks-libev-$(echo ${sslibevtag} | sed -e 's/^[a-zA-Z]//g')"
    [ -d ${sslibevver} ] && rm -rf $sslibevver
    tar zxf ${sslibevver}.tar.gz
    pushd $sslibevver
    ./configure --disable-documentation
    make "-j$((MAKECORES+1))" && make ${1} || sslibevinstallerr "shadowsocks-libev-$(echo ${sslibevtag} | sed -e 's/^[a-zA-Z]//g')" err
    popd
    ldconfig
    [ -z "$ssobfstag" ] && ssobfstag="$(wget -qO- https://api.github.com/repos/shadowsocks/simple-obfs/releases/latest | grep 'tag_name' | cut -d\" -f4)"
    ssobfsver="simple-obfs-$(echo ${ssobfstag} | sed -e 's/^[a-zA-Z]//g')"
    wget -t 3 -T 30 -nv -O ${ssobfsver}.tar.gz https://github.com/shadowsocks/simple-obfs/archive/${ssobfstag}.tar.gz
    [ "$?" != "0" ] && sslibevinstallerr "simple-obfs-$(echo ${ssobfstag} | sed -e 's/^[a-zA-Z]//g')"
    [ -d ${ssobfsver} ] && rm -rf $ssobfsver
    tar zxf ${ssobfsver}.tar.gz
    pushd $ssobfsver
    [ -d libcork ] && rm -rf libcork
    git clone https://github.com/shadowsocks/libcork.git -b simple-obfs
    [ "$?" != "0" ] && sslibevinstallerr "libcork"
    ./autogen.sh
    ./configure
    make "-j$((MAKECORES+1))" && make ${1} || sslibevinstallerr "simple-obfs-$(echo ${ssobfstag} | sed -e 's/^[a-zA-Z]//g')" err
    popd
    ldconfig
    [ -f /usr/local/bin/obfs-server ] && ln -s /usr/local/bin/obfs-server /usr/bin
    rm -rf ${sslibevver}.tar.gz $sslibevver ${ssobfsver}.tar.gz $ssobfsver
}

function sslibevconfigure(){
    OBFSLOCAL="obfs-host"
    [ "$FWS" = "enable" ] && OBFSLOCAL="failover"
    OBFSTFO="fast-open;"
    [ "$FASTOPEN" = "true" ] || OBFSTFO=""
    OBFSURL=";obfs-uri=${OBFSURI}"
    [ -z "$OBFSURI" ] && OBFSURL=""
    [ "$OBFSURI" = "/" ] && OBFSURL=""
    [ -z "$PASSWORD" ] && PASSWORD="$(< /dev/urandom tr -dc 'A-HJ-NPR-Za-km-z2-9-._+?%^&*()' | head -c 8)"
    [ -d /etc/shadowsocks-libev ] || mkdir -p /etc/shadowsocks-libev
    timemachine "backup" "/etc/shadowsocks-libev/config.json" "/etc/twist/config.json"
    cat > /etc/shadowsocks-libev/config.json <<-EOF
{
    "server":${SSLOCAL},
    "server_port":${PORT},
    "password":"${PASSWORD}",
    "method":"${METHOD}",
    "timeout":${TIMEOUT},
    "udp_timeout":${TIMEOUT},
    "plugin":"obfs-server",
    "plugin_opts":"obfs=${OBFS};${OBFSTFO}${OBFSLOCAL}=${OBFSHOST}:${PORT}${OBFSURL}",
    "fast_open":${FASTOPEN},
    "reuse_port":${REUSEPORT},
    "nofile":512000,
    "nameserver":"${DNS}",
    "dscp":"${DSCP}",
    "mode":"${MODE}",
    "mtu":${MTU},
    "mptcp":${MPTCP},
    "ipv6_first":${IPV6FIRST},
    "use_syslog":${SYSLOG},
    "no_delay":${NODELAY},
}
EOF
    if [ "$twistinstalled" = "false" ]; then
        timemachine "backup" "/etc/sysctl.conf" "/etc/twist/sysctl.conf"
        cat >> /etc/sysctl.conf <<-EOF

# Twist
fs.file-max = 512000
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 256000
net.core.somaxconn = 4096
net.ipv4.udp_mem = 25600 51200 102400
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.ip_local_port_range = 49152 65535
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 4096
net.core.default_qdisc = fq
net.ipv4.ip_forward = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_fack = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fwmark_accept = 1
net.ipv4.tcp_stdurg = 1
net.ipv4.tcp_synack_retries = 30
net.ipv4.tcp_syn_retries = 30
net.ipv4.tcp_rfc1337 = 1
net.ipv4.tcp_fin_timeout = 60
net.ipv4.tcp_keepalive_time = ${TIMEOUT}
net.ipv4.tcp_mtu_probing = 2
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_low_latency = 1
net.ipv4.udp_l3mdev_accept = 1
net.ipv4.fib_multipath_hash_policy = 1
net.ipv4.fib_multipath_use_neigh = 1
net.ipv4.cipso_rbm_optfmt = 1
net.ipv4.fwmark_reflect = 1
net.ipv4.conf.all.accept_source_route = 1
net.ipv4.conf.all.accept_redirects = 1
net.ipv4.conf.all.send_redirects = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.all.arp_accept = 1
net.ipv4.conf.all.arp_announce = 1
net.ipv4.conf.all.proxy_arp = 1
net.ipv4.conf.all.proxy_arp_pvlan = 1
net.ipv4.conf.all.mc_forwarding = 1
net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.all.accept_source_route = 1
net.ipv6.conf.all.accept_redirects = 1
net.ipv6.conf.all.autoconf = 1
net.ipv6.conf.all.accept_ra = 2
net.ipv6.conf.all.seg6_enabled = 1

EOF
        timemachine "backup" "/etc/security/limits.conf" "/etc/twist/limits.conf"
        echo "*                soft    nofile          512000" >> /etc/security/limits.conf
        echo "*                hard    nofile          512000" >> /etc/security/limits.conf
        echo "" >> /etc/security/limits.conf
        if ! grep -qs "pam_limits.so" /etc/pam.d/login; then
            timemachine "backup" "/etc/pam.d/login" "/etc/twist/login"
            [ "$systemtype" = "0" ] && echo "session    required     pam_limits.so" >> /etc/pam.d/login
        fi
        timemachine "backup" "/etc/resolv.conf" "/etc/twist/resolv.conf"
        echo "nameserver ${DNS1}" >> /etc/resolv.conf
        echo "nameserver ${DNS2}" >> /etc/resolv.conf
        [ "$IPV6ENABLE" = "false" ] || echo "nameserver ${DNSv6a}" >> /etc/resolv.conf
        [ "$IPV6ENABLE" = "false" ] || echo "nameserver ${DNSv6b}" >> /etc/resolv.conf
        echo "" >> /etc/resolv.conf
    fi
}

function firewallconfigure(){
    iptables-save > "/etc/twist/iptables.rules"
    iptables-save > "/etc/twist/iptables.rules.old-${date}"
    iptables -I INPUT -m conntrack --ctstate INVALID -j DROP
    iptables -I INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    iptables -I INPUT -p tcp -m multiport --dports $PORT -j ACCEPT
    iptables -I INPUT -p udp -m multiport --dports $PORT -j ACCEPT
    iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $PORT -j ACCEPT
    iptables -I INPUT -m state --state NEW -m udp -p udp --dport $PORT -j ACCEPT
    iptables -I FORWARD -m conntrack --ctstate INVALID -j DROP
    iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
    iptables -t nat -A POSTROUTING -o $ETH -j MASQUERADE
    iptables-save > "/etc/iptables.rules"
    timemachine "backup" "/etc/ip6tables.rules" "/etc/twist/ip6tables.rules"
    cp -f "/etc/iptables.rules" "/etc/ip6tables.rules"
    [ -d /etc/network/if-pre-up.d ] || mkdir -p /etc/network/if-pre-up.d
    timemachine "backup" "/etc/network/if-pre-up.d/iptablesload" "/etc/twist/iptablesload"
    cat > /etc/network/if-pre-up.d/iptablesload <<-EOF
#!/bin/sh

iptables-restore < /etc/iptables.rules
exit 0

EOF
    timemachine "backup" "/etc/network/if-pre-up.d/ip6tablesload" "/etc/twist/ip6tablesload"
    cat > /etc/network/if-pre-up.d/ip6tablesload <<-EOF
#!/bin/sh

ip6tables-restore < /etc/ip6tables.rules
exit 0

EOF
}

function servicesstart(){
    recheckkernelverheader="$(uname -r | grep -oE '[0-9]+\.[0-9]+')"
    if [ $(echo ${recheckkernelverheader} | awk -v ver="${kernelverheaderold}" '{print($1>ver)? "1":"0"}') -eq "1" ]; then
        serverrestart="true"
        [ "$recheckkernelverheader" = "$kernelverheaderold" ] && serverrestart="false"
    fi
    if [ -f /usr/local/bin/ss-server ]; then
        ssserverpath="/usr/local/bin/ss-server"
    else
        ssserverpath="/usr/bin/ss-server"
    fi
    if [ "$twistinstalled" = "false" ]; then
        timemachine "backup" "/etc/rc.local" "/etc/twist/rc.local"
        [ -e /etc/rc.local ] || echo "#!/bin/bash" > /etc/rc.local
        sed --follow-symlinks -i '/^exit 0/d' /etc/rc.local
        cat >> /etc/rc.local <<-EOF

sysctl -q -p
iptables-restore < /etc/iptables.rules
ip6tables-restore < /etc/ip6tables.rules
systemctl restart fail2ban cron ${webservername}
if [ -e /etc/twist/twistprotect ]; then
    if [ -r /var/run/shadowsocks-libev.pid ]; then
        read pid < /var/run/shadowsocks-libev.pid
        [ -d "/proc/\${pid}" ] || ${ssserverpath} -uv -c /etc/shadowsocks-libev/config.json -f /var/run/shadowsocks-libev.pid
    else
        ${ssserverpath} -uv -c /etc/shadowsocks-libev/config.json -f /var/run/shadowsocks-libev.pid
    fi
fi
exit 0

EOF
    else
        [ -e /etc/rc.local ] && cp -f "/etc/rc.local" "/etc/twist/rc.local.old-${date}"
    fi
    cat > /usr/bin/twist <<-EOF
#!/bin/bash

date="\$(date +%Y-%m-%d-%H:%M:%S)"
status="0"
if [ ! -f /etc/shadowsocks-libev/config.json ]; then
    twistlog "Shadowsocks-libev Service Error Due To No Config File"
    echo -e "# \033[31;1mError: Shadowsocks-libev config file\033[0m \033[32;1m/etc/shadowsocks-libev/config.json\033[0m \033[31;1mwas not found \033[0m"
    exit 1
else
    [ -e /var/log/twist ] || touch /var/log/twist
fi

twistlog(){
    echo "# \${date} \${1} " >> /var/log/twist
    [ "\$2" = "echo" ] && echo -e "# \033[\${3};1m\${1} \033[0m"
}

ssserverstatus(){
    if [ -r /var/run/shadowsocks-libev.pid ]; then
        read pid < /var/run/shadowsocks-libev.pid
        if [ -d "/proc/\${pid}" ]; then
            twistlog "Shadowsocks-libev Service is Running" "\$1" "32"
            status="0"
            return 0
        else
            twistlog "Shadowsocks-libev Service is Stoped" "\$1" "31"
            rm -f /var/run/shadowsocks-libev.pid
            status="1"
            return 1
        fi
    else
        twistlog "Shadowsocks-libev Service is Stoped" "\$1" "31"
        status="2"
        return 2
    fi
}

componentps(){
    if [ "\$(pgrep \${1} | wc -l)" = "0" ]; then
        if [ "\$4" = "enable" ]; then
            twistlog "\${2} Service is Stoped" "\$3" "31"
            return 1
        else
            twistlog "\${2} Service is Disabled" "\$3" "33"
            return 2
        fi
    else
        twistlog "\${2} Service is Running" "\$3" "32"
        return 0
    fi
}

echostatus(){
    if [ "\$2" = "Starting" ]; then
        statusa="Success" && statusb="Failed"
        colora="32" && colorb="31"
    else
        statusa="Failed" && statusb="Success"
        colora="31" && colorb="32"
    fi
    if [ "\$1" = "0" ]; then
        twistlog "\${2} \${3} Service \${statusa}" "echo" "\${colora}"
    else
        twistlog "\${2} \${3} Service \${statusb}" "echo" "\${colorb}"
    fi
}

twist_status(){
    twistlog "[TWIST Checking Server Status]" "echo" "34"
    ssserverstatus "echo"
    componentps "fail2ban" "Fail2ban Protect" "echo" "enable"
    componentps "$webservername" "Fake Web Redirect" "echo" "$FWS"
    if [ "\$(lsmod | grep bbr)" = "" ]; then
        twistlog "TCP BBR Support is Disabled" "echo" "33"
    else
        twistlog "TCP BBR Support is Enabled" "echo" "32"
    fi
}

twist_start(){
    twistlog "[TWIST Starting Server Service]" "echo" "34"
    ssserverstatus
    if [ "\$?" = "0" ]; then
       twistlog "Shadowsocks-libev Service is Already Running" "echo" "32"
        status="0"
    else
        ${ssserverpath} -uv -c /etc/shadowsocks-libev/config.json -f /var/run/shadowsocks-libev.pid
        [ -e /etc/twist/twistprotect ] || echo -e "# \${date} [Shadowsocks Protect Services Enabled] " >> /etc/twist/twistprotect
        ssserverstatus
        echostatus "\$?" "Starting" "Shadowsocks-libev"
    fi
    componentps "fail2ban" "Fail2ban Protect" "hide" "enable"
    if [ "\$?" = "0" ]; then
        twistlog "Fail2ban Protect Service is Already Running" "echo" "32"
    else
        systemctl start fail2ban
        componentps "fail2ban" "Fail2ban Protect" "hide" "enable"
        echostatus "\$?" "Starting" "Fail2ban Protect"
    fi
    componentps "$webservername" "Fake Web Redirect" "hide" "$FWS"
    case "\$?" in
        0)
            twistlog "Fake Web Redirect Service is Already Running" "echo" "32"
            ;;
        1)
            systemctl start ${webservername}
            componentps "$webservername" "Fake Web Redirect" "hide" "$FWS"
            echostatus "\$?" "Starting" "Fake Web Redirect"
            ;;
        2)
            componentps "$webservername" "Fake Web Redirect" "echo" "disabled"
            ;;
    esac
}

twist_stop(){
    twistlog "[TWIST Stopping Server Service]" "echo" "34"
    ssserverstatus
    if [ "\$?" = "0" ]; then
        [ -e /etc/twist/twistprotect ] && { echo -e "# \${date} [Shadowsocks Protect Services Disabled] " >> /var/log/twist; rm -f /etc/twist/twistprotect; }
        kill -9 \$pid
        rm -f /var/run/shadowsocks-libev.pid
        [ -e /etc/systemd/system/shadowsocks-libev.service ] && systemctl stop shadowsocks-libev
        ssserverstatus
        echostatus "\$?" "Stopping" "Shadowsocks-libev"
    else
        twistlog "Shadowsocks-libev is Already Stopped" "echo" "31"
        status="0"
    fi
    componentps "fail2ban" "Fail2ban Protect" "hide" "enable"
    if [ "\$?" = "0" ]; then
        systemctl stop fail2ban
        componentps "fail2ban" "Fail2ban Protect" "hide" "enable"
        echostatus "\$?" "Stopping" "Fail2ban Protect"
    else
        twistlog "Fail2ban Protect Service is Already Stopped" "echo" "31"
    fi
    componentps "$webservername" "Fake Web Redirect" "hide" "$FWS"
    case "\$?" in
        0)
            systemctl stop ${webservername}
            componentps "$webservername" "Fake Web Redirect" "hide" "$FWS"
            echostatus "\$?" "Stopping" "Fake Web Redirect"
            ;;
        1)
            twistlog "Fake Web Redirect Service is Already Stopped" "echo" "31"
            ;;
        2)
            componentps "$webservername" "Fake Web Redirect" "echo" "disabled"
            ;;
    esac
}

twist_restart(){
    twistlog "[TWIST Restarting Server Service]" "echo" "34"
    twistlog "Twist Trying to Restart Service" "echo" "32"
    /usr/bin/twist stop
    sleep 2
    /usr/bin/twist start
}

twist_custom(){
    twistlog "[TWIST Loading Shadowsocks Configurator]" "echo" "34"
    sleep 2
    nano /etc/shadowsocks-libev/config.json
    /usr/bin/twist restart
}

twist_do(){
    twistlog "[TWIST Preparing \${2}]" "echo" "34"
    sleep 2
    cd /tmp
    wget -t 3 -T 30 -nv -O "twist.sh" "https://raw.githubusercontent.com/Unbinilium/Twist/master/twist" && { chmod -x twist.sh; bash twist.sh \${1}; }
    if [ "\$?" = "0" ]; then
        status="0"
    else
        status="1"
    fi
}

case "\$1" in
    status|start|stop|restart|custom)
        twist_\${1}
        ;;
    update)
        twist_do "update" "Update"
        ;;
    uninstall)
        twist_do "uninstall" "Uninstall"
        ;;
    *)
        if [ -z "$1" ]; then
            twist_status
        else
            echo "Usage: \$0 { status | start | stop | restart | custom | update | uninstall }"
            status="0"
        fi
        ;;
esac
exit \$status

EOF
    cat > /root/twistprotect <<-EOF
#!/bin/bash

date="\$(date +%Y-%m-%d-%H:%M:%S)"
echo -e "# [\033[34;1mTWIST Shadowsocks-libev Service Protect Services\033[0m]"

twistlog(){
    [ -e /var/log/twist ] || touch /var/log/twist
    echo "# \${date} \${1} " >> /var/log/twist
}

twistprotect(){
    echo -e "# \033[32;1mTWIST Shadowsocks Protect Services Enabled \033[0m"
    if [ "\$(ps -ef | grep -v grep | grep -i "${ssserverpath}" | awk '{print \$2}')" = "" ]; then
        echo -e "# \033[31;1mShadowsocks-libev Service Stopped Detected \033[0m"
        twistlog "Shadowsocks-libev Service Stopped Detected"
        /usr/bin/twist restart
        if [ "\$(ps -ef | grep -v grep | grep -i "${ssserverpath}" | awk '{print \$2}')" = "" ]; then
            twistlog "Shadowsocks-libev Service Restart Failed"
            twistlog "[Shadowsocks Protect Services Disabled Due To Error]"
            rm -f /etc/twist/twistprotect
        else
            twistlog "Shadowsocks-libev Service Restart Success"
        fi
    else
        echo -e "# \033[32;1mShadowsocks-libev Service Running Detected \033[0m"
    fi
}

if [ -e /etc/twist/twistprotect ]; then
    twistprotect
else
    echo -e "# \033[31;1mTWIST Shadowsocks Protect Services Disabled \033[0m"
fi

EOF
    chmod +x /etc/network/if-pre-up.d/iptablesload /etc/network/if-pre-up.d/ip6tablesload /etc/rc.local /usr/bin/twist /root/twistprotect
    chmod 600 /etc/shadowsocks-libev/config.json
    systemctl enable iptables fail2ban cron
    systemctl restart iptables fail2ban cron
    iptables-restore < /etc/iptables.rules
    ip6tables-restore < /etc/ip6tables.rules
    sysctl -p
    ldconfig
    if [ "$FWS" = "enable" ]; then
        timemachine "backup" "/var/www/html/.htaccess" "/etc/twist/.htaccess"
        timemachine "backup" "/var/www/html/index.html" "/etc/twist/index.html"
        cat > /var/www/html/.htaccess <<-EOF
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteRule (.*) http://${OBFSHOST}/\$1 [R=301,L]
</IfModule>
EOF
        cat > /var/www/html/index.html <<-EOF
<head><meta http-equiv="refresh" content="0;url=http://${OBFSHOST}"></head>
EOF
        systemctl restart ${webservername}
    fi
    twistlog "[TWIST Installed]"
    sleep 3
    echo ""
    twist start
    sleep 3
    timemachine "backup" "/etc/crontab" "/etc/twist/crontab"
    [ -e /etc/crontab ] || touch /etc/crontab
    echo "*/1 * * * * root bash /root/twistprotect" >> /etc/crontab
    sleep 2
}

function servicesstatus(){
    clear
    twistprint
    echo -e "                            [\033[32;1mInstall Complete\033[0m]"
    echo -e "        [\033[32;1mPlease Press Enter to Show Connect Infomation and EXIT\033[0m]"
    twistprint banner
    read -p ""
    echo "ss://$(echo -n "${METHOD}:${PASSWORD}@${PUBLICIP}:${PORT}?plugin=obfs-local;obfs-host=${OBFSHOST};obfs-uri=${OBFSURI};obfs=${OBFS}#Twist" | base64 -w 0)" | qr
    echo -e "# [\033[32;1mss://\033[0m\033[34;1m$(echo -n "${METHOD}:${PASSWORD}@${PUBLICIP}:${PORT}?plugin=obfs-local;obfs-host=${OBFSHOST};obfs-uri=${OBFSURI};obfs=${OBFS}#Twist" | base64 -w 0)\033[0m]"
    echo -e "# [\033[32;1mServer IP:\033[0m \033[34;1m${PUBLICIP}\033[0m\c"
    [ ! "$IPV6ENABLE" = "false" ] && echo -e "(\033[34;1m${PUBLICIPv6}\033[0m)\c"
    echo -e " \033[32;1mPassWord:\033[0m \033[34;1m${PASSWORD}\033[0m \033[32;1mEncryption:\033[0m \033[34;1m${METHOD}\033[0m \033[32;1mOBFS:\033[0m \033[34;1m${OBFS}\033[0m \033[32;1mOBFS-HOST:\033[0m \033[34;1m${OBFSHOST}\033[0m \033[32;1mOBFS-URI:\033[0m \033[34;1m${OBFSURI}\033[0m]"
    serverrestart "Installation"
}

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
date="$(date +%Y-%m-%d-%H:%M:%S)"
[ -d /tmp ] || mkdir /tmp
cd /tmp

case "$1" in
    install|update|uninstall)
        ${1}_twist
        exit 0
        ;;
    *)
        if [ -z "$1" ]; then
            install_twist
        else
            echo "Usage: $0 { install | update | uninstall }"
            exit 1
        fi
        ;;
esac
