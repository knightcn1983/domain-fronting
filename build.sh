#!/bin/bash

# 由 hosts.source.txt 生成四个文件：
# hosts.txt, host_rules.md, domain_fronting.json, df.py

SOURCE_FILE="hosts.source.txt"
ALL_LINES=$(wc -l "$SOURCE_FILE" |awk '{print $1}')
LINE_NUMBER=0

HOSTS_FILE="hosts.txt"
JSON_FILE="domain_fronting.json"

HOST_RULES=""
HOST_RESOLVER_RULES=""
RULES_FILE="host_rules.md"

DF_FILE="df.py"
DF_FILE_TEMPLATE="_df.py"

FRONT_HOSTS=""
PROXY_HOSTS=""
TMP_PROXY_HOSTS_FILE=""


_rules_file_header() {
cat <<EOF > $RULES_FILE
### 支持的网站列表
（本文档由脚本生成）

相同参数的内容合并在一起，可以让多个网站使用域前置。

如果部署并设置了 cloudflare workers，proxy hosts 可通过其转发。

EOF
}

_json_file_start() {
cat <<EOF > $JSON_FILE
{
  "mappings": [
EOF
}

_json_file_end() {
    local tmp_json_file=$(mktemp)
    cat $JSON_FILE |grep -v '^ *$' |sed '$s/},/}/g' > $tmp_json_file

cat <<EOF >> $tmp_json_file
  ]
}
EOF
    cat $tmp_json_file |jq . > $JSON_FILE
    rm $tmp_json_file
}

_write_host() {
    local line_array=($@)
    # ip and front domain
    echo "${line_array[2]} ${line_array[1]}" >> $HOSTS_FILE
}

_make_temp_rule() {
    local line_array=($@)
    HOST_RESOLVER_RULES+="MAP ${line_array[1]} ${line_array[2]}, "

    # 从第 5 个字段开始作为 host 域名
    local hosts=$(echo ${line_array[@]} \
	    |awk 'BEGIN{OFS=" "} {
		for (i=5;i<=NF;i++)
		    printf "%s%s", $i, (i<NF ? OFS : "")}')
    for host in $hosts; do
        HOST_RULES+="MAP $host ${line_array[1]}:${line_array[3]}, "
        FRONT_HOSTS+="${host} "
    done
}

_write_rule() {
    # 把网站 rules 写入文件，同时清零

    if [ "$HOST_RULES" ]; then
        echo "" >> $RULES_FILE	
        echo "domain fronting:" >> $RULES_FILE
        echo '```' >> $RULES_FILE
        for host in $FRONT_HOSTS; do
            echo "$host" >> $RULES_FILE
        done
        echo '```' >> $RULES_FILE

        cat <<EOF >> $RULES_FILE
$(echo '```')
--host-rules="${HOST_RULES%, }" --host-resolver-rules="${HOST_RESOLVER_RULES%, }"
$(echo '```')

EOF
    fi

    if [ "$PROXY_HOSTS" ]; then
        echo "" >> $RULES_FILE
        echo "proxy hosts:" >> $RULES_FILE
        echo '```' >> $RULES_FILE
	for host in $PROXY_HOSTS; do
            echo "$host" >> $RULES_FILE
        done
        echo '```' >> $RULES_FILE
        echo "" >> $RULES_FILE
    fi

    HOST_RULES=""
    HOST_RESOLVER_RULES=""
    FRONT_HOSTS=""
    PROXY_HOSTS=""
}

_write_json() {
    local line_array=($@)
    # 第 5 字段开始为 host 域名，以 , 隔开
    local patterns=$(echo ${line_array[@]}|awk 'BEGIN{OFS=","} {for (i=5;i<=NF;i++) printf "%s%s", "\"" $i "\"", (i<NF ? OFS : "")}')

cat <<EOF >> $JSON_FILE
      {
          "patterns": [${patterns}],
          "server": "${line_array[1]}",
          "port": ${line_array[3]}
      },
EOF
}

_df_file_header() {
cat <<EOF > $DF_FILE
# 本文件由 $DF_FILE_TEMPLATE, $JSON_FILE 合成。
# df_hosts 内容与 $JSON_FILE 相同。
# proxy_hosts 则是 $SOURCE_FILE 的 -proxy 行。
# 
# Usage:
#    mitmdump -s ./df.py
#

# cloudflare workers 域名和端口
SERVER = None
PORT = "443"


EOF
}

_write_df_file() {
    echo -n "df_hosts = " >> $DF_FILE
    cat $JSON_FILE >> $DF_FILE
    echo "" >> $DF_FILE
    echo "proxy_hosts = [" >> $DF_FILE
    cat $TMP_PROXY_HOSTS_FILE >> $DF_FILE
    echo "]" >> $DF_FILE
    echo "" >> $DF_FILE
    echo "" >> $DF_FILE
    cat $DF_FILE_TEMPLATE >> $DF_FILE
}

_write_proxy_host() {
    local line_array=($@)
    unset line_array[0]
    for host in "${line_array[@]}"; do
        echo "    \"$host\"," >> $TMP_PROXY_HOSTS_FILE
        PROXY_HOSTS+="$host "
    done
}

generate_files() {
    _rules_file_header
    _df_file_header
    _json_file_start
    TMP_PROXY_HOSTS_FILE=$(mktemp)
    echo -n "" > $HOSTS_FILE

    while IFS='' read -r line; do
        LINE_NUMBER=$(($LINE_NUMBER + 1))

	# 网站名称以 === 开头
        echo "$line" |grep '^ *===' >/dev/null
        if [ "$?" -eq 0 ]; then
	    # hosts.txt
            echo "" >> $HOSTS_FILE
            echo "# $line" >> $HOSTS_FILE

            # host_rule.md
            # 把上一个网站 rules 写入文件
            _write_rule
	    # 写入网站名称
            echo "-${line//=/}" >> $RULES_FILE
            continue
        fi

	# 以 -front 开头的行为 domain fronting 的域名
        echo "$line" |grep '^ *-front' >/dev/null
        if [ "$?" -eq 0 ]; then
            _write_host $line
            _make_temp_rule $line
            _write_json $line
            continue
        fi

	# 以 -proxy 开头的行为通过 proxy 访问的域名
        echo "$line" |grep '^ *-proxy' >/dev/null
        if [ "$?" -eq 0 ]; then
            _write_proxy_host $line
        fi
    done < "$SOURCE_FILE"

    # 最后一行
    if [ "$LINE_NUMBER" -eq "$ALL_LINES" ]; then
        _write_rule
    fi

    _json_file_end
    _write_df_file
    rm $TMP_PROXY_HOSTS_FILE
}

generate_files

