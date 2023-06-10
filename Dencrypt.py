#!/usr/bin/python
# -*- coding:utf-8 -*-
#
# Batch Decryption 202009 (BatchEncryption Build 201610)
#

import os
import sys

encrypt_file = ''
encodeErrByteArray = [b'\xfe', b'\xff']


def decryption(data):
    # 去除头部后的源代码下标开始位置
    i = data.index(b'163.com\r\n') + 9
    vars = {}
    length = len(data)
    source = ''
    while i < length:
        Data = run(vars, data, i)
        i = Data.get('index')
        source += Data.get('buf')
    return source


def run(vars, data, i):
    buf = ''
    f = 0
    t = 0
    x = False
    l = len(data)
    while (True):
        if data[i] == 0x0d and data[i+1] == 0x0a:  # == '\r'
            i += 2
            break
        if data[i] == 0x25:  # get %var:~x,y% %0     XXX  => 0x25 == %
            if not x:
                x = True
                f = i
            else:
                x = False
                t = i
                rst = var_percent(data[f:t+1], vars)
                buf += rst
            i += 1
        else:
            if not x:
                try:
                    buf += str(data[i:i+1], encoding="utf-8")
                    i += 1
                except Exception as err:
                    # 过滤掉无法解析的字节
                    if data[i:i+1] in encodeErrByteArray:
                        buf = ''
                        i += 1
                    else:
                        # 以ansi码解析中文
                        chinese = b''
                        temp = i
                        while (str(data[temp:temp+1]).find('x') >= 0):
                            chinese += data[temp:temp+1]
                            temp += 1
                        buf += chinese.decode('ansi', 'ignore')
                        i = temp
            else:
                if (f + 1 == i) and ((data[i] >= 0x30 and data[i] <= 0x39) or data[i] == 0x2a):
                    x = False
                    t = i
                    rst = str(data[f:t+1], encoding="utf-8")
                    buf += rst
                i += 1
        if i >= l:
            break
    # print(buf)
    bufs = buf.split('&@')
    for var in bufs:
        if var[0:4] == 'set ':
            var = var[4:]
            b = var.find('=')
            vars[var[0:b]] = var[b+1:].replace('^^^', '^')
    buf += '\r\n'
    return {'index': i, 'buf': buf}


"""
%':~-53,1%
':~-53,1
["'", '-53,1']
"""


def var_percent(data, vars):
    full = str(data, encoding="utf-8")
    buf = full[1:len(full)-1]
    buf = buf.split(':~')
    var = buf[0]
    if not var in vars:
        vars[var] = os.getenv(var)
    ent = vars[var]
    if (len(buf) > 1):
        l = len(ent)
        buf = buf[1].split(',')
        f = int(buf[0])
        t = int(buf[1])
        if f < 0:
            f, t = l + f, t
        rst = ent[f: f+t]
    else:
        rst = full
    return rst


def makeFile(path, content):
    try:
        encryptionFilePath = os.path.dirname(sys.argv[1])
        encryptionFileName = os.path.basename(sys.argv[1])
        encryptionFile = encryptionFileName.split('.')
        decryptionFileName = encryptionFile[0] + \
            '_denctyption.' + encryptionFile[1]
        decryptionFile = encryptionFilePath + '/' + decryptionFileName
        print(decryptionFile)
        file = open(decryptionFile, 'w+')
        file.write(content)
        file.close()
    except Exception as err:
        print(err)
        exit


if __name__ == '__main__':

    try:
        if len(sys.argv) < 2:
            print('param len error\nuse: python dencrypt.py encrypt.bat')
            exit
        encrypt_file = sys.argv[1]
        file = open(encrypt_file, "rb")
        data = file.read()
        file.close()
        source = decryption(data)
        # makeFile(encrypt_file, source)
    except Exception as err:
        print(err)
        exit
