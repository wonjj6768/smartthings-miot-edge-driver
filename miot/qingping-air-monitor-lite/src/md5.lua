-- MD5 extracted from pure_lua_SHA (Lua 5.3+ only)
-- Original: https://github.com/Egor-Skriptunoff/pure_lua_SHA
-- License: MIT

local string_rep, string_sub, string_char, string_format, string_gsub, string_byte =
   string.rep, string.sub, string.char, string.format, string.gsub, string.byte
local string_unpack, string_pack = string.unpack, string.pack

-- Hex/Binary conversion
local function hex_to_bin(hex_string)
   return (string_gsub(hex_string, "%x%x", function(hh)
      return string_char(tonumber(hh, 16))
   end))
end

local function bin_to_hex(binary_string)
   return (string_gsub(binary_string, ".", function(c)
      return string_format("%02x", string_byte(c))
   end))
end

-- MD5 상수 (사전 계산된 값 - 런타임 계산 제거)
local md5_K = {
   0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee, 0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
   0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be, 0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
   0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa, 0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
   0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed, 0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
   0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c, 0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
   0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05, 0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
   0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039, 0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
   0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1, 0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
}
local md5_next_shift = {0, 0, 0, 0, 0, 0, 0, 0, 28, 25, 26, 27, 0, 0, 10, 9, 11, 12, 0, 15, 16, 17, 18, 0, 20, 22, 23, 21}
local md5_H = {0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476}
local common_W = {}


-- Core MD5 transform (INT64 branch from pure_lua_SHA)
local function md5_feed_64(H, str, offs, size)
   local W, K, next_shift = common_W, md5_K, md5_next_shift
   local h1, h2, h3, h4 = H[1], H[2], H[3], H[4]
   for pos = offs + 1, offs + size, 64 do
      W[1], W[2], W[3], W[4], W[5], W[6], W[7], W[8], W[9], W[10], W[11], W[12], W[13], W[14], W[15], W[16] =
         string_unpack("<I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4I4", str, pos)
      local a, b, c, d = h1, h2, h3, h4
      local s = 32-7
      for j = 1, 16 do
         local F = (d ~ b & (c ~ d)) + a + K[j] + W[j]
         a = d
         d = c
         c = b
         b = ((F<<32 | F & (1<<32)-1) >> s) + b
         s = next_shift[s]
      end
      s = 32-5
      for j = 17, 32 do
         local F = (c ~ d & (b ~ c)) + a + K[j] + W[(5*j-4 & 15) + 1]
         a = d
         d = c
         c = b
         b = ((F<<32 | F & (1<<32)-1) >> s) + b
         s = next_shift[s]
      end
      s = 32-4
      for j = 33, 48 do
         local F = (b ~ c ~ d) + a + K[j] + W[(3*j+2 & 15) + 1]
         a = d
         d = c
         c = b
         b = ((F<<32 | F & (1<<32)-1) >> s) + b
         s = next_shift[s]
      end
      s = 32-6
      for j = 49, 64 do
         local F = (c ~ (b | ~d)) + a + K[j] + W[(j*7-7 & 15) + 1]
         a = d
         d = c
         c = b
         b = ((F<<32 | F & (1<<32)-1) >> s) + b
         s = next_shift[s]
      end
      h1 = a + h1
      h2 = b + h2
      h3 = c + h3
      h4 = d + h4
   end
   H[1], H[2], H[3], H[4] = h1, h2, h3, h4
end

-- 공통 MD5 계산 로직
local function compute_md5(message)
   local H = {md5_H[1], md5_H[2], md5_H[3], md5_H[4]}
   local length = #message
   
   -- Process message
   local size_tail = length % 64
   md5_feed_64(H, message, 0, length - size_tail)
   local tail = string_sub(message, length + 1 - size_tail)
   
   -- Padding
   local final_blocks = tail .. "\128" .. string_rep("\0", (-9 - length) % 64) .. string_pack("<I8", length * 8)
   md5_feed_64(H, final_blocks, 0, #final_blocks)
   
   return H
end

-- 바이너리 출력 (16 bytes) - miot.lua에서 사용
local function sum(message)
   local H = compute_md5(message)
   return string_pack("<I4I4I4I4", H[1] & 0xFFFFFFFF, H[2] & 0xFFFFFFFF, H[3] & 0xFFFFFFFF, H[4] & 0xFFFFFFFF)
end

-- Hex 문자열 출력 (32 chars)
local function md5(message)
   local H = compute_md5(message)
   return bin_to_hex(string_pack("<I4I4I4I4", H[1] & 0xFFFFFFFF, H[2] & 0xFFFFFFFF, H[3] & 0xFFFFFFFF, H[4] & 0xFFFFFFFF))
end

return {
   sum = sum,
   md5 = md5,
   hex_to_bin = hex_to_bin,
   bin_to_hex = bin_to_hex,
}
