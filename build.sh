#!/bin/bash
# 由 hosts.source.txt 生成其他文件

ALL_ISP="dianxin other"
ISP=""
ISP_NAME=""

SOURCE_FILE="hosts.source.txt"
HOSTS_FILE=""

HOST_RULES=""
RESOLVER_RULES=""
RULES_FILE="host_rules.md"
DF_TXT_FILE="df.txt"

TMP_PROXY_HOSTS_FILE=""
TMP_JSON_FILE=""
DF_PY_FILE=""
DF_PY_FILE_TEMPLATE="_df.py"


_df_txt_file_header() {
cat <<EOF > $DF_TXT_FILE
# update: $(date)
# repo: https://github.com/rabbit2123/domain-fronting
#
# 下载本文件：
#   https://raw.githubusercontent.com/rabbit2123/domain-fronting/main/$DF_TXT_FILE
#   https://cf.rabbit2123.kozow.com/gh/domain-fronting/main/$DF_TXT_FILE
#   curl -O https://yelp.com/rabbit2123/domain-fronting/main/$DF_TXT_FILE -H 'host: raw.githubusercontent.com'
#
# 如何使用：
#   支持chromium内核的浏览器如Google浏览器，微软edge，brave等。
#   在命令行启动，或者修改浏览器快捷方式。
#   在powershell上运行要在命令前加上 '& '，不包含引号。
#   浏览器的执行文件路径可在浏览器打开 chrome://version 找到。
#   微软edge还需关闭浏览器的 设置->系统与性能->启动增强。
#
# 支持的网站：
EOF
}

