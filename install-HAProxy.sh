#!/bin/bash

set -e

######## General checks #########

# exit with error status code if user is not root
if [[ $EUID -ne 0 ]]; then
  echo "* 該腳本必須以root權限執行 (sudo)." 1>&2
  exit 1
fi

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "* 該腳本必須安裝curl."
  echo "* 指令: sudo apt -y install curl"
  exit 1
fi

EXPOSED_PORT="25565"
BACKEND_HOST="1.2.3.4:25577"

perform_install() {
 echo "* 啟用 Google BBR 優化網路連線品質"
 curl -fsSL git.io/deploy-google-bbr.sh | bash

 echo "* 安裝 HAProxy 轉封包程式"
 curl -fsSL git.io/deploy-haproxy.sh | sudo -E bash


main() {
  print_brake 72
  echo "* HAProxy 配置."
  echo ""

  export INSTANCE_IPV4=$(curl -4fsSL ip.denpa.io)

  echo -n "* 如使用預設數值,即可Enter跳過配置"
  echo -n "* 請輸入在該主機上開的 Port 編號 [預設: $EXPOSED_PORT]: "
  read -r Port_INPUT

  [ -z "$Port_INPUT" ] && EXPOSED_PORT="$EXPOSED_PORT" || EXPOSED_PORT=$Port_INPUT

  echo -n "* 請輸入目標IP位置及轉發埠 (請保護好這個 IP 避免外洩被繞過攻擊)"
  echo -n "* 範例: 1.2.3.4:25577"
  read -r IP_INPUT

  [ -z "$IP_INPUT" ] && BACKEND_HOST="$BACKEND_HOST" || BACKEND_HOST=$IP_INPUT

  summary

  echo -e -n "\n* 初始配置完成, 要繼續安裝嗎？ (y/N): "
  read -r CONFIRM
  if [[ "$CONFIRM" =~ [Yy] ]]; then
    perform_install
  else
    print_error "安裝中止."
    exit 1
  fi
}

summary() {
  print_brake 62
  echo "「HAProxy 配置」"
  echo "* 主機IP位置: $INSTANCE_IPV4"
  echo "* 主機Port編號: $EXPOSED_PORT"
  echo "* 目標IP位置: $BACKEND_HOST"
  echo ""  
  print_brake 62
}

goodbye() {
  print_brake 62
  echo "* HAProxy 安裝完成"
  echo "*"

  echo "您現在可以使用 '${INSTANCE_IPV4}:${EXPOSED_PORT}' 連接到您的Minecraft伺服器"
  print_brake 62
}

# run script
main
goodbye
