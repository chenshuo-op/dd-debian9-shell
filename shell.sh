#!/usr/bin/env bash

#检查系统
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
  fi
}

#检查Linux版本
check_version(){
	if [[ -s /etc/redhat-release ]]; then
		version=`grep -oE  "[0-9.]+" /etc/redhat-release | cut -d . -f 1`
	else
		version=`grep -oE  "[0-9.]+" /etc/issue | cut -d . -f 1`
	fi
	bit=`uname -m`
	if [[ ${bit} = "x86_64" ]]; then
		bit="x64"
	else
		bit="x32"
	fi
}

install(){
        echo "————————————此脚本只运行于debian9————————————"
        echo "1: 安装锐速内核"
        echo "2: 使用锐速加速"
        echo "3: 安装v2ray和xray"
	echo "4: 退出脚本"
	read -p " 请输入数字 :" num
  case "$num" in
	1)
	bash <(wget --no-check-certificate -qO- 'https://raw.githubusercontent.com/chenshuo-dr/dd-debian9-install/master//Debian_Kernel.sh')
	read -p "需要重启VPS后，才能使用锐速，是否现在重启 ? [Y/n] :" yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
		echo -e "VPS 重启中..."
		reboot
	else
	    sleep 1s
	    install
	fi
	;;
	2)
	bash <(wget --no-check-certificate -qO- https://github.com/chenshuo-as/LotServer_Vicer/raw/master/Install.sh) install
	sed -i '/advinacc/d' /appex/etc/config
	sed -i '/maxmode/d' /appex/etc/config
	echo -e "advinacc=\"1\"
maxmode=\"1\"">>/appex/etc/config
	/appex/bin/lotServer.sh restart
	sleep 1s
	install
	;;
	3)
	wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/chenshuo-dr/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
	;;
	4)
	exit 1
	;;
	*)
	clear
	echo -e "输入错误！请输入正确数字 [0-4]"
	sleep 1s
	install
	;;
   esac
}

check_sys
check_version
[[ ${release} != "debian" ]] && [[ ${version} != "9" ]] && [[ ${bit} != "x64" ]] && echo -e "脚本只支持debian9 x64!" && exit 1
apt-get update
install