_rules_file_header() {
cat <<EOF > $RULES_FILE
# 支持的网站列表
具体哪些域名使用了域前置，哪些可以通过cloudflare workers/pages转发，请看[hosts.source.txt](https://github.com/rabbit2123/domain-fronting/blob/main/hosts.source.txt)。

EOF
}

_write_rules_file() {
    echo "" >> $RULES_FILE
    echo "## ${ISP_NAME}" >> $RULES_FILE
    echo '```' >> $RULES_FILE
    echo -n "--host-rules=\"${HOST_RULES%, }\"" >> $RULES_FILE
    echo " --host-resolver-rules=\"${RESOLVER_RULES%, }\"" >> $RULES_FILE
    echo '```' >> $RULES_FILE
}

_tmp_json_file_start() {
cat <<EOF > $TMP_JSON_FILE
{
  "mappings": [
EOF
}

_tmp_json_file_end() {
    local tmp_json_file=$(mktemp)
    cat $TMP_JSON_FILE |grep -v '^ *$' |sed '$s/},/}/g' > $tmp_json_file

cat <<EOF >> $tmp_json_file
  ]
}
EOF
    cat $tmp_json_file |jq . > $TMP_JSON_FILE
    rm $tmp_json_file
}

_write_df_txt_file() {
    echo "" >> $DF_TXT_FILE
    echo "${ISP_NAME}：" >> $DF_TXT_FILE
    echo -n "\"浏览器可执行文件\"" >> $DF_TXT_FILE
    echo -n " --host-rules=\"${HOST_RULES%, }\"" >> $DF_TXT_FILE
    echo " --host-resolver-rules=\"${RESOLVER_RULES%, }\"" >> $DF_TXT_FILE
    echo "" >> $DF_TXT_FILE
}

write_headers() {
    _df_txt_file_header
    _rules_file_header

    while IFS='' read -r line; do
        # 网站名称以 === 开头
        echo "$line" |grep '^ *===' >/dev/null
        if [ "$?" -eq 0 ]; then
            local line_array=($line)
            unset line_array[0]
            local title=${line_array[@]}
            echo "- $title" >> $RULES_FILE
            echo "#   $title" >> $DF_TXT_FILE
        fi
    done < "$SOURCE_FILE"
}

_write_title() {
    local line_array=($@)
    unset line_array[0]
    local title=${line_array[@]}
    echo "" >> $HOSTS_FILE
    echo "# === $title" >> $HOSTS_FILE
}

_write_host() {
    local line_array=($@)
    local net_type=${line_array[1]}
    if [ "$net_type" == "common" ] || [ "$net_type" == "$ISP" ]; then
        # ip front-domain
        echo "${line_array[3]} ${line_array[2]}" >> $HOSTS_FILE
    fi
}

_make_temp_rule() {
    local line_array=($@)
    local net_type=${line_array[1]}

    # 从第6个字段开始作为host域名
    local hosts=$(echo ${line_array[@]} \
            |awk 'BEGIN{OFS=" "} {
                for (i=6;i<=NF;i++)
                    printf "%s%s", $i, (i<NF ? OFS : "")}')

    if [ "$net_type" == "common" ] || [ "$net_type" == "$ISP" ]; then
        # map front-domain ip
        RESOLVER_RULES+="MAP ${line_array[2]} ${line_array[3]}, "
        for host in $hosts; do
            # map host front-domain:port
            HOST_RULES+="MAP $host ${line_array[2]}:${line_array[4]}, "
        done
    fi
}

_write_json() {
    local line_array=($@)
    local net_type=${line_array[1]}

    # 第6字段开始为host域名，以,隔开
    local patterns=$(echo ${line_array[@]}|awk 'BEGIN{OFS=","} {for (i=6;i<=NF;i++) printf "%s%s", "\"" $i "\"", (i<NF ? OFS : "")}')

    if [ "$net_type" == "common" ] || [ "$net_type" == "$ISP" ]; then
cat <<EOF >> $TMP_JSON_FILE
      {
          "patterns": [${patterns}],
          "server": "${line_array[2]}",
          "port": ${line_array[4]}
      },
EOF
    fi
}

df_py_file_header() {
cat <<EOF > $DF_PY_FILE
# update: $(date)
# repo: https://github.com/rabbit2123/domain-fronting
#
# Usage:
#   mitmdump -s ./df.py -p 8080
#

# cloudflare workers/pages 域名和端口
SERVER = None
PORT = "443"


EOF
}

_write_df_py_file() {
    echo -n "df_hosts = " >> $DF_PY_FILE
    cat $TMP_JSON_FILE >> $DF_PY_FILE
    echo "" >> $DF_PY_FILE
    echo "proxy_hosts = [" >> $DF_PY_FILE
    cat $TMP_PROXY_HOSTS_FILE >> $DF_PY_FILE
    echo "]" >> $DF_PY_FILE
    echo "" >> $DF_PY_FILE
    echo "" >> $DF_PY_FILE
    cat $DF_PY_FILE_TEMPLATE >> $DF_PY_FILE
}

_write_proxy_host() {
    local line_array=($@)
    unset line_array[0]
    for host in "${line_array[@]}"; do
        echo "    \"$host\"," >> $TMP_PROXY_HOSTS_FILE
    done
}


hosts_header() {
cat <<EOF > $HOSTS_FILE
# update: $(date)
# repo: https://github.com/rabbit2123/domain-fronting

EOF
}

generate_files() {
    TMP_JSON_FILE=$(mktemp)
    TMP_PROXY_HOSTS_FILE=$(mktemp)
    _tmp_json_file_start

    while IFS='' read -r line; do
        # 网站名称以 === 开头
        echo "$line" |grep '^ *===' >/dev/null
        if [ "$?" -eq 0 ]; then
            # hosts
            _write_title $line
            continue
        fi

        # 以 front 开头的行为domain fronting的域名
        echo "$line" |grep '^ *front' >/dev/null
        if [ "$?" -eq 0 ]; then
            _write_host $line
            _write_json $line
            _make_temp_rule $line
            continue
        fi

        # 以 proxy 开头的行为通过proxy访问的域名
        echo "$line" |grep '^ *proxy' >/dev/null
        if [ "$?" -eq 0 ]; then
            _write_proxy_host $line
        fi
    done < "$SOURCE_FILE"

    _tmp_json_file_end
    _write_df_py_file
    _write_df_txt_file
    _write_rules_file

    HOST_RULES=""
    RESOLVER_RULES=""

    rm $TMP_JSON_FILE
    rm $TMP_PROXY_HOSTS_FILE
}


write_headers

for isp in $ALL_ISP; do
    case "$isp" in
        "dianxin")
            ISP_NAME="电信网络"
            ;;

        "other")
            ISP_NAME="其他网络"
            ;;
    esac

    ISP=$isp
    HOSTS_FILE="hosts-${isp}.txt"
    DF_PY_FILE="df-${isp}.py"
    hosts_header
    df_py_file_header
    generate_files
done

