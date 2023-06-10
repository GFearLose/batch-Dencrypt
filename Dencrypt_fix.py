#!/usr/bin/python
# -*- coding: UTF-8 -*-

import os
import sys

envars = dict()


def readVarvalue(data):
    length = len(data)
    source = str(data, encoding="utf-8")
    buffer = source[1:length - 1]
    buffer = buffer.split(":~")
    
    varname = buffer[0]
    if not varname in envars:
        envars[varname] = os.getenv(varname)
    
    entity = envars[varname]
    if not entity:  # None value
        return source
    
    length = len(buffer)
    if length > 1:
        length = len(entity)
        buffer = buffer[1].split(",")
        start = int(buffer[0])
        ended = int(buffer[1])
        if start < 0:
            start, ended = length + start, ended
        source = entity[start: start + ended]
    return source


def batchReader(data, index, length):
    buffer = bytes(); source = str()
    
    flag = False; start = 0; ended = 0
    while(True):
        if data[index] in [0xFF, 0xFE]: index += 1; continue
        if data[index] == 0x0D and data[index + 1] == 0x0A: index += 2; break
        if data[index] == 0x25: # 判断变量符号, 获取符号名
            if not flag:
                flag = True
                start = index
            else:
                flag = False
                ended = index + 1
                buffer = data[start:ended]
                source += readVarvalue(buffer)
            index += 1
        else:
            if not flag: # 保存其他字符串
                try:
                    buffer = data[index:index + 1]
                    source += str(buffer, encoding="utf-8")
                    index += 1
                except Exception as err:
                    ansiByte = bytes(); ansiLen = index
                    while (str(buffer).find("x") >= 0):
                        ansiByte += buffer; ansiLen += 1
                        buffer = data[ansiLen:ansiLen + 1]
                    source += ansiByte.decode("ansi", "ignore")
                    index = ansiLen
            else: # 保存变量内的名称
                if (start + 1 == index) and ((data[index] >= 0x30 and data[index] <= 0x39) or data[index] == 0x2A):
                    flag = False
                    ended = index
                    buffer = data[start: ended + 1]
                    source += str(buffer, encoding="utf-8")
                index += 1
        if index >= length: break
    print(source)
    bufs = source.split('&@') # 解析加密变量
    for var in bufs:
        if var[0:4] == 'set ':
            var = var[4:]
            b = var.find('=')
            envars[var[0:b]] = var[b+1:].replace('^^^', '^')
    source += '\r\n'
    return {"index": index, "source": source}


def batchDecryp(data):
    result = dict(); source = str()

    index = 0; length = len(data)
    while (index < length):
        result = batchReader(data, index, length)
        index = result.get("index")
        source = result.get("source")
    return source


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("[x] Script parameter length error!")
        print("[!] Usage: python dencrypt.py encrypt.bat")
        exit(0)

    file = open(sys.argv[1], "rb")
    data = file.read(); file.close()
    batchDecryp(data)

    exit(0)
