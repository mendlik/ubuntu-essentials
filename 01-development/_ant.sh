#!/bin/bash -e

# declare -r version="3.3.9";
declare -r version="$(curl -L http://ftp.piotrkosoft.net/pub/mirrors/ftp.apache.org/ant/binaries/ | grep \<a | grep -v [DIR] | head -n 1 | grep -Po '\d+.\d+.\d+' | head -n 1)"
declare -r url="http://ftp.piotrkosoft.net/pub/mirrors/ftp.apache.org/ant/binaries/apache-ant-${version}-bin.tar.gz"
declare -r exportFile="$HOME/.bash_exports"

rm -rf "/tmp/apache-ant-${version}*"
trap "rm -rf /tmp/apache-ant-${version}*" EXIT
wget -LP /tmp "$url"
tar -zxf "/tmp/apache-ant-${version}-bin.tar.gz" -C /tmp
[ -d "/usr/lib/ant" ] || sudo mkdir -p "/usr/lib/ant"
[ -d "/usr/lib/ant/apache-ant-${version}" ] && sudo rm -r "/usr/lib/ant/apache-ant-${version}" || :
sudo mv "/tmp/apache-ant-${version}" "/usr/lib/ant/"

for binfile in $(find /usr/lib/ant/apache-ant-${version}/bin -executable -type f ! -name "*.bat" ! -name "*.py" ! -name "*.pl"); do
    declare binname="$(basename $binfile)"
    sudo update-alternatives --install "/usr/bin/$binname" "$binname" "$binfile" 1000
done;

touch "$exportFile"
if [ -z "$JAVA_HOME" ] && ! grep -qc 'JAVA_HOME' "$exportFile"; then
cat <<EOT | tee -a "$exportFile"

# Java
export JAVA_HOME="\$(update-alternatives --get-selections | grep -e "^java " | tr -s " " | cut -d " " -f 3 | sed -s "s|/jre/bin/java||")"
EOT
fi

if [ -z "$ANT_HOME" ] && ! grep -qc 'ANT_HOME' "$exportFile"; then
cat <<EOT | tee -a "$exportFile"

# Java Build Tool: Ant
export ANT_HOME="\$(update-alternatives --get-selections | grep -e "^ant " | tr -s " " | cut -d " " -f 3 | sed -s "s|/bin/ant||")"
EOT
fi

echo "ANT v${version} installed"
