#!/usr/bin/env python3
"""
从 DEX 文件提取类名列表
"""
import sys
import struct
import os

def read_uleb128(data, offset):
    """读取 ULEB128 编码的整数"""
    result = 0
    shift = 0
    while True:
        byte = data[offset]
        offset += 1
        result |= (byte & 0x7f) << shift
        if (byte & 0x80) == 0:
            break
        shift += 7
    return result, offset

def parse_dex_strings(dex_data):
    """解析 DEX 文件中的字符串池"""
    # DEX 文件头
    magic = dex_data[0:8]
    if not magic.startswith(b'dex\n'):
        print("不是有效的 DEX 文件")
        return []
    
    # 读取字符串ID列表的偏移和大小
    string_ids_size = struct.unpack('<I', dex_data[0x38:0x3C])[0]
    string_ids_off = struct.unpack('<I', dex_data[0x3C:0x40])[0]
    
    strings = []
    for i in range(string_ids_size):
        # 每个字符串ID占4字节，指向字符串数据的偏移
        string_data_off = struct.unpack('<I', dex_data[string_ids_off + i*4:string_ids_off + i*4 + 4])[0]
        
        # 读取字符串长度（ULEB128编码）
        str_len, data_offset = read_uleb128(dex_data, string_data_off)
        
        # 读取字符串内容
        try:
            string = dex_data[data_offset:data_offset + str_len].decode('utf-8', errors='ignore')
            strings.append(string)
        except:
            pass
    
    return strings

def extract_class_names(dex_file):
    """从 DEX 文件提取类名"""
    try:
        with open(dex_file, 'rb') as f:
            dex_data = f.read()
        
        strings = parse_dex_strings(dex_data)
        
        # 过滤出看起来像类名的字符串
        class_names = []
        for s in strings:
            # 类名通常是 Lcom/example/ClassName; 格式
            if s.startswith('Lcom/') and s.endswith(';'):
                # 转换为 Java 类名格式
                class_name = s[1:-1].replace('/', '.')
                class_names.append(class_name)
        
        return class_names
    except Exception as e:
        print(f"解析失败: {e}")
        return []

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("用法: python3 extract_classes.py <dex_file>")
        sys.exit(1)
    
    dex_file = sys.argv[1]
    class_names = extract_class_names(dex_file)
    
    print(f"从 {dex_file} 提取到 {len(class_names)} 个类")
    
    # 输出所有类名
    for name in sorted(set(class_names)):
        print(name)
