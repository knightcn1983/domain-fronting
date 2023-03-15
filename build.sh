#!/bin/bash


hosts_source_file="hosts.source.txt"
hosts_file="hosts.txt"
tmp_file="hosts-source.tmp"

df_json_file="domain_fronting.json"
tmp_df_json_file="${df_json_file}.tmp"
df_py_file="df.py"
df_py_file_template="_df.py"

host_resolver_rules=""
host_rules=""
host_rules_file="host_rules.md"


generate_df_file() {
cat <<EOF > $tmp_df_json_file
{
    "mappings": [
EOF

    egrep -v "^#|^ *$|===" $hosts_source_file > $tmp_file
    number_of_lines=$(cat $tmp_file|wc -l)
    line_number=0
    comma=","

    while IFS='' read -r line; do
        line_number=$(($line_number + 1))
        if [ "$line_number" -eq "$number_of_lines" ]; then
            comma=""
        fi

        line_array=($line)
        patterns=$(echo ${line_array[@]}|awk 'BEGIN{OFS=","} {for (i=4;i<=NF;i++) printf "%s%s", "\"" $i "\"", (i<NF ? OFS : "")}')

cat <<EOF >> $tmp_df_json_file
        {
            "patterns": [${patterns}],
            "server": "${line_array[0]}",
            "port": ${line_array[2]}
        }$comma
EOF

    done < "$tmp_file"

cat <<EOF >> $tmp_df_json_file
    ]
}
EOF

    cat $tmp_df_json_file |jq . > $df_json_file
    rm $tmp_df_json_file
}

generate_hosts_file() {
cat <<EOF > $hosts_file
update: $(date)
repo: https://github.com/rabbit2123/domain-fronting
EOF

    egrep -v "^#|^ *$" $hosts_source_file > $tmp_file
    while IFS='' read -r line; do
        echo $line |grep '===' >/dev/null
        if [ "$?" -eq 0 ]; then
            echo "" >> $hosts_file
            echo "# $line" >> $hosts_file
            continue
        fi
        line_array=($line)
        # ip and front domain
        echo "${line_array[1]} ${line_array[0]}" >> $hosts_file
    done < "$tmp_file"
    rm $tmp_file
}

write_rule() {
cat <<EOF >> $host_rules_file
$(echo '```')
--host-rules="${host_rules%, }" --host-resolver-rules="${host_resolver_rules%, }"
$(echo '```')

EOF
}

generate_host_rules_file() {
cat <<EOF > $host_rules_file
### 支持的网站列表
（本文档由脚本生成）

相同参数的内容合并在一起，可以让多个网站使用域前置。

EOF
    egrep -v "^#|^ *$" $hosts_source_file > $tmp_file
    number_of_lines=$(cat $tmp_file|wc -l)
    line_number=0
    while IFS='' read -r line; do
        line_number=$(($line_number + 1))
        # 当遇到 === 行时说明上一个规则结束，规则写入文件
        echo $line |grep '===' >/dev/null
        if [ "$?" -eq 0 ]; then
            if [ "$host_rules" ]; then
                write_rule
            fi
            # 网站名称
            echo "-${line//=/}" >> $host_rules_file
            host_rules=""
            host_resolver_rules=""
            continue
        fi

        line_array=($line)
        host_resolver_rules+="MAP ${line_array[0]} ${line_array[1]}, "
        # 从第四个字段开始是后端域名
        hosts=$(echo ${line_array[@]}|awk 'BEGIN{OFS=" "} {for (i=4;i<=NF;i++) printf "%s%s", $i, (i<NF ? OFS : "")}')
        for host in $hosts; do
            host_rules+="MAP $host ${line_array[0]}:${line_array[2]}, "
        done

        # 最后一行，写入规则文件
        if [ "$line_number" -eq "$number_of_lines" ]; then
            write_rule
        fi
    done < "$tmp_file"
    rm $tmp_file
}

generate_df_py_file() {
    cat <<EOF > $df_py_file
#本文件由 $df_py_file_template, $df_json_file 合成，df_hosts 内容与 $df_json_file 相同。
# 
# Usage:
#    mitmdump -s ./df.py
#

EOF

    echo -n "df_hosts = " >> $df_py_file
    cat $df_json_file >> $df_py_file
    echo "" >> $df_py_file
    echo "" >> $df_py_file
    cat $df_py_file_template >> $df_py_file
}

generate_df_file
generate_hosts_file
generate_host_rules_file
generate_df_py_file

