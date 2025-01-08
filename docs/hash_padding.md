# Padding

MPad = M || 0x06 || 0x00 ... || 0x80

based on rate
SHA3-512, r = 576
SHA3-256, r = 1088

ex for SHA3-512, MPad until 576 bits

# How padding done in SHA3

M = message

i.e., len(M) = 8m for a nonnegative integer m

In this case, the total number of bytes, denoted by q, that are appended to the message is determined as follows by m and the rate r:

q = (r/8) – (m mod (r/8))

The value of q determines the hexadecimal form of these bytes in this case according to the conversion functions, summarized as

| Type of SHA-3 Function | Number of Padding Bytes | Padded Message |
| --- | --- | --- |
| Hash | q=1 | M \|\| 0x86 |
| Hash | q=2 | M \|\| 0x0680 |
| Hash | q>2 | M \|\| 0x06 \|\| 0x00 ... \|\| 0x80 |
| XOF | q=1 | M \|\| 0x9F |
| XOF | q=2 | M \|\| 0x1F80 |
| XOF | q>2 | M \|\| 0x1F \|\| 0x00 ... \|\| 0x80 |

example : 

for SHA3-256 we have c=512 and r=1600−c=1088

if message is empty, len(M)=0, therefore m=0. Hence 

q = (1088/8) – (0 mod (1088/8)) = 136

Therefore we are in the third case: (q>2)

## Hash function in Kyber

| Kyber Function | Mapping Function | Location | Input (bytes) | Output (bytes) |
|-- | -- | -- | -- | --|
|G | SHA3-512 | Alg.4:2 | 32 | 64 |
|  |   | Alg.8:3 | 32+32 | 64 |
|  |   | Alg.9:5 | 32+32 | 64 |
|H | SHA3-256 | Alg.7:3 | 800 | 32 |
|  |   | Alg.8:2 | 32 | 32 |
|  |   | Alg.8:3 | 800 | 32 |
|  |   | Alg.8:5 | 768 | 32 |
|  |   | Alg.9:8 | 768 | 32 |
|  |   | Alg.9:10 | 768 | 32 |
|XOF | SHAKE128 | Alg.4:6 | 32+1+1 | 768 |
|  |   | Alg.5:6 | 32+1+1 | 768 |
|PRF | SHAKE256 | Alg.4:10 | 32+1 | 192 |
|  |   | Alg.4:14 | 32+1 | 192 |
|  |   | Alg.5:10 | 32+1 | 192 |
|  |   | Alg.5:14 | 32+1 | 128 |
|  |   | Alg.5:17 | 32+1 | 128 |
|KDF | SHAKE256 | Alg.8:5 | 32+32 | 32 |
|  |   | Alg.9:8 | 32+32 | 32 |
|  |   | Alg.9:10 | 32+32 | 32 |

## Rate in SHA3

|Function | Output (bit) | rate | capacity|
|--- | -- | -- | -- |
|SHA3-256 | 256 | 1088 | 512|
|SHA3-512 | 512 | 576 | 1024|
|SHAKE-128 | * | 1344 | 256|
|SHAKE-256 | * | 1088 | 512|
*user defined


refs:

[FIPS-202 specification](https://nvlpubs.nist.gov/nistpubs/fips/nist.fips.202.pdf)

https://crypto.stackexchange.com/questions/40511/padding-in-keccak-sha3-hashing-algorithm