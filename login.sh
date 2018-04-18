#!/bin/bash

CONFIGS=(
    "名称 端口 IP 用户名 密码"
)

CONFIG_LENGTH=${#CONFIGS[*]}

function LoginMenu(){
    echo "请输入要登录的服务器序号："
    for ((i=0;i<${CONFIG_LENGTH};i++));
    do
        CONFIG=(${CONFIGS[$i]})
        serverNum=$(($i+1))
        echo "  ${serverNum} ${CONFIG[0]}(${CONFIG[2]})"
    done

    echo "请输入您选择登陆的服务器序号："
}

function chooseServer(){
    read serverNum
    variable=$(echo $serverNum | bc)
    if [[ $variable != $serverNum ]]; then
        echo "输入的序号不正确，请重新输入："
        chooseServer;
        return ;
    fi

    if [[ $serverNum -gt $CONFIG_LENGTH ]]; then
        echo "输入的序号不正确，请重新输入："
        chooseServer;
        return ;
    fi

    if [[ $serverNum -lt 1 ]]; then
        echo "输入的序号不正确，请重新输入："
        chooseServer;
        return ;
    fi

    AutoLogin $serverNum;
}

function AutoLogin(){
    num=$(($1-1))
    CONFIG=(${CONFIGS[$num]})
    echo "正在登录 ${CONFIG[0]}(${CONFIG[2]}) ..."
    expect -c "
        spawn ssh -p ${CONFIG[1]} ${CONFIG[3]}@${CONFIG[2]}
        expect {
            \"*assword\" {set timeout 6000; send \"${CONFIG[4]}\n\";}
            \"yes/no\" {send \"yes\n\"; exp_continue;}
            \"Last*\" {send_user \"成功登陆【${CONFIG[0]}(${CONFIG[2]})】\";}
        }
    interact"

    echo "您已成功退出 ${CONFIG[0]}(${CONFIG[2]})"
}

LoginMenu;
chooseServer;
