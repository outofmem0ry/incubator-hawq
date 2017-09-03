#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
# 
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

if [ x$1 != x ] ; then
    HAWQ_HOME_PATH=$1
else
    HAWQ_HOME_PATH="\`pwd\`"
fi

if [ "$2" = "ISO" ] ; then
	cat <<-EOF
		if [ "\${BASH_SOURCE:0:1}" == "/" ]
		then
		    HAWQ_HOME=\`dirname "\$BASH_SOURCE"\`
		else
		    HAWQ_HOME=\`pwd\`/\`dirname "\$BASH_SOURCE"\`
		fi
	EOF
else
	cat <<-EOF
		HAWQ_HOME=${HAWQ_HOME_PATH}
	EOF
fi


PLAT=`uname -s`
if [ $? -ne 0 ] ; then
    echo "Error executing uname -s"
    exit 1
fi

cat << EOF

# Replace with symlink path if it is present and correct
if [ -h \${HAWQ_HOME}/../hawq ]; then
    HAWQ_HOME_BY_SYMLINK=\`(cd \${HAWQ_HOME}/../hawq/ && pwd -P)\`
    if [ x"\${HAWQ_HOME_BY_SYMLINK}" = x"\${HAWQ_HOME}" ]; then
        HAWQ_HOME=\`(cd \${HAWQ_HOME}/../hawq/ && pwd -L)\`/.
    fi
    unset HAWQ_HOME_BY_SYMLINK
fi
EOF

cat <<EOF
PATH=\$HAWQ_HOME/bin:\$PATH
EOF

if [ "${PLAT}" = "Darwin" ] ; then
	cat <<EOF
DYLD_LIBRARY_PATH=\$HAWQ_HOME/lib:\$DYLD_LIBRARY_PATH
EOF
else
    cat <<EOF
LD_LIBRARY_PATH=\$HAWQ_HOME/lib:\$LD_LIBRARY_PATH
EOF
fi

#setup PYTHONPATH
cat <<EOF
PYTHONPATH=\$HAWQ_HOME/lib/python:\$PYTHONPATH
EOF

# openssl configuration file path
cat <<EOF
OPENSSL_CONF=\$HAWQ_HOME/etc/openssl.cnf
EOF

# libhdfs3 configuration file path
cat << EOF
LIBHDFS3_CONF=\$HAWQ_HOME/etc/hdfs-client.xml
EOF

# libyarn configuration file path
cat << EOF
LIBYARN_CONF=\$HAWQ_HOME/etc/yarn-client.xml
EOF

# global resource manager configuration file path
cat << EOF
HAWQSITE_CONF=\$HAWQ_HOME/etc/hawq-site.xml
EOF

cat <<EOF
export HAWQ_HOME
export PATH
EOF

if [ "${PLAT}" != "Darwin" ] ; then
cat <<EOF
export LD_LIBRARY_PATH
EOF
else
cat <<EOF
export DYLD_LIBRARY_PATH
EOF
fi

cat <<EOF
export PYTHONPATH
EOF

cat <<EOF
export OPENSSL_CONF
EOF

cat <<EOF
export LIBHDFS3_CONF
EOF

cat <<EOF
export LIBYARN_CONF
EOF

cat <<EOF
export HAWQSITE_CONF
EOF
