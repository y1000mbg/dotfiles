# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
[ -r /home/y_shirai/.byobu/prompt ] && . /home/y_shirai/.byobu/prompt   #byobu-prompt#

## 2018.04.29 add
# C-sでターミナルのスクリーンロックをしない
stty stop undef

# 起動時byoubuを起動
# /usr/bin/byobu

# ranger起動用エイリアス
alias r='ranger'

## 2018.04.30 add rbenv
#  rbenvがインストール済みの場合実行
if [ -e /usr/bin/rbenv ]; then
	eval "$(rbenv init -)"
fi

## 2018.05.02 add monoaudio_deviceset
## ThinkPadx230用のモノラル設定
function mono (){
       	# デバイス名をセット
       	device=`pacmd stat | grep "Default sink name:" | sed s/"Default sink name: "//`;
	# 仮想デバイスを作成 （再起動でもとに戻る）
	pacmd load-module module-remap-sink master=${device} sink_name=mono channels=2 channel_map=mono,mono;
}

## 2018.05.05 add gitrepository_convert_tool
## https:~のgithubリポジトリーをssh経由でcloneする形式に変更
function h2s (){
	if [ $# -ne 1 ] ; then
		echo "h2s エラー 必要引数:1 / 今回:$#"
		return 1
	fi
	echo "git clone ${1}" | sed -e s#https://github.com/#git@github.com:# -e "s#\$#.git#"
}

## 2018.06.07 add 
## ディレクトリ内のファイルを連番にリネーム
function numv () {
	## ファイル数を求める
	fcnt=$(( `ls -l | wc -l` - 1))
	k=`echo -n $fcnt | wc -c`

	## 0埋めしたファイル数までの連番を生成し配列へ格納
	array=(`seq -f %0${k}g 1 $fcnt`)

	## 繰り返しでリネーム
	### fn ファイル名
	### ext 拡張子（ドット以降）
	### ls --color=nonはcygwinで端末制御コードが解釈されて動作がおかしくなるので無効化している
	cnt=0
	for fn in `ls --color=non`
	do
		ext=`echo $fn | cut -d"." -f2`
		mv -v $fn ${array[$cnt]}.$ext
		let cnt++
	done
}
eval "$(rbenv init -)"

## 2018.07.03 add
## githubの画像リポジトリからurl取得する
function picurl () {
  year=`echo $1 | cut -c1-4`
  month=`echo $1 | cut -c5-6`
  day=`echo $1 | cut -c7-8`
  for num in `seq -f %03g $2 $3`
  do
    echo '<img src="https://github.com/y1000mbg/blog_pic/blob/master/'${year}'/'${month}'/'${day}'/'${num}'.png?raw=true" align="left">'
    echo '<br style="clear:left;">'
  done
}

alias nkfowl='nkf --overwrite -w -Lu'
alias msd='mkdocs serve --dev-addr=` hostname -i | cut -d" " -f 1`:8000'
alias gacp='git add --all && git commit -m"commit" && git push'

function indexcreate () {
  # tmpファイル初期化
  echo -n > /tmp/filelist_1
  echo -n > /tmp/filelist_2

  # ファイル名からymd取得
  grep -H "^# " *.md | cut -c 1-8 | gawk '{print "- "$0}' > /tmp/filelist_1
  # 見出し1: ファイル名取得
  grep -H "^# " *.md | gawk -F":" '{print $2":",$1}' | cut -c 3- > /tmp/filelist_2
  echo "pagesへ追加してください"
  paste -d"_" /tmp/filelist_1 /tmp/filelist_2
  echo -e "---\\nカテゴリーへ追加してください"
  # - [見出し1](ファイル名)取得
  grep -H "^# " *.md | gawk -F":" '{print $2,$1}' | cut -c 3- | gawk '{print "- ["$1"]("$2")"}'
}
